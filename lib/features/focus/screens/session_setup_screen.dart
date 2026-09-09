import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/focus_session.dart';
import '../../../core/providers/core_providers.dart';
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
  bool _pinPhoneToApp = false;

  static const String _keySeenPinningExplainer = 'has_seen_screen_pinning_explainer';

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _handlePinningToggle(bool enabled) async {
    if (!enabled) {
      setState(() => _pinPhoneToApp = false);
      return;
    }

    final prefs = ref.read(sharedPreferencesProvider);
    final hasSeenExplainer = prefs.getBool(_keySeenPinningExplainer) ?? false;

    if (!hasSeenExplainer) {
      final confirmed = await _showScreenPinningExplainerDialog();
      if (confirmed == true) {
        await prefs.setBool(_keySeenPinningExplainer, true);
        setState(() => _pinPhoneToApp = true);
      }
    } else {
      setState(() => _pinPhoneToApp = true);
    }
  }

  Future<bool?> _showScreenPinningExplainerDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Row(
          children: [
            Icon(Icons.push_pin_rounded, color: AppColors.primary, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Screen Pinning',
                style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lock phone to Refocus for this session',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'During your focus session, your device is pinned strictly to Refocus Again. The home button, recent apps overview, and status bar are unavailable.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: AppColors.cyan, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'How to exit anytime',
                        style: TextStyle(
                          color: AppColors.cyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Use Android\'s standard system exit gesture (touch and hold Back and Overview/Recents, or swipe up and hold). Exiting via gesture will be logged as an interrupted session.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          height: 1.3,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('I Understand & Enable'),
          ),
        ],
      ),
    );
  }

  void _showUninstallProtectionInfoDialog(bool isActive) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Row(
          children: [
            Icon(
              Icons.admin_panel_settings_rounded,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text(
              'Uninstall Protection',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isActive
                  ? 'Uninstall protection is currently ACTIVE via Android Device Admin. Refocus cannot be uninstalled mid-session.'
                  : 'Uninstall protection is currently INACTIVE. You can enable it in Settings to prevent accidental or compulsive uninstallation during Locked sessions.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'This is a one-time Android Device Admin permission. It is managed in Settings rather than toggled per session.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    height: 1.3,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/settings');
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appSelectionState = ref.watch(appSelectionProvider);
    final focusNotifier = ref.read(focusSessionProvider.notifier);
    final permissionsAsync = ref.watch(permissionStatusProvider);

    final isDeviceAdminActive = permissionsAsync.asData?.value.isDeviceAdminActive ?? false;

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
              // Passive Status Line: Uninstall Protection
              InkWell(
                onTap: () => _showUninstallProtectionInfoDialog(isDeviceAdminActive),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDeviceAdminActive
                        ? AppColors.primary.withOpacity(0.08)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDeviceAdminActive
                          ? AppColors.primary.withOpacity(0.25)
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shield_outlined,
                        size: 16,
                        color: isDeviceAdminActive ? AppColors.primary : AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Uninstall protection: ${isDeviceAdminActive ? 'ON' : 'OFF'}',
                        style: TextStyle(
                          color: isDeviceAdminActive ? AppColors.primary : AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textMuted),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

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
              const SizedBox(height: 24),

              // 5. Per-Session Screen Pinning (Lock Task Mode) Choice
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _pinPhoneToApp ? AppColors.primary.withOpacity(0.4) : AppColors.border,
                  ),
                ),
                child: SwitchListTile(
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _pinPhoneToApp
                          ? AppColors.primary.withOpacity(0.15)
                          : AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.push_pin_rounded,
                      color: _pinPhoneToApp ? AppColors.primary : AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Lock phone to Refocus',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: const Text(
                    'Pin screen to Refocus during this session (Screen Pinning)',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  value: _pinPhoneToApp,
                  activeTrackColor: AppColors.primary,
                  onChanged: (val) => _handlePinningToggle(val),
                ),
              ),
              const SizedBox(height: 36),

              // 6. Start Focus CTA Button
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
                      isScreenPinning: _pinPhoneToApp,
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
