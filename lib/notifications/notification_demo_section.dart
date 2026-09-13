import 'package:app_settings/app_settings.dart';
import 'package:material_ui/material_ui.dart';

import '../app_settings/app_settings_page.dart';
import '../l10n/app_localizations.dart';
import '../l10n/l10n_extension.dart';
import 'notification_service.dart';

class NotificationDemoSection extends StatelessWidget {
  const NotificationDemoSection({super.key});

  static const _scheduleDelay = Duration(seconds: 5);

  NotificationService get _service => NotificationService.instance;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.notifications, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilledButton.icon(
              icon: const Icon(Icons.notifications_active),
              label: Text(l10n.showNotification),
              onPressed: () => _showNow(context),
            ),
            OutlinedButton.icon(
              icon: const Icon(Icons.schedule),
              label: Text(l10n.scheduleNotification(_scheduleDelay.inSeconds)),
              onPressed: _service.supportsScheduling ? () => _schedule(context) : null,
            ),
            FilledButton.tonalIcon(
              icon: const Icon(Icons.alarm_add),
              label: Text(l10n.setAlarm),
              onPressed: _service.supportsScheduling ? () => _setAlarm(context) : null,
            ),
            TextButton(
              onPressed: _service.cancelAll,
              child: Text(l10n.cancelNotifications),
            ),
          ],
        ),
        if (!_service.supportsScheduling)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(l10n.schedulingNotSupported),
          ),
        ValueListenableBuilder<String?>(
          valueListenable: _service.tappedPayload,
          builder: (context, payload, _) => payload == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(l10n.lastTappedNotification(payload)),
                ),
        ),
      ],
    );
  }

  Future<void> _showNow(BuildContext context) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    if (!await _service.requestPermission()) {
      _showPermissionDenied(messenger, l10n);
      return;
    }
    await _service.show(
      title: l10n.notificationTitle,
      body: l10n.notificationBody,
      channelName: l10n.notificationChannelName,
      payload: 'demo-now',
    );
  }

  Future<void> _schedule(BuildContext context) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    if (!await _service.requestPermission()) {
      _showPermissionDenied(messenger, l10n);
      return;
    }
    await _service.schedule(
      after: _scheduleDelay,
      title: l10n.notificationTitle,
      body: l10n.notificationBody,
      channelName: l10n.notificationChannelName,
      payload: 'demo-scheduled',
    );
    messenger.showSnackBar(
      SnackBar(content: Text(l10n.notificationScheduled(_scheduleDelay.inSeconds))),
    );
  }

  /// Denied permissions can only be changed in system settings — offer a shortcut.
  void _showPermissionDenied(ScaffoldMessengerState messenger, AppLocalizations l10n) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.notificationPermissionDenied),
        action: AppSettingsPage.isSupported
            ? SnackBarAction(
                label: l10n.openSettings,
                onPressed: () =>
                    AppSettings.openAppSettings(type: AppSettingsType.notification),
              )
            : null,
      ),
    );
  }

  /// Pick a date, then a time → alarm notification at exactly that moment.
  Future<void> _setAlarm(BuildContext context) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateUtils.dateOnly(now),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(minutes: 1))),
    );
    if (time == null) return;

    final at = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (!at.isAfter(DateTime.now())) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.alarmTimeInPast)));
      return;
    }

    if (!await _service.requestPermission()) {
      _showPermissionDenied(messenger, l10n);
      return;
    }
    // Android 12+: may open system settings; falls back to inexact if still not allowed.
    await _service.requestExactAlarmPermission();

    final exact = await _service.scheduleAlarm(
      at: at,
      title: l10n.alarmTitle,
      body: l10n.alarmBody,
      channelName: l10n.alarmChannelName,
      payload: 'alarm-${at.toIso8601String()}',
    );
    messenger.showSnackBar(
      SnackBar(content: Text(exact ? l10n.alarmScheduled(at, at) : l10n.alarmInexact)),
    );
  }
}
