import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/models/focus_session.dart';
import '../../../core/providers/core_providers.dart';
import '../../focus/providers/focus_session_provider.dart';
import '../models/wellbeing_analytics.dart';

final wellbeingSummaryProvider =
    FutureProvider.autoDispose<WellbeingSummary>((ref) async {
  // Watch focusSessionProvider so session transitions automatically invalidate & recompute stats
  ref.watch(focusSessionProvider);
  final database = ref.watch(databaseProvider);
  final allSessions = await database.getAllSessions();
  final streakDays = await database.calculateCurrentStreakDays();
  final blockedApps = await database.getSelectedBlockedPackageNames();

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);

  // 1. Build last 7 days bar data (from 6 days ago to today)
  final dayFormatter = DateFormat('E'); // Mon, Tue, ...
  final List<DailyFocusBarData> last7Days = [];
  var totalWeeklySeconds = 0;
  var todaySeconds = 0;

  for (int i = 6; i >= 0; i--) {
    final targetDate = todayStart.subtract(Duration(days: i));
    final nextDate = targetDate.add(const Duration(days: 1));
    final targetStartMs = targetDate.millisecondsSinceEpoch;
    final targetEndMs = nextDate.millisecondsSinceEpoch;

    final daySessions = allSessions.where((s) {
      final sessionMs = s.startTime.millisecondsSinceEpoch;
      return sessionMs >= targetStartMs && sessionMs < targetEndMs;
    }).toList();

    var dayFocusSeconds = 0;
    var completedCount = 0;

    for (final s in daySessions) {
      if (s.status == SessionStatus.completed) {
        dayFocusSeconds += s.durationSeconds;
        completedCount++;
      }
    }

    if (i == 0) {
      todaySeconds = dayFocusSeconds;
    }
    totalWeeklySeconds += dayFocusSeconds;

    last7Days.add(DailyFocusBarData(
      date: targetDate,
      dayLabel: i == 0 ? 'Today' : dayFormatter.format(targetDate),
      focusMinutes: dayFocusSeconds ~/ 60,
      sessionCount: completedCount,
      isToday: i == 0,
    ));
  }

  // 2. Hourly distribution
  var morningSec = 0;
  var afternoonSec = 0;
  var eveningSec = 0;
  var nightSec = 0;
  var completedSessionsCount = 0;
  var interruptedSessionsCount = 0;

  for (final s in allSessions) {
    if (s.status == SessionStatus.completed) {
      completedSessionsCount++;
      final hour = s.startTime.hour;
      if (hour >= 6 && hour < 12) {
        morningSec += s.durationSeconds;
      } else if (hour >= 12 && hour < 18) {
        afternoonSec += s.durationSeconds;
      } else if (hour >= 18 && hour < 24) {
        eveningSec += s.durationSeconds;
      } else {
        nightSec += s.durationSeconds;
      }
    } else if (s.status == SessionStatus.interrupted) {
      interruptedSessionsCount++;
    }
  }

  final hourlyDist = HourlyDistribution(
    morningMinutes: morningSec ~/ 60,
    afternoonMinutes: afternoonSec ~/ 60,
    eveningMinutes: eveningSec ~/ 60,
    nightMinutes: nightSec ~/ 60,
  );

  // 3. Focus Mastery / Digital Wellbeing score (0 - 100)
  // Factors: Completion rate (40%), Streak (30%), Daily Goal (30%)
  const dailyGoalMinutes = 90; // Standard 1.5h default focus target
  final todayMinutes = todaySeconds ~/ 60;
  final goalRatio = (todayMinutes / dailyGoalMinutes).clamp(0.0, 1.0);

  final totalSessions = completedSessionsCount + interruptedSessionsCount;
  final completionRatio = totalSessions > 0
      ? (completedSessionsCount / totalSessions).clamp(0.0, 1.0)
      : 0.5;

  final streakScoreRatio = (streakDays / 7).clamp(0.0, 1.0);

  int computedScore = 20; // baseline for starting
  if (totalSessions > 0) {
    computedScore = ((completionRatio * 40) +
            (streakScoreRatio * 30) +
            (goalRatio * 30))
        .round()
        .clamp(10, 100);
  }

  return WellbeingSummary(
    last7Days: last7Days,
    totalWeeklyMinutes: totalWeeklySeconds ~/ 60,
    dailyAverageMinutes: (totalWeeklySeconds ~/ 60) ~/ 7,
    todayMinutes: todayMinutes,
    dailyGoalMinutes: dailyGoalMinutes,
    totalCompletedSessions: completedSessionsCount,
    totalInterruptedSessions: interruptedSessionsCount,
    currentStreakDays: streakDays,
    wellbeingScore: computedScore,
    hourlyDistribution: hourlyDist,
    recentSessions: allSessions.take(5).toList(),
    totalProtectedApps: blockedApps.length,
  );
});
