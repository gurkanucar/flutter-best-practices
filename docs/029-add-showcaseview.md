# Feature Tours with showcaseview

Uses [`showcaseview`](https://pub.dev/packages/showcaseview) **5.x** — highlight widgets step by step with a
tooltip ("coach marks").

| Android | iOS | macOS | Windows | Linux | Web |
|:-:|:-:|:-:|:-:|:-:|:-:|
| ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

## Steps

### 1. Add dependency
```bash
flutter pub add showcaseview
```

### 2. Register, start, unregister (v5 API)
v5 removed the `ShowCaseWidget` wrapper and `ShowCaseWidget.of(context)`. Register a `ShowcaseView` in the
page state instead:
```dart
import 'package:showcaseview/showcaseview.dart';

class _FeatureTourPageState extends State<FeatureTourPage> {
  static const scope = 'featureTour';
  final _searchKey = GlobalKey();
  final _firstItemKey = GlobalKey();
  final _fabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    ShowcaseView.register(
      scope: scope,                 // named scope: tours on different pages don't collide
      enableAutoScroll: true,       // scroll off-screen targets into view
      onFinish: () { /* save "tour seen" */ },
    );
    // Targets need a size → start after the first frame.
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ShowcaseView.getNamed(scope).startShowCase([_searchKey, _firstItemKey, _fabKey]),
    );
  }

  @override
  void dispose() {
    ShowcaseView.getNamed(scope).unregister();
    super.dispose();
  }
}
```
Without a scope use `ShowcaseView.register()` / `ShowcaseView.get()`.

### 3. Wrap targets
```dart
Showcase(
  key: _fabKey,
  scope: scope,
  title: l10n.tourFabTitle,
  description: l10n.tourFabBody,
  titleTextStyle: theme.textTheme.titleMedium!.copyWith(color: colors.onSurface),
  descTextStyle: theme.textTheme.bodyMedium!.copyWith(color: colors.onSurfaceVariant),
  tooltipBackgroundColor: colors.surfaceContainerHigh,
  targetShapeBorder: const CircleBorder(),            // highlight shape
  tooltipActions: [
    TooltipActionButton(type: TooltipDefaultActionType.previous, name: l10n.previous),
    TooltipActionButton(type: TooltipDefaultActionType.next, name: l10n.next),
    TooltipActionButton(type: TooltipDefaultActionType.skip, name: l10n.skip),
  ],
  child: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
)
```
- `name:` localizes the default action labels (English otherwise).
- `TooltipActionButton.custom(button: ...)` for a fully custom button.
- `Showcase.withWidget(container: ..., height:, width:)` for a completely custom tooltip.

### 4. material_ui notes (this project)
Works inside the material_ui app without wrappers (tested). Its defaults read the legacy fallback theme, so set
`titleTextStyle`, `descTextStyle`, `tooltipBackgroundColor` and the action button colors from our theme —
otherwise the tooltip ignores dark mode.

### 5. Demo — `lib/tour/feature_tour_page.dart`
**Home → Demos → Feature tour**: the tour starts automatically (search icon → first list item → FAB); "Start
tour" restarts it; a snackbar shows when finished.

## Show once
Store a flag when `onFinish` / `onDismiss` fires (Hive, [021](021-add-hive.md)) and only call
`startShowCase` if it isn't set. Bump a version number in the key when you add new steps later.

## Notes
- Each `GlobalKey` must be attached to exactly one mounted `Showcase` when the tour starts.
- Don't start the tour on top of a dialog or during a route transition — wait for the post-frame callback.
