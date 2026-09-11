import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/models/focus_session.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/widgets/refocus_components.dart';
import '../../focus/providers/focus_session_provider.dart';
import '../../wellbeing/providers/wellbeing_provider.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(homeStatsProvider);
    final wellbeingAsync = ref.watch(wellbeingSummaryProvider);
    final focusSessionState = ref.watch(focusSessionProvider);
    final isSessionActive = focusSessionState.isSessionActive;

    return Scaffold(
      body: SafeArea(
        child: statsAsync.when(
          data: (stats) {
            final wb = wellbeingAsync.asData?.value;
            final goalText = wb != null
                ? '${stats.recentSessions.where((s) => s.status == SessionStatus.completed).length}/${(wb.dailyGoalMinutes / 25).ceil().clamp(1, 10)}'
                : '${stats.blockedAppsCount} apps';

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(homeStatsProvider);
                ref.invalidate(wellbeingSummaryProvider);
              },
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top App Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${_getGreeting()},',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  'Nevil',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.textPrimary,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text('👋', style: TextStyle(fontSize: 22)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Let's make it count today.",
                              style: GoogleFonts.inter(
                                color: AppColors.textMuted,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        // Profile / Brand Avatar & Settings Action
                        Row(
                          children: [
                            RefocusIconButton(
                              icon: Icons.settings_outlined,
                              iconColor: AppColors.textSecondary,
                              tooltip: 'Settings',
                              onPressed: () => context.push('/settings'),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Primary Hero Card (Active or New Session)
                    if (isSessionActive)
                      RefocusCard(
                        padding: const EdgeInsets.all(22),
                        gradient: AppGradients.heroGradient,
                        hasGlow: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.primary,
                                            blurRadius: 8,
                                            spreadRadius: 1,
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'SESSION IN PROGRESS',
                                      style: GoogleFonts.inter(
                                        color: AppColors.primaryLight,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevated,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Text(
                                    '${focusSessionState.activeSession?.durationSeconds != null ? (focusSessionState.activeSession!.durationSeconds ~/ 60) : 25} min',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              focusSessionState.activeSession?.label?.isNotEmpty == true
                                  ? focusSessionState.activeSession!.label!
                                  : 'Deep Focus Session',
                              style: GoogleFonts.outfit(
                                color: AppColors.textPrimary,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Distracting apps are shielded. Maintain momentum.',
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 20),
                            RefocusButton(
                              text: 'Return to Focus Timer',
                              icon: Icons.timer_outlined,
                              onPressed: () => context.push('/focus/active'),
                            ),
                          ],
                        ),
                      )
                    else
                      RefocusCard(
                        padding: const EdgeInsets.all(22),
                        gradient: AppGradients.cardGradient,
                        hasGlow: true,
                        onTap: () => context.push('/focus/setup'),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.16),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Start Focus',
                                        style: GoogleFonts.inter(
                                          color: AppColors.primaryLight,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '25 minutes',
                                      style: GoogleFonts.inter(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 16,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 18),
                            Text(
                              'Block distractions.\nBuild your future.',
                              style: GoogleFonts.outfit(
                                color: AppColors.textPrimary,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 20),
                            RefocusButton(
                              text: 'Start 25m Session',
                              icon: Icons.play_arrow_rounded,
                              onPressed: () => context.push('/focus/setup'),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 24),

                    // 3-Metric Overview Row (Today, Streak, Goals)
                    Row(
                      children: [
                        Expanded(
                          child: RefocusStatCard(
                            title: 'Today',
                            value: TimeUtils.formatDurationMinutes(stats.todayFocusMinutes),
                            icon: Icons.access_time_rounded,
                            iconColor: AppColors.primary,
                            onTap: () => context.push('/wellbeing'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RefocusStatCard(
                            title: 'Streak',
                            value: '${stats.currentStreakDays} ${stats.currentStreakDays == 1 ? "day" : "days"}',
                            icon: Icons.local_fire_department_rounded,
                            iconColor: AppColors.amber,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: RefocusStatCard(
                            title: 'Goals',
                            value: goalText,
                            icon: Icons.flag_rounded,
                            iconColor: AppColors.accentCyan,
                            onTap: () => context.push('/wellbeing'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Quick Actions Section
                    RefocusSectionHeader(
                      title: 'Quick Actions',
                      accentColor: AppColors.secondary,
                    ),
                    const SizedBox(height: 14),

                    // 2x2 Grid of Quick Actions
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            title: 'Blocked Apps',
                            subtitle: '${stats.blockedAppsCount} configured',
                            icon: Icons.shield_rounded,
                            iconColor: AppColors.accentCyan,
                            onTap: () => context.push('/apps'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            title: 'Focus History',
                            subtitle: 'Past sessions',
                            icon: Icons.history_rounded,
                            iconColor: AppColors.primary,
                            onTap: () => context.push('/history'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionCard(
                            title: 'Statistics',
                            subtitle: 'Track your focus',
                            icon: Icons.insights_rounded,
                            iconColor: AppColors.success,
                            onTap: () => context.push('/wellbeing'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionCard(
                            title: 'Settings',
                            subtitle: 'Preferences & rules',
                            icon: Icons.tune_rounded,
                            iconColor: AppColors.secondary,
                            onTap: () => context.push('/settings'),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Recent Sessions Section
                    RefocusSectionHeader(
                      title: 'Recent Sessions',
                      actionText: stats.recentSessions.isNotEmpty ? 'View All' : null,
                      onAction: stats.recentSessions.isNotEmpty ? () => context.push('/history') : null,
                    ),
                    const SizedBox(height: 12),

                    if (stats.recentSessions.isEmpty)
                      const RefocusEmptyState(
                        icon: Icons.history_toggle_off_rounded,
                        title: 'No focus sessions yet',
                        description: 'Start your first focus session and your progress will appear here.',
                      )
                    else
                      ...stats.recentSessions.map((session) => _RecentSessionTile(session: session)),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (err, _) => Center(
            child: Text('Error loading dashboard: $err'),
          ),
        ),
      ),
      bottomNavigationBar: RefocusBottomNavigation(
        currentIndex: 0, // Home tab
        onTap: (index) {
          if (index == 0) context.go('/home');
          if (index == 1) context.go('/focus/setup');
          if (index == 2) context.go('/wellbeing');
        },
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RefocusCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.14),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    color: AppColors.textMuted,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RefocusCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.success.withOpacity(0.14)
                    : AppColors.danger.withOpacity(0.14),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isCompleted ? Icons.check_rounded : Icons.close_rounded,
                color: isCompleted ? AppColors.success : AppColors.danger,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.label?.isNotEmpty == true
                        ? session.label!
                        : 'Focus Session',
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    TimeUtils.formatTime(session.startTime),
                    style: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${session.durationSeconds ~/ 60}m',
              style: GoogleFonts.inter(
                color: isCompleted ? AppColors.textPrimary : AppColors.textMuted,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
