import 'package:material_ui/material_ui.dart';

import 'app_environment.dart';

/// Corner ribbon ("DEV", "STAGING") so testers never confuse builds. Hidden in prod.
class EnvironmentBanner extends StatelessWidget {
  const EnvironmentBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (AppEnvironment.isProduction) return child;

    return Banner(
      message: AppEnvironment.flavor.name.toUpperCase(),
      location: BannerLocation.topStart,
      color: AppEnvironment.flavor == AppFlavor.dev ? Colors.green.shade700 : Colors.orange.shade800,
      child: child,
    );
  }
}
