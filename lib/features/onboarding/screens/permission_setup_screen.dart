import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/providers/core_providers.dart';
import '../../../core/widgets/refocus_components.dart';
import '../providers/onboarding_provider.dart';

class PermissionSetupScreen extends ConsumerStatefulWidget {
  const PermissionSetupScreen({super.key});

  @override
  ConsumerState<PermissionSetupScreen> createState() => _PermissionSetupScreenState();
}

class _PermissionSetupScreenState extends ConsumerState<PermissionSetupScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(permissionStatusProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionsAsync = ref.watch(permissionStatusProvider);
    final permissionService = ref.watch(permissionServiceProvider);

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
                        context.go('/onboarding');
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Setup Permissions',
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
              child: permissionsAsync.when(
                data: (permissions) {
                  final canProceed = permissions.isAccessibilityGranted;

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    children: [
                      Text(
                        'To shield you from distracting apps and mute their incoming notifications, Android requires the following setup.',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 1. Accessibility Service Card (Mandatory)
                      _PermissionCard(
                        title: 'Accessibility Service',
                        description:
                            'Detects when a blocked app opens so Refocus can present the focus shield.',
                        isGranted: permissions.isAccessibilityGranted,
                        isRequired: true,
                        onTap: () => permissionService.requestAccessibility(),
                      ),
                      const SizedBox(height: 14),

                      // 2. Notification Access Card (Essential)
                      _PermissionCard(
                        title: 'Notification Access',
                        description:
                            'Silences distracting notifications, banners, and sounds from blocked apps during active focus.',
                        isGranted: permissions.isNotificationListenerGranted,
                        isRequired: true,
                        onTap: () => permissionService.requestNotificationAccess(),
                      ),
                      const SizedBox(height: 14),

                      // 3. Battery Optimization (Recommended)
                      _PermissionCard(
                        title: 'Battery Exemption',
                        description:
                            'Prevents Android from killing the focus blocker while your screen is locked or idle.',
                        isGranted: permissions.isBatteryOptimizationIgnored,
                        isRequired: false,
                        onTap: () => permissionService.requestBatteryOptimization(),
                      ),
                      const SizedBox(height: 24),

                      // Disclosure Note Card
                      RefocusCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_outline_rounded,
                                color: AppColors.primary, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Refocus does not read message texts, passwords, or personal content. Only app package identifiers are checked locally.',
                                style: GoogleFonts.inter(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      RefocusButton(
                        text: canProceed ? 'Continue to Refocus' : 'Grant Accessibility to Continue',
                        icon: canProceed ? Icons.arrow_forward_rounded : Icons.lock_open_rounded,
                        onPressed: canProceed
                            ? () async {
                                await ref
                                    .read(onboardingCompletedProvider.notifier)
                                    .completeOnboarding();
                                if (context.mounted) {
                                  context.go('/home');
                                }
                              }
                            : null,
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
                error: (err, _) => Center(
                  child: Text('Error loading permissions: $err'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final String title;
  final String description;
  final bool isGranted;
  final bool isRequired;
  final VoidCallback onTap;

  const _PermissionCard({
    required this.title,
    required this.description,
    required this.isGranted,
    required this.isRequired,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RefocusCard(
      padding: const EdgeInsets.all(18),
      border: Border.all(
        color: isGranted ? AppColors.primary.withOpacity(0.4) : AppColors.border,
        width: isGranted ? 1.5 : 1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'REQUIRED',
                          style: GoogleFonts.inter(
                            color: AppColors.primaryLight,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isGranted)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 16, color: Colors.white),
                )
              else
                RefocusButton(
                  text: 'Enable',
                  variant: RefocusButtonVariant.secondary,
                  isFullWidth: false,
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  onPressed: onTap,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
