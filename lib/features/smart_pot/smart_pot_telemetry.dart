import 'package:equatable/equatable.dart';

import '../../core/parse_from_json.dart';

/// Dati di telemetria del dispositivo smart pot.
///
/// Arduino (o il backend) aggiorna la sub-map `telemetry` dentro il documento
/// `devices/{deviceId}` su Firestore a ogni ciclo di lettura sensori.
///
/// Il campo [isOnline] NON viene mai scritto su Firestore: è calcolato lato app
/// confrontando [lastSeenAt] con la soglia [defaultOnlineThreshold].
class SmartPotTelemetry extends Equatable {
  const SmartPotTelemetry({
    required this.soilMoisturePercent,
    required this.lightLux,
    required this.waterRemainingMl,
    required this.waterRemainingPercent,
    required this.pumpActive,
    required this.irrigationMode,
    required this.batteryPercent,
    required this.lastSeenAt,
    required this.isOnline,
  });

  /// Umidità del suolo in percentuale [0–100].
  final double soilMoisturePercent;

  /// Intensità luminosa in lux.
  final double lightLux;

  /// Acqua residua nel serbatoio in millilitri.
  final double waterRemainingMl;

  /// Acqua residua in percentuale rispetto a [SmartPotConfig.tankCapacityMl].
  final double waterRemainingPercent;

  /// Indica se la pompa risulta attiva nell'ultimo snapshot ricevuto.
  final bool pumpActive;

  /// Modalità irrigazione riportata dal dispositivo: "manual" | "auto" | "off".
  final String irrigationMode;

  /// Livello batteria in percentuale [0–100].
  /// -1 indica che il sensore non è presente o il dato non è ancora disponibile
  /// (es. dispositivo alimentato via cavo senza sensore batteria).
  final double batteryPercent;

  /// Ultimo timestamp in cui il dispositivo ha aggiornato la sub-map telemetry.
  final DateTime? lastSeenAt;

  /// Calcolato lato app: true se [lastSeenAt] è entro [defaultOnlineThreshold].
  /// Non viene persistito su Firestore — è derivato a ogni lettura.
  final bool isOnline;

  // ── Soglia online ─────────────────────────────────────────────────────────

  /// Soglia di default per considerare un dispositivo online: 90 secondi.
  /// Copre un ciclo di heartbeat Arduino (tipicamente 30–60 s) con margine
  /// per latenza di rete, senza marcare erroneamente offline dispositivi lenti.
  static const Duration defaultOnlineThreshold = Duration(seconds: 90);

  // ── Factory ───────────────────────────────────────────────────────────────

  factory SmartPotTelemetry.fromJson(
    Map<String, dynamic> json, {
    Duration onlineThreshold = defaultOnlineThreshold,
  }) {
    final lastSeen = readDateTime(json['lastSeenAt']);

    return SmartPotTelemetry(
      soilMoisturePercent: readDouble(json['soilMoisturePercent']),
      lightLux: readDouble(json['lightLux']),
      waterRemainingMl: readDouble(json['waterRemainingMl']),
      waterRemainingPercent: readDouble(json['waterRemainingPercent']),
      pumpActive: readBool(json['pumpActive']),
      irrigationMode: readString(json['irrigationMode'], fallback: 'off'),
      batteryPercent: readDouble(json['batteryPercent'], fallback: -1),
      lastSeenAt: lastSeen,
      isOnline: _computeIsOnline(lastSeen, onlineThreshold),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soilMoisturePercent': soilMoisturePercent,
      'lightLux': lightLux,
      'waterRemainingMl': waterRemainingMl,
      'waterRemainingPercent': waterRemainingPercent,
      'pumpActive': pumpActive,
      'irrigationMode': irrigationMode,
      'batteryPercent': batteryPercent,
      'lastSeenAt': lastSeenAt?.toIso8601String(),
      // isOnline NON viene persistito: è calcolato in lettura.
    };
  }

  SmartPotTelemetry copyWith({
    double? soilMoisturePercent,
    double? lightLux,
    double? waterRemainingMl,
    double? waterRemainingPercent,
    bool? pumpActive,
    String? irrigationMode,
    double? batteryPercent,
    DateTime? lastSeenAt,
    bool clearLastSeenAt = false,
    bool? isOnline,
  }) {
    return SmartPotTelemetry(
      soilMoisturePercent: soilMoisturePercent ?? this.soilMoisturePercent,
      lightLux: lightLux ?? this.lightLux,
      waterRemainingMl: waterRemainingMl ?? this.waterRemainingMl,
      waterRemainingPercent:
          waterRemainingPercent ?? this.waterRemainingPercent,
      pumpActive: pumpActive ?? this.pumpActive,
      irrigationMode: irrigationMode ?? this.irrigationMode,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      lastSeenAt: clearLastSeenAt ? null : lastSeenAt ?? this.lastSeenAt,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  static bool _computeIsOnline(DateTime? lastSeen, Duration threshold) {
    if (lastSeen == null) return false;
    return DateTime.now().toUtc().difference(lastSeen.toUtc()) <= threshold;
  }

  @override
  List<Object?> get props => [
        soilMoisturePercent,
        lightLux,
        waterRemainingMl,
        waterRemainingPercent,
        pumpActive,
        irrigationMode,
        batteryPercent,
        lastSeenAt,
        isOnline,
      ];
}
