part of 'sign_out_cubit.dart';

sealed class SignOutState extends Equatable {
  const SignOutState();

  @override
  List<Object?> get props => [];
}

final class SignOutInitial extends SignOutState {
  const SignOutInitial();
}

final class SignOutLoading extends SignOutState {
  const SignOutLoading();
}

final class SignOutSuccess extends SignOutState {
  const SignOutSuccess();
}

final class SignOutFailure extends SignOutState {
  final String message;

  const SignOutFailure(this.message);

  @override
  List<Object?> get props => [message];
}