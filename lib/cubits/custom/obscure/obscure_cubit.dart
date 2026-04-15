import 'package:flutter_bloc/flutter_bloc.dart';

class ObscureState {
  final bool password;
  final bool confirmPassword;

  const ObscureState({
    this.password = true,
    this.confirmPassword = true,
  });

  ObscureState copyWith({
    bool? password,
    bool? confirmPassword,
  }) {
    return ObscureState(
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
    );
  }
}

class ObscureCubit extends Cubit<ObscureState> {
  ObscureCubit() : super(const ObscureState());

  void togglePassword() {
    emit(state.copyWith(password: !state.password));
  }

  void toggleConfirmPassword() {
    emit(state.copyWith(confirmPassword: !state.confirmPassword));
  }
}
