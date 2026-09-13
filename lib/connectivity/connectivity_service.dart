import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'connectivity_status.dart';

class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// `null` until the first check completes. Only notifies on real changes
  /// because [ConnectivityStatus] is Equatable.
  final status = ValueNotifier<ConnectivityStatus?>(null);

  Future<void> start() async {
    _subscription ??= _connectivity.onConnectivityChanged.listen(_update);
    await refresh();
  }

  /// Android doesn't deliver changes while the app is in background — call on resume.
  Future<void> refresh() async => _update(await _connectivity.checkConnectivity());

  void _update(List<ConnectivityResult> results) {
    status.value = ConnectivityStatus(results);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    status.dispose();
  }
}
