import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/user/user.dart';
import '../../repositories/user_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(const ProfileInitial());

  final UserRepository _userRepository;
  StreamSubscription<PlantlyUser?>? _subscription;
  String? _currentUserId;

  Future<void> watchProfile(String userId) async {
    if (userId.trim().isEmpty) {
      emit(const ProfileFailure('Utente non disponibile'));
      return;
    }

    if (_currentUserId == userId && _subscription != null) {
      return;
    }

    _currentUserId = userId;
    emit(const ProfileLoading());
    await _subscription?.cancel();
    _subscription = _userRepository.watchUser(userId).listen(
      (user) {
        if (user == null) {
          emit(const ProfileFailure('Profilo non trovato'));
        } else {
          emit(ProfileLoaded(user));
        }
      },
      onError: (_) {
        emit(const ProfileFailure('Errore nel caricamento del profilo'));
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
