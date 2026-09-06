import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/installed_app.dart';
import '../../../core/providers/core_providers.dart';

// Fallback curated distracting apps list in case platform channel returns empty
final List<InstalledApp> _fallbackCuratedApps = [
  InstalledApp(appName: 'Instagram', packageName: 'com.instagram.android', iconBase64: ''),
  InstalledApp(appName: 'YouTube', packageName: 'com.google.android.youtube', iconBase64: ''),
  InstalledApp(appName: 'Snapchat', packageName: 'com.snapchat.android', iconBase64: ''),
  InstalledApp(appName: 'Reddit', packageName: 'com.reddit.frontpage', iconBase64: ''),
  InstalledApp(appName: 'Chrome', packageName: 'com.android.chrome', iconBase64: ''),
  InstalledApp(appName: 'TikTok', packageName: 'com.zhiliaoapp.musically', iconBase64: ''),
  InstalledApp(appName: 'Facebook', packageName: 'com.facebook.katana', iconBase64: ''),
  InstalledApp(appName: 'X (Twitter)', packageName: 'com.twitter.android', iconBase64: ''),
  InstalledApp(appName: 'Netflix', packageName: 'com.netflix.mediaclient', iconBase64: ''),
  InstalledApp(appName: 'Discord', packageName: 'com.discord', iconBase64: ''),
  InstalledApp(appName: 'WhatsApp', packageName: 'com.whatsapp', iconBase64: ''),
  InstalledApp(appName: 'Telegram', packageName: 'org.telegram.messenger', iconBase64: ''),
  InstalledApp(appName: 'Spotify', packageName: 'com.spotify.music', iconBase64: ''),
  InstalledApp(appName: 'Prime Video', packageName: 'com.amazon.avod.thirdpartyclient', iconBase64: ''),
  InstalledApp(appName: 'Pinterest', packageName: 'com.pinterest', iconBase64: ''),
];

class AppSelectionState {
  final List<InstalledApp> allApps;
  final List<InstalledApp> filteredApps;
  final String searchQuery;
  final bool isLoading;

  AppSelectionState({
    this.allApps = const [],
    this.filteredApps = const [],
    this.searchQuery = '',
    this.isLoading = false,
  });

  int get selectedCount => allApps.where((a) => a.isSelected).length;

  List<String> get selectedPackageNames =>
      allApps.where((a) => a.isSelected).map((a) => a.packageName).toList();

  AppSelectionState copyWith({
    List<InstalledApp>? allApps,
    List<InstalledApp>? filteredApps,
    String? searchQuery,
    bool? isLoading,
  }) {
    return AppSelectionState(
      allApps: allApps ?? this.allApps,
      filteredApps: filteredApps ?? this.filteredApps,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final appSelectionProvider =
    StateNotifierProvider<AppSelectionNotifier, AppSelectionState>((ref) {
  final nativeBridge = ref.watch(nativeBridgeProvider);
  final database = ref.watch(databaseProvider);
  return AppSelectionNotifier(nativeBridge, database, ref);
});

class AppSelectionNotifier extends StateNotifier<AppSelectionState> {
  final dynamic _nativeBridge;
  final dynamic _database;
  final Ref _ref;

  AppSelectionNotifier(this._nativeBridge, this._database, this._ref)
      : super(AppSelectionState(isLoading: true)) {
    loadApps();
  }

  /// Notifies every consumer of the persisted selection that it changed, so the
  /// settings count, session setup list and home stats all stay in sync.
  void _notifySelectionChanged() {
    _ref.invalidate(selectedBlockedPackagesProvider);
    _ref.invalidate(blockedAppsCountProvider);
  }

  Future<void> loadApps() async {
    state = state.copyWith(isLoading: true);
    try {
      List<InstalledApp> installedApps = await _nativeBridge.getInstalledApps();
      if (installedApps.isEmpty) {
        installedApps = List.from(_fallbackCuratedApps);
      }

      final savedBlockedPackages = await _database.getSelectedBlockedPackageNames();
      final savedBlockedSet = Set<String>.from(savedBlockedPackages);

      // A previously chosen package that is not in the discovered list (for
      // example an app that failed to enumerate) must still be shown as chosen,
      // so the user's saved selection is never silently dropped.
      final knownPackages = installedApps.map((a) => a.packageName).toSet();
      final restored = savedBlockedSet
          .where((p) => !knownPackages.contains(p))
          .map((p) => InstalledApp(appName: p, packageName: p, iconBase64: ''))
          .toList();

      final mergedApps = [...installedApps, ...restored].map<InstalledApp>((app) {
        final isSelected = savedBlockedSet.contains(app.packageName);
        return app.copyWith(isSelected: isSelected);
      }).toList()
        ..sort((a, b) =>
            a.appName.toLowerCase().compareTo(b.appName.toLowerCase()));

      state = state.copyWith(
        allApps: mergedApps,
        filteredApps: _filter(mergedApps, state.searchQuery),
        isLoading: false,
      );
    } catch (_) {
      // If native bridge throws, use fallback list
      final savedBlockedPackages = await _database.getSelectedBlockedPackageNames();
      final savedBlockedSet = Set<String>.from(savedBlockedPackages);

      final fallback = _fallbackCuratedApps.map((app) {
        final isSelected = savedBlockedSet.contains(app.packageName);
        return app.copyWith(isSelected: isSelected);
      }).toList();

      state = state.copyWith(
        allApps: fallback,
        filteredApps: _filter(fallback, state.searchQuery),
        isLoading: false,
      );
    }
  }

  void search(String query) {
    state = state.copyWith(
      searchQuery: query,
      filteredApps: _filter(state.allApps, query),
    );
  }

  /// Toggles one app and PERSISTS it before returning, so the choice survives the
  /// app being killed immediately afterwards.
  Future<void> toggleSelection(String packageName) async {
    final updatedAll = state.allApps.map((app) {
      if (app.packageName == packageName) {
        return app.copyWith(isSelected: !app.isSelected);
      }
      return app;
    }).toList();

    state = state.copyWith(
      allApps: updatedAll,
      filteredApps: _filter(updatedAll, state.searchQuery),
    );

    final target = updatedAll.firstWhere((a) => a.packageName == packageName);
    await _database.setAppBlocked(
      target.packageName,
      target.appName,
      target.isSelected,
    );
    _notifySelectionChanged();
  }

  Future<void> selectAll() => _setAll(true);

  Future<void> deselectAll() => _setAll(false);

  /// Applies a selection change to every app in one atomic batch write.
  Future<void> _setAll(bool isSelected) async {
    final updatedAll = state.allApps
        .map((app) => app.copyWith(isSelected: isSelected))
        .toList();
    state = state.copyWith(
      allApps: updatedAll,
      filteredApps: _filter(updatedAll, state.searchQuery),
    );

    await _database.setAppsBlockedBatch(
      updatedAll
          .map((app) => (
                packageName: app.packageName,
                appName: app.appName,
                isSelected: isSelected,
              ))
          .toList(),
    );
    _notifySelectionChanged();
  }

  List<InstalledApp> _filter(List<InstalledApp> list, String query) {
    if (query.trim().isEmpty) return list;
    final q = query.toLowerCase().trim();
    return list.where((app) {
      return app.appName.toLowerCase().contains(q) ||
          app.packageName.toLowerCase().contains(q);
    }).toList();
  }
}
