import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:refocus_again/app/theme.dart';
import 'package:refocus_again/core/models/focus_session.dart';
import 'package:refocus_again/core/models/installed_app.dart';
import 'package:refocus_again/core/services/permission_service.dart';
import 'package:refocus_again/core/utils/time_utils.dart';
import 'package:refocus_again/core/widgets/refocus_components.dart';

void main() {
  group('TimeUtils Tests', () {
    test('formatRemainingSeconds handles minutes and seconds', () {
      expect(TimeUtils.formatRemainingSeconds(125), '02:05');
      expect(TimeUtils.formatRemainingSeconds(0), '00:00');
      expect(TimeUtils.formatRemainingSeconds(3665), '01:01:05');
    });

    test('formatDurationMinutes formats correctly', () {
      expect(TimeUtils.formatDurationMinutes(25), '25m');
      expect(TimeUtils.formatDurationMinutes(60), '1h');
      expect(TimeUtils.formatDurationMinutes(90), '1h 30m');
      expect(TimeUtils.formatDurationMinutes(0), '0m');
    });
  });

  group('FocusSessionModel Tests', () {
    test('calculates remaining seconds and expiration accurately from timestamps', () {
      final now = DateTime.now();
      final session = FocusSessionModel(
        id: 'test-123',
        startTime: now.subtract(const Duration(minutes: 10)),
        plannedEndTime: now.add(const Duration(minutes: 15)),
        durationSeconds: 1500,
        status: SessionStatus.active,
        strictModeType: StrictModeType.friction,
        createdAt: now.subtract(const Duration(minutes: 10)),
        blockedApps: ['com.instagram.android', 'com.google.android.youtube'],
      );

      expect(session.isExpired, false);
      expect(session.remainingSeconds > 0, true);
      expect(session.remainingSeconds <= 900, true);
      expect(session.progressFraction > 0.0, true);
      expect(session.progressFraction < 1.0, true);
      expect(session.isStrictMode, true);
      expect(session.isFrictionMode, true);
      expect(session.isLockedMode, false);
    });

    test('supports 3 distinct StrictModeType tiers (Off, Friction, Locked)', () {
      final offSession = FocusSessionModel(
        id: 'off-1',
        startTime: DateTime.now(),
        plannedEndTime: DateTime.now().add(const Duration(minutes: 25)),
        durationSeconds: 1500,
        status: SessionStatus.active,
        strictModeType: StrictModeType.off,
        createdAt: DateTime.now(),
        blockedApps: [],
      );
      expect(offSession.isStrictMode, false);
      expect(offSession.isFrictionMode, false);
      expect(offSession.isLockedMode, false);

      final frictionSession = offSession.copyWith(strictModeType: StrictModeType.friction);
      expect(frictionSession.isStrictMode, true);
      expect(frictionSession.isFrictionMode, true);
      expect(frictionSession.isLockedMode, false);

      final lockedSession = offSession.copyWith(strictModeType: StrictModeType.locked);
      expect(lockedSession.isStrictMode, true);
      expect(lockedSession.isFrictionMode, false);
      expect(lockedSession.isLockedMode, true);

      // Verify conversions
      expect(StrictModeType.fromInt(0), StrictModeType.off);
      expect(StrictModeType.fromInt(1), StrictModeType.friction);
      expect(StrictModeType.fromInt(2), StrictModeType.locked);

      expect(StrictModeType.off.toInt(), 0);
      expect(StrictModeType.friction.toInt(), 1);
      expect(StrictModeType.locked.toInt(), 2);
    });
  });

  group('InstalledApp Model Tests', () {
    test('instantiates and copies correctly', () {
      final app = InstalledApp(
        appName: 'Instagram',
        packageName: 'com.instagram.android',
        iconBase64: '',
        isSelected: false,
      );

      expect(app.appName, 'Instagram');
      expect(app.isSelected, false);

      final toggled = app.copyWith(isSelected: true);
      expect(toggled.isSelected, true);
      expect(toggled.packageName, 'com.instagram.android');
    });

    test('parses iconBytes from map as Uint8List or List<int>', () {
      final dummyBytes = [137, 80, 78, 71, 13, 10, 26, 10]; // PNG magic header
      final appFromList = InstalledApp.fromMap({
        'appName': 'YouTube',
        'packageName': 'com.google.android.youtube',
        'iconBytes': dummyBytes,
      });

      expect(appFromList.appName, 'YouTube');
      expect(appFromList.iconBytes != null, true);
      expect(appFromList.iconBytes!.length, 8);
    });
  });


  group('PermissionStatusState Tests', () {
    test('instantiates with permissions and Screen Pinning properties', () {
      const state = PermissionStatusState(
        isAccessibilityGranted: true,
        isBatteryOptimizationIgnored: true,
        isNotificationGranted: true,
        isNotificationListenerGranted: true,
        isScreenPinningEnabled: true,
      );

      expect(state.isAccessibilityGranted, true);
      expect(state.isNotificationListenerGranted, true);
      expect(state.isScreenPinningEnabled, true);
      expect(state.isCorePermissionGranted, true);
    });
  });

  group('Premium Dark Theme & Component Tests', () {
    test('AppColors verify violet / obsidian dark tokens', () {
      expect(AppColors.deepObsidian, const Color(0xFF090A0F));
      expect(AppColors.background, const Color(0xFF090A0F));
      expect(AppColors.primary, const Color(0xFF8B5CF6));
      expect(AppColors.surface, const Color(0xFF12151E));
      expect(AppColors.surfaceElevated, const Color(0xFF1A1F2C));
      expect(AppColors.neonMint, const Color(0xFF00E699));
      expect(AppColors.electricCyan, const Color(0xFF38BDF8));
      expect(AppColors.royalIndigo, const Color(0xFF818CF8));
    });

    test('AppRadius tokens verify Neo-Brutalism sharp shape scale', () {
      expect(AppRadius.small, 2.0);
      expect(AppRadius.medium, 3.0);
      expect(AppRadius.large, 4.0);
      expect(AppRadius.extraLarge, 4.0);
      expect(AppRadius.full, 4.0);
    });

    testWidgets('RefocusButton renders with text and triggers callback', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: RefocusButton(
              text: 'Start Focus',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Start Focus'), findsOneWidget);
      await tester.tap(find.text('Start Focus'));
      expect(tapped, true);
    });

    testWidgets('RefocusProgressRing renders time text and subtitle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(
            body: RefocusProgressRing(
              progress: 0.6,
              timeText: '24:17',
              subtitle: '25m planned',
            ),
          ),
        ),
      );

      expect(find.text('24:17'), findsOneWidget);
      expect(find.text('25m planned'), findsOneWidget);
    });
  });
}
