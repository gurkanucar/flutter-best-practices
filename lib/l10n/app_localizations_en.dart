// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Flutter Best Practices';

  @override
  String get language => 'Language';

  @override
  String get systemLanguage => 'System language';

  @override
  String get hello => 'Hello!';

  @override
  String welcome(String name) {
    return 'Welcome, $name!';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }

  @override
  String userRole(String role) {
    String _temp0 = intl.Intl.selectLogic(role, {
      'admin': 'Administrator',
      'user': 'User',
      'other': 'Guest',
    });
    return '$_temp0';
  }

  @override
  String lastLogin(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Last login: $dateString';
  }

  @override
  String price(double amount) {
    final intl.NumberFormat amountNumberFormat = intl.NumberFormat.currency(
      locale: localeName,
      name: 'TRY',
      decimalDigits: 2,
    );
    final String amountString = amountNumberFormat.format(amount);

    return 'Price: $amountString';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationChannelName => 'General';

  @override
  String get showNotification => 'Show notification';

  @override
  String scheduleNotification(int seconds) {
    return 'Schedule in $seconds seconds';
  }

  @override
  String get cancelNotifications => 'Cancel all';

  @override
  String get notificationTitle => 'Hello from Flutter Best Practices';

  @override
  String get notificationBody => 'This is a local notification.';

  @override
  String notificationScheduled(int seconds) {
    return 'Notification scheduled in $seconds seconds';
  }

  @override
  String get notificationPermissionDenied => 'Notification permission denied';

  @override
  String get schedulingNotSupported =>
      'Scheduled notifications are not supported on this platform';

  @override
  String lastTappedNotification(String payload) {
    return 'Last tapped notification: $payload';
  }

  @override
  String get setAlarm => 'Set alarm at date & time';

  @override
  String get alarmChannelName => 'Alarms';

  @override
  String get alarmTitle => 'Alarm';

  @override
  String get alarmBody => 'Time\'s up!';

  @override
  String alarmScheduled(DateTime date, DateTime time) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);
    final intl.DateFormat timeDateFormat = intl.DateFormat.jm(localeName);
    final String timeString = timeDateFormat.format(time);

    return 'Alarm set for $dateString $timeString';
  }

  @override
  String get alarmTimeInPast => 'Pick a time in the future';

  @override
  String get alarmInexact =>
      'Exact alarm permission not granted — the alarm may be delayed';

  @override
  String get demos => 'Demos';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get unknown => 'Unknown';

  @override
  String loadError(String error) {
    return 'Could not load: $error';
  }

  @override
  String get openSettings => 'Settings';

  @override
  String get deviceInfoTitle => 'Device info';

  @override
  String get deviceInfoPlatform => 'Platform';

  @override
  String get deviceInfoModel => 'Model';

  @override
  String get deviceInfoOsVersion => 'OS version';

  @override
  String get deviceInfoPhysicalDevice => 'Physical device';

  @override
  String get deviceInfoRawData => 'All data';

  @override
  String get connectivityTitle => 'Connectivity';

  @override
  String get connectivityOnline => 'Connected to a network';

  @override
  String get connectivityOffline => 'No network connection';

  @override
  String connectivityTypes(String types) {
    return 'Connection types: $types';
  }

  @override
  String get connectivityNoInternetGuarantee =>
      'A network connection doesn\'t guarantee internet access (e.g. hotel Wi-Fi login pages).';

  @override
  String get connectivityCheckAgain => 'Check again';

  @override
  String get connectivityOpenWifiSettings => 'Wi-Fi settings';

  @override
  String get appSettingsTitle => 'System settings';

  @override
  String get appSettingsUnsupported =>
      'Opening system settings is only supported on Android, iOS and macOS.';

  @override
  String get appSettingsApp => 'App info';

  @override
  String get appSettingsAlarms => 'Alarms & reminders (Android 12+)';

  @override
  String get appSettingsLanguage => 'App language (Android 13+)';

  @override
  String get appSettingsLocation => 'Location';

  @override
  String get appSettingsWifi => 'Wi-Fi';

  @override
  String get appSettingsBluetooth => 'Bluetooth';

  @override
  String get appSettingsBattery => 'Battery optimization';

  @override
  String get appSettingsPanels => 'Quick panels (Android 10+)';

  @override
  String get appSettingsPanelInternet => 'Internet';

  @override
  String get appSettingsPanelVolume => 'Volume';

  @override
  String get formTitle => 'Sign-up form';

  @override
  String get formName => 'Full name';

  @override
  String get formEmail => 'Email';

  @override
  String get formPassword => 'Password';

  @override
  String get formConfirmPassword => 'Confirm password';

  @override
  String get formPasswordsDoNotMatch => 'Passwords don\'t match';

  @override
  String get formBirthDate => 'Birth date';

  @override
  String get formRole => 'Role';

  @override
  String get formAcceptTerms => 'I accept the terms';

  @override
  String get formTermsRequired => 'You must accept the terms';

  @override
  String get formSubmit => 'Submit';

  @override
  String get formReset => 'Reset';

  @override
  String get formSubmitted => 'Form submitted';

  @override
  String get formInvalid => 'Please fix the errors';

  @override
  String get keyboardVisible => 'Keyboard is open';

  @override
  String get keyboardHidden => 'Keyboard is closed';

  @override
  String get keyboardTip => 'Tap outside a field to close the keyboard.';
}
