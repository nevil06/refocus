import 'package:flutter/foundation.dart';
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

      debugPrint('=== Dart AppIconDiag: Received ${rawList.length} apps from native MethodChannel ===');
      for (final item in rawList) {
        if (item is Map) {
          final pkg = item['packageName'];
          final name = item['appName'];
          final rawBytes = item['iconBytes'];
          final typeStr = rawBytes == null ? 'null' : rawBytes.runtimeType.toString();
          final len = rawBytes is Uint8List
              ? rawBytes.length
              : (rawBytes is List ? rawBytes.length : (rawBytes != null ? 'unknown' : 'null'));
          debugPrint('Dart AppIconDiag: $pkg ($name) -> iconBytes type: $typeStr, length: $len');
        }
      }

      return rawList
          .whereType<Map<dynamic, dynamic>>()
          .map((item) => InstalledApp.fromMap(item))
          .toList();
    } catch (e, stack) {
      debugPrint('NativeBridgeService.getInstalledApps error: $e\n$stack');
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
    int? strictModeType,
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
        'strictModeType': strictModeType ?? (isStrict ? 1 : 0),
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

  Future<bool> getNotificationPermissionStatus() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('getNotificationPermissionStatus');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> requestNotificationAccess() async {
    try {
      await _channel.invokeMethod('requestNotificationAccess');
    } catch (_) {}
  }

  Future<bool> isNotificationBlockingEnabled() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('isNotificationBlockingEnabled');
      return result ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<bool> setNotificationBlockingEnabled(bool enabled) async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('setNotificationBlockingEnabled', {
        'enabled': enabled,
      });
      return result ?? true;
    } catch (_) {
      return false;
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

  // Screen Pinning (Lock Task Mode)
  Future<bool> startScreenPinning() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('startScreenPinning');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> stopScreenPinning() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('stopScreenPinning');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isInLockTaskMode() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('isInLockTaskMode');
      return result ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isScreenPinningEnabled() async {
    try {
      final bool? result = await _channel.invokeMethod<bool>('isScreenPinningEnabled');
      return result ?? true;
    } catch (_) {
      return true;
    }
  }

  Future<void> openScreenPinningSettings() async {
    try {
      await _channel.invokeMethod('openScreenPinningSettings');
    } catch (_) {}
  }
}
