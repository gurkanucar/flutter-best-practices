import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/l10n_extension.dart';
import 'hive_setup.dart';
import 'note.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _title = TextEditingController();

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _add(Box<Note> box) {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    box.add(Note(title: title, createdAt: DateTime.now())); // auto-increment int key
    _title.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (!Hive.isBoxOpen(HiveBoxes.notes)) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.hiveTitle)),
        body: Center(child: Text(l10n.loadError('Hive box "${HiveBoxes.notes}" is not open'))),
      );
    }

    final box = Hive.box<Note>(HiveBoxes.notes);
    final dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).toLanguageTag()).add_Hm();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.hiveTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _title,
                    decoration: InputDecoration(labelText: l10n.notesHint),
                    onSubmitted: (_) => _add(box),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.add),
                  tooltip: l10n.add,
                  onPressed: () => _add(box),
                ),
              ],
            ),
          ),
          Expanded(
            // Rebuilds on every put/delete in the box.
            child: ValueListenableBuilder<Box<Note>>(
              valueListenable: box.listenable(),
              builder: (context, box, _) {
                if (box.isEmpty) return Center(child: Text(l10n.notesEmpty));

                final entries = box.toMap().entries.toList()
                  ..sort((a, b) {
                    if (a.value.pinned != b.value.pinned) return a.value.pinned ? -1 : 1;
                    return b.value.createdAt.compareTo(a.value.createdAt);
                  });

                return ListView(
                  children: [
                    for (final entry in entries)
                      Dismissible(
                        key: ValueKey(entry.key),
                        onDismissed: (_) => box.delete(entry.key),
                        background: ColoredBox(color: Theme.of(context).colorScheme.errorContainer),
                        child: ListTile(
                          title: Text(entry.value.title),
                          subtitle: Text(dateFormat.format(entry.value.createdAt)),
                          trailing: IconButton(
                            icon: Icon(entry.value.pinned ? Icons.push_pin : Icons.push_pin_outlined),
                            tooltip: entry.value.pinned ? l10n.unpin : l10n.pin,
                            onPressed: () => box.put(
                              entry.key,
                              entry.value.copyWith(pinned: !entry.value.pinned),
                            ),
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
