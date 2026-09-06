import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_database.dart';
import '../services/native_bridge_service.dart';
import '../services/permission_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize in main()');
});

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase.instance;
});

final nativeBridgeProvider = Provider<NativeBridgeService>((ref) {
  return NativeBridgeService();
});

final permissionServiceProvider = Provider<PermissionService>((ref) {
  final bridge = ref.watch(nativeBridgeProvider);
  return PermissionService(bridge);
});

final permissionStatusProvider = FutureProvider.autoDispose<PermissionStatusState>((ref) async {
  final service = ref.watch(permissionServiceProvider);
  return await service.checkAllPermissions();
});

final notificationBlockingEnabledProvider = StateNotifierProvider<NotificationBlockingNotifier, bool>((ref) {
  final bridge = ref.watch(nativeBridgeProvider);
  return NotificationBlockingNotifier(bridge);
});

class NotificationBlockingNotifier extends StateNotifier<bool> {
  final NativeBridgeService _bridge;

  NotificationBlockingNotifier(this._bridge) : super(true) {
    _load();
  }

  Future<void> _load() async {
    final enabled = await _bridge.isNotificationBlockingEnabled();
    state = enabled;
  }

  Future<void> toggle(bool enabled) async {
    state = enabled;
    await _bridge.setNotificationBlockingEnabled(enabled);
  }
}
