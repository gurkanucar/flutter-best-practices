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

  /// Bottom navigation tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation tab and product list title
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get navProducts;

  /// Bottom navigation tab and profile title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Login page title
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// Login and edit profile text field label
  ///
  /// In en, this message translates to:
  /// **'User name'**
  String get loginUserName;

  /// Login button
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginButton;

  /// Shown when a protected page redirected to login
  ///
  /// In en, this message translates to:
  /// **'Sign in to open {location}'**
  String loginRequiredFor(String location);

  /// Logout action
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// Current user on the profile page
  ///
  /// In en, this message translates to:
  /// **'Signed in as {name}'**
  String profileGreeting(String name);

  /// Opens the edit profile page
  ///
  /// In en, this message translates to:
  /// **'Edit name'**
  String get profileEdit;

  /// Snackbar after the edit page returned a new name
  ///
  /// In en, this message translates to:
  /// **'Name updated'**
  String get profileNameUpdated;

  /// App version from package_info_plus
  ///
  /// In en, this message translates to:
  /// **'Version {version} ({buildNumber})'**
  String appVersion(String version, String buildNumber);

  /// Generic save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Sort products by name
  ///
  /// In en, this message translates to:
  /// **'By name'**
  String get productsSortName;

  /// Sort products by price
  ///
  /// In en, this message translates to:
  /// **'By price'**
  String get productsSortPrice;

  /// Opens checkout for the product
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get productBuy;

  /// Explains how the detail page got its data
  ///
  /// In en, this message translates to:
  /// **'Product object passed with extra (no lookup).'**
  String get productPassedWithExtra;

  /// Explains how the detail page got its data
  ///
  /// In en, this message translates to:
  /// **'Product looked up by the id in the URL.'**
  String get productLoadedById;

  /// Unknown product id in the URL
  ///
  /// In en, this message translates to:
  /// **'Product {id} not found'**
  String productNotFound(String id);

  /// Checkout page title
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkoutTitle;

  /// Completes the demo order
  ///
  /// In en, this message translates to:
  /// **'Place order'**
  String get checkoutPlaceOrder;

  /// Order complete page title
  ///
  /// In en, this message translates to:
  /// **'Order complete'**
  String get orderCompleteTitle;

  /// Order confirmation; explains the disabled back navigation
  ///
  /// In en, this message translates to:
  /// **'Order #{orderId} received. Going back is disabled on this page.'**
  String orderCompleteMessage(String orderId);

  /// Button that goes to the home page
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backToHome;

  /// 404 page title
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get notFoundTitle;

  /// 404 page message
  ///
  /// In en, this message translates to:
  /// **'There is no page for {location}'**
  String notFoundMessage(String location);

  /// Unsaved changes dialog title
  ///
  /// In en, this message translates to:
  /// **'Leave this page?'**
  String get discardChangesTitle;

  /// Unsaved changes dialog message
  ///
  /// In en, this message translates to:
  /// **'Your unsaved changes will be lost.'**
  String get discardChangesMessage;

  /// Leave the page and discard changes
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get discard;

  /// Stay on the page
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// Generic add button tooltip
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Hive demo page title
  ///
  /// In en, this message translates to:
  /// **'Notes (Hive CE)'**
  String get hiveTitle;

  /// Note input label
  ///
  /// In en, this message translates to:
  /// **'Write a note'**
  String get notesHint;

  /// Empty notes list
  ///
  /// In en, this message translates to:
  /// **'No notes yet'**
  String get notesEmpty;

  /// Pin a note to the top
  ///
  /// In en, this message translates to:
  /// **'Pin'**
  String get pin;

  /// Unpin a note
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpin;

  /// Drift demo page title
  ///
  /// In en, this message translates to:
  /// **'Todos (Drift)'**
  String get driftTitle;

  /// Todo input label
  ///
  /// In en, this message translates to:
  /// **'New todo'**
  String get todosHint;

  /// Empty todo list
  ///
  /// In en, this message translates to:
  /// **'Nothing to do'**
  String get todosEmpty;

  /// image_picker + flutter_image_compress demo title
  ///
  /// In en, this message translates to:
  /// **'Pick & compress images'**
  String get imagesTitle;

  /// Pick an image from the gallery / files
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get pickFromGallery;

  /// Take a photo with the camera
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get pickFromCamera;

  /// Original image size
  ///
  /// In en, this message translates to:
  /// **'Original: {size}'**
  String imageOriginal(String size);

  /// Compressed image size and saving
  ///
  /// In en, this message translates to:
  /// **'Compressed: {size} ({percent}% smaller)'**
  String imageCompressed(String size, int percent);

  /// Shown on Windows and Linux
  ///
  /// In en, this message translates to:
  /// **'Image compression isn\'t supported on this platform.'**
  String get compressUnsupported;

  /// Nothing picked yet
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get noImageSelected;

  /// Hint above the thumbnails
  ///
  /// In en, this message translates to:
  /// **'Tap an image to zoom.'**
  String get tapToZoom;

  /// photo_view page title
  ///
  /// In en, this message translates to:
  /// **'Photo viewer'**
  String get photoViewerTitle;

  /// pdfrx demo title
  ///
  /// In en, this message translates to:
  /// **'PDF viewer'**
  String get pdfTitle;

  /// Current page of the PDF
  ///
  /// In en, this message translates to:
  /// **'Page {page} / {count}'**
  String pdfPage(int page, int count);

  /// Go to the previous PDF page
  ///
  /// In en, this message translates to:
  /// **'Previous page'**
  String get previousPage;

  /// Go to the next PDF page
  ///
  /// In en, this message translates to:
  /// **'Next page'**
  String get nextPage;

  /// permission_handler demo title
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsTitle;

  /// Shown on macOS and Linux
  ///
  /// In en, this message translates to:
  /// **'permission_handler only supports Android, iOS, Windows and web.'**
  String get permissionsUnsupported;

  /// permission_handler Windows limitation
  ///
  /// In en, this message translates to:
  /// **'On Windows every permission is reported as granted.'**
  String get permissionsWindowsNote;

  /// Camera permission
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get permissionCamera;

  /// Photo library permission
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get permissionPhotos;

  /// Location permission
  ///
  /// In en, this message translates to:
  /// **'Location (while in use)'**
  String get permissionLocation;

  /// Android 12+ BLUETOOTH_SCAN permission
  ///
  /// In en, this message translates to:
  /// **'Bluetooth scan'**
  String get permissionBluetoothScan;

  /// Android 12+ BLUETOOTH_CONNECT permission
  ///
  /// In en, this message translates to:
  /// **'Bluetooth connect'**
  String get permissionBluetoothConnect;

  /// Request a permission
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get permissionRequest;

  /// Permission status
  ///
  /// In en, this message translates to:
  /// **'Granted'**
  String get permissionStatusGranted;

  /// Permission status
  ///
  /// In en, this message translates to:
  /// **'Denied'**
  String get permissionStatusDenied;

  /// Permission status
  ///
  /// In en, this message translates to:
  /// **'Permanently denied — change it in settings'**
  String get permissionStatusPermanentlyDenied;

  /// Permission status
  ///
  /// In en, this message translates to:
  /// **'Restricted (e.g. parental controls)'**
  String get permissionStatusRestricted;

  /// Permission status (iOS selected photos)
  ///
  /// In en, this message translates to:
  /// **'Limited access'**
  String get permissionStatusLimited;

  /// Permission status (iOS provisional notifications)
  ///
  /// In en, this message translates to:
  /// **'Provisional'**
  String get permissionStatusProvisional;

  /// flutter_blue_plus demo title
  ///
  /// In en, this message translates to:
  /// **'Bluetooth LE'**
  String get bluetoothTitle;

  /// No BLE adapter / unsupported browser
  ///
  /// In en, this message translates to:
  /// **'Bluetooth LE isn\'t available on this device.'**
  String get bluetoothUnsupported;

  /// Bluetooth adapter state
  ///
  /// In en, this message translates to:
  /// **'Adapter: {state}'**
  String bluetoothAdapterState(String state);

  /// Turn Bluetooth on (Android)
  ///
  /// In en, this message translates to:
  /// **'Turn on'**
  String get bluetoothTurnOn;

  /// Start a BLE scan
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get bluetoothScan;

  /// Stop the BLE scan
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get bluetoothStopScan;

  /// Empty scan result list
  ///
  /// In en, this message translates to:
  /// **'No devices found yet'**
  String get bluetoothNoDevices;

  /// Device without an advertised name
  ///
  /// In en, this message translates to:
  /// **'Unnamed device'**
  String get bluetoothUnnamed;

  /// Connect to a BLE device
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get bluetoothConnect;

  /// Disconnect from a BLE device
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get bluetoothDisconnect;

  /// Number of discovered GATT services
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 service} other{{count} services}}'**
  String bluetoothServices(int count);

  /// License reminder on the BLE demo page
  ///
  /// In en, this message translates to:
  /// **'flutter_blue_plus: commercial use requires a paid license.'**
  String get bluetoothLicenseNote;

  /// Build environment demo page title
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get environmentTitle;

  /// APP_FLAVOR: dev / staging / prod
  ///
  /// In en, this message translates to:
  /// **'Flavor'**
  String get envFlavor;

  /// Shown when the build didn't pass --dart-define-from-file
  ///
  /// In en, this message translates to:
  /// **'default — no env file passed'**
  String get envDefault;

  /// debug / profile / release
  ///
  /// In en, this message translates to:
  /// **'Build mode'**
  String get envBuildMode;

  /// API_BASE_URL value
  ///
  /// In en, this message translates to:
  /// **'API base URL'**
  String get envApiBaseUrl;

  /// ENABLE_LOGGING value
  ///
  /// In en, this message translates to:
  /// **'Logging'**
  String get envLogging;

  /// Whether SENTRY_DSN is set
  ///
  /// In en, this message translates to:
  /// **'Crash reporting'**
  String get envCrashReporting;

  /// Empty environment value
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get envNotSet;

  /// Warning on the environment page
  ///
  /// In en, this message translates to:
  /// **'These values come from --dart-define-from-file at build time and are compiled into the app. Never put secrets in them.'**
  String get envSecretWarning;

  /// flutter_form_builder field showcase page title
  ///
  /// In en, this message translates to:
  /// **'All form fields'**
  String get formFieldsTitle;

  /// Section header
  ///
  /// In en, this message translates to:
  /// **'Date & time'**
  String get fieldsSectionDateTime;

  /// Time-only picker label
  ///
  /// In en, this message translates to:
  /// **'Meeting time'**
  String get fieldsMeetingTime;

  /// Date and time picker label
  ///
  /// In en, this message translates to:
  /// **'Appointment (date + time)'**
  String get fieldsAppointment;

  /// Date range picker label
  ///
  /// In en, this message translates to:
  /// **'Trip dates'**
  String get fieldsTripDates;

  /// Section header
  ///
  /// In en, this message translates to:
  /// **'Sliders & numbers'**
  String get fieldsSectionNumbers;

  /// Slider label
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get fieldsVolume;

  /// Range slider label
  ///
  /// In en, this message translates to:
  /// **'Price range'**
  String get fieldsPriceRange;

  /// Numeric text field label
  ///
  /// In en, this message translates to:
  /// **'Age (optional)'**
  String get fieldsAge;

  /// Section header
  ///
  /// In en, this message translates to:
  /// **'Choices'**
  String get fieldsSectionChoices;

  /// Switch label
  ///
  /// In en, this message translates to:
  /// **'Subscribe to the newsletter'**
  String get fieldsNewsletter;

  /// Radio group label
  ///
  /// In en, this message translates to:
  /// **'Preferred contact'**
  String get fieldsContactMethod;

  /// Radio option
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get fieldsContactPhone;

  /// Radio option
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get fieldsContactSms;

  /// Conditional phone field label
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get fieldsPhone;

  /// Checkbox group label
  ///
  /// In en, this message translates to:
  /// **'Interests (pick at least one)'**
  String get fieldsInterests;

  /// Checkbox option
  ///
  /// In en, this message translates to:
  /// **'Design'**
  String get fieldsInterestDesign;

  /// Choice chips label
  ///
  /// In en, this message translates to:
  /// **'T-shirt size'**
  String get fieldsSize;

  /// Filter chips label
  ///
  /// In en, this message translates to:
  /// **'Pizza toppings'**
  String get fieldsToppings;

  /// Filter chip option
  ///
  /// In en, this message translates to:
  /// **'Cheese'**
  String get fieldsToppingCheese;

  /// Filter chip option
  ///
  /// In en, this message translates to:
  /// **'Mushroom'**
  String get fieldsToppingMushroom;

  /// Filter chip option
  ///
  /// In en, this message translates to:
  /// **'Olive'**
  String get fieldsToppingOlive;

  /// Filter chip option
  ///
  /// In en, this message translates to:
  /// **'Pepper'**
  String get fieldsToppingPepper;

  /// Section header
  ///
  /// In en, this message translates to:
  /// **'Custom & dynamic fields'**
  String get fieldsSectionCustom;

  /// Custom star rating field label
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get fieldsRating;

  /// Custom color field label
  ///
  /// In en, this message translates to:
  /// **'Favorite color'**
  String get fieldsFavoriteColor;

  /// Multiline text field label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fieldsNotes;

  /// Dynamic guest name field label
  ///
  /// In en, this message translates to:
  /// **'Guest {number}'**
  String fieldsGuestName(int number);

  /// Adds a dynamic guest field
  ///
  /// In en, this message translates to:
  /// **'Add guest'**
  String get fieldsAddGuest;

  /// Removes a dynamic guest field
  ///
  /// In en, this message translates to:
  /// **'Remove guest'**
  String get fieldsRemoveGuest;

  /// Fills the form programmatically with patchValue
  ///
  /// In en, this message translates to:
  /// **'Fill example'**
  String get fieldsFillExample;

  /// Result dialog title
  ///
  /// In en, this message translates to:
  /// **'Form values'**
  String get fieldsResult;

  /// Generic cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// local_auth demo title
  ///
  /// In en, this message translates to:
  /// **'Biometric authentication'**
  String get biometricTitle;

  /// Shown on web and Linux
  ///
  /// In en, this message translates to:
  /// **'local_auth supports Android, iOS, macOS and Windows.'**
  String get biometricUnsupported;

  /// isDeviceSupported result
  ///
  /// In en, this message translates to:
  /// **'Device supports secure authentication'**
  String get biometricDeviceSupported;

  /// canCheckBiometrics result
  ///
  /// In en, this message translates to:
  /// **'Biometric hardware'**
  String get biometricHardware;

  /// getAvailableBiometrics result
  ///
  /// In en, this message translates to:
  /// **'Enrolled: {types}'**
  String biometricEnrolled(String types);

  /// No enrolled biometrics
  ///
  /// In en, this message translates to:
  /// **'none'**
  String get biometricNone;

  /// authenticate with device credential fallback
  ///
  /// In en, this message translates to:
  /// **'Authenticate (biometrics or device PIN)'**
  String get biometricAuthenticate;

  /// authenticate with biometricOnly: true
  ///
  /// In en, this message translates to:
  /// **'Biometrics only'**
  String get biometricOnlyAuthenticate;

  /// localizedReason shown in the system prompt
  ///
  /// In en, this message translates to:
  /// **'Confirm your identity to open the secure area'**
  String get biometricReason;

  /// Android biometric prompt title
  ///
  /// In en, this message translates to:
  /// **'Authentication required'**
  String get biometricPromptTitle;

  /// Android biometric prompt hint
  ///
  /// In en, this message translates to:
  /// **'Verify identity'**
  String get biometricPromptHint;

  /// authenticate returned true
  ///
  /// In en, this message translates to:
  /// **'Authenticated'**
  String get biometricSuccess;

  /// authenticate returned false or the user cancelled
  ///
  /// In en, this message translates to:
  /// **'Not authenticated'**
  String get biometricFailed;

  /// LocalAuthException code
  ///
  /// In en, this message translates to:
  /// **'Error: {details}'**
  String biometricError(String details);

  /// in_app_review demo title
  ///
  /// In en, this message translates to:
  /// **'In-app review'**
  String get reviewTitle;

  /// Shown on other platforms
  ///
  /// In en, this message translates to:
  /// **'in_app_review supports Android, iOS and macOS (store listing also on Windows).'**
  String get reviewUnsupported;

  /// isAvailable result
  ///
  /// In en, this message translates to:
  /// **'Review dialog available: {value}'**
  String reviewAvailable(String value);

  /// Explains the ReviewPromptPolicy
  ///
  /// In en, this message translates to:
  /// **'The review dialog is requested automatically after 3 completed actions (never from a \"Rate\" button).'**
  String get reviewWillAsk;

  /// Simulates a meaningful user action
  ///
  /// In en, this message translates to:
  /// **'Complete an action'**
  String get reviewCompleteAction;

  /// Number of simulated actions
  ///
  /// In en, this message translates to:
  /// **'Completed actions: {count}'**
  String reviewProgress(int count);

  /// After requestReview
  ///
  /// In en, this message translates to:
  /// **'Review requested — the OS decides whether the dialog is shown.'**
  String get reviewRequested;

  /// openStoreListing button
  ///
  /// In en, this message translates to:
  /// **'Open store listing (Rate us)'**
  String get reviewOpenStore;

  /// appStoreId / microsoftStoreId not configured
  ///
  /// In en, this message translates to:
  /// **'Set the store id in InAppReviewPage to open the store listing on this platform.'**
  String get reviewStoreIdMissing;

  /// ditredi demo title
  ///
  /// In en, this message translates to:
  /// **'3D viewer (ditredi)'**
  String get threeDTitle;

  /// Cube scene
  ///
  /// In en, this message translates to:
  /// **'Cube'**
  String get threeDCube;

  /// OBJ model scene
  ///
  /// In en, this message translates to:
  /// **'OBJ model'**
  String get threeDModel;

  /// Gesture hint
  ///
  /// In en, this message translates to:
  /// **'Drag to rotate, pinch or scroll to zoom.'**
  String get threeDHint;

  /// Reset rotation and zoom
  ///
  /// In en, this message translates to:
  /// **'Reset view'**
  String get threeDReset;

  /// Generic next button
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Generic previous button
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// Generic skip button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Generic done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// pinput demo title
  ///
  /// In en, this message translates to:
  /// **'OTP code (pinput)'**
  String get otpTitle;

  /// OTP instructions
  ///
  /// In en, this message translates to:
  /// **'Enter the 4-digit code we sent to your phone. Demo code: 2222'**
  String get otpInstruction;

  /// OTP validation error
  ///
  /// In en, this message translates to:
  /// **'Wrong code'**
  String get otpInvalid;

  /// OTP success
  ///
  /// In en, this message translates to:
  /// **'Code verified'**
  String get otpVerified;

  /// Validate the OTP form
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get otpVerify;

  /// Clear the OTP input
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get otpClear;

  /// Obscured pinput example title
  ///
  /// In en, this message translates to:
  /// **'Hidden PIN (6 digits)'**
  String get otpObscured;

  /// introduction_screen demo title
  ///
  /// In en, this message translates to:
  /// **'Onboarding (introduction_screen)'**
  String get onboardingTitle;

  /// Onboarding page 1 title
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get onboardingPage1Title;

  /// Onboarding page 1 body
  ///
  /// In en, this message translates to:
  /// **'Best practices for Flutter apps, in one place.'**
  String get onboardingPage1Body;

  /// Onboarding page 2 title
  ///
  /// In en, this message translates to:
  /// **'Works everywhere'**
  String get onboardingPage2Title;

  /// Onboarding page 2 body
  ///
  /// In en, this message translates to:
  /// **'Android, iOS, web and desktop from one codebase.'**
  String get onboardingPage2Body;

  /// Onboarding page 3 title
  ///
  /// In en, this message translates to:
  /// **'Ready?'**
  String get onboardingPage3Title;

  /// Onboarding page 3 body
  ///
  /// In en, this message translates to:
  /// **'Tap Done to start exploring the demos.'**
  String get onboardingPage3Body;

  /// showcaseview demo title
  ///
  /// In en, this message translates to:
  /// **'Feature tour (showcaseview)'**
  String get tourTitle;

  /// Restart the showcase tour
  ///
  /// In en, this message translates to:
  /// **'Start tour'**
  String get tourStart;

  /// Tour step title
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get tourSearchTitle;

  /// Tour step description
  ///
  /// In en, this message translates to:
  /// **'Find any demo quickly.'**
  String get tourSearchBody;

  /// Tour step title
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get tourListTitle;

  /// Tour step description
  ///
  /// In en, this message translates to:
  /// **'Tap an item to open its details.'**
  String get tourListBody;

  /// Tour step title
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get tourFabTitle;

  /// Tour step description
  ///
  /// In en, this message translates to:
  /// **'Add a new item here.'**
  String get tourFabBody;

  /// Snackbar after the tour
  ///
  /// In en, this message translates to:
  /// **'Tour finished'**
  String get tourFinished;

  /// List item label
  ///
  /// In en, this message translates to:
  /// **'Item {number}'**
  String tourItem(int number);

  /// flutter_tilt demo title
  ///
  /// In en, this message translates to:
  /// **'Tilt effect (flutter_tilt)'**
  String get tiltTitle;

  /// Tilt gesture hint
  ///
  /// In en, this message translates to:
  /// **'Move the pointer over the card, drag it, or tilt your phone.'**
  String get tiltHint;

  /// Toggle gyroscope tilt
  ///
  /// In en, this message translates to:
  /// **'Use device sensors (Android, iOS, web)'**
  String get tiltSensors;

  /// Tilt card subtitle
  ///
  /// In en, this message translates to:
  /// **'Parallax layers move with the tilt'**
  String get tiltCardSubtitle;

  /// flutter_tts demo title
  ///
  /// In en, this message translates to:
  /// **'Text to speech (flutter_tts)'**
  String get ttsTitle;

  /// TTS unsupported platform
  ///
  /// In en, this message translates to:
  /// **'Text to speech isn\'t available on this platform.'**
  String get ttsUnsupported;

  /// Default text to speak
  ///
  /// In en, this message translates to:
  /// **'Hello! This text is read aloud in the language you choose.'**
  String get ttsSampleText;

  /// Text field label
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get ttsText;

  /// Language dropdown label
  ///
  /// In en, this message translates to:
  /// **'Speech language'**
  String get ttsLanguage;

  /// Voice dropdown label
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get ttsVoice;

  /// Use the language's default voice
  ///
  /// In en, this message translates to:
  /// **'Default voice'**
  String get ttsDefaultVoice;

  /// Speech rate slider
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get ttsRate;

  /// Pitch slider
  ///
  /// In en, this message translates to:
  /// **'Pitch'**
  String get ttsPitch;

  /// Volume slider
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get ttsVolume;

  /// Start speaking
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get ttsSpeak;

  /// Pause speaking
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get ttsPause;

  /// Stop speaking
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get ttsStop;

  /// Empty language list
  ///
  /// In en, this message translates to:
  /// **'No speech languages found. Install a text-to-speech engine or voice data.'**
  String get ttsNoLanguages;

  /// setLanguage failed
  ///
  /// In en, this message translates to:
  /// **'{language} isn\'t supported by the speech engine.'**
  String ttsLanguageUnavailable(String language);

  /// Android voice data missing
  ///
  /// In en, this message translates to:
  /// **'Voice data for {language} isn\'t downloaded. Install it in the system text-to-speech settings.'**
  String ttsLanguageNotInstalled(String language);

  /// TTS error
  ///
  /// In en, this message translates to:
  /// **'Speech error: {details}'**
  String ttsError(String details);

  /// speech_to_text demo title
  ///
  /// In en, this message translates to:
  /// **'Speech to text (speech_to_text)'**
  String get sttTitle;

  /// STT unsupported platform
  ///
  /// In en, this message translates to:
  /// **'Speech recognition isn\'t available on this platform.'**
  String get sttUnsupported;

  /// Windows beta warning
  ///
  /// In en, this message translates to:
  /// **'Windows support is in beta: English only and not ready for production.'**
  String get sttWindowsBeta;

  /// Mic permission denied
  ///
  /// In en, this message translates to:
  /// **'Microphone permission is denied. Allow it in the app settings.'**
  String get sttPermissionDenied;

  /// Recognizer unavailable
  ///
  /// In en, this message translates to:
  /// **'Speech recognition isn\'t available on this device.'**
  String get sttUnavailable;

  /// Open app settings button
  ///
  /// In en, this message translates to:
  /// **'Open app settings'**
  String get sttOpenSettings;

  /// Empty locale list
  ///
  /// In en, this message translates to:
  /// **'The recognizer didn\'t report languages; the device language is used.'**
  String get sttNoLocales;

  /// Locale dropdown label
  ///
  /// In en, this message translates to:
  /// **'Recognition language'**
  String get sttLanguage;

  /// Mic button tooltip
  ///
  /// In en, this message translates to:
  /// **'Start listening'**
  String get sttStart;

  /// Stop button tooltip
  ///
  /// In en, this message translates to:
  /// **'Stop listening'**
  String get sttStop;

  /// Listening state
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get sttListening;

  /// Idle hint
  ///
  /// In en, this message translates to:
  /// **'Tap the microphone and speak'**
  String get sttTapToSpeak;

  /// Empty result placeholder
  ///
  /// In en, this message translates to:
  /// **'Recognized text appears here'**
  String get sttEmpty;

  /// Final result label
  ///
  /// In en, this message translates to:
  /// **'Final'**
  String get sttFinal;

  /// Partial result label
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get sttPartial;

  /// Recognition confidence
  ///
  /// In en, this message translates to:
  /// **'Confidence {percent}%'**
  String sttConfidence(int percent);

  /// error_no_match
  ///
  /// In en, this message translates to:
  /// **'Nothing was recognized. Try again.'**
  String get sttNoMatch;

  /// screen_protector demo title
  ///
  /// In en, this message translates to:
  /// **'Screenshot protection (screen_protector)'**
  String get screenProtectorTitle;

  /// Unsupported platform
  ///
  /// In en, this message translates to:
  /// **'screen_protector supports Android and iOS only.'**
  String get screenProtectorUnsupported;

  /// Demo card title
  ///
  /// In en, this message translates to:
  /// **'Sensitive data'**
  String get screenProtectorCardTitle;

  /// Protection switch
  ///
  /// In en, this message translates to:
  /// **'Block screenshots and screen recording'**
  String get screenProtectorBlock;

  /// Android behavior
  ///
  /// In en, this message translates to:
  /// **'Screenshots and recordings turn black and the app is hidden in recent apps.'**
  String get screenProtectorBlockAndroid;

  /// iOS behavior
  ///
  /// In en, this message translates to:
  /// **'Screenshots and recordings show a blank screen.'**
  String get screenProtectorBlockIos;

  /// iOS blur switch
  ///
  /// In en, this message translates to:
  /// **'Blur in the app switcher'**
  String get screenProtectorBlur;

  /// Screenshot counter
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No screenshots detected} =1{1 screenshot detected} other{{count} screenshots detected}}'**
  String screenProtectorScreenshots(int count);

  /// Recording active
  ///
  /// In en, this message translates to:
  /// **'The screen is being recorded or mirrored'**
  String get screenProtectorRecording;

  /// Recording inactive
  ///
  /// In en, this message translates to:
  /// **'The screen isn\'t being recorded'**
  String get screenProtectorNotRecording;

  /// qr_flutter demo title
  ///
  /// In en, this message translates to:
  /// **'QR code (qr_flutter)'**
  String get qrTitle;

  /// QR data field label
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get qrData;

  /// Data length
  ///
  /// In en, this message translates to:
  /// **'{count} characters'**
  String qrCharacters(int count);

  /// QR validation error
  ///
  /// In en, this message translates to:
  /// **'Too much data for a QR code'**
  String get qrTooLong;

  /// QR size info
  ///
  /// In en, this message translates to:
  /// **'Version {version} · {modules}×{modules} modules'**
  String qrInfo(int version, int modules);

  /// Error correction level label
  ///
  /// In en, this message translates to:
  /// **'Error correction'**
  String get qrErrorCorrection;

  /// Rounded style switch
  ///
  /// In en, this message translates to:
  /// **'Rounded modules'**
  String get qrRounded;

  /// Embedded image switch
  ///
  /// In en, this message translates to:
  /// **'Logo in the middle'**
  String get qrLogo;

  /// Embedded image hint
  ///
  /// In en, this message translates to:
  /// **'Uses error correction H so the code stays readable'**
  String get qrLogoHint;

  /// Export button
  ///
  /// In en, this message translates to:
  /// **'Export as PNG'**
  String get qrExport;

  /// Export result
  ///
  /// In en, this message translates to:
  /// **'PNG created ({kb} KB)'**
  String qrExported(int kb);

  /// flutter_chat_ui demo title
  ///
  /// In en, this message translates to:
  /// **'Chat (flutter_chat_ui)'**
  String get chatTitle;

  /// First bot message
  ///
  /// In en, this message translates to:
  /// **'Hi! Send a message and I\'ll reply.'**
  String get chatWelcome;

  /// Bot reply
  ///
  /// In en, this message translates to:
  /// **'You said: {text}'**
  String chatEcho(String text);

  /// Composer hint
  ///
  /// In en, this message translates to:
  /// **'Type a message'**
  String get chatHint;

  /// Typing indicator label
  ///
  /// In en, this message translates to:
  /// **'Bot is typing…'**
  String get chatTyping;

  /// Empty chat
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get chatEmpty;

  /// story_view demo title
  ///
  /// In en, this message translates to:
  /// **'Stories (story_view)'**
  String get storiesTitle;

  /// Stories usage hint
  ///
  /// In en, this message translates to:
  /// **'Tap a story. Tap right/left to skip, hold to pause, swipe down to close.'**
  String get storiesHint;

  /// Story group name
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get storyGroupWelcome;

  /// Story group name
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get storyGroupPhotos;

  /// Text story
  ///
  /// In en, this message translates to:
  /// **'Welcome to stories!'**
  String get storyWelcome;

  /// Text story
  ///
  /// In en, this message translates to:
  /// **'Tap to go forward, hold to pause, swipe down to close.'**
  String get storyHowTo;

  /// Asset story caption
  ///
  /// In en, this message translates to:
  /// **'Images can also come from assets or memory'**
  String get storyAssetCaption;

  /// Photo caption
  ///
  /// In en, this message translates to:
  /// **'Network images are cached'**
  String get storyCaptionMountains;

  /// Photo caption
  ///
  /// In en, this message translates to:
  /// **'The story waits until the image is loaded'**
  String get storyCaptionCity;

  /// Video caption
  ///
  /// In en, this message translates to:
  /// **'Video story (Android, iOS, macOS)'**
  String get storyCaptionVideo;

  /// image_cropper demo title
  ///
  /// In en, this message translates to:
  /// **'Crop image (image_cropper)'**
  String get cropTitle;

  /// Unsupported platform
  ///
  /// In en, this message translates to:
  /// **'image_cropper supports Android, iOS and web only.'**
  String get cropUnsupported;

  /// Circle crop switch
  ///
  /// In en, this message translates to:
  /// **'Circle crop (profile photo)'**
  String get cropCircle;

  /// Circle crop hint
  ///
  /// In en, this message translates to:
  /// **'Locks a 1:1 ratio with a round overlay'**
  String get cropCircleHint;

  /// Gallery button
  ///
  /// In en, this message translates to:
  /// **'Pick from gallery'**
  String get cropPickGallery;

  /// Camera button
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get cropPickCamera;

  /// No result yet
  ///
  /// In en, this message translates to:
  /// **'Pick an image to crop it.'**
  String get cropEmpty;

  /// Web cropper tooltip
  ///
  /// In en, this message translates to:
  /// **'Rotate left'**
  String get cropRotateLeft;

  /// Web cropper tooltip
  ///
  /// In en, this message translates to:
  /// **'Rotate right'**
  String get cropRotateRight;

  /// Web cropper button
  ///
  /// In en, this message translates to:
  /// **'Crop'**
  String get cropApply;

  /// Result size
  ///
  /// In en, this message translates to:
  /// **'Cropped: {kb} KB'**
  String cropResultSize(int kb);

  /// Result and original size
  ///
  /// In en, this message translates to:
  /// **'Cropped: {kb} KB (original {originalKb} KB)'**
  String cropResultSizes(int kb, int originalKb);

  /// flutter_doc_scanner demo title
  ///
  /// In en, this message translates to:
  /// **'Document scanner (flutter_doc_scanner)'**
  String get docScanTitle;

  /// Unsupported platform
  ///
  /// In en, this message translates to:
  /// **'The document scanner supports Android and iOS only.'**
  String get docScanUnsupported;

  /// Scanner intro
  ///
  /// In en, this message translates to:
  /// **'The system scanner detects edges, fixes perspective and lets you add pages.'**
  String get docScanIntro;

  /// Android page limit
  ///
  /// In en, this message translates to:
  /// **'Page limit: {count}'**
  String docScanPageLimit(int count);

  /// Scan images button
  ///
  /// In en, this message translates to:
  /// **'Scan as images'**
  String get docScanImages;

  /// Scan PDF button
  ///
  /// In en, this message translates to:
  /// **'Scan as PDF'**
  String get docScanPdf;

  /// Scanned page count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 page} other{{count} pages}}'**
  String docScanPages(int count);

  /// PDF without page count
  ///
  /// In en, this message translates to:
  /// **'PDF created'**
  String get docScanPdfReady;

  /// IDs demo title
  ///
  /// In en, this message translates to:
  /// **'Unique IDs (uuid, nanoid, flutter_udid)'**
  String get idsTitle;

  /// Copy tooltip
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get idsCopy;

  /// Copied snackbar
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get idsCopied;

  /// Generate button
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get idsGenerate;

  /// UUID section
  ///
  /// In en, this message translates to:
  /// **'UUID'**
  String get idsUuidTitle;

  /// UUID section text
  ///
  /// In en, this message translates to:
  /// **'Globally unique without a central counter — clients can create ids offline.'**
  String get idsUuidBody;

  /// v4 explanation
  ///
  /// In en, this message translates to:
  /// **'v4: fully random. Good default when order doesn\'t matter.'**
  String get idsV4Hint;

  /// v7 explanation
  ///
  /// In en, this message translates to:
  /// **'v7: starts with a timestamp, so ids sort by creation time. Best for database keys.'**
  String get idsV7Hint;

  /// v5 section
  ///
  /// In en, this message translates to:
  /// **'Name-based UUID (v5)'**
  String get idsV5Title;

  /// v5 section text
  ///
  /// In en, this message translates to:
  /// **'The same name always gives the same UUID.'**
  String get idsV5Body;

  /// v5 input label
  ///
  /// In en, this message translates to:
  /// **'Name (URL namespace)'**
  String get idsV5Name;

  /// Validation section
  ///
  /// In en, this message translates to:
  /// **'Validate a UUID'**
  String get idsValidateTitle;

  /// Validation input label
  ///
  /// In en, this message translates to:
  /// **'UUID'**
  String get idsValidateLabel;

  /// Validation hint
  ///
  /// In en, this message translates to:
  /// **'Paste a UUID to check it'**
  String get idsValidateHint;

  /// Invalid UUID
  ///
  /// In en, this message translates to:
  /// **'Not a valid UUID'**
  String get idsInvalid;

  /// Valid UUID
  ///
  /// In en, this message translates to:
  /// **'Valid UUID (version {version})'**
  String idsValid(int version);

  /// nanoid section
  ///
  /// In en, this message translates to:
  /// **'Nano ID'**
  String get idsNanoTitle;

  /// nanoid section text
  ///
  /// In en, this message translates to:
  /// **'Shorter, URL-safe random ids with a custom alphabet and length.'**
  String get idsNanoBody;

  /// Default nanoid label
  ///
  /// In en, this message translates to:
  /// **'Default (21 characters)'**
  String get idsNanoDefault;

  /// Custom alphabet label
  ///
  /// In en, this message translates to:
  /// **'Order code (no 0/O/1/I)'**
  String get idsOrderCode;

  /// Device id section
  ///
  /// In en, this message translates to:
  /// **'Device ID (flutter_udid)'**
  String get idsDeviceTitle;

  /// Device id section text
  ///
  /// In en, this message translates to:
  /// **'Hashed platform id. Survives reinstalls (usually), changes on factory reset. Treat it as personal data.'**
  String get idsDeviceBody;

  /// Device id on web
  ///
  /// In en, this message translates to:
  /// **'Not available on web.'**
  String get idsDeviceUnsupported;
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
