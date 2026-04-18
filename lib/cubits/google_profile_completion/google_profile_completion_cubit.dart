import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/user/user.dart';
import '../../repositories/user_repository.dart';

part 'google_profile_completion_state.dart';

/// Handles saving the missing profile fields (username, country, city)
/// for a Google-authenticated user who does not yet have a complete
/// Firestore profile.
///
/// This cubit is scoped to the [GoogleProfileCompletionPage] and is
/// provided only while that page is in the navigator stack.
class GoogleProfileCompletionCubit
    extends Cubit<GoogleProfileCompletionState> {
  GoogleProfileCompletionCubit({
    required UserRepository userRepository,
    required fb.User firebaseUser,
    required PlantlyUser incompleteUser,
  })  : _userRepository = userRepository,
        _firebaseUser = firebaseUser,
        _incompleteUser = incompleteUser,
        super(const GoogleProfileCompletionInitial());

  final UserRepository _userRepository;
  final fb.User _firebaseUser;
  final PlantlyUser _incompleteUser;

  /// Exposes the partial user so the page can pre-fill the username field.
  PlantlyUser get incompleteUser => _incompleteUser;

  /// Validates and persists the completed profile.
  ///
  /// [username], [country], and [city] are the values entered by the user.
  /// Any other fields already present on [_incompleteUser] are preserved.
  Future<void> completeProfile({
    required String username,
    required String country,
    required String city,
  }) async {
    emit(const GoogleProfileCompletionLoading());

    try {
      final trimmedUsername = username.trim();
      final trimmedCountry = country.trim();
      final trimmedCity = city.trim();

      // ── Client-side validation ──────────────────────────────────────────
      final validationError = _validate(
        username: trimmedUsername,
        country: trimmedCountry,
        city: trimmedCity,
      );
      if (validationError != null) {
        emit(GoogleProfileCompletionFailure(validationError));
        return;
      }

      // ── Username uniqueness check ───────────────────────────────────────
      // We only check uniqueness when the username differs from the one
      // already stored (the auto-generated one). This avoids a false
      // conflict when the user keeps the generated username as-is.
      final currentUsername = _incompleteUser.username.trim().toLowerCase();
      final newUsername = trimmedUsername.toLowerCase();
      if (currentUsername != newUsername) {
        final taken = await _userRepository.usernameExists(trimmedUsername);
        if (taken) {
          emit(const GoogleProfileCompletionFailure('Username già in uso'));
          return;
        }
      }

      // ── Determine whether to create or update ──────────────────────────
      // ensureGoogleUserProfile already created a partial document for new
      // users. We therefore always call updateUserProfile here.
      // For the edge case where the document was never written (shouldn't
      // happen in normal flow but is a safe guard), we fall back to create.
      final existingDoc =
          await _userRepository.getUser(_firebaseUser.uid);

      final completedUser = _incompleteUser.copyWith(
        username: trimmedUsername,
        country: trimmedCountry,
        city: trimmedCity,
      );

      if (existingDoc == null) {
        await _userRepository.createUserProfile(completedUser);
      } else {
        await _userRepository.updateUserProfile(completedUser);
      }

      emit(const GoogleProfileCompletionSuccess());
    } on UserRepositoryException catch (e) {
      emit(GoogleProfileCompletionFailure(e.message));
    } catch (_) {
      emit(const GoogleProfileCompletionFailure(
        'Errore durante il salvataggio del profilo',
      ));
    }
  }

  String? _validate({
    required String username,
    required String country,
    required String city,
  }) {
    if (username.isEmpty) return 'Username obbligatorio';
    if (username.length < 3) return 'Username: minimo 3 caratteri';
    final validChars = RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(username);
    if (!validChars) return 'Username: usa solo lettere, numeri, punto o _';
    if (country.isEmpty) return 'Paese obbligatorio';
    if (city.isEmpty) return 'Città obbligatoria';
    return null;
  }
}
