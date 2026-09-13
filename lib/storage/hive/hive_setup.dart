import 'package:flutter/widgets.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../../l10n/supported_languages.dart';
import 'hive_registrar.g.dart';
import 'note.dart';

abstract final class HiveBoxes {
  static const settings = 'settings';
  static const notes = 'notes';
}

abstract final class SettingsKeys {
  static const languageCode = 'languageCode';
}

/// Call once in `main()` before `runApp`.
Future<void> initHive() async {
  // App documents directory on native, IndexedDB on web.
  await Hive.initFlutter();
  Hive.registerAdapters(); // generated extension

  // Open boxes up front → Hive.box() is synchronous everywhere afterwards.
  final settings = await Hive.openBox<String>(HiveBoxes.settings);
  await Hive.openBox<Note>(HiveBoxes.notes);

  _persistLanguage(settings);
}

/// Restores the language picked in the language selector and saves future changes.
void _persistLanguage(Box<String> settings) {
  final savedCode = settings.get(SettingsKeys.languageCode);
  if (savedCode != null) localeNotifier.value = Locale(savedCode);

  localeNotifier.addListener(() {
    final locale = localeNotifier.value;
    if (locale == null) {
      settings.delete(SettingsKeys.languageCode); // follow system language again
    } else {
      settings.put(SettingsKeys.languageCode, locale.languageCode);
    }
  });
}
