import 'package:equatable/equatable.dart';

/// Field names shared by the form widgets and [SignUpData.fromFormValue].
abstract final class SignUpFields {
  static const name = 'name';
  static const email = 'email';
  static const password = 'password';
  static const confirmPassword = 'confirmPassword';
  static const birthDate = 'birthDate';
  static const role = 'role';
  static const acceptTerms = 'acceptTerms';
}

class SignUpData extends Equatable {
  const SignUpData({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    required this.acceptedTerms,
    this.birthDate,
  });

  /// Maps `FormBuilderState.value` (after `saveAndValidate`) to a typed model.
  factory SignUpData.fromFormValue(Map<String, dynamic> value) {
    return SignUpData(
      name: (value[SignUpFields.name] as String).trim(),
      email: (value[SignUpFields.email] as String).trim(),
      password: value[SignUpFields.password] as String,
      role: value[SignUpFields.role] as String,
      acceptedTerms: value[SignUpFields.acceptTerms] as bool? ?? false,
      birthDate: value[SignUpFields.birthDate] as DateTime?,
    );
  }

  final String name;
  final String email;
  final String password;
  final String role;
  final bool acceptedTerms;
  final DateTime? birthDate;

  @override
  List<Object?> get props => [name, email, password, role, acceptedTerms, birthDate];

  /// Never print the password — overrides `EquatableConfig.stringify` (true in debug).
  @override
  bool get stringify => false;
}
