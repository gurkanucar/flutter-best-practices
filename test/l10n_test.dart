import 'package:flutter/material.dart';
import 'package:flutter_best_practices/home_page.dart';
import 'package:flutter_best_practices/l10n/app_localizations.dart';
import 'package:flutter_best_practices/l10n/language_selector.dart';
import 'package:flutter_best_practices/l10n/supported_languages.dart';
import 'package:flutter_best_practices/main.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

void main() {
  tearDown(() => localeNotifier.value = null);

  testWidgets('shows English texts', (tester) async {
    await tester.pumpWidget(wrap(const HomePage()));
    await tester.pumpAndSettle();

    expect(find.text('Hello!'), findsOneWidget);
    expect(find.text('Welcome, John!'), findsOneWidget);
    expect(find.text('No items'), findsOneWidget);
    expect(find.text('1 item'), findsOneWidget);
    expect(find.text('5 items'), findsOneWidget);
    expect(find.text('Administrator'), findsOneWidget);
  });

  testWidgets('shows Turkish texts', (tester) async {
    await tester.pumpWidget(wrap(const HomePage(), locale: const Locale('tr')));
    await tester.pumpAndSettle();

    expect(find.text('Merhaba!'), findsOneWidget);
    expect(find.text('Hoş geldin, John!'), findsOneWidget);
    expect(find.text('Öğe yok'), findsOneWidget);
    expect(find.text('1 öğe'), findsOneWidget);
    expect(find.text('5 öğe'), findsOneWidget);
    expect(find.text('Yönetici'), findsOneWidget);
  });

  test('supportedLanguages matches AppLocalizations.supportedLocales', () {
    expect(
      supportedLanguages.map((o) => o.locale.languageCode).toSet(),
      AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet(),
    );
  });

  testWidgets('language selector switches between system, Turkish and English',
      (tester) async {
    await tester.pumpWidget(const MainApp());
    await tester.pumpAndSettle();
    expect(find.text('Hello!'), findsOneWidget); // test device locale = en_US

    await tester.tap(find.byType(LanguageSelector));
    await tester.pumpAndSettle();
    expect(find.text('System language'), findsOneWidget);
    expect(find.text('Türkçe'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);

    await tester.tap(find.text('Türkçe'));
    await tester.pumpAndSettle();
    expect(localeNotifier.value, const Locale('tr'));
    expect(find.text('Merhaba!'), findsOneWidget);

    await tester.tap(find.byType(LanguageSelector));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sistem dili'));
    await tester.pumpAndSettle();
    expect(localeNotifier.value, isNull);
    expect(find.text('Hello!'), findsOneWidget);
  });
}
