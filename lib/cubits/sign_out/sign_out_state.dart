part of 'sign_out_cubit.dart';

sealed class SignOutState extends Equatable {
  const SignOutState();
  @override
  List<Object?> get props => [];
}

class SignOutInitial extends SignOutState {
  const SignOutInitial();
}

class SignOutLoading extends SignOutState {
  const SignOutLoading();
}

class SignOutSuccess extends SignOutState {
  const SignOutSuccess();
}

class SignOutFailure extends SignOutState {
  final String message;
  const SignOutFailure(this.message);
  @override
  List<Object?> get props => [message];
}
