import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../models/installed_app.dart';

class NativeBridgeService {
  static const MethodChannel _channel = MethodChannel(AppConstants.bridgeChannel);

  Future<bool> isAccessibilityEnabled() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('isAccessibilityEnabled');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openAccessibilitySettings() async {
    try {
      await _channel.invokeMethod('openAccessibilitySettings');
    } catch (_) {}
  }

  Future<List<InstalledApp>> getInstalledApps() async {
    try {
      final List<dynamic>? rawList = await _channel.invokeMethod<List<dynamic>>('getInstalledApps');
      if (rawList == null) return [];

      return rawList
          .whereType<Map<dynamic, dynamic>>()
          .map((item) => InstalledApp.fromMap(item))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> startBlocking({
    required String sessionId,
    required DateTime startTime,
    required DateTime plannedEndTime,
    required int durationSeconds,
    required List<String> blockedPackages,
    required bool isStrict,
    String? label,
  }) async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('startBlocking', {
        'sessionId': sessionId,
        'startTimeEpochMs': startTime.millisecondsSinceEpoch,
        'endTimeEpochMs': plannedEndTime.millisecondsSinceEpoch,
        'durationSeconds': durationSeconds,
        'blockedPackages': blockedPackages,
        'isStrict': isStrict,
        'label': label ?? '',
      });
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> stopBlocking() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('stopBlocking');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isBlockingActive() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('isBlockingActive');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getActiveSessionState() async {
    try {
      final dynamic raw = await _channel.invokeMethod('getActiveSessionState');
      if (raw is Map) {
        return Map<String, dynamic>.from(raw);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> isIgnoringBatteryOptimizations() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> requestBatteryOptimizationExemption() async {
    try {
      await _channel.invokeMethod('requestBatteryOptimizationExemption');
    } catch (_) {}
  }

  Future<bool> hasNotificationPermission() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('hasNotificationPermission');
      return result ?? false;
    } catch (_) {
      return true;
    }
  }

  Future<bool> hasUsageStatsPermission() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('hasUsageStatsPermission');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> openUsageStatsSettings() async {
    try {
      await _channel.invokeMethod('openUsageStatsSettings');
    } catch (_) {}
  }
}
