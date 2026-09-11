import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/widgets/refocus_components.dart';
import '../models/wellbeing_analytics.dart';
import '../providers/wellbeing_provider.dart';

class WellbeingScreen extends ConsumerStatefulWidget {
  const WellbeingScreen({super.key});

  @override
  ConsumerState<WellbeingScreen> createState() => _WellbeingScreenState();
}

class _WellbeingScreenState extends ConsumerState<WellbeingScreen> {
  int? _selectedBarIndex;
  String _selectedTimeframe = 'Week';

  @override
  Widget build(BuildContext context) {
    final wellbeingAsync = ref.watch(wellbeingSummaryProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Statistics',
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
                    onPressed: () => ref.invalidate(wellbeingSummaryProvider),
                    tooltip: 'Refresh Analytics',
                  ),
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: wellbeingAsync.when(
                data: (summary) {
                  final completedSessions = summary.totalCompletedSessions;
                  final avgMinutes = completedSessions > 0
                      ? (summary.todayMinutes / completedSessions).round()
                      : 0;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeframe Segmented Chips [ Day ] [ Week ] [ Month ] [ Year ]
                        Row(
                          children: ['Day', 'Week', 'Month', 'Year'].map((tf) {
                            final isSelected = _selectedTimeframe == tf;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: RefocusChip(
                                label: tf,
                                isSelected: isSelected,
                                onTap: () => setState(() => _selectedTimeframe = tf),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // 1. Total Focus Time Hero Card
                        _TotalFocusTimeHeroCard(
                          summary: summary,
                          timeframe: _selectedTimeframe,
                        ),
                        const SizedBox(height: 20),

                        // 2. Weekly Focus Activity Bar Graph
                        _WeeklyFocusGraph(
                          last7Days: summary.last7Days,
                          dailyGoalMinutes: summary.dailyGoalMinutes,
                          selectedIndex: _selectedBarIndex,
                          onBarSelected: (index) {
                            setState(() {
                              _selectedBarIndex = _selectedBarIndex == index ? null : index;
                            });
                          },
                        ),
                        const SizedBox(height: 20),

                        // 3. Sessions & Avg Session Metrics Row
                        Row(
                          children: [
                            Expanded(
                              child: RefocusStatCard(
                                title: 'Completed Sessions',
                                value: '$completedSessions',
                                subtitle: '${summary.totalInterruptedSessions} canceled',
                                icon: Icons.check_circle_outline_rounded,
                                iconColor: AppColors.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: RefocusStatCard(
                                title: 'Avg. Session',
                                value: avgMinutes > 0 ? '${avgMinutes}m' : '—',
                                subtitle: 'Based on active time',
                                icon: Icons.av_timer_rounded,
                                iconColor: AppColors.accentCyan,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // 4. Peak Focus Time of Day
                        _HourlyDistributionCard(distribution: summary.hourlyDistribution),
                        const SizedBox(height: 24),

                        // 5. Subject / Recent Activity Breakdown
                        RefocusSectionHeader(
                          title: 'Session Breakdown',
                          actionText: 'Full History',
                          onAction: () => context.push('/history'),
                        ),
                        const SizedBox(height: 12),

                        if (summary.recentSessions.isEmpty)
                          const RefocusEmptyState(
                            icon: Icons.history_toggle_off_rounded,
                            title: 'No Session Records Yet',
                            description: 'Complete focus sessions to see your subject breakdown.',
                          )
                        else
                          ...summary.recentSessions.map((session) => Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: RefocusCard(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: session.status.name == 'completed'
                                              ? AppColors.success.withOpacity(0.14)
                                              : AppColors.danger.withOpacity(0.14),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          session.status.name == 'completed'
                                              ? Icons.check_rounded
                                              : Icons.close_rounded,
                                          color: session.status.name == 'completed'
                                              ? AppColors.success
                                              : AppColors.danger,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              session.label?.isNotEmpty == true
                                                  ? session.label!
                                                  : 'General Focus',
                                              style: GoogleFonts.inter(
                                                color: AppColors.textPrimary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
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
                                        '${session.durationSeconds ~/ 60} min',
                                        style: GoogleFonts.inter(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (err, _) => Center(
                  child: Text('Error loading stats: $err'),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: RefocusBottomNavigation(
        currentIndex: 3, // Stats tab
        onTap: (index) {
          if (index == 0) context.go('/home');
          if (index == 1) context.go('/focus/setup');
          if (index == 2) context.go('/study');
          if (index == 3) context.go('/wellbeing');
        },
      ),
    );
  }
}

// ---------------------------------------------------------
// Total Focus Time Hero Card
// ---------------------------------------------------------
class _TotalFocusTimeHeroCard extends StatelessWidget {
  final WellbeingSummary summary;
  final String timeframe;

  const _TotalFocusTimeHeroCard({
    required this.summary,
    required this.timeframe,
  });

  @override
  Widget build(BuildContext context) {
    return RefocusCard(
      padding: const EdgeInsets.all(22),
      gradient: AppGradients.cardGradient,
      hasGlow: true,
      child: Column(
        children: [
          Row(
            children: [
              // Circular Arc Gauge
              SizedBox(
                width: 84,
                height: 84,
                child: CustomPaint(
                  painter: _ScoreArcPainter(
                    score: summary.wellbeingScore,
                    color: AppColors.primary,
                    bgColor: AppColors.surfaceElevated,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${summary.wellbeingScore}',
                          style: GoogleFonts.outfit(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'SCORE',
                          style: GoogleFonts.inter(
                            color: AppColors.textMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL FOCUS TIME',
                      style: GoogleFonts.inter(
                        color: AppColors.secondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      TimeUtils.formatDurationMinutes(summary.todayMinutes),
                      style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Goal: ${summary.dailyGoalMinutes}m (${(summary.goalProgress * 100).toInt()}% completed)',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Goal Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: summary.goalProgress,
              minHeight: 7,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoreArcPainter extends CustomPainter {
  final int score;
  final Color color;
  final Color bgColor;

  _ScoreArcPainter({
    required this.score,
    required this.color,
    required this.bgColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;
    const strokeWidth = 7.0;

    final bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Draw full background circle
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      bgPaint,
    );

    // Draw active score arc
    final sweepAngle = (score / 100.0) * (2 * math.pi);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreArcPainter oldDelegate) {
    return oldDelegate.score != score || oldDelegate.color != color;
  }
}

// ---------------------------------------------------------
// Weekly Focus Bar Graph
// ---------------------------------------------------------
class _WeeklyFocusGraph extends StatelessWidget {
  final List<DailyFocusBarData> last7Days;
  final int dailyGoalMinutes;
  final int? selectedIndex;
  final ValueChanged<int> onBarSelected;

  const _WeeklyFocusGraph({
    required this.last7Days,
    required this.dailyGoalMinutes,
    required this.selectedIndex,
    required this.onBarSelected,
  });

  @override
  Widget build(BuildContext context) {
    final maxRecorded = last7Days.fold<int>(
        dailyGoalMinutes, (prev, elem) => math.max(prev, elem.focusMinutes));
    final chartMax = (maxRecorded * 1.25).ceil();

    final selectedData = selectedIndex != null && selectedIndex! < last7Days.length
        ? last7Days[selectedIndex!]
        : null;

    return RefocusCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WEEKLY ACTIVITY',
                    style: GoogleFonts.inter(
                      color: AppColors.secondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedData != null
                        ? '${selectedData.dayLabel}: ${TimeUtils.formatDurationMinutes(selectedData.focusMinutes)}'
                        : 'Tap a bar for details',
                    style: GoogleFonts.inter(
                      color: selectedData != null
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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
                child: Row(
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
                      'Goal: 90m',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(last7Days.length, (index) {
                final day = last7Days[index];
                final barRatio =
                    chartMax > 0 ? (day.focusMinutes / chartMax).clamp(0.05, 1.0) : 0.05;
                final isSelected = selectedIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onBarSelected(index),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 100 * barRatio,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryLight
                                      : day.isToday
                                          ? AppColors.primary
                                          : (day.focusMinutes > 0
                                              ? AppColors.primary.withOpacity(0.4)
                                              : AppColors.surfaceElevated),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primaryLight
                                        : day.isToday
                                            ? AppColors.primary
                                            : AppColors.border,
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                  boxShadow: day.isToday || isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.primary.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            day.dayLabel,
                            style: GoogleFonts.inter(
                              color: day.isToday
                                  ? AppColors.primary
                                  : isSelected
                                      ? AppColors.primaryLight
                                      : AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: day.isToday || isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------
// Peak Hourly Time of Day Distribution
// ---------------------------------------------------------
class _HourlyDistributionCard extends StatelessWidget {
  final HourlyDistribution distribution;

  const _HourlyDistributionCard({required this.distribution});

  @override
  Widget build(BuildContext context) {
    final total = math.max(1, distribution.totalMinutes);

    return RefocusCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PEAK FOCUS TIME',
                style: GoogleFonts.inter(
                  color: AppColors.secondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  distribution.peakPeriodName,
                  style: GoogleFonts.inter(
                    color: AppColors.primaryLight,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _TimeSlotRow(
            label: 'Morning (6 AM - 12 PM)',
            minutes: distribution.morningMinutes,
            ratio: distribution.morningMinutes / total,
            color: AppColors.amber,
          ),
          const SizedBox(height: 10),
          _TimeSlotRow(
            label: 'Afternoon (12 PM - 6 PM)',
            minutes: distribution.afternoonMinutes,
            ratio: distribution.afternoonMinutes / total,
            color: AppColors.accentCyan,
          ),
          const SizedBox(height: 10),
          _TimeSlotRow(
            label: 'Evening (6 PM - 12 AM)',
            minutes: distribution.eveningMinutes,
            ratio: distribution.eveningMinutes / total,
            color: AppColors.primary,
          ),
          const SizedBox(height: 10),
          _TimeSlotRow(
            label: 'Night (12 AM - 6 AM)',
            minutes: distribution.nightMinutes,
            ratio: distribution.nightMinutes / total,
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }
}

class _TimeSlotRow extends StatelessWidget {
  final String label;
  final int minutes;
  final double ratio;
  final Color color;

  const _TimeSlotRow({
    required this.label,
    required this.minutes,
    required this.ratio,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              TimeUtils.formatDurationMinutes(minutes),
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 5,
            backgroundColor: AppColors.surfaceElevated,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
