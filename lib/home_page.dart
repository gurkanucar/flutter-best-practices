import 'package:flutter/material.dart';

import 'app_settings/app_settings_page.dart';
import 'connectivity/connectivity_page.dart';
import 'device_info/device_info_page.dart';
import 'forms/sign_up_form_page.dart';
import 'l10n/l10n_extension.dart';
import 'l10n/language_selector.dart';
import 'notifications/notification_demo_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: const [LanguageSelector()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.hello, style: Theme.of(context).textTheme.headlineMedium),
          Text(l10n.welcome('John')),
          Text(l10n.itemCount(0)),
          Text(l10n.itemCount(1)),
          Text(l10n.itemCount(5)),
          Text(l10n.userRole('admin')),
          Text(l10n.lastLogin(DateTime.now())),
          Text(l10n.price(149.9)),
          const Divider(height: 32),
          const NotificationDemoSection(),
          const Divider(height: 32),
          Text(l10n.demos, style: Theme.of(context).textTheme.titleLarge),
          _DemoTile(Icons.phone_android, l10n.deviceInfoTitle, (_) => const DeviceInfoPage()),
          _DemoTile(Icons.wifi, l10n.connectivityTitle, (_) => const ConnectivityPage()),
          _DemoTile(Icons.settings, l10n.appSettingsTitle, (_) => const AppSettingsPage()),
          _DemoTile(Icons.edit_note, l10n.formTitle, (_) => const SignUpFormPage()),
        ],
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  const _DemoTile(this.icon, this.title, this.pageBuilder);

  final IconData icon;
  final String title;
  final WidgetBuilder pageBuilder;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: pageBuilder)),
    );
  }
}
