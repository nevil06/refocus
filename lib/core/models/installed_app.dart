import 'dart:convert';
import 'dart:typed_data';

class InstalledApp {
  final String appName;
  final String packageName;
  final String iconBase64;
  final bool isSelected;

  Uint8List? _cachedIconBytes;

  InstalledApp({
    required this.appName,
    required this.packageName,
    required this.iconBase64,
    this.isSelected = false,
  });

  Uint8List? get iconBytes {
    if (_cachedIconBytes != null) return _cachedIconBytes;
    if (iconBase64.isNotEmpty) {
      try {
        _cachedIconBytes = base64Decode(iconBase64);
        return _cachedIconBytes;
      } catch (_) {}
    }
    return null;
  }

  InstalledApp copyWith({
    String? appName,
    String? packageName,
    String? iconBase64,
    bool? isSelected,
  }) {
    return InstalledApp(
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      iconBase64: iconBase64 ?? this.iconBase64,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory InstalledApp.fromMap(Map<dynamic, dynamic> map, {bool isSelected = false}) {
    return InstalledApp(
      appName: map['appName'] as String? ?? '',
      packageName: map['packageName'] as String? ?? '',
      iconBase64: map['iconBase64'] as String? ?? '',
      isSelected: isSelected,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'packageName': packageName,
      'iconBase64': iconBase64,
      'isSelected': isSelected,
    };
  }
}
