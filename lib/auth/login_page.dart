import 'package:material_ui/material_ui.dart';

import '../l10n/l10n_extension.dart';
import 'auth_scope.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.from});

  /// Location the user wanted to open before being redirected here.
  final String? from;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _userName = TextEditingController();

  @override
  void dispose() {
    _userName.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _userName.text.trim();
    if (name.isEmpty) return;
    // No navigation here: the router's refreshListenable re-runs redirect,
    // which sends the user to `from` (or home).
    await AuthScope.read(context).login(name);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.loginTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.from != null) ...[
            Text(l10n.loginRequiredFor(widget.from!)),
            const SizedBox(height: 16),
          ],
          TextField(
            controller: _userName,
            decoration: InputDecoration(labelText: l10n.loginUserName),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: _submit, child: Text(l10n.loginButton)),
        ],
      ),
    );
  }
}
