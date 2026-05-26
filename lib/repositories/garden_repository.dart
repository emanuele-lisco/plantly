import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/plant/garden_plant.dart';

class GardenRepository {
  GardenRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _gardenCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('garden');
  }

  Stream<List<GardenPlant>> watchGarden(String userId) {
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      throw const GardenRepositoryException('Utente non disponibile.');
    }

    return _gardenCollection(trimmedUserId)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((QuerySnapshot<Map<String, dynamic>> snapshot) {
      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> document) {
        return GardenPlant.fromFirestore(document);
      }).toList(growable: false);
    });
  }

  Future<List<GardenPlant>> getGarden(String userId) async {
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      throw const GardenRepositoryException('Utente non disponibile.');
    }

    try {
      final snapshot = await _gardenCollection(trimmedUserId)
          .orderBy('addedAt', descending: true)
          .get();

      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> document) {
        return GardenPlant.fromFirestore(document);
      }).toList(growable: false);
    } on FirebaseException catch (_) {
      throw const GardenRepositoryException(
        'Errore durante il caricamento del giardino.',
      );
    }
  }

  Future<void> addPlantToGarden(String userId, GardenPlant plant) async {
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      throw const GardenRepositoryException('Utente non disponibile.');
    }

    try {
      final alreadyExists = await plantAlreadyInGarden(
        trimmedUserId,
        plant.speciesId,
      );
      if (alreadyExists) {
        throw const GardenRepositoryException(
          'Questa pianta è già nel tuo giardino.',
        );
      }

      final collection = _gardenCollection(trimmedUserId);
      final document = plant.id.trim().isEmpty
          ? collection.doc()
          : collection.doc(plant.id.trim());
      final now = DateTime.now().toUtc();
      final plantToSave = plant.copyWith(
        id: document.id,
        userId: trimmedUserId,
        addedAt: plant.addedAt ?? now,
        updatedAt: now,
      );

      await document.set(_toFirestorePayload(plantToSave));
    } on GardenRepositoryException {
      rethrow;
    } on FirebaseException catch (_) {
      throw const GardenRepositoryException(
        'Errore durante il salvataggio della pianta.',
      );
    } catch (_) {
      throw const GardenRepositoryException(
        'Errore imprevisto durante il salvataggio della pianta.',
      );
    }
  }

  Future<void> updateGardenPlant(String userId, GardenPlant plant) async {
    final trimmedUserId = userId.trim();
    final trimmedPlantId = plant.id.trim();

    if (trimmedUserId.isEmpty) {
      throw const GardenRepositoryException('Utente non disponibile.');
    }
    if (trimmedPlantId.isEmpty) {
      throw const GardenRepositoryException('Pianta non valida.');
    }

    try {
      final payload = _toFirestorePayload(
        plant.copyWith(
          userId: trimmedUserId,
          updatedAt: DateTime.now().toUtc(),
        ),
      )..remove('addedAt');

      await _gardenCollection(trimmedUserId).doc(trimmedPlantId).update(payload);
    } on FirebaseException catch (_) {
      throw const GardenRepositoryException(
        'Errore durante l’aggiornamento della pianta.',
      );
    }
  }

  Future<void> removeGardenPlant(String userId, String plantId) async {
    final trimmedUserId = userId.trim();
    final trimmedPlantId = plantId.trim();

    if (trimmedUserId.isEmpty) {
      throw const GardenRepositoryException('Utente non disponibile.');
    }
    if (trimmedPlantId.isEmpty) {
      throw const GardenRepositoryException('Pianta non valida.');
    }

    try {
      await _gardenCollection(trimmedUserId).doc(trimmedPlantId).delete();
    } on FirebaseException catch (_) {
      throw const GardenRepositoryException(
        'Errore durante la rimozione della pianta.',
      );
    }
  }

  Future<void> markAsWatered(
      String userId,
      String plantId,
      DateTime wateredAt,
      ) async {
    final trimmedUserId = userId.trim();
    final trimmedPlantId = plantId.trim();

    if (trimmedUserId.isEmpty) {
      throw const GardenRepositoryException('Utente non disponibile.');
    }
    if (trimmedPlantId.isEmpty) {
      throw const GardenRepositoryException('Pianta non valida.');
    }

    try {
      await _gardenCollection(trimmedUserId).doc(trimmedPlantId).update({
        'lastWateredAt': wateredAt.toUtc(),
        'nextWateringAt': wateredAt.toUtc().add(const Duration(days: 7)),
        'updatedAt': DateTime.now().toUtc(),
      });
    } on FirebaseException catch (_) {
      throw const GardenRepositoryException(
        'Errore durante l’aggiornamento dell’annaffiatura.',
      );
    }
  }

  Future<bool> plantAlreadyInGarden(String userId, String speciesId) async {
    final trimmedUserId = userId.trim();
    final trimmedSpeciesId = speciesId.trim();

    if (trimmedUserId.isEmpty || trimmedSpeciesId.isEmpty) return false;

    try {
      final snapshot = await _gardenCollection(trimmedUserId)
          .where('speciesId', isEqualTo: trimmedSpeciesId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } on FirebaseException catch (_) {
      throw const GardenRepositoryException(
        'Errore durante il controllo del giardino.',
      );
    }
  }

  Map<String, dynamic> _toFirestorePayload(GardenPlant plant) {
    return plant.toJson();
  }
}

class GardenRepositoryException implements Exception {
  const GardenRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}
