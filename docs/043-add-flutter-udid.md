# Device Identifier with flutter_udid

Uses [`flutter_udid`](https://pub.dev/packages/flutter_udid) **4.1.x** — a per-device identifier that usually
survives app reinstalls.

| Android | iOS | macOS | Windows | Linux | Web |
|:-:|:-:|:-:|:-:|:-:|:-:|
| ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |

## Steps

### 1. Add dependency
```bash
flutter pub add flutter_udid
```
No native setup (iOS/macOS store the id in the Keychain).

### 2. Read it
```dart
import 'package:flutter_udid/flutter_udid.dart';

if (!kIsWeb) {
  try {
    final deviceId = await FlutterUdid.consistentUdid;   // SHA-256 hex (64 chars) — send this
    // FlutterUdid.udid → raw platform value, don't send/store it
  } on PlatformException catch (e) {
    // UNAVAILABLE — e.g. iOS Keychain locked before the first unlock after a reboot
  }
}
```

### 3. Where it comes from
| Platform | Source | Changes when |
|---|---|---|
| Android | `Settings.Secure.ANDROID_ID` (scoped per signing key + user + device since Android 8) | factory reset, different signing key (debug vs. release!) |
| iOS | `identifierForVendor`, cached in the Keychain (this device only, not synced) | device erase, restore to a new device |
| macOS | hardware UUID, cached in the Keychain | — |
| Windows | BIOS/SMBIOS UUID (WMI) | motherboard change; can be identical on cloned VMs |
| Linux | `/etc/machine-id` | OS reinstall; can be identical on cloned images |

### 4. Good and bad uses
**Good:** "remember this device" / trusted device lists, limiting free trials per device, per-device push/session
records, fraud signals on the backend.

**Bad:**
- **Authentication** — the value can be spoofed on rooted/jailbroken devices and emulators. Combine with tokens,
  biometric unlock ([025](025-add-local-auth.md)) and server checks.
- **Advertising/cross-app tracking** — against Google Play policy for `ANDROID_ID`; on iOS it would require ATT.
- **A stable user id** — users change devices; use your account id.

### 5. Privacy
- Treat it as **personal data** (GDPR/KVKK): mention it in the privacy policy, delete it with the account.
- **App Store:** privacy nutrition label → "Device ID". **Google Play:** Data safety form → "Device or other IDs".
- Send only `consistentUdid` (hashed); for extra separation hash it again with an app-specific salt on the server.

### 6. Demo — `lib/ids/unique_ids_page.dart`
**Home → Demos → Unique IDs → Device ID**: shows `consistentUdid` with a copy button (hidden on web).

## Alternatives
- App-instance id: generate a UUID ([041](041-add-uuid.md)) on first launch and store it in
  `flutter_secure_storage` ([019](019-add-secure-storage.md)) — no device fingerprinting, resets on reinstall
  (Android) or survives in the Keychain (iOS).
- Firebase Installations id / App Set ID (Android) for analytics-style use cases.
