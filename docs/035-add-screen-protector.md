# Block Screenshots with screen_protector

Uses [`screen_protector`](https://pub.dev/packages/screen_protector) **1.5.x** — prevent screenshots and screen
recording of sensitive screens, hide the app switcher snapshot, detect screenshots on iOS.

| Android | iOS | macOS | Windows | Linux | Web |
|:-:|:-:|:-:|:-:|:-:|:-:|
| ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |

On other platforms every call throws `MissingPluginException` → guard by platform.

> This raises the bar, it isn't DRM: another camera, a rooted/jailbroken device or an external capture card still
> works. Don't rely on it instead of server-side protection.

## Steps

### 1. Add dependency
```bash
flutter pub add screen_protector
```
No permissions or native setup. `protectDataLeakageWithImage('LaunchImage')` needs an image set with that name in
`ios/Runner/Assets.xcassets`.

**Android build fix (AGP 9 + `android.builtInKotlin=false`).** The plugin applies `kotlin-android` only on AGP < 9
and otherwise relies on AGP's built-in Kotlin. Flutter's template sets `android.builtInKotlin=false`, so the
plugin's Kotlin sources are never compiled and the build fails with:
```
GeneratedPluginRegistrant.java: error: cannot find symbol
  new com.prongbang.screen_protector.ScreenProtectorPlugin()
```
Workaround in `android/build.gradle.kts` (applies Kotlin to that plugin project only):
```kotlin
subprojects {
    if (name == "screen_protector") {
        pluginManager.withPlugin("com.android.library") {
            pluginManager.apply("org.jetbrains.kotlin.android")
            tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
                compilerOptions.jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }
    }
}
```
Remove it once the plugin fixes this or the project switches to `android.builtInKotlin=true` (only possible when no
plugin applies KGP anymore — see the build warning listing them).

### 2. What each call does
| Dart | Android | iOS |
|---|---|---|
| `preventScreenshotOn()` / `Off()` | `FLAG_SECURE` on the window: screenshots/recordings/casts are black, app hidden in recents | Secure overlay: screenshots and recordings are blank |
| `protectDataLeakageWithBlur()` / `WithColor(color)` / `WithImage(name)` (+ `…Off()`) | no-op | Cover the app switcher snapshot |
| `addListener(onScreenshot, onScreenRecord)` / `removeListener()` | no-op | Screenshot taken (after the fact) / recording or mirroring started/stopped |
| `isRecording()` | always `false` | `UIScreen.isCaptured` |

Android can't detect screenshots at all.

### 3. Protect one sensitive page
```dart
@override
void initState() {
  super.initState();
  ScreenProtector.preventScreenshotOn();
  if (Platform.isIOS) {
    ScreenProtector.protectDataLeakageWithBlur();
    ScreenProtector.addListener(
      () => log('screenshot taken'),            // e.g. warn the user, audit log
      (isRecording) => setState(() => recording = isRecording),
    );
  }
}

@override
void dispose() {
  if (Platform.isIOS) {
    ScreenProtector.removeListener();
    ScreenProtector.protectDataLeakageWithBlurOff();
  }
  ScreenProtector.preventScreenshotOff();       // FLAG_SECURE stays on the whole Activity otherwise
  super.dispose();
}
```
`FLAG_SECURE` belongs to the Activity window, not the widget: while it's on, **every** screen of the app is
protected — including pages pushed on top. Always turn it off when leaving.

### 4. Whole-app protection
For banking-style apps, call `preventScreenshotOn()` once in `main()` after `WidgetsFlutterBinding.ensureInitialized()`
and never turn it off. Android alternative without a plugin: set `FLAG_SECURE` in `MainActivity.onCreate`.

### 5. Demo — `lib/security/screen_protector_page.dart`
**Home → Demos → Screenshot protection**: a card with fake card data; protection is on while the page is open,
with a switch to turn it off. iOS adds the app switcher blur switch, a screenshot counter and the recording state.

## Testing
- **Android:** take a screenshot → "Can't take screenshot due to security policy" or a black image; the recents
  thumbnail is blank. Emulator screenshots from Android Studio are blocked as well.
- **iOS:** test on a device — Control Center screen recording shows the recording state. Simulator: Device →
  Trigger Screenshot fires the screenshot listener.
- Keep it **off in debug builds** if it gets in the way of bug reports (`if (kReleaseMode)`).
