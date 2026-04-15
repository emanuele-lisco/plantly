import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AuthFlowDestination { signIn, signUp }

class AuthFlowState extends Equatable {
  final AuthFlowDestination? destination;

  const AuthFlowState({this.destination});

  @override
  List<Object?> get props => [destination];
}

class AuthFlowCubit extends Cubit<AuthFlowState> {
  AuthFlowCubit() : super(const AuthFlowState());

  void goToSignIn() =>
      emit(const AuthFlowState(destination: AuthFlowDestination.signIn));

  void goToSignUp() =>
      emit(const AuthFlowState(destination: AuthFlowDestination.signUp));

  void clear() => emit(const AuthFlowState());
}
