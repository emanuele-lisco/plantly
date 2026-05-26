import 'package:equatable/equatable.dart';

import '../../core/parse_from_json.dart';
import 'smart_pot_config.dart';
import 'smart_pot_telemetry.dart';

/// Entità che rappresenta un dispositivo hardware smart pot.
///
/// ## Struttura Firestore
///
/// I dispositivi sono archiviati in una **collezione globale** `devices`,
/// non come sub-collection dell'utente. Questo permette a Cloud Functions
/// e alle Firestore Security Rules di accedere ai device senza attraversare
/// la gerarchia utente, e semplifica la gestione futura di dispositivi condivisi.
///
/// ```
/// devices/{deviceId}
///   ownerUid          : String    ← UID Firebase Auth del proprietario
///   linkedUserPlantId : String?   ← ID della GardenPlant collegata (nullable)
///   telemetry         : Map       ← sub-map aggiornata da Arduino / backend
///   config            : Map       ← sub-map scritta dall'app
/// ```
///
/// La pianta collega il device tramite il campo `deviceId` in:
/// ```
/// users/{ownerUid}/garden/{plantId}
///   deviceId : String?
/// ```
///
/// Il collegamento è **bidirezionale e transazionale**: link/unlink aggiorna
/// entrambi i documenti atomicamente.
class SmartPotDevice extends Equatable {
  const SmartPotDevice({
    required this.id,
    required this.ownerUid,
    this.linkedUserPlantId,
    required this.telemetry,
    required this.config,
  });

  /// ID documento Firestore del dispositivo (es. MAC address o UUID hardware).
  final String id;

  /// UID Firebase Auth del proprietario.
  final String ownerUid;

  /// ID della [GardenPlant] collegata. Null se il device non è ancora associato.
  final String? linkedUserPlantId;

  /// Dati di telemetria live provenienti da Arduino / backend.
  final SmartPotTelemetry telemetry;

  /// Configurazione inviata dall'app al dispositivo.
  final SmartPotConfig config;

  // ── Getters derivati ──────────────────────────────────────────────────────

  /// True se il device è associato a una pianta.
  bool get isLinked =>
      linkedUserPlantId != null && linkedUserPlantId!.trim().isNotEmpty;

  /// True se il device ha inviato dati di recente (delegato a telemetry).
  bool get isOnline => telemetry.isOnline;

  // ── Factory ──────────────────────────────────────────────────────────────

  factory SmartPotDevice.fromJson(
    Map<String, dynamic> json, {
    Duration onlineThreshold = SmartPotTelemetry.defaultOnlineThreshold,
  }) {
    // Usa Map<String, dynamic>.from() per gestire in modo sicuro sia
    // Map<String, dynamic> nativi che Map<Object, Object> restituiti da
    // Firestore in alcuni contesti (es. sub-map non tipizzate).
    final rawTelemetry = json['telemetry'];
    final rawConfig = json['config'];

    return SmartPotDevice(
      id: readString(json['id']),
      ownerUid: readString(json['ownerUid']),
      linkedUserPlantId: readNullableString(json['linkedUserPlantId']),
      telemetry: rawTelemetry is Map
          ? SmartPotTelemetry.fromJson(
              Map<String, dynamic>.from(rawTelemetry),
              onlineThreshold: onlineThreshold,
            )
          : SmartPotTelemetry.fromJson(
              const {},
              onlineThreshold: onlineThreshold,
            ),
      config: rawConfig is Map
          ? SmartPotConfig.fromJson(Map<String, dynamic>.from(rawConfig))
          : SmartPotConfig.defaults(),
    );
  }

  factory SmartPotDevice.fromFirestore(
    String id,
    Map<String, dynamic> data, {
    Duration onlineThreshold = SmartPotTelemetry.defaultOnlineThreshold,
  }) {
    return SmartPotDevice.fromJson(
      {...data, 'id': id},
      onlineThreshold: onlineThreshold,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerUid': ownerUid,
      'linkedUserPlantId': linkedUserPlantId,
      'telemetry': telemetry.toJson(),
      'config': config.toJson(),
    };
  }

  /// Payload parziale di root da usare in operazioni merge su Firestore.
  Map<String, dynamic> toFirestoreRootPayload() => {
        'ownerUid': ownerUid,
        'linkedUserPlantId': linkedUserPlantId,
      };

  /// Payload della sola sub-map [config] da scrivere su Firestore.
  Map<String, dynamic> toFirestoreConfigPayload() => config.toJson();

  SmartPotDevice copyWith({
    String? id,
    String? ownerUid,
    String? linkedUserPlantId,
    bool clearLinkedUserPlantId = false,
    SmartPotTelemetry? telemetry,
    SmartPotConfig? config,
  }) {
    return SmartPotDevice(
      id: id ?? this.id,
      ownerUid: ownerUid ?? this.ownerUid,
      linkedUserPlantId: clearLinkedUserPlantId
          ? null
          : linkedUserPlantId ?? this.linkedUserPlantId,
      telemetry: telemetry ?? this.telemetry,
      config: config ?? this.config,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerUid,
        linkedUserPlantId,
        telemetry,
        config,
      ];
}
