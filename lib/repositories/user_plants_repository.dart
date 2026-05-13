import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/plant/user_plant.dart';

class UserPlantsRepository {
  UserPlantsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _plantsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('plants');
  }

  Stream<List<UserPlant>> watchUserPlants(String userId) {
    final trimmedUserId = userId.trim();

    if (trimmedUserId.isEmpty) {
      throw const UserPlantsRepositoryException('Utente non disponibile');
    }

    return _plantsCollection(trimmedUserId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => UserPlant.fromFirestore(doc.id, doc.data()))
          .toList(growable: false),
    );
  }

  Future<void> addUserPlant({
    required String userId,
    required UserPlant plant,
  }) async {
    final trimmedUserId = userId.trim();

    if (trimmedUserId.isEmpty) {
      throw const UserPlantsRepositoryException('Utente non disponibile');
    }

    try {
      final collection = _plantsCollection(trimmedUserId);
      final doc =
      plant.id.trim().isEmpty ? collection.doc() : collection.doc(plant.id);

      final payload = _toFirestorePayload(plant, isCreate: true);

      await doc.set(payload, SetOptions(merge: true));
    } on FirebaseException catch (_) {
      throw const UserPlantsRepositoryException(
        'Errore durante il salvataggio della pianta',
      );
    } catch (_) {
      throw const UserPlantsRepositoryException(
        'Errore imprevisto durante il salvataggio della pianta',
      );
    }
  }

  Future<void> updateUserPlant({
    required String userId,
    required UserPlant plant,
  }) async {
    final trimmedUserId = userId.trim();
    final trimmedPlantId = plant.id.trim();

    if (trimmedUserId.isEmpty) {
      throw const UserPlantsRepositoryException('Utente non disponibile');
    }

    if (trimmedPlantId.isEmpty) {
      throw const UserPlantsRepositoryException('Pianta non valida');
    }

    try {
      final payload = _toFirestorePayload(plant, isCreate: false);

      await _plantsCollection(trimmedUserId).doc(trimmedPlantId).update(payload);
    } on FirebaseException catch (_) {
      throw const UserPlantsRepositoryException(
        'Errore durante l’aggiornamento della pianta',
      );
    } catch (_) {
      throw const UserPlantsRepositoryException(
        'Errore imprevisto durante l’aggiornamento della pianta',
      );
    }
  }

  Future<void> deleteUserPlant({
    required String userId,
    required String plantId,
  }) async {
    final trimmedUserId = userId.trim();
    final trimmedPlantId = plantId.trim();

    if (trimmedUserId.isEmpty) {
      throw const UserPlantsRepositoryException('Utente non disponibile');
    }

    if (trimmedPlantId.isEmpty) {
      throw const UserPlantsRepositoryException('Pianta non valida');
    }

    try {
      await _plantsCollection(trimmedUserId).doc(trimmedPlantId).delete();
    } on FirebaseException catch (_) {
      throw const UserPlantsRepositoryException(
        'Errore durante l’eliminazione della pianta',
      );
    } catch (_) {
      throw const UserPlantsRepositoryException(
        'Errore imprevisto durante l’eliminazione della pianta',
      );
    }
  }

  Map<String, dynamic> _toFirestorePayload(
      UserPlant plant, {
        required bool isCreate,
      }) {
    final payload = Map<String, dynamic>.from(plant.toJson())..remove('id');

    payload['updatedAt'] = FieldValue.serverTimestamp();

    if (isCreate) {
      payload['createdAt'] = FieldValue.serverTimestamp();
    } else {
      payload.remove('createdAt');
    }

    return payload;
  }
}

class UserPlantsRepositoryException implements Exception {
  const UserPlantsRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}