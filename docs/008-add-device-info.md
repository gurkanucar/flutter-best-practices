# Add Device Info

Uses [`device_info_plus`](https://pub.dev/packages/device_info_plus) **13.x** — model, OS version,
emulator vs real device, browser info.

| Android | iOS | macOS | Web | Linux | Windows |
|:-:|:-:|:-:|:-:|:-:|:-:|
| ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

## Steps

### 1. Add dependency
```bash
flutter pub add device_info_plus
```
No native setup. Requirements (already met by this project): Flutter ≥ 3.38.1, Java 17,
AGP ≥ 8.12.1, Kotlin 2.2+, iOS ≥ 13, macOS ≥ 10.15.

### 2. Platform getters
```dart
final plugin = DeviceInfoPlugin();

final android = await plugin.androidInfo;     // AndroidDeviceInfo
final ios = await plugin.iosInfo;             // IosDeviceInfo
final macOs = await plugin.macOsInfo;         // MacOsDeviceInfo
final windows = await plugin.windowsInfo;     // WindowsDeviceInfo
final linux = await plugin.linuxInfo;         // LinuxDeviceInfo
final web = await plugin.webBrowserInfo;      // WebBrowserInfo
final any = await plugin.deviceInfo;          // BaseDeviceInfo for the current platform
```
Only call the getter for the platform you're on — others throw.

Useful fields:

| Platform | Fields |
|---|---|
| Android | `manufacturer`, `model`, `brand`, `version.release` ("14"), `version.sdkInt` (34), `isPhysicalDevice` |
| iOS | `modelName` ("iPhone 16"), `utsname.machine` ("iPhone17,3"), `systemName`, `systemVersion`, `isPhysicalDevice`, `isiOSAppOnMac` |
| macOS | `modelName`, `model`, `osRelease`, `arch`, `memorySize`, `computerName` |
| Windows | `productName`, `displayVersion` ("24H2"), `buildNumber`, `computerName`, `numberOfCores`, `systemMemoryInMegabytes` |
| Linux | `name`, `prettyName` ("Ubuntu 24.04 LTS"), `version` |
| Web | `browserName` (enum), `userAgent`, `platform` |

### 3. Service — `lib/device_info/device_info_service.dart`

Maps every platform to one `DeviceSummary` model (Equatable, see [011](011-add-equatable.md)):
```dart
Future<DeviceSummary> summary() async {
  if (kIsWeb) {                                   // check web first: defaultTargetPlatform
    final web = await _plugin.webBrowserInfo;     // reports the host OS inside a browser
    return DeviceSummary(platform: 'Web', model: web.browserName.name, osVersion: web.platform ?? '-');
  }

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      final android = await _plugin.androidInfo;
      return DeviceSummary(
        platform: 'Android',
        model: '${android.manufacturer} ${android.model}',
        osVersion: 'Android ${android.version.release} (API ${android.version.sdkInt})',
        isPhysicalDevice: android.isPhysicalDevice,
      );
    case TargetPlatform.iOS:
      final ios = await _plugin.iosInfo;
      return DeviceSummary(
        platform: 'iOS',
        model: ios.modelName,
        osVersion: '${ios.systemName} ${ios.systemVersion}',
        isPhysicalDevice: ios.isPhysicalDevice,
      );
    case TargetPlatform.windows:
      final windows = await _plugin.windowsInfo;
      return DeviceSummary(
        platform: 'Windows',
        model: windows.computerName,
        osVersion: '${windows.productName} ${windows.displayVersion} (build ${windows.buildNumber})',
      );
    // macOS, linux ... see the file
  }
}

/// Everything the plugin knows (debugging / crash reports). Not JSON-safe.
Future<Map<String, dynamic>> rawData() async => (await _plugin.deviceInfo).data;
```

### 4. Page — `lib/device_info/device_info_page.dart`
`FutureBuilder` → summary list + expandable "All data" list. Opened from **Home → Demos → Device info**.

Create the `Future` once (`late final _future = _load();`), never inside `build` —
otherwise every rebuild starts a new platform call.

## Common uses
- Send `model` + OS version with bug reports / analytics.
- Feature gates by OS version:
  ```dart
  final android = await DeviceInfoPlugin().androidInfo;
  if (android.version.sdkInt >= 33) { /* Android 13+: runtime notification permission */ }
  ```
- Hide debug-only features on emulators: `isPhysicalDevice == false`.

## Notes
- **Android serial number** (`serialNumber`) returns `unknown` unless the app meets Android's
  [privileged requirements](https://developer.android.com/reference/android/os/Build#getSerial()) — don't use it as an ID.
- **iOS `name`** (user-assigned device name) needs the
  `com.apple.developer.device-information.user-assigned-device-name` entitlement on iOS 16+,
  otherwise it's just "iPhone"/"iPad".
- **Windows 11** is detected by `buildNumber >= 22000`; don't parse `productName`.
- **Web** can't see the real device model — only the browser/user agent.
- There is **no stable unique device ID** in this plugin (by design, for privacy).
  Generate your own UUID and store it if you need an install ID.
- Results are cached per `DeviceInfoPlugin` instance.
- Widget tests have no platform channel → don't call the plugin in widget tests; test mapping logic
  or the `DeviceSummary` model instead (`test/equatable_test.dart`).
