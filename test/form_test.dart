import 'package:flutter/material.dart';
import 'package:flutter_best_practices/forms/sign_up_data.dart';
import 'package:flutter_best_practices/forms/sign_up_form_page.dart';
import 'package:flutter_best_practices/l10n/app_localizations.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

Widget wrap(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        FormBuilderLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).first);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => KeyboardVisibilityTesting.setVisibilityForTesting(false));

  testWidgets('empty submit shows English validator errors', (tester) async {
    await tester.pumpWidget(wrap(const SignUpFormPage()));
    await tester.pumpAndSettle();

    await tapVisible(tester, find.text('Submit'));

    expect(find.text('Please fix the errors'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('This field cannot be empty.').first,
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('This field cannot be empty.'), findsWidgets);
  });

  testWidgets('empty submit shows Turkish validator errors', (tester) async {
    await tester.pumpWidget(wrap(const SignUpFormPage(), locale: const Locale('tr')));
    await tester.pumpAndSettle();

    await tapVisible(tester, find.text('Gönder'));

    expect(find.text('Lütfen hataları düzeltin'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Bu alan boş olamaz.').first,
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Bu alan boş olamaz.'), findsWidgets);
  });

  testWidgets('valid input submits and shows the result', (tester) async {
    await tester.pumpWidget(wrap(const SignUpFormPage()));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Full name'), 'Ada Lovelace');
    await tester.enterText(find.widgetWithText(TextField, 'Email'), 'ada@example.com');
    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
    await tester.enterText(find.widgetWithText(TextField, 'Confirm password'), 'password123');
    await tapVisible(tester, find.text('I accept the terms'));
    await tapVisible(tester, find.text('Submit'));

    expect(find.text('Form submitted'), findsOneWidget);
    // The email field behind the dialog also contains the text — look inside the dialog only.
    expect(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.textContaining('ada@example.com'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('different confirm password shows mismatch error', (tester) async {
    await tester.pumpWidget(wrap(const SignUpFormPage()));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Password'), 'password123');
    await tester.enterText(find.widgetWithText(TextField, 'Confirm password'), 'password999');
    await tapVisible(tester, find.text('Submit'));

    await tester.scrollUntilVisible(
      find.text("Passwords don't match"),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text("Passwords don't match"), findsOneWidget);
  });

  testWidgets('keyboard tip is hidden while the keyboard is visible', (tester) async {
    await tester.pumpWidget(wrap(const SignUpFormPage()));
    await tester.pumpAndSettle();
    expect(find.text('Tap outside a field to close the keyboard.'), findsOneWidget);

    KeyboardVisibilityTesting.setVisibilityForTesting(true);
    await tester.pumpWidget(wrap(const SignUpFormPage(), locale: const Locale('en')));
    await tester.pumpAndSettle();
    expect(find.text('Tap outside a field to close the keyboard.'), findsNothing);
  });

  group('SignUpData', () {
    final formValue = <String, dynamic>{
      SignUpFields.name: '  Ada Lovelace ',
      SignUpFields.email: 'ada@example.com',
      SignUpFields.password: 'password123',
      SignUpFields.role: 'user',
      SignUpFields.acceptTerms: true,
      SignUpFields.birthDate: null,
    };

    test('fromFormValue trims and equals an identical model', () {
      expect(
        SignUpData.fromFormValue(formValue),
        const SignUpData(
          name: 'Ada Lovelace',
          email: 'ada@example.com',
          password: 'password123',
          role: 'user',
          acceptedTerms: true,
        ),
      );
    });

    test('toString never contains the password', () {
      expect(SignUpData.fromFormValue(formValue).toString(), isNot(contains('password123')));
    });
  });
}
