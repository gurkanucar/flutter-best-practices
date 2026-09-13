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

  @override
  String get navHome => 'Ana sayfa';

  @override
  String get navProducts => 'Ürünler';

  @override
  String get navProfile => 'Profil';

  @override
  String get loginTitle => 'Giriş yap';

  @override
  String get loginUserName => 'Kullanıcı adı';

  @override
  String get loginButton => 'Giriş yap';

  @override
  String loginRequiredFor(String location) {
    return '$location sayfasını açmak için giriş yap';
  }

  @override
  String get logout => 'Çıkış yap';

  @override
  String profileGreeting(String name) {
    return '$name olarak giriş yapıldı';
  }

  @override
  String get profileEdit => 'Adı düzenle';

  @override
  String get profileNameUpdated => 'Ad güncellendi';

  @override
  String appVersion(String version, String buildNumber) {
    return 'Sürüm $version ($buildNumber)';
  }

  @override
  String get save => 'Kaydet';

  @override
  String get productsSortName => 'Ada göre';

  @override
  String get productsSortPrice => 'Fiyata göre';

  @override
  String get productBuy => 'Satın al';

  @override
  String get productPassedWithExtra =>
      'Ürün nesnesi extra ile geldi (arama yapılmadı).';

  @override
  String get productLoadedById => 'Ürün URL\'deki id ile bulundu.';

  @override
  String productNotFound(String id) {
    return '$id numaralı ürün bulunamadı';
  }

  @override
  String get checkoutTitle => 'Ödeme';

  @override
  String get checkoutPlaceOrder => 'Siparişi ver';

  @override
  String get orderCompleteTitle => 'Sipariş tamamlandı';

  @override
  String orderCompleteMessage(String orderId) {
    return '#$orderId numaralı sipariş alındı. Bu sayfada geri gitmek kapalı.';
  }

  @override
  String get backToHome => 'Ana sayfaya dön';

  @override
  String get notFoundTitle => 'Sayfa bulunamadı';

  @override
  String notFoundMessage(String location) {
    return '$location için bir sayfa yok';
  }

  @override
  String get discardChangesTitle => 'Sayfadan çıkılsın mı?';

  @override
  String get discardChangesMessage => 'Kaydedilmemiş değişiklikler kaybolacak.';

  @override
  String get discard => 'Çık';

  @override
  String get stay => 'Kal';

  @override
  String get add => 'Ekle';

  @override
  String get hiveTitle => 'Notlar (Hive CE)';

  @override
  String get notesHint => 'Bir not yaz';

  @override
  String get notesEmpty => 'Henüz not yok';

  @override
  String get pin => 'Sabitle';

  @override
  String get unpin => 'Sabitlemeyi kaldır';

  @override
  String get driftTitle => 'Yapılacaklar (Drift)';

  @override
  String get todosHint => 'Yeni görev';

  @override
  String get todosEmpty => 'Yapılacak bir şey yok';

  @override
  String get imagesTitle => 'Görsel seç ve sıkıştır';

  @override
  String get pickFromGallery => 'Galeri';

  @override
  String get pickFromCamera => 'Kamera';

  @override
  String imageOriginal(String size) {
    return 'Orijinal: $size';
  }

  @override
  String imageCompressed(String size, int percent) {
    return 'Sıkıştırılmış: $size (%$percent daha küçük)';
  }

  @override
  String get compressUnsupported =>
      'Görsel sıkıştırma bu platformda desteklenmiyor.';

  @override
  String get noImageSelected => 'Görsel seçilmedi';

  @override
  String get tapToZoom => 'Yakınlaştırmak için görsele dokun.';

  @override
  String get photoViewerTitle => 'Fotoğraf görüntüleyici';

  @override
  String get pdfTitle => 'PDF görüntüleyici';

  @override
  String pdfPage(int page, int count) {
    return 'Sayfa $page / $count';
  }

  @override
  String get previousPage => 'Önceki sayfa';

  @override
  String get nextPage => 'Sonraki sayfa';

  @override
  String get permissionsTitle => 'İzinler';

  @override
  String get permissionsUnsupported =>
      'permission_handler yalnızca Android, iOS, Windows ve web\'de çalışır.';

  @override
  String get permissionsWindowsNote =>
      'Windows\'ta tüm izinler verilmiş olarak görünür.';

  @override
  String get permissionCamera => 'Kamera';

  @override
  String get permissionPhotos => 'Fotoğraflar';

  @override
  String get permissionLocation => 'Konum (kullanırken)';

  @override
  String get permissionBluetoothScan => 'Bluetooth tarama';

  @override
  String get permissionBluetoothConnect => 'Bluetooth bağlantı';

  @override
  String get permissionRequest => 'İste';

  @override
  String get permissionStatusGranted => 'Verildi';

  @override
  String get permissionStatusDenied => 'Reddedildi';

  @override
  String get permissionStatusPermanentlyDenied =>
      'Kalıcı olarak reddedildi — ayarlardan değiştir';

  @override
  String get permissionStatusRestricted => 'Kısıtlı (ör. ebeveyn denetimi)';

  @override
  String get permissionStatusLimited => 'Sınırlı erişim';

  @override
  String get permissionStatusProvisional => 'Geçici';

  @override
  String get bluetoothTitle => 'Bluetooth LE';

  @override
  String get bluetoothUnsupported => 'Bu cihazda Bluetooth LE kullanılamıyor.';

  @override
  String bluetoothAdapterState(String state) {
    return 'Adaptör: $state';
  }

  @override
  String get bluetoothTurnOn => 'Aç';

  @override
  String get bluetoothScan => 'Tara';

  @override
  String get bluetoothStopScan => 'Durdur';

  @override
  String get bluetoothNoDevices => 'Henüz cihaz bulunamadı';

  @override
  String get bluetoothUnnamed => 'İsimsiz cihaz';

  @override
  String get bluetoothConnect => 'Bağlan';

  @override
  String get bluetoothDisconnect => 'Bağlantıyı kes';

  @override
  String bluetoothServices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count servis',
      one: '1 servis',
    );
    return '$_temp0';
  }

  @override
  String get bluetoothLicenseNote =>
      'flutter_blue_plus: ticari kullanım ücretli lisans gerektirir.';
}
