import 'package:material_ui/material_ui.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

import '../l10n/l10n_extension.dart';
import 'sign_up_data.dart';

class SignUpFormPage extends StatefulWidget {
  const SignUpFormPage({super.key});

  @override
  State<SignUpFormPage> createState() => _SignUpFormPageState();
}

class _SignUpFormPageState extends State<SignUpFormPage> {
  final _formKey = GlobalKey<FormBuilderState>();

  static const _roles = ['admin', 'user', 'guest'];
  static const _gap = SizedBox(height: 16);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateFormat = DateFormat.yMMMd(
      Localizations.localeOf(context).toLanguageTag(),
    );

    // Tapping outside a text field unfocuses it and closes the keyboard.
    return KeyboardDismissOnTap(
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.formTitle),
          actions: [
            KeyboardVisibilityBuilder(
              builder: (context, isKeyboardVisible) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Icon(
                  isKeyboardVisible ? Icons.keyboard : Icons.keyboard_hide,
                  semanticLabel: isKeyboardVisible
                      ? l10n.keyboardVisible
                      : l10n.keyboardHidden,
                ),
              ),
            ),
          ],
        ),
        body: FormBuilder(
          key: _formKey,
          // Not ListView: lazily built (off-screen) fields aren't registered, so they'd be skipped
          // by saveAndValidate() — e.g. the terms checkbox on a small screen.
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hide hints while the keyboard takes screen space.
                KeyboardVisibilityBuilder(
                  builder: (context, isKeyboardVisible) => isKeyboardVisible
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(l10n.keyboardTip),
                        ),
                ),
                FormBuilderTextField(
                  name: SignUpFields.name,
                  decoration: InputDecoration(labelText: l10n.formName),
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(2),
                  ]),
                ),
                _gap,
                FormBuilderTextField(
                  name: SignUpFields.email,
                  decoration: InputDecoration(labelText: l10n.formEmail),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.email(),
                  ]),
                ),
                _gap,
                FormBuilderTextField(
                  name: SignUpFields.password,
                  decoration: InputDecoration(labelText: l10n.formPassword),
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    FormBuilderValidators.minLength(8),
                  ]),
                ),
                _gap,
                FormBuilderTextField(
                  name: SignUpFields.confirmPassword,
                  decoration: InputDecoration(
                    labelText: l10n.formConfirmPassword,
                  ),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(),
                    // Cross-field validation: compare with the password field.
                    (value) =>
                        value ==
                            _formKey
                                .currentState
                                ?.fields[SignUpFields.password]
                                ?.value
                        ? null
                        : l10n.formPasswordsDoNotMatch,
                  ]),
                ),
                _gap,
                FormBuilderDateTimePicker(
                  name: SignUpFields.birthDate,
                  inputType: InputType.date,
                  format: dateFormat,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  decoration: InputDecoration(
                    labelText: l10n.formBirthDate,
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
                _gap,
                FormBuilderDropdown<String>(
                  name: SignUpFields.role,
                  initialValue: 'user',
                  decoration: InputDecoration(labelText: l10n.formRole),
                  validator: FormBuilderValidators.required(),
                  items: [
                    for (final role in _roles)
                      DropdownMenuItem(
                        value: role,
                        child: Text(l10n.userRole(role)),
                      ),
                  ],
                ),
                _gap,
                FormBuilderCheckbox(
                  name: SignUpFields.acceptTerms,
                  initialValue: false,
                  title: Text(l10n.formAcceptTerms),
                  validator: (value) =>
                      value == true ? null : l10n.formTermsRequired,
                ),
                _gap,
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _formKey.currentState?.reset(),
                        child: Text(l10n.formReset),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => _submit(dateFormat),
                        child: Text(l10n.formSubmit),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit(DateFormat dateFormat) {
    final l10n = context.l10n;
    final form = _formKey.currentState!;

    // Saves every field into form.value, validates, focuses the first invalid field.
    if (!form.saveAndValidate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.formInvalid)));
      return;
    }

    final data = SignUpData.fromFormValue(form.value);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.formSubmitted),
        content: Text(
          [
            data.name,
            data.email,
            l10n.userRole(data.role),
            if (data.birthDate != null) dateFormat.format(data.birthDate!),
          ].join('\n'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).okButtonLabel),
          ),
        ],
      ),
    );
  }
}
