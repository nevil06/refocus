import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../home/providers/home_provider.dart';
import '../../history/providers/history_provider.dart';
import '../../wellbeing/providers/wellbeing_provider.dart';

class SessionCompleteScreen extends ConsumerWidget {
  const SessionCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 2),
                ),
                child: const Center(
                  child: Text('🎉', style: TextStyle(fontSize: 44)),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Focus Complete',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: AppColors.textPrimary,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Great work! You successfully shielded your attention and finished your session.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 3),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref.invalidate(wellbeingSummaryProvider);
                    ref.invalidate(homeStatsProvider);
                    ref.invalidate(historyProvider);
                    context.go('/home');
                  },
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
