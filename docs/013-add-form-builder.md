# Forms with flutter_form_builder + form_builder_validators

- [`flutter_form_builder`](https://pub.dev/packages/flutter_form_builder) **11.x** — `FormBuilder` + ready-made fields;
  collects all values into a `Map` with one call.
- [`form_builder_validators`](https://pub.dev/packages/form_builder_validators) **11.x** — reusable validators
  with translated error messages (incl. Turkish).

Pure Dart/Flutter, all platforms.

> ⚠️ **`flutter_form_builder` 11 is built on [`material_ui`](https://pub.dev/packages/material_ui).**
> Its `TextField`, `Material`, `Theme` are **different classes** from `package:flutter/material.dart`.
> Inside a `flutter/material` `MaterialApp` a v11 field throws **`No Material widget found`**
> (verified with a widget test). This project is migrated to `material_ui`
> ([020](020-add-go-router.md#material_ui-migration)), so it uses 11.x.
> Apps still on `flutter/material.dart` must pin `flutter_form_builder: ^10.3.0+2`.

## Steps

### 1. Add dependencies
```bash
flutter pub add "flutter_form_builder:^11.0.0" form_builder_validators
```
In PowerShell keep the quotes — otherwise `^` is swallowed and the version is pinned exactly.

`pubspec.yaml`:
```yaml
dependencies:
  # 11.x uses package:material_ui — the app is migrated to material_ui, so this is fine.
  flutter_form_builder: ^11.0.0
  form_builder_validators: ^11.3.0
```

### 2. Translated validator messages — `lib/main.dart`
`lib/l10n/app_localization_delegates.dart` (used by `main.dart` and every widget test):
```dart
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:material_ui/material_ui.dart';

final List<LocalizationsDelegate<dynamic>> appLocalizationDelegates = [
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,   // material_ui: Widgets + Material + Cupertino
  FormBuilderLocalizations.delegate,          // translated validator error messages
];

// main.dart
MaterialApp.router(
  localizationsDelegates: appLocalizationDelegates,
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
  // ⚠️ Not ListView: it builds children lazily. Fields that were never on screen aren't registered,
  // so saveAndValidate() skips them, patchValue() ignores them and form.value lacks them.
  child: SingleChildScrollView(
    child: Column(
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

## More field types — `lib/forms/form_fields_page.dart`
**Home → Demos → All form fields** shows every built-in field plus custom, conditional and dynamic fields.

| Field | Value in `form.value` | Example |
|---|---|---|
| `FormBuilderTextField` | `String?` (or anything via `valueTransformer`) | name, notes (`maxLines`, `maxLength`), age → `int?` |
| `FormBuilderDateTimePicker(inputType: InputType.time)` | `DateTime?` | meeting time |
| `FormBuilderDateTimePicker(inputType: InputType.both)` | `DateTime?` | appointment |
| `FormBuilderDateRangePicker` | `DateTimeRange?` | trip dates |
| `FormBuilderSlider` | `double` | volume 0–100 |
| `FormBuilderRangeSlider` | `RangeValues` | price range |
| `FormBuilderSwitch` | `bool` | newsletter |
| `FormBuilderCheckbox` | `bool` | accept terms |
| `FormBuilderRadioGroup<T>` | `T?` | contact method |
| `FormBuilderCheckboxGroup<T>` | `List<T>?` | interests |
| `FormBuilderChoiceChips<T>` | `T?` (single) | T-shirt size |
| `FormBuilderFilterChips<T>` | `List<T>?` (multiple) | pizza toppings |
| `FormBuilderDropdown<T>` | `T?` | role (sign-up form) |
| `FormBuilderField<T>` (custom) | `T?` | star rating, color |

### Date, time and range
```dart
FormBuilderDateTimePicker(
  name: FieldNames.meetingTime,
  inputType: InputType.time,                       // date | time | both
  format: DateFormat.jm(locale),                   // "9:30 AM" / "09:30"
  validator: FormBuilderValidators.required(),
),
FormBuilderDateRangePicker(
  name: FieldNames.tripDates,
  firstDate: DateUtils.dateOnly(DateTime.now()),
  lastDate: DateTime.now().add(const Duration(days: 365)),
  format: DateFormat.yMMMd(locale),
),
```

### Sliders and numbers
```dart
FormBuilderSlider(
  name: FieldNames.volume,
  min: 0, max: 100, divisions: 20, initialValue: 40,
  displayValues: DisplayValues.current,            // all | current | minMax | none
),
FormBuilderRangeSlider(
  name: FieldNames.priceRange,
  min: 0, max: 10000, divisions: 20,
  initialValue: const RangeValues(1000, 5000),
),
FormBuilderTextField(
  name: FieldNames.age,
  keyboardType: TextInputType.number,
  valueTransformer: (value) => int.tryParse(value ?? ''),     // form.value['age'] is int?
  validator: FormBuilderValidators.compose([
    FormBuilderValidators.integer(checkNullOrEmpty: false),   // optional field
    FormBuilderValidators.min(18, checkNullOrEmpty: false),
    FormBuilderValidators.max(120, checkNullOrEmpty: false),
  ]),
),
```

### Choices
```dart
FormBuilderRadioGroup<String>(
  name: FieldNames.contact,
  validator: FormBuilderValidators.required(),
  options: [
    FormBuilderFieldOption(value: 'email', child: Text(l10n.formEmail)),
    FormBuilderFieldOption(value: 'phone', child: Text(l10n.fieldsContactPhone)),
  ],
),
FormBuilderCheckboxGroup<String>(
  name: FieldNames.interests,
  validator: FormBuilderValidators.minLength(1),   // at least one checked
  options: const [FormBuilderFieldOption(value: 'flutter', child: Text('Flutter'))],
),
FormBuilderChoiceChips<String>(
  name: FieldNames.size,
  spacing: 8,
  options: const [FormBuilderChipOption(value: 'S'), FormBuilderChipOption(value: 'M')],   // label = value
),
FormBuilderFilterChips<String>(
  name: FieldNames.toppings,
  options: [FormBuilderChipOption(value: 'cheese', child: Text(l10n.fieldsToppingCheese))],
),
```
Layout: `orientation: OptionsOrientation.horizontal | vertical | wrap | auto`.

### Custom field — any widget
```dart
FormBuilderField<int>(
  name: FieldNames.rating,
  validator: FormBuilderValidators.required(),
  builder: (field) => InputDecorator(
    decoration: InputDecoration(labelText: l10n.fieldsRating, errorText: field.errorText, border: InputBorder.none),
    child: Row(children: [
      for (var star = 1; star <= 5; star++)
        IconButton(
          icon: Icon(star <= (field.value ?? 0) ? Icons.star : Icons.star_border),
          onPressed: () => field.didChange(star),   // set value
        ),
    ]),
  ),
)
```
Same pattern for the color picker (`FormBuilderField<Color>`), signature pads, file pickers, maps…

### Conditional field
```dart
FormBuilderRadioGroup<String>(
  name: FieldNames.contact,
  onChanged: (value) => setState(() => _contact = value),
  ...
),
if (_contact == 'phone')
  FormBuilderTextField(
    name: FieldNames.phone,
    validator: FormBuilderValidators.compose([
      FormBuilderValidators.required(),
      FormBuilderValidators.phoneNumber(),
    ]),
  ),
```
Hidden fields aren't validated. With `FormBuilder(clearValueOnUnregister: true)` their value also disappears
from `form.value` when they're removed.

### Dynamic fields (add / remove)
```dart
final _guestIds = <int>[];
int _nextGuestId = 1;

for (final (index, id) in _guestIds.indexed)
  FormBuilderTextField(
    key: ValueKey(id),                              // stable identity when others are removed
    name: FieldNames.guest(id),                     // 'guest_1', 'guest_2', ...
    decoration: InputDecoration(
      labelText: l10n.fieldsGuestName(index + 1),
      suffixIcon: IconButton(
        icon: const Icon(Icons.remove_circle_outline),
        onPressed: () => setState(() => _guestIds.remove(id)),
      ),
    ),
  ),
TextButton(onPressed: () => setState(() => _guestIds.add(_nextGuestId++)), child: Text(l10n.fieldsAddGuest)),
```
Use an increasing id, not the list index, for `name` and `key`.

### Fill programmatically (edit an existing record)
```dart
_formKey.currentState?.patchValue({
  FieldNames.meetingTime: DateTime(2026, 1, 1, 9, 30),
  FieldNames.priceRange: const RangeValues(2000, 8000),
  FieldNames.interests: ['flutter', 'dart'],
  FieldNames.rating: 4,
  FieldNames.color: Colors.green,
});
```

### Tests — `test/form_fields_test.dart`
Empty submit errors, `patchValue` + submit result, conditional phone field, add/remove guests.

### Even more fields
[`form_builder_extra_fields`](https://pub.dev/packages/form_builder_extra_fields) (13.x, `material_ui`-based):
typeahead/autocomplete, searchable dropdown, color picker, signature pad, rating bar, touch spin, cupertino pickers.
Its own dependencies (`flutter_typeahead`, `dropdown_search`, `flutter_colorpicker`, `signature`,
`flutter_rating_bar`) may still use `package:flutter/material.dart` — test each field in this app before relying on it
(a "No Material widget found" error means that dependency isn't migrated). Also:
[`form_builder_image_picker`](https://pub.dev/packages/form_builder_image_picker),
[`form_builder_file_picker`](https://pub.dev/packages/form_builder_file_picker),
[`form_builder_phone_field`](https://pub.dev/packages/form_builder_phone_field).

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
      localizationsDelegates: appLocalizationDelegates,
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
- Long forms are taller than the test screen (800×600) — `tester.scrollUntilVisible(...)` then
  `tester.ensureVisible(...)` before tapping lower widgets, otherwise the tap misses.
- Find text fields by label: `find.widgetWithText(TextField, 'Email')`.

## Troubleshooting
| Problem | Fix |
|---|---|
| `No Material widget found` from a `FormBuilder*` field | 11.x inside a `flutter/material` app → migrate the app to `material_ui` ([020](020-add-go-router.md#material_ui-migration)) or pin `^10.3.0+2` |
| `No MaterialLocalizations found` | Using `AppLocalizations.localizationsDelegates` → use `appLocalizationDelegates` (material_ui delegates) |
| Error messages always English | Add `FormBuilderLocalizations.delegate` to `localizationsDelegates` |
| `form.value` is empty | You called `validate()` — use `saveAndValidate()` or read `instantValue` |
| Optional field shows "cannot be empty" | v11 validators check null/empty → `checkNullOrEmpty: false` |
| `match('pattern')` doesn't compile | v11 needs `match(RegExp('pattern'))` |
| Value missing from the map | Typo in `name:` — use constants |
| Required field below the fold isn't validated / `patchValue` ignores it / missing from `form.value` | Fields are inside a lazy `ListView` and were never built → use `SingleChildScrollView` + `Column` |
