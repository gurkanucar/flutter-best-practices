import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:story_view/story_view.dart';

import '../l10n/app_localizations.dart';
import '../l10n/l10n_extension.dart';

enum StoryGroup {
  welcome(Icons.waving_hand),
  photos(Icons.photo_library);

  const StoryGroup(this.icon);

  final IconData icon;

  String title(AppLocalizations l10n) => switch (this) {
        StoryGroup.welcome => l10n.storyGroupWelcome,
        StoryGroup.photos => l10n.storyGroupPhotos,
      };

  static StoryGroup fromName(String? name) => values.firstWhere((group) => group.name == name, orElse: () => welcome);
}

class StoryViewerPage extends StatefulWidget {
  const StoryViewerPage({super.key, required this.group});

  final StoryGroup group;

  /// StoryItem.pageVideo uses video_player + dart:io → Android, iOS and macOS only.
  static bool get videoSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  @override
  State<StoryViewerPage> createState() => _StoryViewerPageState();
}

class _StoryViewerPageState extends State<StoryViewerPage> {
  // StoryView doesn't dispose the controller — we own it.
  final _controller = StoryController();
  List<StoryItem>? _items;
  bool _closed = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Build the items once: StoryView keeps playback state (`shown`) on them.
    _items ??= _buildItems(context.l10n, Theme.of(context).colorScheme);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<StoryItem> _buildItems(AppLocalizations l10n, ColorScheme colors) {
    const captionStyle = TextStyle(color: Color(0xFFFFFFFF), fontSize: 16);

    return switch (widget.group) {
      StoryGroup.welcome => [
          StoryItem.text(title: l10n.storyWelcome, backgroundColor: colors.primary),
          StoryItem.text(
            title: l10n.storyHowTo,
            backgroundColor: colors.tertiary,
            duration: const Duration(seconds: 6),
          ),
          // Assets / memory images: ImageProvider-based items, no controller needed.
          StoryItem.pageProviderImage(
            const AssetImage('assets/icon/icon.png'),
            imageFit: BoxFit.contain,
            caption: l10n.storyAssetCaption,
          ),
        ],
      StoryGroup.photos => [
          // URL items download through flutter_cache_manager and pause the story until loaded.
          StoryItem.pageImage(
            url: 'https://picsum.photos/id/1018/1080/1920',
            controller: _controller,
            imageFit: BoxFit.cover,
            caption: Text(l10n.storyCaptionMountains, style: captionStyle),
          ),
          StoryItem.pageImage(
            url: 'https://picsum.photos/id/1043/1080/1920',
            controller: _controller,
            imageFit: BoxFit.cover,
            caption: Text(l10n.storyCaptionCity, style: captionStyle),
          ),
          if (StoryViewerPage.videoSupported)
            StoryItem.pageVideo(
              'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4',
              controller: _controller,
              // The progress bar uses this duration, not the real video length.
              duration: const Duration(seconds: 7),
              caption: Text(l10n.storyCaptionVideo, style: captionStyle),
            ),
        ],
    };
  }

  void _close() {
    if (_closed || !mounted) return;
    _closed = true;
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Stack(
          children: [
            StoryView(
              storyItems: _items!,
              controller: _controller,
              onComplete: _close,
              onVerticalSwipeComplete: (direction) {
                if (direction == Direction.down) _close();
              },
              indicatorHeight: IndicatorHeight.medium,
            ),
            PositionedDirectional(
              top: 20,
              end: 8,
              child: IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                icon: const Icon(Icons.close, color: Color(0xFFFFFFFF)),
                onPressed: _close,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
