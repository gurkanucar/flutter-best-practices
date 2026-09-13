import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

import 'device_summary.dart';

class DeviceInfoService {
  DeviceInfoService({DeviceInfoPlugin? plugin}) : _plugin = plugin ?? DeviceInfoPlugin();

  final DeviceInfoPlugin _plugin;

  /// Common fields for the current platform. The plugin caches results per instance.
  Future<DeviceSummary> summary() async {
    if (kIsWeb) {
      final web = await _plugin.webBrowserInfo;
      return DeviceSummary(
        platform: 'Web',
        model: web.browserName.name,
        osVersion: web.platform ?? '-',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final android = await _plugin.androidInfo;
        return DeviceSummary(
          platform: 'Android',
          model: '${android.manufacturer} ${android.model}',
          osVersion: 'Android ${android.version.release} (API ${android.version.sdkInt})',
          isPhysicalDevice: android.isPhysicalDevice,
        );
      case TargetPlatform.iOS:
        final ios = await _plugin.iosInfo;
        return DeviceSummary(
          platform: 'iOS',
          model: ios.modelName,
          osVersion: '${ios.systemName} ${ios.systemVersion}',
          isPhysicalDevice: ios.isPhysicalDevice,
        );
      case TargetPlatform.macOS:
        final macOs = await _plugin.macOsInfo;
        return DeviceSummary(
          platform: 'macOS',
          model: macOs.modelName,
          osVersion: 'macOS ${macOs.osRelease}',
        );
      case TargetPlatform.windows:
        final windows = await _plugin.windowsInfo;
        return DeviceSummary(
          platform: 'Windows',
          model: windows.computerName,
          // Windows 11 = build 22000 or higher.
          osVersion:
              '${windows.productName} ${windows.displayVersion} (build ${windows.buildNumber})',
        );
      case TargetPlatform.linux:
        final linux = await _plugin.linuxInfo;
        return DeviceSummary(
          platform: 'Linux',
          model: linux.name,
          osVersion: linux.prettyName,
        );
      case TargetPlatform.fuchsia:
        throw UnsupportedError('Fuchsia is not supported');
    }
  }

  /// Everything the plugin knows, for debugging / crash reports. Not JSON-safe.
  Future<Map<String, dynamic>> rawData() async => (await _plugin.deviceInfo).data;
}
