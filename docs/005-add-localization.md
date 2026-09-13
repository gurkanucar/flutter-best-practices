# Add Flutter Localization

Uses Flutter's built-in `gen-l10n` (ARB files → generated `AppLocalizations` class).
Languages in this project: **English (`en`, template)** and **Turkish (`tr`)**.

> Current Flutter (3.47) no longer supports the synthetic `package:flutter_gen` package
> (`synthetic-package` is deprecated and can't be enabled).
> Generated files are written into `lib/l10n/` and imported with a relative/package path.
> Old imports like `package:flutter_gen/gen_l10n/app_localizations.dart` must be changed.

## Steps

### 1. Add dependencies
```bash
flutter pub add flutter_localizations --sdk=flutter
flutter pub add intl:any
```

Or manually in `pubspec.yaml`:
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: any   # version is pinned by flutter_localizations; a fixed ^ constraint may conflict after SDK upgrades
```

### 2. Enable generation in `pubspec.yaml`
```yaml
flutter:
  generate: true
```

### 3. Create `l10n.yaml` in project root
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
nullable-getter: false                       # AppLocalizations.of(context) without `!`
untranslated-messages-file: untranslated.json  # lists missing translations per locale (project root)
# preferred-supported-locales: [tr]          # optional: fallback locale when device locale is unsupported
# required-resource-attributes: true         # optional: force "@key" description for every message
```
- Do **not** add `synthetic-package` — it is deprecated and can't be enabled.
- Add `untranslated.json` to `.gitignore` (or commit it if you want to track missing keys in review).

### 4. Create ARB files in `lib/l10n/`

Rules:
- Save as **UTF-8** (Turkish characters: ş, ğ, ı, ö, ü, ç).
- Keys must be valid Dart identifiers → `camelCase` (`loginButton`, not `login_button` or `login.button`).
- Metadata (`@key`) is only **required** in the template (`app_en.arb`). This project keeps
  `app_tr.arb` structurally identical (same keys, same order, same `@key` blocks) so the two
  files diff line by line and nothing gets forgotten. `gen-l10n` always takes placeholder
  types/formats from the template.

**app_en.arb** (template):
```json
{
  "@@locale": "en",

  "appTitle": "Flutter Best Practices",
  "@appTitle": { "description": "App name shown in task switcher / browser tab" },

  "hello": "Hello!",
  "@hello": { "description": "A simple greeting" },

  "welcome": "Welcome, {name}!",
  "@welcome": {
    "placeholders": { "name": { "type": "String", "example": "John" } }
  },

  "itemCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}",
  "@itemCount": {
    "placeholders": { "count": { "type": "int" } }
  },

  "userRole": "{role, select, admin{Administrator} user{User} other{Guest}}",
  "@userRole": {
    "placeholders": { "role": { "type": "String" } }
  },

  "lastLogin": "Last login: {date}",
  "@lastLogin": {
    "placeholders": { "date": { "type": "DateTime", "format": "yMMMd" } }
  },

  "price": "Price: {amount}",
  "@price": {
    "placeholders": {
      "amount": {
        "type": "double",
        "format": "currency",
        "optionalParameters": { "name": "TRY", "decimalDigits": 2 }
      }
    }
  }
}
```

**app_tr.arb** (translation — same structure as the template):
```json
{
  "@@locale": "tr",

  "appTitle": "Flutter Best Practices",
  "@appTitle": { "description": "App name shown in task switcher / browser tab" },

  "hello": "Merhaba!",
  "@hello": { "description": "A simple greeting" },

  "welcome": "Hoş geldin, {name}!",
  "@welcome": {
    "placeholders": { "name": { "type": "String", "example": "John" } }
  },

  "itemCount": "{count, plural, =0{Öğe yok} =1{1 öğe} other{{count} öğe}}",
  "@itemCount": {
    "placeholders": { "count": { "type": "int" } }
  },

  "userRole": "{role, select, admin{Yönetici} user{Kullanıcı} other{Misafir}}",
  "@userRole": {
    "placeholders": { "role": { "type": "String" } }
  },

  "lastLogin": "Son giriş: {date}",
  "@lastLogin": {
    "placeholders": { "date": { "type": "DateTime", "format": "yMMMd" } }
  },

  "price": "Fiyat: {amount}",
  "@price": {
    "placeholders": {
      "amount": {
        "type": "double",
        "format": "currency",
        "optionalParameters": { "name": "TRY", "decimalDigits": 2 }
      }
    }
  }
}
```
- Turkish has no singular/plural distinction for counted nouns ("1 öğe", "5 öğe"); `=1{...}` is
  kept only to mirror the template.
- When changing a placeholder's `type`/`format`, change it in **both** files.
- Date/number formats use the **current locale** automatically (`Sep 13, 2026` vs `13 Eyl 2026`).

### 5. Generate
```bash
flutter pub get
flutter gen-l10n    # also runs automatically on flutter run / build / hot reload when ARB files change
```
Output in `lib/l10n/`: `app_localizations.dart`, `app_localizations_en.dart`, `app_localizations_tr.dart`.
Commit these files — the app doesn't compile without them on a fresh checkout until `gen-l10n` runs.

### 6. Configure `MaterialApp`

**a) Follow the device language (simplest):**
```dart
import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomePage(),
    );
  }
}
```
- Don't make `MaterialApp` `const` and don't pass `locale:` unless you define it (see b).
- `localizationsDelegates` already includes `GlobalMaterialLocalizations`, `GlobalCupertinoLocalizations`
  and `GlobalWidgetsLocalizations` — date pickers, dialogs, "Copy/Paste" menus are translated too.
- Use `onGenerateTitle`, not `title:` — `title` can't access `AppLocalizations`.
- If the device language isn't supported, Flutter falls back to the first entry of
  `supportedLocales` (alphabetical → `en`), unless `preferred-supported-locales` is set.

**b) Let the user change the language at runtime:**
```dart
/// `null` = follow the device language.
final localeNotifier = ValueNotifier<Locale?>(null);

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) => MaterialApp(
        locale: locale,
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomePage(),
      ),
    );
  }
}

// Anywhere:
localeNotifier.value = const Locale('tr');
localeNotifier.value = null; // back to system language
```
- Persist the choice (e.g. `shared_preferences`) and restore it in `main()` before `runApp`.
- In a real app keep this in your state management (Riverpod/Bloc/Provider) instead of a global.

**c) Language selector with flags (this project):**

Uses [`country_flags`](https://pub.dev/packages/country_flags) (SVG flags, no image assets needed).
```bash
flutter pub add country_flags
```

Add the menu texts to **both** ARB files:
```json
// app_en.arb
"language": "Language",
"@language": { "description": "Tooltip of the language selector" },
"systemLanguage": "System language",
"@systemLanguage": { "description": "Language menu item that follows the device language" },

// app_tr.arb
"language": "Dil",
"@language": { "description": "Tooltip of the language selector" },
"systemLanguage": "Sistem dili",
"@systemLanguage": { "description": "Language menu item that follows the device language" },
```

`lib/l10n/supported_languages.dart` — single source of truth for languages + selected locale:
```dart
import 'package:flutter/widgets.dart';

class LanguageOption {
  final Locale locale;
  final String countryCode;
  final String label;

  const LanguageOption({
    required this.locale,
    required this.countryCode,
    required this.label,
  });

  /// Option matching [locale] by language code, or the first supported language.
  static LanguageOption fromLocale(Locale locale) => supportedLanguages.firstWhere(
        (option) => option.locale.languageCode == locale.languageCode,
        orElse: () => supportedLanguages.first,
      );
}

/// Labels are native names on purpose — users look for their own language.
const supportedLanguages = [
  LanguageOption(locale: Locale('tr'), countryCode: 'TR', label: 'Türkçe'),
  LanguageOption(locale: Locale('en'), countryCode: 'US', label: 'English'),
];

/// Selected app locale. `null` = follow the device language.
final localeNotifier = ValueNotifier<Locale?>(null);
```
- `countryCode` is separate from `locale` because a language isn't a country
  (`en` → 🇺🇸 or 🇬🇧, `pt` → 🇧🇷 or 🇵🇹). `CountryFlag.fromLanguageCode` exists but guesses.
- Move `localeNotifier` here (out of `main.dart`) so widgets don't import `main.dart`.

`lib/l10n/language_selector.dart`:
```dart
import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';

import 'l10n_extension.dart';
import 'supported_languages.dart';

/// App bar language menu: device language + [supportedLanguages] with flags.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  // PopupMenuButton treats a null value as "cancelled", so use string keys.
  static const _systemKey = 'system';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = LanguageOption.fromLocale(Localizations.localeOf(context));

    return ValueListenableBuilder<Locale?>(
      valueListenable: localeNotifier,
      builder: (context, selectedLocale, _) {
        final selectedKey = selectedLocale?.languageCode ?? _systemKey;

        return PopupMenuButton<String>(
          tooltip: l10n.language,
          initialValue: selectedKey,
          onSelected: (key) =>
              localeNotifier.value = key == _systemKey ? null : Locale(key),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _systemKey,
              child: _MenuRow(
                leading: const Icon(Icons.phone_android, size: 20),
                label: l10n.systemLanguage,
                selected: selectedKey == _systemKey,
              ),
            ),
            const PopupMenuDivider(),
            for (final option in supportedLanguages)
              PopupMenuItem(
                value: option.locale.languageCode,
                child: _MenuRow(
                  leading: LanguageFlag(option.countryCode),
                  label: option.label,
                  selected: selectedKey == option.locale.languageCode,
                ),
              ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: LanguageFlag(current.countryCode),
          ),
        );
      },
    );
  }
}

class LanguageFlag extends StatelessWidget {
  const LanguageFlag(this.countryCode, {super.key});

  final String countryCode;

  @override
  Widget build(BuildContext context) {
    return CountryFlag.fromCountryCode(
      countryCode,
      theme: const ImageTheme(width: 28, height: 20, shape: RoundedRectangle(4)),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.leading,
    required this.label,
    required this.selected,
  });

  final Widget leading;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 28, child: Center(child: leading)),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        if (selected) const Icon(Icons.check, size: 20),
      ],
    );
  }
}
```

Use it in any `AppBar`:
```dart
AppBar(
  title: Text(context.l10n.appTitle),
  actions: const [LanguageSelector()],
)
```
- The app bar flag shows the **effective** language (`Localizations.localeOf`), so it's
  correct in "System language" mode too.
- `country_flags` ≥ 4 API: `CountryFlag.fromCountryCode(code, theme: ImageTheme(...))`
  (shapes: `Rectangle()`, `Circle()`, `RoundedRectangle(r)`; or `EmojiTheme(size:)`).
- Keep `supportedLanguages` in sync with the ARB files — a test checks this (see step 9).

### 7. Use in widgets

Optional shortcut — `lib/l10n/l10n_extension.dart`:
```dart
import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
```

```dart
final l10n = context.l10n;            // or AppLocalizations.of(context)
Text(l10n.hello);                     // Simple string
Text(l10n.welcome('John'));           // Placeholder
Text(l10n.itemCount(3));              // Plural
Text(l10n.userRole('admin'));         // Select
Text(l10n.lastLogin(DateTime.now())); // DateTime, locale-aware format
Text(l10n.price(149.9));              // Currency, locale-aware format

// Current locale (e.g. for API "Accept-Language" header):
final languageCode = Localizations.localeOf(context).languageCode;
```
- `AppLocalizations.of(context)` needs a context **below** `MaterialApp` — it doesn't work
  inside `MainApp.build` itself (use `onGenerateTitle` there).

### 8. Platform configuration

**iOS / macOS — required for App Store & system language settings.**
Add to `ios/Runner/Info.plist` and `macos/Runner/Info.plist` inside `<dict>`:
```xml
<key>CFBundleLocalizations</key>
<array>
  <string>en</string>
  <string>tr</string>
</array>
```
Without this, iOS may report only English to Flutter and the app is listed as English-only.

**Android 13+ — per-app language (optional).** Lets users pick the app language in system settings.
1. Create `android/app/src/main/res/xml/locales_config.xml`:
   ```xml
   <?xml version="1.0" encoding="utf-8"?>
   <locale-config xmlns:android="http://schemas.android.com/apk/res/android">
     <locale android:name="en"/>
     <locale android:name="tr"/>
   </locale-config>
   ```
2. In `android/app/src/main/AndroidManifest.xml`, on `<application>`:
   `android:localeConfig="@xml/locales_config"`

**Web:** set the default document language in `web/index.html` → `<html lang="en">`.

**Windows / Linux:** nothing extra — device locale is read automatically.

### 9. Widget tests
```dart
Widget wrap(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

testWidgets('shows Turkish greeting', (tester) async {
  await tester.pumpWidget(wrap(const HomePage(), locale: const Locale('tr')));
  await tester.pumpAndSettle();
  expect(find.text('Merhaba!'), findsOneWidget);
});

// Fails when an ARB file is added/removed without updating supportedLanguages.
test('supportedLanguages matches AppLocalizations.supportedLocales', () {
  expect(
    supportedLanguages.map((o) => o.locale.languageCode).toSet(),
    AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
  );
});
```
- If a test uses the global `localeNotifier`, reset it: `tearDown(() => localeNotifier.value = null);`
- Full example incl. tapping the `LanguageSelector`: `test/l10n_test.dart`.

## Adding a New Language
1. Create `lib/l10n/app_XX.arb` (e.g. `app_de.arb`) with `"@@locale": "de"`.
2. Copy `app_en.arb` as a starting point and translate the values — keep keys, order and `@key` blocks identical.
3. Run `flutter gen-l10n` (or just `flutter run`) and check `untranslated.json` for missing keys.
4. Add the code to `CFBundleLocalizations` (iOS/macOS) and `locales_config.xml` (Android).
5. Add a `LanguageOption` to `supportedLanguages` (native label + flag country code),
   e.g. `LanguageOption(locale: Locale('de'), countryCode: 'DE', label: 'Deutsch')`.

## ARB Key Types
| Type | Example |
|---|---|
| Simple | `"hello": "Hello!"` |
| Placeholder | `"welcome": "Welcome, {name}!"` + `@welcome.placeholders` |
| Plural | `"{count, plural, =0{None} =1{One} other{{count} items}}"` |
| Select | `"{role, select, admin{Admin} other{Guest}}"` |
| DateTime | `"type": "DateTime", "format": "yMMMd"` |
| Number / currency | `"type": "double", "format": "currency"` (`compact`, `decimalPattern`, `percentPattern`…) |

## Troubleshooting
| Problem | Fix |
|---|---|
| `Undefined name '_locale'` | Remove `locale:` or define it (step 6b); also remove `const` from `MaterialApp` |
| `Invalid constant value` on `MaterialApp` | A non-const value (e.g. `locale: _locale`, `onGenerateTitle`) is inside `const MaterialApp(...)` — remove `const` |
| `package:flutter_gen/...` not found | Import `l10n/app_localizations.dart` instead; delete `synthetic-package` from `l10n.yaml` |
| `AppLocalizations.of(context)` returns null / throws | Context is above `MaterialApp`, or delegates not added |
| Changes in ARB not visible | Run `flutter gen-l10n`; hot restart |
| Text shows English on iOS | Add `CFBundleLocalizations` (step 8) |
| `{` or `'` breaks parsing | Set `use-escaping: true` in `l10n.yaml` and wrap literals in single quotes: `'{'` |
