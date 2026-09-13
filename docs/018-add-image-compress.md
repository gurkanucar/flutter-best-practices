# Image Compression with flutter_image_compress

Uses [`flutter_image_compress`](https://pub.dev/packages/flutter_image_compress) **2.5.x** — resize and
re-encode images natively (JPEG/PNG/WebP/HEIC) before upload or storage.

| Android | iOS | macOS | Web | Windows | Linux |
|:-:|:-:|:-:|:-:|:-:|:-:|
| ✅ | ✅ | ✅ (10.15+) | ⚠️ `compressWithList` only | ❌ | ❌ |

## Steps

### 1. Add dependency
```bash
flutter pub add flutter_image_compress
```
- Android / iOS: no setup (no permissions).
- macOS: deployment target ≥ 10.15.
- Web: no script tag needed anymore (pica was removed in 2.4.0; uses Canvas).

### 2. API

| Method | Input → output | Web |
|---|---|---|
| `compressWithList(Uint8List, ...)` | bytes → `Uint8List` | ✅ |
| `compressWithFile(path, ...)` | file → `Uint8List?` | ❌ |
| `compressAndGetFile(path, targetPath, ...)` | file → `XFile?` (target must differ) | ❌ |
| `compressAssetImage(assetName, ...)` | asset → `Uint8List?` | ✅ |

Common parameters:
```dart
final bytes = await FlutterImageCompress.compressWithList(
  original,
  minWidth: 1280,        // upper bounds that keep the aspect ratio (name is misleading); never upscales
  minHeight: 1280,
  quality: 70,           // 0–100 (jpeg/webp)
  format: CompressFormat.jpeg,   // jpeg | png | webp | heic
  keepExif: false,       // strips GPS etc. by default (not on web)
  autoCorrectionAngle: true,     // apply EXIF orientation
);
```

### 3. Demo — `lib/media/image_demo_page.dart`
Pick with `image_picker` ([024](024-add-image-picker.md)) → compress → compare sizes → zoom with `photo_view`
([023](023-add-photo-view.md)):
```dart
static bool get compressionSupported =>
    kIsWeb ||
    defaultTargetPlatform == TargetPlatform.android ||
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

final file = await _picker.pickImage(source: source);
if (file == null) return;
final original = await file.readAsBytes();                // works on every platform incl. web
final compressed = compressionSupported
    ? await FlutterImageCompress.compressWithList(original,
        minWidth: 1280, minHeight: 1280, quality: 70, format: CompressFormat.jpeg)
    : null;
```
Size label helper `lib/media/byte_size.dart` (tested in `test/byte_size_test.dart`):
```dart
formatBytes(3250586);                                    // "3.1 MB"
savedPercent(original: 1000, compressed: 250);           // 75
```

## Formats

| Format | Android | iOS | macOS | Web |
|---|:-:|:-:|:-:|:-:|
| jpeg | ✅ | ✅ | ✅ | ✅ |
| png | ✅ | ✅ | ✅ | ✅ |
| webp | ✅ | ✅ (slow) | ❌ | browser-dependent |
| heic | API 28+ with HW encoder | iOS 11+ | ✅ | ❌ |

Unsupported format → `UnsupportedError`; fall back to JPEG:
```dart
try {
  return await FlutterImageCompress.compressWithList(bytes, format: CompressFormat.heic);
} on UnsupportedError {
  return FlutterImageCompress.compressWithList(bytes, format: CompressFormat.jpeg);
}
```

## Notes
- Native failures throw `CompressError` (not `null`) in recent versions — catch it.
- PNG ignores `quality` (lossless); resize dimensions instead.
- Compression can make already-small/optimized images **bigger** — compare sizes and keep the smaller one.
- `rotate` + `autoCorrectionAngle` can rotate twice.
- Background isolate: call `BackgroundIsolateBinaryMessenger.ensureInitialized(token)` first.
- Windows/Linux: use a pure-Dart package like `image` (slower) or compress on the server.
