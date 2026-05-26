import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/smart_pot/smart_pot_config.dart';
import '../../repositories/smart_pot_repository.dart';
import '../../services/irrigation/irrigation_recommendation_service.dart';
import 'auto_irrigation_settings_state.dart';

export 'auto_irrigation_settings_state.dart';

/// Cubit per leggere e salvare la configurazione di irrigazione automatica.
///
/// Non decide quando irrigare e non crea comandi: salva solo i parametri che
/// l'app/backend useranno in futuro per generare comandi automatici.
class AutoIrrigationSettingsCubit extends Cubit<AutoIrrigationSettingsState> {
  AutoIrrigationSettingsCubit({
    required SmartPotRepository smartPotRepository,
    IrrigationRecommendationService recommendationService =
    const IrrigationRecommendationService(),
  })  : _smartPotRepository = smartPotRepository,
        _recommendationService = recommendationService,
        super(const AutoIrrigationSettingsInitial());

  final SmartPotRepository _smartPotRepository;
  final IrrigationRecommendationService _recommendationService;

  Future<void> load(String? deviceId) async {
    final did = deviceId?.trim() ?? '';
    if (did.isEmpty) {
      emit(const AutoIrrigationSettingsFailure(
        message: 'Nessun vaso intelligente collegato.',
      ));
      return;
    }

    emit(const AutoIrrigationSettingsLoading());

    try {
      final device = await _smartPotRepository.getDevice(did);
      if (device == null) {
        emit(const AutoIrrigationSettingsFailure(
          message: 'Dispositivo non trovato su Firestore.',
        ));
        return;
      }

      emit(AutoIrrigationSettingsLoaded(config: device.config));
    } on SmartPotRepositoryException catch (e) {
      emit(AutoIrrigationSettingsFailure(message: e.message));
    } catch (_) {
      emit(const AutoIrrigationSettingsFailure(
        message: 'Errore imprevisto durante il caricamento della configurazione.',
      ));
    }
  }


  /// Applica valori consigliati prudenti alla configurazione locale.
  ///
  /// Non salva su Firestore e non crea comandi automatici. L'utente deve
  /// confermare con "Salva configurazione".
  void applyRecommendedSettings({
    required SmartPotConfig currentConfig,
    required String? watering,
  }) {
    final recommendedConfig = _recommendationService.applyRecommendedValues(
      currentConfig: currentConfig,
      watering: watering,
    );

    emit(AutoIrrigationSettingsLoaded(config: recommendedConfig));
  }

  Future<void> saveSettings({
    required String? deviceId,
    required SmartPotConfig currentConfig,
    required bool autoIrrigationEnabled,
    required double soilMoistureThreshold,
    required double maxWaterMlPerCycle,
    required double maxWaterMlPerDay,
  }) async {
    final did = deviceId?.trim() ?? '';
    if (did.isEmpty) {
      emit(AutoIrrigationSettingsFailure(
        message: 'Nessun vaso intelligente collegato.',
        config: currentConfig,
      ));
      return;
    }

    final validationMessage = _validate(
      soilMoistureThreshold: soilMoistureThreshold,
      maxWaterMlPerCycle: maxWaterMlPerCycle,
      maxWaterMlPerDay: maxWaterMlPerDay,
    );

    if (validationMessage != null) {
      emit(AutoIrrigationSettingsFailure(
        message: validationMessage,
        config: currentConfig,
      ));
      return;
    }

    final updatedConfig = currentConfig.copyWith(
      autoIrrigationEnabled: autoIrrigationEnabled,
      soilMoistureThreshold: soilMoistureThreshold,
      maxWaterMlPerCycle: maxWaterMlPerCycle,
      maxWaterMlPerDay: maxWaterMlPerDay,
    );

    emit(AutoIrrigationSettingsSaving(config: updatedConfig));

    try {
      await _smartPotRepository.updateConfig(
        deviceId: did,
        config: updatedConfig,
      );

      emit(AutoIrrigationSettingsSuccess(
        config: updatedConfig,
        message: 'Configurazione irrigazione automatica salvata.',
      ));
    } on SmartPotRepositoryException catch (e) {
      emit(AutoIrrigationSettingsFailure(
        message: e.message,
        config: updatedConfig,
      ));
    } catch (_) {
      emit(AutoIrrigationSettingsFailure(
        message: 'Errore imprevisto durante il salvataggio della configurazione.',
        config: updatedConfig,
      ));
    }
  }

  String? _validate({
    required double soilMoistureThreshold,
    required double maxWaterMlPerCycle,
    required double maxWaterMlPerDay,
  }) {
    if (soilMoistureThreshold < 5 || soilMoistureThreshold > 90) {
      return 'La soglia umidità deve essere compresa tra 5% e 90%.';
    }

    if (maxWaterMlPerCycle <= 0 || maxWaterMlPerCycle > 1000) {
      return 'I ml per ciclo devono essere compresi tra 1 e 1000 ml.';
    }

    if (maxWaterMlPerDay <= 0 || maxWaterMlPerDay > 5000) {
      return 'Il massimo giornaliero deve essere compreso tra 1 e 5000 ml.';
    }

    if (maxWaterMlPerCycle > maxWaterMlPerDay) {
      return 'I ml per ciclo non possono superare il massimo giornaliero.';
    }

    return null;
  }
}
