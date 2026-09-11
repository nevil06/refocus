import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/refocus_components.dart';
import '../../home/providers/home_provider.dart';
import '../../history/providers/history_provider.dart';
import '../../wellbeing/providers/wellbeing_provider.dart';
import '../providers/focus_session_provider.dart';

class SessionCompleteScreen extends ConsumerWidget {
  const SessionCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionState = ref.watch(focusSessionProvider);
    final session = sessionState.lastCompletedSession;

    final durationMins = session != null ? (session.durationSeconds ~/ 60) : 25;
    final subjectName = session?.label?.isNotEmpty == true ? session!.label! : 'Deep Focus';
    final blockedCount = session?.blockedApps.length ?? 0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Glowing Celebration Icon ✦
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.16),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.4),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '✦',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Title
              Text(
                'Focus Complete!',
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Great job, Nevil.',
                style: GoogleFonts.inter(
                  color: AppColors.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 28),

              // Summary Card
              RefocusCard(
                padding: const EdgeInsets.all(20),
                gradient: AppGradients.cardGradient,
                hasGlow: true,
                child: Column(
                  children: [
                    _MetricRow(
                      icon: Icons.timer_outlined,
                      iconColor: AppColors.primary,
                      title: 'Duration',
                      value: '$durationMins minutes',
                    ),
                    const Divider(height: 24),
                    _MetricRow(
                      icon: Icons.menu_book_rounded,
                      iconColor: AppColors.accentCyan,
                      title: 'Subject',
                      value: subjectName,
                    ),
                    const Divider(height: 24),
                    _MetricRow(
                      icon: Icons.shield_rounded,
                      iconColor: AppColors.secondary,
                      title: 'Shielded Apps',
                      value: '$blockedCount blocked',
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // Action Buttons
              RefocusButton(
                text: 'View Statistics',
                icon: Icons.insights_rounded,
                variant: RefocusButtonVariant.secondary,
                onPressed: () {
                  _refreshProviders(ref);
                  context.go('/wellbeing');
                },
              ),
              const SizedBox(height: 12),
              RefocusButton(
                text: 'Start Another Session',
                icon: Icons.play_arrow_rounded,
                variant: RefocusButtonVariant.primary,
                onPressed: () {
                  _refreshProviders(ref);
                  context.go('/focus/setup');
                },
              ),
              const SizedBox(height: 8),
              RefocusButton(
                text: 'Done & Return Home',
                variant: RefocusButtonVariant.ghost,
                onPressed: () {
                  _refreshProviders(ref);
                  context.go('/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _refreshProviders(WidgetRef ref) {
    ref.invalidate(wellbeingSummaryProvider);
    ref.invalidate(homeStatsProvider);
    ref.invalidate(historyProvider);
  }
}

class _MetricRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;

  const _MetricRow({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 14),
        Text(
          title,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
