import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart'; // dart run build_runner build

/// Table → generated row class `Todo` and `TodosCompanion` for inserts/updates.
class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [Todos])
class AppDatabase extends _$AppDatabase {
  /// Pass `NativeDatabase.memory()` in tests.
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  // Bump schemaVersion and add steps here when tables change.
  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {},
      );

  static QueryExecutor _openConnection() => driftDatabase(
        name: 'app_db', // <app documents>/app_db.sqlite on native
        web: DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'), // web/sqlite3.wasm
          driftWorker: Uri.parse('drift_worker.js'), // web/drift_worker.js
        ),
      );

  /// Open todos first, newest first. Emits again whenever the table changes.
  Stream<List<Todo>> watchTodos() => (select(todos)
        ..orderBy([
          (t) => OrderingTerm(expression: t.done),
          (t) => OrderingTerm.desc(t.createdAt),
          (t) => OrderingTerm.desc(t.id),
        ]))
      .watch();

  Future<int> addTodo(String title) => into(todos).insert(TodosCompanion.insert(title: title));

  Future<void> toggleTodo(Todo todo) => (update(todos)..where((t) => t.id.equals(todo.id)))
      .write(TodosCompanion(done: Value(!todo.done)));

  Future<int> deleteTodo(int id) => (delete(todos)..where((t) => t.id.equals(id))).go();
}

/// App-wide instance, opened lazily on first use.
final appDatabase = AppDatabase();
