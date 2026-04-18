part of 'sign_up_cubit.dart';

abstract class SignUpState extends Equatable {
  const SignUpState();

  @override
  List<Object?> get props => [];
}

class SignUpInitial extends SignUpState {}

class SignUpLoading extends SignUpState {}

class SignUpSuccess extends SignUpState {
  final String success;

  const SignUpSuccess(this.success);

  @override
  List<Object?> get props => [success];
}

/// Emitted after a successful Google Sign-Up when the Firestore profile
/// exists but is missing required fields (username, country, or city).
///
/// Mirrors [SignInNeedsProfileCompletion] so that [App] can handle both
/// cases with the same navigation logic.
class SignUpNeedsProfileCompletion extends SignUpState {
  final fb.User firebaseUser;
  final PlantlyUser incompleteUser;

  const SignUpNeedsProfileCompletion({
    required this.firebaseUser,
    required this.incompleteUser,
  });

  @override
  List<Object?> get props => [firebaseUser, incompleteUser];
}

class SignUpFailure extends SignUpState {
  final String error;

  const SignUpFailure(this.error);

  @override
  List<Object?> get props => [error];
}
