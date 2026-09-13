# React to Keyboard Visibility

Uses [`flutter_keyboard_visibility`](https://pub.dev/packages/flutter_keyboard_visibility) **7.x** —
know when the on-screen keyboard opens/closes and dismiss it by tapping outside a field.

| Android | iOS | macOS | Windows | Linux | Web |
|:-:|:-:|:-:|:-:|:-:|:-:|
| ✅ | ✅ | always `false` | always `false` | always `false` | always `false` |

Desktop has no soft keyboard; on web the package currently always reports `false`.

## Steps

### 1. Add dependency
```bash
flutter pub add flutter_keyboard_visibility
```
No native setup. v7 builds with AGP 9 / Java 17 (older 5.x/6.x forks had Android namespace issues).

### 2. Dismiss keyboard on outside tap
```dart
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

return KeyboardDismissOnTap(
  child: Scaffold(...),
);
```
- By default taps on buttons/other interactive widgets are **not** treated as "outside".
  `dismissOnCapturedTaps: true` dismisses on every tap.
- `IgnoreKeyboardDismiss(child: ...)` excludes an area (e.g. an emoji bar above the keyboard).
- App-wide alternative — every route gets it:
  ```dart
  MaterialApp(
    builder: (context, child) => KeyboardDismissOnTap(child: child!),
    ...
  )
  ```

### 3. Rebuild on visibility change
**a) Builder** (local, simplest):
```dart
KeyboardVisibilityBuilder(
  builder: (context, isKeyboardVisible) => isKeyboardVisible
      ? const SizedBox.shrink()                 // hide hint/illustration/footer
      : Text(l10n.keyboardTip),
)
```

**b) Provider** (read anywhere below it):
```dart
KeyboardVisibilityProvider(child: const MyPage());

// inside MyPage
final isKeyboardVisible = KeyboardVisibilityProvider.isKeyboardVisible(context);
```

**c) Controller** (non-widget code, side effects):
```dart
final controller = KeyboardVisibilityController();
late final StreamSubscription<bool> _subscription;

@override
void initState() {
  super.initState();
  debugPrint('visible now: ${controller.isVisible}');
  _subscription = controller.onChange.listen((visible) {
    if (!visible) _saveDraft();
  });
}

@override
void dispose() {
  _subscription.cancel();
  super.dispose();
}
```

## In this project — `lib/forms/sign_up_form_page.dart`
**Home → Demos → Sign-up form** ([013](013-add-form-builder.md)):
- The whole page is wrapped in `KeyboardDismissOnTap`.
- App bar icon switches between `Icons.keyboard` / `Icons.keyboard_hide`.
- The "Tap outside a field to close the keyboard." hint is hidden while the keyboard is open.

## Do you need the package?
For simple cases Flutter can do it without a dependency:
```dart
final isKeyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;   // rebuilds on change
FocusManager.instance.primaryFocus?.unfocus();                           // close keyboard
```
Use the package when you want a stream/controller, the ready-made `KeyboardDismissOnTap`
(with `IgnoreKeyboardDismiss`), or easy test overrides. `viewInsets` can also be non-zero for
other reasons (e.g. floating keyboards, some tablets), so treat it as an approximation.

## Testing
```dart
setUp(() => KeyboardVisibilityTesting.setVisibilityForTesting(false));

testWidgets('keyboard tip is hidden while the keyboard is visible', (tester) async {
  KeyboardVisibilityTesting.setVisibilityForTesting(true);
  await tester.pumpWidget(wrap(const SignUpFormPage()));
  await tester.pumpAndSettle();
  expect(find.text('Tap outside a field to close the keyboard.'), findsNothing);
});
```
The override is **global** — reset it in `setUp`. Builders/providers also accept a `controller:` for mocks.

## Notes
- `Scaffold(resizeToAvoidBottomInset: true)` (default) already moves content up; this package is for
  *reacting* (hide/show widgets, save drafts), not for layout.
- Hiding widgets that contain the focused field will close the keyboard — only hide decoration.
