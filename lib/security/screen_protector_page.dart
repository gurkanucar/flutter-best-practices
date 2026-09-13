import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:screen_protector/screen_protector.dart';

import '../l10n/l10n_extension.dart';

/// A "sensitive" screen: screenshots/recording are blocked while it is visible.
class ScreenProtectorPage extends StatefulWidget {
  const ScreenProtectorPage({super.key});

  /// screen_protector only has Android and iOS implementations — elsewhere calls throw MissingPluginException.
  static bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  @override
  State<ScreenProtectorPage> createState() => _ScreenProtectorPageState();
}

class _ScreenProtectorPageState extends State<ScreenProtectorPage> {
  bool _protected = false;
  bool _blurInAppSwitcher = true;
  int _screenshots = 0;
  bool _recording = false;

  bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    if (!ScreenProtectorPage.isSupported) return;

    _setProtected(true);

    if (_isIOS) {
      // iOS only: events arrive after the fact — use them to warn or log, not to block.
      ScreenProtector.addListener(
        () {
          if (mounted) setState(() => _screenshots++);
        },
        (isRecording) {
          if (mounted) setState(() => _recording = isRecording);
        },
      );
      ScreenProtector.isRecording().then((isRecording) {
        if (mounted) setState(() => _recording = isRecording);
      });
    }
  }

  @override
  void dispose() {
    if (ScreenProtectorPage.isSupported) {
      if (_isIOS) {
        ScreenProtector.removeListener();
        unawaited(ScreenProtector.protectDataLeakageWithBlurOff());
      }
      // Android FLAG_SECURE is set on the whole Activity window — without this the entire app stays protected.
      unawaited(ScreenProtector.preventScreenshotOff());
    }
    super.dispose();
  }

  Future<void> _setProtected(bool value) async {
    if (value) {
      await ScreenProtector.preventScreenshotOn();
    } else {
      await ScreenProtector.preventScreenshotOff();
    }
    if (_isIOS) await _setAppSwitcherBlur(value && _blurInAppSwitcher);
    if (mounted) setState(() => _protected = value);
  }

  /// iOS: blur the snapshot shown in the app switcher (Android's FLAG_SECURE already hides it).
  Future<void> _setAppSwitcherBlur(bool value) async {
    if (value) {
      await ScreenProtector.protectDataLeakageWithBlur();
    } else {
      await ScreenProtector.protectDataLeakageWithBlurOff();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.screenProtectorTitle)),
      body: !ScreenProtectorPage.isSupported
          ? Center(child: Padding(padding: const EdgeInsets.all(16), child: Text(l10n.screenProtectorUnsupported)))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.credit_card),
                            const SizedBox(width: 8),
                            Text(l10n.screenProtectorCardTitle, style: theme.textTheme.titleMedium),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('4242 4242 4242 4242', style: theme.textTheme.headlineSmall),
                        const SizedBox(height: 4),
                        const Text('TR00 0000 0000 0000 0000 0000 00'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  secondary: const Icon(Icons.screenshot_monitor),
                  title: Text(l10n.screenProtectorBlock),
                  subtitle: Text(_isIOS ? l10n.screenProtectorBlockIos : l10n.screenProtectorBlockAndroid),
                  value: _protected,
                  onChanged: _setProtected,
                ),
                if (_isIOS) ...[
                  SwitchListTile(
                    secondary: const Icon(Icons.blur_on),
                    title: Text(l10n.screenProtectorBlur),
                    value: _blurInAppSwitcher,
                    onChanged: _protected
                        ? (value) {
                            setState(() => _blurInAppSwitcher = value);
                            _setAppSwitcherBlur(value);
                          }
                        : null,
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_camera),
                    title: Text(l10n.screenProtectorScreenshots(_screenshots)),
                  ),
                  ListTile(
                    leading: Icon(
                      _recording ? Icons.fiber_manual_record : Icons.videocam_off,
                      color: _recording ? theme.colorScheme.error : null,
                    ),
                    title: Text(_recording ? l10n.screenProtectorRecording : l10n.screenProtectorNotRecording),
                  ),
                ],
              ],
            ),
    );
  }
}
