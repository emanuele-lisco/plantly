import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/location/city_option.dart';
import '../../features/location/country_option.dart';
import '../../features/strenght_enum.dart';
import '../sign_up/sign_up_cubit.dart';

class SignUpFormState extends Equatable {
  final String username;
  final String nome;
  final String cognome;
  final String email;
  final String countryCode;
  final String country;
  final String city;
  final double? latitude;
  final double? longitude;
  final String password;
  final String confirmPassword;
  final String? usernameError;
  final String? nomeError;
  final String? cognomeError;
  final String? emailError;
  final String? countryError;
  final String? cityError;
  final String? passwordError;
  final String? confirmPasswordError;
  final bool showErrors;
  final Strength passwordStrength;

  const SignUpFormState({
    this.username = '',
    this.nome = '',
    this.cognome = '',
    this.email = '',
    this.countryCode = '',
    this.country = '',
    this.city = '',
    this.latitude,
    this.longitude,
    this.password = '',
    this.confirmPassword = '',
    this.usernameError,
    this.nomeError,
    this.cognomeError,
    this.emailError,
    this.countryError,
    this.cityError,
    this.passwordError,
    this.confirmPasswordError,
    this.showErrors = false,
    this.passwordStrength = Strength.empty,
  });

  CountryOption? get selectedCountry => CountryOption.fromValues(
        countryCode: countryCode,
        countryName: country,
      );

  CityOption? get selectedCity {
    if (city.trim().isEmpty) return null;
    return CityOption(
      name: city,
      countryCode: countryCode,
      countryName: country,
      latitude: latitude,
      longitude: longitude,
    );
  }

  SignUpFormState copyWith({
    String? username,
    String? nome,
    String? cognome,
    String? email,
    String? countryCode,
    String? country,
    String? city,
    double? latitude,
    double? longitude,
    bool clearLatitude = false,
    bool clearLongitude = false,
    String? password,
    String? confirmPassword,
    String? usernameError,
    String? nomeError,
    String? cognomeError,
    String? emailError,
    String? countryError,
    String? cityError,
    String? passwordError,
    String? confirmPasswordError,
    bool? showErrors,
    Strength? passwordStrength,
  }) {
    return SignUpFormState(
      username: username ?? this.username,
      nome: nome ?? this.nome,
      cognome: cognome ?? this.cognome,
      email: email ?? this.email,
      countryCode: countryCode ?? this.countryCode,
      country: country ?? this.country,
      city: city ?? this.city,
      latitude: clearLatitude ? null : latitude ?? this.latitude,
      longitude: clearLongitude ? null : longitude ?? this.longitude,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      usernameError: usernameError,
      nomeError: nomeError,
      cognomeError: cognomeError,
      emailError: emailError,
      countryError: countryError,
      cityError: cityError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      showErrors: showErrors ?? this.showErrors,
      passwordStrength: passwordStrength ?? this.passwordStrength,
    );
  }

  @override
  List<Object?> get props => [
        username,
        nome,
        cognome,
        email,
        countryCode,
        country,
        city,
        latitude,
        longitude,
        password,
        confirmPassword,
        usernameError,
        nomeError,
        cognomeError,
        emailError,
        countryError,
        cityError,
        passwordError,
        confirmPasswordError,
        showErrors,
        passwordStrength,
      ];
}

class SignUpFormCubit extends Cubit<SignUpFormState> {
  final SignUpCubit signUpCubit;

  SignUpFormCubit({required this.signUpCubit}) : super(const SignUpFormState());

  void updateUsername(String value) {
    emit(state.copyWith(
      username: value,
      usernameError: _validateUsername(value),
    ));
  }

  void updateNome(String value) {
    emit(state.copyWith(
      nome: value,
      nomeError: _validateRequired(value, 'Nome'),
    ));
  }

  void updateCognome(String value) {
    emit(state.copyWith(
      cognome: value,
      cognomeError: _validateRequired(value, 'Cognome'),
    ));
  }

  void updateEmail(String value) {
    emit(state.copyWith(
      email: value,
      emailError: _validateEmail(value),
    ));
  }

  void updateCountry(CountryOption? value) {
    emit(state.copyWith(
      countryCode: value?.code ?? '',
      country: value?.name ?? '',
      city: '',
      clearLatitude: true,
      clearLongitude: true,
      countryError: value == null ? 'Paese obbligatorio' : null,
      cityError: 'Città obbligatoria',
    ));
  }

  void updateCity(CityOption? value) {
    emit(state.copyWith(
      city: value?.name ?? '',
      latitude: value?.latitude,
      longitude: value?.longitude,
      clearLatitude: value == null,
      clearLongitude: value == null,
      cityError: value == null ? 'Seleziona una città dalla lista' : null,
    ));
  }

  void updatePassword(String value) {
    emit(state.copyWith(
      password: value,
      passwordError: _validatePassword(value),
      confirmPasswordError: _validateConfirmPassword(state.confirmPassword, value),
      passwordStrength: _calculatePasswordStrength(value),
    ));
  }

  void updateConfirmPassword(String value) {
    emit(state.copyWith(
      confirmPassword: value,
      confirmPasswordError: _validateConfirmPassword(value, state.password),
    ));
  }

  Future<void> submit() async {
    final usernameError = _validateUsername(state.username);
    final nomeError = _validateRequired(state.nome, 'Nome');
    final cognomeError = _validateRequired(state.cognome, 'Cognome');
    final emailError = _validateEmail(state.email);
    final countryError = _validateRequired(state.countryCode, 'Paese');
    final cityError = _validateRequired(state.city, 'Città');
    final passwordError = _validatePassword(state.password);
    final confirmPasswordError =
        _validateConfirmPassword(state.confirmPassword, state.password);

    final hasError = [
      usernameError,
      nomeError,
      cognomeError,
      emailError,
      countryError,
      cityError,
      passwordError,
      confirmPasswordError,
    ].any((e) => e != null);

    if (hasError) {
      emit(state.copyWith(
        usernameError: usernameError,
        nomeError: nomeError,
        cognomeError: cognomeError,
        emailError: emailError,
        countryError: countryError,
        cityError: cityError,
        passwordError: passwordError,
        confirmPasswordError: confirmPasswordError,
        showErrors: true,
      ));
      return;
    }

    await signUpCubit.signUp(
      username: state.username.trim(),
      nome: state.nome.trim(),
      cognome: state.cognome.trim(),
      email: state.email.trim(),
      countryCode: state.countryCode.trim(),
      country: state.country.trim(),
      city: state.city.trim(),
      latitude: state.latitude,
      longitude: state.longitude,
      password: state.password,
    );
  }

  String? _validateRequired(String value, String fieldName) {
    if (value.trim().isEmpty) return '$fieldName obbligatorio';
    return null;
  }

  String? _validateUsername(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'Username obbligatorio';
    if (trimmed.length < 3) return 'Minimo 3 caratteri';
    final valid = RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(trimmed);
    if (!valid) return 'Usa solo lettere, numeri, punto o underscore';
    return null;
  }

  String? _validateEmail(String value) {
    if (value.trim().isEmpty) return 'Email obbligatoria';
    final valid = RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim());
    if (!valid) return 'Email non valida';
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Password obbligatoria';
    if (value.length < 8) return 'Minimo 8 caratteri';

    final hasUppercase = RegExp(r'[A-Z]').hasMatch(value);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(value);
    final hasDigit = RegExp(r'\d').hasMatch(value);
    final hasSpecialChar =
        RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\\/\[\]=+;]').hasMatch(value);

    if (!hasUppercase) return 'Almeno una lettera maiuscola';
    if (!hasLowercase) return 'Almeno una lettera minuscola';
    if (!hasDigit) return 'Almeno un numero';
    if (!hasSpecialChar) return 'Almeno un carattere speciale';

    return null;
  }

  String? _validateConfirmPassword(String confirmPassword, String password) {
    if (confirmPassword.isEmpty) return 'Conferma la password';
    if (confirmPassword != password) return 'Le password non coincidono';
    return null;
  }

  Strength _calculatePasswordStrength(String value) {
    if (value.isEmpty) return Strength.empty;

    int score = 0;
    if (value.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(value)) score++;
    if (RegExp(r'[a-z]').hasMatch(value)) score++;
    if (RegExp(r'\d').hasMatch(value)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\\/\[\]=+;]').hasMatch(value)) {
      score++;
    }

    if (score <= 3) return Strength.weak;
    if (score <= 4) return Strength.medium;
    return Strength.strong;
  }
}
