import 'package:equatable/equatable.dart';

import '../../core/parse_from_json.dart';

/// Configurazione del dispositivo smart pot.
///
/// Questi valori vengono scritti dall'app su Firestore nella sub-map `config`
/// del documento `devices/{deviceId}`. Arduino legge questa map a ogni
/// avvio e periodicamente per adattare il proprio comportamento.
///
/// **Ruolo di Arduino**: esecutore semplice e sicuro. Riceve comandi espliciti
/// (es. "eroga X ml") e applica i limiti di sicurezza definiti qui.
/// Non decide autonomamente quando irrigare: è sempre l'app o il backend
/// a generare i comandi di irrigazione, anche in modalità automatica.
class SmartPotConfig extends Equatable {
  const SmartPotConfig({
    required this.tankCapacityMl,
    required this.pumpMlPerSecond,
    required this.cooldownSeconds,
    required this.autoIrrigationEnabled,
    required this.soilMoistureThreshold,
    required this.maxWaterMlPerCycle,
    required this.maxWaterMlPerDay,
  });

  /// Capacità totale del serbatoio in millilitri.
  /// Usata per calcolare [SmartPotTelemetry.waterRemainingPercent].
  final double tankCapacityMl;

  /// Portata calibrata della pompa in ml/s.
  /// Usata dall'app/backend per calcolare la durata di un ciclo di irrigazione.
  /// Arduino usa questo valore come parametro di sicurezza per non superare
  /// la quantità richiesta.
  final double pumpMlPerSecond;

  /// Tempo minimo in secondi tra due irrigazioni consecutive.
  /// Arduino rifiuta comandi che arrivano prima del cooldown trascorso.
  final int cooldownSeconds;

  /// Se true, l'app o il backend possono generare automaticamente comandi
  /// di irrigazione basati su [soilMoistureThreshold] e sui limiti giornalieri.
  /// Arduino resta esecutore: riceve ed esegue il comando, non lo genera.
  final bool autoIrrigationEnabled;

  /// Soglia di umidità (%) sotto cui l'app/backend genera un comando
  /// di irrigazione automatica, se [autoIrrigationEnabled] è true.
  final double soilMoistureThreshold;

  /// Quantità massima di acqua erogabile in un singolo ciclo (ml).
  /// Arduino tronca l'erogazione se supera questo limite.
  final double maxWaterMlPerCycle;

  /// Quantità massima di acqua erogabile nell'arco di 24 ore (ml).
  /// Limite di sicurezza verificato dall'app/backend prima di inviare comandi.
  final double maxWaterMlPerDay;

  // ── Factory ──────────────────────────────────────────────────────────────

  factory SmartPotConfig.fromJson(Map<String, dynamic> json) {
    return SmartPotConfig(
      tankCapacityMl: readDouble(json['tankCapacityMl'], fallback: 4000),
      pumpMlPerSecond: readDouble(json['pumpMlPerSecond'], fallback: 20),
      cooldownSeconds: readInt(json['cooldownSeconds'], fallback: 1800),
      autoIrrigationEnabled: readBool(json['autoIrrigationEnabled']),
      soilMoistureThreshold:
          readDouble(json['soilMoistureThreshold'], fallback: 30),
      maxWaterMlPerCycle: readDouble(json['maxWaterMlPerCycle'], fallback: 100),
      maxWaterMlPerDay: readDouble(json['maxWaterMlPerDay'], fallback: 300),
    );
  }

  /// Valori di default sicuri per un dispositivo appena registrato.
  ///
  /// - [tankCapacityMl] 4000 ml: serbatoio standard da 4 litri.
  /// - [pumpMlPerSecond] 20 ml/s: valore prudente, calibrabile dall'utente.
  /// - [cooldownSeconds] 1800 s (30 min): evita irrigazioni troppo ravvicinate.
  /// - [autoIrrigationEnabled] false: l'utente deve abilitare esplicitamente.
  /// - [soilMoistureThreshold] 30%: soglia conservativa.
  /// - [maxWaterMlPerCycle] 100 ml: ciclo singolo limitato e sicuro.
  /// - [maxWaterMlPerDay] 300 ml: limite giornaliero conservativo.
  factory SmartPotConfig.defaults() => const SmartPotConfig(
        tankCapacityMl: 4000,
        pumpMlPerSecond: 20,
        cooldownSeconds: 1800,
        autoIrrigationEnabled: false,
        soilMoistureThreshold: 30,
        maxWaterMlPerCycle: 100,
        maxWaterMlPerDay: 300,
      );

  Map<String, dynamic> toJson() {
    return {
      'tankCapacityMl': tankCapacityMl,
      'pumpMlPerSecond': pumpMlPerSecond,
      'cooldownSeconds': cooldownSeconds,
      'autoIrrigationEnabled': autoIrrigationEnabled,
      'soilMoistureThreshold': soilMoistureThreshold,
      'maxWaterMlPerCycle': maxWaterMlPerCycle,
      'maxWaterMlPerDay': maxWaterMlPerDay,
    };
  }

  SmartPotConfig copyWith({
    double? tankCapacityMl,
    double? pumpMlPerSecond,
    int? cooldownSeconds,
    bool? autoIrrigationEnabled,
    double? soilMoistureThreshold,
    double? maxWaterMlPerCycle,
    double? maxWaterMlPerDay,
  }) {
    return SmartPotConfig(
      tankCapacityMl: tankCapacityMl ?? this.tankCapacityMl,
      pumpMlPerSecond: pumpMlPerSecond ?? this.pumpMlPerSecond,
      cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
      autoIrrigationEnabled:
          autoIrrigationEnabled ?? this.autoIrrigationEnabled,
      soilMoistureThreshold:
          soilMoistureThreshold ?? this.soilMoistureThreshold,
      maxWaterMlPerCycle: maxWaterMlPerCycle ?? this.maxWaterMlPerCycle,
      maxWaterMlPerDay: maxWaterMlPerDay ?? this.maxWaterMlPerDay,
    );
  }

  @override
  List<Object?> get props => [
        tankCapacityMl,
        pumpMlPerSecond,
        cooldownSeconds,
        autoIrrigationEnabled,
        soilMoistureThreshold,
        maxWaterMlPerCycle,
        maxWaterMlPerDay,
      ];
}
