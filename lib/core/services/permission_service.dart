import 'native_bridge_service.dart';

class PermissionStatusState {
  final bool isAccessibilityGranted;
  final bool isBatteryOptimizationIgnored;
  final bool isNotificationGranted;
  final bool isNotificationListenerGranted;

  const PermissionStatusState({
    required this.isAccessibilityGranted,
    required this.isBatteryOptimizationIgnored,
    required this.isNotificationGranted,
    this.isNotificationListenerGranted = false,
  });

  bool get isCorePermissionGranted => isAccessibilityGranted;
}

class PermissionService {
  final NativeBridgeService _nativeBridge;

  PermissionService(this._nativeBridge);

  Future<PermissionStatusState> checkAllPermissions() async {
    final accessibility = await _nativeBridge.isAccessibilityEnabled();
    final battery = await _nativeBridge.isIgnoringBatteryOptimizations();
    final notification = await _nativeBridge.hasNotificationPermission();
    final notificationListener = await _nativeBridge.getNotificationPermissionStatus();

    return PermissionStatusState(
      isAccessibilityGranted: accessibility,
      isBatteryOptimizationIgnored: battery,
      isNotificationGranted: notification,
      isNotificationListenerGranted: notificationListener,
    );
  }

  Future<void> requestAccessibility() async {
    await _nativeBridge.openAccessibilitySettings();
  }

  Future<void> requestBatteryOptimization() async {
    await _nativeBridge.requestBatteryOptimizationExemption();
  }

  Future<void> requestNotificationAccess() async {
    await _nativeBridge.requestNotificationAccess();
  }
}
