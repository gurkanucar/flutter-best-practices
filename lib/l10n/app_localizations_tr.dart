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

  @override
  String get environmentTitle => 'Ortam';

  @override
  String get envFlavor => 'Ortam türü';

  @override
  String get envDefault => 'varsayılan — env dosyası verilmedi';

  @override
  String get envBuildMode => 'Derleme modu';

  @override
  String get envApiBaseUrl => 'API adresi';

  @override
  String get envLogging => 'Loglama';

  @override
  String get envCrashReporting => 'Hata raporlama';

  @override
  String get envNotSet => 'Ayarlanmamış';

  @override
  String get envSecretWarning =>
      'Bu değerler derleme sırasında --dart-define-from-file ile gelir ve uygulamanın içine gömülür. Buraya asla gizli bilgi koyma.';

  @override
  String get formFieldsTitle => 'Tüm form alanları';

  @override
  String get fieldsSectionDateTime => 'Tarih ve saat';

  @override
  String get fieldsMeetingTime => 'Toplantı saati';

  @override
  String get fieldsAppointment => 'Randevu (tarih + saat)';

  @override
  String get fieldsTripDates => 'Seyahat tarihleri';

  @override
  String get fieldsSectionNumbers => 'Kaydırıcılar ve sayılar';

  @override
  String get fieldsVolume => 'Ses düzeyi';

  @override
  String get fieldsPriceRange => 'Fiyat aralığı';

  @override
  String get fieldsAge => 'Yaş (isteğe bağlı)';

  @override
  String get fieldsSectionChoices => 'Seçimler';

  @override
  String get fieldsNewsletter => 'Bültene abone ol';

  @override
  String get fieldsContactMethod => 'Tercih edilen iletişim';

  @override
  String get fieldsContactPhone => 'Telefon';

  @override
  String get fieldsContactSms => 'SMS';

  @override
  String get fieldsPhone => 'Telefon numarası';

  @override
  String get fieldsInterests => 'İlgi alanları (en az bir tane seç)';

  @override
  String get fieldsInterestDesign => 'Tasarım';

  @override
  String get fieldsSize => 'Tişört bedeni';

  @override
  String get fieldsToppings => 'Pizza malzemeleri';

  @override
  String get fieldsToppingCheese => 'Peynir';

  @override
  String get fieldsToppingMushroom => 'Mantar';

  @override
  String get fieldsToppingOlive => 'Zeytin';

  @override
  String get fieldsToppingPepper => 'Biber';

  @override
  String get fieldsSectionCustom => 'Özel ve dinamik alanlar';

  @override
  String get fieldsRating => 'Puan';

  @override
  String get fieldsFavoriteColor => 'Favori renk';

  @override
  String get fieldsNotes => 'Notlar';

  @override
  String fieldsGuestName(int number) {
    return '$number. misafir';
  }

  @override
  String get fieldsAddGuest => 'Misafir ekle';

  @override
  String get fieldsRemoveGuest => 'Misafiri kaldır';

  @override
  String get fieldsFillExample => 'Örnek doldur';

  @override
  String get fieldsResult => 'Form değerleri';

  @override
  String get cancel => 'İptal';

  @override
  String get biometricTitle => 'Biyometrik doğrulama';

  @override
  String get biometricUnsupported =>
      'local_auth yalnızca Android, iOS, macOS ve Windows\'ta çalışır.';

  @override
  String get biometricDeviceSupported =>
      'Cihaz güvenli doğrulamayı destekliyor';

  @override
  String get biometricHardware => 'Biyometrik donanım';

  @override
  String biometricEnrolled(String types) {
    return 'Kayıtlı: $types';
  }

  @override
  String get biometricNone => 'yok';

  @override
  String get biometricAuthenticate => 'Doğrula (biyometri veya cihaz PIN\'i)';

  @override
  String get biometricOnlyAuthenticate => 'Yalnızca biyometri';

  @override
  String get biometricReason => 'Güvenli alanı açmak için kimliğini doğrula';

  @override
  String get biometricPromptTitle => 'Doğrulama gerekli';

  @override
  String get biometricPromptHint => 'Kimliğini doğrula';

  @override
  String get biometricSuccess => 'Doğrulandı';

  @override
  String get biometricFailed => 'Doğrulanmadı';

  @override
  String biometricError(String details) {
    return 'Hata: $details';
  }

  @override
  String get reviewTitle => 'Uygulama içi değerlendirme';

  @override
  String get reviewUnsupported =>
      'in_app_review yalnızca Android, iOS ve macOS\'ta çalışır (mağaza sayfası Windows\'ta da açılır).';

  @override
  String reviewAvailable(String value) {
    return 'Değerlendirme penceresi kullanılabilir: $value';
  }

  @override
  String get reviewWillAsk =>
      'Değerlendirme penceresi 3 işlem tamamlandıktan sonra otomatik istenir (asla bir \"Puan ver\" butonundan değil).';

  @override
  String get reviewCompleteAction => 'Bir işlem tamamla';

  @override
  String reviewProgress(int count) {
    return 'Tamamlanan işlemler: $count';
  }

  @override
  String get reviewRequested =>
      'Değerlendirme istendi — pencerenin gösterilip gösterilmeyeceğine sistem karar verir.';

  @override
  String get reviewOpenStore => 'Mağaza sayfasını aç (Puan ver)';

  @override
  String get reviewStoreIdMissing =>
      'Bu platformda mağaza sayfasını açmak için InAppReviewPage içindeki mağaza kimliğini ayarla.';

  @override
  String get threeDTitle => '3D görüntüleyici (ditredi)';

  @override
  String get threeDCube => 'Küp';

  @override
  String get threeDModel => 'OBJ model';

  @override
  String get threeDHint =>
      'Döndürmek için sürükle, yakınlaştırmak için sıkıştır veya kaydır.';

  @override
  String get threeDReset => 'Görünümü sıfırla';

  @override
  String get next => 'İleri';

  @override
  String get previous => 'Geri';

  @override
  String get skip => 'Geç';

  @override
  String get done => 'Bitti';

  @override
  String get otpTitle => 'Doğrulama kodu (pinput)';

  @override
  String get otpInstruction =>
      'Telefonuna gönderdiğimiz 4 haneli kodu gir. Demo kodu: 2222';

  @override
  String get otpInvalid => 'Kod hatalı';

  @override
  String get otpVerified => 'Kod doğrulandı';

  @override
  String get otpVerify => 'Doğrula';

  @override
  String get otpClear => 'Temizle';

  @override
  String get otpObscured => 'Gizli PIN (6 hane)';

  @override
  String get onboardingTitle => 'Tanıtım ekranı (introduction_screen)';

  @override
  String get onboardingPage1Title => 'Hoş geldin';

  @override
  String get onboardingPage1Body =>
      'Flutter uygulamaları için en iyi pratikler tek bir yerde.';

  @override
  String get onboardingPage2Title => 'Her yerde çalışır';

  @override
  String get onboardingPage2Body =>
      'Tek kod tabanıyla Android, iOS, web ve masaüstü.';

  @override
  String get onboardingPage3Title => 'Hazır mısın?';

  @override
  String get onboardingPage3Body => 'Örnekleri keşfetmek için Bitti\'ye dokun.';

  @override
  String get tourTitle => 'Özellik turu (showcaseview)';

  @override
  String get tourStart => 'Turu başlat';

  @override
  String get tourSearchTitle => 'Arama';

  @override
  String get tourSearchBody => 'Herhangi bir örneği hızlıca bul.';

  @override
  String get tourListTitle => 'Öğeler';

  @override
  String get tourListBody => 'Ayrıntılarını açmak için bir öğeye dokun.';

  @override
  String get tourFabTitle => 'Oluştur';

  @override
  String get tourFabBody => 'Buradan yeni öğe ekle.';

  @override
  String get tourFinished => 'Tur bitti';

  @override
  String tourItem(int number) {
    return 'Öğe $number';
  }

  @override
  String get tiltTitle => 'Eğim efekti (flutter_tilt)';

  @override
  String get tiltHint =>
      'İmleci kartın üzerinde gezdir, sürükle veya telefonunu eğ.';

  @override
  String get tiltSensors => 'Cihaz sensörlerini kullan (Android, iOS, web)';

  @override
  String get tiltCardSubtitle =>
      'Paralaks katmanlar eğimle birlikte hareket eder';

  @override
  String get ttsTitle => 'Metin okuma (flutter_tts)';

  @override
  String get ttsUnsupported => 'Bu platformda metin okuma kullanılamıyor.';

  @override
  String get ttsSampleText => 'Merhaba! Bu metin seçtiğin dilde sesli okunur.';

  @override
  String get ttsText => 'Metin';

  @override
  String get ttsLanguage => 'Konuşma dili';

  @override
  String get ttsVoice => 'Ses';

  @override
  String get ttsDefaultVoice => 'Varsayılan ses';

  @override
  String get ttsRate => 'Hız';

  @override
  String get ttsPitch => 'Ses tonu';

  @override
  String get ttsVolume => 'Ses düzeyi';

  @override
  String get ttsSpeak => 'Oku';

  @override
  String get ttsPause => 'Duraklat';

  @override
  String get ttsStop => 'Durdur';

  @override
  String get ttsNoLanguages =>
      'Konuşma dili bulunamadı. Bir metin okuma motoru veya ses verisi yükle.';

  @override
  String ttsLanguageUnavailable(String language) {
    return '$language konuşma motoru tarafından desteklenmiyor.';
  }

  @override
  String ttsLanguageNotInstalled(String language) {
    return '$language ses verisi indirilmemiş. Sistemin metin okuma ayarlarından yükle.';
  }

  @override
  String ttsError(String details) {
    return 'Okuma hatası: $details';
  }

  @override
  String get sttTitle => 'Sesi yazıya çevirme (speech_to_text)';

  @override
  String get sttUnsupported => 'Bu platformda konuşma tanıma kullanılamıyor.';

  @override
  String get sttWindowsBeta =>
      'Windows desteği beta: yalnızca İngilizce ve canlı kullanıma hazır değil.';

  @override
  String get sttPermissionDenied =>
      'Mikrofon izni reddedildi. Uygulama ayarlarından izin ver.';

  @override
  String get sttUnavailable => 'Bu cihazda konuşma tanıma kullanılamıyor.';

  @override
  String get sttOpenSettings => 'Uygulama ayarlarını aç';

  @override
  String get sttNoLocales =>
      'Tanıyıcı dil listesi vermedi; cihaz dili kullanılıyor.';

  @override
  String get sttLanguage => 'Tanıma dili';

  @override
  String get sttStart => 'Dinlemeye başla';

  @override
  String get sttStop => 'Dinlemeyi durdur';

  @override
  String get sttListening => 'Dinleniyor…';

  @override
  String get sttTapToSpeak => 'Mikrofona dokun ve konuş';

  @override
  String get sttEmpty => 'Tanınan metin burada görünür';

  @override
  String get sttFinal => 'Kesin';

  @override
  String get sttPartial => 'Ara sonuç';

  @override
  String sttConfidence(int percent) {
    return 'Güven %$percent';
  }

  @override
  String get sttNoMatch => 'Hiçbir şey tanınmadı. Tekrar dene.';

  @override
  String get screenProtectorTitle =>
      'Ekran görüntüsü koruması (screen_protector)';

  @override
  String get screenProtectorUnsupported =>
      'screen_protector yalnızca Android ve iOS\'u destekler.';

  @override
  String get screenProtectorCardTitle => 'Hassas veri';

  @override
  String get screenProtectorBlock => 'Ekran görüntüsünü ve kaydını engelle';

  @override
  String get screenProtectorBlockAndroid =>
      'Ekran görüntüleri ve kayıtlar siyah çıkar, uygulama son uygulamalarda gizlenir.';

  @override
  String get screenProtectorBlockIos =>
      'Ekran görüntüleri ve kayıtlar boş ekran gösterir.';

  @override
  String get screenProtectorBlur => 'Uygulama değiştiricide bulanıklaştır';

  @override
  String screenProtectorScreenshots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ekran görüntüsü algılandı',
      zero: 'Ekran görüntüsü algılanmadı',
    );
    return '$_temp0';
  }

  @override
  String get screenProtectorRecording => 'Ekran kaydediliyor veya yansıtılıyor';

  @override
  String get screenProtectorNotRecording => 'Ekran kaydedilmiyor';

  @override
  String get qrTitle => 'QR kod (qr_flutter)';

  @override
  String get qrData => 'İçerik';

  @override
  String qrCharacters(int count) {
    return '$count karakter';
  }

  @override
  String get qrTooLong => 'QR kod için veri çok uzun';

  @override
  String qrInfo(int version, int modules) {
    return 'Sürüm $version · $modules×$modules modül';
  }

  @override
  String get qrErrorCorrection => 'Hata düzeltme';

  @override
  String get qrRounded => 'Yuvarlak modüller';

  @override
  String get qrLogo => 'Ortada logo';

  @override
  String get qrLogoHint =>
      'Kod okunabilir kalsın diye H hata düzeltme seviyesi kullanılır';

  @override
  String get qrExport => 'PNG olarak dışa aktar';

  @override
  String qrExported(int kb) {
    return 'PNG oluşturuldu ($kb KB)';
  }

  @override
  String get chatTitle => 'Sohbet (flutter_chat_ui)';

  @override
  String get chatWelcome => 'Merhaba! Bir mesaj gönder, cevap vereyim.';

  @override
  String chatEcho(String text) {
    return 'Şunu yazdın: $text';
  }

  @override
  String get chatHint => 'Mesaj yaz';

  @override
  String get chatTyping => 'Bot yazıyor…';

  @override
  String get chatEmpty => 'Henüz mesaj yok';

  @override
  String get storiesTitle => 'Hikayeler (story_view)';

  @override
  String get storiesHint =>
      'Bir hikayeye dokun. Sağa/sola dokunarak geç, basılı tutarak duraklat, aşağı kaydırarak kapat.';

  @override
  String get storyGroupWelcome => 'Hoş geldin';

  @override
  String get storyGroupPhotos => 'Fotoğraflar';

  @override
  String get storyWelcome => 'Hikayelere hoş geldin!';

  @override
  String get storyHowTo =>
      'İlerlemek için dokun, duraklatmak için basılı tut, kapatmak için aşağı kaydır.';

  @override
  String get storyAssetCaption =>
      'Görseller asset\'lerden veya bellekten de gelebilir';

  @override
  String get storyCaptionMountains => 'Ağdan gelen görseller önbelleğe alınır';

  @override
  String get storyCaptionCity => 'Hikaye, görsel yüklenene kadar bekler';

  @override
  String get storyCaptionVideo => 'Video hikaye (Android, iOS, macOS)';

  @override
  String get cropTitle => 'Görsel kırpma (image_cropper)';

  @override
  String get cropUnsupported =>
      'image_cropper yalnızca Android, iOS ve web\'i destekler.';

  @override
  String get cropCircle => 'Daire kırpma (profil fotoğrafı)';

  @override
  String get cropCircleHint => '1:1 oranı ve yuvarlak çerçeveyi sabitler';

  @override
  String get cropPickGallery => 'Galeriden seç';

  @override
  String get cropPickCamera => 'Fotoğraf çek';

  @override
  String get cropEmpty => 'Kırpmak için bir görsel seç.';

  @override
  String get cropRotateLeft => 'Sola döndür';

  @override
  String get cropRotateRight => 'Sağa döndür';

  @override
  String get cropApply => 'Kırp';

  @override
  String cropResultSize(int kb) {
    return 'Kırpılan: $kb KB';
  }

  @override
  String cropResultSizes(int kb, int originalKb) {
    return 'Kırpılan: $kb KB (orijinal $originalKb KB)';
  }

  @override
  String get docScanTitle => 'Belge tarayıcı (flutter_doc_scanner)';

  @override
  String get docScanUnsupported =>
      'Belge tarayıcı yalnızca Android ve iOS\'u destekler.';

  @override
  String get docScanIntro =>
      'Sistem tarayıcısı kenarları bulur, perspektifi düzeltir ve sayfa eklemeye izin verir.';

  @override
  String docScanPageLimit(int count) {
    return 'Sayfa sınırı: $count';
  }

  @override
  String get docScanImages => 'Görsel olarak tara';

  @override
  String get docScanPdf => 'PDF olarak tara';

  @override
  String docScanPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sayfa',
    );
    return '$_temp0';
  }

  @override
  String get docScanPdfReady => 'PDF oluşturuldu';

  @override
  String get idsTitle => 'Benzersiz kimlikler (uuid, nanoid, flutter_udid)';

  @override
  String get idsCopy => 'Kopyala';

  @override
  String get idsCopied => 'Kopyalandı';

  @override
  String get idsGenerate => 'Üret';

  @override
  String get idsUuidTitle => 'UUID';

  @override
  String get idsUuidBody =>
      'Merkezi bir sayaç olmadan dünya çapında benzersiz — istemci çevrimdışıyken de kimlik üretebilir.';

  @override
  String get idsV4Hint =>
      'v4: tamamen rastgele. Sıra önemli değilse iyi bir varsayılan.';

  @override
  String get idsV7Hint =>
      'v7: zaman damgasıyla başlar, oluşturulma sırasına göre sıralanır. Veritabanı anahtarları için en iyisi.';

  @override
  String get idsV5Title => 'İsim tabanlı UUID (v5)';

  @override
  String get idsV5Body => 'Aynı isim her zaman aynı UUID\'yi verir.';

  @override
  String get idsV5Name => 'İsim (URL namespace)';

  @override
  String get idsValidateTitle => 'UUID doğrula';

  @override
  String get idsValidateLabel => 'UUID';

  @override
  String get idsValidateHint => 'Kontrol etmek için bir UUID yapıştır';

  @override
  String get idsInvalid => 'Geçerli bir UUID değil';

  @override
  String idsValid(int version) {
    return 'Geçerli UUID (sürüm $version)';
  }

  @override
  String get idsNanoTitle => 'Nano ID';

  @override
  String get idsNanoBody =>
      'Özel alfabe ve uzunlukla daha kısa, URL\'de güvenli rastgele kimlikler.';

  @override
  String get idsNanoDefault => 'Varsayılan (21 karakter)';

  @override
  String get idsOrderCode => 'Sipariş kodu (0/O/1/I yok)';

  @override
  String get idsDeviceTitle => 'Cihaz kimliği (flutter_udid)';

  @override
  String get idsDeviceBody =>
      'Hash\'lenmiş platform kimliği. Genelde yeniden yüklemede korunur, fabrika ayarlarına dönünce değişir. Kişisel veri gibi davran.';

  @override
  String get idsDeviceUnsupported => 'Web\'de kullanılamaz.';
}
