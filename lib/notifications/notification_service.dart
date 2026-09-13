import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Wrapper around [FlutterLocalNotificationsPlugin]. Call [init] once in `main`.
class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  static const _channelId = 'general';

  /// Separate channel: Android fixes sound/importance per channel once created.
  static const _alarmChannelId = 'alarm';

  /// Windows toast identity. Generate your own GUID per app.
  static const _windowsAppName = 'Flutter Best Practices';
  static const _windowsAppUserModelId = 'FlutterBestPractices';
  static const _windowsGuid = '64fc77fa-1a4c-4514-8d81-0ae570941fc3';

  final _plugin = FlutterLocalNotificationsPlugin();

  /// Payload of the last tapped notification (also set when one launched the app).
  final tappedPayload = ValueNotifier<String?>(null);

  bool _initialized = false;
  int _nextId = 0;

  /// Browsers and Linux have no scheduler API — `zonedSchedule` throws there.
  bool get supportsScheduling =>
      !kIsWeb && defaultTargetPlatform != TargetPlatform.linux;

  Future<void> init() async {
    if (_initialized) return;

    await _initTimeZone();

    // Permissions are requested later from a user action (required on web, better UX everywhere).
    final darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: InitializationSettings(
        android: const AndroidInitializationSettings('ic_notification'),
        iOS: darwin,
        macOS: darwin,
        linux: const LinuxInitializationSettings(defaultActionName: 'Open'),
        windows: const WindowsInitializationSettings(
          appName: _windowsAppName,
          appUserModelId: _windowsAppUserModelId,
          guid: _windowsGuid,
        ),
        web: const WebInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );
    _initialized = true;

    try {
      final launchDetails = await _plugin.getNotificationAppLaunchDetails();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        tappedPayload.value = launchDetails!.notificationResponse?.payload;
      }
    } on UnimplementedError {
      // Linux can't detect launches from a notification.
    }
  }

  /// Asks the OS for permission. Returns `true` if notifications can be shown.
  Future<bool> requestPermission() async {
    if (kIsWeb) {
      final web = _plugin.resolvePlatformSpecificImplementation<
          WebFlutterLocalNotificationsPlugin>();
      if (web == null) return false;
      if (web.permissionStatus != WebNotificationPermission.granted) {
        await web.requestNotificationsPermission();
      }
      return web.permissionStatus == WebNotificationPermission.granted;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>()
                ?.requestNotificationsPermission() ??
            false;
      case TargetPlatform.iOS:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                    IOSFlutterLocalNotificationsPlugin>()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      case TargetPlatform.macOS:
        return await _plugin
                .resolvePlatformSpecificImplementation<
                    MacOSFlutterLocalNotificationsPlugin>()
                ?.requestPermissions(alert: true, badge: true, sound: true) ??
            false;
      default:
        return true; // Windows / Linux: no runtime permission.
    }
  }

  Future<void> show({
    required String title,
    required String body,
    required String channelName,
    String? payload,
  }) {
    return _plugin.show(
      id: _nextId++,
      title: title,
      body: body,
      notificationDetails: _details(channelName),
      payload: payload,
    );
  }

  /// Throws [UnsupportedError] when ![supportsScheduling].
  Future<void> schedule({
    required Duration after,
    required String title,
    required String body,
    required String channelName,
    String? payload,
  }) async {
    if (!supportsScheduling) {
      throw UnsupportedError('Scheduled notifications are not supported here');
    }
    await _plugin.zonedSchedule(
      id: _nextId++,
      title: title,
      body: body,
      payload: payload,
      scheduledDate: tz.TZDateTime.now(tz.local).add(after),
      notificationDetails: _details(channelName),
      androidScheduleMode: await _androidScheduleMode(),
    );
  }

  /// Android 12+: opens the "Alarms & reminders" settings screen if exact alarms
  /// aren't allowed yet. Returns `true` if exact alarms can be scheduled
  /// (always `true` on other platforms).
  Future<bool> requestExactAlarmPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;
    if (await android.canScheduleExactNotifications() ?? false) return true;

    await android.requestExactAlarmsPermission();
    return await android.canScheduleExactNotifications() ?? false;
  }

  /// Shows an alarm-style notification at [at] (device local date & time).
  ///
  /// Returns `false` if Android exact alarms aren't allowed and the alarm was
  /// scheduled inexact instead (the OS may delay it).
  /// Throws [ArgumentError] if [at] isn't in the future and
  /// [UnsupportedError] when ![supportsScheduling].
  Future<bool> scheduleAlarm({
    required DateTime at,
    required String title,
    required String body,
    required String channelName,
    String? payload,
  }) async {
    if (!supportsScheduling) {
      throw UnsupportedError('Scheduled notifications are not supported here');
    }
    if (!at.isAfter(DateTime.now())) {
      throw ArgumentError.value(at, 'at', 'must be in the future');
    }

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final exact =
        android == null || (await android.canScheduleExactNotifications() ?? false);

    await _plugin.zonedSchedule(
      // One alarm per minute: setting the same minute again replaces it.
      id: (at.millisecondsSinceEpoch ~/ Duration.millisecondsPerMinute) & 0x7FFFFFFF,
      title: title,
      body: body,
      payload: payload,
      // `from` keeps the same instant, so this is correct even if tz.local fell back to UTC.
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      notificationDetails: _alarmDetails(channelName),
      androidScheduleMode: exact
          ? AndroidScheduleMode.alarmClock
          : AndroidScheduleMode.inexactAllowWhileIdle,
    );
    return exact;
  }

  /// On Windows without MSIX packaging this does nothing (OS limitation).
  Future<void> cancelAll() => _plugin.cancelAll();

  Future<void> _initTimeZone() async {
    tz.initializeTimeZones();
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (error) {
      // Unknown identifier → tz.local stays UTC. Relative schedules still fire on time.
      debugPrint('NotificationService: could not set local time zone: $error');
    }
  }

  /// Exact alarms need SCHEDULE_EXACT_ALARM granted by the user on Android 12+.
  /// Falls back to inexact (may be delayed by the OS) instead of failing.
  Future<AndroidScheduleMode> _androidScheduleMode() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return AndroidScheduleMode.exactAllowWhileIdle;

    final canScheduleExact = await android.canScheduleExactNotifications() ?? false;
    return canScheduleExact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  NotificationDetails _details(String channelName) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        channelName,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
  }

  NotificationDetails _alarmDetails(String channelName) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        _alarmChannelId,
        channelName,
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.alarm,
        // Plays on the alarm volume stream (not muted by notification volume).
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );
  }

  void _onNotificationResponse(NotificationResponse response) {
    tappedPayload.value = response.payload;
  }
}
