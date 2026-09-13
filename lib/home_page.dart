import 'package:flutter/material.dart';

import 'l10n/l10n_extension.dart';
import 'l10n/language_selector.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: const [LanguageSelector()],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(l10n.hello, style: Theme.of(context).textTheme.headlineMedium),
          Text(l10n.welcome('John')),
          Text(l10n.itemCount(0)),
          Text(l10n.itemCount(1)),
          Text(l10n.itemCount(5)),
          Text(l10n.userRole('admin')),
          Text(l10n.lastLogin(DateTime.now())),
          Text(l10n.price(149.9)),
        ],
      ),
    );
  }
}
