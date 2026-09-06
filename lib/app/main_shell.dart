import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'theme.dart';
import '../core/providers/core_providers.dart';

/// App shell hosting the three primary destinations (Home, History, Settings)
/// with a persistent bottom navigation bar.
///
/// It also acts as the app-wide lifecycle observer: whenever the app returns to
/// the foreground we re-verify the accessibility permission. That matters because
/// accessibility can be turned off outside the app (including by hiding the
/// system accessibility shortcut on some devices), which would otherwise
/// silently stop all blocking.
///
/// Inset handling: with edge-to-edge enabled (see main.dart), the Material 3
/// [NavigationBar] automatically reserves space for the system navigation area,
/// so it sits correctly above BOTH the gesture pill and the 3-button nav bar
/// without any hardcoded padding. We wrap it in [SafeArea] (top: false) as a
/// belt-and-braces guard for devices that report the inset differently.
class MainShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
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
      ref.invalidate(blockedAppsCountProvider);
    }
  }

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      // Re-tapping the active tab returns to that branch's initial route.
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Let the body draw behind the (transparent) system bars; each screen
      // uses its own SafeArea for the top/header inset.
      extendBody: true,
      body: widget.navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            height: 64,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            indicatorColor: AppColors.primary.withValues(alpha: 0.18),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            selectedIndex: widget.navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
            destinations: [
              NavigationDestination(
                icon: Icon(Icons.home_outlined, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.home_rounded, color: AppColors.primary),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_outlined, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.history_rounded, color: AppColors.primary),
                label: 'History',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined, color: AppColors.textSecondary),
                selectedIcon: Icon(Icons.settings_rounded, color: AppColors.primary),
                label: 'Settings',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
