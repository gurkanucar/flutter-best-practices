# Crop Images with image_cropper

Uses [`image_cropper`](https://pub.dev/packages/image_cropper) **12.x** — native crop screens: uCrop (Android),
TOCropViewController (iOS), cropperjs (web).

| Android | iOS | macOS | Windows | Linux | Web |
|:-:|:-:|:-:|:-:|:-:|:-:|
| ✅ | ✅ | ❌ | ❌ | ❌ | ✅ |

## Steps

### 1. Add dependency
```bash
flutter pub add image_cropper
```

### 2. Platform setup
**Android** — `AndroidManifest.xml`, inside `<application>`:
```xml
<activity
    android:name="com.yalantis.ucrop.UCropActivity"
    android:screenOrientation="portrait"
    android:theme="@style/Theme.AppCompat.Light.NoActionBar"/>
```
`UCropActivity` is an `AppCompatActivity` — without an AppCompat theme it crashes. Since 10.0 uCrop handles Android
15 edge-to-edge itself; remove old `values-v35` workarounds.

**Web** — `web/index.html`, inside `<head>`:
```html
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.css"
  integrity="sha384-msRo/DUqciLiajfTHR4aynPm/OyeCwjTio3llAz/9Ajeq4fDBmSiNL1QDum77PDK" crossorigin="anonymous" />
<script src="https://cdnjs.cloudflare.com/ajax/libs/cropperjs/1.6.2/cropper.min.js"
  integrity="sha384-jrOgQzBlDeUNdmQn3rUt/PZD+pdcRBdWd/HWRqRo+n2OR2QtGyjSaJC0GiCeH+ir" crossorigin="anonymous"></script>
```
`integrity` (Subresource Integrity) makes the browser refuse a modified CDN file. Or self-host the two files.

**iOS** — nothing.

### 3. Pick, then crop
```dart
final picked = await ImagePicker().pickImage(source: ImageSource.gallery);   // 024
if (picked == null || !mounted) return;

final cropped = await ImageCropper().cropImage(
  sourcePath: picked.path,                              // web: blob URL, also fine
  aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),   // locks the ratio
  maxWidth: 1080, maxHeight: 1080,                      // ignored on web
  compressFormat: ImageCompressFormat.jpg,
  compressQuality: 85,                                  // ignored on web
  uiSettings: [
    AndroidUiSettings(
      toolbarTitle: 'Crop',
      toolbarColor: colors.surface,
      toolbarWidgetColor: colors.onSurface,
      activeControlsWidgetColor: colors.primary,
      cropStyle: CropStyle.circle,                      // or rectangle
      lockAspectRatio: true,
      aspectRatioPresets: [CropAspectRatioPreset.square],
    ),
    IOSUiSettings(
      title: 'Crop',
      doneButtonTitle: l10n.done,
      cancelButtonTitle: l10n.cancel,
      cropStyle: CropStyle.circle,
      aspectRatioLockEnabled: true,
      aspectRatioPresets: [CropAspectRatioPreset.square],
    ),
    WebUiSettings(                                       // required on web
      context: context,
      presentStyle: WebPresentStyle.dialog,
      size: const CropperSize(width: 520, height: 520),
      translations: WebTranslations(title: …, rotateLeftTooltip: …, rotateRightTooltip: …, cancelButton: …, cropButton: …),
    ),
  ],
);
if (cropped == null) return;              // cancelled
final bytes = await cropped.readAsBytes();
```
- **Presets** moved into the UI settings (`aspectRatioPresets`) in 8.0. Custom ratios: implement
  `CropAspectRatioPresetData`.
- **Circle crop** only changes the overlay — the file is still a square image. Clip it when showing
  (`ClipOval` / `CircleAvatar`).
- **Temporary output:** the result is in the cache/tmp directory; copy or upload it.
- **BuildContext:** `WebUiSettings(context:)` — don't `await` anything between the `mounted` check and `cropImage`
  (lint `use_build_context_synchronously`).

### 4. Android: recover after process death
Android can kill the app while uCrop is open:
```dart
@override
void initState() {
  super.initState();
  ImageCropper().recoverImage().then((file) { /* show file if not null */ });
}
```

### 5. Demo — `lib/media/image_crop_page.dart`
**Home → Demos → Crop image**: gallery/camera → crop (free ratios or a locked 1:1 circle) → preview with the
cropped vs. original size.

## Notes
- Compress after cropping for uploads ([018](018-add-image-compress.md)).
- Web: the crop dialog is built with legacy `flutter/material` widgets — it works through the legacy
  localizations in `appLocalizationDelegates` ([027](027-add-pinput.md)) but uses the default Material look.
