import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n_extension.dart';
import 'app_environment.dart';

class EnvironmentPage extends StatelessWidget {
  const EnvironmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final buildMode = kReleaseMode ? 'release' : (kProfileMode ? 'profile' : 'debug');

    return Scaffold(
      appBar: AppBar(title: Text(l10n.environmentTitle)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.layers),
            title: Text(l10n.envFlavor),
            subtitle: Text(AppEnvironment.isConfigured
                ? AppEnvironment.flavor.name
                : '${AppEnvironment.flavor.name} (${l10n.envDefault})'),
          ),
          ListTile(
            leading: const Icon(Icons.build),
            title: Text(l10n.envBuildMode),
            subtitle: Text(buildMode),
          ),
          ListTile(
            leading: const Icon(Icons.cloud),
            title: Text(l10n.envApiBaseUrl),
            subtitle: SelectableText(AppEnvironment.apiBaseUrl),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Text(l10n.envLogging),
            subtitle: Text(AppEnvironment.enableLogging ? l10n.yes : l10n.no),
          ),
          ListTile(
            leading: const Icon(Icons.bug_report),
            title: Text(l10n.envCrashReporting),
            subtitle: Text(AppEnvironment.sentryDsn.isEmpty ? l10n.envNotSet : l10n.yes),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(l10n.envSecretWarning, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
