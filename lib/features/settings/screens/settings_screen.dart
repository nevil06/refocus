import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../core/providers/core_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

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

          // Section 2: App Blocking Setup
          Text(
            'APP BLOCKING CONFIGURATION',
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
            child: ListTile(
              leading: const Icon(Icons.apps_rounded, color: AppColors.primary),
              title: const Text('Manage Blocked Apps'),
              subtitle: const Text(
                'Customize apps that get locked during sessions',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () => context.push('/apps'),
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
                  'Refocus Again runs completely on your device. The Accessibility Service is used strictly to match foreground package names against your blocked list during active focus sessions. No screen content, text, passwords, or personal data are ever read, transmitted, or logged.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Section 4: About
          Center(
            child: Column(
              children: [
                Text(
                  'REFOCUS AGAIN • Phase 1 (Core Focus)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 4),
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
