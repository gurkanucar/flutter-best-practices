import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'l10n/l10n_extension.dart';
import 'l10n/language_selector.dart';
import 'notifications/notification_demo_section.dart';
import 'router/routes.dart';

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
          _DemoTile(Icons.phone_android, l10n.deviceInfoTitle, Routes.deviceInfo),
          _DemoTile(Icons.wifi, l10n.connectivityTitle, Routes.connectivity),
          _DemoTile(Icons.settings, l10n.appSettingsTitle, Routes.appSettings),
          _DemoTile(Icons.edit_note, l10n.formTitle, Routes.signUpForm),
          _DemoTile(Icons.dynamic_form, l10n.formFieldsTitle, Routes.formFields),
          _DemoTile(Icons.sticky_note_2, l10n.hiveTitle, Routes.hiveNotes),
          _DemoTile(Icons.checklist, l10n.driftTitle, Routes.driftTodos),
          _DemoTile(Icons.image, l10n.imagesTitle, Routes.images),
          _DemoTile(Icons.picture_as_pdf, l10n.pdfTitle, Routes.pdf),
          _DemoTile(Icons.verified_user, l10n.permissionsTitle, Routes.permissions),
          _DemoTile(Icons.bluetooth, l10n.bluetoothTitle, Routes.bluetooth),
          _DemoTile(Icons.tune, l10n.environmentTitle, Routes.environment),
        ],
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  const _DemoTile(this.icon, this.title, this.location);

  final IconData icon;
  final String title;
  final String location;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      // push: opens above the bottom navigation, back returns here.
      onTap: () => context.push(location),
    );
  }
}
