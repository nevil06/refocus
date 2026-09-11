import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/focus_session.dart';
import 'focus_session_provider.dart';

class TimerState {
  final int remainingSeconds;
  final double progress;
  final bool isCompleted;

  const TimerState({
    required this.remainingSeconds,
    required this.progress,
    this.isCompleted = false,
  });
}

final timerProvider = StateNotifierProvider.autoDispose<TimerNotifier, TimerState>((ref) {
  // Watch specifically the active session instance to avoid rebuilding on isLoading changes
  final activeSession = ref.watch(focusSessionProvider.select((s) => s.activeSession));
  return TimerNotifier(activeSession, ref);
});

class TimerNotifier extends StateNotifier<TimerState> {
  final FocusSessionModel? _activeSession;
  final Ref _ref;
  Timer? _timer;
  bool _hasTriggeredCompletion = false;

  TimerNotifier(this._activeSession, this._ref)
      : super(TimerState(
          remainingSeconds: _activeSession?.remainingSeconds ?? 0,
          progress: _activeSession?.progressFraction ?? 0.0,
          isCompleted: (_activeSession != null && _activeSession.remainingSeconds <= 0),
        )) {
    _startTicking();
  }

  void _startTicking() {
    _timer?.cancel();
    if (_activeSession == null) return;

    _tick(); // initial calculation
    if (!_hasTriggeredCompletion) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _tick();
      });
    }
  }

  void _tick() {
    if (_activeSession == null) {
      _timer?.cancel();
      return;
    }

    final remaining = _activeSession.remainingSeconds;
    final progress = _activeSession.progressFraction;

    if (remaining <= 0) {
      _timer?.cancel();
      state = const TimerState(
        remainingSeconds: 0,
        progress: 1.0,
        isCompleted: true,
      );

      if (!_hasTriggeredCompletion) {
        _hasTriggeredCompletion = true;
        // Schedule completion on next microtask to avoid recursive re-entrant Riverpod state builds
        Future.microtask(() {
          _ref.read(focusSessionProvider.notifier).completeSession();
        });
      }
    } else {
      state = TimerState(
        remainingSeconds: remaining,
        progress: progress,
        isCompleted: false,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

