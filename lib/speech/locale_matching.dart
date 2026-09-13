import 'dart:ui';

/// Speech APIs report locales in different shapes: `tr-TR` (Android, web), `tr_TR` (iOS speech),
/// `tr` (some web voices). Compare them only after normalizing.
String normalizeLocaleId(String id) => id.replaceAll('_', '-').toLowerCase();

String languageOf(String id) => normalizeLocaleId(id).split('-').first;

bool sameLocale(String a, String b) => normalizeLocaleId(a) == normalizeLocaleId(b);

bool sameLanguage(String a, String b) => languageOf(a) == languageOf(b);

/// Picks the platform locale id that fits [preferred] best:
/// exact match (`tr-TR`) → the language's main region (`tr-TR`, `de-DE`, `en-US`) → any region of the language.
/// Tries [fallback] the same way, then returns null.
String? bestLocaleMatch(
  Iterable<String> candidates,
  Locale preferred, {
  Locale fallback = const Locale('en', 'US'),
}) {
  final ids = candidates.toList();

  String? find(Locale locale) {
    final language = locale.languageCode.toLowerCase();
    final wanted = [
      if (locale.countryCode != null) '$language-${locale.countryCode!.toLowerCase()}',
      '$language-${_mainRegions[language] ?? language}',
    ];
    for (final id in wanted) {
      for (final candidate in ids) {
        if (normalizeLocaleId(candidate) == id) return candidate;
      }
    }
    for (final candidate in ids) {
      if (languageOf(candidate) == language) return candidate;
    }
    return null;
  }

  return find(preferred) ?? find(fallback);
}

/// Languages whose main region code differs from the language code (`tr` → `tr-TR` needs no entry).
const _mainRegions = {
  'ar': 'sa',
  'cs': 'cz',
  'da': 'dk',
  'el': 'gr',
  'en': 'us',
  'hi': 'in',
  'ja': 'jp',
  'ko': 'kr',
  'pt': 'br',
  'sv': 'se',
  'uk': 'ua',
  'zh': 'cn',
};
