# Forms with flutter_form_builder + form_builder_validators

- [`flutter_form_builder`](https://pub.dev/packages/flutter_form_builder) **10.3.x** — `FormBuilder` + ready-made fields;
  collects all values into a `Map` with one call.
- [`form_builder_validators`](https://pub.dev/packages/form_builder_validators) **11.x** — reusable validators
  with translated error messages (incl. Turkish).

Pure Dart/Flutter, all platforms.

> ⚠️ **Why 10.3.x and not 11.x?** `flutter_form_builder` 11.0.0 moved to the separate
> [`material_ui`](https://pub.dev/packages/material_ui) package. Its `TextField`, `Material`, `Theme` are
> **different classes** from `package:flutter/material.dart`. Inside our `flutter/material` `MaterialApp`
> a v11 field throws **`No Material widget found`** (verified with a widget test).
> Stay on 10.x until the whole app migrates to `material_ui`
> (all imports + `material_ui`'s `MaterialApp`/localization delegates), then upgrade.

## Steps

### 1. Add dependencies
```bash
flutter pub add "flutter_form_builder:^10.3.0+2" form_builder_validators
```
In PowerShell keep the quotes — otherwise `^` is swallowed and the version is pinned exactly.

`pubspec.yaml`:
```yaml
dependencies:
  # 11.x is built on package:material_ui and crashes inside a package:flutter/material.dart app.
  flutter_form_builder: ^10.3.0+2
  form_builder_validators: ^11.3.0
```

### 2. Translated validator messages — `lib/main.dart`
```dart
import 'package:form_builder_validators/form_builder_validators.dart';

MaterialApp(
  localizationsDelegates: const [
    ...AppLocalizations.localizationsDelegates,
    FormBuilderLocalizations.delegate,
  ],
  supportedLocales: AppLocalizations.supportedLocales,   // en + tr — both supported by the validators
)
```
Without the delegate every error is English. With it: `required()` → "This field cannot be empty." /
"Bu alan boş olamaz.".

### 3. Build the form — `lib/forms/sign_up_form_page.dart`
```dart
final _formKey = GlobalKey<FormBuilderState>();

FormBuilder(
  key: _formKey,
  child: ListView(
    children: [
      FormBuilderTextField(
        name: SignUpFields.email,                       // key in the value map
        decoration: InputDecoration(labelText: l10n.formEmail),
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        autofillHints: const [AutofillHints.email],
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          FormBuilderValidators.email(),
        ]),
      ),
      FormBuilderTextField(
        name: SignUpFields.password,
        obscureText: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          FormBuilderValidators.minLength(8),
        ]),
      ),
      FormBuilderTextField(
        name: SignUpFields.confirmPassword,
        obscureText: true,
        validator: FormBuilderValidators.compose([
          FormBuilderValidators.required(),
          // cross-field validation
          (value) => value == _formKey.currentState?.fields[SignUpFields.password]?.value
              ? null
              : l10n.formPasswordsDoNotMatch,
        ]),
      ),
      FormBuilderDateTimePicker(
        name: SignUpFields.birthDate,
        inputType: InputType.date,
        format: DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      ),
      FormBuilderDropdown<String>(
        name: SignUpFields.role,
        initialValue: 'user',
        items: [
          for (final role in ['admin', 'user', 'guest'])
            DropdownMenuItem(value: role, child: Text(l10n.userRole(role))),
        ],
      ),
      FormBuilderCheckbox(
        name: SignUpFields.acceptTerms,
        initialValue: false,
        title: Text(l10n.formAcceptTerms),
        validator: (value) => value == true ? null : l10n.formTermsRequired,
      ),
    ],
  ),
)
```
Other fields: `FormBuilderSwitch`, `FormBuilderRadioGroup`, `FormBuilderSlider`, `FormBuilderRangeSlider`,
`FormBuilderChoiceChips`, `FormBuilderFilterChips`, `FormBuilderCheckboxGroup`, `FormBuilderDateRangePicker`,
custom `FormBuilderField`.

### 4. Submit / reset
```dart
void _submit() {
  final form = _formKey.currentState!;
  if (!form.saveAndValidate()) {           // saves all fields, validates, focuses first invalid field
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.formInvalid)));
    return;
  }
  final data = SignUpData.fromFormValue(form.value);   // Map<String, dynamic> → typed model
  // send data to the API...
}

_formKey.currentState?.reset();                          // back to initial values
_formKey.currentState?.patchValue({'email': 'a@b.c'});   // set values programmatically
_formKey.currentState?.fields['email']?.invalidate('Email already taken');  // server-side error
```
- `value` — saved values (after `save`/`saveAndValidate`).
- `instantValue` — current values without saving.

### 5. Typed result — `lib/forms/sign_up_data.dart`
```dart
abstract final class SignUpFields {
  static const name = 'name';
  static const email = 'email';
  // ...
}

class SignUpData extends Equatable {
  factory SignUpData.fromFormValue(Map<String, dynamic> value) => SignUpData(
        name: (value[SignUpFields.name] as String).trim(),
        email: (value[SignUpFields.email] as String).trim(),
        password: value[SignUpFields.password] as String,
        role: value[SignUpFields.role] as String,
        acceptedTerms: value[SignUpFields.acceptTerms] as bool? ?? false,
        birthDate: value[SignUpFields.birthDate] as DateTime?,
      );

  @override
  List<Object?> get props => [name, email, password, role, acceptedTerms, birthDate];

  @override
  bool get stringify => false;   // never print the password in logs
}
```
- Keep field names in **one** place (`SignUpFields`) — a typo in `name:` silently creates a new key.
- Don't pass the raw `Map` around the app; convert to a model right after validation.
- Equatable: see [011](011-add-equatable.md). `EquatableConfig.stringify` is `true` in debug, so
  classes with secrets must override `stringify => false`.

## Validators cheat sheet (`FormBuilderValidators.`)

| Group | Validators |
|---|---|
| Core | `required()`, `compose([...])`, `aggregate([...])` (all errors), `conditional(...)`, `equal(v)`, `notEqual(v)`, `or([...])`, `skipWhen(...)`, `transform(...)` |
| Strings | `minLength(n)`, `maxLength(n)`, `match(RegExp(...))`, `alphabetical()`, `uppercase()`, `startsWith(s)`, `contains(s)`, `singleLine()` |
| Numbers | `numeric()`, `integer()`, `min(n)`, `max(n)`, `between(a, b)`, `positiveNumber()` |
| Network | `email()`, `url()`, `ip()`, `phoneNumber()`, `portNumber()` |
| Identity | `password()`, `username()`, `zipCode()`, `firstName()`, `lastName()` |
| Dates | `dateFuture()`, `datePast()`, `dateRange(...)` |
| Finance | `creditCard()`, `iban()`, `bic()` |

- Every validator accepts `errorText:` to override the message.
- v11: validators fail on null/empty by default — pass `checkNullOrEmpty: false` for optional fields
  (e.g. an optional `url()`).
- v11: `match()` takes a `RegExp`, not a `String`; `dateString()` → `date()`.
- Works with plain `TextFormField` too — no need for `flutter_form_builder`.

## Keyboard handling
The page uses `KeyboardDismissOnTap` and `KeyboardVisibilityBuilder` — see [012](012-add-keyboard-visibility.md).
Also set `textInputAction: TextInputAction.next` on every field except the last (`done`) and `autofillHints`
for name/email/password so password managers work.

## Tests — `test/form_test.dart`
```dart
Widget wrap(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        FormBuilderLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

testWidgets('empty submit shows Turkish validator errors', (tester) async {
  await tester.pumpWidget(wrap(const SignUpFormPage(), locale: const Locale('tr')));
  await tester.tap(find.text('Gönder'));
  await tester.pumpAndSettle();
  expect(find.text('Bu alan boş olamaz.'), findsWidgets);
});
```
Covered: English + Turkish required errors, valid submit dialog, password mismatch, keyboard hint,
`SignUpData` equality and password not in `toString`.
- Long forms in a `ListView` build lazily — use `tester.scrollUntilVisible(...)` before tapping lower widgets.
- Find text fields by label: `find.widgetWithText(TextField, 'Email')`.

## Troubleshooting
| Problem | Fix |
|---|---|
| `No Material widget found` from a `FormBuilder*` field | You're on `flutter_form_builder` 11.x in a `flutter/material` app → use `^10.3.0+2` (or migrate app to `material_ui`) |
| Error messages always English | Add `FormBuilderLocalizations.delegate` to `localizationsDelegates` |
| `form.value` is empty | You called `validate()` — use `saveAndValidate()` or read `instantValue` |
| Optional field shows "cannot be empty" | v11 validators check null/empty → `checkNullOrEmpty: false` |
| `match('pattern')` doesn't compile | v11 needs `match(RegExp('pattern'))` |
| Value missing from the map | Typo in `name:` — use constants |
