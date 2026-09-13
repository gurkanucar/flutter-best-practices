import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:material_ui/material_ui.dart';

import 'app_localizations.dart';

/// Localization delegates for the whole app (and widget tests).
///
/// Don't use the generated `AppLocalizations.localizationsDelegates`: it still lists
/// `flutter_localizations`' Material/Cupertino delegates, which `material_ui` widgets
/// (date pickers, dialogs, text fields) don't read.
final List<LocalizationsDelegate<dynamic>> appLocalizationDelegates = [
  AppLocalizations.delegate,
  // Widgets + Material + Cupertino localizations from material_ui / cupertino_ui.
  ...GlobalMaterialLocalizations.delegates,
  FormBuilderLocalizations.delegate, // translated validator error messages
];
