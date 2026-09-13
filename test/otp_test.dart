import 'package:flutter_best_practices/l10n/app_localization_delegates.dart';
import 'package:flutter_best_practices/l10n/app_localizations.dart';
import 'package:flutter_best_practices/otp/otp_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget wrap(Widget child) => MaterialApp(
      localizationsDelegates: appLocalizationDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

// The autofocused pinput has a blinking cursor animation, so pumpAndSettle never settles.
Future<void> settle(WidgetTester tester) => tester.pump(const Duration(milliseconds: 500));

void main() {
  testWidgets('pinput builds inside the material_ui app (legacy Material scope)', (tester) async {
    await tester.pumpWidget(wrap(const OtpPage()));
    await settle(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wrong code shows the error, demo code verifies', (tester) async {
    await tester.pumpWidget(wrap(const OtpPage()));
    await settle(tester);

    final codeInput = find.byType(EditableText).first;

    await tester.enterText(codeInput, '1111');
    await settle(tester);
    expect(find.text('Wrong code'), findsOneWidget);
    expect(find.text('Code verified'), findsNothing);

    await tester.enterText(codeInput, OtpPage.demoCode);
    await settle(tester);
    expect(find.text('Code verified'), findsOneWidget);
    expect(find.text('Wrong code'), findsNothing);
  });
}
