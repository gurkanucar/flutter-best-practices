# Key-Value Storage with Hive CE

Uses [`hive_ce`](https://pub.dev/packages/hive_ce) **2.20** + `hive_ce_flutter` + `hive_ce_generator` —
fast local NoSQL boxes, pure Dart, all platforms (IndexedDB on web).

## Which Hive?

| Package | Status (Sep 2026) | Use? |
|---|---|---|
| `hive` 2.2.3 | Last release **2022**, unmaintained | ❌ |
| `hive` 4.0.0-dev (github.com/isar/hive) | **Pre-release** (`4.0.0-dev.2`), needs `isar_flutter_libs` dev, different API | ❌ for production |
| **`hive_ce`** 2.20 (Community Edition) | Maintained, Hive 2 API, generator, isolates, WASM | ✅ this project |

`hive_ce` keeps the Hive 2 box API (`openBox`, `put`, `get`, `listenable`), so most Hive 2 tutorials apply —
just import `package:hive_ce/hive_ce.dart` / `package:hive_ce_flutter/hive_ce_flutter.dart`.

**Hive vs Drift ([022](022-add-drift.md)) vs secure storage ([019](019-add-secure-storage.md)):**
Hive = settings, caches, small object lists by key. Drift = relational data, queries, joins, migrations.
Secure storage = secrets.

## Steps

### 1. Add dependencies
```bash
flutter pub add hive_ce hive_ce_flutter dev:hive_ce_generator dev:build_runner
```

### 2. Model — `lib/storage/hive/note.dart`
```dart
class Note {
  const Note({required this.title, required this.createdAt, this.pinned = false});

  final String title;
  final DateTime createdAt;
  final bool pinned;
}
```
Plain class, final fields matching constructor parameters. No annotations on the class.

### 3. Adapters — `lib/storage/hive/hive_adapters.dart`
```dart
import 'package:hive_ce/hive_ce.dart';
import 'note.dart';

@GenerateAdapters([AdapterSpec<Note>()])
part 'hive_adapters.g.dart';
```
```bash
dart run build_runner build
```
Generates next to the file:
- `hive_adapters.g.dart` — `NoteAdapter`
- `hive_adapters.g.yaml` — type ids and field indexes. **Commit it**: it keeps ids stable when you add/remove
  fields; changing ids breaks existing data.
- `hive_registrar.g.dart` — `Hive.registerAdapters()` extension

Adding a field later: add it to the class and constructor (with a default), run build_runner again.
Old `@HiveType(typeId:)`/`@HiveField(n)` annotations still work, but `GenerateAdapters` avoids manual ids.

### 4. Init — `lib/storage/hive/hive_setup.dart`
```dart
abstract final class HiveBoxes {
  static const settings = 'settings';
  static const notes = 'notes';
}

Future<void> initHive() async {
  await Hive.initFlutter();          // app documents dir (native) / IndexedDB (web)
  Hive.registerAdapters();           // generated

  final settings = await Hive.openBox<String>(HiveBoxes.settings);
  await Hive.openBox<Note>(HiveBoxes.notes);
  _persistLanguage(settings);
}
```
`main.dart`:
```dart
try {
  await initHive();
} catch (error) {
  debugPrint('Hive init failed: $error');
}
```
Open boxes before `runApp` → `Hive.box<Note>('notes')` is synchronous everywhere.

### 5. Read / write
```dart
final box = Hive.box<Note>(HiveBoxes.notes);

final key = await box.add(Note(title: 'Buy milk', createdAt: DateTime.now()));   // auto int key
await box.put('custom-key', note);                                                // own key
final note = box.get(key);                                                        // sync
box.values;  box.keys;  box.length;  box.toMap();
await box.delete(key);
await box.clear();
```
Objects are **copied** into the box — change them with `put(key, note.copyWith(...))`, not by mutating.

### 6. Rebuild UI on changes — `lib/storage/hive/notes_page.dart`
```dart
ValueListenableBuilder<Box<Note>>(
  valueListenable: box.listenable(),              // or listenable(keys: ['a', 'b'])
  builder: (context, box, _) {
    if (box.isEmpty) return Text(l10n.notesEmpty);
    final entries = box.toMap().entries.toList();
    return ListView(children: [
      for (final entry in entries)
        Dismissible(
          key: ValueKey(entry.key),
          onDismissed: (_) => box.delete(entry.key),
          child: ListTile(title: Text(entry.value.title)),
        ),
    ]);
  },
)
```
Streams: `box.watch(key: 'languageCode').listen((event) => ...)` (`event.deleted`, `event.value`).

### 7. Persist settings — saved language
```dart
void _persistLanguage(Box<String> settings) {
  final savedCode = settings.get(SettingsKeys.languageCode);
  if (savedCode != null) localeNotifier.value = Locale(savedCode);

  localeNotifier.addListener(() {
    final locale = localeNotifier.value;
    locale == null
        ? settings.delete(SettingsKeys.languageCode)            // back to system language
        : settings.put(SettingsKeys.languageCode, locale.languageCode);
  });
}
```
The language picked in the app bar ([005](005-add-localization.md)) now survives restarts.

## Encryption
```dart
const secureStorage = FlutterSecureStorage();
var encoded = await secureStorage.read(key: 'hive_key');
if (encoded == null) {
  encoded = base64UrlEncode(Hive.generateSecureKey());           // 32 bytes
  await secureStorage.write(key: 'hive_key', value: encoded);
}
final box = await Hive.openBox<String>(
  'secrets',
  encryptionCipher: HiveAesCipher(base64Url.decode(encoded)),   // AES-256
);
```
Only values are encrypted, not keys. Keep the key in secure storage, never in code.

## Other features
- `Hive.openLazyBox<T>` — values loaded on demand (`await lazyBox.get(key)`) for big boxes.
- `IsolatedHive` — share boxes safely between isolates (no `HiveObject`/`HiveList`).
- `box.compact()`, `Hive.close()`, `Hive.deleteBoxFromDisk('notes')`.

## Testing — `test/hive_test.dart`
```dart
setUpAll(() => Hive.registerAdapters());

setUp(() async {
  directory = await Directory.systemTemp.createTemp('hive_test_');
  Hive.init(directory.path);                   // not initFlutter — no path_provider in tests
});

tearDown(() async {
  await Hive.deleteFromDisk();
  await directory.delete(recursive: true);
});

test('stores a Note with the generated adapter', () async {
  final box = await Hive.openBox<Note>('notes');
  final key = await box.add(Note(title: 'Buy milk', createdAt: DateTime(2026, 9, 13), pinned: true));
  await box.close();
  expect((await Hive.openBox<Note>('notes')).get(key)!.title, 'Buy milk');
});
```

## Notes
- Register adapters **once** per isolate; registering the same type id twice throws.
- Box names are case-insensitive and should be constants.
- Don't store secrets unencrypted; don't use Hive for relational data.
- `build_runner` in this project also runs `drift_dev` — one command generates both.
