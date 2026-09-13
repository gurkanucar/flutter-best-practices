# Instagram-style Stories with story_view

Uses [`story_view`](https://pub.dev/packages/story_view) **0.16.x** — full-screen or inline stories with progress
bars, tap to skip, hold to pause.

| Item | Android | iOS | macOS | Windows | Linux | Web |
|---|:-:|:-:|:-:|:-:|:-:|:-:|
| text, asset/memory image | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| network image (`pageImage`) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| video (`pageVideo`) | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |

Video uses `video_player` (no Windows/Linux) and `dart:io` files (no web).

## Steps

### 1. Add dependency
```bash
flutter pub add story_view
```
Network items download through `flutter_cache_manager`:
- **Android:** `INTERNET` in `src/main/AndroidManifest.xml` (Flutter's template has it only for debug).
- **macOS:** `com.apple.security.network.client` in both entitlements files.
- **iOS:** HTTPS URLs work; `http://` needs an ATS exception.

The package uses `flutter/material` widgets internally but doesn't read the theme — works in the material_ui app.

### 2. Items and controller
```dart
final controller = StoryController();   // StoryView does NOT dispose it → dispose in your State

final items = [
  StoryItem.text(title: 'Welcome!', backgroundColor: colors.primary),                // 3 s default
  StoryItem.pageImage(
    url: 'https://example.com/1.jpg',
    controller: controller,              // pauses the story until the image is loaded
    imageFit: BoxFit.cover,
    caption: const Text('Caption', style: TextStyle(color: Colors.white)),
  ),
  StoryItem.pageProviderImage(const AssetImage('assets/icon/icon.png')),             // asset / MemoryImage
  StoryItem.pageVideo(
    'https://example.com/clip.mp4',
    controller: controller,
    duration: const Duration(seconds: 7),  // progress bar length — not read from the video
  ),
];
```
**Create the items once** (`initState` / `didChangeDependencies`), not in `build`: StoryView keeps the playback
state (`shown`) on them, and rebuilding restarts the story.

### 3. Viewer
```dart
StoryView(
  storyItems: items,
  controller: controller,
  onComplete: () => Navigator.of(context).maybePop(),
  onVerticalSwipeComplete: (direction) {
    if (direction == Direction.down) Navigator.of(context).maybePop();
  },
  onStoryShow: (item, index) => markSeen(index),   // e.g. report "seen" to the backend
  indicatorHeight: IndicatorHeight.medium,
  repeat: false,
)
```
Control it from your own buttons: `controller.pause()`, `play()`, `next()`, `previous()`.
`StoryView` has no `key` parameter — wrap it in `KeyedSubtree` to force a restart.

### 4. Routing
Open the viewer as a full-screen route with the story group in the path, so deep links work
([020](020-add-go-router.md)):
```dart
GoRoute(
  path: '/demos/stories/:groupId',
  builder: (context, state) => StoryViewerPage(group: StoryGroup.fromName(state.pathParameters['groupId'])),
),
// open: await context.push(Routes.storyViewerFor('photos'));  → then mark the ring as seen
```

### 5. Demo — `lib/stories/`
**Home → Demos → Stories**: avatar row with gradient (unseen) / grey (seen) rings. "Welcome" = text + asset image,
"Photos" = network images + a video on Android/iOS/macOS. Swipe down or tap ✕ to close.

## Notes
- Close guard: `onComplete` and the close button can both fire — pop only once (see `_closed` in the demo).
- Preload the next group's images (`precacheImage` / `DefaultCacheManager().downloadFile`) for instant starts.
- The package is maintained slowly (last release mid-2025); for heavy video use consider a custom `PageView` +
  `video_player`.
