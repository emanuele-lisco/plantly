import 'package:equatable/equatable.dart';

import '../../features/plant/garden_plant.dart';

sealed class GardenState extends Equatable {
  const GardenState({this.isActionInProgress = false});

  final bool isActionInProgress;

  @override
  List<Object?> get props => [isActionInProgress];
}

final class GardenInitial extends GardenState {
  const GardenInitial({super.isActionInProgress});

  GardenInitial copyWith({bool? isActionInProgress}) {
    return GardenInitial(
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
    );
  }
}

final class GardenLoading extends GardenState {
  const GardenLoading({super.isActionInProgress});

  GardenLoading copyWith({bool? isActionInProgress}) {
    return GardenLoading(
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
    );
  }
}

final class GardenSuccess extends GardenState {
  const GardenSuccess({
    required this.plants,
    super.isActionInProgress,
  });

  final List<GardenPlant> plants;

  GardenSuccess copyWith({
    List<GardenPlant>? plants,
    bool? isActionInProgress,
  }) {
    return GardenSuccess(
      plants: plants ?? this.plants,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
    );
  }

  @override
  List<Object?> get props => [plants, isActionInProgress];
}

final class GardenEmpty extends GardenState {
  const GardenEmpty({super.isActionInProgress});

  GardenEmpty copyWith({bool? isActionInProgress}) {
    return GardenEmpty(
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
    );
  }
}

final class GardenFailure extends GardenState {
  const GardenFailure(
    this.message, {
    super.isActionInProgress,
  });

  final String message;

  GardenFailure copyWith({
    String? message,
    bool? isActionInProgress,
  }) {
    return GardenFailure(
      message ?? this.message,
      isActionInProgress: isActionInProgress ?? this.isActionInProgress,
    );
  }

  @override
  List<Object?> get props => [message, isActionInProgress];
}

class GardenMutationResult extends Equatable {
  const GardenMutationResult._({
    required this.isSuccess,
    required this.message,
  });

  const GardenMutationResult.success(String message)
      : this._(isSuccess: true, message: message);

  const GardenMutationResult.failure(String message)
      : this._(isSuccess: false, message: message);

  final bool isSuccess;
  final String message;

  @override
  List<Object?> get props => [isSuccess, message];
}
