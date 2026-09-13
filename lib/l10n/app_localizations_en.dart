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

  @override
  String get navHome => 'Home';

  @override
  String get navProducts => 'Products';

  @override
  String get navProfile => 'Profile';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginUserName => 'User name';

  @override
  String get loginButton => 'Sign in';

  @override
  String loginRequiredFor(String location) {
    return 'Sign in to open $location';
  }

  @override
  String get logout => 'Sign out';

  @override
  String profileGreeting(String name) {
    return 'Signed in as $name';
  }

  @override
  String get profileEdit => 'Edit name';

  @override
  String get profileNameUpdated => 'Name updated';

  @override
  String appVersion(String version, String buildNumber) {
    return 'Version $version ($buildNumber)';
  }

  @override
  String get save => 'Save';

  @override
  String get productsSortName => 'By name';

  @override
  String get productsSortPrice => 'By price';

  @override
  String get productBuy => 'Buy';

  @override
  String get productPassedWithExtra =>
      'Product object passed with extra (no lookup).';

  @override
  String get productLoadedById => 'Product looked up by the id in the URL.';

  @override
  String productNotFound(String id) {
    return 'Product $id not found';
  }

  @override
  String get checkoutTitle => 'Checkout';

  @override
  String get checkoutPlaceOrder => 'Place order';

  @override
  String get orderCompleteTitle => 'Order complete';

  @override
  String orderCompleteMessage(String orderId) {
    return 'Order #$orderId received. Going back is disabled on this page.';
  }

  @override
  String get backToHome => 'Back to home';

  @override
  String get notFoundTitle => 'Page not found';

  @override
  String notFoundMessage(String location) {
    return 'There is no page for $location';
  }

  @override
  String get discardChangesTitle => 'Leave this page?';

  @override
  String get discardChangesMessage => 'Your unsaved changes will be lost.';

  @override
  String get discard => 'Leave';

  @override
  String get stay => 'Stay';

  @override
  String get add => 'Add';

  @override
  String get hiveTitle => 'Notes (Hive CE)';

  @override
  String get notesHint => 'Write a note';

  @override
  String get notesEmpty => 'No notes yet';

  @override
  String get pin => 'Pin';

  @override
  String get unpin => 'Unpin';

  @override
  String get driftTitle => 'Todos (Drift)';

  @override
  String get todosHint => 'New todo';

  @override
  String get todosEmpty => 'Nothing to do';

  @override
  String get imagesTitle => 'Pick & compress images';

  @override
  String get pickFromGallery => 'Gallery';

  @override
  String get pickFromCamera => 'Camera';

  @override
  String imageOriginal(String size) {
    return 'Original: $size';
  }

  @override
  String imageCompressed(String size, int percent) {
    return 'Compressed: $size ($percent% smaller)';
  }

  @override
  String get compressUnsupported =>
      'Image compression isn\'t supported on this platform.';

  @override
  String get noImageSelected => 'No image selected';

  @override
  String get tapToZoom => 'Tap an image to zoom.';

  @override
  String get photoViewerTitle => 'Photo viewer';

  @override
  String get pdfTitle => 'PDF viewer';

  @override
  String pdfPage(int page, int count) {
    return 'Page $page / $count';
  }

  @override
  String get previousPage => 'Previous page';

  @override
  String get nextPage => 'Next page';

  @override
  String get permissionsTitle => 'Permissions';

  @override
  String get permissionsUnsupported =>
      'permission_handler only supports Android, iOS, Windows and web.';

  @override
  String get permissionsWindowsNote =>
      'On Windows every permission is reported as granted.';

  @override
  String get permissionCamera => 'Camera';

  @override
  String get permissionPhotos => 'Photos';

  @override
  String get permissionLocation => 'Location (while in use)';

  @override
  String get permissionBluetoothScan => 'Bluetooth scan';

  @override
  String get permissionBluetoothConnect => 'Bluetooth connect';

  @override
  String get permissionRequest => 'Request';

  @override
  String get permissionStatusGranted => 'Granted';

  @override
  String get permissionStatusDenied => 'Denied';

  @override
  String get permissionStatusPermanentlyDenied =>
      'Permanently denied — change it in settings';

  @override
  String get permissionStatusRestricted =>
      'Restricted (e.g. parental controls)';

  @override
  String get permissionStatusLimited => 'Limited access';

  @override
  String get permissionStatusProvisional => 'Provisional';

  @override
  String get bluetoothTitle => 'Bluetooth LE';

  @override
  String get bluetoothUnsupported =>
      'Bluetooth LE isn\'t available on this device.';

  @override
  String bluetoothAdapterState(String state) {
    return 'Adapter: $state';
  }

  @override
  String get bluetoothTurnOn => 'Turn on';

  @override
  String get bluetoothScan => 'Scan';

  @override
  String get bluetoothStopScan => 'Stop';

  @override
  String get bluetoothNoDevices => 'No devices found yet';

  @override
  String get bluetoothUnnamed => 'Unnamed device';

  @override
  String get bluetoothConnect => 'Connect';

  @override
  String get bluetoothDisconnect => 'Disconnect';

  @override
  String bluetoothServices(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count services',
      one: '1 service',
    );
    return '$_temp0';
  }

  @override
  String get bluetoothLicenseNote =>
      'flutter_blue_plus: commercial use requires a paid license.';

  @override
  String get environmentTitle => 'Environment';

  @override
  String get envFlavor => 'Flavor';

  @override
  String get envDefault => 'default — no env file passed';

  @override
  String get envBuildMode => 'Build mode';

  @override
  String get envApiBaseUrl => 'API base URL';

  @override
  String get envLogging => 'Logging';

  @override
  String get envCrashReporting => 'Crash reporting';

  @override
  String get envNotSet => 'Not set';

  @override
  String get envSecretWarning =>
      'These values come from --dart-define-from-file at build time and are compiled into the app. Never put secrets in them.';

  @override
  String get formFieldsTitle => 'All form fields';

  @override
  String get fieldsSectionDateTime => 'Date & time';

  @override
  String get fieldsMeetingTime => 'Meeting time';

  @override
  String get fieldsAppointment => 'Appointment (date + time)';

  @override
  String get fieldsTripDates => 'Trip dates';

  @override
  String get fieldsSectionNumbers => 'Sliders & numbers';

  @override
  String get fieldsVolume => 'Volume';

  @override
  String get fieldsPriceRange => 'Price range';

  @override
  String get fieldsAge => 'Age (optional)';

  @override
  String get fieldsSectionChoices => 'Choices';

  @override
  String get fieldsNewsletter => 'Subscribe to the newsletter';

  @override
  String get fieldsContactMethod => 'Preferred contact';

  @override
  String get fieldsContactPhone => 'Phone';

  @override
  String get fieldsContactSms => 'SMS';

  @override
  String get fieldsPhone => 'Phone number';

  @override
  String get fieldsInterests => 'Interests (pick at least one)';

  @override
  String get fieldsInterestDesign => 'Design';

  @override
  String get fieldsSize => 'T-shirt size';

  @override
  String get fieldsToppings => 'Pizza toppings';

  @override
  String get fieldsToppingCheese => 'Cheese';

  @override
  String get fieldsToppingMushroom => 'Mushroom';

  @override
  String get fieldsToppingOlive => 'Olive';

  @override
  String get fieldsToppingPepper => 'Pepper';

  @override
  String get fieldsSectionCustom => 'Custom & dynamic fields';

  @override
  String get fieldsRating => 'Rating';

  @override
  String get fieldsFavoriteColor => 'Favorite color';

  @override
  String get fieldsNotes => 'Notes';

  @override
  String fieldsGuestName(int number) {
    return 'Guest $number';
  }

  @override
  String get fieldsAddGuest => 'Add guest';

  @override
  String get fieldsRemoveGuest => 'Remove guest';

  @override
  String get fieldsFillExample => 'Fill example';

  @override
  String get fieldsResult => 'Form values';

  @override
  String get cancel => 'Cancel';

  @override
  String get biometricTitle => 'Biometric authentication';

  @override
  String get biometricUnsupported =>
      'local_auth supports Android, iOS, macOS and Windows.';

  @override
  String get biometricDeviceSupported =>
      'Device supports secure authentication';

  @override
  String get biometricHardware => 'Biometric hardware';

  @override
  String biometricEnrolled(String types) {
    return 'Enrolled: $types';
  }

  @override
  String get biometricNone => 'none';

  @override
  String get biometricAuthenticate => 'Authenticate (biometrics or device PIN)';

  @override
  String get biometricOnlyAuthenticate => 'Biometrics only';

  @override
  String get biometricReason => 'Confirm your identity to open the secure area';

  @override
  String get biometricPromptTitle => 'Authentication required';

  @override
  String get biometricPromptHint => 'Verify identity';

  @override
  String get biometricSuccess => 'Authenticated';

  @override
  String get biometricFailed => 'Not authenticated';

  @override
  String biometricError(String details) {
    return 'Error: $details';
  }

  @override
  String get reviewTitle => 'In-app review';

  @override
  String get reviewUnsupported =>
      'in_app_review supports Android, iOS and macOS (store listing also on Windows).';

  @override
  String reviewAvailable(String value) {
    return 'Review dialog available: $value';
  }

  @override
  String get reviewWillAsk =>
      'The review dialog is requested automatically after 3 completed actions (never from a \"Rate\" button).';

  @override
  String get reviewCompleteAction => 'Complete an action';

  @override
  String reviewProgress(int count) {
    return 'Completed actions: $count';
  }

  @override
  String get reviewRequested =>
      'Review requested — the OS decides whether the dialog is shown.';

  @override
  String get reviewOpenStore => 'Open store listing (Rate us)';

  @override
  String get reviewStoreIdMissing =>
      'Set the store id in InAppReviewPage to open the store listing on this platform.';

  @override
  String get threeDTitle => '3D viewer (ditredi)';

  @override
  String get threeDCube => 'Cube';

  @override
  String get threeDModel => 'OBJ model';

  @override
  String get threeDHint => 'Drag to rotate, pinch or scroll to zoom.';

  @override
  String get threeDReset => 'Reset view';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get skip => 'Skip';

  @override
  String get done => 'Done';

  @override
  String get otpTitle => 'OTP code (pinput)';

  @override
  String get otpInstruction =>
      'Enter the 4-digit code we sent to your phone. Demo code: 2222';

  @override
  String get otpInvalid => 'Wrong code';

  @override
  String get otpVerified => 'Code verified';

  @override
  String get otpVerify => 'Verify';

  @override
  String get otpClear => 'Clear';

  @override
  String get otpObscured => 'Hidden PIN (6 digits)';

  @override
  String get onboardingTitle => 'Onboarding (introduction_screen)';

  @override
  String get onboardingPage1Title => 'Welcome';

  @override
  String get onboardingPage1Body =>
      'Best practices for Flutter apps, in one place.';

  @override
  String get onboardingPage2Title => 'Works everywhere';

  @override
  String get onboardingPage2Body =>
      'Android, iOS, web and desktop from one codebase.';

  @override
  String get onboardingPage3Title => 'Ready?';

  @override
  String get onboardingPage3Body => 'Tap Done to start exploring the demos.';

  @override
  String get tourTitle => 'Feature tour (showcaseview)';

  @override
  String get tourStart => 'Start tour';

  @override
  String get tourSearchTitle => 'Search';

  @override
  String get tourSearchBody => 'Find any demo quickly.';

  @override
  String get tourListTitle => 'Items';

  @override
  String get tourListBody => 'Tap an item to open its details.';

  @override
  String get tourFabTitle => 'Create';

  @override
  String get tourFabBody => 'Add a new item here.';

  @override
  String get tourFinished => 'Tour finished';

  @override
  String tourItem(int number) {
    return 'Item $number';
  }

  @override
  String get tiltTitle => 'Tilt effect (flutter_tilt)';

  @override
  String get tiltHint =>
      'Move the pointer over the card, drag it, or tilt your phone.';

  @override
  String get tiltSensors => 'Use device sensors (Android, iOS, web)';

  @override
  String get tiltCardSubtitle => 'Parallax layers move with the tilt';

  @override
  String get ttsTitle => 'Text to speech (flutter_tts)';

  @override
  String get ttsUnsupported =>
      'Text to speech isn\'t available on this platform.';

  @override
  String get ttsSampleText =>
      'Hello! This text is read aloud in the language you choose.';

  @override
  String get ttsText => 'Text';

  @override
  String get ttsLanguage => 'Speech language';

  @override
  String get ttsVoice => 'Voice';

  @override
  String get ttsDefaultVoice => 'Default voice';

  @override
  String get ttsRate => 'Speed';

  @override
  String get ttsPitch => 'Pitch';

  @override
  String get ttsVolume => 'Volume';

  @override
  String get ttsSpeak => 'Speak';

  @override
  String get ttsPause => 'Pause';

  @override
  String get ttsStop => 'Stop';

  @override
  String get ttsNoLanguages =>
      'No speech languages found. Install a text-to-speech engine or voice data.';

  @override
  String ttsLanguageUnavailable(String language) {
    return '$language isn\'t supported by the speech engine.';
  }

  @override
  String ttsLanguageNotInstalled(String language) {
    return 'Voice data for $language isn\'t downloaded. Install it in the system text-to-speech settings.';
  }

  @override
  String ttsError(String details) {
    return 'Speech error: $details';
  }

  @override
  String get sttTitle => 'Speech to text (speech_to_text)';

  @override
  String get sttUnsupported =>
      'Speech recognition isn\'t available on this platform.';

  @override
  String get sttWindowsBeta =>
      'Windows support is in beta: English only and not ready for production.';

  @override
  String get sttPermissionDenied =>
      'Microphone permission is denied. Allow it in the app settings.';

  @override
  String get sttUnavailable =>
      'Speech recognition isn\'t available on this device.';

  @override
  String get sttOpenSettings => 'Open app settings';

  @override
  String get sttNoLocales =>
      'The recognizer didn\'t report languages; the device language is used.';

  @override
  String get sttLanguage => 'Recognition language';

  @override
  String get sttStart => 'Start listening';

  @override
  String get sttStop => 'Stop listening';

  @override
  String get sttListening => 'Listening…';

  @override
  String get sttTapToSpeak => 'Tap the microphone and speak';

  @override
  String get sttEmpty => 'Recognized text appears here';

  @override
  String get sttFinal => 'Final';

  @override
  String get sttPartial => 'Partial';

  @override
  String sttConfidence(int percent) {
    return 'Confidence $percent%';
  }

  @override
  String get sttNoMatch => 'Nothing was recognized. Try again.';

  @override
  String get screenProtectorTitle => 'Screenshot protection (screen_protector)';

  @override
  String get screenProtectorUnsupported =>
      'screen_protector supports Android and iOS only.';

  @override
  String get screenProtectorCardTitle => 'Sensitive data';

  @override
  String get screenProtectorBlock => 'Block screenshots and screen recording';

  @override
  String get screenProtectorBlockAndroid =>
      'Screenshots and recordings turn black and the app is hidden in recent apps.';

  @override
  String get screenProtectorBlockIos =>
      'Screenshots and recordings show a blank screen.';

  @override
  String get screenProtectorBlur => 'Blur in the app switcher';

  @override
  String screenProtectorScreenshots(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count screenshots detected',
      one: '1 screenshot detected',
      zero: 'No screenshots detected',
    );
    return '$_temp0';
  }

  @override
  String get screenProtectorRecording =>
      'The screen is being recorded or mirrored';

  @override
  String get screenProtectorNotRecording => 'The screen isn\'t being recorded';

  @override
  String get qrTitle => 'QR code (qr_flutter)';

  @override
  String get qrData => 'Content';

  @override
  String qrCharacters(int count) {
    return '$count characters';
  }

  @override
  String get qrTooLong => 'Too much data for a QR code';

  @override
  String qrInfo(int version, int modules) {
    return 'Version $version · $modules×$modules modules';
  }

  @override
  String get qrErrorCorrection => 'Error correction';

  @override
  String get qrRounded => 'Rounded modules';

  @override
  String get qrLogo => 'Logo in the middle';

  @override
  String get qrLogoHint => 'Uses error correction H so the code stays readable';

  @override
  String get qrExport => 'Export as PNG';

  @override
  String qrExported(int kb) {
    return 'PNG created ($kb KB)';
  }

  @override
  String get chatTitle => 'Chat (flutter_chat_ui)';

  @override
  String get chatWelcome => 'Hi! Send a message and I\'ll reply.';

  @override
  String chatEcho(String text) {
    return 'You said: $text';
  }

  @override
  String get chatHint => 'Type a message';

  @override
  String get chatTyping => 'Bot is typing…';

  @override
  String get chatEmpty => 'No messages yet';

  @override
  String get storiesTitle => 'Stories (story_view)';

  @override
  String get storiesHint =>
      'Tap a story. Tap right/left to skip, hold to pause, swipe down to close.';

  @override
  String get storyGroupWelcome => 'Welcome';

  @override
  String get storyGroupPhotos => 'Photos';

  @override
  String get storyWelcome => 'Welcome to stories!';

  @override
  String get storyHowTo =>
      'Tap to go forward, hold to pause, swipe down to close.';

  @override
  String get storyAssetCaption => 'Images can also come from assets or memory';

  @override
  String get storyCaptionMountains => 'Network images are cached';

  @override
  String get storyCaptionCity => 'The story waits until the image is loaded';

  @override
  String get storyCaptionVideo => 'Video story (Android, iOS, macOS)';

  @override
  String get cropTitle => 'Crop image (image_cropper)';

  @override
  String get cropUnsupported =>
      'image_cropper supports Android, iOS and web only.';

  @override
  String get cropCircle => 'Circle crop (profile photo)';

  @override
  String get cropCircleHint => 'Locks a 1:1 ratio with a round overlay';

  @override
  String get cropPickGallery => 'Pick from gallery';

  @override
  String get cropPickCamera => 'Take a photo';

  @override
  String get cropEmpty => 'Pick an image to crop it.';

  @override
  String get cropRotateLeft => 'Rotate left';

  @override
  String get cropRotateRight => 'Rotate right';

  @override
  String get cropApply => 'Crop';

  @override
  String cropResultSize(int kb) {
    return 'Cropped: $kb KB';
  }

  @override
  String cropResultSizes(int kb, int originalKb) {
    return 'Cropped: $kb KB (original $originalKb KB)';
  }

  @override
  String get docScanTitle => 'Document scanner (flutter_doc_scanner)';

  @override
  String get docScanUnsupported =>
      'The document scanner supports Android and iOS only.';

  @override
  String get docScanIntro =>
      'The system scanner detects edges, fixes perspective and lets you add pages.';

  @override
  String docScanPageLimit(int count) {
    return 'Page limit: $count';
  }

  @override
  String get docScanImages => 'Scan as images';

  @override
  String get docScanPdf => 'Scan as PDF';

  @override
  String docScanPages(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages',
      one: '1 page',
    );
    return '$_temp0';
  }

  @override
  String get docScanPdfReady => 'PDF created';

  @override
  String get idsTitle => 'Unique IDs (uuid, nanoid, flutter_udid)';

  @override
  String get idsCopy => 'Copy';

  @override
  String get idsCopied => 'Copied';

  @override
  String get idsGenerate => 'Generate';

  @override
  String get idsUuidTitle => 'UUID';

  @override
  String get idsUuidBody =>
      'Globally unique without a central counter — clients can create ids offline.';

  @override
  String get idsV4Hint =>
      'v4: fully random. Good default when order doesn\'t matter.';

  @override
  String get idsV7Hint =>
      'v7: starts with a timestamp, so ids sort by creation time. Best for database keys.';

  @override
  String get idsV5Title => 'Name-based UUID (v5)';

  @override
  String get idsV5Body => 'The same name always gives the same UUID.';

  @override
  String get idsV5Name => 'Name (URL namespace)';

  @override
  String get idsValidateTitle => 'Validate a UUID';

  @override
  String get idsValidateLabel => 'UUID';

  @override
  String get idsValidateHint => 'Paste a UUID to check it';

  @override
  String get idsInvalid => 'Not a valid UUID';

  @override
  String idsValid(int version) {
    return 'Valid UUID (version $version)';
  }

  @override
  String get idsNanoTitle => 'Nano ID';

  @override
  String get idsNanoBody =>
      'Shorter, URL-safe random ids with a custom alphabet and length.';

  @override
  String get idsNanoDefault => 'Default (21 characters)';

  @override
  String get idsOrderCode => 'Order code (no 0/O/1/I)';

  @override
  String get idsDeviceTitle => 'Device ID (flutter_udid)';

  @override
  String get idsDeviceBody =>
      'Hashed platform id. Survives reinstalls (usually), changes on factory reset. Treat it as personal data.';

  @override
  String get idsDeviceUnsupported => 'Not available on web.';
}
