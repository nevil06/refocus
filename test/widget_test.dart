import 'package:flutter_test/flutter_test.dart';
import 'package:refocus_again/core/models/focus_session.dart';
import 'package:refocus_again/core/models/installed_app.dart';
import 'package:refocus_again/core/utils/time_utils.dart';

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
        isStrictMode: true,
        createdAt: now.subtract(const Duration(minutes: 10)),
        blockedApps: ['com.instagram.android', 'com.google.android.youtube'],
      );

      expect(session.isExpired, false);
      expect(session.remainingSeconds > 0, true);
      expect(session.remainingSeconds <= 900, true);
      expect(session.progressFraction > 0.0, true);
      expect(session.progressFraction < 1.0, true);
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
  });
}
