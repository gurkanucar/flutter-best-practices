import 'package:material_ui/material_ui.dart';

import '../l10n/l10n_extension.dart';

/// Returns `true` if the user wants to leave and lose unsaved changes.
Future<bool> confirmDiscardChanges(BuildContext context) async {
  final l10n = context.l10n;
  final leave = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.discardChangesTitle),
      content: Text(l10n.discardChangesMessage),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.stay)),
        FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l10n.discard)),
      ],
    ),
  );
  return leave ?? false;
}
