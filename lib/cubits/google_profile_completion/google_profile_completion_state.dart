part of 'google_profile_completion_cubit.dart';

abstract class GoogleProfileCompletionState extends Equatable {
  const GoogleProfileCompletionState();

  @override
  List<Object?> get props => [];
}

/// Initial state — form is ready and empty.
class GoogleProfileCompletionInitial extends GoogleProfileCompletionState {
  const GoogleProfileCompletionInitial();
}

/// Submission in progress.
class GoogleProfileCompletionLoading extends GoogleProfileCompletionState {
  const GoogleProfileCompletionLoading();
}

/// Profile saved successfully — caller should navigate to home.
class GoogleProfileCompletionSuccess extends GoogleProfileCompletionState {
  const GoogleProfileCompletionSuccess();
}

/// An error occurred (username taken, network, etc.).
class GoogleProfileCompletionFailure extends GoogleProfileCompletionState {
  final String error;

  const GoogleProfileCompletionFailure(this.error);

  @override
  List<Object?> get props => [error];
}
