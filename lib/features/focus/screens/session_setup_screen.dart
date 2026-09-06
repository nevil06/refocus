import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/models/focus_session.dart';
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
  StrictModeType _strictMode = StrictModeType.off;

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
                                    fontSize: 12,
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

              // 4. 3-Tier Strict Mode Selector Card (Off / Friction / Locked)
              Text(
                'STRICT MODE LEVEL',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.cyan,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _strictMode == StrictModeType.locked
                        ? AppColors.red.withOpacity(0.5)
                        : (_strictMode == StrictModeType.friction
                            ? AppColors.amber.withOpacity(0.5)
                            : AppColors.border),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _strictMode == StrictModeType.locked
                                ? AppColors.red.withOpacity(0.15)
                                : (_strictMode == StrictModeType.friction
                                    ? AppColors.amber.withOpacity(0.15)
                                    : AppColors.surfaceElevated),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _strictMode == StrictModeType.locked
                                ? Icons.lock_rounded
                                : (_strictMode == StrictModeType.friction
                                    ? Icons.lock_clock_rounded
                                    : Icons.lock_open_rounded),
                            color: _strictMode == StrictModeType.locked
                                ? AppColors.red
                                : (_strictMode == StrictModeType.friction
                                    ? AppColors.amber
                                    : AppColors.textSecondary),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _strictMode == StrictModeType.locked
                                    ? 'Locked Mode (No Exit)'
                                    : (_strictMode == StrictModeType.friction
                                        ? 'Friction Mode (5s + STOP)'
                                        : 'Off (Normal Mode)'),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _strictMode == StrictModeType.locked
                                    ? 'No way to end session early. Runs until timer completes.'
                                    : (_strictMode == StrictModeType.friction
                                        ? 'Requires 5s countdown + typing STOP to cancel.'
                                        : 'Standard session. Give up option available immediately.'),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // 3-Option Segmented Control
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<StrictModeType>(
                        segments: const [
                          ButtonSegment(
                            value: StrictModeType.off,
                            label: Text('Off'),
                          ),
                          ButtonSegment(
                            value: StrictModeType.friction,
                            label: Text('Friction'),
                          ),
                          ButtonSegment(
                            value: StrictModeType.locked,
                            label: Text('Locked'),
                          ),
                        ],
                        selected: {_strictMode},
                        onSelectionChanged: (Set<StrictModeType> newSelection) {
                          setState(() {
                            _strictMode = newSelection.first;
                          });
                        },
                        style: ButtonStyle(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                            if (states.contains(WidgetState.selected)) {
                              if (_strictMode == StrictModeType.locked) {
                                return AppColors.red.withOpacity(0.2);
                              }
                              if (_strictMode == StrictModeType.friction) {
                                return AppColors.amber.withOpacity(0.2);
                              }
                              return AppColors.primary.withOpacity(0.2);
                            }
                            return AppColors.surfaceElevated;
                          }),
                          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
                            if (states.contains(WidgetState.selected)) {
                              if (_strictMode == StrictModeType.locked) return AppColors.red;
                              if (_strictMode == StrictModeType.friction) return AppColors.amber;
                              return AppColors.primary;
                            }
                            return AppColors.textSecondary;
                          }),
                        ),
                      ),
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
                      strictModeType: _strictMode,
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
