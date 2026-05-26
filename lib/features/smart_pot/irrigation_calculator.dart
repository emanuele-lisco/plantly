import 'irrigation_recommendation.dart';

class IrrigationCalculator {
  const IrrigationCalculator();

  IrrigationRecommendation calculate({
    required String potSize,
    required String plantCategory,
    required String soilType,
    required String drainageLevel,
    required String plantSize,
    required String season,
    required String exposure,
    required double targetMoistureMin,
    required double targetMoistureMax,
    required double pumpMlPerSecond,
    double? moisturePercent,
    double maxMlPerIrrigation = 180,
  }) {
    final safeTargetMin = targetMoistureMin.clamp(0, 100).toDouble();
    final safeTargetMax = targetMoistureMax.clamp(safeTargetMin, 100).toDouble();
    final safePumpMlPerSecond = pumpMlPerSecond <= 0 ? 0 : pumpMlPerSecond;
    final safeMaxMl = maxMlPerIrrigation <= 0 ? 180.0 : maxMlPerIrrigation;

    if (moisturePercent != null && moisturePercent >= safeTargetMin) {
      return IrrigationRecommendation(
        recommendedWaterMl: 0,
        pumpRuntimeSeconds: 0,
        shouldIrrigate: false,
        reason: 'Umidità sufficiente: il valore rilevato è già sopra la soglia minima.',
        moistureBefore: moisturePercent,
        targetMoistureMin: safeTargetMin,
        targetMoistureMax: safeTargetMax,
        safetyLimitApplied: false,
      );
    }

    final baseWater = _baseWaterByPotSize(potSize);
    final rawWaterMl = baseWater *
        _plantCategoryFactor(plantCategory) *
        _soilFactor(soilType) *
        _drainageFactor(drainageLevel) *
        _plantSizeFactor(plantSize) *
        _seasonFactor(season) *
        _exposureFactor(exposure) *
        _moistureDeficitFactor(
          moisturePercent: moisturePercent,
          targetMoistureMin: safeTargetMin,
          targetMoistureMax: safeTargetMax,
        );

    final safetyLimitApplied = rawWaterMl > safeMaxMl;
    final recommendedWaterMl = rawWaterMl.clamp(0, safeMaxMl).toDouble();

    if (recommendedWaterMl <= 0) {
      return IrrigationRecommendation(
        recommendedWaterMl: 0,
        pumpRuntimeSeconds: 0,
        shouldIrrigate: false,
        reason: 'I dati disponibili non richiedono irrigazione.',
        moistureBefore: moisturePercent,
        targetMoistureMin: safeTargetMin,
        targetMoistureMax: safeTargetMax,
        safetyLimitApplied: safetyLimitApplied,
      );
    }

    if (safePumpMlPerSecond <= 0) {
      return IrrigationRecommendation(
        recommendedWaterMl: recommendedWaterMl,
        pumpRuntimeSeconds: 0,
        shouldIrrigate: false,
        reason: 'Calibrazione pompa mancante: imposta ml/sec prima di irrigare dall’app.',
        moistureBefore: moisturePercent,
        targetMoistureMin: safeTargetMin,
        targetMoistureMax: safeTargetMax,
        safetyLimitApplied: safetyLimitApplied,
      );
    }

    final pumpRuntimeSeconds = recommendedWaterMl / safePumpMlPerSecond;

    return IrrigationRecommendation(
      recommendedWaterMl: recommendedWaterMl,
      pumpRuntimeSeconds: pumpRuntimeSeconds,
      shouldIrrigate: true,
      reason: safetyLimitApplied
          ? 'Irrigazione consigliata con limite di sicurezza applicato e micro-irrigazione.'
          : 'Irrigazione consigliata in base ai dati disponibili.',
      moistureBefore: moisturePercent,
      targetMoistureMin: safeTargetMin,
      targetMoistureMax: safeTargetMax,
      safetyLimitApplied: safetyLimitApplied,
    );
  }

  double _baseWaterByPotSize(String value) {
    switch (value.trim().toLowerCase()) {
      case 'small':
      case 'piccolo':
        return 80;
      case 'large':
      case 'grande':
        return 350;
      case 'medium':
      case 'medio':
      default:
        return 180;
    }
  }

  double _plantCategoryFactor(String value) {
    switch (value.trim().toLowerCase()) {
      case 'succulent':
      case 'succulenta':
      case 'cactus':
        return 0.4;
      case 'tropical':
      case 'tropicale':
        return 1.2;
      case 'herb':
      case 'aromatica':
        return 1.0;
      default:
        return 1.0;
    }
  }

  double _soilFactor(String value) {
    switch (value.trim().toLowerCase()) {
      case 'sandy':
      case 'sabbioso':
        return 0.8;
      case 'clay':
      case 'compact':
      case 'argilloso':
      case 'compatto':
        return 0.7;
      case 'draining':
      case 'draining mix':
      case 'drenante':
        return 0.9;
      case 'standard':
      default:
        return 1.0;
    }
  }

  double _drainageFactor(String value) {
    switch (value.trim().toLowerCase()) {
      case 'poor':
      case 'scarso':
        return 0.7;
      case 'high':
      case 'alto':
        return 1.1;
      case 'normal':
      case 'normale':
      default:
        return 1.0;
    }
  }

  double _plantSizeFactor(String value) {
    switch (value.trim().toLowerCase()) {
      case 'young':
      case 'small':
      case 'giovane':
      case 'piccola':
        return 0.7;
      case 'large':
      case 'grande':
        return 1.3;
      case 'medium':
      case 'media':
      default:
        return 1.0;
    }
  }

  double _seasonFactor(String value) {
    switch (value.trim().toLowerCase()) {
      case 'winter':
      case 'inverno':
        return 0.6;
      case 'summer':
      case 'estate':
        return 1.2;
      case 'autumn':
      case 'fall':
      case 'autunno':
        return 0.8;
      case 'spring':
      case 'primavera':
      default:
        return 1.0;
    }
  }

  double _exposureFactor(String value) {
    switch (value.trim().toLowerCase()) {
      case 'low':
      case 'low light':
      case 'poca luce':
        return 0.8;
      case 'direct':
      case 'direct sun':
      case 'sole diretto':
        return 1.2;
      case 'indirect':
      case 'indirect light':
      case 'indiretta':
      default:
        return 1.0;
    }
  }

  double _moistureDeficitFactor({
    required double? moisturePercent,
    required double targetMoistureMin,
    required double targetMoistureMax,
  }) {
    if (moisturePercent == null) return 1.0;

    final deficit = (targetMoistureMin - moisturePercent).clamp(0, 100).toDouble();
    if (deficit <= 0) return 0;

    final range = (targetMoistureMax - targetMoistureMin).abs();
    final safeRange = range <= 0 ? 30.0 : range;
    return (1 + (deficit / safeRange)).clamp(1.0, 2.0).toDouble();
  }
}
