import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'main_shell.dart';
import '../features/onboarding/screens/welcome_screen.dart';
import '../features/onboarding/screens/permission_setup_screen.dart';
import '../features/onboarding/providers/onboarding_provider.dart';
import '../features/home/screens/home_screen.dart';
import '../features/app_selection/screens/app_selection_screen.dart';
import '../features/focus/screens/session_setup_screen.dart';
import '../features/focus/screens/focus_timer_screen.dart';
import '../features/focus/screens/session_complete_screen.dart';
import '../features/history/screens/history_screen.dart';
import '../features/settings/screens/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final hasCompletedOnboarding = ref.watch(onboardingCompletedProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: hasCompletedOnboarding ? '/home' : '/onboarding',
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const WelcomeScreen(),
        routes: [
          GoRoute(
            path: 'permissions',
            builder: (context, state) => const PermissionSetupScreen(),
          ),
        ],
      ),

      // Primary destinations hosted in a persistent bottom-nav shell.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),

      // Full-screen routes pushed above the shell (no bottom nav).
      GoRoute(
        path: '/apps',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AppSelectionScreen(),
      ),
      GoRoute(
        path: '/focus/setup',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SessionSetupScreen(),
      ),
      GoRoute(
        path: '/focus/active',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FocusTimerScreen(),
      ),
      GoRoute(
        path: '/focus/complete',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SessionCompleteScreen(),
      ),
    ],
  );
});
