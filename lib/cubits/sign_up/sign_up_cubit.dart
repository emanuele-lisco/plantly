import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../features/user/user.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/user_repository.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  SignUpCubit({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  })  : _authRepository = authRepository,
        _userRepository = userRepository,
        super(SignUpInitial());

  Future<void> signUp({
    required String username,
    required String nome,
    required String cognome,
    required String email,
    required String password,
    required String countryCode,
    required String country,
    required String city,
    double? latitude,
    double? longitude,
  }) async {
    emit(SignUpLoading());

    try {
      final displayName = [nome.trim(), cognome.trim()]
          .where((part) => part.isNotEmpty)
          .join(' ');

      final authUser = await _authRepository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );

      final user = PlantlyUser(
        id: authUser.uid,
        username: username.trim(),
        name: nome.trim(),
        surname: cognome.trim(),
        email: email.trim(),
        country: country.trim(),
        countryCode: countryCode.trim().toUpperCase(),
        countryName: country.trim(),
        city: city.trim(),
        latitude: latitude,
        longitude: longitude,
      );

      try {
        await _userRepository.createUserProfile(user);
      } catch (_) {
        try {
          await authUser.delete();
        } catch (e, st) {
          debugPrint('Errore durante rollback authUser.delete(): $e');
          debugPrintStack(stackTrace: st);
        }
        rethrow;
      }

      emit(const SignUpSuccess('Registrazione completata con successo'));
    } on UserRepositoryException catch (e) {
      emit(SignUpFailure(e.message));
    } on FirebaseAuthException catch (e) {
      emit(SignUpFailure(_mapFirebaseError(e)));
    } catch (_) {
      emit(const SignUpFailure('Errore durante la registrazione'));
    }
  }

  Future<void> signUpWithGoogle() async {
    emit(SignUpLoading());

    try {
      final result = await _authRepository.signInWithGoogle();

      await _userRepository.ensureGoogleUserProfile(result.user);

      emit(const SignUpSuccess('Accesso con Google completato'));
    } on GoogleSignInException catch (e) {
      emit(SignUpFailure(_mapGoogleError(e)));
    } on UserRepositoryException catch (e) {
      emit(SignUpFailure(e.message));
    } on FirebaseAuthException catch (e) {
      emit(SignUpFailure(_mapFirebaseError(e)));
    } catch (_) {
      emit(const SignUpFailure('Errore durante la registrazione con Google'));
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Questa email è già registrata';
      case 'invalid-email':
        return 'Email non valida';
      case 'weak-password':
        return 'Password troppo debole';
      case 'operation-not-allowed':
        return 'Registrazione non abilitata';
      case 'network-request-failed':
        return 'Errore di rete';
      case 'requires-recent-login':
        return 'Operazione non completata. Riprova';
      case 'account-exists-with-different-credential':
        return 'Esiste già un account con questa email ma con un metodo di accesso diverso.';
      case 'popup-closed-by-user':
        return 'Accesso con Google annullato.';
      case 'popup-blocked':
        return 'Il popup di Google è stato bloccato dal browser.';
      default:
        return e.message ?? 'Errore durante la registrazione';
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
        return e.description ?? 'Errore durante la registrazione con Google.';
      default:
        return e.description ?? 'Errore durante la registrazione con Google.';
    }
  }
}