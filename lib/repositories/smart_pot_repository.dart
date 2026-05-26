import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/smart_pot/smart_pot_device.dart';

class SmartPotRepository {
  SmartPotRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _devicesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('devices');
  }

  CollectionReference<Map<String, dynamic>> _gardenCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('garden');
  }

  Stream<SmartPotDevice?> watchDevice(String userId, String deviceId) {
    final safeUserId = _requireValue(userId, 'Utente non disponibile');
    final safeDeviceId = _requireValue(deviceId, 'Dispositivo non valido');

    return _devicesCollection(safeUserId).doc(safeDeviceId).snapshots().map(
      (doc) {
        if (!doc.exists || doc.data() == null) return null;
        return SmartPotDevice.fromFirestore(doc.id, doc.data()!);
      },
    );
  }

  Future<void> linkDeviceToPlant({
    required String userId,
    required String deviceId,
    required String gardenPlantId,
    String? name,
    String? deviceCode,
  }) async {
    final safeUserId = _requireValue(userId, 'Utente non disponibile');
    final safeDeviceId = _requireValue(deviceId, 'Dispositivo non valido');
    final safeGardenPlantId = _requireValue(
      gardenPlantId,
      'Pianta del giardino non valida',
    );

    try {
      final deviceRef = _devicesCollection(safeUserId).doc(safeDeviceId);
      final plantRef = _gardenCollection(safeUserId).doc(safeGardenPlantId);

      await _firestore.runTransaction((transaction) async {
        transaction.set(
          deviceRef,
          {
            'id': safeDeviceId,
            'userId': safeUserId,
            'gardenPlantId': safeGardenPlantId,
            if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
            if (deviceCode != null && deviceCode.trim().isNotEmpty)
              'deviceCode': deviceCode.trim(),
            'isLinked': true,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        transaction.set(
          plantRef,
          {
            'smartPotId': safeDeviceId,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      });
    } on FirebaseException catch (error) {
      throw SmartPotRepositoryException(_firebaseMessage(error));
    } catch (_) {
      throw const SmartPotRepositoryException(
        'Errore imprevisto durante il collegamento del vaso intelligente.',
      );
    }
  }

  Future<void> unlinkDevice({
    required String userId,
    required String deviceId,
    required String gardenPlantId,
  }) async {
    final safeUserId = _requireValue(userId, 'Utente non disponibile');
    final safeDeviceId = _requireValue(deviceId, 'Dispositivo non valido');
    final safeGardenPlantId = _requireValue(
      gardenPlantId,
      'Pianta del giardino non valida',
    );

    try {
      final deviceRef = _devicesCollection(safeUserId).doc(safeDeviceId);
      final plantRef = _gardenCollection(safeUserId).doc(safeGardenPlantId);

      await _firestore.runTransaction((transaction) async {
        transaction.set(
          deviceRef,
          {
            'gardenPlantId': '',
            'isLinked': false,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        transaction.set(
          plantRef,
          {
            'smartPotId': null,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      });
    } on FirebaseException catch (error) {
      throw SmartPotRepositoryException(_firebaseMessage(error));
    } catch (_) {
      throw const SmartPotRepositoryException(
        'Errore imprevisto durante lo scollegamento del vaso intelligente.',
      );
    }
  }

  Future<void> updatePumpCalibration({
    required String userId,
    required String deviceId,
    required double pumpMlPerSecond,
  }) async {
    final safeUserId = _requireValue(userId, 'Utente non disponibile');
    final safeDeviceId = _requireValue(deviceId, 'Dispositivo non valido');

    if (pumpMlPerSecond <= 0) {
      throw const SmartPotRepositoryException(
        'La calibrazione della pompa deve essere maggiore di zero.',
      );
    }

    try {
      await _devicesCollection(safeUserId).doc(safeDeviceId).set(
        {
          'pumpMlPerSecond': pumpMlPerSecond,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } on FirebaseException catch (error) {
      throw SmartPotRepositoryException(_firebaseMessage(error));
    } catch (_) {
      throw const SmartPotRepositoryException(
        'Errore imprevisto durante la calibrazione della pompa.',
      );
    }
  }

  Future<void> requestManualIrrigation({
    required String userId,
    required String deviceId,
    required double waterMl,
    required double pumpRuntimeSeconds,
  }) async {
    final safeUserId = _requireValue(userId, 'Utente non disponibile');
    final safeDeviceId = _requireValue(deviceId, 'Dispositivo non valido');

    if (waterMl <= 0 || pumpRuntimeSeconds <= 0) {
      throw const SmartPotRepositoryException(
        'Richiesta irrigazione non valida: quantità o durata mancanti.',
      );
    }

    try {
      await _devicesCollection(safeUserId).doc(safeDeviceId).set(
        {
          // Placeholder: in futuro Arduino leggerà/consumerà questo comando
          // oppure una Cloud Function lo inoltrerà al device.
          'pendingCommand': {
            'type': 'manual_irrigation',
            'waterMl': waterMl,
            'pumpRuntimeSeconds': pumpRuntimeSeconds,
            'status': 'pending',
            'createdAt': FieldValue.serverTimestamp(),
          },
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } on FirebaseException catch (error) {
      throw SmartPotRepositoryException(_firebaseMessage(error));
    } catch (_) {
      throw const SmartPotRepositoryException(
        'Errore imprevisto durante la richiesta di irrigazione manuale.',
      );
    }
  }

  Future<void> updateSensorSnapshot({
    required String userId,
    required String deviceId,
    required int moistureRaw,
    required double moisturePercent,
    required double lightLux,
    double? waterReservoirMl,
    String? firmwareVersion,
  }) async {
    final safeUserId = _requireValue(userId, 'Utente non disponibile');
    final safeDeviceId = _requireValue(deviceId, 'Dispositivo non valido');

    try {
      await _devicesCollection(safeUserId).doc(safeDeviceId).set(
        {
          'moistureRaw': moistureRaw,
          'moisturePercent': moisturePercent.clamp(0, 100),
          'lightLux': lightLux < 0 ? 0 : lightLux,
          if (waterReservoirMl != null) 'waterReservoirMl': waterReservoirMl,
          if (firmwareVersion != null && firmwareVersion.trim().isNotEmpty)
            'firmwareVersion': firmwareVersion.trim(),
          'isOnline': true,
          'lastSeenAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } on FirebaseException catch (error) {
      throw SmartPotRepositoryException(_firebaseMessage(error));
    } catch (_) {
      throw const SmartPotRepositoryException(
        'Errore imprevisto durante l’aggiornamento dei sensori.',
      );
    }
  }

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
