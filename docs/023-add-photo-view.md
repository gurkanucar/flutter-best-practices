# Zoomable Images with photo_view

Uses [`photo_view`](https://pub.dev/packages/photo_view) **0.15.0** — pinch/double-tap zoom, pan, rotation and
swipeable galleries. Pure Flutter, all platforms.

> 0.15.0 is from **April 2024** and still imports `package:flutter/material.dart`. In this `material_ui` app it
> works because it doesn't need a Material ancestor — but pass your own `loadingBuilder` (its default spinner is the
> legacy Material one). If a future Flutter breaks it, alternatives: `InteractiveViewer` (built in) or
> `extended_image`.

## Steps

### 1. Add dependency
```bash
flutter pub add photo_view
```

### 2. Single image
```dart
import 'package:photo_view/photo_view.dart';

PhotoView(
  imageProvider: const AssetImage('assets/icon/icon.png'),   // NetworkImage, FileImage, MemoryImage...
  minScale: PhotoViewComputedScale.contained,
  maxScale: PhotoViewComputedScale.covered * 4,
  initialScale: PhotoViewComputedScale.contained,
  heroAttributes: const PhotoViewHeroAttributes(tag: 'avatar'),
  backgroundDecoration: const BoxDecoration(color: Colors.black),
  loadingBuilder: (context, event) => const Center(child: CircularProgressIndicator()),
  errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
)
```
Any widget: `PhotoView.customChild(child: MySvg(), childSize: const Size(400, 400))`.

### 3. Gallery — `lib/media/photo_viewer_page.dart`
```dart
import 'package:photo_view/photo_view_gallery.dart';

PhotoViewGallery.builder(
  itemCount: images.length,
  pageController: _pageController,
  onPageChanged: (index) => setState(() => _index = index),
  loadingBuilder: (context, event) => const Center(child: CircularProgressIndicator()),
  builder: (context, index) => PhotoViewGalleryPageOptions(
    imageProvider: MemoryImage(images[index].bytes),
    heroAttributes: PhotoViewHeroAttributes(tag: 'image-$index'),
    minScale: PhotoViewComputedScale.contained,
    maxScale: PhotoViewComputedScale.covered * 4,
  ),
)
```

### 4. Open it with a Hero animation
Thumbnail (`lib/media/image_demo_page.dart`):
```dart
InkWell(
  onTap: () => context.push(
    Routes.photoViewer,
    extra: PhotoViewerArgs(images: images, initialIndex: 0),   // bytes can't go into a URL
  ),
  child: Hero(tag: 'image-0', child: Image.memory(bytes, height: 200, fit: BoxFit.cover)),
)
```
Route (`lib/router/app_router.dart`):
```dart
GoRoute(
  path: Routes.photoViewer,
  builder: (context, state) => PhotoViewerPage(args: state.extra as PhotoViewerArgs?),
)
```
The viewer shows "No image selected" when `extra` is missing (web refresh / deep link) — see
[020](020-add-go-router.md#passing-data).

## Controllers
```dart
final controller = PhotoViewController();
final scaleController = PhotoViewScaleStateController();

PhotoView(imageProvider: provider, controller: controller, scaleStateController: scaleController);

controller.scale = 2;                          // zoom programmatically
controller.outputStateStream.listen((value) => debugPrint('${value.scale}'));
scaleController.scaleState = PhotoViewScaleState.initial;   // reset zoom
```
Dispose both in `dispose()`.

## Notes
- Put `PhotoView` in a widget with bounded size (full screen, `SizedBox`, `Expanded`) — unbounded constraints throw.
- In a `PageView`/`ListView` use `PhotoViewGallery` or the gestures fight each other.
- `enableRotation: true` for two-finger rotation.
- Big photos: resize first ([018](018-add-image-compress.md)) or use `ResizeImage(provider, width: 2000)`.
