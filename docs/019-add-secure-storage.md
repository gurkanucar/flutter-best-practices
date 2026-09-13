# Secure Storage (tokens, secrets)

Uses [`flutter_secure_storage`](https://pub.dev/packages/flutter_secure_storage) **11.x** — key/value strings
encrypted by the platform's secure store.

| Platform | Backend |
|---|---|
| Android | Android Keystore (RSA-OAEP key) + AES-GCM encrypted SharedPreferences |
| iOS / macOS | Keychain |
| Windows | DPAPI |
| Linux | libsecret (GNOME Keyring / KWallet) |
| Web | WebCrypto + localStorage — **experimental, not truly secure** |

Use it for **small secrets**: auth/refresh tokens, API keys, encryption keys (e.g. for Hive, see
[021](021-add-hive.md)). Not for large data or anything you query.

## Steps

### 1. Add dependency
```bash
flutter pub add flutter_secure_storage
```

### 2. Platform setup

**Android**
- `minSdk` 24 (v11). Flutter's default is 24 — nothing to change.
- **Backups:** Auto Backup restores the encrypted prefs on a new device, but the Keystore key doesn't move →
  `InvalidKeyException: Failed to unwrap key`. Either disable backup or exclude the storage:
  ```xml
  <application android:allowBackup="false" ...>
  ```
- Biometrics (`AndroidOptions.biometric()`): add `<uses-permission android:name="android.permission.USE_BIOMETRIC"/>`.

**iOS** — nothing. Choose accessibility if you read in the background:
```dart
const IOSOptions(accessibility: KeychainAccessibility.first_unlock)
```

**macOS** — add to `macos/Runner/DebugProfile.entitlements` **and** `Release.entitlements`:
```xml
<key>keychain-access-groups</key>
<array/>
```
With App Groups use `$(AppIdentifierPrefix)your.group`; a wrong group makes writes fail silently.

**Windows** — needs the Visual Studio **C++ ATL** component (same as [006](006-add-local-notifications.md#windows-install-c-atl-required-to-build)).

**Linux** — `sudo apt install libsecret-1-dev libsecret-1-0` and a running, unlocked keyring.
Headless CI:
```bash
eval $(dbus-launch --sh-syntax)
echo "" | gnome-keyring-daemon --unlock --daemonize --components=secrets
```

**Web** — HTTPS or `localhost` only. Anything in a browser can be read by injected scripts;
prefer HttpOnly cookies for web auth.

### 3. API
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();

await storage.write(key: 'auth_token', value: token);   // value: null deletes
final token = await storage.read(key: 'auth_token');     // String?
await storage.containsKey(key: 'auth_token');
await storage.delete(key: 'auth_token');
final all = await storage.readAll();                     // Map<String, String>
await storage.deleteAll();
```
Everything is a `String` — `jsonEncode` objects if needed. All calls are async and can throw
`PlatformException` (locked keyring, corrupted key) — catch at startup.

### 4. In this project — `lib/auth/auth_controller.dart`
The demo login token lives in secure storage, so the user stays signed in after restart:
```dart
class AuthController extends ChangeNotifier {
  AuthController({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _tokenKey = 'auth_token';
  static const _userNameKey = 'auth_user_name';

  final FlutterSecureStorage _storage;
  String? _userName;

  bool get isLoggedIn => _userName != null;

  Future<void> restore() async {                     // called in main() before runApp
    final token = await _storage.read(key: _tokenKey);
    _userName = token == null ? null : await _storage.read(key: _userNameKey);
    notifyListeners();
  }

  Future<void> login(String userName) async {
    await _storage.write(key: _tokenKey, value: 'token-from-backend');
    await _storage.write(key: _userNameKey, value: userName);
    _userName = userName;
    notifyListeners();                               // go_router re-runs redirect
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userNameKey);
    _userName = null;
    notifyListeners();
  }
}
```
`main.dart` wraps `restore()` in `try/catch` so a locked Linux keyring doesn't crash startup.
Routing/redirect details: [020](020-add-go-router.md).

## Options (v11)
```dart
const storage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    // defaults: RSA_ECB_OAEPwithSHA_256andMGF1Padding + AES_GCM_NoPadding
    resetOnError: true,          // wipe on unrecoverable key errors instead of throwing forever
    storageNamespace: 'auth',    // replaces sharedPreferencesName
  ),
  iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
  webOptions: WebOptions(dbName: 'app_secure', publicKey: 'app'),
);
```
**v11 breaking changes:** `encryptedSharedPreferences`, `sharedPreferencesName`, `RSA_ECB_PKCS1Padding` and
`AES_CBC_PKCS7Padding` were removed. Apps still on v9 data must upgrade to **v10 first** (it migrates),
then to v11 — otherwise old values can't be read.

## Listening
```dart
storage.registerListener(key: 'auth_token', listener: (value) => debugPrint('token changed: $value'));
storage.unregisterAllListeners();
```

## Testing
```dart
FlutterSecureStorage.setMockInitialValues({'auth_token': 'test-token', 'auth_user_name': 'Ada'});
final auth = AuthController();
await auth.restore();
expect(auth.isLoggedIn, isTrue);
```
Used in `test/router_test.dart` and `test/l10n_test.dart`.

## Notes
- iOS Keychain items **survive app uninstall** — clear them on first launch if that matters
  (store a "first run" flag in normal storage and `deleteAll()` when it's missing).
- Don't keep secrets in `SharedPreferences`, Hive or Drift without encryption.
- Secure storage protects data at rest on the device; it doesn't protect against a compromised/rooted device.
