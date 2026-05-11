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

    _authSubscription = _authRepository.authStateChanges.listen(
          (user) => add(AuthUserChanged(user)),
      onError: (Object error, StackTrace stackTrace) {
        add(const AuthUserChanged(null));
      },
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