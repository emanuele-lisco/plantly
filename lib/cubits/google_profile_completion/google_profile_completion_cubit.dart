import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/user/user.dart';
import '../../repositories/user_repository.dart';

part 'google_profile_completion_state.dart';

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

  PlantlyUser get incompleteUser => _incompleteUser;

  Future<void> completeProfile({
    required String username,
    required String countryCode,
    required String country,
    required String city,
    double? latitude,
    double? longitude,
  }) async {
    emit(const GoogleProfileCompletionLoading());

    try {
      final trimmedUsername = username.trim();
      final trimmedCountryCode = countryCode.trim().toUpperCase();
      final trimmedCountry = country.trim();
      final trimmedCity = city.trim();

      final validationError = _validate(
        username: trimmedUsername,
        countryCode: trimmedCountryCode,
        country: trimmedCountry,
        city: trimmedCity,
      );

      if (validationError != null) {
        emit(GoogleProfileCompletionFailure(validationError));
        return;
      }

      final completedUser = _incompleteUser.copyWith(
        id: _firebaseUser.uid,
        username: trimmedUsername,
        country: trimmedCountry,
        countryCode: trimmedCountryCode,
        countryName: trimmedCountry,
        city: trimmedCity,
        latitude: latitude,
        longitude: longitude,
        updatedAt: DateTime.now().toUtc(),
      );

      final existingProfile = await _userRepository.getUser(_firebaseUser.uid);

      if (existingProfile == null) {
        await _userRepository.createUserProfile(completedUser);
      } else {
        await _userRepository.updateUserProfile(
          existingProfile.copyWith(
            username: trimmedUsername,
            country: trimmedCountry,
            countryCode: trimmedCountryCode,
            countryName: trimmedCountry,
            city: trimmedCity,
            latitude: latitude,
            longitude: longitude,
            updatedAt: DateTime.now().toUtc(),
          ),
        );
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
    required String countryCode,
    required String country,
    required String city,
  }) {
    if (username.isEmpty) return 'Username obbligatorio';
    if (username.length < 3) return 'Username: minimo 3 caratteri';

    final validChars = RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(username);
    if (!validChars) {
      return 'Username: usa solo lettere, numeri, punto o _';
    }

    if (countryCode.isEmpty || country.isEmpty) return 'Paese obbligatorio';
    if (city.isEmpty) return 'Città obbligatoria';

    return null;
  }
}