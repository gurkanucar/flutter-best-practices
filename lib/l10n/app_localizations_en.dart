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
}
