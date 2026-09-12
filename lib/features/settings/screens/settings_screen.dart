import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/refocus_components.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissionsAsync = ref.watch(permissionStatusProvider);
    final permissionService = ref.watch(permissionServiceProvider);
    final notifBlockingEnabled = ref.watch(notificationBlockingEnabledProvider);

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
                    'Settings',
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                children: [
                  // SECTION 1: FOCUS CONTROLS
                  RefocusSectionHeader(title: 'Focus Controls'),
                  const SizedBox(height: 12),
                  RefocusCard(
                    tonalElevation: 2,
                    borderRadius: AppRadius.large,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          leading: const Icon(Icons.shield_rounded, color: AppColors.primary),
                          title: Text(
                            'Manage Blocked Apps',
                            style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Customize apps locked during sessions',
                            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                          onTap: () => context.push('/apps'),
                        ),
                        const Divider(height: 1),
                        SwitchListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          secondary: const Icon(Icons.notifications_off_rounded, color: AppColors.secondary),
                          title: Text(
                            'Mute Notifications',
                            style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          subtitle: Text(
                            'Silence banners from blocked apps during focus',
                            style: GoogleFonts.inter(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          value: notifBlockingEnabled,
                          activeColor: AppColors.primary,
                          activeTrackColor: AppColors.primary.withOpacity(0.4),
                          onChanged: (val) {
                            ref.read(notificationBlockingEnabledProvider.notifier).toggle(val);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // SECTION 2: ANDROID SYSTEM PERMISSIONS
                  RefocusSectionHeader(title: 'Permissions & System Integration'),
                  const SizedBox(height: 12),

                  permissionsAsync.when(
                    data: (permissions) => RefocusCard(
                      tonalElevation: 2,
                      borderRadius: AppRadius.large,
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            leading: Icon(
                              Icons.accessibility_new_rounded,
                              color: permissions.isAccessibilityGranted ? AppColors.primary : AppColors.danger,
                            ),
                            title: Text('Accessibility Service', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(
                              permissions.isAccessibilityGranted
                                  ? 'Active — ready to shield blocked apps'
                                  : 'Disabled — required for app blocking',
                              style: GoogleFonts.inter(
                                color: permissions.isAccessibilityGranted ? AppColors.primaryLight : AppColors.danger,
                                fontSize: 12,
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                            onTap: () => permissionService.requestAccessibility(),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            leading: Icon(
                              Icons.notifications_active_rounded,
                              color: permissions.isNotificationListenerGranted ? AppColors.primary : AppColors.amber,
                            ),
                            title: Text('Notification Access', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(
                              permissions.isNotificationListenerGranted
                                  ? 'Active — incoming banners muted'
                                  : 'Disabled — tap to enable notification muting',
                              style: GoogleFonts.inter(
                                color: permissions.isNotificationListenerGranted ? AppColors.primaryLight : AppColors.amber,
                                fontSize: 12,
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                            onTap: () => permissionService.requestNotificationAccess(),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                            leading: Icon(
                              Icons.battery_saver_rounded,
                              color: permissions.isBatteryOptimizationIgnored ? AppColors.primary : AppColors.amber,
                            ),
                            title: Text('Battery Optimization', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(
                              permissions.isBatteryOptimizationIgnored
                                  ? 'Exempted — background protection active'
                                  : 'Not exempted — Android may stop service',
                              style: GoogleFonts.inter(
                                color: permissions.isBatteryOptimizationIgnored ? AppColors.primaryLight : AppColors.amber,
                                fontSize: 12,
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                            onTap: () => permissionService.requestBatteryOptimization(),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    error: (err, _) => const SizedBox(),
                  ),

                  const SizedBox(height: 28),

                  // SECTION 3: APPEARANCE
                  RefocusSectionHeader(title: 'Appearance'),
                  const SizedBox(height: 12),
                  RefocusCard(
                    tonalElevation: 2,
                    borderRadius: AppRadius.large,
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          leading: const Icon(Icons.dark_mode_rounded, color: AppColors.primary),
                          title: Text('Theme', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.16),
                              borderRadius: AppRadius.fullRadius,
                            ),
                            child: Text(
                              'Premium Dark',
                              style: GoogleFonts.inter(color: AppColors.primaryLight, fontWeight: FontWeight.w700, fontSize: 12),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          leading: const Icon(Icons.language_rounded, color: AppColors.accentCyan),
                          title: Text('Language', style: GoogleFonts.inter(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                          trailing: Text(
                            'English',
                            style: GoogleFonts.inter(color: AppColors.textMuted, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // SECTION 4: PRIVACY & ABOUT
                  RefocusSectionHeader(title: 'Privacy & Security Guarantee'),
                  const SizedBox(height: 12),
                  RefocusCard(
                    tonalElevation: 1,
                    borderRadius: AppRadius.large,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              '100% Local & Privacy-Preserving',
                              style: GoogleFonts.inter(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Refocus runs completely on your device. The Accessibility Service is used strictly to match foreground package names against your blocked list during active focus sessions. No screen content, text, passwords, or personal data are ever read, transmitted, or logged.',
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // App Brand Footer
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
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.2),
                                blurRadius: 12,
                              ),
                            ],
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
                          style: GoogleFonts.outfit(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Focus Today. A Better Tomorrow.',
                          style: GoogleFonts.inter(
                            color: AppColors.secondary,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'v1.0.0 (Premium Dark Edition)',
                          style: GoogleFonts.inter(
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
            ),
          ],
        ),
      ),
    );
  }
}
