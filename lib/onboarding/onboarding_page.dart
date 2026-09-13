import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n_extension.dart';
import '../storage/hive/hive_setup.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  static const completedKey = 'onboardingCompleted';

  /// A real app checks this in a go_router redirect on first launch (see docs).
  static bool get isCompleted =>
      Hive.isBoxOpen(HiveBoxes.settings) &&
      Hive.box<String>(HiveBoxes.settings).get(completedKey) == 'true';

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // introduction_screen 3.1.6: override* buttons are plain widgets → drive the pages via its state.
  final _introKey = GlobalKey<IntroductionScreenState>();

  Future<void> _finish() async {
    if (Hive.isBoxOpen(HiveBoxes.settings)) {
      await Hive.box<String>(HiveBoxes.settings).put(OnboardingPage.completedKey, 'true');
    }
    if (mounted) await Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    // Its internal widgets use package:flutter/material's fallback theme → pass colors/styles explicitly.
    final decoration = PageDecoration(
      titleTextStyle: theme.textTheme.headlineMedium!.copyWith(color: colors.onSurface),
      bodyTextStyle: theme.textTheme.bodyLarge!.copyWith(color: colors.onSurfaceVariant),
      pageColor: colors.surface,
      imagePadding: const EdgeInsets.only(top: 48),
    );

    PageViewModel page(IconData icon, String title, String body) => PageViewModel(
          title: title,
          body: body,
          image: Icon(icon, size: 140, color: colors.primary),
          decoration: decoration,
        );

    return IntroductionScreen(
      key: _introKey,
      globalBackgroundColor: colors.surface,
      pages: [
        page(Icons.waving_hand, l10n.onboardingPage1Title, l10n.onboardingPage1Body),
        page(Icons.devices, l10n.onboardingPage2Title, l10n.onboardingPage2Body),
        page(Icons.rocket_launch, l10n.onboardingPage3Title, l10n.onboardingPage3Body),
      ],
      showSkipButton: true,
      overrideSkip: TextButton(
        onPressed: () => _introKey.currentState?.skipToEnd(),
        child: Text(l10n.skip),
      ),
      overrideNext: TextButton(
        onPressed: () => _introKey.currentState?.next(),
        child: Text(l10n.next),
      ),
      overrideDone: FilledButton(onPressed: _finish, child: Text(l10n.done)),
      onDone: _finish,
      dotsDecorator: DotsDecorator(
        color: colors.outlineVariant,
        activeColor: colors.primary,
        size: const Size.square(10),
        activeSize: const Size(22, 10),
        activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      controlsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
    );
  }
}
