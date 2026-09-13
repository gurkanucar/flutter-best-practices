import 'package:ditredi/ditredi.dart';
import 'package:material_ui/material_ui.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

import '../l10n/l10n_extension.dart';

/// 3D demo with ditredi (flutter_cube replacement: pure Dart canvas renderer, all platforms).
class ThreeDPage extends StatefulWidget {
  const ThreeDPage({super.key});

  static const torusAsset = 'assets/3d/torus.obj'; // declared in pubspec.yaml

  @override
  State<ThreeDPage> createState() => _ThreeDPageState();
}

enum _Scene { cube, model }

class _ThreeDPageState extends State<ThreeDPage> {
  final _controller = DiTreDiController(rotationX: -20, rotationY: 30);
  late final Future<List<Face3D>> _torus = ObjParser().loadFromResources(ThreeDPage.torusAsset);
  _Scene _scene = _Scene.model;

  void _resetView() => _controller.update(rotationX: -20, rotationY: 30, rotationZ: 0, userScale: 1);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.threeDTitle),
        actions: [
          IconButton(icon: const Icon(Icons.center_focus_strong), tooltip: l10n.threeDReset, onPressed: _resetView),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedButton<_Scene>(
              segments: [
                ButtonSegment(value: _Scene.cube, label: Text(l10n.threeDCube), icon: const Icon(Icons.crop_square)),
                ButtonSegment(value: _Scene.model, label: Text(l10n.threeDModel), icon: const Icon(Icons.donut_large)),
              ],
              selected: {_scene},
              onSelectionChanged: (selection) => setState(() => _scene = selection.first),
            ),
          ),
          Expanded(
            // Drag to rotate, pinch / mouse wheel to zoom.
            child: DiTreDiDraggable(
              controller: _controller,
              child: switch (_scene) {
                _Scene.cube => DiTreDi(
                    controller: _controller,
                    figures: [Cube3D(2, vector.Vector3.zero())],
                  ),
                _Scene.model => FutureBuilder<List<Face3D>>(
                    future: _torus, // parsed once, not in build
                    builder: (context, snapshot) {
                      if (snapshot.hasError) return Center(child: Text(l10n.loadError('${snapshot.error}')));
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      return DiTreDi(controller: _controller, figures: [Mesh3D(snapshot.requireData)]);
                    },
                  ),
              },
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: Text(l10n.threeDHint)),
        ],
      ),
    );
  }
}
