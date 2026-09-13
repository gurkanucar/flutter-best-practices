// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Flutter Best Practices';

  @override
  String get language => 'Dil';

  @override
  String get systemLanguage => 'Sistem dili';

  @override
  String get hello => 'Merhaba!';

  @override
  String welcome(String name) {
    return 'Hoş geldin, $name!';
  }

  @override
  String itemCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count öğe',
      one: '1 öğe',
      zero: 'Öğe yok',
    );
    return '$_temp0';
  }

  @override
  String userRole(String role) {
    String _temp0 = intl.Intl.selectLogic(role, {
      'admin': 'Yönetici',
      'user': 'Kullanıcı',
      'other': 'Misafir',
    });
    return '$_temp0';
  }

  @override
  String lastLogin(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Son giriş: $dateString';
  }

  @override
  String price(double amount) {
    final intl.NumberFormat amountNumberFormat = intl.NumberFormat.currency(
      locale: localeName,
      name: 'TRY',
      decimalDigits: 2,
    );
    final String amountString = amountNumberFormat.format(amount);

    return 'Fiyat: $amountString';
  }

  @override
  String get notifications => 'Bildirimler';

  @override
  String get notificationChannelName => 'Genel';

  @override
  String get showNotification => 'Bildirim göster';

  @override
  String scheduleNotification(int seconds) {
    return '$seconds saniye sonra planla';
  }

  @override
  String get cancelNotifications => 'Tümünü iptal et';

  @override
  String get notificationTitle => 'Flutter Best Practices\'ten merhaba';

  @override
  String get notificationBody => 'Bu bir yerel bildirim.';

  @override
  String notificationScheduled(int seconds) {
    return 'Bildirim $seconds saniye sonra gösterilecek';
  }

  @override
  String get notificationPermissionDenied => 'Bildirim izni verilmedi';

  @override
  String get schedulingNotSupported =>
      'Planlı bildirimler bu platformda desteklenmiyor';

  @override
  String lastTappedNotification(String payload) {
    return 'Son dokunulan bildirim: $payload';
  }
}
