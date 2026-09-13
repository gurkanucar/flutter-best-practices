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
/// Keep in sync with the ARB files in `lib/l10n/`.
const supportedLanguages = [
  LanguageOption(locale: Locale('tr'), countryCode: 'TR', label: 'Türkçe'),
  LanguageOption(locale: Locale('en'), countryCode: 'US', label: 'English'),
];

/// Selected app locale. `null` = follow the device language.
final localeNotifier = ValueNotifier<Locale?>(null);
