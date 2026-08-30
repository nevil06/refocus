import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

final routerProvider = Provider<GoRouter>((ref) {
  final hasCompletedOnboarding = ref.watch(onboardingCompletedProvider);

  return GoRouter(
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
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/apps',
        builder: (context, state) => const AppSelectionScreen(),
      ),
      GoRoute(
        path: '/focus/setup',
        builder: (context, state) => const SessionSetupScreen(),
      ),
      GoRoute(
        path: '/focus/active',
        builder: (context, state) => const FocusTimerScreen(),
      ),
      GoRoute(
        path: '/focus/complete',
        builder: (context, state) => const SessionCompleteScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
