import 'package:flutter/widgets.dart';

import 'auth_controller.dart';

/// Makes [AuthController] available below the app and rebuilds dependents on change.
class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({super.key, required AuthController super.notifier, required super.child});

  /// Use in `build` — rebuilds when auth state changes.
  static AuthController of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthScope>()!.notifier!;

  /// Use in callbacks — no rebuild dependency.
  static AuthController read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AuthScope>()!.notifier!;
}
