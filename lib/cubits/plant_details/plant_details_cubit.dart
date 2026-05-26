import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/plant/plant_species.dart';
import '../../repositories/plant_repository.dart';
import 'plant_details_state.dart';

class PlantDetailsCubit extends Cubit<PlantDetailsState> {
  PlantDetailsCubit({required PlantRepository plantRepository})
      : _plantRepository = plantRepository,
        super(const PlantDetailsInitial());

  final PlantRepository _plantRepository;

  Future<void> loadPlantDetails(PlantSpecies initialPlant) async {
    emit(PlantDetailsSuccess(initialPlant));

    final plantId = initialPlant.id.trim();
    if (plantId.isEmpty) return;

    try {
      final details = await _plantRepository.getPlantDetails(plantId);
      if (details != null) {
        emit(PlantDetailsSuccess(_mergePlant(initialPlant, details)));
      }
    } on PlantRepositoryException catch (e) {
      emit(PlantDetailsFailure(message: e.message, fallbackPlant: initialPlant));
    } catch (_) {
      emit(
        PlantDetailsFailure(
          message: 'Errore imprevisto durante il caricamento del dettaglio.',
          fallbackPlant: initialPlant,
        ),
      );
    }
  }

  PlantSpecies _mergePlant(PlantSpecies initial, PlantSpecies details) {
    return details.copyWith(
      commonName: details.commonName.trim().isNotEmpty ? details.commonName : initial.commonName,
      scientificName: details.scientificName.trim().isNotEmpty ? details.scientificName : initial.scientificName,
      imageThumbnailUrl: details.imageThumbnailUrl.isNotEmpty ? details.imageThumbnailUrl : initial.imageThumbnailUrl,
      imageSmallUrl: details.imageSmallUrl.isNotEmpty ? details.imageSmallUrl : initial.imageSmallUrl,
      imageMediumUrl: details.imageMediumUrl.isNotEmpty ? details.imageMediumUrl : initial.imageMediumUrl,
      imageOriginalUrl: details.imageOriginalUrl.isNotEmpty ? details.imageOriginalUrl : initial.imageOriginalUrl,
    );
  }
}
