import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'core/database/app_database.dart';
import 'core/providers/core_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Edge-to-edge so our own SafeArea/insets control spacing consistently across
  // gesture-nav and 3-button-nav devices, instead of the OS reserving an opaque bar.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final sharedPreferences = await SharedPreferences.getInstance();
  // Ensure database initialization
  await AppDatabase.instance.database;

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const RefocusAgainApp(),
    ),
  );
}

class RefocusAgainApp extends ConsumerWidget {
  const RefocusAgainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    // Follow the system light/dark setting.
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    // Keep the runtime palette in sync so AppColors.* resolves correctly.
    AppColors.brightness = platformBrightness;

    final isDark = platformBrightness == Brightness.dark;
    // Transparent system bars whose icon brightness matches the theme, so the
    // status/nav bar icons stay legible in both light and dark mode.
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return MaterialApp.router(
      title: 'Refocus Again',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
