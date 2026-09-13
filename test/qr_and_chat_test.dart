import 'package:flutter_best_practices/chat/chat_demo_page.dart';
import 'package:flutter_best_practices/l10n/app_localization_delegates.dart';
import 'package:flutter_best_practices/l10n/app_localizations.dart';
import 'package:flutter_best_practices/qr/qr_code_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:qr_flutter/qr_flutter.dart';

Widget wrap(Widget child) => MaterialApp(
      localizationsDelegates: appLocalizationDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    );

void main() {
  testWidgets('QR code renders and reports data that is too long', (tester) async {
    await tester.pumpWidget(wrap(const QrCodePage()));
    await tester.pumpAndSettle();
    expect(find.byType(QrImageView), findsOneWidget);
    expect(find.textContaining('Version'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'a' * 3000);
    await tester.pumpAndSettle();
    expect(find.text('Too much data for a QR code'), findsOneWidget);
  });

  testWidgets('chat shows the sent message and the bot reply', (tester) async {
    await tester.pumpWidget(wrap(const ChatDemoPage()));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.enterText(find.byType(TextField), 'Hello');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Hello'), findsOneWidget);
    expect(find.text('Bot is typing…'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('You said: Hello'), findsOneWidget);
    expect(find.text('Bot is typing…'), findsNothing);
  });
}
