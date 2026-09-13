# Tilt, Light and Parallax Effects with flutter_tilt

Uses [`flutter_tilt`](https://pub.dev/packages/flutter_tilt) **4.x** — 3D tilt on hover, touch or device
motion, with light, shadow and parallax layers.

| | Pointer / touch | Gyroscope |
|---|:-:|:-:|
| Android | ✅ | ✅ |
| iOS | ✅ | ✅ |
| Web | ✅ | ✅ (mobile browsers) |
| macOS / Windows / Linux | ✅ | ❌ |

Sensors come from `sensors_plus`.

## Steps

### 1. Add dependency
```bash
flutter pub add flutter_tilt
```

### 2. Platform setup
**iOS** — `ios/Runner/Info.plist` (motion access via `sensors_plus`):
```xml
<key>NSMotionUsageDescription</key>
<string>Tilt cards by moving your phone.</string>
```
Nothing else. The package has no `flutter/material.dart` dependency, so it works in the material_ui app as is.

### 3. Simple tilt
```dart
import 'package:flutter_tilt/flutter_tilt.dart';

Tilt(
  borderRadius: BorderRadius.circular(24),
  tiltConfig: const TiltConfig(angle: 15, leaveCurve: Curves.easeOutBack),
  child: const ProductCard(),
)
```
`Tilt` includes light and shadow by default; `Tilt.base` gives full control of the layers.

### 4. Layers and parallax
```dart
Tilt.base(
  tiltConfig: TiltConfig(
    angle: 15,
    enableGestureSensors: useSensors,        // gyroscope on Android/iOS/web
    leaveDuration: const Duration(milliseconds: 600),
  ),
  borderRadius: BorderRadius.circular(24),
  lightConfig: const LightConfig(maxIntensity: 0.35),
  shadowConfig: const ShadowBaseConfig(maxIntensity: 0.4),
  childLayout: ChildLayout(
    inner: [                                  // above the child, clipped to it
      TiltParallax(offset: const Offset(-18, -18), child: logo),
      TiltParallax(offset: const Offset(10, 10), child: caption),
    ],
    // outer: [...]   above, not clipped
    // behind: [...]  below the child
  ),
  child: gradientCard,
)
```
Different `TiltParallax` offsets move the layers at different speeds → depth.

### 5. Control it
```dart
final controller = TiltController();       // dispose() it
Tilt(tiltController: controller, ...);
controller.move(...);  controller.leave(); // e.g. drive the tilt from a slider or animation
```
Also: `disable: true`, `onGestureMove` / `onGestureLeave` callbacks, `TiltConfig(enableReverse:, enableRevert:)`.

### 6. Demo — `lib/tilt/tilt_page.dart`
**Home → Demos → Tilt effect**: gradient card with two parallax layers; a switch enables device sensors (disabled
on desktop).

## Notes
- The effect is decorative: respect reduced motion — check `MediaQuery.disableAnimationsOf(context)` and pass
  `disable: true`.
- Many simultaneous sensor-driven tilts (e.g. a long grid) cost battery and frames — enable sensors only for the
  focused card.
