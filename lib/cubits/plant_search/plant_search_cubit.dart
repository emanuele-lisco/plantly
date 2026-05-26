import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:translator/translator.dart';

import '../../repositories/plant_repository.dart';
import 'plant_search_state.dart';

class PlantSearchCubit extends Cubit<PlantSearchState> {
  PlantSearchCubit({required PlantRepository plantRepository})
      : _plantRepository = plantRepository,
        _translator = GoogleTranslator(),
        super(const PlantSearchInitial());

  final PlantRepository _plantRepository;
  final GoogleTranslator _translator;
  int _requestId = 0;

  Future<void> searchPlants(String query) async {
    final displayQuery = query.trim();

    if (displayQuery.isEmpty) {
      emit(const PlantSearchInitial());
      return;
    }

    final currentRequestId = ++_requestId;
    emit(PlantSearchLoading(query: displayQuery, apiQuery: displayQuery));

    try {
      final apiQuery = await _translateQueryForApi(displayQuery);
      if (currentRequestId != _requestId) return;

      final plants = await _plantRepository.searchPlants(apiQuery);
      if (currentRequestId != _requestId) return;

      if (plants.isEmpty) {
        emit(PlantSearchEmpty(query: displayQuery, apiQuery: apiQuery));
      } else {
        emit(
          PlantSearchSuccess(
            query: displayQuery,
            apiQuery: apiQuery,
            plants: plants,
          ),
        );
      }
    } on PlantRepositoryException catch (e) {
      if (currentRequestId != _requestId) return;
      emit(
        PlantSearchFailure(
          message: e.message,
          query: displayQuery,
          apiQuery: displayQuery,
        ),
      );
    } catch (_) {
      if (currentRequestId != _requestId) return;
      emit(
        PlantSearchFailure(
          message: 'Errore imprevisto durante la ricerca delle piante.',
          query: displayQuery,
          apiQuery: displayQuery,
        ),
      );
    }
  }

  Future<void> loadMore() async {
    // La vertical slice usa una ricerca semplice senza paginazione.
    // Il metodo resta per compatibilità con vecchi widget non ancora rimossi.
  }

  void clearSearch() {
    _requestId++;
    emit(const PlantSearchInitial());
  }

  Future<String> _translateQueryForApi(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return normalized;

    try {
      final translation = await _translator.translate(
        normalized,
        from: 'it',
        to: 'en',
      );
      final translated = translation.text.trim();
      return translated.isEmpty ? normalized : translated;
    } catch (_) {
      return normalized;
    }
  }
}
