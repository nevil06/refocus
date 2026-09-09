import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/services/permission_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _handleDeviceAdminTap(BuildContext context, bool isActive, PermissionService permissionService) {
    if (!isActive) {
      // Show explainer before triggering system ACTION_ADD_DEVICE_ADMIN
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border),
          ),
          title: const Row(
            children: [
              Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Uninstall Protection',
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
                'Prevent uninstallation during focus sessions',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'This activates Android Device Admin to prevent uninstalling Refocus mid-session as a bypass for Locked Mode.',
                style: Theme.of(dialogCtx).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Important details:',
                      style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• This is a persistent grant managed by Android OS.\n• To turn off at any time, simply deactivate it in Android Settings → Security → Device Admin apps.',
                      style: Theme.of(dialogCtx).textTheme.bodySmall?.copyWith(
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
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                await permissionService.requestDeviceAdmin();
              },
              child: const Text('Continue to System Dialog'),
            ),
          ],
        ),
      );
    } else {
      // Show deactivation instructions and button
      showDialog(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          backgroundColor: AppColors.surfaceElevated,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppColors.border),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Uninstall Protection is ON',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Device Admin is active. The Android OS prevents uninstallation of Refocus.',
                style: Theme.of(dialogCtx).textTheme.bodySmall?.copyWith(
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
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'How to deactivate:',
                      style: TextStyle(color: AppColors.cyan, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '1. Open Android Settings\n2. Go to Security → Device Admin apps\n3. Select Refocus Again → tap Deactivate',
                      style: Theme.of(dialogCtx).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Done', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                await permissionService.openDeviceAdminSettings();
              },
              child: const Text('Open Device Admin Settings'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionsAsync = ref.watch(permissionStatusProvider);
    final permissionService = ref.watch(permissionServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        children: [
          // Section 1: Android System Permissions
          Text(
            'PERMISSIONS & SYSTEM INTEGRATION',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.cyan,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
          ),
          const SizedBox(height: 10),

          permissionsAsync.when(
            data: (permissions) => Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: const Text('Accessibility Service'),
                    subtitle: Text(
                      permissions.isAccessibilityGranted
                          ? 'Active & ready to block apps'
                          : 'Disabled — required for app blocking',
                      style: TextStyle(
                        color: permissions.isAccessibilityGranted
                            ? AppColors.primary
                            : AppColors.red,
                        fontSize: 12,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => permissionService.requestAccessibility(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Notification Access (Notification Muting)'),
                    subtitle: Text(
                      permissions.isNotificationListenerGranted
                          ? 'Active — incoming notifications from blocked apps will be silenced'
                          : 'Disabled — required to silence notifications from blocked apps',
                      style: TextStyle(
                        color: permissions.isNotificationListenerGranted
                            ? AppColors.primary
                            : AppColors.amber,
                        fontSize: 12,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => permissionService.requestNotificationAccess(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Battery Optimization Exemption'),
                    subtitle: Text(
                      permissions.isBatteryOptimizationIgnored
                          ? 'Exempted — background protection active'
                          : 'Not exempted — Android may stop background service',
                      style: TextStyle(
                        color: permissions.isBatteryOptimizationIgnored
                            ? AppColors.primary
                            : AppColors.amber,
                        fontSize: 12,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => permissionService.requestBatteryOptimization(),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Uninstall Protection (Device Admin)'),
                    subtitle: Text(
                      permissions.isDeviceAdminActive
                          ? 'Active — OS prevents uninstall mid-session'
                          : 'Disabled — tap to enable Device Admin protection',
                      style: TextStyle(
                        color: permissions.isDeviceAdminActive
                            ? AppColors.primary
                            : AppColors.amber,
                        fontSize: 12,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => _handleDeviceAdminTap(context, permissions.isDeviceAdminActive, permissionService),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Screen Pinning (Lock Task Mode)'),
                    subtitle: const Text(
                      'Available — configure per-session on the focus setup screen',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                    onTap: () => permissionService.openScreenPinningSettings(),
                  ),
                ],
              ),
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            error: (err, stack) => const SizedBox(),
          ),

          const SizedBox(height: 28),

          // Section 2: App Blocking Setup & Focus Tracking
          Text(
            'FOCUS TRACKING & CONTROLS',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.cyan,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.insights_rounded, color: AppColors.cyan),
                  title: const Text('Track Your Focus'),
                  subtitle: const Text(
                    'Weekly focus charts, daily goals & focus score',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => context.push('/wellbeing'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.apps_rounded, color: AppColors.primary),
                  title: const Text('Manage Blocked Apps'),
                  subtitle: const Text(
                    'Customize apps that get locked during sessions',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () => context.push('/apps'),
                ),
                const Divider(height: 1),
                Consumer(
                  builder: (context, ref, child) {
                    final notifBlockingEnabled = ref.watch(notificationBlockingEnabledProvider);
                    final notifNotifier = ref.read(notificationBlockingEnabledProvider.notifier);

                    return SwitchListTile(
                      secondary: const Icon(Icons.notifications_off_rounded, color: AppColors.primary),
                      title: const Text('Silence notifications from blocked apps'),
                      subtitle: const Text(
                        'Automatically mute banners and alerts from blocked apps during active focus',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                      value: notifBlockingEnabled,
                      activeTrackColor: AppColors.primary,
                      onChanged: (val) {
                        notifNotifier.toggle(val);
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Section 3: Privacy & Security
          Text(
            'PRIVACY & PLATFORM GUARANTEE',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.cyan,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20),
                    const SizedBox(width: 10),
                    Text(
                      '100% Local & Privacy-Preserving',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Refocus runs completely on your device. The Accessibility Service is used strictly to match foreground package names against your blocked list during active focus sessions. No screen content, text, passwords, or personal data are ever read, transmitted, or logged.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Section 4: About
          Center(
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.hourglass_bottom_rounded,
                              color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'REFOCUS',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'v1.0.0 (Android Native + Flutter)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
