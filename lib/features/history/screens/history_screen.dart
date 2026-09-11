import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/models/focus_session.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/widgets/refocus_components.dart';
import '../providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

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
                    'Focus History',
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: historyAsync.when(
                data: (data) {
                  if (data.groupedSessions.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: RefocusEmptyState(
                          icon: Icons.history_toggle_off_rounded,
                          title: 'No Session History Yet',
                          description: 'Your completed and past focus sessions will show here.',
                          buttonText: 'Start Focus',
                          onButtonPressed: () => context.push('/focus/setup'),
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Metrics Hero Card
                        RefocusCard(
                          padding: const EdgeInsets.all(20),
                          gradient: AppGradients.cardGradient,
                          hasGlow: true,
                          child: Row(
                            children: [
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
                                      TimeUtils.formatDurationMinutes(data.totalCompletedMinutes),
                                      style: GoogleFonts.outfit(
                                        color: AppColors.textPrimary,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(width: 1, height: 44, color: AppColors.border),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'COMPLETED',
                                      style: GoogleFonts.inter(
                                        color: AppColors.secondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      '${data.totalCompletedSessions} sessions',
                                      style: GoogleFonts.outfit(
                                        color: AppColors.textPrimary,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Grouped Session Records
                        ...data.groupedSessions.entries.map((entry) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                child: Text(
                                  entry.key.toUpperCase(),
                                  style: GoogleFonts.inter(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              ...entry.value.map((session) => _HistorySessionTile(session: session)),
                              const SizedBox(height: 12),
                            ],
                          );
                        }),
                      ],
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (err, _) => Center(
                  child: Text('Error loading history: $err'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistorySessionTile extends StatelessWidget {
  final FocusSessionModel session;

  const _HistorySessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final isCompleted = session.status == SessionStatus.completed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RefocusCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          session.label?.isNotEmpty == true ? session.label! : 'Focus Session',
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (session.isStrictMode) ...[
                        const SizedBox(width: 6),
                        Icon(
                          session.isLockedMode ? Icons.lock_rounded : Icons.lock_clock_rounded,
                          size: 13,
                          color: session.isLockedMode ? AppColors.danger : AppColors.amber,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${TimeUtils.formatTime(session.startTime)} • ${isCompleted ? "Completed" : "Interrupted"}',
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
