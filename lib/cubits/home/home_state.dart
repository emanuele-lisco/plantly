import 'package:equatable/equatable.dart';

import '../../features/plant/garden_plant.dart';

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

final class HomeLoading extends HomeState {
  const HomeLoading();
}

final class HomeEmpty extends HomeState {
  const HomeEmpty();
}

final class HomeSuccess extends HomeState {
  const HomeSuccess({
    required this.plants,
    required this.totalPlants,
    required this.plantsToWaterToday,
    required this.nextCarePlant,
    required this.nextCareAt,
  });

  final List<GardenPlant> plants;
  final int totalPlants;
  final List<GardenPlant> plantsToWaterToday;
  final GardenPlant? nextCarePlant;
  final DateTime? nextCareAt;

  int get plantsToWaterTodayCount => plantsToWaterToday.length;

  @override
  List<Object?> get props => [
        plants,
        totalPlants,
        plantsToWaterToday,
        nextCarePlant,
        nextCareAt,
      ];
}

final class HomeFailure extends HomeState {
  const HomeFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
