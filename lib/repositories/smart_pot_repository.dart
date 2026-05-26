import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/smart_pot/smart_pot_config.dart';
import '../features/smart_pot/smart_pot_device.dart';
import '../features/smart_pot/smart_pot_telemetry.dart';

/// Repository per le operazioni sul dispositivo smart pot in Firestore.
///
/// ## Struttura Firestore
///
/// ```
/// devices/{deviceId}            ← collezione globale
///   ownerUid          : String
///   linkedUserPlantId : String?
///   telemetry         : Map
///   config            : Map
///
/// users/{ownerUid}/garden/{plantId}
///   deviceId          : String?
/// ```
///
/// I dispositivi vivono in una collezione globale `devices` (non sotto
/// `users/{uid}/devices`) per consentire a Cloud Functions di accedervi
/// senza attraversare la gerarchia utente, e per semplificare le Firestore
/// Security Rules sul lato firmware.
class SmartPotRepository {
  SmartPotRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  // ── Riferimenti ──────────────────────────────────────────────────────────

  DocumentReference<Map<String, dynamic>> _deviceRef(String deviceId) =>
      _firestore.collection('devices').doc(deviceId);

  DocumentReference<Map<String, dynamic>> _plantRef(
          String ownerUid, String plantId) =>
      _firestore.collection('users').doc(ownerUid).collection('garden').doc(plantId);

  // ── Lettura real-time ────────────────────────────────────────────────────

  /// Stream del documento device. Emette null se il documento non esiste.
  Stream<SmartPotDevice?> watchDevice(
    String deviceId, {
    Duration onlineThreshold = SmartPotTelemetry.defaultOnlineThreshold,
  }) {
    final did = _requireValue(deviceId, 'Dispositivo non valido');

    return _deviceRef(did).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return SmartPotDevice.fromFirestore(
        doc.id,
        doc.data()!,
        onlineThreshold: onlineThreshold,
      );
    });
  }

  // ── Collegamento / scollegamento ─────────────────────────────────────────

  /// Collega un device a una [UserPlant] in modo transazionale:
  /// - scrive `linkedUserPlantId` + `ownerUid` sul documento device
  /// - scrive `deviceId` sul documento UserPlant
  Future<void> linkDeviceToUserPlant({
    required String ownerUid,
    required String deviceId,
    required String userPlantId,
  }) async {
    final uid = _requireValue(ownerUid, 'Utente non disponibile');
    final did = _requireValue(deviceId, 'Dispositivo non valido');
    final pid = _requireValue(userPlantId, 'Pianta non valida');

    try {
      await _firestore.runTransaction((tx) async {
        tx.set(
          _deviceRef(did),
          {
            'ownerUid': uid,
            'linkedUserPlantId': pid,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        tx.set(
          _plantRef(uid, pid),
          {
            'deviceId': did,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      });
    } on FirebaseException catch (e) {
      throw SmartPotRepositoryException(_firebaseMessage(e));
    } catch (_) {
      throw const SmartPotRepositoryException(
        'Errore imprevisto durante il collegamento del vaso intelligente.',
      );
    }
  }

  /// Scollega il device dalla [UserPlant] in modo transazionale:
  /// - azzera `linkedUserPlantId` sul documento device
  /// - rimuove `deviceId` dal documento UserPlant
  Future<void> unlinkDeviceFromUserPlant({
    required String ownerUid,
    required String deviceId,
    required String userPlantId,
  }) async {
    final uid = _requireValue(ownerUid, 'Utente non disponibile');
    final did = _requireValue(deviceId, 'Dispositivo non valido');
    final pid = _requireValue(userPlantId, 'Pianta non valida');

    try {
      await _firestore.runTransaction((tx) async {
        tx.set(
          _deviceRef(did),
          {
            'linkedUserPlantId': null,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
        tx.set(
          _plantRef(uid, pid),
          {
            'deviceId': null,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      });
    } on FirebaseException catch (e) {
      throw SmartPotRepositoryException(_firebaseMessage(e));
    } catch (_) {
      throw const SmartPotRepositoryException(
        'Errore imprevisto durante lo scollegamento del vaso intelligente.',
      );
    }
  }

  // ── Configurazione ───────────────────────────────────────────────────────

  /// Aggiorna la sub-map `config` del documento device.
  /// Usa merge per non sovrascrivere campi non inclusi (es. telemetry).
  Future<void> updateConfig({
    required String deviceId,
    required SmartPotConfig config,
  }) async {
    final did = _requireValue(deviceId, 'Dispositivo non valido');

    try {
      await _deviceRef(did).set(
        {
          'config': config.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } on FirebaseException catch (e) {
      throw SmartPotRepositoryException(_firebaseMessage(e));
    } catch (_) {
      throw const SmartPotRepositoryException(
        'Errore imprevisto durante il salvataggio della configurazione.',
      );
    }
  }


  /// Lettura one-shot del documento device.
  /// Utile per validare lo stato subito prima di creare un comando manuale.
  Future<SmartPotDevice?> getDevice(
    String deviceId, {
    Duration onlineThreshold = SmartPotTelemetry.defaultOnlineThreshold,
  }) async {
    final did = _requireValue(deviceId, 'Dispositivo non valido');

    try {
      final doc = await _deviceRef(did).get();
      if (!doc.exists || doc.data() == null) return null;
      return SmartPotDevice.fromFirestore(
        doc.id,
        doc.data()!,
        onlineThreshold: onlineThreshold,
      );
    } on FirebaseException catch (e) {
      throw SmartPotRepositoryException(_firebaseMessage(e));
    } catch (_) {
      throw const SmartPotRepositoryException(
        'Errore imprevisto durante la lettura del vaso intelligente.',
      );
    }
  }

  /// Crea un comando manuale pending per avviare l'irrigazione.
  ///
  /// L'app non comunica direttamente con Arduino: scrive il comando in
  /// `devices/{deviceId}/commands/{commandId}`. Il backend/firmware lo leggerà
  /// e lo consumerà in modo asincrono.
  ///
  /// Validazioni eseguite prima della scrittura:
  /// - il device deve esistere;
  /// - il device deve essere online;
  /// - la pompa non deve essere già attiva;
  /// - l'acqua residua stimata deve essere sufficiente;
  /// - la portata pompa deve essere valida per calcolare `durationMs`.
  Future<void> createManualIrrigationCommand({
    required String deviceId,
    required String requestedBy,
  }) async {
    final did = _requireValue(deviceId, 'Dispositivo non valido');
    final uid = _requireValue(requestedBy, 'Utente non disponibile');

    try {
      final device = await getDevice(did);

      if (device == null) {
        throw const SmartPotRepositoryException(
          'Dispositivo non trovato su Firestore.',
        );
      }

      final ownerUid = device.ownerUid.trim();
      if (ownerUid.isNotEmpty && ownerUid != uid) {
        throw const SmartPotRepositoryException(
          'Questo vaso intelligente non è associato al tuo account.',
        );
      }

      if (!device.isOnline) {
        throw const SmartPotRepositoryException(
          'Il vaso intelligente è offline. Riprova quando torna online.',
        );
      }

      if (device.telemetry.pumpActive) {
        throw const SmartPotRepositoryException(
          'La pompa è già attiva. Attendi la fine dell\'irrigazione.',
        );
      }

      final configuredMl = device.config.maxWaterMlPerCycle;
      if (configuredMl <= 0) {
        throw const SmartPotRepositoryException(
          'Quantità di irrigazione non configurata correttamente.',
        );
      }

      if (device.telemetry.waterRemainingMl < configuredMl) {
        throw const SmartPotRepositoryException(
          'Acqua insufficiente nel serbatoio stimato. Riempilo prima di annaffiare.',
        );
      }

      final pumpMlPerSecond = device.config.pumpMlPerSecond;
      if (pumpMlPerSecond <= 0) {
        throw const SmartPotRepositoryException(
          'Portata della pompa non configurata correttamente.',
        );
      }

      final durationMs = ((configuredMl / pumpMlPerSecond) * 1000).ceil();

      await _deviceRef(did).collection('commands').add({
        'type': 'irrigate',
        'status': 'pending',
        'requestedBy': uid,
        'payload': {
          'ml': configuredMl,
          'durationMs': durationMs,
        },
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on SmartPotRepositoryException {
      rethrow;
    } on FirebaseException catch (e) {
      throw SmartPotRepositoryException(_firebaseMessage(e));
    } catch (_) {
      throw const SmartPotRepositoryException(
        'Errore imprevisto durante la creazione del comando di irrigazione.',
      );
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _requireValue(String value, String message) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) throw SmartPotRepositoryException(message);
    return trimmed;
  }

  String _firebaseMessage(FirebaseException error) {
    if (error.code == 'permission-denied') {
      return 'Permessi Firestore insufficienti per i dispositivi smart pot.';
    }
    return 'Errore Firestore smart pot: ${error.code}';
  }
}

class SmartPotRepositoryException implements Exception {
  const SmartPotRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
