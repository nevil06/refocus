import 'native_bridge_service.dart';

class PermissionStatusState {
  final bool isAccessibilityGranted;
  final bool isBatteryOptimizationIgnored;
  final bool isNotificationGranted;

  const PermissionStatusState({
    required this.isAccessibilityGranted,
    required this.isBatteryOptimizationIgnored,
    required this.isNotificationGranted,
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

    return PermissionStatusState(
      isAccessibilityGranted: accessibility,
      isBatteryOptimizationIgnored: battery,
      isNotificationGranted: notification,
    );
  }

  Future<void> requestAccessibility() async {
    await _nativeBridge.openAccessibilitySettings();
  }

  Future<void> requestBatteryOptimization() async {
    await _nativeBridge.requestBatteryOptimizationExemption();
  }
}
