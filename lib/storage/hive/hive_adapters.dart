import 'package:hive_ce/hive_ce.dart';

import 'note.dart';

// `dart run build_runner build` generates:
//  - hive_adapters.g.dart   → NoteAdapter
//  - hive_adapters.g.yaml   → type/field ids (commit it! keeps ids stable across changes)
//  - hive_registrar.g.dart  → Hive.registerAdapters()
@GenerateAdapters([AdapterSpec<Note>()])
part 'hive_adapters.g.dart';
