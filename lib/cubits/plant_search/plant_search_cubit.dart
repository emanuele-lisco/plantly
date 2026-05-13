import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plantly_app/repositories/plant_species_repository.dart';

import '../../features/plant/plant_species.dart';

part 'plant_search_state.dart';

class PlantSearchCubit extends Cubit<PlantSearchState> {
  PlantSearchCubit({required PlantSpeciesRepository plantSpeciesRepository})
      : _plantSpeciesRepository = plantSpeciesRepository,
        super(const PlantSearchInitial());

  final PlantSpeciesRepository _plantSpeciesRepository;

  Future<void> searchPlants(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.isEmpty) {
      emit(const PlantSearchInitial());
      return;
    }

    emit(PlantSearchLoading(query: trimmedQuery));

    try {
      final result = await _plantSpeciesRepository.searchPlants(
        query: trimmedQuery,
      );

      if (result.plants.isEmpty) {
        emit(PlantSearchEmpty(query: trimmedQuery));
        return;
      }

      emit(
        PlantSearchLoaded(
          query: trimmedQuery,
          plants: result.plants,
          currentPage: result.currentPage,
          hasMore: result.hasMore,
        ),
      );
    } on PlantSpeciesRepositoryException catch (e) {
      emit(PlantSearchFailure(message: e.message, query: trimmedQuery));
    } catch (_) {
      emit(
        PlantSearchFailure(
          message: 'Errore imprevisto durante la ricerca delle piante',
          query: trimmedQuery,
        ),
      );
    }
  }

  Future<void> loadMore() async {
    final currentState = state;

    if (currentState is! PlantSearchLoaded) return;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final result = await _plantSpeciesRepository.searchPlants(
        query: currentState.query,
        page: currentState.currentPage + 1,
      );

      emit(
        currentState.copyWith(
          plants: [
            ...currentState.plants,
            ...result.plants,
          ],
          currentPage: result.currentPage,
          hasMore: result.hasMore,
          isLoadingMore: false,
        ),
      );
    } on PlantSpeciesRepositoryException catch (e) {
      emit(PlantSearchFailure(message: e.message, query: currentState.query));
    } catch (_) {
      emit(
        PlantSearchFailure(
          message: 'Errore imprevisto durante il caricamento di altre piante',
          query: currentState.query,
        ),
      );
    }
  }

  void clearSearch() {
    emit(const PlantSearchInitial());
  }
}