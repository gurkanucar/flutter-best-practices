# Pick Images with image_picker

Uses [`image_picker`](https://pub.dev/packages/image_picker) **1.2.x** — pick photos/videos from the gallery or
take them with the camera.

| Android | iOS | macOS | Windows | Linux | Web |
|:-:|:-:|:-:|:-:|:-:|:-:|
| ✅ | ✅ | ✅ gallery | ✅ gallery | ✅ gallery | ✅ |

Camera on desktop only with a custom `cameraDelegate`; resizing options are ignored on desktop.

## Steps

### 1. Add dependency
```bash
flutter pub add image_picker
```

### 2. Platform setup
**iOS** — `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Pick a photo to compress and preview it.</string>
<key>NSCameraUsageDescription</key>
<string>Take a photo to compress and preview it.</string>
<!-- video recording only: NSMicrophoneUsageDescription -->
```
`NSPhotoLibraryUsageDescription` is required by App Store review even with `requestFullMetadata: false`.

**macOS** — both entitlements files:
```xml
<key>com.apple.security.files.user-selected.read-only</key>
<true/>
```

**Android** — nothing. Android 13+ uses the system **Photo Picker** (no storage permission). Don't use
`launchMode="singleInstance"` for the activity (results come back as cancelled); Flutter's default `singleTop`
works.

**Windows / Linux / Web** — nothing.

### 3. Pick
```dart
import 'package:image_picker/image_picker.dart';

final picker = ImagePicker();

final XFile? photo = await picker.pickImage(
  source: ImageSource.gallery,          // or ImageSource.camera
  maxWidth: 2000,                       // ignored on desktop
  imageQuality: 85,                     // jpeg/webp, ignored on desktop
);
if (photo == null) return;              // user cancelled

final List<XFile> photos = await picker.pickMultiImage(limit: 5);
final XFile? video = await picker.pickVideo(source: ImageSource.camera, maxDuration: const Duration(seconds: 30));
final XFile? media = await picker.pickMedia();          // image or video
```
Check camera availability first:
```dart
if (picker.supportsImageSource(ImageSource.camera)) { /* show camera button */ }
```

### 4. Use the file
```dart
final bytes = await photo.readAsBytes();   // every platform
photo.name;  photo.mimeType;  await photo.length();

Image.memory(bytes);                        // works everywhere
// Image.file(File(photo.path))            // not on web
// Image.network(photo.path)               // web: path is a blob: URL
```
Prefer bytes/`XFile` APIs over `dart:io File` if you target web.

### 5. Demo — `lib/media/image_demo_page.dart`
**Home → Demos → Pick & compress images**:
```dart
final file = await _picker.pickImage(source: source);
if (file == null) return;
final original = await file.readAsBytes();
// → flutter_image_compress (018) → thumbnails → photo_view gallery (023)
```
The camera button is only shown when `supportsImageSource(ImageSource.camera)` is true.

## Android: recover lost results
Android can kill the app while the camera is open. On startup:
```dart
Future<void> recoverLostImage() async {
  final response = await ImagePicker().retrieveLostData();
  if (response.isEmpty) return;
  if (response.files != null) {
    // handle response.files
  } else {
    debugPrint('${response.exception}');
  }
}
```

## Permissions
- Gallery: no permission needed on Android (Photo Picker) or iOS 14+ (PHPicker, limited access).
- Camera: the plugin triggers the OS dialog; to explain first or handle "permanently denied", check with
  `permission_handler` ([015](015-add-permission-handler.md)).

## Notes
- EXIF (GPS, date) is kept by default on some platforms — strip it before upload
  (`flutter_image_compress` with `keepExif: false`).
- Photos from modern phones are large (5–15 MB) — resize/compress before upload.
- Widget tests: mock `ImagePickerPlatform.instance` or test the logic after picking.
