# Onboarding with introduction_screen

Uses [`introduction_screen`](https://pub.dev/packages/introduction_screen) **3.1.x** — swipeable intro pages
with dots, Skip / Next / Done.

| Android | iOS | macOS | Windows | Linux | Web |
|:-:|:-:|:-:|:-:|:-:|:-:|
| ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

## Why 3.1.6 and not 4.0.0
4.0.0 requires `flutter_keyboard_visibility` **^8**, which conflicts with this project's
`flutter_keyboard_visibility` **7** ([012](012-add-keyboard-visibility.md)). Pin 3.1.x until that is upgraded:
```bash
flutter pub add introduction_screen:^3.1.6
```
In 4.x the `override*` parameters are builders that receive the tap callback; in 3.1.x they are plain widgets
(see step 3).

## Steps

### 1. Pages
```dart
PageViewModel(
  title: l10n.onboardingPage1Title,          // or titleWidget:
  body: l10n.onboardingPage1Body,            // or bodyWidget:
  image: Icon(Icons.waving_hand, size: 140, color: colors.primary),  // Image.asset / SvgPicture / Lottie
  decoration: PageDecoration(
    titleTextStyle: theme.textTheme.headlineMedium!.copyWith(color: colors.onSurface),
    bodyTextStyle: theme.textTheme.bodyLarge!.copyWith(color: colors.onSurfaceVariant),
    pageColor: colors.surface,
  ),
)
```

### 2. material_ui notes (this project)
The package builds on `flutter/material.dart` and brings its own legacy `Scaffold`, so it **doesn't crash**
inside a material_ui app. But its defaults read the legacy fallback theme (not our theme), so pass colors
explicitly: `PageDecoration` text styles / `pageColor`, `globalBackgroundColor`, `DotsDecorator.activeColor`.

### 3. Screen with themed buttons
```dart
final _introKey = GlobalKey<IntroductionScreenState>();

IntroductionScreen(
  key: _introKey,
  pages: pages,
  globalBackgroundColor: colors.surface,
  showSkipButton: true,
  // 3.1.x: override* are plain widgets → drive navigation through the state.
  overrideSkip: TextButton(onPressed: () => _introKey.currentState?.skipToEnd(), child: Text(l10n.skip)),
  overrideNext: TextButton(onPressed: () => _introKey.currentState?.next(), child: Text(l10n.next)),
  overrideDone: FilledButton(onPressed: _finish, child: Text(l10n.done)),
  onDone: _finish,                  // assert: required when `done`/`overrideDone` is set
  dotsDecorator: DotsDecorator(     // re-exported by introduction_screen, no extra import
    color: colors.outlineVariant,
    activeColor: colors.primary,
    activeSize: const Size(22, 10),
    activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
  ),
)
```
Without overrides use `skip: Text(...)`, `next: Icon(...)`, `done: Text(...)` (`next` is required while
`showNextButton` is true). Other state methods: `previous()`, `animateScroll(page)`.

### 4. Show it only once
```dart
Future<void> _finish() async {
  await Hive.box<String>(HiveBoxes.settings).put('onboardingCompleted', 'true');
  if (mounted) await Navigator.of(context).maybePop();   // or context.go(Routes.home)
}
```
In a real app, route to it from a `go_router` redirect ([020](020-add-go-router.md)):
```dart
redirect: (context, state) {
  if (!OnboardingPage.isCompleted && state.matchedLocation != Routes.onboarding) return Routes.onboarding;
  return null;
},
```

### 5. Demo — `lib/onboarding/onboarding_page.dart`
**Home → Demos → Onboarding**: three pages; Done saves the flag and closes the page (the demo opens from Home, so
it doesn't redirect). Test: `test/onboarding_test.dart` (Next → Next → Done, and Skip).

## Notes
- Keep it short (≤ 3–4 pages) and always allow skipping.
- Ask for permissions on the page that explains them, not all at start-up.
