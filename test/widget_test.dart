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

  group('Session consistency rules', () {
    FocusSessionModel makeSession(SessionStatus status, {int minutesAgo = 60}) {
      final start = DateTime.now().subtract(Duration(minutes: minutesAgo));
      return FocusSessionModel(
        id: 'id-${status.name}-$minutesAgo',
        startTime: start,
        plannedEndTime: start.add(const Duration(minutes: 25)),
        durationSeconds: 1500,
        status: status,
        isStrictMode: false,
        createdAt: start,
        blockedApps: const ['com.instagram.android'],
      );
    }

    test('active sessions are excluded from history and recent lists', () {
      final sessions = [
        makeSession(SessionStatus.active, minutesAgo: 5),
        makeSession(SessionStatus.completed, minutesAgo: 120),
        makeSession(SessionStatus.interrupted, minutesAgo: 200),
      ];

      // Mirrors the filter used by historyProvider and homeStatsProvider.
      final visible =
          sessions.where((s) => s.status != SessionStatus.active).toList();

      expect(visible.length, 2);
      expect(visible.any((s) => s.status == SessionStatus.active), isFalse);
    });

    test('only completed sessions count toward total focus minutes', () {
      final sessions = [
        makeSession(SessionStatus.completed, minutesAgo: 120),
        makeSession(SessionStatus.completed, minutesAgo: 300),
        makeSession(SessionStatus.interrupted, minutesAgo: 200),
        makeSession(SessionStatus.cancelled, minutesAgo: 400),
        makeSession(SessionStatus.active, minutesAgo: 2),
      ];

      var totalSeconds = 0;
      for (final s in sessions) {
        if (s.status == SessionStatus.completed) {
          totalSeconds += s.durationSeconds;
        }
      }

      // Two completed sessions of 1500s each.
      expect(totalSeconds ~/ 60, 50);
    });

    test('status strings round-trip through fromString', () {
      for (final status in SessionStatus.values) {
        expect(SessionStatus.fromString(status.name), status);
      }
    });

    test('remaining time never goes negative once expired', () {
      final start = DateTime.now().subtract(const Duration(hours: 2));
      final expired = FocusSessionModel(
        id: 'expired',
        startTime: start,
        plannedEndTime: start.add(const Duration(minutes: 25)),
        durationSeconds: 1500,
        status: SessionStatus.active,
        isStrictMode: false,
        createdAt: start,
        blockedApps: const [],
      );

      expect(expired.isExpired, isTrue);
      expect(expired.remainingSeconds, 0);
      expect(expired.progressFraction, 1.0);
      expect(expired.elapsedSeconds, expired.durationSeconds);
    });
  });
}
