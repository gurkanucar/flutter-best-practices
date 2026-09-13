# Add Local Notifications

Uses [`flutter_local_notifications`](https://pub.dev/packages/flutter_local_notifications) **22.x**
(+ [`timezone`](https://pub.dev/packages/timezone) and [`flutter_timezone`](https://pub.dev/packages/flutter_timezone) for scheduling).

> v22 uses **named parameters** everywhere: `initialize(settings: ...)`, `show(id: ..., title: ...)`,
> `zonedSchedule(id: ..., scheduledDate: ...)`, `cancel(id: ...)`.
> Older snippets on the internet (`show(0, 'title', 'body', details)`) don't compile.

## Platform support

| Feature | Android | iOS | macOS | Windows | Linux | Web |
|---|---|---|---|---|---|---|
| Show now | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (after user-initiated permission) |
| Schedule (`zonedSchedule`) | ✅ | ✅ (max 64 pending) | ✅ | ✅ | ❌ `UnimplementedError` | ❌ `UnsupportedError` |
| Repeat (`periodicallyShow`) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| `cancel` / active notifications | ✅ | ✅ | ✅ | ⚠️ only MSIX-packaged apps | ✅ | ✅ |
| Runtime permission | Android 13+ | ✅ | ✅ | – | – | ✅ (only from a click) |

## Steps

### 1. Add dependencies
```bash
flutter pub add flutter_local_notifications timezone flutter_timezone
```
`timezone` is a transitive dependency too, but add it directly — you import it
(`depend_on_referenced_packages` lint).

### 2. Android

**a) `android/app/build.gradle.kts` — core library desugaring (required):**
```kotlin
android {
    compileSdk = flutter.compileSdkVersion   // 36 in Flutter 3.47 — plugin needs ≥ 35

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```
- `multiDexEnabled` from the plugin README is not needed: Flutter's `minSdk` is 24 (multidex is built in since 21).

**b) `android/app/src/main/AndroidManifest.xml` — only for scheduled notifications:**
```xml
<manifest ...>
    <!-- POST_NOTIFICATIONS + VIBRATE are added by the plugin itself -->
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>

    <application ...>
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
        <receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED"/>
                <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
                <action android:name="android.intent.action.QUICKBOOT_POWERON" />
                <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
            </intent-filter>
        </receiver>
        ...
    </application>
</manifest>
```
- `SCHEDULE_EXACT_ALARM` is **not granted by default on Android 14+**. The service checks
  `canScheduleExactNotifications()` and falls back to `inexactAllowWhileIdle` (the OS may delay it).
  To ask the user, call `requestExactAlarmsPermission()` (opens system settings).
- Don't use `USE_EXACT_ALARM` unless the app is an alarm clock / calendar — Google Play restricts it.
- Other features need more entries (actions → `ActionBroadcastReceiver`, full-screen intent,
  foreground service, DnD) — see the plugin README.

**c) Notification icon — `android/app/src/main/res/drawable/ic_notification.xml`:**
White silhouette on transparent background (Android tints it; a colored launcher icon shows as a white square).
This project uses a vector bell icon. Create your own with Android Studio →
*New → Image Asset → Notification Icons*. Referenced by name in `AndroidInitializationSettings('ic_notification')`.

**d) Keep the icon in release builds — `android/app/src/main/res/raw/keep.xml`:**
```xml
<?xml version="1.0" encoding="utf-8"?>
<resources xmlns:tools="http://schemas.android.com/tools"
    tools:keep="@drawable/ic_notification" />
```
Without this, R8 resource shrinking can remove the icon → notifications silently fail in release.
ProGuard rules are not needed since plugin v19.

### 3. iOS — `ios/Runner/AppDelegate.swift`

This project uses the UIScene / implicit engine template (`FlutterImplicitEngineDelegate`):
```swift
import Flutter
import UIKit
import flutter_local_notifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
```
- The delegate line is needed for tap callbacks and showing notifications while the app is in the foreground.
- `setPluginRegistrantCallback` is only needed for notification actions (background isolate), but harmless.

### 4. macOS / Windows / Linux / Web

- **macOS:** no native changes.
- **Windows:** no project changes, but the **build machine needs the Visual Studio "C++ ATL" component**
  — see [Windows: install C++ ATL](#windows-install-c-atl-required-to-build) below.
  `WindowsInitializationSettings` needs `appName`, `appUserModelId` and a **unique GUID** per app
  (`[guid]::NewGuid()` in PowerShell). Without MSIX packaging `cancel` does nothing.
- **Linux:** no native changes. `defaultActionName` is required. No scheduling.
- **Web:** no HTML/JS changes. Permission can **only** be requested from a user gesture (button click) —
  asking on page load can get the site permanently blocked by the browser.

### Windows: install C++ ATL (required to build)

`flutter_local_notifications_windows` compiles native C++ that includes `atlbase.h`.
Visual Studio / Build Tools **don't install ATL by default** ("Desktop development with C++" workload alone
is not enough), so the first Windows build fails with:
```
plugin.cpp(5,10): error C1083: Cannot open include file: 'atlbase.h': No such file or directory
```
This is a one-time setup per machine (every developer and CI agent that builds for Windows).

**Check if ATL is installed:**
```powershell
& "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe" -products * -requires Microsoft.VisualStudio.Component.VC.ATL -property installationPath
```
Prints the install path → installed. Prints nothing → not installed.

**Option A — Visual Studio Installer (GUI):**
1. Start menu → **Visual Studio Installer**
2. Next to **Visual Studio Build Tools 2022** (or Visual Studio 2022) → **Modify**
3. **Individual components** tab → search `ATL`
4. Tick **C++ ATL for latest v143 build tools (x86 & x64)**
5. **Modify** (bottom right) and wait until it finishes

**Option B — command line (PowerShell as Administrator), paste as ONE line:**
```powershell
& "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\setup.exe" modify --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools" --add Microsoft.VisualStudio.Component.VC.ATL --passive
```
- Replace `--installPath` if you use Visual Studio instead of Build Tools
  (e.g. `C:\Program Files\Microsoft Visual Studio\2022\Community`). Find it with
  `vswhere.exe -products * -property installationPath`.
- Close any open Visual Studio Installer window first — only one installer can run at a time.
- Don't split the command over multiple lines when pasting: a missing trailing `` ` `` starts `setup.exe`
  without arguments (opens the installer UI) and then fails with
  `modify : The term 'modify' is not recognized`.
- `profile.ps1 cannot be loaded because running scripts is disabled` at PowerShell startup is unrelated — ignore it.

**Then rebuild:**
```bash
flutter clean
flutter run -d windows
```

### 5. Service — `lib/notifications/notification_service.dart`

Key parts (full file in the project):
```dart
class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  final tappedPayload = ValueNotifier<String?>(null);

  bool get supportsScheduling => !kIsWeb && defaultTargetPlatform != TargetPlatform.linux;

  Future<void> init() async {
    // 1. Time zones (needed for zonedSchedule)
    tz.initializeTimeZones();                                   // package:timezone/data/latest_all.dart
    final timezone = await FlutterTimezone.getLocalTimezone();  // v5 returns TimezoneInfo
    tz.setLocalLocation(tz.getLocation(timezone.identifier));   // wrap in try/catch → falls back to UTC

    // 2. Plugin — don't request permissions here; do it from a user action
    final darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: InitializationSettings(
        android: const AndroidInitializationSettings('ic_notification'),
        iOS: darwin,
        macOS: darwin,
        linux: const LinuxInitializationSettings(defaultActionName: 'Open'),
        windows: const WindowsInitializationSettings(
          appName: 'Flutter Best Practices',
          appUserModelId: 'FlutterBestPractices',
          guid: '64fc77fa-1a4c-4514-8d81-0ae570941fc3',
        ),
        web: const WebInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) => tappedPayload.value = response.payload,
    );

    // 3. App opened by tapping a notification (callback above only fires while running)
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp ?? false) {
      tappedPayload.value = launch!.notificationResponse?.payload;
    }
  }
}
```
- Every platform you run on **must** have its settings in `InitializationSettings`, otherwise
  `initialize` throws `ArgumentError` at runtime.

**Permissions** (per platform implementation):
```dart
// Web
final web = _plugin.resolvePlatformSpecificImplementation<WebFlutterLocalNotificationsPlugin>();
await web?.requestNotificationsPermission();          // only inside onPressed!
// Android 13+
await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission();
// iOS (macOS: MacOSFlutterLocalNotificationsPlugin)
await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
    ?.requestPermissions(alert: true, badge: true, sound: true);
// Windows / Linux: nothing to request
```

**Show now:**
```dart
await _plugin.show(
  id: id,
  title: title,
  body: body,
  payload: 'demo-now',
  notificationDetails: NotificationDetails(
    android: AndroidNotificationDetails(
      'general',            // channel id — never change after release
      channelName,          // shown in system settings (localized)
      importance: Importance.high,   // high = heads-up popup
      priority: Priority.high,
    ),
  ),
);
```
- Same `id` → replaces the existing notification. Use unique ids for separate notifications.
- Android 8+: sound/vibration/importance belong to the **channel** and can't change after it's created
  — use a new channel id (or reinstall while developing).

**Schedule:**
```dart
await _plugin.zonedSchedule(
  id: id,
  title: title,
  body: body,
  scheduledDate: tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
  notificationDetails: details,
  androidScheduleMode: canScheduleExact
      ? AndroidScheduleMode.exactAllowWhileIdle
      : AndroidScheduleMode.inexactAllowWhileIdle,
  // matchDateTimeComponents: DateTimeComponents.time,  // repeat daily at that time
);
```

### 6. Initialize in `lib/main.dart`
```dart
Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    await NotificationService.instance.init();
  } catch (error, stackTrace) {
    // e.g. browser without Notification / Service Worker support — app still starts
    debugPrint('Notification init failed: $error\n$stackTrace');
  }

  runApp(const MainApp());
  FlutterNativeSplash.remove();
}
```

### 7. Localized texts

Notification texts come from the ARB files (both `app_en.arb` and `app_tr.arb`, same structure — see
[005-add-localization.md](005-add-localization.md)): `notifications`, `notificationChannelName`,
`showNotification`, `scheduleNotification`, `cancelNotifications`, `notificationTitle`, `notificationBody`,
`notificationScheduled`, `notificationPermissionDenied`, `schedulingNotSupported`, `lastTappedNotification`.

The service takes already-localized strings (`title`, `body`, `channelName`) — it has no `BuildContext`.
Scheduled notifications keep the language they were scheduled in.

### 8. Demo UI — `lib/notifications/notification_demo_section.dart`

Shown at the bottom of `HomePage`:
- **Show notification** → requests permission → `show`
- **Schedule in 5 seconds** → requests permission → `schedule` (disabled on web/Linux)
- **Cancel all** → `cancelAll`
- Displays the payload of the last tapped notification

Capture `ScaffoldMessenger.of(context)` and `context.l10n` **before** `await` (no `BuildContext` across async gaps).

### 9. Tests

Plugin calls need a real platform — in widget tests there is no platform channel, so only test the UI
(`test/notifications_test.dart`). Don't call `NotificationService.instance.init()` from widgets under test.

## Verify

```bash
flutter run -d windows   # Show → toast in the bottom-right; Schedule → after 5 s
flutter run -d chrome    # click Show → browser permission prompt → notification
flutter run -d <android> # Android 13+: permission dialog on first tap
```
- Android: test scheduled notifications with the app in background **and** killed.
  Some OEMs (Xiaomi, Huawei, Samsung…) kill background apps — see https://dontkillmyapp.com.
- iOS: notifications don't show in the simulator while the app is in the foreground unless
  the delegate line in `AppDelegate.swift` is present.
- Web: `localhost` counts as a secure context; production must be served over HTTPS.

## Troubleshooting
| Problem | Fix |
|---|---|
| `Dependency ':flutter_local_notifications' requires core library desugaring` | Step 2a |
| Windows build: `Cannot open include file: 'atlbase.h'` | Install **C++ ATL for latest v143 build tools (x86 & x64)** — see "Windows: install C++ ATL", then `flutter clean` |
| `modify : The term 'modify' is not recognized` (VS installer command) | Command was split over lines — paste it as one line; close the installer window it opened first |
| Android build: `this and base files have different roots` (Kotlin incremental caches) | Pub cache and project are on different drives (e.g. `C:` vs `D:`) → add `kotlin.incremental=false` to `android/gradle.properties`, then `flutter clean` |
| Notification not shown on Android, no error | Missing/invalid `ic_notification` drawable, or permission denied, or channel importance too low |
| Works in debug, not in release (Android) | `keep.xml` missing (step 2d) |
| Scheduled notification late on Android 14+ | Exact alarm permission not granted → inexact mode |
| Scheduled notifications gone after reboot | `RECEIVE_BOOT_COMPLETED` + boot receiver missing |
| Android build warning: `plugins that apply Kotlin Gradle Plugin (KGP): flutter_timezone` | Only a warning (plugin not yet migrated to Built-in Kotlin); build still succeeds. Upgrade `flutter_timezone` when a migrated version is released |
| `ArgumentError` on `initialize` | Settings for the current platform not passed |
| `UnimplementedError` / `UnsupportedError` on `zonedSchedule` | Linux / web — check `supportsScheduling` |
| `LocationNotFoundException` | Time zone identifier unknown to `timezone` — catch and fall back to UTC |
| Web: permission prompt never appears | Requested on page load, or site blocked in browser settings |
| Windows: `cancel` does nothing | App isn't MSIX-packaged (OS limitation) |
| `show(0, 'title', ...)` doesn't compile | v22 named parameters: `show(id: 0, title: ...)` |
