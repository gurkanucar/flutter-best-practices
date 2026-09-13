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

  @override
  String get setAlarm => 'Tarih ve saatte alarm kur';

  @override
  String get alarmChannelName => 'Alarmlar';

  @override
  String get alarmTitle => 'Alarm';

  @override
  String get alarmBody => 'Zaman doldu!';

  @override
  String alarmScheduled(DateTime date, DateTime time) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMd(localeName);
    final String dateString = dateDateFormat.format(date);
    final intl.DateFormat timeDateFormat = intl.DateFormat.jm(localeName);
    final String timeString = timeDateFormat.format(time);

    return 'Alarm kuruldu: $dateString $timeString';
  }

  @override
  String get alarmTimeInPast => 'İleri bir zaman seç';

  @override
  String get alarmInexact =>
      'Tam zamanlı alarm izni verilmedi — alarm gecikebilir';

  @override
  String get demos => 'Örnekler';

  @override
  String get yes => 'Evet';

  @override
  String get no => 'Hayır';

  @override
  String get unknown => 'Bilinmiyor';

  @override
  String loadError(String error) {
    return 'Yüklenemedi: $error';
  }

  @override
  String get openSettings => 'Ayarlar';

  @override
  String get deviceInfoTitle => 'Cihaz bilgisi';

  @override
  String get deviceInfoPlatform => 'Platform';

  @override
  String get deviceInfoModel => 'Model';

  @override
  String get deviceInfoOsVersion => 'İşletim sistemi sürümü';

  @override
  String get deviceInfoPhysicalDevice => 'Fiziksel cihaz';

  @override
  String get deviceInfoRawData => 'Tüm veriler';

  @override
  String get connectivityTitle => 'Bağlantı durumu';

  @override
  String get connectivityOnline => 'Bir ağa bağlı';

  @override
  String get connectivityOffline => 'Ağ bağlantısı yok';

  @override
  String connectivityTypes(String types) {
    return 'Bağlantı türleri: $types';
  }

  @override
  String get connectivityNoInternetGuarantee =>
      'Ağ bağlantısı internet erişimini garanti etmez (ör. otel Wi-Fi giriş sayfaları).';

  @override
  String get connectivityCheckAgain => 'Tekrar kontrol et';

  @override
  String get connectivityOpenWifiSettings => 'Wi-Fi ayarları';

  @override
  String get appSettingsTitle => 'Sistem ayarları';

  @override
  String get appSettingsUnsupported =>
      'Sistem ayarlarını açmak yalnızca Android, iOS ve macOS\'ta destekleniyor.';

  @override
  String get appSettingsApp => 'Uygulama bilgisi';

  @override
  String get appSettingsAlarms => 'Alarmlar ve anımsatıcılar (Android 12+)';

  @override
  String get appSettingsLanguage => 'Uygulama dili (Android 13+)';

  @override
  String get appSettingsLocation => 'Konum';

  @override
  String get appSettingsWifi => 'Wi-Fi';

  @override
  String get appSettingsBluetooth => 'Bluetooth';

  @override
  String get appSettingsBattery => 'Pil optimizasyonu';

  @override
  String get appSettingsPanels => 'Hızlı paneller (Android 10+)';

  @override
  String get appSettingsPanelInternet => 'İnternet';

  @override
  String get appSettingsPanelVolume => 'Ses düzeyi';

  @override
  String get formTitle => 'Kayıt formu';

  @override
  String get formName => 'Ad soyad';

  @override
  String get formEmail => 'E-posta';

  @override
  String get formPassword => 'Şifre';

  @override
  String get formConfirmPassword => 'Şifre tekrar';

  @override
  String get formPasswordsDoNotMatch => 'Şifreler eşleşmiyor';

  @override
  String get formBirthDate => 'Doğum tarihi';

  @override
  String get formRole => 'Rol';

  @override
  String get formAcceptTerms => 'Koşulları kabul ediyorum';

  @override
  String get formTermsRequired => 'Koşulları kabul etmelisin';

  @override
  String get formSubmit => 'Gönder';

  @override
  String get formReset => 'Sıfırla';

  @override
  String get formSubmitted => 'Form gönderildi';

  @override
  String get formInvalid => 'Lütfen hataları düzeltin';

  @override
  String get keyboardVisible => 'Klavye açık';

  @override
  String get keyboardHidden => 'Klavye kapalı';

  @override
  String get keyboardTip => 'Klavyeyi kapatmak için alanın dışına dokun.';
}
