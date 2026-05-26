import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/plant/garden_plant.dart';
import '../../features/plant/plant_species.dart';
import '../../repositories/garden_repository.dart';
import '../../repositories/notification_repository.dart';
import 'garden_state.dart';

class GardenCubit extends Cubit<GardenState> {
  GardenCubit({
    required GardenRepository gardenRepository,
    NotificationRepository? notificationRepository,
  })  : _gardenRepository = gardenRepository,
        _notificationRepository = notificationRepository ?? const NotificationRepository(),
        super(const GardenInitial());

  final GardenRepository _gardenRepository;
  final NotificationRepository _notificationRepository;
  StreamSubscription<List<GardenPlant>>? _subscription;
  String? _currentUserId;

  Future<void> watchGarden(String userId) async {
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      emit(const GardenFailure('Utente non disponibile. Accedi di nuovo e riprova.'));
      return;
    }

    if (_currentUserId == trimmedUserId && _subscription != null) return;

    emit(const GardenLoading());
    await _subscription?.cancel();
    _currentUserId = trimmedUserId;

    try {
      _subscription = _gardenRepository.watchGarden(trimmedUserId).listen(
        (plants) {
          if (plants.isEmpty) {
            emit(const GardenEmpty());
          } else {
            emit(GardenSuccess(plants: plants));
          }
        },
        onError: (Object error) {
          emit(GardenFailure(_readableGardenError(error)));
        },
      );
    } on GardenRepositoryException catch (e) {
      emit(GardenFailure(e.message));
    } catch (e) {
      emit(GardenFailure(_readableGardenError(e)));
    }
  }

  Future<GardenMutationResult> addPlantFromSpecies({
    required String userId,
    required PlantSpecies species,
    String nickname = '',
    String location = '',
  }) async {
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      return const GardenMutationResult.failure(
        'Utente non disponibile. Accedi di nuovo e riprova.',
      );
    }

    final normalizedLocation = location.trim();

    final now = DateTime.now().toUtc();
    final plant = GardenPlant(
      id: _buildGardenPlantId(species.id, now),
      userId: trimmedUserId,
      speciesId: species.id,
      commonName: species.commonName,
      scientificName: species.scientificName,
      nickname: nickname.trim(),
      imageUrl: species.imageUrl,
      watering: species.watering,
      sunlight: species.sunlight,
      indoor: species.indoor,
      poisonousToHumans: species.poisonousToHumans,
      poisonousToPets: species.poisonousToPets,
      addedAt: now,
      updatedAt: now,
      lastWateredAt: null,
      nextWateringAt: _initialNextWateringAt(now, species.watering),
      notes: '',
      location: normalizedLocation,
      notificationEnabled: true,
      smartPotId: null,
    );

    return _performMutation(
      action: () async {
        await _gardenRepository.addPlantToGarden(trimmedUserId, plant);
        await _notificationRepository.scheduleWateringReminder(plant);
      },
      successMessage: 'Pianta aggiunta al giardino.',
    );
  }

  Future<GardenMutationResult> removePlant({
    required String userId,
    required String plantId,
  }) {
    return _performMutation(
      action: () async {
        await _gardenRepository.removeGardenPlant(userId, plantId);
        await _notificationRepository.cancelWateringReminder(plantId);
      },
      successMessage: 'Pianta rimossa dal giardino.',
    );
  }

  Future<GardenMutationResult> markAsWatered({
    required String userId,
    required GardenPlant plant,
    DateTime? wateredAt,
  }) {
    final date = wateredAt ?? DateTime.now().toUtc();
    final updatedPlant = plant.copyWith(
      lastWateredAt: date,
      nextWateringAt: _initialNextWateringAt(date, plant.watering),
    );

    return _performMutation(
      action: () async {
        await _gardenRepository.markAsWatered(userId, plant.id, date);
        await _notificationRepository.rescheduleWateringReminder(updatedPlant);
      },
      successMessage: 'Annaffiatura registrata.',
    );
  }

  Future<GardenMutationResult> updatePlant({
    required String userId,
    required GardenPlant plant,
  }) {
    return _performMutation(
      action: () async {
        await _gardenRepository.updateGardenPlant(userId, plant);
        await _notificationRepository.rescheduleWateringReminder(plant);
      },
      successMessage: 'Pianta aggiornata.',
    );
  }

  Future<bool> plantAlreadyInGarden({
    required String userId,
    required String speciesId,
  }) async {
    try {
      return _gardenRepository.plantAlreadyInGarden(userId, speciesId);
    } catch (_) {
      return false;
    }
  }

  Future<GardenMutationResult> _performMutation({
    required Future<void> Function() action,
    required String successMessage,
  }) async {
    _emitActionProgress(true);

    try {
      await action();
      _emitActionProgress(false);
      return GardenMutationResult.success(successMessage);
    } on GardenRepositoryException catch (e) {
      _emitActionProgress(false);
      return GardenMutationResult.failure(e.message);
    } catch (e) {
      _emitActionProgress(false);
      return GardenMutationResult.failure(_readableGardenError(e));
    }
  }

  void _emitActionProgress(bool isActionInProgress) {
    final currentState = state;

    switch (currentState) {
      case GardenInitial():
        emit(currentState.copyWith(isActionInProgress: isActionInProgress));
      case GardenLoading():
        emit(currentState.copyWith(isActionInProgress: isActionInProgress));
      case GardenEmpty():
        emit(currentState.copyWith(isActionInProgress: isActionInProgress));
      case GardenSuccess():
        emit(currentState.copyWith(isActionInProgress: isActionInProgress));
      case GardenFailure():
        emit(currentState.copyWith(isActionInProgress: isActionInProgress));
    }
  }

  String _readableGardenError(Object error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Permessi Firestore insufficienti per leggere o scrivere il giardino. Aggiorna le regole per users/{uid}/garden/{plantId}.';
        case 'unavailable':
          return 'Firestore non è momentaneamente disponibile. Controlla la connessione e riprova.';
        default:
          return 'Errore Firestore (${error.code}) durante il caricamento del giardino.';
      }
    }

    if (error is GardenRepositoryException) return error.message;

    return 'Errore imprevisto durante l’operazione sul giardino.';
  }


  String _buildGardenPlantId(String speciesId, DateTime createdAt) {
    final normalizedSpeciesId = speciesId.trim().isEmpty ? 'plant' : speciesId.trim();
    return '${normalizedSpeciesId}_${createdAt.microsecondsSinceEpoch}';
  }

  DateTime _initialNextWateringAt(DateTime from, String watering) {
    final normalized = watering.trim().toLowerCase();
    final days = switch (normalized) {
      'frequent' => 2,
      'average' => 7,
      'minimum' => 14,
      'none' => 30,
      _ => 7,
    };
    return from.add(Duration(days: days));
  }

  Future<void> clear() async {
    await _subscription?.cancel();
    _subscription = null;
    _currentUserId = null;
    emit(const GardenInitial());
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
