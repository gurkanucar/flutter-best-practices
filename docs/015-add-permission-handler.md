# Runtime Permissions with permission_handler

Uses [`permission_handler`](https://pub.dev/packages/permission_handler) **13.x** — check and request
camera, photos, location, notification, Bluetooth… with one API.

| Android | iOS | Windows | Web | macOS | Linux |
|:-:|:-:|:-:|:-:|:-:|:-:|
| ✅ | ✅ | ⚠️ always "granted" | ⚠️ camera, microphone, notification, location only | ❌ | ❌ |

Many plugins already ask for their own permission (`image_picker`, `flutter_local_notifications`,
`flutter_blue_plus` on Android). Use permission_handler when you need to **check first, explain, and handle
"permanently denied"** yourself.

## Steps

### 1. Add dependency
```bash
flutter pub add permission_handler
```

### 2. Android — declare every permission you request
The plugin's manifest is empty. `android/app/src/main/AndroidManifest.xml` (this project):
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>                         <!-- Permission.photos, 13+ -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
<!-- POST_NOTIFICATIONS comes from flutter_local_notifications -->
```
A permission missing from the manifest is always `denied` without a dialog.

`permission_handler_android` 14.1 is compiled with **`compileSdk = 37`** — see
[Troubleshooting](#troubleshooting) if your Android build complains.

### 3. iOS — Info.plist keys + enable the permissions in native code
Every requested permission needs a usage string in `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>Take a photo to compress and preview it.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Pick a photo to compress and preview it.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Show how location permission requests work.</string>
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Scan for and connect to nearby Bluetooth LE devices.</string>
```
Unused permissions are compiled out (App Store rejects apps referencing APIs without usage strings). How you
enable them depends on the iOS dependency manager:

**Swift Package Manager** (default for new Flutter projects): permissions are enabled automatically from the
Info.plist keys above. `notification` is on by default. After changing keys:
`rm -rf ~/Library/Developer/Xcode/DerivedData` and rebuild. Building from Xcode.app may not find the plist →
`launchctl setenv PERMISSION_HANDLER_INFO_PLIST /absolute/path/ios/Runner/Info.plist`.

**CocoaPods** (`ios/Podfile` exists): add macros in `post_install`:
```ruby
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
        '$(inherited)',
        'PERMISSION_CAMERA=1',
        'PERMISSION_PHOTOS=1',
        'PERMISSION_NOTIFICATIONS=1',
        'PERMISSION_LOCATION_WHENINUSE=1',
        'PERMISSION_BLUETOOTH=1',
      ]
    end
  end
end
```
Without it every check returns `denied` and no dialog appears.

### 4. API
```dart
import 'package:permission_handler/permission_handler.dart';

final status = await Permission.camera.status;          // check, no dialog
if (status.isGranted) { /* use camera */ }

final result = await Permission.camera.request();       // shows the OS dialog (if allowed)
if (result.isPermanentlyDenied) {
  await openAppSettings();                              // only way out
}

final statuses = await [Permission.camera, Permission.photos].request();   // Map<Permission, PermissionStatus>

await Permission.locationWhenInUse.shouldShowRequestRationale;           // Android: explain first?
await Permission.location.serviceStatus;                                  // GPS on/off
```

| Status | Meaning |
|---|---|
| `granted` | OK |
| `denied` | Not granted yet / user said no; you may ask again |
| `permanentlyDenied` | "Don't ask again" (Android) / denied once (iOS) — dialog won't show, open settings |
| `restricted` | iOS: blocked by parental controls / MDM |
| `limited` | iOS: selected photos only |
| `provisional` | iOS: provisional (quiet) notifications |

Android 13.0.2+ behavior: **`status` never returns `permanentlyDenied`** — only `request()` does, and it returns
immediately without a dialog.

Which permission to use:
- Photos: `Permission.photos` (Android 13+ = `READ_MEDIA_IMAGES`); `Permission.storage` is always denied on 13+.
- Bluetooth on Android 12+: `bluetoothScan`, `bluetoothConnect`. `Permission.bluetooth` is iOS.
- Notification: `Permission.notification` (Android 13+ dialog; below it just reports the setting).

### 5. Demo — `lib/permissions/permissions_page.dart`
**Home → Demos → Permissions**: status per permission, "Request" button, settings shortcut, refresh on resume:
```dart
@override
void initState() {
  super.initState();
  _lifecycle = AppLifecycleListener(onResume: _refresh);   // back from system settings
  _refresh();
}

Future<void> _request(Permission permission) async {
  final status = await permission.request();
  setState(() => _statuses[permission] = status);
  if (status.isPermanentlyDenied) {
    messenger.showSnackBar(SnackBar(
      content: Text(l10n.permissionStatusPermanentlyDenied),
      action: SnackBarAction(label: l10n.openSettings, onPressed: openAppSettings),
    ));
  }
}
```
Platform list:
```dart
static List<Permission> get permissions => [
  Permission.camera,
  if (!kIsWeb) Permission.photos,
  Permission.notification,
  kIsWeb ? Permission.location : Permission.locationWhenInUse,
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) ...[
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
  ],
];
```

## Good practice
1. Ask **in context** (when the user taps "Take photo"), not all at app start.
2. Explain before the OS dialog if `shouldShowRequestRationale` is true — you get one or two chances.
3. Handle every status; never assume `granted`.
4. Re-check on resume; the user can revoke permissions any time.

## Name clash with app_settings
Both packages have "open app settings": permission_handler exports a top-level `openAppSettings()`,
app_settings uses `AppSettings.openAppSettings()` (static) — no conflict. If another package exports a top-level
`openAppSettings`, use `import 'package:permission_handler/permission_handler.dart' hide openAppSettings;`
or an import prefix.

## Platform notes
- **Windows:** `status`/`request` always return `granted` (only `serviceStatus` for location/Bluetooth is real).
  `openAppSettings` isn't implemented there (throws `MissingPluginException`) — hide the button.
- **Web:** other permissions throw `UnsupportedError`/`UnimplementedError`; `openAppSettings` returns `false`.
- **macOS / Linux:** no implementation → guard with a platform check (`PermissionsPage.isSupported`).

## Troubleshooting
| Problem | Fix |
|---|---|
| Always `denied`, no dialog (Android) | Permission missing from `AndroidManifest.xml` |
| Always `denied`, no dialog (iOS) | Info.plist key missing, or Podfile macros missing (CocoaPods) / stale DerivedData (SwiftPM) |
| `Dependency 'permission_handler_android' requires compileSdk 37` / "compileSdk of at least 37" | Install **Android SDK Platform 37** (Android Studio → SDK Manager) and set `compileSdk = 37` in `android/app/build.gradle.kts` |
| `MissingPluginException` on macOS/Linux | Not supported — guard by platform |
| Photos denied on Android 13+ | Use `Permission.photos` + `READ_MEDIA_IMAGES`, not `storage` |
