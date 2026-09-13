import 'package:flutter/foundation.dart';
import 'package:flutter_tilt/flutter_tilt.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n_extension.dart';

class TiltPage extends StatefulWidget {
  const TiltPage({super.key});

  /// flutter_tilt reads gyroscope/accelerometer (sensors_plus) only on Android, iOS and web.
  static bool get sensorsAvailable =>
      kIsWeb || defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;

  @override
  State<TiltPage> createState() => _TiltPageState();
}

class _TiltPageState extends State<TiltPage> {
  bool _useSensors = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    final onCard = colors.onPrimary;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tiltTitle)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(l10n.tiltHint, textAlign: TextAlign.center),
          const SizedBox(height: 32),
          Center(
            // Tilt.base = gestures/sensors + light, shadow and parallax layers.
            child: Tilt.base(
              tiltConfig: TiltConfig(
                angle: 15,
                enableGestureSensors: _useSensors && TiltPage.sensorsAvailable,
                leaveCurve: Curves.easeOutBack,
                leaveDuration: const Duration(milliseconds: 600),
              ),
              borderRadius: BorderRadius.circular(24),
              lightConfig: const LightConfig(maxIntensity: 0.35),
              shadowConfig: const ShadowBaseConfig(maxIntensity: 0.4),
              childLayout: ChildLayout(
                inner: [
                  // Parallax layers move against the tilt → depth effect.
                  TiltParallax(
                    offset: const Offset(-18, -18),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Icon(Icons.contactless, size: 44, color: onCard),
                      ),
                    ),
                  ),
                  TiltParallax(
                    offset: const Offset(10, 10),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.appTitle,
                              style: Theme.of(context).textTheme.titleLarge!.copyWith(color: onCard),
                            ),
                            Text(
                              l10n.tiltCardSubtitle,
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(color: onCard),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              child: Container(
                width: 320,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colors.primary, colors.tertiary],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SwitchListTile(
            title: Text(l10n.tiltSensors),
            value: _useSensors && TiltPage.sensorsAvailable,
            onChanged: TiltPage.sensorsAvailable ? (value) => setState(() => _useSensors = value) : null,
          ),
        ],
      ),
    );
  }
}
