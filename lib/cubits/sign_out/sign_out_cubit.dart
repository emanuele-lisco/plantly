import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/auth_repository.dart';

part 'sign_out_state.dart';

class SignOutCubit extends Cubit<SignOutState> {
  SignOutCubit({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const SignOutInitial());

  final AuthRepository _authRepository;

  Future<void> signOut() async {
    emit(const SignOutLoading());

    try {
      await _authRepository.signOut();
      emit(const SignOutSuccess());
    } on FirebaseAuthException catch (e) {
      emit(SignOutFailure(_mapFirebaseError(e)));
    } catch (_) {
      emit(const SignOutFailure(
        'Errore durante il logout. Riprova.',
      ));
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'network-request-failed':
        return 'Errore di rete durante il logout.';
      case 'too-many-requests':
        return 'Troppi tentativi. Riprova più tardi.';
      case 'user-token-expired':
        return 'Sessione scaduta. Accedi di nuovo.';
      case 'requires-recent-login':
        return 'Per completare l’operazione è necessario accedere di nuovo.';
      default:
        return e.message ?? 'Errore durante il logout.';
    }
  }
}