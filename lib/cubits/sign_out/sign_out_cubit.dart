import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/auth_repository.dart';

part 'sign_out_state.dart';

class SignOutCubit extends Cubit<SignOutState> {
  final AuthRepository _authRepository;

  SignOutCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const SignOutInitial());

  Future<void> signOut() async {
    emit(const SignOutLoading());
    try {
      await _authRepository.signOut();
      emit(const SignOutSuccess());
    } catch (_) {
      emit(const SignOutFailure('Errore durante il logout'));
    }
  }
}
