# Background Removal with image_background_remover (evaluated, not added)

[`image_background_remover`](https://pub.dev/packages/image_background_remover) **2.0.x** removes image
backgrounds **on-device** with a bundled ONNX segmentation model. It was evaluated for this project and
**not added** — this page records why and how to use it if your requirements differ.

## Why it's not in this project
| Requirement | Package | This project |
|---|---|---|
| iOS deployment target | **16.0** (ONNX Runtime pod) | 13.0 |
| macOS deployment target | **14.0** | 10.15 |
| Web | needs `ort.min.js` script; model asset loading unreliable | supported |

A plugin can't be excluded per platform, so adding it forces the **whole app** to iOS 16 / macOS 14 and drops
users on older OS versions. We keep the lower targets.

Other trade-offs:
- +~4.4 MB bundled model (320×320 input) plus the ONNX Runtime native libraries per platform.
- Post-processing runs per pixel in Dart on the calling isolate → UI jank on large photos.
- Quality is fine for portraits/products, weaker on hair, fine detail and busy backgrounds.
- The Windows build downloads onnxruntime from GitHub at build time (offline/CI builds fail).

## If you do use it
```bash
flutter pub add image_background_remover
```
**iOS** — `ios/Podfile`: `platform :ios, '16.0'` and `IPHONEOS_DEPLOYMENT_TARGET = 16.0` in Xcode.
**macOS** — `platform :osx, '14.0'` and `MACOSX_DEPLOYMENT_TARGET = 14.0`.
**Android release** — `android/app/proguard-rules.pro` (JNI classes are looked up by name):
```
-keep class ai.onnxruntime.** { *; }
```

```dart
import 'package:image_background_remover/image_background_remover.dart';

await BackgroundRemover.instance.initializeOrt();          // once, e.g. before first use

final Uint8List png = await BackgroundRemover.instance.removeBgBytes(
  await pickedFile.readAsBytes(),
  threshold: 0.5,
  smoothMask: true,
  enhanceEdges: true,
);                                                          // transparent PNG
Image.memory(png);

// ui.Image variant: removeBg(bytes) → dispose() it when done
// JPEG with a solid background: addBackground(image: png, bgColor: Colors.white)

BackgroundRemover.instance.dispose();                      // free the ONNX session
```
- Downscale the photo first (`flutter_image_compress`, [018](018-add-image-compress.md)) — the model works at
  320×320 anyway, and it shortens the Dart post-processing.
- Show a progress indicator; expect hundreds of ms to seconds on mid-range phones.

## Alternatives
| Option | Platforms | Notes |
|---|---|---|
| Server-side (remove.bg API, own model on a backend) | all | Best quality, costs money, image leaves the device (privacy), needs network |
| Google ML Kit **Subject Segmentation** (`google_mlkit_subject_segmentation`) | Android | No bundled model (Play services download), good quality |
| ML Kit **Selfie Segmentation** (`google_mlkit_selfie_segmentation`) | Android, iOS | People only; iOS min 15.5 |
| Apple Vision `VNGenerateForegroundInstanceMaskRequest` via platform channel | iOS 17+, macOS 14+ | Native "lift subject" quality, write your own channel |
