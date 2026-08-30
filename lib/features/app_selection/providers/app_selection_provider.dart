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
  return AppSelectionNotifier(nativeBridge, database);
});

class AppSelectionNotifier extends StateNotifier<AppSelectionState> {
  final dynamic _nativeBridge;
  final dynamic _database;

  AppSelectionNotifier(this._nativeBridge, this._database)
      : super(AppSelectionState(isLoading: true)) {
    loadApps();
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

      final mergedApps = installedApps.map<InstalledApp>((app) {
        final isSelected = savedBlockedSet.contains(app.packageName);
        return app.copyWith(isSelected: isSelected);
      }).toList();

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

  void toggleSelection(String packageName) {
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

    // Update database immediately
    final target = updatedAll.firstWhere((a) => a.packageName == packageName);
    _database.setAppBlocked(target.packageName, target.appName, target.isSelected);
  }

  void selectAll() {
    final updatedAll = state.allApps.map((app) => app.copyWith(isSelected: true)).toList();
    state = state.copyWith(
      allApps: updatedAll,
      filteredApps: _filter(updatedAll, state.searchQuery),
    );
    for (final app in updatedAll) {
      _database.setAppBlocked(app.packageName, app.appName, true);
    }
  }

  void deselectAll() {
    final updatedAll = state.allApps.map((app) => app.copyWith(isSelected: false)).toList();
    state = state.copyWith(
      allApps: updatedAll,
      filteredApps: _filter(updatedAll, state.searchQuery),
    );
    for (final app in updatedAll) {
      _database.setAppBlocked(app.packageName, app.appName, false);
    }
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
