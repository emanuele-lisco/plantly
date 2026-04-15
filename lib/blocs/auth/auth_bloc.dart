import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/auth_repository.dart';

part 'auth_bloc_event.dart';
part 'auth_bloc_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthBlocState> {
  final AuthRepository _authRepository;
  StreamSubscription<fb.User?>? _authSubscription;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthBlocState.unknown()) {
    on<AuthUserChanged>(_onAuthUserChanged);

    // Firebase emette subito il valore corrente al momento della sottoscrizione,
    // quindi non serve nessun evento "check" manuale: questo stream gestisce
    // sia il cold start che i cambi successivi (login/logout).
    _authSubscription = _authRepository.authStateChanges.listen(
      (user) => add(AuthUserChanged(user)),
    );
  }

  void _onAuthUserChanged(
    AuthUserChanged event,
    Emitter<AuthBlocState> emit,
  ) {
    final user = event.user;
    if (user != null) {
      emit(AuthBlocState.authenticated(user));
    } else {
      emit(const AuthBlocState.unauthenticated());
    }
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
