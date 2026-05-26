import 'package:equatable/equatable.dart';

import '../../features/plant/plant_species.dart';

sealed class PlantDetailsState extends Equatable {
  const PlantDetailsState();

  @override
  List<Object?> get props => [];
}

final class PlantDetailsInitial extends PlantDetailsState {
  const PlantDetailsInitial();
}

final class PlantDetailsLoading extends PlantDetailsState {
  const PlantDetailsLoading();
}

final class PlantDetailsSuccess extends PlantDetailsState {
  const PlantDetailsSuccess(this.plant);

  final PlantSpecies plant;

  @override
  List<Object?> get props => [plant];
}

final class PlantDetailsFailure extends PlantDetailsState {
  const PlantDetailsFailure({
    required this.message,
    this.fallbackPlant,
  });

  final String message;
  final PlantSpecies? fallbackPlant;

  @override
  List<Object?> get props => [message, fallbackPlant];
}
