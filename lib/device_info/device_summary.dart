import 'package:equatable/equatable.dart';

/// Platform-independent subset of `device_info_plus` data.
class DeviceSummary extends Equatable {
  const DeviceSummary({
    required this.platform,
    required this.model,
    required this.osVersion,
    this.isPhysicalDevice,
  });

  final String platform;
  final String model;
  final String osVersion;

  /// `null` where the platform doesn't report it (web, desktop).
  final bool? isPhysicalDevice;

  @override
  List<Object?> get props => [platform, model, osVersion, isPhysicalDevice];
}
