import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../l10n/l10n_extension.dart';

class ViewerImage {
  const ViewerImage({required this.bytes, required this.label});

  final Uint8List bytes;
  final String label;
}

class PhotoViewerArgs {
  const PhotoViewerArgs({required this.images, this.initialIndex = 0});

  final List<ViewerImage> images;
  final int initialIndex;
}

/// Full-screen zoomable gallery (pinch, double-tap, swipe between images).
class PhotoViewerPage extends StatefulWidget {
  const PhotoViewerPage({super.key, required this.args});

  /// `null` when opened without `extra` (deep link / web refresh).
  final PhotoViewerArgs? args;

  @override
  State<PhotoViewerPage> createState() => _PhotoViewerPageState();
}

class _PhotoViewerPageState extends State<PhotoViewerPage> {
  late int _index = widget.args?.initialIndex ?? 0;
  late final _pageController = PageController(initialPage: _index);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final images = widget.args?.images ?? const <ViewerImage>[];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(images.isEmpty ? l10n.photoViewerTitle : images[_index].label),
      ),
      body: images.isEmpty
          ? Center(child: Text(l10n.noImageSelected, style: const TextStyle(color: Colors.white)))
          : PhotoViewGallery.builder(
              itemCount: images.length,
              pageController: _pageController,
              onPageChanged: (index) => setState(() => _index = index),
              // photo_view still uses package:flutter/material.dart; a custom loadingBuilder
              // avoids its legacy progress indicator (no MaterialUiCompatibilityBridge needed).
              loadingBuilder: (context, event) => const Center(child: CircularProgressIndicator()),
              builder: (context, index) => PhotoViewGalleryPageOptions(
                imageProvider: MemoryImage(images[index].bytes),
                heroAttributes: PhotoViewHeroAttributes(tag: 'image-$index'),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 4,
              ),
            ),
    );
  }
}
