# Value Equality with Equatable

Uses [`equatable`](https://pub.dev/packages/equatable) **2.x** — `==` and `hashCode` by value,
without writing them by hand or running code generation. Pure Dart, all platforms.

## Why
```dart
class Person {
  const Person(this.name);
  final String name;
}

Person('Bob') == Person('Bob');   // false — compares identity
[1, 2] == [1, 2];                 // false — lists too
```
This breaks `expect(a, b)` in tests, `Set`/`Map` keys, `ValueNotifier`/state management
"did it change?" checks (extra rebuilds), and `distinct()` on streams.

## Steps

### 1. Add dependency
```bash
flutter pub add equatable
```

### 2. Extend `Equatable` and list the fields in `props`
```dart
import 'package:equatable/equatable.dart';

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
  final bool? isPhysicalDevice;

  @override
  List<Object?> get props => [platform, model, osVersion, isPhysicalDevice];
}
```
Rules:
- **All fields `final`** (immutable). A mutable field in `props` breaks `Set`/`Map` lookups.
- **Every field that defines equality goes into `props`.** A forgotten field = silently "equal" objects.
- Use `List<Object?>` when a field is nullable.
- Collections in `props` (List/Set/Map) are compared **by content**.

### 3. Already have a superclass? Use the mixin
```dart
class EquatableDateTime extends DateTime with EquatableMixin {
  EquatableDateTime(super.year, [super.month, super.day]);

  @override
  List<Object> get props => [year, month, day];
}
```
Subclass: `List<Object?> get props => [...super.props, extraField];`

### 4. `toString`
```dart
@override
bool get stringify => true;   // DeviceSummary(Android, Pixel 9, Android 16, true)
```
Global: `EquatableConfig.stringify = true;` — default is **true in debug, false in release**.
A per-class override wins.

## Examples in this project

**1. Model equality** — `lib/device_info/device_summary.dart` (see above).

**2. Deduplicating stream events** — `lib/connectivity/connectivity_status.dart`:
```dart
class ConnectivityStatus extends Equatable {
  const ConnectivityStatus(this.results);

  final List<ConnectivityResult> results;

  bool get isOnline => results.any((result) => result != ConnectivityResult.none);

  @override
  List<Object?> get props => [results];
}
```
`connectivity_plus` emits `List<ConnectivityResult>`, and iOS/macOS may repeat the same value.
`ValueNotifier` only notifies when `newValue != oldValue`, so:
- raw `List` → every event rebuilds the UI (lists are never `==`),
- `ConnectivityStatus` → duplicates are skipped.

**3. Form result** — `SignUpData` in `lib/forms/sign_up_data.dart` ([013](013-add-form-builder.md)).

## Tests — `test/equatable_test.dart`
```dart
test('instances with the same values are equal', () {
  expect(pixel, other);
  expect(pixel.hashCode, other.hashCode);
  expect({pixel, other}, hasLength(1));
});

test('ValueNotifier skips duplicate statuses', () {
  final notifier = ValueNotifier<ConnectivityStatus?>(null);
  var notifications = 0;
  notifier.addListener(() => notifications++);

  notifier.value = const ConnectivityStatus([ConnectivityResult.wifi]);
  notifier.value = const ConnectivityStatus([ConnectivityResult.wifi]); // duplicate
  expect(notifications, 1);
});
```

## When not to use
- Entities with an identity (`User` with `id`): two users with the same name aren't the same user —
  put only `id` in `props`, or don't use Equatable.
- Mutable classes / widgets / controllers.
- Large lists compared very often: deep comparison costs O(n) on every `==`.
- Need `copyWith`, JSON, unions? Consider code generation (`freezed`, `dart_mappable`) instead.
