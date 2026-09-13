# Add Connectivity Status

Uses [`connectivity_plus`](https://pub.dev/packages/connectivity_plus) **7.x** — which network
types are active (Wi-Fi, mobile, ethernet, VPN…) and a stream of changes.

| Android | iOS | macOS | Web | Linux | Windows |
|:-:|:-:|:-:|:-:|:-:|:-:|
| ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

> ⚠️ **Connectivity ≠ internet.** `wifi` only means a Wi-Fi interface is up — it may be a hotel/airport
> network behind a login page, or have no route to the internet. Never skip a request because of this
> plugin; always handle timeouts and network errors. Use it for UX (offline banner, "retry when back online").

## Steps

### 1. Add dependency
```bash
flutter pub add connectivity_plus
```
- **Android:** nothing — the plugin's manifest adds `ACCESS_NETWORK_STATE`.
- **iOS / macOS:** nothing.
- **Linux:** needs NetworkManager on the machine (default on most desktop distros).
- Requirements (met by this project): Java 17, AGP ≥ 8.12.1, iOS ≥ 13, macOS ≥ 10.15.

### 2. Check once
```dart
import 'package:connectivity_plus/connectivity_plus.dart';

final List<ConnectivityResult> results = await Connectivity().checkConnectivity();

if (results.contains(ConnectivityResult.none)) {
  // no network interface
} else if (results.contains(ConnectivityResult.wifi)) {
  // Wi-Fi (Android reports only Wi-Fi when Wi-Fi and mobile are both on)
}
```
Since v6 the API returns a **`List`** — several interfaces can be active at once (e.g. `[wifi, vpn]`).

### 3. Listen for changes
```dart
StreamSubscription<List<ConnectivityResult>>? _subscription;

@override
void initState() {
  super.initState();
  _subscription = Connectivity().onConnectivityChanged.listen((results) {
    // update UI
  });
}

@override
void dispose() {
  _subscription?.cancel();   // always cancel
  super.dispose();
}
```

### 4. Service with deduplicated state — `lib/connectivity/`

`connectivity_status.dart` (Equatable, see [011](011-add-equatable.md)):
```dart
class ConnectivityStatus extends Equatable {
  const ConnectivityStatus(this.results);

  final List<ConnectivityResult> results;

  /// Some network interface is up. Does NOT guarantee internet access.
  bool get isOnline => results.any((result) => result != ConnectivityResult.none);

  @override
  List<Object?> get props => [results];
}
```

`connectivity_service.dart`:
```dart
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  /// null until the first check; only notifies on real changes (Equatable).
  final status = ValueNotifier<ConnectivityStatus?>(null);

  Future<void> start() async {
    _subscription ??= _connectivity.onConnectivityChanged.listen(_update);
    await refresh();
  }

  Future<void> refresh() async => _update(await _connectivity.checkConnectivity());

  void _update(List<ConnectivityResult> results) =>
      status.value = ConnectivityStatus(results);

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    status.dispose();
  }
}
```
- Call `start()` — the stream doesn't emit the current state immediately, so do an initial `checkConnectivity()`.
- Inject `Connectivity` in the constructor to mock it in tests.

### 5. Page — `lib/connectivity/connectivity_page.dart`
**Home → Demos → Connectivity**: online/offline icon, active types, "Check again", and
"Wi-Fi settings" via `app_settings` ([009](009-add-app-settings.md)) on Android/iOS/macOS.
```dart
ValueListenableBuilder<ConnectivityStatus?>(
  valueListenable: _service.status,
  builder: (context, status, _) {
    if (status == null) return const CircularProgressIndicator();
    return ListTile(
      leading: Icon(status.isOnline ? Icons.wifi : Icons.wifi_off),
      title: Text(status.isOnline ? l10n.connectivityOnline : l10n.connectivityOffline),
      subtitle: Text(l10n.connectivityTypes(status.results.map((r) => r.name).join(', '))),
    );
  },
)
```

## Which values each platform returns

| | Android | iOS | Web | macOS | Windows | Linux |
|---|:-:|:-:|:-:|:-:|:-:|:-:|
| wifi | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| ethernet | ✅ | ✅ | | ✅ | ✅ | ✅ |
| mobile | ✅ | ✅ | | ✅ | | |
| vpn | ✅ | | | | ✅ | ✅ |
| bluetooth | ✅ | | | | | ✅ |
| satellite | ✅ | ✅ | | | | |
| other | ✅ | ✅ | | ✅ | ✅ | ✅ |
| none | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

## Platform notes
- **Android 8+:** changes aren't delivered while the app is in the **background** — call `refresh()` on resume
  (`AppLifecycleListener(onResume: service.refresh)`).
- **iOS / macOS:** `NWPathMonitor` can emit repeated or flapping values (`none` then `wifi`) — debounce if
  you show banners; Equatable already drops exact duplicates. VPN shows up as `other`.
  The iOS **simulator** may not update when the Mac's Wi-Fi changes — test on a device.
- **Web:** only `wifi` (online) or `none` (offline) via `navigator.onLine`; no SSID or real type.
- **Real internet check:** make a lightweight request to your own backend (e.g. `HEAD /health`) with a
  short timeout, or use a reachability package — don't rely on the connection type.

## Testing
- Unit test the model (`test/equatable_test.dart`): equality and `ValueNotifier` deduplication.
- Widget tests have no platform channel → pass a fake `Connectivity` to `ConnectivityService` instead of
  using the real plugin.
