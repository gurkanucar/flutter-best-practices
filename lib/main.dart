import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'auth/auth_controller.dart';
import 'auth/auth_scope.dart';
import 'l10n/app_localization_delegates.dart';
import 'l10n/app_localizations.dart';
import 'l10n/supported_languages.dart';
import 'notifications/notification_service.dart';
import 'router/app_router.dart';
import 'router/routes.dart';
import 'storage/hive/hive_setup.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  try {
    await NotificationService.instance.init();
  } catch (error, stackTrace) {
    // e.g. a browser without Notification/Service Worker support — the app still starts.
    debugPrint('Notification init failed: $error\n$stackTrace');
  }

  try {
    await initHive(); // opens boxes, restores the saved language
  } catch (error) {
    debugPrint('Hive init failed: $error');
  }

  final auth = AuthController();
  try {
    // Restore before the first route so redirects see the real auth state.
    await auth.restore();
  } catch (error) {
    // e.g. Linux without an unlocked keyring — continue signed out.
    debugPrint('Auth restore failed: $error');
  }

  runApp(MainApp(auth: auth));
  FlutterNativeSplash.remove();
}

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.auth, this.initialLocation = Routes.home});

  final AuthController auth;

  /// Tests start the app at any location.
  final String initialLocation;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  // Created once. Building a new GoRouter on every rebuild resets navigation.
  late final GoRouter _router =
      createAppRouter(widget.auth, initialLocation: widget.initialLocation);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScope(
      notifier: widget.auth,
      child: ValueListenableBuilder<Locale?>(
        valueListenable: localeNotifier,
        builder: (context, locale, _) => MaterialApp.router(
          routerConfig: _router,
          locale: locale,
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          localizationsDelegates: appLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
  }
}
