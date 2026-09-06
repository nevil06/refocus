import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/utils/time_utils.dart';
import '../models/wellbeing_analytics.dart';
import '../providers/wellbeing_provider.dart';

class WellbeingScreen extends ConsumerStatefulWidget {
  const WellbeingScreen({super.key});

  @override
  ConsumerState<WellbeingScreen> createState() => _WellbeingScreenState();
}

class _WellbeingScreenState extends ConsumerState<WellbeingScreen> {
  int? _selectedBarIndex;

  @override
  Widget build(BuildContext context) {
    final wellbeingAsync = ref.watch(wellbeingSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Digital Wellbeing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(wellbeingSummaryProvider),
            tooltip: 'Refresh Analytics',
          ),
        ],
      ),
      body: wellbeingAsync.when(
        data: (summary) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Digital Wellbeing Score & Goal Hero Card
                _ScoreHeroCard(summary: summary),
                const SizedBox(height: 24),

                // 2. Weekly Focus Graph Section
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
                const SizedBox(height: 24),

                // 3. Peak Focus Time-of-Day Distribution
                _HourlyDistributionCard(distribution: summary.hourlyDistribution),
                const SizedBox(height: 24),

                // 4. Distraction Shield & Session Health Grid
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        title: 'Completed',
                        value: '${summary.totalCompletedSessions}',
                        subtitle: '${summary.totalInterruptedSessions} canceled',
                        icon: Icons.check_circle_outline_rounded,
                        accentColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => context.push('/apps'),
                        borderRadius: BorderRadius.circular(18),
                        child: _MetricCard(
                          title: 'Shielded Apps',
                          value: '${summary.totalProtectedApps}',
                          subtitle: 'Tap to configure',
                          icon: Icons.shield_rounded,
                          accentColor: AppColors.cyan,
                          showArrow: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // 5. Recent Activity Quick View
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RECENT FOCUS SESSIONS',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.cyan,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/history'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                      ),
                      child: const Text(
                        'Full History',
                        style: TextStyle(color: AppColors.primary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (summary.recentSessions.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Center(
                      child: Text(
                        'No focus sessions recorded yet.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    ),
                  )
                else
                  ...summary.recentSessions.map((session) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
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
                                color: session.status.name == 'completed'
                                    ? AppColors.primary.withOpacity(0.12)
                                    : AppColors.red.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                session.status.name == 'completed'
                                    ? Icons.check_rounded
                                    : Icons.close_rounded,
                                color: session.status.name == 'completed'
                                    ? AppColors.primary
                                    : AppColors.red,
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
                                        : 'Focus Session',
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    TimeUtils.formatTime(session.startTime),
                                    style: const TextStyle(
                                      color: AppColors.textMuted,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${session.durationSeconds ~/ 60} min',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
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
          child: Text('Error loading wellbeing stats: $err'),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------
// Score Hero Card
// ---------------------------------------------------------
class _ScoreHeroCard extends StatelessWidget {
  final WellbeingSummary summary;

  const _ScoreHeroCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        gradient: LinearGradient(
          colors: [
            AppColors.surfaceElevated,
            AppColors.surface,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
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
                    bgColor: AppColors.borderLight,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${summary.wellbeingScore}',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const Text(
                          'SCORE',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        summary.scoreTitle.toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      TimeUtils.formatDurationMinutes(summary.todayMinutes),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Today\'s Focus (${(summary.goalProgress * 100).toInt()}% of ${summary.dailyGoalMinutes}m goal)',
                      style: const TextStyle(
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
              backgroundColor: AppColors.border,
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
    // Determine maximum minutes to scale bars
    final maxRecorded = last7Days.fold<int>(
        dailyGoalMinutes, (prev, elem) => math.max(prev, elem.focusMinutes));
    final chartMax = (maxRecorded * 1.25).ceil();

    final selectedData = selectedIndex != null && selectedIndex! < last7Days.length
        ? last7Days[selectedIndex!]
        : null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WEEKLY FOCUS ACTIVITY',
                    style: TextStyle(
                      color: AppColors.cyan,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    selectedData != null
                        ? '${selectedData.dayLabel}: ${TimeUtils.formatDurationMinutes(selectedData.focusMinutes)} (${selectedData.sessionCount} sessions)'
                        : 'Tap a bar for details',
                    style: TextStyle(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    const Text(
                      'Goal: 90m',
                      style: TextStyle(
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
          // Chart Bars Area
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
                          // Bar
                          Expanded(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 100 * barRatio,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.cyan
                                      : day.isToday
                                          ? AppColors.primary
                                          : (day.focusMinutes > 0
                                              ? AppColors.primary.withOpacity(0.4)
                                              : AppColors.surfaceElevated),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.cyan
                                        : day.isToday
                                            ? AppColors.primary
                                            : AppColors.border,
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Day Label
                          Text(
                            day.dayLabel,
                            style: TextStyle(
                              color: day.isToday
                                  ? AppColors.primary
                                  : isSelected
                                      ? AppColors.cyan
                                      : AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: day.isToday || isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
// Hourly Time of Day Distribution
// ---------------------------------------------------------
class _HourlyDistributionCard extends StatelessWidget {
  final HourlyDistribution distribution;

  const _HourlyDistributionCard({required this.distribution});

  @override
  Widget build(BuildContext context) {
    final total = math.max(1, distribution.totalMinutes);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PEAK FOCUS TIME OF DAY',
                style: TextStyle(
                  color: AppColors.cyan,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.purple.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  distribution.peakPeriodName,
                  style: const TextStyle(
                    color: AppColors.purple,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
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
            color: AppColors.cyan,
          ),
          const SizedBox(height: 10),
          _TimeSlotRow(
            label: 'Evening (6 PM - 12 AM)',
            minutes: distribution.eveningMinutes,
            ratio: distribution.eveningMinutes / total,
            color: AppColors.purple,
          ),
          const SizedBox(height: 10),
          _TimeSlotRow(
            label: 'Night (12 AM - 6 AM)',
            minutes: distribution.nightMinutes,
            ratio: distribution.nightMinutes / total,
            color: AppColors.primary,
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
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              TimeUtils.formatDurationMinutes(minutes),
              style: const TextStyle(
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

// ---------------------------------------------------------
// Reusable Metric Card
// ---------------------------------------------------------
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final bool showArrow;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: accentColor, size: 22),
              if (showArrow)
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 13, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
