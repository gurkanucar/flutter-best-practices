import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:permission_handler/permission_handler.dart';

import '../l10n/app_localizations.dart';
import '../l10n/l10n_extension.dart';

class PermissionsPage extends StatefulWidget {
  const PermissionsPage({super.key});

  /// permission_handler has no macOS or Linux implementation.
  static bool get isSupported =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.windows;

  /// Web only implements camera, microphone, notification and location.
  static List<Permission> get permissions => [
        Permission.camera,
        if (!kIsWeb) Permission.photos,
        Permission.notification,
        kIsWeb ? Permission.location : Permission.locationWhenInUse,
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) ...[
          Permission.bluetoothScan, // Android 12+
          Permission.bluetoothConnect,
        ],
      ];

  @override
  State<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends State<PermissionsPage> {
  final _statuses = <Permission, PermissionStatus>{};
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // The user may change permissions in system settings — re-check on return.
    _lifecycle = AppLifecycleListener(onResume: _refresh);
    if (PermissionsPage.isSupported) _refresh();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    for (final permission in PermissionsPage.permissions) {
      try {
        final status = await permission.status;
        if (!mounted) return;
        setState(() => _statuses[permission] = status);
      } on UnimplementedError {
        // not available on this platform
      }
    }
  }

  Future<void> _request(Permission permission) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final status = await permission.request();
    if (!mounted) return;
    setState(() => _statuses[permission] = status);

    // The OS won't show the dialog again — only system settings can change it.
    if (status.isPermanentlyDenied) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(l10n.permissionStatusPermanentlyDenied),
          action: SnackBarAction(label: l10n.openSettings, onPressed: openAppSettings),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isWindows = !kIsWeb && defaultTargetPlatform == TargetPlatform.windows;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.permissionsTitle),
        actions: [
          if (PermissionsPage.isSupported && !isWindows)
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: l10n.openSettings,
              onPressed: openAppSettings, // permission_handler's top-level function
            ),
        ],
      ),
      body: ListView(
        children: [
          if (!PermissionsPage.isSupported)
            Padding(padding: const EdgeInsets.all(16), child: Text(l10n.permissionsUnsupported)),
          if (isWindows)
            Padding(padding: const EdgeInsets.all(16), child: Text(l10n.permissionsWindowsNote)),
          if (PermissionsPage.isSupported)
            for (final permission in PermissionsPage.permissions)
              ListTile(
                leading: Icon(_icon(permission)),
                title: Text(_label(l10n, permission)),
                subtitle: Text(_statusLabel(l10n, _statuses[permission])),
                trailing: FilledButton.tonal(
                  onPressed: _statuses[permission]?.isGranted ?? false ? null : () => _request(permission),
                  child: Text(l10n.permissionRequest),
                ),
              ),
        ],
      ),
    );
  }

  String _label(AppLocalizations l10n, Permission permission) {
    if (permission == Permission.camera) return l10n.permissionCamera;
    if (permission == Permission.photos) return l10n.permissionPhotos;
    if (permission == Permission.notification) return l10n.notifications;
    if (permission == Permission.bluetoothScan) return l10n.permissionBluetoothScan;
    if (permission == Permission.bluetoothConnect) return l10n.permissionBluetoothConnect;
    return l10n.permissionLocation;
  }

  IconData _icon(Permission permission) {
    if (permission == Permission.camera) return Icons.photo_camera;
    if (permission == Permission.photos) return Icons.photo_library;
    if (permission == Permission.notification) return Icons.notifications;
    if (permission == Permission.bluetoothScan || permission == Permission.bluetoothConnect) {
      return Icons.bluetooth;
    }
    return Icons.location_on;
  }

  String _statusLabel(AppLocalizations l10n, PermissionStatus? status) => switch (status) {
        null => l10n.unknown,
        PermissionStatus.granted => l10n.permissionStatusGranted,
        PermissionStatus.denied => l10n.permissionStatusDenied,
        PermissionStatus.permanentlyDenied => l10n.permissionStatusPermanentlyDenied,
        PermissionStatus.restricted => l10n.permissionStatusRestricted,
        PermissionStatus.limited => l10n.permissionStatusLimited,
        PermissionStatus.provisional => l10n.permissionStatusProvisional,
      };
}
