import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/focus_session.dart';
import '../../../core/providers/core_providers.dart';
import '../../focus/providers/focus_session_provider.dart';

class HomeStats {
  final int todayFocusMinutes;
  final int currentStreakDays;
  final int blockedAppsCount;
  final int todayCompletedCount;
  final List<FocusSessionModel> recentSessions;

  HomeStats({
    required this.todayFocusMinutes,
    required this.currentStreakDays,
    required this.blockedAppsCount,
    required this.todayCompletedCount,
    required this.recentSessions,
  });
}

final homeStatsProvider = FutureProvider.autoDispose<HomeStats>((ref) async {
  // Re-fetch when focus session status changes
  ref.watch(focusSessionProvider);

  final database = ref.watch(databaseProvider);
  final todayCompletedMinutes = await database.getTodayTotalFocusMinutes();
  final todayCompleted = await database.getCompletedSessionsToday();
  final streak = await database.calculateCurrentStreakDays();
  // Canonical persisted selection, so the Blocked Apps count on Home updates as
  // soon as the user changes their choice anywhere in the app.
  final blockedPackages = await ref.watch(selectedBlockedPackagesProvider.future);
  final allSessions = await database.getAllSessions();

  // Include elapsed time from an in-progress session started today so the
  // "Today's Focus" figure reflects the time the user is actively putting in
  // right now, not only finished sessions.
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);
  var liveMinutes = 0;
  final active = allSessions.where((s) => s.status == SessionStatus.active);
  for (final s in active) {
    if (!s.startTime.isBefore(startOfDay)) {
      liveMinutes += s.elapsedSeconds ~/ 60;
    }
  }

  // "Recent" should show past sessions only. The currently active session is
  // still stored with status 'active', so exclude it here to avoid showing an
  // in-progress session in the history list.
  final recent = allSessions
      .where((s) => s.status != SessionStatus.active)
      .take(5)
      .toList();

  return HomeStats(
    todayFocusMinutes: todayCompletedMinutes + liveMinutes,
    currentStreakDays: streak,
    blockedAppsCount: blockedPackages.length,
    todayCompletedCount: todayCompleted.length,
    recentSessions: recent,
  );
});
