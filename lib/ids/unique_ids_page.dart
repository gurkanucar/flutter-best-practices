import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_udid/flutter_udid.dart';
import 'package:material_ui/material_ui.dart';
import 'package:uuid/uuid.dart';

import '../l10n/l10n_extension.dart';
import 'ids.dart';

enum _UuidVersion { v4, v7 }

class UniqueIdsPage extends StatefulWidget {
  const UniqueIdsPage({super.key});

  @override
  State<UniqueIdsPage> createState() => _UniqueIdsPageState();
}

class _UniqueIdsPageState extends State<UniqueIdsPage> {
  final _nameController = TextEditingController(text: 'https://example.com/users/42');
  final _validateController = TextEditingController();
  final List<String> _generated = [];

  _UuidVersion _version = _UuidVersion.v7;
  String _nanoId = Ids.nanoId();
  String _orderCode = Ids.orderCode();
  String? _deviceId;
  String? _deviceIdError;

  @override
  void initState() {
    super.initState();
    _generate();
    // flutter_udid has no web implementation.
    if (!kIsWeb) _loadDeviceId();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _validateController.dispose();
    super.dispose();
  }

  void _generate() {
    setState(() {
      for (var i = 0; i < 3; i++) {
        _generated.insert(0, _version == _UuidVersion.v4 ? Ids.uuidV4() : Ids.uuidV7());
      }
      if (_generated.length > 9) _generated.removeRange(9, _generated.length);
    });
  }

  Future<void> _loadDeviceId() async {
    try {
      // SHA-256 of the platform id — send this, not the raw ANDROID_ID / identifierForVendor.
      final id = await FlutterUdid.consistentUdid;
      if (mounted) setState(() => _deviceId = id);
    } on PlatformException catch (error) {
      if (mounted) setState(() => _deviceIdError = error.message ?? error.code);
    }
  }

  Future<void> _copy(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.idsCopied)));
  }

  String _validationResult() {
    final l10n = context.l10n;
    final value = _validateController.text.trim();
    if (value.isEmpty) return l10n.idsValidateHint;
    if (!Ids.isValidUuid(value)) return l10n.idsInvalid;
    return l10n.idsValid(UuidValue.fromString(value).version);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.idsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionHeader(title: l10n.idsUuidTitle, body: l10n.idsUuidBody),
          SegmentedButton<_UuidVersion>(
            segments: const [
              ButtonSegment(value: _UuidVersion.v4, label: Text('v4')),
              ButtonSegment(value: _UuidVersion.v7, label: Text('v7')),
            ],
            selected: {_version},
            onSelectionChanged: (selection) {
              _version = selection.first;
              _generated.clear();
              _generate();
            },
          ),
          const SizedBox(height: 8),
          Text(_version == _UuidVersion.v4 ? l10n.idsV4Hint : l10n.idsV7Hint),
          for (final id in _generated) _IdTile(value: id, onCopy: _copy),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.refresh),
              label: Text(l10n.idsGenerate),
              onPressed: _generate,
            ),
          ),
          const Divider(height: 40),
          _SectionHeader(title: l10n.idsV5Title, body: l10n.idsV5Body),
          TextField(
            controller: _nameController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: l10n.idsV5Name, border: const OutlineInputBorder()),
          ),
          _IdTile(value: Ids.uuidV5(_nameController.text), onCopy: _copy),
          const Divider(height: 40),
          _SectionHeader(title: l10n.idsValidateTitle),
          TextField(
            controller: _validateController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(labelText: l10n.idsValidateLabel, border: const OutlineInputBorder()),
          ),
          Padding(padding: const EdgeInsets.only(top: 8), child: Text(_validationResult())),
          const Divider(height: 40),
          _SectionHeader(title: l10n.idsNanoTitle, body: l10n.idsNanoBody),
          _IdTile(value: _nanoId, label: l10n.idsNanoDefault, onCopy: _copy),
          _IdTile(value: _orderCode, label: l10n.idsOrderCode, onCopy: _copy),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: FilledButton.tonalIcon(
              icon: const Icon(Icons.refresh),
              label: Text(l10n.idsGenerate),
              onPressed: () => setState(() {
                _nanoId = Ids.nanoId();
                _orderCode = Ids.orderCode();
              }),
            ),
          ),
          const Divider(height: 40),
          _SectionHeader(title: l10n.idsDeviceTitle, body: l10n.idsDeviceBody),
          if (kIsWeb)
            Text(l10n.idsDeviceUnsupported)
          else if (_deviceIdError != null)
            Text(_deviceIdError!)
          else if (_deviceId == null)
            const LinearProgressIndicator()
          else
            _IdTile(value: _deviceId!, onCopy: _copy),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.body});

  final String title;
  final String? body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          if (body != null) Text(body!, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _IdTile extends StatelessWidget {
  const _IdTile({required this.value, required this.onCopy, this.label});

  final String value;
  final String? label;
  final ValueChanged<String> onCopy;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(value, style: const TextStyle(fontFamily: 'monospace')),
      subtitle: label == null ? null : Text(label!),
      trailing: IconButton(
        icon: const Icon(Icons.copy),
        tooltip: context.l10n.idsCopy,
        onPressed: () => onCopy(value),
      ),
    );
  }
}
