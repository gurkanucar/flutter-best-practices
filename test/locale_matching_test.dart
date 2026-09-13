import 'dart:ui';

import 'package:flutter_best_practices/speech/locale_matching.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('bestLocaleMatch', () {
    test('exact language + region wins', () {
      expect(bestLocaleMatch(['en-US', 'tr-TR', 'de-DE'], const Locale('tr', 'TR')), 'tr-TR');
    });

    test('ignores separator and case differences and returns the platform id unchanged', () {
      expect(bestLocaleMatch(['en_US', 'tr_TR'], const Locale('tr')), 'tr_TR');
    });

    test('language without region prefers the main region', () {
      expect(bestLocaleMatch(['en-AU', 'en-GB', 'en-US'], const Locale('en')), 'en-US');
    });

    test('falls back to any region of the language', () {
      expect(bestLocaleMatch(['de-AT', 'de-CH'], const Locale('de')), 'de-AT');
    });

    test('uses the fallback locale when the language is missing', () {
      expect(bestLocaleMatch(['en-GB', 'fr-FR'], const Locale('tr')), 'en-GB');
    });

    test('returns null when nothing fits', () {
      expect(bestLocaleMatch(['fr-FR'], const Locale('tr')), isNull);
    });
  });

  test('sameLocale / sameLanguage normalize ids', () {
    expect(sameLocale('tr_TR', 'tr-tr'), isTrue);
    expect(sameLanguage('en-GB', 'en_US'), isTrue);
    expect(sameLanguage('en-GB', 'tr-TR'), isFalse);
  });
}
