# 3D Shapes and OBJ Models with ditredi

Uses [`ditredi`](https://pub.dev/packages/ditredi) **2.0.x** — a pure-Dart 3D renderer (Canvas) for points,
lines, cubes and meshes, with drag-to-rotate and zoom.

| Android | iOS | macOS | Windows | Linux | Web |
|:-:|:-:|:-:|:-:|:-:|:-:|
| ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

## Why not flutter_cube
[`flutter_cube`](https://pub.dev/packages/flutter_cube) was requested first, but its last release (0.1.1) is not
null-safe, and Dart 3 only runs null-safe code — `flutter pub add flutter_cube` fails at version solving.
ditredi is maintained, null-safe, and has no native code.

**When you need more:** ditredi draws flat-shaded triangles on a `Canvas` — no textures, no GLTF, no PBR, and
performance drops beyond a few thousand faces. For textured GLB/GLTF models use
[`model_viewer_plus`](https://pub.dev/packages/model_viewer_plus) (WebView-based; Android/iOS/web) or
[`flutter_scene`](https://pub.dev/packages/flutter_scene) (Impeller, experimental).

## Steps

### 1. Add dependencies
```bash
flutter pub add ditredi vector_math
```
`vector_math` is added explicitly because we import `Vector3` from it (`depend_on_referenced_packages`).

### 2. Asset
`pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/3d/torus.obj
```
The OBJ needs `v` (vertex) and `f` (face) lines; materials (`.mtl`) and textures are ignored.

### 3. Controller and scene
```dart
import 'package:ditredi/ditredi.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;

final _controller = DiTreDiController(
  rotationX: -20,
  rotationY: 30,
  light: Vector3(-0.5, -0.5, 0.5),
  maxUserScale: 5,
);
late final Future<List<Face3D>> _model = ObjParser().loadFromResources('assets/3d/torus.obj');

DiTreDiDraggable(                     // drag = rotate, pinch / scroll = zoom
  controller: _controller,
  child: DiTreDi(
    controller: _controller,
    figures: [Cube3D(2, Vector3.zero(), color: colors.primary)],
    // or: [Mesh3D(faces)]  (faces from the FutureBuilder)
    config: const DiTreDiConfig(supportZIndex: true),
  ),
)
```
Other figures: `Point3D`, `Line3D`, `Face3D`, `Group3D`, `TransformModifier3D` (move/rotate/scale a figure).

Reset the view:
```dart
_controller.update(rotationX: -20, rotationY: 30, rotationZ: 0, userScale: 1);
```

### 4. Demo — `lib/three_d/three_d_page.dart`
**Home → Demos → 3D**: a `SegmentedButton` switches between a cube and the torus OBJ
(`assets/3d/torus.obj`, 512 vertices / 1024 faces); drag to rotate, pinch or scroll to zoom, "Reset view".

## Notes
- Load models once (`late final Future`) — not inside `build`.
- `ObjParser().parse(String)` for downloaded models, `loadFromFile(Uri)` on non-web platforms.
- Keep meshes small (≲ 5k faces) for smooth dragging on low-end phones; decimate in Blender if needed.
