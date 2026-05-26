import '../../features/smart_pot/smart_pot_config.dart';

/// Valori consigliati iniziali per la configurazione di irrigazione automatica.
///
/// Questa classe NON implementa ancora meteo, formula avanzata o decisioni
/// automatiche. Fornisce solo default prudenti basati sul fabbisogno idrico
/// della specie, quando disponibile.
class IrrigationRecommendationService {
  const IrrigationRecommendationService();

  SmartPotConfig applyRecommendedValues({
    required SmartPotConfig currentConfig,
    required String? watering,
  }) {
    final recommendation = _recommendationFor(watering);

    return currentConfig.copyWith(
      autoIrrigationEnabled: true,
      soilMoistureThreshold: recommendation.soilMoistureThreshold,
      maxWaterMlPerCycle: recommendation.maxWaterMlPerCycle,
      maxWaterMlPerDay: recommendation.maxWaterMlPerDay,
    );
  }

  _IrrigationRecommendation _recommendationFor(String? watering) {
    final normalized = (watering ?? '').trim().toLowerCase();

    if (normalized.contains('frequent') ||
        normalized.contains('frequente') ||
        normalized.contains('high')) {
      return const _IrrigationRecommendation(
        soilMoistureThreshold: 40,
        maxWaterMlPerCycle: 120,
        maxWaterMlPerDay: 350,
      );
    }

    if (normalized.contains('average') ||
        normalized.contains('medium') ||
        normalized.contains('media')) {
      return const _IrrigationRecommendation(
        soilMoistureThreshold: 30,
        maxWaterMlPerCycle: 100,
        maxWaterMlPerDay: 300,
      );
    }

    if (normalized.contains('minimum') ||
        normalized.contains('low') ||
        normalized.contains('minima') ||
        normalized.contains('bassa')) {
      return const _IrrigationRecommendation(
        soilMoistureThreshold: 20,
        maxWaterMlPerCycle: 60,
        maxWaterMlPerDay: 150,
      );
    }

    return const _IrrigationRecommendation(
      soilMoistureThreshold: 30,
      maxWaterMlPerCycle: 80,
      maxWaterMlPerDay: 250,
    );
  }
}

class _IrrigationRecommendation {
  const _IrrigationRecommendation({
    required this.soilMoistureThreshold,
    required this.maxWaterMlPerCycle,
    required this.maxWaterMlPerDay,
  });

  final double soilMoistureThreshold;
  final double maxWaterMlPerCycle;
  final double maxWaterMlPerDay;
}
