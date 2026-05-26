import 'package:equatable/equatable.dart';

class IrrigationRecommendation extends Equatable {
  final double recommendedWaterMl;
  final double pumpRuntimeSeconds;
  final bool shouldIrrigate;
  final String reason;
  final double? moistureBefore;
  final double targetMoistureMin;
  final double targetMoistureMax;
  final bool safetyLimitApplied;

  const IrrigationRecommendation({
    required this.recommendedWaterMl,
    required this.pumpRuntimeSeconds,
    required this.shouldIrrigate,
    required this.reason,
    required this.moistureBefore,
    required this.targetMoistureMin,
    required this.targetMoistureMax,
    required this.safetyLimitApplied,
  });

  const IrrigationRecommendation.noIrrigation({
    required this.reason,
    required this.moistureBefore,
    required this.targetMoistureMin,
    required this.targetMoistureMax,
    this.safetyLimitApplied = false,
  })  : recommendedWaterMl = 0,
        pumpRuntimeSeconds = 0,
        shouldIrrigate = false;

  IrrigationRecommendation copyWith({
    double? recommendedWaterMl,
    double? pumpRuntimeSeconds,
    bool? shouldIrrigate,
    String? reason,
    double? moistureBefore,
    bool clearMoistureBefore = false,
    double? targetMoistureMin,
    double? targetMoistureMax,
    bool? safetyLimitApplied,
  }) {
    return IrrigationRecommendation(
      recommendedWaterMl: recommendedWaterMl ?? this.recommendedWaterMl,
      pumpRuntimeSeconds: pumpRuntimeSeconds ?? this.pumpRuntimeSeconds,
      shouldIrrigate: shouldIrrigate ?? this.shouldIrrigate,
      reason: reason ?? this.reason,
      moistureBefore:
          clearMoistureBefore ? null : moistureBefore ?? this.moistureBefore,
      targetMoistureMin: targetMoistureMin ?? this.targetMoistureMin,
      targetMoistureMax: targetMoistureMax ?? this.targetMoistureMax,
      safetyLimitApplied: safetyLimitApplied ?? this.safetyLimitApplied,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'recommendedWaterMl': recommendedWaterMl,
      'pumpRuntimeSeconds': pumpRuntimeSeconds,
      'shouldIrrigate': shouldIrrigate,
      'reason': reason,
      'moistureBefore': moistureBefore,
      'targetMoistureMin': targetMoistureMin,
      'targetMoistureMax': targetMoistureMax,
      'safetyLimitApplied': safetyLimitApplied,
    };
  }

  @override
  List<Object?> get props => [
        recommendedWaterMl,
        pumpRuntimeSeconds,
        shouldIrrigate,
        reason,
        moistureBefore,
        targetMoistureMin,
        targetMoistureMax,
        safetyLimitApplied,
      ];
}
