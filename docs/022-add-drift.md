# SQL Database with Drift

Uses [`drift`](https://pub.dev/packages/drift) **2.35** + `drift_flutter` 0.3 + `drift_dev` — type-safe SQLite
with generated code, reactive queries (`watch`) and migrations. All platforms (web via WASM).

## Steps

### 1. Add dependencies
```bash
flutter pub add drift drift_flutter dev:drift_dev dev:build_runner
```
- **Android / iOS / macOS / Windows / Linux:** SQLite is bundled automatically by `sqlite3` 3.x build hooks
  (prebuilt binaries are downloaded at build time — needs network on the first build).
  `sqlite3_flutter_libs` is no longer needed.
- **Web:** see step 5.

### 2. Tables and database — `lib/storage/drift/app_database.dart`
```dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class Todos extends Table {                               // → row class `Todo`, `TodosCompanion`
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Todos])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {},
      );

  static QueryExecutor _openConnection() => driftDatabase(
        name: 'app_db',                                   // <documents>/app_db.sqlite
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.js'),
        ),
      );
}

final appDatabase = AppDatabase();                        // one instance for the whole app
```
Use `@DataClassName('TodoItem')` on the table to rename the generated row class.

### 3. Generate
```bash
dart run build_runner build        # or: dart run build_runner watch
```
Creates `app_database.g.dart`. Re-run after every table change. (build_runner 2.16 removed
`--delete-conflicting-outputs`; it's no longer needed.)

### 4. Queries
```dart
// insert → returns the new id
Future<int> addTodo(String title) => into(todos).insert(TodosCompanion.insert(title: title));

// reactive select — emits again whenever the table changes
Stream<List<Todo>> watchTodos() => (select(todos)
      ..orderBy([
        (t) => OrderingTerm(expression: t.done),
        (t) => OrderingTerm.desc(t.createdAt),
      ]))
    .watch();

// one-shot select
Future<List<Todo>> openTodos() => (select(todos)..where((t) => t.done.equals(false))).get();

// update
Future<void> toggleTodo(Todo todo) => (update(todos)..where((t) => t.id.equals(todo.id)))
    .write(TodosCompanion(done: Value(!todo.done)));

// delete
Future<int> deleteTodo(int id) => (delete(todos)..where((t) => t.id.equals(id))).go();

// transaction
await transaction(() async {
  await addTodo('a');
  await addTodo('b');
});
```
- `TodosCompanion.insert(...)` — required columns as parameters, defaults filled by the DB.
- `Value(x)` = set column, `Value.absent()` = leave unchanged.

### 5. Web setup
Put two files in `web/` (already done in this project):

| File | Source |
|---|---|
| `web/sqlite3.wasm` | GitHub release of `simolus3/sqlite3.dart` **matching `sqlite3` in pubspec.lock** (here `sqlite3-3.5.2`) → asset `sqlite3.wasm` |
| `web/drift_worker.js` | Copy from the pub cache: `drift-2.35.0/drift_worker.js` |

```powershell
# version from pubspec.lock → release sqlite3-<version>
Invoke-WebRequest https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-3.5.2/sqlite3.wasm -OutFile web\sqlite3.wasm
Copy-Item "$env:LOCALAPPDATA\Pub\Cache\hosted\pub.dev\drift-2.35.0\drift_worker.js" web\drift_worker.js
```
Update both when upgrading `drift`/`sqlite3`. A `sql.js` wasm doesn't work. Web storage uses OPFS/IndexedDB
depending on browser support.

### 6. UI — `lib/storage/drift/todos_page.dart`
```dart
class _TodosPageState extends State<TodosPage> {
  late final AppDatabase _db = widget.database ?? appDatabase;
  late final Stream<List<Todo>> _todos = _db.watchTodos();     // once, not in build

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Todo>>(
      stream: _todos,
      builder: (context, snapshot) {
        final todos = snapshot.data;
        if (todos == null) return const CircularProgressIndicator();
        return ListView(children: [
          for (final todo in todos)
            CheckboxListTile(
              value: todo.done,
              onChanged: (_) => _db.toggleTodo(todo),              // UI updates via the stream
              title: Text(todo.title),
            ),
        ]);
      },
    );
  }
}
```
No `setState` after writes — `watch()` pushes the new list.

## Migrations
```dart
@override
int get schemaVersion => 2;

@override
MigrationStrategy get migration => MigrationStrategy(
      onCreate: (m) => m.createAll(),
      onUpgrade: (m, from, to) async {
        if (from < 2) {
          await m.addColumn(todos, todos.priority);   // after adding `priority` to the table
        }
      },
    );
```
- Never edit an old step; add a new `if (from < N)` block.
- For larger apps use `drift_dev make-migrations` (schema snapshots + generated step-by-step migrations and tests).
- Downgrades throw — don't lower `schemaVersion`.

## Testing — `test/drift_test.dart`
```dart
import 'package:drift/native.dart';

setUp(() => db = AppDatabase(NativeDatabase.memory()));
tearDown(() => db.close());

test('insert, toggle and delete a todo', () async {
  final id = await db.addTodo('Write docs');
  var todos = await db.watchTodos().first;
  expect(todos.single.done, isFalse);

  await db.toggleTodo(todos.single);
  expect((await db.watchTodos().first).single.done, isTrue);

  await db.deleteTodo(id);
  expect(await db.watchTodos().first, isEmpty);
});
```
In-memory SQLite works in `flutter test` on desktop hosts (bundled by the `sqlite3` hooks).

## Notes
- Keep **one** `AppDatabase` instance per database file; multiple instances on the same file cause lock errors
  (drift prints a warning).
- `drift_dev` and `hive_ce_generator` share `build_runner` in this project (compatible analyzer 14 / build 4).
- Heavy queries on the main isolate: `DriftNativeOptions(shareAcrossIsolates: true)` or run in a background isolate.
- Commit generated `*.g.dart` files or run build_runner in CI before `flutter build`.
