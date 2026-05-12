import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/user/user.dart';
import '../../repositories/user_repository.dart';

part 'session_state.dart';

class SessionCubit extends Cubit<SessionState> {
  SessionCubit({
    required UserRepository userRepository,
  })  : _userRepository = userRepository,
        super(const SessionInitial());

  final UserRepository _userRepository;

  Future<void> resolveAuthenticatedUser(fb.User firebaseUser) async {
    emit(const SessionLoading());

    try {
      PlantlyUser? profile = await _userRepository.getUser(firebaseUser.uid);

      if (profile == null) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        profile = await _userRepository.getUser(firebaseUser.uid);
      }

      final isGoogleUser = firebaseUser.providerData.any(
        (provider) => provider.providerId == 'google.com',
      );

      if (profile == null) {
        if (isGoogleUser) {
          emit(
            SessionAuthenticatedNeedsProfileCompletion(
              firebaseUser: firebaseUser,
              incompleteUser: _buildFallbackUser(firebaseUser),
            ),
          );
          return;
        }

        emit(
          const SessionFailure(
            'Profilo utente non trovato. Effettua di nuovo l’accesso.',
          ),
        );
        return;
      }

      if (isGoogleUser && !_userRepository.isProfileComplete(profile)) {
        emit(
          SessionAuthenticatedNeedsProfileCompletion(
            firebaseUser: firebaseUser,
            incompleteUser: profile,
          ),
        );
        return;
      }

      emit(const SessionAuthenticatedComplete());
    } on UserRepositoryException catch (e) {
      emit(SessionFailure(e.message));
    } catch (_) {
      emit(
        const SessionFailure(
          'Errore durante il caricamento della sessione utente.',
        ),
      );
    }
  }

  void markUnauthenticated() {
    emit(const SessionUnauthenticated());
  }

  PlantlyUser _buildFallbackUser(fb.User firebaseUser) {
    return PlantlyUser(
      id: firebaseUser.uid,
      username: '',
      name: firebaseUser.displayName?.trim() ?? '',
      surname: '',
      email: firebaseUser.email?.trim() ?? '',
      country: '',
      city: '',
      imageUrl: firebaseUser.photoURL,
      bio: null,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
  }
}
