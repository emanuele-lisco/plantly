import 'package:equatable/equatable.dart';

import '../../features/smart_pot/smart_pot_config.dart';

/// Stati della configurazione irrigazione automatica.
///
/// Questa fase salva solo la configurazione su Firestore: non genera comandi
/// automatici e non contiene algoritmi meteo/avanzati.
sealed class AutoIrrigationSettingsState extends Equatable {
  const AutoIrrigationSettingsState();

  @override
  List<Object?> get props => [];
}

final class AutoIrrigationSettingsInitial extends AutoIrrigationSettingsState {
  const AutoIrrigationSettingsInitial();
}

final class AutoIrrigationSettingsLoading extends AutoIrrigationSettingsState {
  const AutoIrrigationSettingsLoading();
}

final class AutoIrrigationSettingsLoaded extends AutoIrrigationSettingsState {
  const AutoIrrigationSettingsLoaded({required this.config});

  final SmartPotConfig config;

  @override
  List<Object?> get props => [config];
}

final class AutoIrrigationSettingsSaving extends AutoIrrigationSettingsState {
  const AutoIrrigationSettingsSaving({required this.config});

  final SmartPotConfig config;

  @override
  List<Object?> get props => [config];
}

final class AutoIrrigationSettingsSuccess extends AutoIrrigationSettingsState {
  const AutoIrrigationSettingsSuccess({
    required this.config,
    required this.message,
  });

  final SmartPotConfig config;
  final String message;

  @override
  List<Object?> get props => [config, message];
}

final class AutoIrrigationSettingsFailure extends AutoIrrigationSettingsState {
  const AutoIrrigationSettingsFailure({
    required this.message,
    this.config,
  });

  final String message;
  final SmartPotConfig? config;

  @override
  List<Object?> get props => [message, config];
}
