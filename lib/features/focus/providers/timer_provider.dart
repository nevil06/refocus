import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'focus_session_provider.dart';

class TimerState {
  final int remainingSeconds;
  final double progress;
  final bool isCompleted;

  TimerState({
    required this.remainingSeconds,
    required this.progress,
    this.isCompleted = false,
  });
}

final timerProvider = StateNotifierProvider.autoDispose<TimerNotifier, TimerState>((ref) {
  final sessionState = ref.watch(focusSessionProvider);
  return TimerNotifier(sessionState, ref);
});

class TimerNotifier extends StateNotifier<TimerState> {
  final FocusSessionState _sessionState;
  final Ref _ref;
  Timer? _timer;

  TimerNotifier(this._sessionState, this._ref)
      : super(TimerState(
          remainingSeconds: _sessionState.activeSession?.remainingSeconds ?? 0,
          progress: _sessionState.activeSession?.progressFraction ?? 0.0,
        )) {
    _startTicking();
  }

  void _startTicking() {
    _timer?.cancel();
    _tick(); // initial calculation

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tick();
    });
  }

  void _tick() {
    final active = _sessionState.activeSession;
    if (active == null) {
      _timer?.cancel();
      return;
    }

    final remaining = active.remainingSeconds;
    final progress = active.progressFraction;

    if (remaining <= 0) {
      _timer?.cancel();
      state = TimerState(
        remainingSeconds: 0,
        progress: 1.0,
        isCompleted: true,
      );
      _ref.read(focusSessionProvider.notifier).completeSession();
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
