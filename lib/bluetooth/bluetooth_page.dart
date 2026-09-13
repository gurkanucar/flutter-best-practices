import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n_extension.dart';

/// flutter_blue_plus is NOT free for commercial use (FlutterBluePlus License v1.5).
/// Personal / nonprofit / education → [License.nonprofit].
/// For-profit company (incl. development) → buy a license and use [License.commercial].
const fbpLicense = License.nonprofit;

class BluetoothPage extends StatefulWidget {
  const BluetoothPage({super.key});

  @override
  State<BluetoothPage> createState() => _BluetoothPageState();
}

class _BluetoothPageState extends State<BluetoothPage> {
  late final Future<bool> _supported = FlutterBluePlus.isSupported;
  final _serviceCounts = <DeviceIdentifier, int>{};
  DeviceIdentifier? _busyDevice;

  @override
  void dispose() {
    // stopScan isn't available on web (scanning there is a one-shot browser chooser).
    if (!kIsWeb && FlutterBluePlus.isScanningNow) FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _scan() async {
    try {
      // On Android the plugin asks for BLUETOOTH_SCAN itself. Results arrive on scanResults.
      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _connect(BluetoothDevice device) async {
    setState(() => _busyDevice = device.remoteId);
    try {
      await device.connect(license: fbpLicense, timeout: const Duration(seconds: 15));
      final services = await device.discoverServices();
      if (!mounted) return;
      setState(() => _serviceCounts[device.remoteId] = services.length);
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _busyDevice = null);
    }
  }

  Future<void> _disconnect(BluetoothDevice device) async {
    await device.disconnect();
    if (!mounted) return;
    setState(() => _serviceCounts.remove(device.remoteId));
  }

  void _showError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.loadError('$error'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bluetoothTitle)),
      body: FutureBuilder<bool>(
        future: _supported,
        builder: (context, supported) {
          if (!supported.hasData) return const Center(child: CircularProgressIndicator());
          if (supported.data != true) return Center(child: Text(l10n.bluetoothUnsupported));

          return Column(
            children: [
              if (!kIsWeb) // adapterState isn't implemented on web
                StreamBuilder<BluetoothAdapterState>(
                  stream: FlutterBluePlus.adapterState,
                  initialData: FlutterBluePlus.adapterStateNow,
                  builder: (context, snapshot) {
                    final state = snapshot.data ?? BluetoothAdapterState.unknown;
                    final canTurnOn = defaultTargetPlatform == TargetPlatform.android &&
                        state == BluetoothAdapterState.off;
                    return ListTile(
                      leading: Icon(
                        state == BluetoothAdapterState.on ? Icons.bluetooth : Icons.bluetooth_disabled,
                      ),
                      title: Text(l10n.bluetoothAdapterState(state.name)),
                      trailing: canTurnOn
                          ? TextButton(onPressed: FlutterBluePlus.turnOn, child: Text(l10n.bluetoothTurnOn))
                          : null,
                    );
                  },
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: StreamBuilder<bool>(
                  stream: FlutterBluePlus.isScanning,
                  initialData: kIsWeb ? false : FlutterBluePlus.isScanningNow,
                  builder: (context, snapshot) {
                    final scanning = snapshot.data ?? false;
                    return Row(
                      children: [
                        FilledButton.icon(
                          icon: const Icon(Icons.bluetooth_searching),
                          label: Text(l10n.bluetoothScan),
                          onPressed: scanning ? null : _scan,
                        ),
                        const SizedBox(width: 8),
                        if (scanning && !kIsWeb)
                          OutlinedButton(
                            onPressed: FlutterBluePlus.stopScan,
                            child: Text(l10n.bluetoothStopScan),
                          ),
                        if (scanning) const Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator()),
                      ],
                    );
                  },
                ),
              ),
              Expanded(
                child: StreamBuilder<List<ScanResult>>(
                  stream: FlutterBluePlus.scanResults,
                  initialData: const [],
                  builder: (context, snapshot) {
                    final results = [...?snapshot.data]..sort((a, b) => b.rssi.compareTo(a.rssi));
                    if (results.isEmpty) return Center(child: Text(l10n.bluetoothNoDevices));

                    return ListView(
                      children: [
                        for (final result in results)
                          _DeviceTile(
                            result: result,
                            serviceCount: _serviceCounts[result.device.remoteId],
                            busy: _busyDevice == result.device.remoteId,
                            onConnect: () => _connect(result.device),
                            onDisconnect: () => _disconnect(result.device),
                          ),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(l10n.bluetoothLicenseNote, style: Theme.of(context).textTheme.bodySmall),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DeviceTile extends StatelessWidget {
  const _DeviceTile({
    required this.result,
    required this.serviceCount,
    required this.busy,
    required this.onConnect,
    required this.onDisconnect,
  });

  final ScanResult result;
  final int? serviceCount;
  final bool busy;
  final VoidCallback onConnect;
  final VoidCallback onDisconnect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final name = result.advertisementData.advName;
    final connected = serviceCount != null;

    return ListTile(
      leading: Text('${result.rssi} dBm'),
      title: Text(name.isEmpty ? l10n.bluetoothUnnamed : name),
      subtitle: Text(
        connected ? '${result.device.remoteId}\n${l10n.bluetoothServices(serviceCount!)}' : '${result.device.remoteId}',
      ),
      isThreeLine: connected,
      trailing: busy
          ? const SizedBox.square(dimension: 24, child: CircularProgressIndicator())
          : connected
              ? TextButton(onPressed: onDisconnect, child: Text(l10n.bluetoothDisconnect))
              : result.advertisementData.connectable
                  ? TextButton(onPressed: onConnect, child: Text(l10n.bluetoothConnect))
                  : null,
    );
  }
}
