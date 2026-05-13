import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/repositories/user_plants_repository.dart';

import '../../features/plant/plant_species.dart';
import '../../features/plant/user_plant.dart';

part 'user_plants_state.dart';

class UserPlantsCubit extends Cubit<UserPlantsState> {
  UserPlantsCubit({required UserPlantsRepository userPlantsRepository})
      : _userPlantsRepository = userPlantsRepository,
        super(const UserPlantsInitial());

  final UserPlantsRepository _userPlantsRepository;
  StreamSubscription<List<UserPlant>>? _subscription;
  String? _currentUserId;

  Future<void> watchUserPlants(String userId) async {
    final trimmedUserId = userId.trim();

    if (trimmedUserId.isEmpty) {
      emit(const UserPlantsFailure('Utente non disponibile'));
      return;
    }

    if (_currentUserId == trimmedUserId && _subscription != null) {
      return;
    }

    emit(const UserPlantsLoading());

    try {
      await _subscription?.cancel();
      _currentUserId = trimmedUserId;

      _subscription = _userPlantsRepository.watchUserPlants(trimmedUserId).listen(
            (plants) {
          if (plants.isEmpty) {
            emit(const UserPlantsEmpty());
          } else {
            emit(UserPlantsLoaded(plants: plants));
          }
        },
        onError: (_) {
          emit(const UserPlantsFailure('Errore nel caricamento del giardino'));
        },
      );
    } on UserPlantsRepositoryException catch (e) {
      emit(UserPlantsFailure(e.message));
    } catch (_) {
      emit(const UserPlantsFailure('Errore nel caricamento del giardino'));
    }
  }

  Future<void> addPlant({
    required String userId,
    required UserPlant plant,
  }) async {
    await _performSavingAction(
      action: () => _userPlantsRepository.addUserPlant(
        userId: userId,
        plant: plant,
      ),
    );
  }

  Future<void> addPlantFromSpecies({
    required String userId,
    required PlantSpecies species,
    String room = 'Non assegnata',
  }) async {
    final userPlant = UserPlant(
      id: '',
      speciesId: species.id,
      name: species.commonName,
      species: species.scientificName,
      room: room,
      moisture: 0,
      light: 0,
      health: 100,
      nextAction: 'Configura la cura',
      imageUrl: species.imageUrl,
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );

    await addPlant(userId: userId, plant: userPlant);
  }

  Future<void> updatePlant({
    required String userId,
    required UserPlant plant,
  }) async {
    await _performSavingAction(
      action: () => _userPlantsRepository.updateUserPlant(
        userId: userId,
        plant: plant,
      ),
    );
  }

  Future<void> deletePlant({
    required String userId,
    required String plantId,
  }) async {
    await _performSavingAction(
      action: () => _userPlantsRepository.deleteUserPlant(
        userId: userId,
        plantId: plantId,
      ),
    );
  }

  Future<void> clear() async {
    await _subscription?.cancel();
    _subscription = null;
    _currentUserId = null;
    emit(const UserPlantsInitial());
  }

  Future<void> _performSavingAction({
    required Future<void> Function() action,
  }) async {
    final previousState = state;

    if (previousState is UserPlantsLoaded) {
      emit(previousState.copyWith(isSaving: true));
    } else if (previousState is UserPlantsEmpty) {
      emit(previousState.copyWith(isSaving: true));
    }

    try {
      await action();
    } on UserPlantsRepositoryException catch (e) {
      emit(UserPlantsFailure(e.message));
    } catch (_) {
      emit(const UserPlantsFailure('Errore imprevisto durante il salvataggio'));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}