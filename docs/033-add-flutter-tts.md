# Text to Speech with flutter_tts

Uses [`flutter_tts`](https://pub.dev/packages/flutter_tts) **4.2.x** — read text aloud with the platform speech
engine, with a selectable language and voice.

| Android | iOS | macOS | Windows | Linux | Web |
|:-:|:-:|:-:|:-:|:-:|:-:|
| ✅ | ✅ | ✅ | ✅ SAPI | ❌ | ✅ Web Speech API |

## Steps

### 1. Add dependency
```bash
flutter pub add flutter_tts
```

### 2. Platform setup
**Android** — `android/app/src/main/AndroidManifest.xml`, inside `<queries>` (Android 11+ package visibility,
otherwise no TTS engine is found):
```xml
<intent>
    <action android:name="android.intent.action.TTS_SERVICE"/>
</intent>
```
The plugin needs **minSdk 24** (the README still says 21); Flutter's default `flutter.minSdkVersion` already is 24.

**Windows** — the plugin's CMake needs **`nuget.exe` on the PATH** (it downloads C++/WinRT). Without it the build
stops with `nuget.exe not found. Please install it.` Install once per machine (and on CI):
```bash
winget install Microsoft.NuGet
```
Open a new terminal afterwards so the PATH is updated.

**iOS / macOS / Web** — nothing. The plugin is CocoaPods-only on iOS/macOS (no `Package.swift`).

### 3. Initialize
```dart
final tts = FlutterTts(); // one instance at a time — the constructor re-registers the handlers

tts
  ..setStartHandler(() => setState(() => status = TtsStatus.speaking))
  ..setCompletionHandler(() => setState(() => status = TtsStatus.idle))
  ..setCancelHandler(() => setState(() => status = TtsStatus.idle))
  ..setPauseHandler(() => setState(() => status = TtsStatus.paused))
  ..setErrorHandler((message) => showError('$message'))
  ..setProgressHandler((text, start, end, word) => highlight(start, end)); // not on Windows

if (Platform.isIOS) {
  await tts.setSharedInstance(true);
  // playback = speak even with the silent switch on; duckOthers = lower music meanwhile
  await tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [IosTextToSpeechAudioCategoryOptions.duckOthers]);
}
```

### 4. Choose the language
```dart
final languages = ((await tts.getLanguages) as List).map((l) => '$l').toSet().toList()..sort();
// Android: tr-TR, iOS/macOS: tr-TR, Windows: tr-TR, web: voice.lang
final voices = ((await tts.getVoices) as List)
    .whereType<Map>()
    .map((v) => {for (final e in v.entries) '${e.key}': '${e.value}'})
    .toList(); // every platform: name + locale; Apple adds identifier/quality/gender

if (await tts.setLanguage('tr-TR') != 1) { /* not supported */ }
if (Platform.isAndroid && await tts.isLanguageInstalled('tr-TR') != true) {
  // supported, but the voice data isn't downloaded yet
}
await tts.setVoice(voices.firstWhere((v) => v['locale'] == 'tr-TR'));
```
Both lists are `dynamic` — always convert them. Locale ids come in different shapes (`tr-TR`, `tr_TR`), so the demo
matches them through `lib/speech/locale_matching.dart` (`bestLocaleMatch`, tested in
`test/locale_matching_test.dart`) and preselects the language of the app locale.

Changing the language after `setVoice` keeps the old voice → set a voice of the new language too (or clear it:
`clearVoice()` exists on Android/iOS only).

**Web:** browsers load voices lazily; the first `getLanguages` can be empty. The demo retries a few times.

### 5. Speak
```dart
await tts.setVolume(1.0);      // 0–1
await tts.setPitch(1.0);       // 0.5–2
await tts.setSpeechRate(0.5);  // native: 0.5 = normal, web: 1.0 = normal
await tts.speak(text);
await tts.pause();             // Android 8+: resumes from the last word on the next speak(sameText)
await tts.stop();
```
- `awaitSpeakCompletion(true)` makes `speak` wait until the end — useful for sequences, but it blocks the caller.
- Set the **volume before the pitch**: on iOS/macOS `setPitch` is ignored while the volume is below 0.5 (plugin bug).
- Stop in `dispose()` — speech continues after leaving the page otherwise.

### 6. Demo — `lib/speech/text_to_speech_page.dart`
**Home → Demos → Text to speech**: text field, searchable language dropdown (preselected from the app language),
voices of that language, speed/pitch/volume sliders, Speak/Pause/Stop and a highlight of the spoken word.

## Platform notes
| | |
|---|---|
| Android emulator | Needs a TTS engine with voice data (Settings → System → Languages → Text-to-speech) |
| Windows | SAPI voices only — voices installed only for Narrator/OneCore may be missing. `isLanguageAvailable` and the progress handler aren't implemented. |
| Android-only APIs | `getEngines`, `setEngine`, `isLanguageInstalled`, `setQueueMode`, `setSilence` (don't await it — it never completes) |
| File output | `synthesizeToFile` on Android/iOS/macOS |
