import 'package:material_ui/material_ui.dart';
import 'package:pinput/pinput.dart';

import '../l10n/l10n_extension.dart';
import '../widgets/legacy_material_scope.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  /// Demo only — a real app verifies the code on the backend.
  static const demoCode = '2222';

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _codeFocus = FocusNode();
  bool _verified = false;

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocus.dispose();
    super.dispose();
  }

  void _clear() {
    _codeController.clear();
    _codeFocus.requestFocus();
    setState(() => _verified = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;

    // "Rounded filled" style from the pinput templates, using theme colors.
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: colors.onSurface,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.transparent),
      ),
    );
    final focusedPinTheme = defaultPinTheme.copyWith(
      width: 64,
      height: 68,
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: colors.primary, width: 2),
      ),
    );
    final submittedPinTheme = defaultPinTheme.copyDecorationWith(
      color: colors.primaryContainer,
    );
    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      color: colors.errorContainer,
      border: Border.all(color: colors.error),
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.otpTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(l10n.otpInstruction, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              // pinput still asserts a legacy (flutter/material) Material ancestor.
              // Don't give it a fixed height: the error text is laid out below the pins.
              LegacyMaterialScope(
                child: Pinput(
                  length: 4,
                  controller: _codeController,
                  focusNode: _codeFocus,
                  autofocus: true,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  submittedPinTheme: submittedPinTheme,
                  errorPinTheme: errorPinTheme,
                  separatorBuilder: (index) => const SizedBox(width: 12),
                  hapticFeedbackType: HapticFeedbackType.lightImpact,
                  keyboardAppearance: Theme.of(context).brightness,
                  // Pinput is a FormField: Form.validate() runs this too.
                  validator: (pin) =>
                      pin == OtpPage.demoCode ? null : l10n.otpInvalid,
                  pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                  showErrorWhenFocused: true,
                  errorTextStyle: TextStyle(color: colors.error),
                  onCompleted: (pin) =>
                      setState(() => _verified = pin == OtpPage.demoCode),
                  onChanged: (_) {
                    if (_verified) setState(() => _verified = false);
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (_verified)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.verified, color: colors.primary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.otpVerified,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clear,
                      child: Text(l10n.otpClear),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => setState(
                        () => _verified = _formKey.currentState!.validate(),
                      ),
                      child: Text(l10n.otpVerify),
                    ),
                  ),
                ],
              ),
              const Divider(height: 48),
              Text(
                l10n.otpObscured,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              LegacyMaterialScope(
                child: Pinput(
                  length: 6,
                  obscureText: true, // PIN entry: show • instead of digits
                  defaultPinTheme: defaultPinTheme.copyWith(
                    width: 44,
                    height: 52,
                  ),
                  focusedPinTheme: focusedPinTheme.copyWith(
                    width: 44,
                    height: 52,
                  ),
                  separatorBuilder: (index) => const SizedBox(width: 8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
