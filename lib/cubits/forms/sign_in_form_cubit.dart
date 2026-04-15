import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../sign_in/sign_in_cubit.dart';

class SignInFormState extends Equatable {
  final String identifier;
  final String password;
  final String? identifierError;
  final String? passwordError;
  final bool showErrors;

  const SignInFormState({
    this.identifier = '',
    this.password = '',
    this.identifierError,
    this.passwordError,
    this.showErrors = false,
  });

  SignInFormState copyWith({
    String? identifier,
    String? password,
    String? identifierError,
    String? passwordError,
    bool? showErrors,
  }) {
    return SignInFormState(
      identifier: identifier ?? this.identifier,
      password: password ?? this.password,
      identifierError: identifierError,
      passwordError: passwordError,
      showErrors: showErrors ?? this.showErrors,
    );
  }

  @override
  List<Object?> get props => [
        identifier,
        password,
        identifierError,
        passwordError,
        showErrors,
      ];
}

class SignInFormCubit extends Cubit<SignInFormState> {
  final SignInCubit signInCubit;

  SignInFormCubit({required this.signInCubit})
      : super(const SignInFormState());

  void updateIdentifier(String value) {
    emit(state.copyWith(
      identifier: value,
      identifierError: _validateIdentifier(value),
    ));
  }

  void updatePassword(String value) {
    emit(state.copyWith(
      password: value,
      passwordError: _validatePassword(value),
    ));
  }

  void submit() {
    final identifierError = _validateIdentifier(state.identifier);
    final passwordError = _validatePassword(state.password);

    if (identifierError != null || passwordError != null) {
      emit(state.copyWith(
        identifierError: identifierError,
        passwordError: passwordError,
        showErrors: true,
      ));
      return;
    }

    signInCubit.signIn(state.identifier.trim(), state.password);
  }

  String? _validateIdentifier(String value) {
    if (value.trim().isEmpty) {
      return 'Inserisci email o username';
    }
    return null;
  }

  String? _validatePassword(String value) {
    if (value.isEmpty) return 'Inserisci la password';
    if (value.length < 8) return 'Almeno 8 caratteri';
    return null;
  }
}
