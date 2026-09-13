import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n_extension.dart';

class AppSettingsPage extends StatelessWidget {
  const AppSettingsPage({super.key});

  /// `app_settings` has no Windows, Linux or web implementation.
  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  /// Settings panels (bottom sheets over the app) exist only on Android 10+.
  static bool get supportsPanels => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appSettingsTitle)),
      body: ListView(
        children: [
          if (!isSupported)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.appSettingsUnsupported),
            ),
          // Unsupported types fall back to the general app settings screen.
          _SettingsTile(Icons.info_outline, l10n.appSettingsApp, AppSettingsType.settings),
          _SettingsTile(Icons.notifications, l10n.notifications, AppSettingsType.notification),
          _SettingsTile(Icons.alarm, l10n.appSettingsAlarms, AppSettingsType.alarm),
          _SettingsTile(Icons.language, l10n.appSettingsLanguage, AppSettingsType.appLocale),
          _SettingsTile(Icons.location_on, l10n.appSettingsLocation, AppSettingsType.location),
          _SettingsTile(Icons.wifi, l10n.appSettingsWifi, AppSettingsType.wifi),
          _SettingsTile(Icons.bluetooth, l10n.appSettingsBluetooth, AppSettingsType.bluetooth),
          _SettingsTile(
            Icons.battery_saver,
            l10n.appSettingsBattery,
            AppSettingsType.batteryOptimization,
          ),
          if (supportsPanels) ...[
            const Divider(),
            ListTile(title: Text(l10n.appSettingsPanels)),
            _PanelTile(Icons.public, l10n.appSettingsPanelInternet, AppSettingsPanelType.internetConnectivity),
            _PanelTile(Icons.wifi, l10n.appSettingsWifi, AppSettingsPanelType.wifi),
            _PanelTile(Icons.volume_up, l10n.appSettingsPanelVolume, AppSettingsPanelType.volume),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile(this.icon, this.title, this.type);

  final IconData icon;
  final String title;
  final AppSettingsType type;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.open_in_new),
      enabled: AppSettingsPage.isSupported,
      onTap: () => AppSettings.openAppSettings(type: type),
    );
  }
}

class _PanelTile extends StatelessWidget {
  const _PanelTile(this.icon, this.title, this.type);

  final IconData icon;
  final String title;
  final AppSettingsPanelType type;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.vertical_align_top),
      onTap: () => AppSettings.openAppSettingsPanel(type),
    );
  }
}
