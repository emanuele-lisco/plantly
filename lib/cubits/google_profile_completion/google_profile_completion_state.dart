part of 'google_profile_completion_cubit.dart';

sealed class GoogleProfileCompletionState extends Equatable {
  const GoogleProfileCompletionState();

  @override
  List<Object?> get props => [];
}

final class GoogleProfileCompletionInitial
    extends GoogleProfileCompletionState {
  const GoogleProfileCompletionInitial();
}

final class GoogleProfileCompletionLoading
    extends GoogleProfileCompletionState {
  const GoogleProfileCompletionLoading();
}

final class GoogleProfileCompletionSuccess
    extends GoogleProfileCompletionState {
  const GoogleProfileCompletionSuccess();
}

final class GoogleProfileCompletionFailure
    extends GoogleProfileCompletionState {
  final String message;

  const GoogleProfileCompletionFailure(this.message);

  @override
  List<Object?> get props => [message];
}