# Run the App

## 1. List devices
```bash
flutter devices
```
Example output on this machine:
```
SM A165F (mobile) • R68Y1018SPH • android-arm64  • Android 14 (API 34)
Windows (desktop) • windows     • windows-x64    • Microsoft Windows
Chrome (web)      • chrome      • web-javascript • Google Chrome
Edge (web)        • edge        • web-javascript • Microsoft Edge
```
Columns: **name** • **id** • platform • OS.

## 2. Pick a device with `-d`

`-d` matches a device **id** or the start of its **name** — not a platform name.

```bash
flutter run -d windows        # id "windows"
flutter run -d chrome         # id "chrome"
flutter run -d R68Y1018SPH    # Android phone by id
flutter run -d "SM A165F"     # same phone by name
flutter run -d all            # every connected device at once
flutter run                   # only one device connected → used automatically; otherwise asks
```
- ❌ `flutter run -d android` → `No supported devices found with name or id matching 'android'`.
  Use the id from `flutter devices` instead.

## 3. Per platform

| Platform | Command | Host OS | Requirements |
|---|---|---|---|
| Windows | `flutter run -d windows` | Windows | Visual Studio / Build Tools with **Desktop development with C++**; **C++ ATL** for `flutter_local_notifications` ([006](006-add-local-notifications.md#windows-install-c-atl-required-to-build)) |
| Web | `flutter run -d chrome` / `-d edge` | any | Chrome or Edge installed |
| Android | `flutter run -d <device-id>` | any | Android SDK + licenses, USB debugging on the phone |
| macOS | `flutter run -d macos` | **macOS only** | Xcode, CocoaPods |
| iOS | `flutter run -d <simulator-or-iphone-id>` | **macOS only** | Xcode, CocoaPods; signing team for real devices |
| Linux | `flutter run -d linux` | **Linux only** | `clang cmake ninja-build pkg-config libgtk-3-dev` |

Check what's missing on the current machine with `flutter doctor -v`.

### Windows
```bash
flutter run -d windows
```
- Closing the app window ends the session → `Lost connection to device.` (normal, not a crash).
- Build errors from native plugins (e.g. `atlbase.h`) mean a Visual Studio component is missing.

### Web
```bash
flutter run -d chrome
flutter run -d web-server --web-port 8080   # no browser launched; open http://localhost:8080 in any browser
```
- Hot reload works; after changing `web/index.html`, `web/manifest.json` or icons do a full restart
  and a hard refresh (`Ctrl+Shift+R`).
- Notification permission prompt only appears after clicking a button.

### Android (real device over USB)
1. On the phone: **Settings → About phone → Software information → tap "Build number" 7×**
   (Samsung path; other brands: *About phone → Build number*) → Developer options enabled.
2. **Settings → Developer options → USB debugging** → on.
3. Connect the cable, unlock the phone, accept **"Allow USB debugging?"** (tick *Always allow*).
4. Check:
   ```bash
   flutter devices          # phone listed with its id
   adb devices              # "device" = OK, "unauthorized" = accept the prompt on the phone
   ```
5. Run:
   ```bash
   flutter run -d R68Y1018SPH
   ```
- First build takes a few minutes (Gradle downloads). Later builds are faster.
- Cable/port set to "charging only"? Switch USB mode to **File transfer** if the phone doesn't show up.
- **Wireless (Android 11+):** Developer options → *Wireless debugging* → *Pair device with pairing code*, then
  ```bash
  adb pair <ip>:<pair-port>     # enter the 6-digit code
  adb connect <ip>:<port>
  flutter devices
  ```
- **Emulator:**
  ```bash
  flutter emulators                     # list
  flutter emulators --launch <id>       # start, then flutter run -d emulator-5554
  ```

### iOS (Mac only)
```bash
open -a Simulator
flutter run -d "iPhone 16"            # simulator by name
```
Real iPhone:
1. Open `ios/Runner.xcworkspace` in Xcode → *Runner* target → *Signing & Capabilities* → select your **Team**.
2. iPhone: *Settings → Privacy & Security → Developer Mode* → on (restart required).
3. Connect, trust the computer, then `flutter run -d <iphone-id>`.
4. First launch: *Settings → General → VPN & Device Management* → trust the developer certificate.

### macOS (Mac only)
```bash
flutter run -d macos
```
- Network access, notifications etc. may need entitlements in `macos/Runner/*.entitlements`.

## 4. Build modes

| Mode | Command | Use for |
|---|---|---|
| Debug (default) | `flutter run` | Development — hot reload, asserts, slower |
| Profile | `flutter run --profile` | Performance measuring with DevTools (real devices only, not emulators/simulators) |
| Release | `flutter run --release` | Real-world speed/size check — no hot reload, no debugging |

## 5. While running

| Key | Action |
|---|---|
| `r` | Hot reload — keeps state, applies UI/logic changes |
| `R` | Hot restart — resets state, re-runs `main()` |
| `q` | Quit and stop the app |
| `d` | Detach — stop `flutter run`, keep the app running |
| `h` | All commands |

- Hot reload works for Dart code and ARB text changes (localizations are regenerated automatically).
- **Stop (`q`) and run again** after changing `pubspec.yaml` dependencies, `l10n.yaml`,
  or native files (`android/`, `ios/`, `windows/`, `macos/`, `web/index.html`).
- App icon / native splash changes need a full rebuild, and on mobile often an uninstall first
  (see [003](003-generate-app-icons.md), [004](004-generate-native-splash.md)).

## Troubleshooting
| Problem | Fix |
|---|---|
| `No supported devices found with name or id matching 'android'` | `-d` takes a device id/name from `flutter devices`, not a platform |
| `Lost connection to device.` | App window closed / app killed. If it happens immediately on start, check the log above it for an exception |
| Android phone not in `flutter devices` | USB debugging off, prompt not accepted, charging-only cable/mode — check `adb devices` |
| `adb devices` shows `unauthorized` | Unlock phone, accept the RSA prompt; if missing: Developer options → *Revoke USB debugging authorizations*, reconnect |
| `Android license status unknown` | `flutter doctor --android-licenses` |
| `cmdline-tools component is missing` | Android Studio → SDK Manager → SDK Tools → *Android SDK Command-line Tools* |
| Android: `this and base files have different roots` | `kotlin.incremental=false` in `android/gradle.properties` ([006](006-add-local-notifications.md)) |
| Windows: `Cannot open include file: 'atlbase.h'` | Install C++ ATL ([006](006-add-local-notifications.md#windows-install-c-atl-required-to-build)) |
| iOS: `No valid code signing certificates` | Select a Team in Xcode → Signing & Capabilities |
| Several devices, wrong one picked | Always pass `-d <id>` |
