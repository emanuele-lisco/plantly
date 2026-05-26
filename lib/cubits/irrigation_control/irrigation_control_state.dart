import 'package:equatable/equatable.dart';

sealed class IrrigationControlState extends Equatable {
  const IrrigationControlState();

  @override
  List<Object?> get props => [];
}

final class IrrigationControlInitial extends IrrigationControlState {
  const IrrigationControlInitial();
}

final class IrrigationControlLoading extends IrrigationControlState {
  const IrrigationControlLoading();
}

final class IrrigationControlSuccess extends IrrigationControlState {
  const IrrigationControlSuccess({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

final class IrrigationControlFailure extends IrrigationControlState {
  const IrrigationControlFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
