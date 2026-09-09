import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/time_utils.dart';
import '../providers/focus_session_provider.dart';
import '../providers/timer_provider.dart';
import '../widgets/strict_mode_dialog.dart';

class FocusTimerScreen extends ConsumerStatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  ConsumerState<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends ConsumerState<FocusTimerScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPinningInterruption();
    }
  }

  Future<void> _checkPinningInterruption() async {
    final sessionState = ref.read(focusSessionProvider);
    if (sessionState.isSessionActive && sessionState.isScreenPinned) {
      final bridge = ref.read(nativeBridgeProvider);
      final inLock = await bridge.isInLockTaskMode();
      if (!inLock && mounted) {
        // User exited via system gesture (Back + Recents / Swipe hold)
        // Log as an interrupted session
        await ref.read(focusSessionProvider.notifier).stopSession(isInterrupted: true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Screen unpinned via system gesture. Focus session ended.'),
              backgroundColor: AppColors.amber,
              duration: Duration(seconds: 3),
            ),
          );
          context.go('/home');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(focusSessionProvider);
    final timerState = ref.watch(timerProvider);
    final focusNotifier = ref.read(focusSessionProvider.notifier);

    // Auto navigate when session completes
    if (timerState.isCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/focus/complete');
        }
      });
    }

    final activeSession = sessionState.activeSession;
    if (activeSession == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No active focus session.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/home'),
                child: const Text('Return Home'),
              ),
            ],
          ),
        ),
      );
    }

    final label = activeSession.label?.isNotEmpty == true
        ? activeSession.label!
        : 'Deep Focus';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (activeSession.isLockedMode) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Session is in Locked Mode. Early cancellation is disabled.'),
              backgroundColor: AppColors.red,
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        _promptStopSession(context, activeSession.isFrictionMode, focusNotifier);
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              children: [
                // Top Header: App Branding + Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'REFOCUS',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (sessionState.isScreenPinned) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.cyan.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.cyan.withOpacity(0.4)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.push_pin_rounded, size: 12, color: AppColors.cyan),
                                SizedBox(width: 4),
                                Text(
                                  'PINNED',
                                  style: TextStyle(
                                    color: AppColors.cyan,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        if (activeSession.isLockedMode)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.red.withOpacity(0.4)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_rounded, size: 12, color: AppColors.red),
                                SizedBox(width: 4),
                                Text(
                                  'LOCKED',
                                  style: TextStyle(
                                    color: AppColors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else if (activeSession.isFrictionMode)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.amber.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.amber.withOpacity(0.4)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_clock_rounded, size: 12, color: AppColors.amber),
                                SizedBox(width: 4),
                                Text(
                                  'FRICTION',
                                  style: TextStyle(
                                    color: AppColors.amber,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                Text(
                  label,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Focus Session Active',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),

                const Spacer(flex: 1),

                // Center Circular Progress Countdown
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: CircularProgressIndicator(
                        value: timerState.progress,
                        strokeWidth: 8,
                        backgroundColor: AppColors.surfaceElevated,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          TimeUtils.formatRemainingSeconds(timerState.remainingSeconds),
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${activeSession.durationSeconds ~/ 60}m planned',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const Spacer(flex: 1),

                // Blocked Apps Indicator Card
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.shield_rounded, color: AppColors.cyan, size: 22),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          '${activeSession.blockedApps.length} distracting apps currently locked',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textPrimary,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Stop / Commitment UI
                if (activeSession.isLockedMode)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.red.withOpacity(0.3)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.lock_rounded, color: AppColors.red, size: 18),
                        SizedBox(width: 10),
                        Text(
                          'Locked Mode • Runs until timer completes',
                          style: TextStyle(
                            color: AppColors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _promptStopSession(
                        context,
                        activeSession.isFrictionMode,
                        focusNotifier,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.red.withOpacity(0.5)),
                        foregroundColor: AppColors.red,
                      ),
                      child: const Text('Give Up & Stop'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _promptStopSession(
    BuildContext context,
    bool isFrictionMode,
    FocusSessionNotifier focusNotifier,
  ) {
    StrictModeStopDialog.show(
      context,
      isStrictMode: isFrictionMode,
      onConfirmStop: () async {
        await focusNotifier.stopSession(isInterrupted: true);
        if (context.mounted) {
          context.go('/home');
        }
      },
    );
  }
}
