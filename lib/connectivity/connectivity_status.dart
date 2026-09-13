import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';

/// Wraps the plugin's `List<ConnectivityResult>`.
///
/// Plain lists compare by identity (`[wifi] == [wifi]` is false), so every stream
/// event would look like a change. Equatable compares the list contents, which lets
/// `ValueNotifier` skip duplicate events (the iOS/macOS monitor emits repeats).
class ConnectivityStatus extends Equatable {
  const ConnectivityStatus(this.results);

  final List<ConnectivityResult> results;

  /// Some network interface is up. Does NOT guarantee internet access.
  bool get isOnline => results.any((result) => result != ConnectivityResult.none);

  @override
  List<Object?> get props => [results];
}
