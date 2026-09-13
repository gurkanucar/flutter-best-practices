import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../auth/auth_scope.dart';
import '../l10n/l10n_extension.dart';
import '../router/routes.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final auth = AuthScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navProfile)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(l10n.profileGreeting(auth.userName ?? '')),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text(l10n.profileEdit),
            onTap: () => _editName(context),
          ),
          const _AppVersionTile(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l10n.logout),
            // Redirect kicks in automatically: /profile is protected → /login.
            onTap: AuthScope.read(context).logout,
          ),
        ],
      ),
    );
  }

  Future<void> _editName(BuildContext context) async {
    final auth = AuthScope.read(context);
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    // push<T> returns what the next page passes to context.pop(result).
    final newName = await context.push<String>(Routes.editProfile, extra: auth.userName);
    if (newName == null) return; // user went back without saving

    await auth.updateUserName(newName);
    messenger.showSnackBar(SnackBar(content: Text(l10n.profileNameUpdated)));
  }
}

class _AppVersionTile extends StatefulWidget {
  const _AppVersionTile();

  @override
  State<_AppVersionTile> createState() => _AppVersionTileState();
}

class _AppVersionTileState extends State<_AppVersionTile> {
  // Created once — not in build.
  late final Future<PackageInfo> _info = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return FutureBuilder<PackageInfo>(
      future: _info,
      builder: (context, snapshot) {
        final info = snapshot.data;
        return ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(info == null ? '…' : l10n.appVersion(info.version, info.buildNumber)),
          subtitle: info == null ? null : Text(info.packageName),
        );
      },
    );
  }
}
