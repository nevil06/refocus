# Branding assets

The in-app brand mark is drawn as a **vector widget** (see the `AppLogo` class in
`lib/app/app_logo.dart`). It renders crisply at any size and requires no binary file, so the
welcome screen and other surfaces use it directly:

```dart
import 'package:refocus_again/app/app_logo.dart';

const AppLogo(size: 72);              // mark only
const AppLogo(size: 96, showWordmark: true); // mark + "REFOCUS AGAIN"
```

## Adding a raster logo (optional)

Drop any PNG/SVG store art into this folder (`assets/branding/`). It is already
declared in `pubspec.yaml`, so after `flutter pub get` you can load it with
`Image.asset('assets/branding/<file>.png')`.

## Generating the Android launcher icon

The launcher icon (`android/app/src/main/res/mipmap-*/ic_launcher.png`) is still
the default Flutter icon. To replace it with the brand mark:

1. Export a 1024×1024 PNG of the logo into this folder as `logo_1024.png`.
2. Add the generator to `dev_dependencies` in `pubspec.yaml`:
   ```yaml
   dev_dependencies:
     flutter_launcher_icons: ^0.14.1
   ```
3. Add this config block to `pubspec.yaml`:
   ```yaml
   flutter_launcher_icons:
     android: true
     ios: false
     image_path: "assets/branding/logo_1024.png"
     adaptive_icon_background: "#0F172A"
     adaptive_icon_foreground: "assets/branding/logo_1024.png"
   ```
4. Run:
   ```bash
   flutter pub get
   dart run flutter_launcher_icons
   ```

This regenerates every `mipmap-*` density plus the adaptive-icon layers.
