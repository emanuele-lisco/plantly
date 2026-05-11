import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../repositories/auth_repository.dart';
import '../../repositories/user_repository.dart';

part 'sign_in_state.dart';

class SignInCubit extends Cubit<SignInState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  SignInCubit({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        super(SignInInitial());

  Future<void> signIn(String identifier, String password) async {
    emit(SignInLoading());

    try {
      final email =
      await _userRepository.resolveEmailFromIdentifier(identifier);

      await _authRepository.signIn(
        email: email,
        password: password,
      );

      emit(SignInSuccess());
    } on UserRepositoryException catch (e) {
      emit(SignInFailure(e.message));
    } on FirebaseAuthException catch (e) {
      emit(SignInFailure(_mapFirebaseError(e)));
    } catch (_) {
      emit(const SignInFailure("Errore durante l'accesso"));
    }
  }

  Future<void> signInWithGoogle() async {
    emit(SignInLoading());

    try {
      final result = await _authRepository.signInWithGoogle();

      await _userRepository.ensureGoogleUserProfile(result.user);

      emit(SignInSuccess());
    } on GoogleSignInException catch (e) {
      emit(SignInFailure(_mapGoogleError(e)));
    } on UserRepositoryException catch (e) {
      emit(SignInFailure(e.message));
    } on FirebaseAuthException catch (e) {
      emit(SignInFailure(_mapFirebaseError(e)));
    } catch (_) {
      emit(const SignInFailure("Errore durante l'accesso con Google"));
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Email non valida';
      case 'invalid-credential':
        return 'Credenziali non corrette';
      case 'user-not-found':
        return 'Utente non trovato';
      case 'wrong-password':
        return 'Password non corretta';
      case 'user-disabled':
        return 'Account disabilitato';
      case 'too-many-requests':
        return 'Troppi tentativi. Riprova più tardi';
      case 'network-request-failed':
        return 'Errore di rete';
      case 'account-exists-with-different-credential':
        return 'Esiste già un account con questa email ma con un metodo di accesso diverso.';
      case 'popup-closed-by-user':
        return 'Accesso con Google annullato.';
      case 'popup-blocked':
        return 'Il popup di Google è stato bloccato dal browser.';
      default:
        return e.message ?? "Errore durante l'accesso";
    }
  }

  String _mapGoogleError(GoogleSignInException e) {
    switch (e.code) {
      case GoogleSignInExceptionCode.canceled:
        return 'Accesso con Google annullato.';
      case GoogleSignInExceptionCode.interrupted:
        return 'Accesso con Google interrotto. Riprova.';
      case GoogleSignInExceptionCode.clientConfigurationError:
        return 'Configurazione Google non valida per questa app.';
      case GoogleSignInExceptionCode.providerConfigurationError:
        return 'Provider Google non configurato correttamente.';
      case GoogleSignInExceptionCode.uiUnavailable:
        return 'Interfaccia Google non disponibile in questo momento.';
      case GoogleSignInExceptionCode.userMismatch:
        return "L'account Google selezionato non è valido per questa sessione.";
      case GoogleSignInExceptionCode.unknownError:
        return e.description ?? "Errore durante l'accesso con Google.";
      default:
        return e.description ?? "Errore durante l'accesso con Google.";
    }
  }
}