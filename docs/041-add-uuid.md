# Generate IDs with uuid

Uses [`uuid`](https://pub.dev/packages/uuid) **4.6.x** — RFC 9562 UUIDs (v1, v4, v5, v6, v7, v8). Pure Dart,
cryptographically secure RNG by default.

## Steps

### 1. Add dependency
```bash
flutter pub add uuid
```

### 2. Keep generation in one place — `lib/ids/ids.dart`
```dart
abstract final class Ids {
  static const _uuid = Uuid();

  static String uuidV4() => _uuid.v4();
  static String uuidV7() => _uuid.v7();
  static String uuidV5(String name, {Namespace namespace = Namespace.url}) => _uuid.v5(namespace.value, name);
  static bool isValidUuid(String value) => Uuid.isValidUUID(fromString: value);
}
```
Tests: `test/ids_test.dart`.

### 3. Which version?
| Version | Content | Use for |
|---|---|---|
| **v7** | Unix ms timestamp + random | **Database primary keys**, message/event ids — sorts by creation time, so B-tree indexes stay compact |
| **v4** | 122 random bits | Ids where order doesn't matter or the creation time must not leak |
| **v5** | SHA-1 of namespace + name | Deterministic ids: same input → same UUID (idempotency keys, ids for external resources) |
| v1 / v6 | timestamp + node | Legacy; avoid |

Client-generated ids let you create records offline and insert them optimistically (chat messages in
[037](037-add-flutter-chat-ui.md) use v7).

### 4. Validate and parse
```dart
Uuid.isValidUUID(fromString: input);                         // strict RFC 9562 (version/variant bits)
Uuid.isValidUUID(fromString: input, validationMode: ValidationMode.nonStrict);
Uuid.isValidUUIDFormat(fromString: input);                   // 8-4-4-4-12 hex only (4.6.0+)

final value = UuidValue.withValidation(input);               // throws FormatException
value.version;   // 4, 7, …
value.toBytes(); // 16 bytes, e.g. for BLOB columns
```

### 5. Demo — `lib/ids/unique_ids_page.dart`
**Home → Demos → Unique IDs**: generate v4/v7, a live v5 from a name, a validator, plus Nano ID
([042](042-add-nanoid.md)) and the device id ([043](043-add-flutter-udid.md)).

## Notes
- 4.x API: `Namespace.url.value` (upper-case `Namespace.URL` and `Uuid.NAMESPACE_*` are deprecated), `config:`
  instead of the old `options:` map, `isValidUUID(fromString:)` is a named parameter.
- UUIDs aren't secrets — don't use them as access tokens or password reset codes.
- v7 exposes the creation time; use v4 where that is sensitive.
