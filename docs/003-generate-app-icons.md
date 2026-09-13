# Generate App Icons

Uses [`flutter_launcher_icons`](https://pub.dev/packages/flutter_launcher_icons).
Supports **Android, iOS, Web, Windows, macOS**. **Linux is not supported** — see the manual step below.

## Source images

Put these under `assets/icon/` (PNG):

| File | Size | Used for | Notes |
|---|---|---|---|
| `icon.png` | 1024x1024 | All platforms (default) | Square, full-bleed |
| `icon_foreground.png` | 1024x1024 | Android adaptive foreground | Transparent bg, logo inside the center ~66% safe zone |
| `icon_monochrome.png` | 1024x1024 | Android 13+ themed icon | Single color (white) on transparent |
| `icon_ios_dark.png` | 1024x1024 | iOS 18+ dark mode | Transparent bg |
| `icon_web_maskable.png` | 1024x1024 | (optional) Web | Logo inside center 80% |

> Only `icon.png` is required. Remove the lines for images you don't have.

## Steps

### 1. Add dependency
```bash
flutter pub add dev:flutter_launcher_icons
```

### 2. Add config to `pubspec.yaml`
```yaml
flutter_launcher_icons:
  image_path: "assets/icon/icon.png"   # default for every platform

  # ---------- Android ----------
  android: true                         # true = overwrite ic_launcher
  min_sdk_android: 21                   # only used if minSdk can't be read from gradle
  # ⚠ Uncomment ONLY if the image files exist — a missing file aborts the whole run
  #   after Android, so iOS/Web/Windows/macOS icons are never generated.
  # adaptive_icon_background: "#FFFFFF"   # hex color or image path
  # adaptive_icon_foreground: "assets/icon/icon_foreground.png"
  # adaptive_icon_foreground_inset: 16    # padding %, tweak if logo is clipped
  # adaptive_icon_monochrome: "assets/icon/icon_monochrome.png"  # Android 13+ themed icons

  # ---------- iOS ----------
  ios: true
  remove_alpha_ios: true                # App Store rejects transparent icons
  background_color_ios: "#FFFFFF"       # fill color for removed alpha
  # image_path_ios_dark_transparent: "assets/icon/icon_ios_dark.png"  # iOS 18+ dark (needs file)

  # ---------- Web ----------
  web:
    generate: true                      # favicon.png + web/icons/Icon-*.png (incl. maskable)
    background_color: "#FFFFFF"         # -> web/manifest.json (PWA splash bg)
    theme_color: "#0175C2"              # -> web/manifest.json (browser/toolbar color)

  # ---------- Windows ----------
  windows:
    generate: true                      # -> windows/runner/resources/app_icon.ico
    icon_size: 256                      # 48–256, default 48. Use 256 for crisp HiDPI/taskbar

  # ---------- macOS ----------
  macos:
    generate: true                      # -> macos/Runner/Assets.xcassets/AppIcon.appiconset
```

Per-platform image overrides (optional): `image_path_android`, `image_path_ios`, and `image_path` inside the `web` / `windows` / `macos` blocks.

### 3. Run
```bash
dart run flutter_launcher_icons
```
(`flutter pub run` is deprecated.)

### 4. Linux (manual — not supported by the package)

1. Register the icon as a Flutter asset in `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/icon/icon.png
   ```
2. In `linux/runner/my_application.cc`, after `gtk_window_set_default_size(...)`:
   ```cpp
   g_autofree gchar* exe_path = g_file_read_link("/proc/self/exe", nullptr);
   g_autofree gchar* exe_dir = g_path_get_dirname(exe_path);
   g_autofree gchar* icon_path = g_build_filename(
       exe_dir, "data", "flutter_assets", "assets", "icon", "icon.png", nullptr);
   gtk_window_set_icon_from_file(window, icon_path, nullptr);
   ```
3. For the dock/app menu icon (especially on Wayland), the icon comes from the `.desktop` file
   when packaging (snap / flatpak / deb): `Icon=<app-id>` + install PNG to
   `share/icons/hicolor/512x512/apps/<app-id>.png`.

### 5. Verify
```bash
flutter clean
flutter run -d windows   # check title bar + taskbar icon
flutter run -d chrome    # hard refresh (Ctrl+Shift+R) — favicon is cached aggressively
```
- Android: uninstall the old app first; launchers cache icons.
- iOS/macOS: clean build folder in Xcode if the old icon persists.

## Notes
- Use a 1024x1024 PNG, no rounded corners — each OS applies its own mask.
- `remove_alpha_ios: true` — Apple rejects icons with transparency.
- Web: the package does not change `name` / `short_name` / `description` in `web/manifest.json`
  or `<title>` in `web/index.html` — edit those by hand.
- Windows: the app name shown in the taskbar/title comes from `windows/runner/main.cpp`
  (`window.Create(L"...")`) and `windows/runner/Runner.rc` (`FileDescription`, `ProductName`).
- Commit the generated files under `android/`, `ios/`, `web/`, `windows/`, `macos/`.
