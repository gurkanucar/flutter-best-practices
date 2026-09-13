import 'package:flutter/material.dart';

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
      messenger.showSnackBar(SnackBar(content: Text(l10n.notificationPermissionDenied)));
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
      messenger.showSnackBar(SnackBar(content: Text(l10n.notificationPermissionDenied)));
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
}
