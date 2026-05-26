import 'package:equatable/equatable.dart';

import '../../features/smart_pot/smart_pot_device.dart';

sealed class SmartPotState extends Equatable {
  const SmartPotState();

  @override
  List<Object?> get props => [];
}

final class SmartPotInitial extends SmartPotState {
  const SmartPotInitial();
}

final class SmartPotLoading extends SmartPotState {
  const SmartPotLoading();
}

final class SmartPotNoDevice extends SmartPotState {
  const SmartPotNoDevice();
}

final class SmartPotLoaded extends SmartPotState {
  const SmartPotLoaded({required this.device});

  final SmartPotDevice device;

  @override
  List<Object?> get props => [device];
}

final class SmartPotOffline extends SmartPotState {
  const SmartPotOffline({required this.device});

  final SmartPotDevice device;

  @override
  List<Object?> get props => [device];
}

final class SmartPotFailure extends SmartPotState {
  const SmartPotFailure({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}
