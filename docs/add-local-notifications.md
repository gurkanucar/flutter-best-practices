# Add Flutter Local Notifications

## Steps

### 1. Add dependencies
```bash
flutter pub add flutter_local_notifications timezone
```

### 2. Android Setup — `android/app/src/main/AndroidManifest.xml`

Add permissions before `<application>`:
```xml
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

Add receivers inside `<application>`:
```xml
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false"
    android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
```

### 3. Android Setup — `android/app/build.gradle.kts`

Enable core library desugaring (required by `flutter_local_notifications`):
```kotlin
android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true  // Add this line
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

### 4. Android Setup — Timezone

You must initialize timezones AND set the local timezone, otherwise `tz.local` throws a `LateInitializationError`:
```dart
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

tz.initializeTimeZones();
tz.setLocalLocation(tz.getLocation('Europe/Istanbul')); // set your local timezone
```

### 5. iOS Setup
No extra config needed — permissions are requested at runtime.

### 6. Initialize in `main.dart`
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const MyApp());
}
```

### 7. Request Permissions (required before showing notifications)
```dart
// Android 13+ requires runtime permission
await plugin
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission();

// Android 14+ requires exact alarm permission
await plugin
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.requestExactAlarmsPermission();

// iOS
await plugin
    .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
    ?.requestPermissions(alert: true, badge: true, sound: true);
```

## Usage Examples

### Show instant notification
```dart
await plugin.show(
  id: 0,
  title: 'Hello',
  body: 'This is a notification',
  notificationDetails: details,
);
```

### Schedule one-time notification
```dart
await plugin.zonedSchedule(
  id: 1,
  title: 'Reminder',
  body: 'Scheduled reminder',
  scheduledDate: tz.TZDateTime.now(tz.local).add(Duration(seconds: 10)),
  notificationDetails: details,
  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
);
```

### Schedule daily recurring notification
```dart
await plugin.zonedSchedule(
  id: 2,
  title: 'Daily Reminder',
  body: 'Time to check in!',
  scheduledDate: nextInstanceOfTime(10, 0), // 10:00 AM
  notificationDetails: details,
  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  matchDateTimeComponents: DateTimeComponents.time, // repeat daily
);
```

### Schedule weekly recurring notification
```dart
await plugin.zonedSchedule(
  id: 3,
  title: 'Weekly Meeting',
  body: 'Standup in 5 minutes',
  scheduledDate: nextInstanceOfWeekday(DateTime.monday, 9, 0),
  notificationDetails: details,
  androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime, // repeat weekly
);
```

### Cancel notifications
```dart
await plugin.cancel(id: 1);      // cancel specific
await plugin.cancelAll();         // cancel all
```

### Get pending notifications
```dart
final pending = await plugin.pendingNotificationRequests();
```

## Permissions Summary

| Platform | Permission | When |
|---|---|---|
| Android 13+ | `POST_NOTIFICATIONS` | Runtime — `requestNotificationsPermission()` |
| Android 14+ | `SCHEDULE_EXACT_ALARM` | Runtime — `requestExactAlarmsPermission()` |
| Android | `RECEIVE_BOOT_COMPLETED` | Manifest — reschedule after reboot |
| iOS | Alert, Badge, Sound | Runtime — `requestPermissions()` |

## matchDateTimeComponents
| Value | Behavior |
|---|---|
| `null` | One-time notification |
| `DateTimeComponents.time` | Daily at that time |
| `DateTimeComponents.dayOfWeekAndTime` | Weekly on that day/time |
| `DateTimeComponents.dateAndTime` | Yearly on that date/time |

## Troubleshooting

### `LateInitializationError: Field '_instance@...' has not been initialized`
You called `tz.local` without setting the local timezone. Fix:
```dart
tz.initializeTimeZones();
tz.setLocalLocation(tz.getLocation('Europe/Istanbul'));
```

### `Dependency ':flutter_local_notifications' requires core library desugaring`
Add to `android/app/build.gradle.kts`:
```kotlin
android {
    compileOptions {
        isCoreLibraryDesugaringEnabled = true
    }
}
dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```
