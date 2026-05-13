part of 'plant_search_cubit.dart';

sealed class PlantSearchState extends Equatable {
  const PlantSearchState();

  @override
  List<Object?> get props => [];
}

class PlantSearchInitial extends PlantSearchState {
  const PlantSearchInitial();
}

class PlantSearchLoading extends PlantSearchState {
  const PlantSearchLoading({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

class PlantSearchLoaded extends PlantSearchState {
  const PlantSearchLoaded({
    required this.query,
    required this.plants,
    required this.currentPage,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  final String query;
  final List<PlantSpecies> plants;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  PlantSearchLoaded copyWith({
    String? query,
    List<PlantSpecies>? plants,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PlantSearchLoaded(
      query: query ?? this.query,
      plants: plants ?? this.plants,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    query,
    plants,
    currentPage,
    hasMore,
    isLoadingMore,
  ];
}

class PlantSearchEmpty extends PlantSearchState {
  const PlantSearchEmpty({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

class PlantSearchFailure extends PlantSearchState {
  const PlantSearchFailure({
    required this.message,
    this.query = '',
  });

  final String message;
  final String query;

  @override
  List<Object?> get props => [message, query];
}