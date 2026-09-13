# Generate Native Splash Screen

Uses [`flutter_native_splash`](https://pub.dev/packages/flutter_native_splash).
Supports **Android, iOS, Web**. Windows / macOS / Linux have no native splash — the window
opens directly into Flutter (see [Desktop](#desktop)).

Reuses the app icon from [003-generate-app-icons.md](003-generate-app-icons.md):
`assets/icon/icon.png` — 1254×1254, transparent background, brand blue `#1168E3`.

## Steps

### 1. Add dependency
```bash
flutter pub add flutter_native_splash
```
Regular dependency (not `dev:`) — `FlutterNativeSplash.preserve/remove` is called at runtime.

### 2. Add config to `pubspec.yaml`
```yaml
flutter_native_splash:
  # ---------- Platforms ----------
  android: true
  ios: true
  web: true

  # ---------- Android <12, iOS, Web ----------
  color: "#FFFFFF"
  color_dark: "#121212"
  image: assets/icon/icon.png           # treated as 4x (xxxhdpi) → ~313dp canvas
  # image_dark: assets/icon/icon_dark.png   # only if the logo needs a dark variant (file must exist)

  # ---------- Android 12+ ----------
  android_12:
    color: "#FFFFFF"
    color_dark: "#121212"
    image: assets/icon/icon.png         # fits the circle mask as-is — see below
    # icon_background_color: "#1168E3"  # only if you want a filled circle behind the icon

  # ---------- Layout ----------
  android_gravity: center
  ios_content_mode: center
  web_image_mode: center
  fullscreen: false                     # true hides status bar (mobile only)
```

### 3. Generate
```bash
dart run flutter_native_splash:create
```
Changes:
- **Android:** `res/drawable*/launch_background.xml`, `res/drawable-*/splash.png`, `res/values*/styles.xml`, `values-v31/` (Android 12)
- **iOS:** `Runner/Assets.xcassets/LaunchImage.imageset`, `LaunchBackground.imageset`, `Base.lproj/LaunchScreen.storyboard`, `Info.plist`
- **Web:** `web/splash/img/*`, `web/index.html` (inline splash CSS + `<picture>`)

### 4. (Optional) Keep splash visible during async init — `lib/main.dart`

Without this, the splash is removed automatically when Flutter draws the first frame.
Only add it once `main` has real async startup work (DI, Firebase, local storage, auth check…):

```dart
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // await initDependencies();
  // await Firebase.initializeApp();

  runApp(const MainApp());
  FlutterNativeSplash.remove();
}
```
- Always call `remove()` — also on error paths (`try/finally`), otherwise the app stays stuck on the splash.
- Don't block on slow network calls here; show an in-app loading state instead.

### 5. Verify
```bash
flutter run -d chrome     # hard refresh (Ctrl+Shift+R)
flutter run -d <android>  # cold start: uninstall or kill the app first
```
- Hot reload / hot restart never shows the native splash — do a full cold start.
- Android 12+: the splash may not appear when launched from `flutter run`/Android Studio;
  close the app and open it from the launcher.
- Test dark mode: switch the device to dark theme and cold start again.

## Android 12 icon size requirement

Android 12+ uses the SplashScreen API and clips the icon to a circle:

| Mode | Canvas | Visible circle | Ratio |
|------|--------|----------------|-------|
| No `icon_background_color` (our setup) | 1152×1152 px | 768 px diameter | 66.7% |
| With `icon_background_color` | 960×960 px | 640 px diameter | 66.7% |

Our `assets/icon/icon.png` (measured):

| | Value |
|---|---|
| Canvas | 1254×1254, transparent |
| Logo bounding box | (290,292) – (962,964) → ~672 px |
| Farthest opaque pixel from center | 826 px diameter = **65.9%** of canvas |

65.9% < 66.7% → **the rounded-square logo fits the mask without extra padding**, so the same
file is used for `image` and `android_12.image`. The margin is small (~5 px at 1152):
if the logo changes or gets bigger, re-check it, or create a padded copy
(e.g. `assets/icon/splash_android12.png` with the logo inside the center 66%) and point
`android_12.image` to it.

## Desktop

`flutter_native_splash` does nothing on Windows / macOS / Linux. Options:
- Leave as is — desktop startup is fast; the window shows the first Flutter frame.
- Show a Flutter-level splash (a simple widget/route) while async init runs.
- Windows: the runner already delays showing the window until the first frame
  (`windows/runner/flutter_window.cpp` → `SetNextFrameCallback`), so there is no white flash.

## Notes
- Re-run `dart run flutter_native_splash:create` whenever the logo or colors change.
- To revert all native changes: `dart run flutter_native_splash:remove`.
- Keep `color` in sync with the app's first screen / `ThemeData` background to avoid a flash
  between splash and app.
- `android_12` must be configured separately; otherwise Android 12+ shows the launcher icon
  on the default background.
- Commit the generated files under `android/`, `ios/`, `web/`.
