import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../app_selection/providers/app_selection_provider.dart';
import '../providers/focus_session_provider.dart';
import '../widgets/duration_picker.dart';

class SessionSetupScreen extends ConsumerStatefulWidget {
  const SessionSetupScreen({super.key});

  @override
  ConsumerState<SessionSetupScreen> createState() => _SessionSetupScreenState();
}

class _SessionSetupScreenState extends ConsumerState<SessionSetupScreen> {
  final TextEditingController _labelController = TextEditingController();
  int _selectedMinutes = 25;
  bool _isStrictMode = false;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appSelectionState = ref.watch(appSelectionProvider);
    final focusNotifier = ref.read(focusSessionProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Start Focus'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Optional Session Label / Topic
              Text(
                'WHAT ARE YOU STUDYING / WORKING ON?',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.cyan,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _labelController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Physics, Calculus, Deep Reading',
                  prefixIcon: Icon(Icons.menu_book_rounded, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 28),

              // 2. Duration Selector
              DurationPicker(
                selectedMinutes: _selectedMinutes,
                onDurationSelected: (minutes) {
                  setState(() => _selectedMinutes = minutes);
                },
              ),
              const SizedBox(height: 28),

              // 3. Blocked Apps Selection Summary Card
              Text(
                'BLOCKED APPLICATIONS',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.cyan,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => context.push('/apps'),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.block_rounded, color: AppColors.primary, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${appSelectionState.selectedCount} apps selected',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              appSelectionState.selectedCount == 0
                                  ? 'Tap to select distracting apps'
                                  : 'Tap to customize blocked list',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // 4. Strict Mode Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isStrictMode ? AppColors.amber.withOpacity(0.4) : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _isStrictMode ? AppColors.amber.withOpacity(0.15) : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.lock_clock_rounded,
                        color: _isStrictMode ? AppColors.amber : AppColors.textSecondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Strict Focus Mode',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Prevents quick cancellation with deliberate friction dialogs',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isStrictMode,
                      onChanged: (val) => setState(() => _isStrictMode = val),
                      activeTrackColor: AppColors.amber,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // 5. Start Focus CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (appSelectionState.selectedCount == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please select at least 1 app to block before starting.'),
                          backgroundColor: AppColors.amber,
                        ),
                      );
                      context.push('/apps');
                      return;
                    }

                    final success = await focusNotifier.startFocusSession(
                      durationMinutes: _selectedMinutes,
                      blockedPackages: appSelectionState.selectedPackageNames,
                      isStrictMode: _isStrictMode,
                      label: _labelController.text.trim().isEmpty
                          ? null
                          : _labelController.text.trim(),
                    );

                    if (success && context.mounted) {
                      context.go('/focus/active');
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.play_arrow_rounded, size: 22),
                      const SizedBox(width: 8),
                      Text('START FOCUS (${_selectedMinutes}m)'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
