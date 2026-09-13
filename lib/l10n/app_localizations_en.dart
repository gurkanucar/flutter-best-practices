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
}
