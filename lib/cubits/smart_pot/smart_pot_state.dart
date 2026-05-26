import 'package:equatable/equatable.dart';

import '../../features/smart_pot/smart_pot_device.dart';

sealed class SmartPotState extends Equatable {
  const SmartPotState({this.device, this.message});

  final SmartPotDevice? device;
  final String? message;

  @override
  List<Object?> get props => [device, message];
}

class SmartPotInitial extends SmartPotState {
  const SmartPotInitial();
}

class SmartPotLoading extends SmartPotState {
  const SmartPotLoading({super.device});
}

class SmartPotConnected extends SmartPotState {
  const SmartPotConnected({required SmartPotDevice device})
      : super(device: device);
}

class SmartPotDisconnected extends SmartPotState {
  const SmartPotDisconnected({super.device, super.message});
}

class SmartPotFailure extends SmartPotState {
  const SmartPotFailure({required String message, super.device})
      : super(message: message);
}
