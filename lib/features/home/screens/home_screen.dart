import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/models/focus_session.dart';
import '../../../core/utils/time_utils.dart';
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
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(homeStatsProvider);
                ref.invalidate(wellbeingSummaryProvider);
              },
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top App Header with GOAT Logo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.primary.withOpacity(0.4),
                                    width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.15),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Center(
                                    child: Text('🎯',
                                        style: TextStyle(fontSize: 22)),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getGreeting(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Refocus',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.insights_rounded,
                                  color: AppColors.cyan),
                              onPressed: () => context.push('/wellbeing'),
                              tooltip: 'Track Your Focus',
                            ),
                            IconButton(
                              icon: const Icon(Icons.history_rounded,
                                  color: AppColors.textSecondary),
                              onPressed: () => context.push('/history'),
                              tooltip: 'History',
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings_outlined,
                                  color: AppColors.textSecondary),
                              onPressed: () => context.push('/settings'),
                              tooltip: 'Settings',
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Active Focus Banner or Start Focus CTA
                    if (isSessionActive)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.18),
                              AppColors.cyan.withOpacity(0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
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
                              focusSessionState.activeSession?.label?.isNotEmpty ==
                                      true
                                  ? focusSessionState.activeSession!.label!
                                  : 'Deep Focus Session',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
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
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
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
                                  child: const Icon(Icons.timer_outlined,
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

                    const SizedBox(height: 26),

                    // Quick Stats 3-Card Grid
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => context.push('/wellbeing'),
                            borderRadius: BorderRadius.circular(16),
                            child: _StatCard(
                              title: "Today's Focus",
                              value: TimeUtils.formatDurationMinutes(
                                  stats.todayFocusMinutes),
                              icon: Icons.access_time_rounded,
                              iconColor: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatCard(
                            title: 'Streak',
                            value:
                                '${stats.currentStreakDays} ${stats.currentStreakDays == 1 ? "day" : "days"}',
                            icon: Icons.local_fire_department_rounded,
                            iconColor: AppColors.amber,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: InkWell(
                            onTap: () => context.push('/apps'),
                            borderRadius: BorderRadius.circular(16),
                            child: _StatCard(
                              title: 'Shielded Apps',
                              value: '${stats.blockedAppsCount}',
                              icon: Icons.shield_rounded,
                              iconColor: AppColors.cyan,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Digital Wellbeing & Analytics Preview Card
                    wellbeingAsync.maybeWhen(
                      data: (wb) => InkWell(
                        onTap: () => context.push('/wellbeing'),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.border),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.surfaceElevated.withOpacity(0.8),
                                AppColors.surface,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.cyan.withOpacity(0.12),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.donut_large_rounded,
                                          color: AppColors.cyan,
                                          size: 18,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Text(
                                        'TRACK YOUR FOCUS',
                                        style: TextStyle(
                                          color: AppColors.cyan,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Row(
                                    children: [
                                      Text(
                                        'View Graph',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.arrow_forward_ios_rounded,
                                          size: 11, color: AppColors.primary),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        TimeUtils.formatDurationMinutes(
                                            wb.todayMinutes),
                                        style: const TextStyle(
                                          color: AppColors.textPrimary,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        'Daily Goal: ${wb.dailyGoalMinutes}m (${(wb.goalProgress * 100).toInt()}%)',
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  // Mini 7-day sparkline/bar preview
                                  SizedBox(
                                    height: 32,
                                    width: 120,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: wb.last7Days.map((d) {
                                        final h = d.focusMinutes > 0
                                            ? (d.focusMinutes /
                                                    (wb.dailyGoalMinutes * 1.2))
                                                .clamp(0.2, 1.0)
                                            : 0.15;
                                        return Container(
                                          width: 10,
                                          height: 32 * h,
                                          decoration: BoxDecoration(
                                            color: d.isToday
                                                ? AppColors.primary
                                                : (d.focusMinutes > 0
                                                    ? AppColors.primary
                                                        .withOpacity(0.4)
                                                    : AppColors.borderLight),
                                            borderRadius:
                                                BorderRadius.circular(3),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 28),

                    // Recent Sessions List
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'RECENT SESSIONS',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
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
                            child: const Text(
                              'View All',
                              style: TextStyle(
                                  color: AppColors.primary, fontSize: 13),
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
                            const Icon(Icons.hourglass_empty_rounded,
                                color: AppColors.textMuted, size: 36),
                            const SizedBox(height: 12),
                            Text(
                              'No focus sessions yet',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Start your first session above to build your streak.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      ...stats.recentSessions
                          .map((session) => _RecentSessionTile(session: session)),
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
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
                  session.label?.isNotEmpty == true
                      ? session.label!
                      : 'Focus Session',
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
