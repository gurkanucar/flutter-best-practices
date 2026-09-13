import 'package:flutter/material.dart' as legacy;
import 'package:flutter/widgets.dart';

/// Wraps widgets from packages still built on `package:flutter/material.dart` that assert a
/// legacy `Material` ancestor (e.g. pinput → "No Material widget found").
///
/// material_ui's `Scaffold`/`Material` are different classes, so they don't satisfy that check.
/// The legacy `MaterialLocalizations` come from `appLocalizationDelegates`.
/// Prefer this narrow wrapper over the deprecated `MaterialUiCompatibilityBridge`.
class LegacyMaterialScope extends StatelessWidget {
  const LegacyMaterialScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return legacy.Material(type: legacy.MaterialType.transparency, child: child);
  }
}
