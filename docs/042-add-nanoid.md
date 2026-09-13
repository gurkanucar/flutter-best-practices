# Short Random IDs with nanoid

Uses [`nanoid`](https://pub.dev/packages/nanoid) **1.0.0** — short, URL-safe random ids with a custom alphabet and
length. Pure Dart.

> The Dart port hasn't been updated since 2021 (it resolves on Dart 3 through the legacy SDK-constraint rule). It is
> ~20 lines on top of `Random.secure()`, so the risk is low — but if a future Dart release rejects it, replace it
> with your own function (see the end).

## Steps

### 1. Add dependency
```bash
flutter pub add nanoid
```

### 2. Pick the right import
| Import | RNG | Returns |
|---|---|---|
| `package:nanoid/nanoid.dart` | `Random.secure()` | `String` |
| `package:nanoid/async.dart` | `Random.secure()` | `Future<String>` (not actually async) |
| `package:nanoid/non_secure.dart` | `Random()` | `String` — **never** for tokens or public ids |

They define the same names → import only one, or use a prefix.

### 3. Use it — `lib/ids/ids.dart`
```dart
import 'package:nanoid/nanoid.dart' as nano;

/// URL-safe (A-Za-z0-9_-), 21 chars ≈ the collision resistance of UUID v4.
static String nanoId([int size = 21]) => nano.nanoid(size);

/// No 0/O and 1/I, so codes can be read aloud or typed from a receipt.
static const orderCodeAlphabet = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
static String orderCode({int length = 8}) => nano.customAlphabet(orderCodeAlphabet, length);
```
Unlike the JS version, `customAlphabet(alphabet, size)` returns the id directly (not a generator function).

### 4. How short is safe?
Collision probability depends on alphabet size and length. With the 32-character order code alphabet:

| Length | Possible ids | ~1% collision chance after |
|---|---|---|
| 6 | 1.07 × 10⁹ | ~4,600 ids |
| 8 | 1.1 × 10¹² | ~150,000 ids |
| 10 | 1.1 × 10¹⁵ | ~4.7 million ids |

Try [zelark.github.io/nano-id-cc](https://zelark.github.io/nano-id-cc/) for your numbers. Short ids **will**
collide eventually: keep a unique index in the database and retry on conflict.

### 5. nanoid or UUID?
| | UUID v7 ([041](041-add-uuid.md)) | Nano ID |
|---|---|---|
| Length | 36 chars | 21 (or shorter) |
| Sortable | ✅ | ❌ |
| Native DB type (`uuid` column) | ✅ | ❌ text |
| Public, human-facing (URLs, codes) | long | ✅ |

Common split: UUID v7 as the primary key, Nano ID / order code as the public identifier.

### 6. Demo — `lib/ids/unique_ids_page.dart`
**Home → Demos → Unique IDs → Nano ID**: a default id and an order code, regenerate button. Tests:
`test/ids_test.dart`.

## Without the package
```dart
import 'dart:math';

final _random = Random.secure();
String customId(String alphabet, int size) =>
    List.generate(size, (_) => alphabet[_random.nextInt(alphabet.length)]).join();
```
