import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/plant/garden_plant.dart';
import '../../repositories/garden_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required GardenRepository gardenRepository})
      : _gardenRepository = gardenRepository,
        super(const HomeInitial());

  final GardenRepository _gardenRepository;
  StreamSubscription<List<GardenPlant>>? _subscription;
  String? _currentUserId;

  Future<void> watchHome(String userId) async {
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      emit(const HomeFailure('Utente non disponibile. Accedi di nuovo e riprova.'));
      return;
    }

    if (_currentUserId == trimmedUserId && _subscription != null) return;

    emit(const HomeLoading());
    await _subscription?.cancel();
    _currentUserId = trimmedUserId;

    try {
      _subscription = _gardenRepository.watchGarden(trimmedUserId).listen(
        _emitDashboardFromPlants,
        onError: (Object error) {
          emit(HomeFailure(_readableHomeError(error)));
        },
      );
    } on GardenRepositoryException catch (e) {
      emit(HomeFailure(e.message));
    } catch (e) {
      emit(HomeFailure(_readableHomeError(e)));
    }
  }

  void _emitDashboardFromPlants(List<GardenPlant> plants) {
    if (plants.isEmpty) {
      emit(const HomeEmpty());
      return;
    }

    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    final plantsToWaterToday = plants
        .where((plant) {
          final nextWateringAt = plant.nextWateringAt;
          if (nextWateringAt == null) return false;
          return !nextWateringAt.toLocal().isAfter(endOfToday);
        })
        .toList(growable: false);

    final plantsWithCareDate = plants
        .where((plant) => plant.nextWateringAt != null)
        .toList(growable: false)
      ..sort((a, b) => a.nextWateringAt!.compareTo(b.nextWateringAt!));

    final nextCarePlant = plantsWithCareDate.isEmpty ? null : plantsWithCareDate.first;

    emit(
      HomeSuccess(
        plants: List.unmodifiable(plants),
        totalPlants: plants.length,
        plantsToWaterToday: List.unmodifiable(plantsToWaterToday),
        nextCarePlant: nextCarePlant,
        nextCareAt: nextCarePlant?.nextWateringAt,
      ),
    );
  }

  String _readableHomeError(Object error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Permessi Firestore insufficienti per leggere il giardino. Controlla le regole su users/{uid}/garden/{plantId}.';
        case 'unavailable':
          return 'Firestore non è momentaneamente disponibile. Controlla la connessione e riprova.';
        default:
          return 'Errore Firestore (${error.code}) durante il caricamento della dashboard.';
      }
    }

    if (error is GardenRepositoryException) return error.message;

    return 'Errore imprevisto durante il caricamento della dashboard.';
  }

  Future<void> clear() async {
    await _subscription?.cancel();
    _subscription = null;
    _currentUserId = null;
    emit(const HomeInitial());
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
