import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/focus_session.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/time_utils.dart';

class HistoryData {
  final Map<String, List<FocusSessionModel>> groupedSessions;
  final int totalCompletedMinutes;
  final int totalCompletedSessions;

  HistoryData({
    required this.groupedSessions,
    required this.totalCompletedMinutes,
    required this.totalCompletedSessions,
  });
}

final historyProvider = FutureProvider.autoDispose<HistoryData>((ref) async {
  final database = ref.watch(databaseProvider);
  final sessions = await database.getAllSessions();

  final Map<String, List<FocusSessionModel>> grouped = {};
  var totalCompletedSeconds = 0;
  var totalCompletedCount = 0;

  for (final session in sessions) {
    final dateKey = TimeUtils.formatDateHeader(session.startTime);
    grouped.putIfAbsent(dateKey, () => []).add(session);

    if (session.status == SessionStatus.completed) {
      totalCompletedSeconds += session.durationSeconds;
      totalCompletedCount++;
    }
  }

  return HistoryData(
    groupedSessions: grouped,
    totalCompletedMinutes: totalCompletedSeconds ~/ 60,
    totalCompletedSessions: totalCompletedCount,
  );
});
