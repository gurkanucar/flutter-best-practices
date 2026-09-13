import 'package:flutter_best_practices/forms/form_fields_page.dart';
import 'package:flutter_best_practices/l10n/app_localization_delegates.dart';
import 'package:flutter_best_practices/l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Widget wrap(Widget child) => MaterialApp(
  localizationsDelegates: appLocalizationDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);

Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  // The form is taller than the 800×600 test screen: scroll until the widget is reached...
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  // ...then scrolls it fully on screen so taps hit its center.
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await scrollTo(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('empty submit reports validation errors', (tester) async {
    await tester.pumpWidget(wrap(const FormFieldsPage()));
    await tester.pumpAndSettle();

    await tapVisible(tester, find.widgetWithText(FilledButton, 'Submit'));

    expect(find.text('Please fix the errors'), findsOneWidget);
  });

  testWidgets('fill example (patchValue) then submit shows the values', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const FormFieldsPage()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Fill example'));
    await tester.pumpAndSettle();
    await tapVisible(tester, find.widgetWithText(FilledButton, 'Submit'));

    expect(find.text('Form values'), findsOneWidget);
    final dialogText = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(Text),
    );
    final content = tester
        .widgetList<Text>(dialogText)
        .map((text) => text.data ?? '')
        .join('\n');
    expect(content, contains('size: M'));
    expect(content, contains('rating: 4'));
    expect(content, contains('priceRange: 2000 – 8000'));
    expect(content, contains('toppings: cheese, olive'));
    expect(content, contains('color: #')); // custom Color field
  });

  testWidgets('phone field appears only when "Phone" is selected', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const FormFieldsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Phone number'), findsNothing);
    await tapVisible(tester, find.text('Phone'));
    await scrollTo(tester, find.text('Phone number'));
    expect(find.text('Phone number'), findsOneWidget);
  });

  testWidgets('guest fields can be added and removed', (tester) async {
    await tester.pumpWidget(wrap(const FormFieldsPage()));
    await tester.pumpAndSettle();

    await tapVisible(tester, find.text('Add guest'));
    await tapVisible(tester, find.text('Add guest'));
    await scrollTo(tester, find.text('Guest 2'));
    expect(find.text('Guest 1'), findsOneWidget);
    expect(find.text('Guest 2'), findsOneWidget);

    await tester.tap(find.byTooltip('Remove guest').first);
    await tester.pumpAndSettle();
    expect(
      find.text('Guest 2'),
      findsNothing,
    ); // remaining guest is renumbered to 1
    expect(find.text('Guest 1'), findsOneWidget);
  });
}
