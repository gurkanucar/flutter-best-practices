# OTP / PIN Input with pinput

Uses [`pinput`](https://pub.dev/packages/pinput) **6.0.x** — customizable code input with SMS autofill,
validation and themes. The demo uses the **"rounded filled"** style.

| Android | iOS | macOS | Windows | Linux | Web |
|:-:|:-:|:-:|:-:|:-:|:-:|
| ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

## Steps

### 1. Add dependency
```bash
flutter pub add pinput
```

### 2. material_ui compatibility (this project)
This app uses `package:material_ui` ([005](005-add-localization.md)). pinput is still built on
`package:flutter/material.dart` and asserts legacy ancestors. Tested results:

| Setup | Result |
|---|---|
| `Pinput` directly in a material_ui `Scaffold` | ❌ `No Material widget found` |
| + legacy `Material` wrapper | ❌ `No MaterialLocalizations found` |
| + legacy `Material` wrapper **and** `flutter_localizations` delegate | ✅ |

So two things are needed:

`lib/l10n/app_localization_delegates.dart`:
```dart
import 'package:flutter_localizations/flutter_localizations.dart' as legacy;

const appLocalizationDelegates = [
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,   // material_ui
  FormBuilderLocalizations.delegate,
  legacy.GlobalMaterialLocalizations.delegate, // legacy flutter/material
];
```

`lib/widgets/legacy_material_scope.dart`:
```dart
import 'package:flutter/material.dart' as legacy;

class LegacyMaterialScope extends StatelessWidget {
  const LegacyMaterialScope({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      legacy.Material(type: legacy.MaterialType.transparency, child: child);
}
```
In an app still on `flutter/material.dart` you need neither.

### 3. Rounded filled theme
```dart
final colors = Theme.of(context).colorScheme;

final defaultPinTheme = PinTheme(
  width: 56,
  height: 60,
  textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: colors.onSurface),
  decoration: BoxDecoration(
    color: colors.surfaceContainerHighest,       // template: Color.fromRGBO(222, 231, 240, .57)
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.transparent),
  ),
);
final focusedPinTheme = defaultPinTheme.copyWith(
  width: 64,
  height: 68,                                    // the focused pin grows
  decoration: defaultPinTheme.decoration!.copyWith(border: Border.all(color: colors.primary, width: 2)),
);
final submittedPinTheme = defaultPinTheme.copyDecorationWith(color: colors.primaryContainer);
final errorPinTheme = defaultPinTheme.copyDecorationWith(
  color: colors.errorContainer,
  border: Border.all(color: colors.error),
);
```
Using `colorScheme` instead of the template's fixed colors makes it work in dark mode.

### 4. The input
```dart
LegacyMaterialScope(
  child: Pinput(
    length: 4,
    controller: _codeController,
    focusNode: _codeFocus,
    autofocus: true,
    defaultPinTheme: defaultPinTheme,
    focusedPinTheme: focusedPinTheme,
    submittedPinTheme: submittedPinTheme,
    errorPinTheme: errorPinTheme,
    separatorBuilder: (index) => const SizedBox(width: 12),
    hapticFeedbackType: HapticFeedbackType.lightImpact,
    validator: (pin) => pin == '2222' ? null : l10n.otpInvalid,
    pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
    onCompleted: (pin) => verify(pin),
  ),
)
```
- `Pinput` is a `FormField` — inside a `Form`, `formKey.currentState!.validate()` runs its validator too.
- For server-side checks, set `forceErrorState: true` + `errorText:` after the request fails.
- Hidden PIN: `obscureText: true` (optionally `obscuringWidget:`).
- Don't wrap it in a fixed-height `SizedBox`: the error text is rendered below the pins inside Pinput and
  overflows ("RenderFlex overflowed") when the validator fails.

### 5. SMS autofill
- **iOS / web**: automatic — the default `autofillHints` is `oneTimeCode`; iOS suggests the code above the
  keyboard.
- **Android**: pinput 6 has no built-in retriever. Implement its `SmsRetriever` interface with e.g.
  [`smart_auth`](https://pub.dev/packages/smart_auth) (SMS Retriever / User Consent API) and pass
  `smsRetriever:`. The SMS must contain your app hash for the Retriever API.

### 6. Demo — `lib/otp/otp_page.dart`
**Home → Demos → OTP code (pinput)**: 4-digit rounded filled input (demo code **2222**), Verify / Clear buttons
and a 6-digit obscured PIN example. Test: `test/otp_test.dart`.

## Notes
- Widget tests: the autofocused input's cursor blinks forever, so `pumpAndSettle()` times out — use
  `pump(const Duration(milliseconds: 500))`.
- Never check real OTPs on the client; the demo compares locally only for illustration.
