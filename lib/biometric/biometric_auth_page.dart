import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n_extension.dart';

class BiometricAuthPage extends StatefulWidget {
  const BiometricAuthPage({super.key});

  /// local_auth has no Linux or web implementation.
  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.windows);

  @override
  State<BiometricAuthPage> createState() => _BiometricAuthPageState();
}

class _BiometricAuthPageState extends State<BiometricAuthPage> {
  final _auth = LocalAuthentication();

  bool? _deviceSupported;
  bool? _hasBiometricHardware;
  List<BiometricType> _enrolled = const [];
  String? _result;
  bool _busy = false;

  /// Windows Hello can't restrict to biometrics — `biometricOnly: true` throws there.
  bool get _canRequireBiometricOnly => defaultTargetPlatform != TargetPlatform.windows;

  @override
  void initState() {
    super.initState();
    if (BiometricAuthPage.isSupported) _loadCapabilities();
  }

  Future<void> _loadCapabilities() async {
    try {
      final supported = await _auth.isDeviceSupported(); // biometrics OR device PIN/pattern
      final hardware = await _auth.canCheckBiometrics; // hardware present (maybe not enrolled)
      final enrolled = await _auth.getAvailableBiometrics();
      if (!mounted) return;
      setState(() {
        _deviceSupported = supported;
        _hasBiometricHardware = hardware;
        _enrolled = enrolled;
      });
    } on PlatformException {
      if (mounted) setState(() => _deviceSupported = false);
    }
  }

  Future<void> _authenticate({required bool biometricOnly}) async {
    final l10n = context.l10n;
    setState(() {
      _busy = true;
      _result = null;
    });

    try {
      final authenticated = await _auth.authenticate(
        localizedReason: l10n.biometricReason,
        biometricOnly: biometricOnly,
        // Keep the prompt alive if the app goes to background (e.g. notification shade).
        persistAcrossBackgrounding: true,
        authMessages: [
          AndroidAuthMessages(
            signInTitle: l10n.biometricPromptTitle,
            signInHint: l10n.biometricPromptHint,
            cancelButton: l10n.cancel,
          ),
          IOSAuthMessages(cancelButton: l10n.cancel),
        ],
      );
      _setResult(authenticated ? l10n.biometricSuccess : l10n.biometricFailed);
    } on LocalAuthException catch (error) {
      // v3: typed codes instead of PlatformException strings.
      final message = switch (error.code) {
        LocalAuthExceptionCode.userCanceled => l10n.biometricFailed,
        LocalAuthExceptionCode.noBiometricsEnrolled ||
        LocalAuthExceptionCode.noCredentialsSet =>
          l10n.biometricError('${error.code.name} — enroll a fingerprint/face or set a device PIN'),
        LocalAuthExceptionCode.temporaryLockout ||
        LocalAuthExceptionCode.biometricLockout =>
          l10n.biometricError('${error.code.name} — too many attempts'),
        _ => l10n.biometricError(error.code.name),
      };
      _setResult(message);
    } on UnsupportedError catch (error) {
      _setResult(l10n.biometricError('$error'));
    }
  }

  void _setResult(String message) {
    if (!mounted) return;
    setState(() {
      _busy = false;
      _result = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.biometricTitle)),
      body: !BiometricAuthPage.isSupported
          ? Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(l10n.biometricUnsupported)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ListTile(
                  leading: const Icon(Icons.phonelink_lock),
                  title: Text(l10n.biometricDeviceSupported),
                  trailing: _StatusIcon(_deviceSupported),
                ),
                ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: Text(l10n.biometricHardware),
                  subtitle: Text(l10n.biometricEnrolled(
                    _enrolled.isEmpty ? l10n.biometricNone : _enrolled.map((type) => type.name).join(', '),
                  )),
                  trailing: _StatusIcon(_hasBiometricHardware),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  icon: const Icon(Icons.lock_open),
                  label: Text(l10n.biometricAuthenticate),
                  onPressed: _busy || _deviceSupported != true ? null : () => _authenticate(biometricOnly: false),
                ),
                if (_canRequireBiometricOnly) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.fingerprint),
                    label: Text(l10n.biometricOnlyAuthenticate),
                    onPressed: _busy || _enrolled.isEmpty ? null : () => _authenticate(biometricOnly: true),
                  ),
                ],
                const SizedBox(height: 16),
                if (_busy) const LinearProgressIndicator(),
                if (_result != null) Text(_result!, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon(this.value);

  final bool? value;

  @override
  Widget build(BuildContext context) => switch (value) {
        null => const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        true => Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
        false => Icon(Icons.cancel, color: Theme.of(context).colorScheme.error),
      };
}
