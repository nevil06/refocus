import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../core/models/focus_session.dart';
import '../../../core/providers/core_providers.dart';

class FocusSessionState {
  final FocusSessionModel? activeSession;
  final bool isLoading;
  final String? errorMessage;

  FocusSessionState({
    this.activeSession,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isSessionActive =>
      activeSession != null &&
      activeSession!.status == SessionStatus.active &&
      !activeSession!.isExpired;

  FocusSessionState copyWith({
    FocusSessionModel? activeSession,
    bool? isLoading,
    String? errorMessage,
    bool clearActiveSession = false,
  }) {
    return FocusSessionState(
      activeSession: clearActiveSession ? null : (activeSession ?? this.activeSession),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

final focusSessionProvider =
    StateNotifierProvider<FocusSessionNotifier, FocusSessionState>((ref) {
  final nativeBridge = ref.watch(nativeBridgeProvider);
  final database = ref.watch(databaseProvider);
  return FocusSessionNotifier(nativeBridge, database);
});

class FocusSessionNotifier extends StateNotifier<FocusSessionState> {
  final dynamic _nativeBridge;
  final dynamic _database;
  static const _uuid = Uuid();

  FocusSessionNotifier(this._nativeBridge, this._database)
      : super(FocusSessionState(isLoading: true)) {
    recoverSession();
  }

  Future<void> recoverSession() async {
    state = state.copyWith(isLoading: true);
    try {
      final nativeSessionData = await _nativeBridge.getActiveSessionState();
      if (nativeSessionData != null) {
        final endTimeMs = nativeSessionData['endTime'] as int? ?? 0;
        final nowMs = DateTime.now().millisecondsSinceEpoch;

        if (endTimeMs > nowMs) {
          final id = nativeSessionData['id'] as String? ?? _uuid.v4();
          final startTimeMs = nativeSessionData['startTime'] as int? ?? nowMs;
          final durationSec = nativeSessionData['durationSeconds'] as int? ?? ((endTimeMs - startTimeMs) ~/ 1000);
          final rawPackages = nativeSessionData['blockedPackages'] as List<dynamic>? ?? [];
          final blockedList = rawPackages.map((e) => e.toString()).toList();
          final isStrict = nativeSessionData['isStrict'] as bool? ?? false;
          final label = nativeSessionData['label'] as String?;

          final session = FocusSessionModel(
            id: id,
            startTime: DateTime.fromMillisecondsSinceEpoch(startTimeMs),
            plannedEndTime: DateTime.fromMillisecondsSinceEpoch(endTimeMs),
            durationSeconds: durationSec,
            status: SessionStatus.active,
            isStrictMode: isStrict,
            createdAt: DateTime.fromMillisecondsSinceEpoch(startTimeMs),
            blockedApps: blockedList,
            label: label,
          );

          await _database.insertSession(session);
          state = state.copyWith(activeSession: session, isLoading: false);
          return;
        } else {
          // Clean up expired session
          await _nativeBridge.stopBlocking();
        }
      }

      // Check database for active session
      final dbActiveSession = await _database.getActiveSession();
      if (dbActiveSession != null) {
        if (!dbActiveSession.isExpired) {
          state = state.copyWith(activeSession: dbActiveSession, isLoading: false);
          return;
        } else {
          await _database.updateSessionStatus(dbActiveSession.id, SessionStatus.completed);
        }
      }

      state = state.copyWith(isLoading: false, clearActiveSession: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> startFocusSession({
    required int durationMinutes,
    required List<String> blockedPackages,
    required bool isStrictMode,
    String? label,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final sessionId = _uuid.v4();
    final now = DateTime.now();
    final durationSeconds = durationMinutes * 60;
    final plannedEndTime = now.add(Duration(seconds: durationSeconds));

    final session = FocusSessionModel(
      id: sessionId,
      startTime: now,
      plannedEndTime: plannedEndTime,
      durationSeconds: durationSeconds,
      status: SessionStatus.active,
      isStrictMode: isStrictMode,
      createdAt: now,
      blockedApps: blockedPackages,
      label: label,
    );

    try {
      // 1. Persist to local SQLite DB
      await _database.insertSession(session);

      // 2. Start Kotlin native foreground service & accessibility blocker
      final nativeStarted = await _nativeBridge.startBlocking(
        sessionId: sessionId,
        startTime: now,
        plannedEndTime: plannedEndTime,
        durationSeconds: durationSeconds,
        blockedPackages: blockedPackages,
        isStrict: isStrictMode,
        label: label,
      );

      if (!nativeStarted) {
        throw Exception("Failed to start native blocker service.");
      }

      state = state.copyWith(activeSession: session, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Error starting session: ${e.toString()}",
      );
      return false;
    }
  }

  Future<void> stopSession({required bool isInterrupted}) async {
    final current = state.activeSession;
    if (current == null) return;

    state = state.copyWith(isLoading: true);
    try {
      await _nativeBridge.stopBlocking();
      final finalStatus = isInterrupted ? SessionStatus.interrupted : SessionStatus.cancelled;
      await _database.updateSessionStatus(current.id, finalStatus);
      state = state.copyWith(isLoading: false, clearActiveSession: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> completeSession() async {
    final current = state.activeSession;
    if (current == null) return;

    state = state.copyWith(isLoading: true);
    try {
      await _nativeBridge.stopBlocking();
      await _database.updateSessionStatus(current.id, SessionStatus.completed, completedAt: DateTime.now());
      state = state.copyWith(isLoading: false, clearActiveSession: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
