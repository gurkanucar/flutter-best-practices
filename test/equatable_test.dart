import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_best_practices/connectivity/connectivity_status.dart';
import 'package:flutter_best_practices/device_info/device_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeviceSummary', () {
    const pixel = DeviceSummary(
      platform: 'Android',
      model: 'Google Pixel 9',
      osVersion: 'Android 16 (API 36)',
      isPhysicalDevice: true,
    );

    test('instances with the same values are equal', () {
      // Not const: const instances with equal values are canonicalized into the same object.
      // ignore: prefer_const_constructors
      final other = DeviceSummary(
        platform: 'Android',
        model: 'Google Pixel 9',
        osVersion: 'Android 16 (API 36)',
        isPhysicalDevice: true,
      );
      expect(pixel, other);
      expect(pixel.hashCode, other.hashCode);
      expect({pixel, other}, hasLength(1));
    });

    test('a different value makes them unequal', () {
      const emulator = DeviceSummary(
        platform: 'Android',
        model: 'Google Pixel 9',
        osVersion: 'Android 16 (API 36)',
        isPhysicalDevice: false,
      );
      expect(pixel, isNot(emulator));
    });
  });

  group('ConnectivityStatus', () {
    test('compares result lists by content, unlike plain lists', () {
      expect([ConnectivityResult.wifi] == [ConnectivityResult.wifi], isFalse);
      expect(
        const ConnectivityStatus([ConnectivityResult.wifi]),
        const ConnectivityStatus([ConnectivityResult.wifi]),
      );
    });

    test('ValueNotifier skips duplicate statuses', () {
      final notifier = ValueNotifier<ConnectivityStatus?>(null);
      addTearDown(notifier.dispose);
      var notifications = 0;
      notifier.addListener(() => notifications++);

      notifier.value = const ConnectivityStatus([ConnectivityResult.wifi]);
      notifier.value = const ConnectivityStatus([ConnectivityResult.wifi]); // duplicate event
      expect(notifications, 1);

      notifier.value = const ConnectivityStatus([ConnectivityResult.none]);
      expect(notifications, 2);
    });

    test('isOnline is false only for none', () {
      expect(const ConnectivityStatus([ConnectivityResult.none]).isOnline, isFalse);
      expect(const ConnectivityStatus([ConnectivityResult.mobile]).isOnline, isTrue);
    });
  });
}
