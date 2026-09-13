import 'dart:io';

import 'package:flutter_best_practices/storage/hive/hive_registrar.g.dart';
import 'package:flutter_best_practices/storage/hive/note.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';

void main() {
  late Directory directory;

  setUpAll(() => Hive.registerAdapters()); // generated; register once per isolate

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('hive_test_');
    Hive.init(directory.path); // plain Hive.init in tests — no path_provider
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await directory.delete(recursive: true);
  });

  test('stores a Note with the generated adapter and reads it after reopening', () async {
    final box = await Hive.openBox<Note>('notes');
    final key = await box.add(Note(title: 'Buy milk', createdAt: DateTime(2026, 9, 13, 10), pinned: true));
    await box.close();

    final reopened = await Hive.openBox<Note>('notes');
    final note = reopened.get(key)!;
    expect(note.title, 'Buy milk');
    expect(note.pinned, isTrue);
    expect(note.createdAt, DateTime(2026, 9, 13, 10));
  });

  test('box.watch emits put and delete events', () async {
    final box = await Hive.openBox<String>('settings');
    final events = <BoxEvent>[];
    final subscription = box.watch(key: 'languageCode').listen(events.add);

    await box.put('languageCode', 'tr');
    await box.delete('languageCode');
    await Future<void>.delayed(Duration.zero);

    expect(events.map((event) => event.deleted), [false, true]);
    await subscription.cancel();
  });
}
