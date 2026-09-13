import 'package:material_ui/material_ui.dart';

import '../../l10n/l10n_extension.dart';
import 'app_database.dart';

class TodosPage extends StatefulWidget {
  const TodosPage({super.key, this.database});

  /// Defaults to the app-wide [appDatabase]; tests pass an in-memory one.
  final AppDatabase? database;

  @override
  State<TodosPage> createState() => _TodosPageState();
}

class _TodosPageState extends State<TodosPage> {
  late final AppDatabase _db = widget.database ?? appDatabase;
  late final Stream<List<Todo>> _todos = _db.watchTodos(); // once, not in build
  final _title = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    _title.clear();
    await _db.addTodo(title);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.driftTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _title,
                    decoration: InputDecoration(labelText: l10n.todosHint),
                    onSubmitted: (_) => _add(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(icon: const Icon(Icons.add), tooltip: l10n.add, onPressed: _add),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Todo>>(
              stream: _todos,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text(l10n.loadError('${snapshot.error}')));
                }
                final todos = snapshot.data;
                if (todos == null) return const Center(child: CircularProgressIndicator());
                if (todos.isEmpty) return Center(child: Text(l10n.todosEmpty));

                return ListView(
                  children: [
                    for (final todo in todos)
                      Dismissible(
                        key: ValueKey(todo.id),
                        onDismissed: (_) => _db.deleteTodo(todo.id),
                        background: ColoredBox(color: Theme.of(context).colorScheme.errorContainer),
                        child: CheckboxListTile(
                          value: todo.done,
                          onChanged: (_) => _db.toggleTodo(todo),
                          title: Text(
                            todo.title,
                            style: todo.done
                                ? const TextStyle(decoration: TextDecoration.lineThrough)
                                : null,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
