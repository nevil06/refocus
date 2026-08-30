import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/focus_session.dart';
import '../../../core/providers/core_providers.dart';
import '../../focus/providers/focus_session_provider.dart';

class HomeStats {
  final int todayFocusMinutes;
  final int currentStreakDays;
  final int blockedAppsCount;
  final List<FocusSessionModel> recentSessions;

  HomeStats({
    required this.todayFocusMinutes,
    required this.currentStreakDays,
    required this.blockedAppsCount,
    required this.recentSessions,
  });
}

final homeStatsProvider = FutureProvider.autoDispose<HomeStats>((ref) async {
  // Re-fetch when focus session status changes
  ref.watch(focusSessionProvider);

  final database = ref.watch(databaseProvider);
  final todayMinutes = await database.getTodayTotalFocusMinutes();
  final streak = await database.calculateCurrentStreakDays();
  final blockedPackages = await database.getSelectedBlockedPackageNames();
  final allSessions = await database.getAllSessions();
  final recent = allSessions.take(5).toList();

  return HomeStats(
    todayFocusMinutes: todayMinutes,
    currentStreakDays: streak,
    blockedAppsCount: blockedPackages.length,
    recentSessions: recent,
  );
});
