import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../features/user/user.dart';
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

  // ── Public flag ─────────────────────────────────────────────────────────

  /// Whether profile completion navigation is pending.
  ///
  /// Set to true before emitting [SignInNeedsProfileCompletion] and reset
  /// to false by [App] after navigation to [Routes.googleProfileCompletion]
  /// has been scheduled. The [AuthBloc] listener in [App] reads this flag
  /// to decide whether to skip its own navigation to /home, which would
  /// otherwise race with the profile-completion navigation.
  bool pendingProfileCompletion = false;

  // ── Classic sign-in ─────────────────────────────────────────────────────

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

  // ── Google sign-in ──────────────────────────────────────────────────────

  Future<void> signInWithGoogle() async {
    emit(SignInLoading());

    try {
      final result = await _authRepository.signInWithGoogle();

      // Ensure a Firestore document exists. For new users this creates a
      // partial document (country and city are empty strings); for existing
      // users it returns the stored profile unchanged.
      final user =
          await _userRepository.ensureGoogleUserProfile(result.user);

      // Check whether required fields are filled.
      if (_isProfileIncomplete(user)) {
        // Set the flag BEFORE emitting the state so that the AuthBloc
        // listener (which fires asynchronously via addPostFrameCallback)
        // sees it as true and skips its own navigation to /home.
        pendingProfileCompletion = true;
        emit(SignInNeedsProfileCompletion(
          firebaseUser: result.user,
          incompleteUser: user,
        ));
        return;
      }

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

  // ── Helpers ─────────────────────────────────────────────────────────────

  /// A profile is considered incomplete when any of the three fields that
  /// Google cannot provide (username chosen by the user, country, city) is
  /// blank.
  bool _isProfileIncomplete(PlantlyUser user) {
    return user.username.trim().isEmpty ||
        user.country.trim().isEmpty ||
        user.city.trim().isEmpty;
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
