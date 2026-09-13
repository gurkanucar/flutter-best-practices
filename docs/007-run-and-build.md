# Run and Build

- [1. Devices](#1-devices)
- [2. Run](#2-run)
- [3. Environments (dev / staging / prod)](#3-environments-dev--staging--prod)
- [4. Build](#4-build)
- [5. Versioning](#5-versioning)
- [6. Release signing](#6-release-signing)
- [7. Obfuscation and symbols](#7-obfuscation-and-symbols)
- [8. Project scripts in pubspec.yaml](#8-project-scripts-in-pubspecyaml)
- [9. CI example](#9-ci-example)
- [Troubleshooting](#troubleshooting)

**TL;DR** — everything below is available as short commands from `pubspec.yaml` ([8](#8-project-scripts-in-pubspecyaml)):
```bash
dart run rps ls                       # list commands
dart run rps start dev -d windows       # run with env/dev.json
dart run rps build apk staging        # codegen + l10n + build with env/staging.json
dart run rps check                    # codegen + analyze + test
```

---

## 1. Devices
```bash
flutter devices
```
```
SM A165F (mobile) • R68Y1018SPH • android-arm64  • Android 14 (API 34)
Windows (desktop) • windows     • windows-x64    • Microsoft Windows
Chrome (web)      • chrome      • web-javascript • Google Chrome
Edge (web)        • edge        • web-javascript • Microsoft Edge
```
Columns: **name** • **id** • platform • OS.

`-d` matches a device **id** or the start of its **name** — not a platform:
```bash
flutter run -d windows        # id
flutter run -d R68Y1018SPH    # Android phone by id
flutter run -d "SM A165F"     # same phone by name
flutter run -d all            # every connected device
```
❌ `flutter run -d android` → `No supported devices found with name or id matching 'android'`.

## 2. Run

Always pass an environment file (see [3](#3-environments-dev--staging--prod)):
```bash
flutter run -d windows --dart-define-from-file=env/dev.json
dart run rps start dev -d windows          # same, via pubspec script
```

| Platform | Command | Host OS | Requirements |
|---|---|---|---|
| Windows | `-d windows` | Windows | VS Build Tools "Desktop development with C++" + **C++ ATL** ([006](006-add-local-notifications.md#windows-install-c-atl-required-to-build)), **Developer Mode** for pdfrx ([016](016-add-pdfrx.md)) |
| Web | `-d chrome` / `-d edge` | any | Chrome or Edge |
| Android | `-d <device-id>` | any | Android SDK (Platform 37) + licenses, USB debugging |
| macOS | `-d macos` | macOS | Xcode |
| iOS | `-d <simulator-or-iphone>` | macOS | Xcode; signing team for real devices |
| Linux | `-d linux` | Linux | `clang cmake ninja-build pkg-config libgtk-3-dev libsecret-1-dev` |

`flutter doctor -v` shows what's missing.

### Windows
- Closing the window ends the session → `Lost connection to device.` (normal).
- Build Windows and Android **one at a time** — parallel builds lock files.

### Web
```bash
dart run rps start dev -d chrome
flutter run -d web-server --web-port 8080 --dart-define-from-file=env/dev.json   # open http://localhost:8080
```
Hard refresh (`Ctrl+Shift+R`) after changing `web/index.html`, icons or manifest.

### Android (USB)
1. Phone: **Settings → About phone → Software information → tap "Build number" 7×** (Samsung).
2. **Developer options → USB debugging** → on.
3. Connect, unlock, accept **"Allow USB debugging?"**.
4. `adb devices` → `device` (not `unauthorized`), then `dart run rps start dev -d <id>`.

Wireless (Android 11+): *Developer options → Wireless debugging → Pair with code* → `adb pair <ip>:<port>`,
`adb connect <ip>:<port>`. Emulator: `flutter emulators --launch <id>`.

### iOS (Mac)
`open -a Simulator` → `dart run rps start dev -d "iPhone 16"`. Real device: Xcode → *Runner → Signing & Capabilities →
Team*, iPhone *Settings → Privacy & Security → Developer Mode*, trust the certificate after first install.

### Modes and keys

| Mode | Command | Use |
|---|---|---|
| Debug (default) | `flutter run` | Hot reload, asserts |
| Profile | `flutter run --profile` | Performance with DevTools (real devices only) |
| Release | `flutter run --release` | Real speed/size, no debugging |

| Key | Action |
|---|---|
| `r` | Hot reload (keeps state) |
| `R` | Hot restart (re-runs `main`) |
| `q` | Quit |
| `d` | Detach (app keeps running) |

Stop and run again after changing `pubspec.yaml`, `l10n.yaml`, native files, **env files** or Hive/Drift models
(`dart run rps gen` regenerates code + localizations).

---

## 3. Environments (dev / staging / prod)

Configuration is injected at **build time** with `--dart-define-from-file` and read with `const fromEnvironment`.
One codebase, no code changes between environments.

### Files — `env/`

| File | Committed | Content |
|---|---|---|
| `env/dev.json` | ✅ | dev API, logging on |
| `env/staging.json` | ✅ | staging API |
| `env/prod.example.json` | ✅ | template for prod |
| `env/prod.json` | ❌ `.gitignore` | real prod values — copy the example locally or create it in CI |
| `env/*.local.json` | ❌ `.gitignore` | personal overrides |

```json
{
  "APP_FLAVOR": "staging",
  "API_BASE_URL": "https://staging.api.example.com",
  "ENABLE_LOGGING": "true",
  "SENTRY_DSN": ""
}
```
`.env` files work too (`--dart-define-from-file=env/dev.env`, `KEY=value` lines). Several files can be passed;
`--dart-define=KEY=value` **overrides** the same key from a file.

### Read the values — `lib/config/app_environment.dart`
```dart
enum AppFlavor { dev, staging, prod }

abstract final class AppEnvironment {
  static const flavorName = String.fromEnvironment('APP_FLAVOR', defaultValue: 'dev');
  static const apiBaseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'https://dev.api.example.com');
  static const enableLogging = bool.fromEnvironment('ENABLE_LOGGING', defaultValue: true);
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');   // '' = disabled
  static const isConfigured = bool.hasEnvironment('APP_FLAVOR');

  static AppFlavor get flavor => parseFlavor(flavorName);
  static bool get isProduction => flavor == AppFlavor.prod;

  static AppFlavor parseFlavor(String name) =>
      AppFlavor.values.firstWhere((f) => f.name == name, orElse: () => AppFlavor.dev);
}
```
Rules:
- **Always `const`.** `String.fromEnvironment` outside a const context is not guaranteed to work (and doesn't on web).
- Give **dev defaults** so a plain `flutter run` still works.
- Types: `String`, `bool.fromEnvironment` (`"true"`/`"false"`), `int.fromEnvironment`.
- `if (AppEnvironment.isProduction)` branches are removed at compile time in other environments.

### Use them
```dart
final dio = Dio(BaseOptions(baseUrl: AppEnvironment.apiBaseUrl));
if (AppEnvironment.enableLogging) dio.interceptors.add(LogInterceptor());
if (AppEnvironment.sentryDsn.isNotEmpty) { /* init crash reporting */ }
```
In this project:
- **Home → Demos → Environment** (`lib/config/environment_page.dart`) lists the values and build mode.
- `lib/config/environment_banner.dart` shows a **DEV**/**STAGING** corner ribbon (hidden in prod) via
  `MaterialApp.router(builder: (context, child) => EnvironmentBanner(child: child!))`.

### ⚠️ Not for secrets
Everything passed with `--dart-define` is **compiled into the binary** and can be extracted from the APK/IPA/JS.
OK: API base URLs, feature flags, public DSNs, analytics ids. Not OK: private API keys, DB passwords, signing keys —
keep those on your backend.

### IDE
**VS Code** — `.vscode/launch.json` (in this repo) has `dev`, `staging`, `prod (profile)` configurations:
```json
{
  "name": "staging",
  "request": "launch",
  "type": "dart",
  "program": "lib/main.dart",
  "args": ["--dart-define-from-file=env/staging.json"]
}
```
**Android Studio / IntelliJ** — *Run → Edit Configurations → main.dart → Additional run args*:
`--dart-define-from-file=env/dev.json` (duplicate the configuration per environment).

### Tests
```bash
flutter test                   # dev defaults
dart run rps test staging      # flutter test --dart-define-from-file=env/staging.json
```
`test/environment_test.dart` skips the defaults test when `APP_FLAVOR` is passed, and runs a staging test only
with the staging file.

### Flavors vs dart-define
`--flavor` (Android product flavors / Xcode schemes) is needed only when environments must be installed **side by
side** with different application ids, icons or app names. It requires native Gradle/Xcode setup per platform.
For "same app, different backend" `--dart-define-from-file` is enough and works on every platform.

---

## 4. Build

Which platforms can be built where:

| Target | Windows | macOS | Linux |
|---|:-:|:-:|:-:|
| `apk`, `appbundle` (Android) | ✅ | ✅ | ✅ |
| `web` | ✅ | ✅ | ✅ |
| `windows` | ✅ | | |
| `ios`, `ipa`, `macos` | | ✅ | |
| `linux` | | | ✅ |

Before building: `dart run rps gen` (Hive/Drift code + localizations). The `build` scripts do this automatically.

### Android
```bash
dart run rps build apk staging                    # universal APK (testers, sideload)
dart run rps build appbundle prod                 # AAB for Google Play (obfuscated)
flutter build apk --release --split-per-abi --dart-define-from-file=env/prod.json   # smaller per-ABI APKs
```
Output: `build/app/outputs/flutter-apk/app-release.apk`, `build/app/outputs/bundle/release/app-release.aab`.
Google Play requires an **AAB** signed with your upload key ([6](#6-release-signing)).

### iOS (Mac)
```bash
dart run rps build ipa prod
```
Output: `build/ios/ipa/*.ipa` → upload with **Transporter**, or open `build/ios/archive/Runner.xcarchive` in Xcode →
*Distribute App*. `flutter build ios` builds the `.app` only.

### macOS (Mac)
```bash
dart run rps build macos prod
```
Output: `build/macos/Build/Products/Release/<App>.app` — sign + notarize for distribution outside the App Store.

### Windows
```bash
dart run rps build windows staging
```
Output: `build/windows/x64/runner/Release/` — ship the **whole folder** (exe + `data/` + DLLs).
For an installer use MSIX (`msix` package) or Inno Setup; MSIX is also required for some Windows features
(e.g. `flutter_local_notifications` `cancel`).

### Linux
```bash
dart run rps build linux prod
```
Output: `build/linux/x64/release/bundle/` → package as deb/rpm/AppImage/Snap/Flatpak.

### Web
```bash
dart run rps build web prod
dart run rps build web prod --wasm                 # WebAssembly (JS fallback)
dart run rps build web prod --base-href /app/      # served under /app/
```
Output: `build/web/` → any static host. Serve `index.html` for unknown paths if you use path URLs
([020](020-add-go-router.md#deep-links--web)). Drift needs `sqlite3.wasm` + `drift_worker.js` in `web/`
([022](022-add-drift.md#5-web-setup)).

---

## 5. Versioning
`pubspec.yaml`:
```yaml
version: 1.2.0+42     # build-name + build-number
```
| | Android | iOS / macOS | Windows |
|---|---|---|---|
| `1.2.0` (build name) | `versionName` | `CFBundleShortVersionString` | `ProductVersion` |
| `42` (build number) | `versionCode` (must increase for Play) | `CFBundleVersion` | file version |

Override per build (e.g. CI) — extra arguments are appended to the script:
```bash
dart run rps build appbundle prod --build-name=1.2.0 --build-number=42
```
Shown in the app with `package_info_plus` ([014](014-add-package-info.md)).

---

## 6. Release signing

### Android
The template signs release builds with the **debug key** — Play rejects that.

1. Create an upload keystore once (keep the file and passwords safe — losing it blocks updates):
   ```bash
   keytool -genkey -v -keystore <home-folder>/upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   `keytool` ships with the JDK (Android Studio: `<Android Studio>/jbr/bin/keytool`).
2. `android/key.properties` (**never commit** — make sure it's in `.gitignore`):
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=<home-folder>/upload-keystore.jks
   ```
3. `android/app/build.gradle.kts`:
   ```kotlin
   import java.io.FileInputStream
   import java.util.Properties

   val keystoreProperties = Properties()
   val keystorePropertiesFile = rootProject.file("key.properties")
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(FileInputStream(keystorePropertiesFile))
   }

   android {
       signingConfigs {
           create("release") {
               keyAlias = keystoreProperties["keyAlias"] as String?
               keyPassword = keystoreProperties["keyPassword"] as String?
               storeFile = keystoreProperties["storeFile"]?.let { file(it) }
               storePassword = keystoreProperties["storePassword"] as String?
           }
       }
       buildTypes {
           release {
               signingConfig = if (keystorePropertiesFile.exists()) {
                   signingConfigs.getByName("release")
               } else {
                   signingConfigs.getByName("debug")   // local builds without the keystore
               }
           }
       }
   }
   ```
4. Enable **Play App Signing** in Play Console (Google keeps the app signing key, you keep the upload key).

In CI, write `key.properties` and the keystore from secrets before building ([9](#9-ci-example)).

### iOS / macOS
Xcode → *Runner → Signing & Capabilities* → Team + "Automatically manage signing". `flutter build ipa` uses it;
for CI: `dart run rps build ipa prod --export-options-plist=ios/ExportOptions.plist`.

---

## 7. Obfuscation and symbols
The `prod` build scripts already add it:
```bash
flutter build appbundle --release --obfuscate --split-debug-info=build-symbols/appbundle/prod --dart-define-from-file=env/prod.json
```
- `--obfuscate` **must** be combined with `--split-debug-info` (symbols directory).
- Available for `apk`, `appbundle`, `ios`, `ipa`, `macos`, `windows` (checked with `flutter build <target> -h`);
  check `flutter build linux -h` on a Linux host. Not for web (JS is already minified; use `--source-maps`).
- Keep the symbols **per release** (upload to Crashlytics/Sentry) — `build-symbols/` is in `.gitignore`.
- Readable stack trace from an obfuscated crash:
  ```bash
  flutter symbolize -i crash.txt -d build-symbols/appbundle/prod/app.android-arm64.symbols
  ```
- Obfuscation renames identifiers: `runtimeType.toString()`, `Enum.toString()` and code relying on class names
  break — use `enum.name` (preserved) and explicit strings.
- It's not security: strings, URLs and `--dart-define` values stay readable.

---

## 8. Project scripts in pubspec.yaml

Dart/pub has no built-in `scripts:` section (like `npm run`). This project uses
[`rps`](https://pub.dev/packages/rps) (Run Pubspec Script, MIT) so all run/build commands live in `pubspec.yaml`
and work the same on Windows, macOS, Linux and CI.

### Setup
`rps` is a **dev dependency**, so `flutter pub get` installs it for everyone — no global tools:
```bash
flutter pub add "dev:rps:^0.10.1"
dart run rps ls
```
Optional shortcut: `dart pub global activate rps` → then just `rps ls`, `rps build apk staging`.

(`derry` is not an option: last release 2023, doesn't support Dart 3. `melos` is for monorepos.)

### The scripts — `pubspec.yaml`
```yaml
scripts:
  gen:
    $description: Code generation (Hive adapters, Drift) + localizations
    $script: dart run build_runner build
    $after: flutter gen-l10n
  check:
    $description: gen, then analyze and test (run before committing)
    $before: rps gen
    $script: flutter analyze
    $after: flutter test
  clean:
    $description: Delete build outputs
    $script: flutter clean

  start:                      # NOT `run` — that's a built-in rps command
    dev:
      $description: Debug run with env/dev.json (append -d <device>)
      $script: flutter run --dart-define-from-file=env/dev.json
    staging: flutter run --dart-define-from-file=env/staging.json
    prod: flutter run --release --dart-define-from-file=env/prod.json

  test:
    staging: flutter test --dart-define-from-file=env/staging.json

  build:
    $before: rps gen          # runs before every `build ...` command
    apk:
      dev: flutter build apk --release --dart-define-from-file=env/dev.json
      staging: flutter build apk --release --dart-define-from-file=env/staging.json
      prod: flutter build apk --release --obfuscate --split-debug-info=build-symbols/apk/prod --dart-define-from-file=env/prod.json
    appbundle:
      staging: ...
      prod: ...
    ipa: { staging: ..., prod: ... }
    macos: { prod: ... }
    windows: { dev: ..., staging: ..., prod: ... }
    linux: { prod: ... }
    web: { staging: ..., prod: ... }
```

### Commands

| Command | Does |
|---|---|
| `dart run rps ls` | List all commands with descriptions |
| `dart run rps gen` | `build_runner build` → `flutter gen-l10n` |
| `dart run rps check` | gen → `flutter analyze` → `flutter test` |
| `dart run rps start dev -d windows` | Run with `env/dev.json` on a device |
| `dart run rps start staging -d chrome` | Run with `env/staging.json` |
| `dart run rps start prod -d <phone>` | Release run with `env/prod.json` |
| `dart run rps test staging` | Tests with staging values |
| `dart run rps build apk dev\|staging\|prod` | gen → APK |
| `dart run rps build appbundle staging\|prod` | gen → AAB |
| `dart run rps build ipa staging\|prod` | gen → IPA (macOS) |
| `dart run rps build macos prod` | gen → macOS app |
| `dart run rps build windows dev\|staging\|prod` | gen → Windows (dev = debug) |
| `dart run rps build linux prod` | gen → Linux bundle |
| `dart run rps build web staging\|prod` | gen → web |
| `dart run rps clean` | `flutter clean` |
| `dart run rps env init-prod` | Create `env/prod.json` from the example (keeps an existing file) |

### Extra arguments
Anything after the command name is appended to the script:
```bash
dart run rps start dev -d R68Y1018SPH
dart run rps build appbundle prod --build-name=1.2.0 --build-number=42
dart run rps build web prod --wasm
dart run rps test staging test/environment_test.dart
```
Secrets from CI/OS environment variables — `--dart-define` overrides the value from the env file:
```bash
dart run rps build appbundle prod --dart-define=SENTRY_DSN=<value-from-ci-secret>
```
(Still compiled into the app — only for values that may be public.)

### Adding a command
```yaml
scripts:
  format: dart format lib test
  build:
    apk:
      qa:
        $description: QA build with a separate env file
        $script: flutter build apk --release --dart-define-from-file=env/qa.json
```
Useful rps features:
- `$before` / `$after` hooks, also on a group (every child runs them).
- References: `rps <other command>` inside a hook doesn't start a new process.
- Positional arguments: `build: flutter build ${0} --release` → `dart run rps build apk` (not in hooks).
- Per-OS scripts (this project's `env init-prod`):
  ```yaml
  scripts:
    env:
      init-prod:
        $script:
          $windows: if not exist env\prod.json copy env\prod.example.json env\prod.json
          $default: cp -n env/prod.example.json env/prod.json
  ```
  Plain `flutter`/`dart` commands work everywhere; only shell-specific syntax (`copy`/`cp`, variables, `&&`)
  needs `$windows`/`$default`.
- **Don't name a script or group `run`** — `rps run <script>` is a built-in command, so `rps run dev` looks for a
  script named `dev` ("Missing script"). This project uses `start`.

### Which shell runs the scripts — `rps.yaml`
By default rps uses **PowerShell on Windows** and **bash on macOS/Linux**. PowerShell loads the user's profile before
every command, so machines with a restricted execution policy print
`profile.ps1 cannot be loaded because running scripts is disabled` on each step. This project switches Windows to
`cmd`:
```yaml
# rps.yaml (project root) — interpreter only, no `scripts:` key
windows:
  interpreter: cmd          # cmd | powershell
```
- If `rps.yaml` has **no** `scripts:`, rps still reads the scripts from `pubspec.yaml`.
- If it **has** `scripts:`, those replace the ones in `pubspec.yaml` (an option if you want scripts out of pubspec).
- Linux/macOS: `linux: { interpreter: zsh }` / `macos: { interpreter: zsh }` (`bash` default, `sh`, `zsh`).

---

## 9. CI example
GitHub Actions — Android App Bundle for prod:
```yaml
name: android-release
on:
  push:
    tags: ['v*']
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-java@v4
        with: { distribution: temurin, java-version: '17' }
      - uses: subosito/flutter-action@v2
        with: { channel: stable }
      - run: flutter pub get
      - name: Create prod env file
        run: echo '${{ secrets.PROD_ENV_JSON }}' > env/prod.json
      - name: Signing
        run: |
          echo '${{ secrets.UPLOAD_KEYSTORE_BASE64 }}' | base64 -d > android/upload-keystore.jks
          cat > android/key.properties <<EOF
          storePassword=${{ secrets.KEYSTORE_PASSWORD }}
          keyPassword=${{ secrets.KEY_PASSWORD }}
          keyAlias=upload
          storeFile=../upload-keystore.jks
          EOF
      - name: Build
        run: >
          dart run rps build appbundle prod
          --build-name=${GITHUB_REF_NAME#v}
          --build-number=${{ github.run_number }}
          --dart-define=SENTRY_DSN=${{ secrets.SENTRY_DSN }}
      - uses: actions/upload-artifact@v4
        with:
          name: app-release
          path: |
            build/app/outputs/bundle/release/app-release.aab
            build-symbols/
```

---

## Troubleshooting
| Problem | Fix |
|---|---|
| Windows: `flutter_tts/windows/CMakeLists.txt … nuget.exe not found. Please install it.` | `winget install Microsoft.NuGet`, then open a new terminal ([033](033-add-flutter-tts.md)) |
| `No supported devices found with name or id matching 'android'` | `-d` takes a device id/name from `flutter devices` |
| `Lost connection to device.` | App window closed / app killed. Immediately on start → check the log above for an exception |
| Android phone not listed | USB debugging off, prompt not accepted, charge-only cable — check `adb devices` |
| `unauthorized` in `adb devices` | Unlock phone, accept the RSA prompt; *Revoke USB debugging authorizations* and reconnect |
| `Android license status unknown` | `flutter doctor --android-licenses` |
| `Could not find package "rps"` | `flutter pub get` (rps is a dev dependency) |
| rps: command not found / unknown script | `dart run rps ls` for the exact names (nested: `build apk staging`) |
| `Error! Missing script. Command: "run dev ..."` | `run` is a built-in rps command — use `dart run rps start dev ...` (never name a script `run`) |
| `profile.ps1 cannot be loaded because running scripts is disabled` on every rps step | rps is using PowerShell — keep `rps.yaml` with `windows: interpreter: cmd` |
| Env values are the defaults | Env file not passed (use `dart run rps start ...`), or `fromEnvironment` not used as `const` |
| Changed `env/*.json` but app shows old values | Values are compile-time — stop and run/build again (hot reload/restart doesn't apply them) |
| `Did not find the file passed to "--dart-define-from-file". Path: env/prod.json` | `dart run rps env init-prod`, then put real values in `env/prod.json` (it's gitignored) — or create it in CI |
| Generated file missing (`*.g.dart`, `app_localizations.dart`) | `dart run rps gen` |
| Play Console: "signed in debug mode" | Configure release signing ([6](#6-release-signing)) |
| Play Console: "version code already used" | Increase `--build-number` / `+N` in pubspec |
| `--obfuscate` error | Add `--split-debug-info=<dir>` |
| Windows: `Cannot open include file: 'atlbase.h'` | Install C++ ATL ([006](006-add-local-notifications.md#windows-install-c-atl-required-to-build)) |
| Windows: pdfrx build fails creating symlinks | Enable **Developer Mode** ([016](016-add-pdfrx.md)) |
| Windows: `C1041: cannot open program database` / file in use | Two builds at once — build one platform at a time |
| Android: `permission_handler_android requires ... compileSdk of at least 37` | `compileSdk = 37` in `android/app/build.gradle.kts` ([015](015-add-permission-handler.md)) |
| Android: `this and base files have different roots` | `kotlin.incremental=false` in `android/gradle.properties` ([006](006-add-local-notifications.md)) |
| Android release: `Cannot access output property 'outputFile' of task ':<plugin>:createFullJarRelease'` | Transient Gradle state/file lock (seen on the first release build here) — run the build again; if it repeats, `dart run rps clean` and rebuild |
| `WARNING: ... plugins that apply Kotlin Gradle Plugin (KGP)` | Warning only; upgrade those plugins when migrated |
| iOS: `No valid code signing certificates` | Select a Team in Xcode → Signing & Capabilities |
