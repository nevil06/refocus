import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/models/focus_session.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/refocus_components.dart';
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
        title: Row(
          children: [
            const Icon(Icons.push_pin_rounded, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Screen Pinning',
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lock phone to Refocus for this session',
              style: GoogleFonts.inter(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'During your focus session, your device is pinned strictly to Refocus. The home button, recent apps overview, and status bar are unavailable.',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 12,
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
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.accentCyan, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'How to exit anytime',
                        style: GoogleFonts.inter(
                          color: AppColors.accentCyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Use Android\'s standard system exit gesture (touch and hold Back and Overview/Recents, or swipe up and hold). Exiting via gesture will be logged as an interrupted session.',
                    style: GoogleFonts.inter(
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
          RefocusButton(
            text: 'I Understand & Enable',
            isFullWidth: false,
            height: 42,
            onPressed: () => Navigator.of(context).pop(true),
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
            Text(
              'Uninstall Protection',
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
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
                  : 'Uninstall protection is currently INACTIVE. You can enable it in Settings to prevent accidental uninstallation during Locked sessions.',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This is a one-time Android Device Admin permission managed in Settings.',
              style: GoogleFonts.inter(
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
          RefocusButton(
            text: 'Open Settings',
            isFullWidth: false,
            height: 42,
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/settings');
            },
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
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
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
                    'Focus Setup',
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  // Active Protection Badge
                  InkWell(
                    onTap: () => _showUninstallProtectionInfoDialog(isDeviceAdminActive),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDeviceAdminActive
                            ? AppColors.primary.withOpacity(0.14)
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDeviceAdminActive
                              ? AppColors.primary.withOpacity(0.35)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 14,
                            color: isDeviceAdminActive ? AppColors.primary : AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isDeviceAdminActive ? 'Shielded' : 'Shield Off',
                            style: GoogleFonts.inter(
                              color: isDeviceAdminActive ? AppColors.primaryLight : AppColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Settings List
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Duration Picker
                    DurationPicker(
                      selectedMinutes: _selectedMinutes,
                      onDurationSelected: (minutes) {
                        setState(() => _selectedMinutes = minutes);
                      },
                    ),
                    const SizedBox(height: 24),

                    // 2. Subject / Topic
                    RefocusSectionHeader(
                      title: 'Subject / Goal',
                      accentColor: AppColors.secondary,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _labelController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Physics, Calculus, Deep Reading',
                        prefixIcon: Icon(Icons.menu_book_rounded, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. Blocked Apps Selection Summary Card
                    RefocusSectionHeader(
                      title: 'Block Distracting Apps',
                      actionText: 'Manage',
                      onAction: () => context.push('/apps'),
                      accentColor: AppColors.secondary,
                    ),
                    const SizedBox(height: 10),
                    RefocusCard(
                      onTap: () => context.push('/apps'),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.block_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${appSelectionState.selectedCount} apps selected',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  appSelectionState.selectedCount == 0
                                      ? 'Tap to select distracting apps'
                                      : 'Will be locked during this session',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.textMuted,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 4. Focus Mode / Strict Mode Level
                    RefocusSectionHeader(
                      title: 'Focus Mode Level',
                      accentColor: AppColors.secondary,
                    ),
                    const SizedBox(height: 10),
                    RefocusCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: _strictMode == StrictModeType.locked
                                      ? AppColors.danger.withOpacity(0.15)
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
                                      ? AppColors.danger
                                      : (_strictMode == StrictModeType.friction
                                          ? AppColors.amber
                                          : AppColors.primary),
                                  size: 20,
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
                                              : 'Standard Mode'),
                                      style: GoogleFonts.inter(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _strictMode == StrictModeType.locked
                                          ? 'No early exit allowed. Runs until timer completes.'
                                          : (_strictMode == StrictModeType.friction
                                              ? 'Requires 5s countdown + typing STOP to cancel.'
                                              : 'Standard focus. Give up option readily available.'),
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
                          const SizedBox(height: 16),
                          // 3-Tier Selector Chips
                          Row(
                            children: [
                              Expanded(
                                child: RefocusChip(
                                  label: 'Off',
                                  isSelected: _strictMode == StrictModeType.off,
                                  onTap: () => setState(() => _strictMode = StrictModeType.off),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RefocusChip(
                                  label: 'Friction',
                                  isSelected: _strictMode == StrictModeType.friction,
                                  activeColor: AppColors.amber,
                                  onTap: () => setState(() => _strictMode = StrictModeType.friction),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RefocusChip(
                                  label: 'Locked',
                                  isSelected: _strictMode == StrictModeType.locked,
                                  activeColor: AppColors.danger,
                                  onTap: () => setState(() => _strictMode = StrictModeType.locked),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 5. Screen Pinning Switch
                    RefocusCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        secondary: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _pinPhoneToApp
                                ? AppColors.primary.withOpacity(0.16)
                                : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.push_pin_rounded,
                            color: _pinPhoneToApp ? AppColors.primary : AppColors.textMuted,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          'Lock Phone to Refocus',
                          style: GoogleFonts.inter(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          'Pins device screen to Refocus during this session',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        value: _pinPhoneToApp,
                        activeColor: AppColors.primary,
                        activeTrackColor: AppColors.primary.withOpacity(0.4),
                        onChanged: (val) => _handlePinningToggle(val),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // 6. Start Focus CTA
                    RefocusButton(
                      text: 'START FOCUS (${_selectedMinutes}m)',
                      icon: Icons.play_arrow_rounded,
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
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
