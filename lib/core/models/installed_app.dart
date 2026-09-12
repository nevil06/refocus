import 'dart:convert';
import 'dart:typed_data';

class InstalledApp {
  final String appName;
  final String packageName;
  final String iconBase64;
  final Uint8List? iconBytes;
  final bool isSelected;

  InstalledApp({
    required this.appName,
    required this.packageName,
    this.iconBase64 = '',
    this.iconBytes,
    this.isSelected = false,
  });

  InstalledApp copyWith({
    String? appName,
    String? packageName,
    String? iconBase64,
    Uint8List? iconBytes,
    bool? isSelected,
  }) {
    return InstalledApp(
      appName: appName ?? this.appName,
      packageName: packageName ?? this.packageName,
      iconBase64: iconBase64 ?? this.iconBase64,
      iconBytes: iconBytes ?? this.iconBytes,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  factory InstalledApp.fromMap(Map<dynamic, dynamic> map, {bool isSelected = false}) {
    Uint8List? parsedBytes;

    final rawIconBytes = map['iconBytes'];
    if (rawIconBytes is Uint8List) {
      parsedBytes = rawIconBytes;
    } else if (rawIconBytes is List<int>) {
      parsedBytes = Uint8List.fromList(rawIconBytes);
    } else if (rawIconBytes is List<dynamic>) {
      try {
        parsedBytes = Uint8List.fromList(rawIconBytes.cast<int>());
      } catch (_) {}
    }

    final b64 = map['iconBase64'] as String? ?? '';
    if (parsedBytes == null && b64.isNotEmpty) {
      try {
        parsedBytes = base64Decode(b64);
      } catch (_) {}
    }

    return InstalledApp(
      appName: map['appName'] as String? ?? '',
      packageName: map['packageName'] as String? ?? '',
      iconBase64: b64,
      iconBytes: parsedBytes,
      isSelected: isSelected,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appName': appName,
      'packageName': packageName,
      'iconBase64': iconBase64,
      'iconBytes': iconBytes,
      'isSelected': isSelected,
    };
  }
}

