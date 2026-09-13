# Biometric Authentication with local_auth

Uses [`local_auth`](https://pub.dev/packages/local_auth) **3.0.x** — fingerprint / face / device credential
(PIN, pattern, password) authentication.

| Android | iOS | macOS | Windows | Linux | Web |
|:-:|:-:|:-:|:-:|:-:|:-:|
| ✅ | ✅ | ✅ | ✅ Windows Hello | ❌ | ❌ |

> `local_auth` only answers "the device owner is here". It is **not** a login by itself — use it to unlock a
> token you already stored (e.g. in `flutter_secure_storage`, [019](019-add-secure-storage.md)).

## Steps

### 1. Add dependencies
```bash
flutter pub add local_auth local_auth_android local_auth_darwin
```
`local_auth_android` / `local_auth_darwin` are only needed for the platform-specific dialog texts
(`AndroidAuthMessages`, `IOSAuthMessages`).

### 2. Platform setup
**Android** — the system `BiometricPrompt` needs a `FragmentActivity`.

`android/app/src/main/kotlin/.../MainActivity.kt`:
```kotlin
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```
With the default `FlutterActivity`, `authenticate()` throws `LocalAuthException` (`uiUnavailable`).

`LaunchTheme` must be an AppCompat theme — `android/app/src/main/res/values/styles.xml`:
```xml
<style name="LaunchTheme" parent="Theme.AppCompat.Light.NoActionBar">
```
and `values-night/styles.xml`:
```xml
<style name="LaunchTheme" parent="Theme.AppCompat.NoActionBar">
```
> `dart run flutter_native_splash:create` ([004](004-generate-native-splash.md)) rewrites these files —
> re-check the parents after running it.

The `USE_BIOMETRIC` permission is merged from the plugin manifest; nothing to add.

**iOS** — `ios/Runner/Info.plist` (required for Face ID, the app crashes without it):
```xml
<key>NSFaceIDUsageDescription</key>
<string>Unlock the app with Face ID.</string>
```

**macOS** — `macos/Runner/Info.plist`, same key (Touch ID text).

**Windows** — nothing. Uses Windows Hello; `biometricOnly: true` is not supported there.

### 3. Check what the device offers
```dart
import 'package:local_auth/local_auth.dart';

final auth = LocalAuthentication();

final bool deviceSupported = await auth.isDeviceSupported();  // biometrics OR device credential
final bool hasBiometricHardware = await auth.canCheckBiometrics;
final List<BiometricType> enrolled = await auth.getAvailableBiometrics();
// e.g. [BiometricType.strong, BiometricType.face]
```
`enrolled` empty but `deviceSupported` true → the user can still authenticate with PIN/password.

### 4. Authenticate
```dart
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

try {
  final ok = await auth.authenticate(
    localizedReason: l10n.biometricReason,          // shown in the dialog
    biometricOnly: false,                            // true = no PIN fallback (not on Windows)
    persistAcrossBackgrounding: true,                // retry when the app returns to foreground
    authMessages: [
      AndroidAuthMessages(signInTitle: l10n.biometricPromptTitle, signInHint: l10n.biometricPromptHint,
          cancelButton: l10n.cancel),
      IOSAuthMessages(cancelButton: l10n.cancel),
    ],
  );
  // ok == false → failed (wrong finger etc.)
} on LocalAuthException catch (e) {
  switch (e.code) {
    case LocalAuthExceptionCode.userCanceled:
      break;                                         // not an error
    case LocalAuthExceptionCode.noBiometricsEnrolled:
    case LocalAuthExceptionCode.noCredentialsSet:
      // offer AppSettings (009) to enrol
      break;
    case LocalAuthExceptionCode.temporaryLockout:
    case LocalAuthExceptionCode.biometricLockout:
      // too many attempts
      break;
    default:
      // show e.description
  }
}
```
3.x replaced the old `PlatformException` error codes and the `AuthenticationOptions` class with
`LocalAuthException` + named parameters.

### 5. Demo — `lib/biometric/biometric_auth_page.dart`
**Home → Demos → Biometric authentication**: shows device support, hardware and enrolled types, and has
"Authenticate" (biometrics or PIN) and "Biometrics only" buttons (the latter hidden on Windows). Unsupported
platforms (Linux, web) show a message instead.

## Notes
- Don't loop `authenticate()` on failure — the OS locks out after a few attempts.
- `stopAuthentication()` cancels an open dialog (Android/Windows).
- Test on a real device or an emulator with an enrolled fingerprint
  (Android emulator → Extended controls → Fingerprint).
- In widget tests, don't call the plugin — wrap `LocalAuthentication` behind your own interface and fake it.
