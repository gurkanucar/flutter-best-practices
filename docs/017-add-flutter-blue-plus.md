# Bluetooth LE with flutter_blue_plus

Uses [`flutter_blue_plus`](https://pub.dev/packages/flutter_blue_plus) **2.3.x** — scan, connect and talk to
Bluetooth **Low Energy** devices (not Bluetooth Classic).

| Android | iOS | macOS | Windows | Linux | Web |
|:-:|:-:|:-:|:-:|:-:|:-:|
| ✅ | ✅ | ✅ | ✅ (via `flutter_blue_plus_winrt`) | ✅ | ⚠️ Chrome/Edge, limited |

## ⚠️ License — read before using

flutter_blue_plus is **not** BSD/MIT anymore. It uses the **FlutterBluePlus License v1.5**:

| Who | Terms |
|---|---|
| Personal use, registered nonprofits, accredited education | Free |
| **Any for-profit company** (incl. individuals doing commercial work) | **Paid commercial license required** — also for development, testing and evaluation |

- Price tiers by employee count (Starter 0–9 … Corporate 250+), perpetual, one license per organization.
- **Build-time telemetry (Android):** a Gradle task sends package name, app name, app version, plugin version,
  date and signing SHA-256 to the author's server before each build. There is **no opt-out** switch; failures
  don't break the build.
- `connect()` requires a `license:` argument.

This project uses it for learning with `License.nonprofit`:
```dart
/// Personal / nonprofit / education → License.nonprofit.
/// For-profit company (incl. development) → buy a license and use License.commercial.
const fbpLicense = License.nonprofit;
```

**Free alternatives (BSD-3):** [`universal_ble`](https://pub.dev/packages/universal_ble) (all platforms),
[`flutter_reactive_ble`](https://pub.dev/packages/flutter_reactive_ble) (Android/iOS).

## Steps

### 1. Add dependency
```bash
flutter pub add "flutter_blue_plus:^2.3.12"
```

### 2. Android — `AndroidManifest.xml`
```xml
<uses-feature android:name="android.hardware.bluetooth_le" android:required="false"/>
<uses-permission android:name="android.permission.BLUETOOTH_SCAN" android:usesPermissionFlags="neverForLocation"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30"/>
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30"/>
<!-- Android ≤ 11 needs location for BLE scans. This project already declares ACCESS_FINE_LOCATION for the
     permission demo; otherwise use android:maxSdkVersion="30". -->
```
- The plugin **requests `BLUETOOTH_SCAN`/`BLUETOOTH_CONNECT` itself** on Android 12+.
- Need location from BLE (beacons)? Remove `neverForLocation`, declare `ACCESS_FINE_LOCATION` and pass
  `startScan(androidUsesFineLocation: true)`.
- R8/ProGuard (release): `-keep class com.jmx.flutter_blue_plus.* { *; }` (package renamed in 2.3.9 —
  older docs say `com.lib.flutter_blue_plus`).

### 3. iOS / macOS
`ios/Runner/Info.plist`:
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Scan for and connect to nearby Bluetooth LE devices.</string>
```
Background: `UIBackgroundModes` → `bluetooth-central`.

`macos/Runner/DebugProfile.entitlements` + `Release.entitlements`:
```xml
<key>com.apple.security.device.bluetooth</key>
<true/>
```

### 4. API
```dart
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

if (!await FlutterBluePlus.isSupported) return;           // no BLE hardware / browser support

// adapter (not on web)
FlutterBluePlus.adapterState.listen((state) {});          // on, off, unauthorized, ...
if (Platform.isAndroid) await FlutterBluePlus.turnOn();

// scan
await FlutterBluePlus.startScan(
  timeout: const Duration(seconds: 10),
  withServices: [Guid('180D')],                           // filter (required for background scans on iOS)
);
FlutterBluePlus.scanResults.listen((results) {
  for (final r in results) {
    r.device.remoteId;  r.advertisementData.advName;  r.rssi;  r.advertisementData.connectable;
  }
});
FlutterBluePlus.isScanning.listen((scanning) {});
await FlutterBluePlus.stopScan();

// connect
final device = results.first.device;
await device.connect(license: License.nonprofit, timeout: const Duration(seconds: 15));
device.connectionState.listen((state) {});
final services = await device.discoverServices();
final characteristic = services.first.characteristics.first;
final value = await characteristic.read();                           // List<int>
await characteristic.write([0x01]);
await characteristic.setNotifyValue(true);
final subscription = characteristic.onValueReceived.listen((value) {});
device.cancelWhenDisconnected(subscription);                          // auto-cancel
await device.disconnect();
```

### 5. Demo — `lib/bluetooth/bluetooth_page.dart`
**Home → Demos → Bluetooth LE**: adapter state + "Turn on" (Android), 10 s scan with RSSI-sorted results,
connect → discover services → disconnect, license note.
```dart
StreamBuilder<List<ScanResult>>(
  stream: FlutterBluePlus.scanResults,
  initialData: const [],
  builder: (context, snapshot) {
    final results = [...?snapshot.data]..sort((a, b) => b.rssi.compareTo(a.rssi));
    return ListView(children: [for (final r in results) _DeviceTile(result: r, ...)]);
  },
)

Future<void> _connect(BluetoothDevice device) async {
  await device.connect(license: fbpLicense, timeout: const Duration(seconds: 15));
  final services = await device.discoverServices();
  setState(() => _serviceCounts[device.remoteId] = services.length);
}
```

## Platform notes
- **Web:** `startScan` opens the browser's device chooser (must be a user gesture). Not available:
  `adapterState`, `stopScan`, `turnOn`, `advName`, `mtu`, `readRssi`, bonding. Pass `webOptionalServices` to access
  services you didn't filter on.
- **iOS:** `remoteId` is a random per-app UUID, not the MAC address. No `turnOn`.
- **Android:** `requestMtu` (default 512 on connect), `autoConnect` requires `mtu: null`.
- **Windows:** implemented by a third-party package (`flutter_blue_plus_winrt`); test your device there.
- Real hardware is needed — emulators/simulators have no BLE.

## Troubleshooting
| Problem | Fix |
|---|---|
| `connect()` doesn't compile | Pass `license:` (2.x) |
| `adapterState` stays `unauthorized` (Android) | Permission denied — open app settings ([009](009-add-app-settings.md)) |
| No scan results on Android ≤ 11 | Location permission + location services on |
| Nothing found in background (iOS) | Scans need `withServices` filter in background |
| Release build crashes (Android) | ProGuard keep rule for `com.jmx.flutter_blue_plus` |
