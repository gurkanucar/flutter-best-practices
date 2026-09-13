import 'package:drift/native.dart';
import 'package:flutter_best_practices/storage/drift/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('insert, toggle and delete a todo', () async {
    final id = await db.addTodo('Write docs');

    var todos = await db.watchTodos().first;
    expect(todos.single.title, 'Write docs');
    expect(todos.single.done, isFalse);

    await db.toggleTodo(todos.single);
    todos = await db.watchTodos().first;
    expect(todos.single.done, isTrue);

    await db.deleteTodo(id);
    expect(await db.watchTodos().first, isEmpty);
  });

  test('open todos are listed before done ones', () async {
    await db.addTodo('first');
    await db.addTodo('second');
    final todos = await db.watchTodos().first;
    await db.toggleTodo(todos.firstWhere((todo) => todo.title == 'second'));

    final ordered = await db.watchTodos().first;
    expect(ordered.map((todo) => todo.title), ['first', 'second']);
    expect(ordered.last.done, isTrue);
  });

  test('watch emits again after an insert', () async {
    final lengths = db.watchTodos().map((todos) => todos.length);
    final expectation = expectLater(lengths, emitsInOrder([0, 1]));
    await Future<void>.delayed(Duration.zero); // let the first query run
    await db.addTodo('a');
    await expectation;
  });
}
