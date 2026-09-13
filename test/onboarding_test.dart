import 'package:flutter_best_practices/l10n/app_localization_delegates.dart';
import 'package:flutter_best_practices/l10n/app_localizations.dart';
import 'package:flutter_best_practices/onboarding/onboarding_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('next, next, done closes the onboarding', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: appLocalizationDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const OnboardingPage()),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Works everywhere'), findsOneWidget);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Ready?'), findsOneWidget);

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingPage), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('skip jumps to the last page', (tester) async {
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: appLocalizationDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const OnboardingPage(),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    expect(find.text('Ready?'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });
}
