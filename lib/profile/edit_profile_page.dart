import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n_extension.dart';
import '../router/confirm_discard_dialog.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.initialName});

  final String initialName;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final _name = TextEditingController(text: widget.initialName)
    ..addListener(() => setState(() {}));

  bool get _hasChanges => _name.text.trim() != widget.initialName && _name.text.trim().isNotEmpty;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() => context.pop(_name.text.trim()); // result for push<String>

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    // Unsaved changes → back button/gesture asks first. context.pop() in _save is not blocked.
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await confirmDiscardChanges(context) && context.mounted) {
          context.pop(); // no result → caller gets null
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.profileEdit),
          actions: [
            TextButton(onPressed: _hasChanges ? _save : null, child: Text(l10n.save)),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _name,
            autofocus: true,
            decoration: InputDecoration(labelText: l10n.loginUserName),
            onSubmitted: (_) => _hasChanges ? _save() : null,
          ),
        ),
      ),
    );
  }
}
