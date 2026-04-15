part of 'auth_bloc.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
}

class AuthBlocState extends Equatable {
  final AuthStatus status;
  final fb.User? user;

  const AuthBlocState({
    required this.status,
    this.user,
  });

  const AuthBlocState.unknown()
      : status = AuthStatus.unknown,
        user = null;

  const AuthBlocState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        user = null;

  const AuthBlocState.authenticated(fb.User this.user)
      : status = AuthStatus.authenticated;

  @override
  List<Object?> get props => [status, user];
}
