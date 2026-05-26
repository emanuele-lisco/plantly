import 'package:equatable/equatable.dart';

import '../../features/plant/plant_species.dart';

sealed class PlantSearchState extends Equatable {
  const PlantSearchState();

  @override
  List<Object?> get props => [];
}

final class PlantSearchInitial extends PlantSearchState {
  const PlantSearchInitial();
}

final class PlantSearchLoading extends PlantSearchState {
  const PlantSearchLoading({
    required this.query,
    required this.apiQuery,
  });

  final String query;
  final String apiQuery;

  @override
  List<Object?> get props => [query, apiQuery];
}

final class PlantSearchSuccess extends PlantSearchState {
  const PlantSearchSuccess({
    required this.query,
    required this.apiQuery,
    required this.plants,
    this.currentPage = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
  });

  final String query;
  final String apiQuery;
  final List<PlantSpecies> plants;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  PlantSearchSuccess copyWith({
    String? query,
    String? apiQuery,
    List<PlantSpecies>? plants,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PlantSearchSuccess(
      query: query ?? this.query,
      apiQuery: apiQuery ?? this.apiQuery,
      plants: plants ?? this.plants,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
        query,
        apiQuery,
        plants,
        currentPage,
        hasMore,
        isLoadingMore,
      ];
}

// Compatibilità con i widget search già presenti nel progetto.
typedef PlantSearchLoaded = PlantSearchSuccess;

final class PlantSearchEmpty extends PlantSearchState {
  const PlantSearchEmpty({
    required this.query,
    required this.apiQuery,
  });

  final String query;
  final String apiQuery;

  @override
  List<Object?> get props => [query, apiQuery];
}

final class PlantSearchFailure extends PlantSearchState {
  const PlantSearchFailure({
    required this.message,
    this.query = '',
    this.apiQuery = '',
  });

  final String message;
  final String query;
  final String apiQuery;

  @override
  List<Object?> get props => [message, query, apiQuery];
}
