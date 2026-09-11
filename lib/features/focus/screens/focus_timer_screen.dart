import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/widgets/refocus_components.dart';
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
              Text(
                'No active focus session.',
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              RefocusButton(
                text: 'Return Home',
                isFullWidth: false,
                onPressed: () => context.go('/home'),
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
              backgroundColor: AppColors.danger,
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              children: [
                // Top Header: Back + Title + Status Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      onPressed: () {
                        if (activeSession.isLockedMode) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Session is in Locked Mode. Early cancellation is disabled.'),
                              backgroundColor: AppColors.danger,
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }
                        _promptStopSession(context, activeSession.isFrictionMode, focusNotifier);
                      },
                    ),
                    Text(
                      'Focus Mode',
                      style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (sessionState.isScreenPinned) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accentCyan.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.accentCyan.withOpacity(0.4)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.push_pin_rounded, size: 12, color: AppColors.accentCyan),
                                SizedBox(width: 4),
                                Text(
                                  'PINNED',
                                  style: TextStyle(
                                    color: AppColors.accentCyan,
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
                              color: AppColors.danger.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.danger.withOpacity(0.4)),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_rounded, size: 12, color: AppColors.danger),
                                SizedBox(width: 4),
                                Text(
                                  'LOCKED',
                                  style: TextStyle(
                                    color: AppColors.danger,
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
                const SizedBox(height: 12),

                // Subtitle Quote
                Text(
                  '"Discipline today, a better tomorrow."',
                  style: GoogleFonts.inter(
                    color: AppColors.secondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),

                const Spacer(flex: 1),

                // Center Dominant Circular Progress Timer
                RefocusProgressRing(
                  progress: timerState.progress,
                  timeText: TimeUtils.formatRemainingSeconds(timerState.remainingSeconds),
                  subtitle: '${activeSession.durationSeconds ~/ 60}m planned',
                  size: 260,
                ),

                const SizedBox(height: 28),

                // Subject / Goal Badge
                Column(
                  children: [
                    Text(
                      'Focusing on',
                      style: GoogleFonts.inter(
                        color: AppColors.textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Blocked Apps Count Chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_rounded, color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        '${activeSession.blockedApps.length} apps blocked',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 1),

                // Stop / Commitment UI Control
                if (activeSession.isLockedMode)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.danger.withOpacity(0.35)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_rounded, color: AppColors.danger, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          'Locked Mode • Runs until timer finishes',
                          style: GoogleFonts.inter(
                            color: AppColors.danger,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  RefocusButton(
                    text: 'Give Up & Stop',
                    icon: Icons.stop_circle_outlined,
                    variant: RefocusButtonVariant.danger,
                    onPressed: () => _promptStopSession(
                      context,
                      activeSession.isFrictionMode,
                      focusNotifier,
                    ),
                  ),

                const SizedBox(height: 16),

                // Bottom Encouragement Quote
                Text(
                  '"Small steps every day lead to big results."',
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
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
