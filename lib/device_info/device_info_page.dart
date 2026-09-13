import 'package:material_ui/material_ui.dart';

import '../l10n/l10n_extension.dart';
import 'device_info_service.dart';
import 'device_summary.dart';

class DeviceInfoPage extends StatefulWidget {
  const DeviceInfoPage({super.key});

  @override
  State<DeviceInfoPage> createState() => _DeviceInfoPageState();
}

class _DeviceInfoPageState extends State<DeviceInfoPage> {
  final _service = DeviceInfoService();
  late final Future<(DeviceSummary, Map<String, dynamic>)> _future = _load();

  Future<(DeviceSummary, Map<String, dynamic>)> _load() async =>
      (await _service.summary(), await _service.rawData());

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.deviceInfoTitle)),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(l10n.loadError(snapshot.error.toString())));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final (summary, raw) = snapshot.requireData;
          final physical = switch (summary.isPhysicalDevice) {
            true => l10n.yes,
            false => l10n.no,
            null => l10n.unknown,
          };
          final rawEntries = raw.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

          return ListView(
            children: [
              ListTile(title: Text(l10n.deviceInfoPlatform), subtitle: Text(summary.platform)),
              ListTile(title: Text(l10n.deviceInfoModel), subtitle: Text(summary.model)),
              ListTile(title: Text(l10n.deviceInfoOsVersion), subtitle: Text(summary.osVersion)),
              ListTile(title: Text(l10n.deviceInfoPhysicalDevice), subtitle: Text(physical)),
              ExpansionTile(
                title: Text(l10n.deviceInfoRawData),
                children: [
                  for (final entry in rawEntries)
                    ListTile(
                      dense: true,
                      title: Text(entry.key),
                      subtitle: SelectableText('${entry.value}'),
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
