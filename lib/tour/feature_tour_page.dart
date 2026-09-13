import 'package:material_ui/material_ui.dart';
import 'package:showcaseview/showcaseview.dart';

import '../l10n/l10n_extension.dart';

/// showcaseview 5.x: `ShowcaseView.register` (no ShowCaseWidget wrapper anymore).
class FeatureTourPage extends StatefulWidget {
  const FeatureTourPage({super.key});

  /// Named scope so this page's tour doesn't collide with tours on other pages.
  static const scope = 'featureTour';

  @override
  State<FeatureTourPage> createState() => _FeatureTourPageState();
}

class _FeatureTourPageState extends State<FeatureTourPage> {
  final _searchKey = GlobalKey();
  final _firstItemKey = GlobalKey();
  final _fabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    ShowcaseView.register(
      scope: FeatureTourPage.scope,
      blurValue: 1,
      enableAutoScroll: true,
      onFinish: () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.tourFinished)));
      },
    );
    // Start after the first frame, when the target widgets have a size.
    // A real app starts it only once (store a "tour seen" flag, e.g. in Hive).
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  @override
  void dispose() {
    ShowcaseView.getNamed(FeatureTourPage.scope).unregister();
    super.dispose();
  }

  void _start() =>
      ShowcaseView.getNamed(FeatureTourPage.scope).startShowCase([_searchKey, _firstItemKey, _fabKey]);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Defaults come from flutter/material's fallback theme → style explicitly.
    final actions = [
      TooltipActionButton(
        type: TooltipDefaultActionType.previous,
        name: l10n.previous,
        backgroundColor: colors.secondaryContainer,
        textStyle: TextStyle(color: colors.onSecondaryContainer),
      ),
      TooltipActionButton(
        type: TooltipDefaultActionType.next,
        name: l10n.next,
        backgroundColor: colors.primary,
        textStyle: TextStyle(color: colors.onPrimary),
      ),
      TooltipActionButton(
        type: TooltipDefaultActionType.skip,
        name: l10n.skip,
        backgroundColor: Colors.transparent,
        textStyle: TextStyle(color: colors.primary),
      ),
    ];

    Showcase step({
      required GlobalKey key,
      required String title,
      required String description,
      required Widget child,
      ShapeBorder shape = const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    }) {
      return Showcase(
        key: key,
        scope: FeatureTourPage.scope,
        title: title,
        description: description,
        titleTextStyle: theme.textTheme.titleMedium!.copyWith(color: colors.onSurface),
        descTextStyle: theme.textTheme.bodyMedium!.copyWith(color: colors.onSurfaceVariant),
        tooltipBackgroundColor: colors.surfaceContainerHigh,
        targetShapeBorder: shape,
        tooltipActions: actions,
        child: child,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tourTitle),
        actions: [
          step(
            key: _searchKey,
            title: l10n.tourSearchTitle,
            description: l10n.tourSearchBody,
            shape: const CircleBorder(),
            child: IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FilledButton.icon(icon: const Icon(Icons.replay), label: Text(l10n.tourStart), onPressed: _start),
          const SizedBox(height: 16),
          for (var number = 1; number <= 6; number++)
            number == 1
                ? step(
                    key: _firstItemKey,
                    title: l10n.tourListTitle,
                    description: l10n.tourListBody,
                    child: ListTile(
                      leading: const Icon(Icons.article),
                      title: Text(l10n.tourItem(number)),
                      onTap: () {},
                    ),
                  )
                : ListTile(leading: const Icon(Icons.article), title: Text(l10n.tourItem(number)), onTap: () {}),
        ],
      ),
      floatingActionButton: step(
        key: _fabKey,
        title: l10n.tourFabTitle,
        description: l10n.tourFabBody,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
        child: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
      ),
    );
  }
}
