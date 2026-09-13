# Open System Settings (app_settings)

Uses [`app_settings`](https://pub.dev/packages/app_settings) **9.x** — jump from the app to
system settings screens (app info, notifications, Wi-Fi, location, exact alarms…).

| Android | iOS | macOS | Windows | Linux | Web |
|:-:|:-:|:-:|:-:|:-:|:-:|
| ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |

On unsupported platforms the call throws (no implementation) → guard it (see below).

## Steps

### 1. Add dependency
```bash
flutter pub add app_settings
```
- **Android:** no setup.
- **iOS (CocoaPods + Objective-C projects only):** add `use_frameworks!` in `ios/Podfile` under `target 'Runner'`.
  Swift projects (like this one) and Swift Package Manager need nothing.

### 2. Open a settings screen
```dart
import 'package:app_settings/app_settings.dart';

AppSettings.openAppSettings();                                  // this app's settings page
AppSettings.openAppSettings(type: AppSettingsType.notification);
AppSettings.openAppSettings(type: AppSettingsType.wifi);
AppSettings.openAppSettings(type: AppSettingsType.location, asAnotherTask: true); // Android: separate task
```
If a `type` isn't available on the current platform/OS version, **the general app settings open instead**.

Useful `AppSettingsType` values:

| Type | Opens | Typical reason |
|---|---|---|
| `settings` (default) | App info / app settings | Permission permanently denied |
| `notification` | App notification settings | User denied notification permission |
| `alarm` | Alarms & reminders (Android 12+) | Exact alarms for [006](006-add-local-notifications.md) |
| `appLocale` | Per-app language (Android 13+) | Language set in [005](005-add-localization.md) |
| `location` | Location services | GPS off |
| `wifi`, `bluetooth` | Wi-Fi / Bluetooth | Offline, device pairing |
| `batteryOptimization` | Battery optimization | Background work killed |

All values: `accessibility, alarm, apn, appLocale, batteryOptimization, bluetooth, camera, dataRoaming, date,
developer, device, display, generalSettings, hotspot, internalStorage, location, lockAndPassword,
manageUnknownAppSources, nfc, notification, security, settings, sound, subscriptions, vpn, wifi, wireless`.

### 3. Android settings panels (Android 10+)
A bottom sheet over the app instead of leaving it:
```dart
AppSettings.openAppSettingsPanel(AppSettingsPanelType.internetConnectivity);
AppSettings.openAppSettingsPanel(AppSettingsPanelType.wifi);
AppSettings.openAppSettingsPanel(AppSettingsPanelType.volume);
AppSettings.openAppSettingsPanel(AppSettingsPanelType.nfc);
```
Android only; does nothing on Android 9 and lower.

### 4. Guard unsupported platforms
```dart
static bool get isSupported =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS);

static bool get supportsPanels => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
```
Disable the buttons (or hide them) when `false`.

## In this project
- **Home → Demos → System settings** (`lib/app_settings/app_settings_page.dart`): one tile per common type,
  plus Android panels.
- **Notification permission denied** (`notification_demo_section.dart`): the snackbar has a **Settings**
  action that opens `AppSettingsType.notification`:
  ```dart
  messenger.showSnackBar(
    SnackBar(
      content: Text(l10n.notificationPermissionDenied),
      action: AppSettingsPage.isSupported
          ? SnackBarAction(
              label: l10n.openSettings,
              onPressed: () => AppSettings.openAppSettings(type: AppSettingsType.notification),
            )
          : null,
    ),
  );
  ```
- **Connectivity page:** "Wi-Fi settings" button ([010](010-add-connectivity.md)).

## Notes
- Once a user denies a runtime permission twice (Android) or once (iOS), the OS won't ask again —
  opening settings is the only way. Explain *why* before sending users there.
- iOS only has one settings page per app; most types end up there.
- You can't detect what the user changed — re-check permissions when the app resumes
  (`AppLifecycleListener(onResume: ...)`).
