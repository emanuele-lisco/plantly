part of 'user_plants_cubit.dart';

sealed class UserPlantsState extends Equatable {
  const UserPlantsState();

  @override
  List<Object?> get props => [];
}

class UserPlantsInitial extends UserPlantsState {
  const UserPlantsInitial();
}

class UserPlantsLoading extends UserPlantsState {
  const UserPlantsLoading();
}

class UserPlantsLoaded extends UserPlantsState {
  const UserPlantsLoaded({
    required this.plants,
    this.isSaving = false,
  });

  final List<UserPlant> plants;
  final bool isSaving;

  UserPlantsLoaded copyWith({
    List<UserPlant>? plants,
    bool? isSaving,
  }) {
    return UserPlantsLoaded(
      plants: plants ?? this.plants,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  List<Object?> get props => [plants, isSaving];
}

class UserPlantsEmpty extends UserPlantsState {
  const UserPlantsEmpty({this.isSaving = false});

  final bool isSaving;

  UserPlantsEmpty copyWith({bool? isSaving}) {
    return UserPlantsEmpty(isSaving: isSaving ?? this.isSaving);
  }

  @override
  List<Object?> get props => [isSaving];
}

class UserPlantsFailure extends UserPlantsState {
  const UserPlantsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}