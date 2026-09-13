import 'package:app_settings/app_settings.dart';
import 'package:material_ui/material_ui.dart';

import '../app_settings/app_settings_page.dart';
import '../l10n/l10n_extension.dart';
import 'connectivity_service.dart';
import 'connectivity_status.dart';

class ConnectivityPage extends StatefulWidget {
  const ConnectivityPage({super.key});

  @override
  State<ConnectivityPage> createState() => _ConnectivityPageState();
}

class _ConnectivityPageState extends State<ConnectivityPage> {
  final _service = ConnectivityService();

  @override
  void initState() {
    super.initState();
    _service.start();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.connectivityTitle)),
      body: ValueListenableBuilder<ConnectivityStatus?>(
        valueListenable: _service.status,
        builder: (context, status, _) {
          if (status == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                leading: Icon(
                  status.isOnline ? Icons.wifi : Icons.wifi_off,
                  color: status.isOnline ? colors.primary : colors.error,
                  size: 36,
                ),
                title: Text(status.isOnline ? l10n.connectivityOnline : l10n.connectivityOffline),
                subtitle: Text(
                  l10n.connectivityTypes(status.results.map((result) => result.name).join(', ')),
                ),
              ),
              const SizedBox(height: 8),
              Text(l10n.connectivityNoInternetGuarantee),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.connectivityCheckAgain),
                    onPressed: _service.refresh,
                  ),
                  if (AppSettingsPage.isSupported)
                    OutlinedButton.icon(
                      icon: const Icon(Icons.settings),
                      label: Text(l10n.connectivityOpenWifiSettings),
                      onPressed: () => AppSettings.openAppSettings(type: AppSettingsType.wifi),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
