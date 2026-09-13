import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// App name shown in task switcher / browser tab
  ///
  /// In en, this message translates to:
  /// **'Flutter Best Practices'**
  String get appTitle;

  /// Tooltip of the language selector
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Language menu item that follows the device language
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get systemLanguage;

  /// A simple greeting
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get hello;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}!'**
  String welcome(String name);

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String itemCount(int count);

  /// No description provided for @userRole.
  ///
  /// In en, this message translates to:
  /// **'{role, select, admin{Administrator} user{User} other{Guest}}'**
  String userRole(String role);

  /// No description provided for @lastLogin.
  ///
  /// In en, this message translates to:
  /// **'Last login: {date}'**
  String lastLogin(DateTime date);

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price: {amount}'**
  String price(double amount);

  /// Title of the notification demo section
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Android notification channel name, shown in system app settings
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get notificationChannelName;

  /// Button that shows a notification immediately
  ///
  /// In en, this message translates to:
  /// **'Show notification'**
  String get showNotification;

  /// Button that schedules a notification
  ///
  /// In en, this message translates to:
  /// **'Schedule in {seconds} seconds'**
  String scheduleNotification(int seconds);

  /// Button that cancels all notifications
  ///
  /// In en, this message translates to:
  /// **'Cancel all'**
  String get cancelNotifications;

  /// Title of the demo notification
  ///
  /// In en, this message translates to:
  /// **'Hello from Flutter Best Practices'**
  String get notificationTitle;

  /// Body of the demo notification
  ///
  /// In en, this message translates to:
  /// **'This is a local notification.'**
  String get notificationBody;

  /// Snackbar after scheduling a notification
  ///
  /// In en, this message translates to:
  /// **'Notification scheduled in {seconds} seconds'**
  String notificationScheduled(int seconds);

  /// Snackbar when the user denies notification permission
  ///
  /// In en, this message translates to:
  /// **'Notification permission denied'**
  String get notificationPermissionDenied;

  /// Shown on web and Linux, which have no scheduler
  ///
  /// In en, this message translates to:
  /// **'Scheduled notifications are not supported on this platform'**
  String get schedulingNotSupported;

  /// Payload of the notification the user tapped
  ///
  /// In en, this message translates to:
  /// **'Last tapped notification: {payload}'**
  String lastTappedNotification(String payload);

  /// Button that opens date and time pickers to schedule an alarm
  ///
  /// In en, this message translates to:
  /// **'Set alarm at date & time'**
  String get setAlarm;

  /// Android notification channel name for alarms, shown in system app settings
  ///
  /// In en, this message translates to:
  /// **'Alarms'**
  String get alarmChannelName;

  /// Title of the alarm notification
  ///
  /// In en, this message translates to:
  /// **'Alarm'**
  String get alarmTitle;

  /// Body of the alarm notification
  ///
  /// In en, this message translates to:
  /// **'Time\'s up!'**
  String get alarmBody;

  /// Snackbar after an exact alarm was scheduled
  ///
  /// In en, this message translates to:
  /// **'Alarm set for {date} {time}'**
  String alarmScheduled(DateTime date, DateTime time);

  /// Snackbar when the picked alarm time has already passed
  ///
  /// In en, this message translates to:
  /// **'Pick a time in the future'**
  String get alarmTimeInPast;

  /// Snackbar when Android exact alarms aren't allowed and the alarm was scheduled inexact
  ///
  /// In en, this message translates to:
  /// **'Exact alarm permission not granted — the alarm may be delayed'**
  String get alarmInexact;

  /// Title of the home page section that links to demo pages
  ///
  /// In en, this message translates to:
  /// **'Demos'**
  String get demos;

  /// Generic yes
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// Generic no
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Value is not available on this platform
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// Generic loading error
  ///
  /// In en, this message translates to:
  /// **'Could not load: {error}'**
  String loadError(String error);

  /// Snackbar action that opens system settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get openSettings;

  /// Title of the device info page
  ///
  /// In en, this message translates to:
  /// **'Device info'**
  String get deviceInfoTitle;

  /// Device info label: operating system family
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get deviceInfoPlatform;

  /// Device info label: device / computer / browser model
  ///
  /// In en, this message translates to:
  /// **'Model'**
  String get deviceInfoModel;

  /// Device info label: operating system version
  ///
  /// In en, this message translates to:
  /// **'OS version'**
  String get deviceInfoOsVersion;

  /// Device info label: real device vs emulator/simulator
  ///
  /// In en, this message translates to:
  /// **'Physical device'**
  String get deviceInfoPhysicalDevice;

  /// Expandable list with every raw device info field
  ///
  /// In en, this message translates to:
  /// **'All data'**
  String get deviceInfoRawData;

  /// Title of the connectivity page
  ///
  /// In en, this message translates to:
  /// **'Connectivity'**
  String get connectivityTitle;

  /// Some network interface is available
  ///
  /// In en, this message translates to:
  /// **'Connected to a network'**
  String get connectivityOnline;

  /// No network interface is available
  ///
  /// In en, this message translates to:
  /// **'No network connection'**
  String get connectivityOffline;

  /// Comma separated list of active connection types
  ///
  /// In en, this message translates to:
  /// **'Connection types: {types}'**
  String connectivityTypes(String types);

  /// Warning that connectivity type is not internet reachability
  ///
  /// In en, this message translates to:
  /// **'A network connection doesn\'t guarantee internet access (e.g. hotel Wi-Fi login pages).'**
  String get connectivityNoInternetGuarantee;

  /// Button that re-checks connectivity
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get connectivityCheckAgain;

  /// Button that opens system Wi-Fi settings
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi settings'**
  String get connectivityOpenWifiSettings;

  /// Title of the page that opens system settings screens
  ///
  /// In en, this message translates to:
  /// **'System settings'**
  String get appSettingsTitle;

  /// Shown on Windows, Linux and web
  ///
  /// In en, this message translates to:
  /// **'Opening system settings is only supported on Android, iOS and macOS.'**
  String get appSettingsUnsupported;

  /// Opens this app's page in system settings
  ///
  /// In en, this message translates to:
  /// **'App info'**
  String get appSettingsApp;

  /// Opens the exact alarm permission screen
  ///
  /// In en, this message translates to:
  /// **'Alarms & reminders (Android 12+)'**
  String get appSettingsAlarms;

  /// Opens the per-app language screen
  ///
  /// In en, this message translates to:
  /// **'App language (Android 13+)'**
  String get appSettingsLanguage;

  /// Opens location settings
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get appSettingsLocation;

  /// Opens Wi-Fi settings
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi'**
  String get appSettingsWifi;

  /// Opens Bluetooth settings
  ///
  /// In en, this message translates to:
  /// **'Bluetooth'**
  String get appSettingsBluetooth;

  /// Opens battery optimization settings (Android)
  ///
  /// In en, this message translates to:
  /// **'Battery optimization'**
  String get appSettingsBattery;

  /// Header for Android settings panels shown over the app
  ///
  /// In en, this message translates to:
  /// **'Quick panels (Android 10+)'**
  String get appSettingsPanels;

  /// Android internet connectivity panel
  ///
  /// In en, this message translates to:
  /// **'Internet'**
  String get appSettingsPanelInternet;

  /// Android volume panel
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get appSettingsPanelVolume;

  /// Title of the form builder demo page
  ///
  /// In en, this message translates to:
  /// **'Sign-up form'**
  String get formTitle;

  /// Form field label
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get formName;

  /// Form field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get formEmail;

  /// Form field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get formPassword;

  /// Form field label
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get formConfirmPassword;

  /// Validation error when confirm password differs
  ///
  /// In en, this message translates to:
  /// **'Passwords don\'t match'**
  String get formPasswordsDoNotMatch;

  /// Form field label
  ///
  /// In en, this message translates to:
  /// **'Birth date'**
  String get formBirthDate;

  /// Form field label for the role dropdown
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get formRole;

  /// Checkbox label
  ///
  /// In en, this message translates to:
  /// **'I accept the terms'**
  String get formAcceptTerms;

  /// Validation error when the terms checkbox is not ticked
  ///
  /// In en, this message translates to:
  /// **'You must accept the terms'**
  String get formTermsRequired;

  /// Form submit button
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get formSubmit;

  /// Form reset button
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get formReset;

  /// Dialog title after a valid submit
  ///
  /// In en, this message translates to:
  /// **'Form submitted'**
  String get formSubmitted;

  /// Snackbar when the form has validation errors
  ///
  /// In en, this message translates to:
  /// **'Please fix the errors'**
  String get formInvalid;

  /// Keyboard visibility status
  ///
  /// In en, this message translates to:
  /// **'Keyboard is open'**
  String get keyboardVisible;

  /// Keyboard visibility status
  ///
  /// In en, this message translates to:
  /// **'Keyboard is closed'**
  String get keyboardHidden;

  /// Hint shown while the keyboard is closed
  ///
  /// In en, this message translates to:
  /// **'Tap outside a field to close the keyboard.'**
  String get keyboardTip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
