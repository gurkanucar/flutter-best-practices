import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'home_page.dart';
import 'l10n/app_localizations.dart';
import 'l10n/supported_languages.dart';
import 'notifications/notification_service.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    await NotificationService.instance.init();
  } catch (error, stackTrace) {
    // e.g. a browser without Notification/Service Worker support — the app still starts.
    debugPrint('Notification init failed: $error\n$stackTrace');
  }

  runApp(const MainApp());
  FlutterNativeSplash.remove();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale?>(
      valueListenable: localeNotifier,
      builder: (context, locale, _) => MaterialApp(
        locale: locale,
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const HomePage(),
      ),
    );
  }
}
