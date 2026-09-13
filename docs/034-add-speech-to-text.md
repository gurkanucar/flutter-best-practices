# Speech Recognition with speech_to_text

Uses [`speech_to_text`](https://pub.dev/packages/speech_to_text) **7.4.x** — convert speech to text with the
platform recognizer, with a selectable recognition language.

| Android | iOS | macOS | Windows | Linux | Web |
|:-:|:-:|:-:|:-:|:-:|:-:|
| ✅ | ✅ | ✅ | ⚠️ beta | ❌ | ✅ Chrome/Edge |

Windows (SAPI) is marked "not ready for production" by the package: `locales()` is hard-coded to en-US/en-GB, the
chosen locale is ignored, no errors or sound levels are reported.

## Steps

### 1. Add dependency
```bash
flutter pub add speech_to_text
```

### 2. Platform setup
**Android** — `AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>  <!-- also in src/main, not only debug -->

<queries>
    <intent>
        <action android:name="android.speech.RecognitionService"/>
    </intent>
</queries>
```
Without `SpeechToText.androidNoBluetooth` (see below) you also need `BLUETOOTH`, `BLUETOOTH_ADMIN` and
`BLUETOOTH_CONNECT` — `initialize()` requests `BLUETOOTH_CONNECT` for headset microphones.

**iOS** — `ios/Runner/Info.plist`:
```xml
<key>NSMicrophoneUsageDescription</key>
<string>Record your voice to convert it to text.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Convert your speech to text.</string>
```

**macOS** — the same two keys in `macos/Runner/Info.plist`, plus in **both** entitlements files:
```xml
<key>com.apple.security.device.audio-input</key>
<true/>
```
The plugin's podspec requires **macOS 11.0**, its `Package.swift` 10.14. When the macOS build uses Swift Package
Manager the app's 10.15 target is fine; when it uses CocoaPods (e.g. because another plugin, like flutter_tts, has
no `Package.swift`) and `pod install` fails, raise `MACOSX_DEPLOYMENT_TARGET` (and `platform :osx` in the Podfile)
to 11.0. Not verified here — this project is built on Windows.

**Windows / Web** — nothing (web needs HTTPS or localhost for microphone access).

### 3. Initialize once
```dart
final speech = SpeechToText(); // singleton

bool available;
try {
  available = await speech.initialize(   // asks for the permission(s)
    onError: (error) => showError(error.errorMsg),   // e.g. error_no_match, error_network
    onStatus: (status) => setState(() {}),           // listening / notListening / done
    options: [SpeechToText.androidNoBluetooth],
  );
} on PlatformException {
  available = false;                     // Android can throw instead of returning false
}
```
`SpeechToText` is a singleton and a second `initialize()` returns the cached result **without registering the new
callbacks**. A page that is opened again must re-attach them:
```dart
speech..errorListener = _onError..statusListener = _onStatus;   // and set them to null in dispose()
```
If `available` is false, check `await speech.hasPermission` and offer `AppSettings.openAppSettings()`
([009](009-add-app-settings.md)) for a permanently denied microphone.

### 4. Choose the language
```dart
final List<LocaleName> locales = await speech.locales();   // LocaleName(localeId, name) — on-device languages
final LocaleName? system = await speech.systemLocale();

final localeId = bestLocaleMatch(locales.map((l) => l.localeId), Localizations.localeOf(context))
    ?? system?.localeId;
```
Locale ids differ per platform (`tr-TR`, `tr_TR`) — `lib/speech/locale_matching.dart` normalizes them (shared with
the TTS demo). Web returns at most one locale; iOS/Android list only languages the recognizer supports.

### 5. Listen
```dart
await speech.listen(
  onResult: (result) => setState(() {
    words = result.recognizedWords;
    isFinal = result.finalResult;
    confidence = result.hasConfidenceRating ? result.confidence : null;
  }),
  onSoundLevelChange: (level) => setState(() => this.level = level), // not on Windows/web
  listenOptions: SpeechListenOptions(          // 7.x: these moved out of listen()
    localeId: localeId,
    partialResults: true,
    cancelOnError: true,
    listenMode: ListenMode.dictation,          // iOS only
    listenFor: const Duration(seconds: 30),
    pauseFor: const Duration(seconds: 3),
  ),
);

await speech.stop();    // delivers the final result
await speech.cancel();  // discards it
```
Sound levels use different units (Android rms dB ≈ -2…10, Apple dB) — the demo normalizes by the observed min/max.

### 6. Demo — `lib/speech/speech_to_text_page.dart`
**Home → Demos → Speech to text**: searchable recognition-language dropdown (preselected from the app language),
microphone button, live partial results, final flag, confidence and a sound level bar.

## Gotchas
- **Android emulator:** needs the Google app with microphone permission and "Virtual microphone uses host audio"
  enabled. Android plays its own start/stop beeps.
- **iOS:** one-minute limit per session; the simulator often fails — test on a device. Using TTS right before
  listening can fail — wait until speaking has completed.
- **Privacy:** Android and iOS may send audio to Google/Apple servers. `SpeechListenOptions(onDevice: true)` forces
  on-device recognition where supported (fails if the language isn't downloaded).
- **macOS:** permission requests can crash when the app is launched from VS Code (flutter#70374) — launch from
  Xcode or the built app.
