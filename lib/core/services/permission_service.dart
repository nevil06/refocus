import 'native_bridge_service.dart';

class PermissionStatusState {
  final bool isAccessibilityGranted;
  final bool isBatteryOptimizationIgnored;
  final bool isNotificationGranted;
  final bool isNotificationListenerGranted;
  final bool isScreenPinningEnabled;

  const PermissionStatusState({
    required this.isAccessibilityGranted,
    required this.isBatteryOptimizationIgnored,
    required this.isNotificationGranted,
    this.isNotificationListenerGranted = false,
    this.isScreenPinningEnabled = true,
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
    final screenPinning = await _nativeBridge.isScreenPinningEnabled();

    return PermissionStatusState(
      isAccessibilityGranted: accessibility,
      isBatteryOptimizationIgnored: battery,
      isNotificationGranted: notification,
      isNotificationListenerGranted: notificationListener,
      isScreenPinningEnabled: screenPinning,
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

  Future<void> openScreenPinningSettings() async {
    await _nativeBridge.openScreenPinningSettings();
  }
}
