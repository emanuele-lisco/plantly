part of 'session_cubit.dart';

sealed class SessionState extends Equatable {
  const SessionState();

  @override
  List<Object?> get props => [];
}

final class SessionInitial extends SessionState {
  const SessionInitial();
}

final class SessionLoading extends SessionState {
  const SessionLoading();
}

final class SessionUnauthenticated extends SessionState {
  const SessionUnauthenticated();
}

final class SessionAuthenticatedComplete extends SessionState {
  const SessionAuthenticatedComplete();
}

final class SessionAuthenticatedNeedsProfileCompletion extends SessionState {
  const SessionAuthenticatedNeedsProfileCompletion({
    required this.firebaseUser,
    required this.incompleteUser,
  });

  final fb.User firebaseUser;
  final PlantlyUser incompleteUser;

  @override
  List<Object?> get props => [firebaseUser, incompleteUser];
}