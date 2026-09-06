import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/models/focus_session.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/utils/time_utils.dart';
import '../../focus/providers/focus_session_provider.dart';
import '../../focus/widgets/strict_mode_dialog.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  /// Verifies accessibility access before a session starts. Returns true when
  /// blocking can actually be enforced. Otherwise shows a blocking dialog that
  /// deep-links into system settings and returns false.
  Future<bool> _ensureAccessibility(BuildContext context, WidgetRef ref) async {
    final bridge = ref.read(nativeBridgeProvider);
    final granted = await bridge.isAccessibilityEnabled();
    if (granted) return true;

    ref.invalidate(permissionStatusProvider);
    if (!context.mounted) return false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Accessibility required'),
        content: Text(
          'Refocus Again cannot block apps without accessibility access. Enable it, then start your session again.',
          style: TextStyle(color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Not now'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ref.read(permissionServiceProvider).requestAccessibility();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
    return false;
  }

  /// Quick Start: launch a focus session in one tap using a chosen preset
  /// duration and the apps already selected in the blocked list, skipping the
  /// full setup screen. If no apps are selected yet, routes the user to pick
  /// some first.
  Future<void> _showQuickStartSheet(BuildContext context, WidgetRef ref) async {
    // Hard guard: without accessibility access nothing can actually be blocked,
    // so refuse to start a session that would silently do nothing.
    if (!await _ensureAccessibility(context, ref)) return;

    final database = ref.read(databaseProvider);
    final blockedPackages = await database.getSelectedBlockedPackageNames();

    if (!context.mounted) return;

    if (blockedPackages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Select at least one app to block first.'),
          backgroundColor: AppColors.amber,
        ),
      );
      context.push('/apps');
      return;
    }

    const presets = [15, 25, 45, 60, 90];

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Start',
                  style: Theme.of(sheetContext).textTheme.headlineMedium?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${blockedPackages.length} ${blockedPackages.length == 1 ? 'app' : 'apps'} will be locked. Pick a duration:',
                  style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: presets.map((minutes) {
                    return ActionChip(
                      backgroundColor: AppColors.surfaceElevated,
                      side: BorderSide(color: AppColors.border),
                      label: Text(
                        TimeUtils.formatDurationMinutes(minutes),
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(sheetContext);
                        final success =
                            await ref.read(focusSessionProvider.notifier).startFocusSession(
                                  durationMinutes: minutes,
                                  blockedPackages: blockedPackages,
                                  isStrictMode: false,
                                  label: null,
                                );
                        if (success && context.mounted) {
                          ref.invalidate(homeStatsProvider);
                          context.push('/focus/active');
                        }
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      context.push('/focus/setup');
                    },
                    icon: const Icon(Icons.tune_rounded, size: 18),
                    label: const Text('More options (label, strict mode)'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// End the active session from the FAB, honoring strict mode friction.
  void _confirmEndSession(
    BuildContext context,
    WidgetRef ref,
    FocusSessionState state,
  ) {
    final isStrict = state.activeSession?.isStrictMode ?? false;
    StrictModeStopDialog.show(
      context,
      isStrictMode: isStrict,
      onConfirmStop: () async {
        await ref.read(focusSessionProvider.notifier).stopSession(isInterrupted: true);
        ref.invalidate(homeStatsProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(homeStatsProvider);
    final focusSessionState = ref.watch(focusSessionProvider);
    final isSessionActive = focusSessionState.isSessionActive;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isSessionActive ? AppColors.red : AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          if (isSessionActive) {
            _confirmEndSession(context, ref, focusSessionState);
          } else {
            _showQuickStartSheet(context, ref);
          }
        },
        icon: Icon(isSessionActive ? Icons.stop_rounded : Icons.bolt_rounded),
        label: Text(isSessionActive ? 'End Session' : 'Quick Start'),
      ),
      body: SafeArea(
        child: statsAsync.when(
          data: (stats) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(homeStatsProvider);
              },
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top App Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Ready to refocus?',
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.shield_outlined, color: AppColors.textSecondary),
                          onPressed: () => context.push('/apps'),
                          tooltip: 'Blocked Apps',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Accessibility guard: blocking cannot work without it, so
                    // surface it prominently instead of failing silently.
                    Consumer(
                      builder: (context, ref, _) {
                        final permsAsync = ref.watch(permissionStatusProvider);
                        final granted = permsAsync.maybeWhen(
                          data: (p) => p.isAccessibilityGranted,
                          orElse: () => true,
                        );
                        if (granted) return const SizedBox.shrink();

                        return Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.red.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: AppColors.red.withValues(alpha: 0.45)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.warning_amber_rounded,
                                      color: AppColors.red, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'App blocking is inactive',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: AppColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Accessibility access is turned off, so blocked apps will NOT be stopped. Re-enable it to restore blocking.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                      height: 1.4,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => ref
                                      .read(permissionServiceProvider)
                                      .requestAccessibility(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.red,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Enable Accessibility'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    // Active Focus Banner or Start Focus CTA
                    if (isSessionActive)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.2),
                              AppColors.cyan.withOpacity(0.1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'SESSION IN PROGRESS',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              focusSessionState.activeSession?.label?.isNotEmpty == true
                                  ? focusSessionState.activeSession!.label!
                                  : 'Deep Focus Session',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => context.push('/focus/active'),
                                child: const Text('Return to Focus Timer'),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(Icons.timer_outlined,
                                      color: AppColors.primary, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'New Focus Session',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: AppColors.textPrimary,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Lock distractions and focus',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => context.push('/focus/setup'),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.play_arrow_rounded, size: 20),
                                    SizedBox(width: 8),
                                    Text('Start Focus'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 28),

                    // Quick Stats Section Header
                    Text(
                      'OVERVIEW',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.cyan,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                    ),
                    const SizedBox(height: 12),

                    // Stats 3-Card Grid
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            title: "Today's Focus",
                            value: TimeUtils.formatDurationMinutes(stats.todayFocusMinutes),
                            icon: Icons.access_time_rounded,
                            iconColor: AppColors.primary,
                            subtitle: stats.todayCompletedCount == 0
                                ? 'No sessions yet'
                                : '${stats.todayCompletedCount} done today',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            title: 'Streak',
                            value: '${stats.currentStreakDays} ${stats.currentStreakDays == 1 ? "day" : "days"}',
                            icon: Icons.local_fire_department_rounded,
                            iconColor: AppColors.amber,
                            subtitle: stats.currentStreakDays == 0
                                ? 'Start one today'
                                : 'Keep it going',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: InkWell(
                            onTap: () => context.push('/apps'),
                            borderRadius: BorderRadius.circular(16),
                            child: _StatCard(
                              title: 'Blocked Apps',
                              value: '${stats.blockedAppsCount}',
                              icon: Icons.shield_rounded,
                              iconColor: AppColors.cyan,
                              subtitle: 'Tap to manage',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Recent Sessions List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RECENT SESSIONS',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.cyan,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                        ),
                        if (stats.recentSessions.isNotEmpty)
                          TextButton(
                            onPressed: () => context.push('/history'),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                            ),
                            child: Text(
                              'View All',
                              style: TextStyle(color: AppColors.primary, fontSize: 13),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (stats.recentSessions.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.hourglass_empty_rounded,
                                color: AppColors.textMuted, size: 36),
                            const SizedBox(height: 12),
                            Text(
                              'No focus sessions yet',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Start your first session above to build your streak.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ...stats.recentSessions.map((session) => _RecentSessionTile(session: session)),
                  ],
                ),
              ),
            );
          },
          loading: () => Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, _) => Center(
            child: Text('Error loading dashboard: $err'),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String? subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _RecentSessionTile extends StatelessWidget {
  final FocusSessionModel session;

  const _RecentSessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final isCompleted = session.status == SessionStatus.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.primary.withOpacity(0.12)
                  : AppColors.red.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCompleted ? Icons.check_rounded : Icons.close_rounded,
              color: isCompleted ? AppColors.primary : AppColors.red,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.label?.isNotEmpty == true ? session.label! : 'Focus Session',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                      ),
                ),
                Text(
                  TimeUtils.formatTime(session.startTime),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
          Text(
            '${session.durationSeconds ~/ 60}m',
            style: TextStyle(
              color: isCompleted ? AppColors.textPrimary : AppColors.textMuted,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
