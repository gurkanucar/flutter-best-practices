import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n_extension.dart';
import '../router/routes.dart';
import 'byte_size.dart';
import 'photo_viewer_page.dart';

class ImageDemoPage extends StatefulWidget {
  const ImageDemoPage({super.key});

  /// flutter_image_compress has no Windows/Linux implementation.
  static bool get compressionSupported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  @override
  State<ImageDemoPage> createState() => _ImageDemoPageState();
}

class _ImageDemoPageState extends State<ImageDemoPage> {
  final _picker = ImagePicker();
  Uint8List? _original;
  Uint8List? _compressed;
  bool _busy = false;

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(source: source); // null = user cancelled
    if (file == null) return;

    setState(() => _busy = true);
    try {
      // readAsBytes works on every platform (on web XFile.path is a blob: URL).
      final original = await file.readAsBytes();
      final compressed = ImageDemoPage.compressionSupported
          ? await FlutterImageCompress.compressWithList(
              original,
              minWidth: 1280, // upper bounds, aspect ratio kept, never upscales
              minHeight: 1280,
              quality: 70,
              format: CompressFormat.jpeg,
            )
          : null;
      if (!mounted) return;
      setState(() {
        _original = original;
        _compressed = compressed;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openViewer(int initialIndex) {
    final l10n = context.l10n;
    final images = [
      if (_original != null) ViewerImage(bytes: _original!, label: l10n.imageOriginal(formatBytes(_original!.length))),
      if (_compressed != null)
        ViewerImage(bytes: _compressed!, label: l10n.imageCompressed(formatBytes(_compressed!.length), savedPercent(original: _original!.length, compressed: _compressed!.length))),
    ];
    // Bytes can't go into a URL → `extra`. The viewer handles a missing extra (e.g. web refresh).
    context.push(Routes.photoViewer, extra: PhotoViewerArgs(images: images, initialIndex: initialIndex));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final original = _original;
    final compressed = _compressed;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.imagesTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                icon: const Icon(Icons.photo_library),
                label: Text(l10n.pickFromGallery),
                onPressed: _busy ? null : () => _pick(ImageSource.gallery),
              ),
              // Desktop has no camera source unless a cameraDelegate is registered.
              if (_picker.supportsImageSource(ImageSource.camera))
                OutlinedButton.icon(
                  icon: const Icon(Icons.photo_camera),
                  label: Text(l10n.pickFromCamera),
                  onPressed: _busy ? null : () => _pick(ImageSource.camera),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_busy) const LinearProgressIndicator(),
          if (!ImageDemoPage.compressionSupported) Text(l10n.compressUnsupported),
          if (original == null && !_busy) Text(l10n.noImageSelected),
          if (original != null) ...[
            Text(l10n.tapToZoom),
            const SizedBox(height: 8),
            _Thumbnail(
              bytes: original,
              label: l10n.imageOriginal(formatBytes(original.length)),
              heroTag: 'image-0',
              onTap: () => _openViewer(0),
            ),
          ],
          if (original != null && compressed != null) ...[
            const SizedBox(height: 16),
            _Thumbnail(
              bytes: compressed,
              label: l10n.imageCompressed(
                formatBytes(compressed.length),
                savedPercent(original: original.length, compressed: compressed.length),
              ),
              heroTag: 'image-1',
              onTap: () => _openViewer(1),
            ),
          ],
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.bytes, required this.label, required this.heroTag, required this.onTap});

  final Uint8List bytes;
  final String label;
  final String heroTag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 4),
        InkWell(
          onTap: onTap,
          child: Hero(
            tag: heroTag,
            child: Image.memory(bytes, height: 200, fit: BoxFit.cover, gaplessPlayback: true),
          ),
        ),
      ],
    );
  }
}
