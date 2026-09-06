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

/// Canonical, persisted list of blocked package names.
///
/// This is the single source of truth for "which apps did the user choose".
/// Every screen that needs the selection (session setup, quick start, settings
/// count, home stats) must read this instead of any in-memory copy, so the list
/// can never drift from what is stored in SQLite. Invalidate it after any change
/// to the selection.
final selectedBlockedPackagesProvider =
    FutureProvider.autoDispose<List<String>>((ref) async {
  final database = ref.watch(databaseProvider);
  return await database.getSelectedBlockedPackageNames();
});

/// Live count of currently selected (blocked) apps, derived from the canonical
/// persisted list above.
final blockedAppsCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final packages = await ref.watch(selectedBlockedPackagesProvider.future);
  return packages.length;
});
