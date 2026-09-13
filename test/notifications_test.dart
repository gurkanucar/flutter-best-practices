import 'package:material_ui/material_ui.dart';
import 'package:flutter_best_practices/home_page.dart';
import 'package:flutter_best_practices/l10n/app_localization_delegates.dart';
import 'package:flutter_best_practices/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
      locale: locale,
      localizationsDelegates: appLocalizationDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

void main() {
  // Only UI is tested here: plugin calls need a real device (no platform channel in tests).
  testWidgets('shows localized notification demo section', (tester) async {
    await tester.pumpWidget(wrap(const HomePage()));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Show notification'), 200);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Schedule in 5 seconds'), findsOneWidget);
    expect(find.text('Cancel all'), findsOneWidget);
    expect(find.text('Set alarm at date & time'), findsOneWidget);
  });

  testWidgets('shows Turkish notification demo section', (tester) async {
    await tester.pumpWidget(wrap(const HomePage(), locale: const Locale('tr')));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(find.text('Bildirim göster'), 200);
    expect(find.text('Bildirimler'), findsOneWidget);
    expect(find.text('5 saniye sonra planla'), findsOneWidget);
    expect(find.text('Tümünü iptal et'), findsOneWidget);
    expect(find.text('Tarih ve saatte alarm kur'), findsOneWidget);
  });
}
