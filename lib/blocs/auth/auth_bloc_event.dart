part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// Emesso dallo stream interno di AuthBloc ogni volta che Firebase
// notifica un cambio di stato utente (login, logout, token refresh).
class AuthUserChanged extends AuthEvent {
  final fb.User? user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}
