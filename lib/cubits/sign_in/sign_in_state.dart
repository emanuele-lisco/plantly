part of 'sign_in_cubit.dart';

abstract class SignInState extends Equatable {
  const SignInState();

  @override
  List<Object?> get props => [];
}

class SignInInitial extends SignInState {}

class SignInLoading extends SignInState {}

class SignInSuccess extends SignInState {}

/// Emitted after a successful Google Sign-In when the Firestore profile
/// exists but is missing required fields (username, country, or city).
///
/// The page layer listens for this state and navigates to
/// [GoogleProfileCompletionPage], passing [firebaseUser] and
/// [incompleteUser] so the completion cubit can be instantiated with the
/// correct context.
class SignInNeedsProfileCompletion extends SignInState {
  final fb.User firebaseUser;
  final PlantlyUser incompleteUser;

  const SignInNeedsProfileCompletion({
    required this.firebaseUser,
    required this.incompleteUser,
  });

  @override
  List<Object?> get props => [firebaseUser, incompleteUser];
}

class SignInFailure extends SignInState {
  final String error;

  const SignInFailure(this.error);

  @override
  List<Object?> get props => [error];
}
