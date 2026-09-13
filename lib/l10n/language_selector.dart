import 'package:country_flags/country_flags.dart';
import 'package:material_ui/material_ui.dart';

import 'l10n_extension.dart';
import 'supported_languages.dart';

/// App bar language menu: device language + [supportedLanguages] with flags.
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  // PopupMenuButton treats a null value as "cancelled", so use string keys.
  static const _systemKey = 'system';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = LanguageOption.fromLocale(Localizations.localeOf(context));

    return ValueListenableBuilder<Locale?>(
      valueListenable: localeNotifier,
      builder: (context, selectedLocale, _) {
        final selectedKey = selectedLocale?.languageCode ?? _systemKey;

        return PopupMenuButton<String>(
          tooltip: l10n.language,
          initialValue: selectedKey,
          onSelected: (key) =>
              localeNotifier.value = key == _systemKey ? null : Locale(key),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: _systemKey,
              child: _MenuRow(
                leading: const Icon(Icons.phone_android, size: 20),
                label: l10n.systemLanguage,
                selected: selectedKey == _systemKey,
              ),
            ),
            const PopupMenuDivider(),
            for (final option in supportedLanguages)
              PopupMenuItem(
                value: option.locale.languageCode,
                child: _MenuRow(
                  leading: LanguageFlag(option.countryCode),
                  label: option.label,
                  selected: selectedKey == option.locale.languageCode,
                ),
              ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: LanguageFlag(current.countryCode),
          ),
        );
      },
    );
  }
}

class LanguageFlag extends StatelessWidget {
  const LanguageFlag(this.countryCode, {super.key});

  final String countryCode;

  @override
  Widget build(BuildContext context) {
    return CountryFlag.fromCountryCode(
      countryCode,
      theme: const ImageTheme(width: 28, height: 20, shape: RoundedRectangle(4)),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.leading,
    required this.label,
    required this.selected,
  });

  final Widget leading;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 28, child: Center(child: leading)),
        const SizedBox(width: 12),
        Expanded(child: Text(label)),
        if (selected) const Icon(Icons.check, size: 20),
      ],
    );
  }
}
