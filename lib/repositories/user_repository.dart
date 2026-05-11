import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../features/user/user.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _usernamesCollection =>
      _firestore.collection('usernames');

  // ── Read ────────────────────────────────────────────────────────────────

  Stream<PlantlyUser?> watchUser(String userId) {
    return _usersCollection.doc(userId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      if (data == null) return null;
      return _fromFirestore(snapshot.id, data);
    });
  }

  Future<PlantlyUser?> getUser(String userId) async {
    try {
      final snapshot = await _usersCollection.doc(userId).get();

      if (!snapshot.exists) return null;
      final data = snapshot.data();
      if (data == null) return null;

      return _fromFirestore(snapshot.id, data);
    } on FirebaseException catch (_) {
      throw const UserRepositoryException(
        'Errore durante il caricamento del profilo utente',
      );
    } catch (_) {
      throw const UserRepositoryException(
        'Errore imprevisto durante il caricamento del profilo utente',
      );
    }
  }

  // ── Username ────────────────────────────────────────────────────────────

  Future<bool> usernameExists(String username) async {
    final normalized = _normalizeUsername(username);
    if (normalized.isEmpty) return false;

    try {
      final snapshot = await _usernamesCollection.doc(normalized).get();
      return snapshot.exists;
    } on FirebaseException catch (_) {
      throw const UserRepositoryException(
        'Errore durante il controllo dello username',
      );
    } catch (_) {
      throw const UserRepositoryException(
        'Errore imprevisto durante il controllo dello username',
      );
    }
  }

  // ── Write ───────────────────────────────────────────────────────────────

  Future<void> createUserProfile(PlantlyUser user) async {
    final normalizedUsername = _normalizeUsername(user.username);
    if (normalizedUsername.isEmpty) {
      throw const UserRepositoryException('Username obbligatorio');
    }

    final now = DateTime.now().toUtc();
    final userDoc = _usersCollection.doc(user.id);
    final usernameDoc = _usernamesCollection.doc(normalizedUsername);

    try {
      await _firestore.runTransaction((transaction) async {
        final usernameSnapshot = await transaction.get(usernameDoc);

        if (usernameSnapshot.exists) {
          final existingUid = usernameSnapshot.data()?['uid'] as String?;
          if (existingUid != user.id) {
            throw const UserRepositoryException('Username già in uso');
          }
        }

        transaction.set(userDoc, {
          'id': user.id,
          'username': user.username.trim(),
          'username_lowercase': normalizedUsername,
          'name': user.name.trim(),
          'surname': user.surname.trim(),
          'email': user.email.trim(),
          'country': user.country.trim(),
          'city': user.city.trim(),
          'imageUrl': user.imageUrl,
          'bio': user.bio,
          'createdAt': (user.createdAt ?? now).toIso8601String(),
          'updatedAt': now.toIso8601String(),
        });

        transaction.set(usernameDoc, {
          'uid': user.id,
          'email': user.email.trim(),
          'username': user.username.trim(),
          'updatedAt': now.toIso8601String(),
        });
      });
    } on UserRepositoryException {
      rethrow;
    } on FirebaseException catch (_) {
      throw const UserRepositoryException(
        'Errore durante la creazione del profilo utente',
      );
    } catch (_) {
      throw const UserRepositoryException(
        'Errore imprevisto durante la creazione del profilo utente',
      );
    }
  }

  Future<void> updateUserProfile(PlantlyUser user) async {
    final normalizedUsername = _normalizeUsername(user.username);
    if (normalizedUsername.isEmpty) {
      throw const UserRepositoryException('Username obbligatorio');
    }

    final userDoc = _usersCollection.doc(user.id);
    final newUsernameDoc = _usernamesCollection.doc(normalizedUsername);
    final now = DateTime.now().toUtc();

    try {
      await _firestore.runTransaction((transaction) async {
        final userSnapshot = await transaction.get(userDoc);
        if (!userSnapshot.exists) {
          throw const UserRepositoryException('Profilo utente non trovato');
        }

        final existingUserData = userSnapshot.data()!;
        final currentUsername = _normalizeUsername(
          (existingUserData['username'] as String?) ?? '',
        );

        final newUsernameSnapshot = await transaction.get(newUsernameDoc);
        if (newUsernameSnapshot.exists) {
          final existingUid = newUsernameSnapshot.data()?['uid'] as String?;
          if (existingUid != user.id) {
            throw const UserRepositoryException('Username già in uso');
          }
        }

        transaction.update(userDoc, {
          'username': user.username.trim(),
          'username_lowercase': normalizedUsername,
          'name': user.name.trim(),
          'surname': user.surname.trim(),
          'email': user.email.trim(),
          'country': user.country.trim(),
          'city': user.city.trim(),
          'imageUrl': user.imageUrl,
          'bio': user.bio,
          'updatedAt': now.toIso8601String(),
        });

        transaction.set(newUsernameDoc, {
          'uid': user.id,
          'email': user.email.trim(),
          'username': user.username.trim(),
          'updatedAt': now.toIso8601String(),
        });

        if (currentUsername.isNotEmpty &&
            currentUsername != normalizedUsername) {
          final oldUsernameDoc = _usernamesCollection.doc(currentUsername);
          transaction.delete(oldUsernameDoc);
        }
      });
    } on UserRepositoryException {
      rethrow;
    } on FirebaseException catch (_) {
      throw const UserRepositoryException(
        'Errore durante l’aggiornamento del profilo utente',
      );
    } catch (_) {
      throw const UserRepositoryException(
        'Errore imprevisto durante l’aggiornamento del profilo utente',
      );
    }
  }

  // ── Google Sign-In profile bootstrap ───────────────────────────────────

  Future<PlantlyUser> ensureGoogleUserProfile(fb.User firebaseUser) async {
    try {
      final existingUser = await getUser(firebaseUser.uid);
      if (existingUser != null) {
        return existingUser;
      }

      final names = _splitDisplayName(firebaseUser.displayName);
      final email = (firebaseUser.email ?? '').trim();

      final generatedUsername = await _generateUniqueUsername(
        email: email,
        displayName: firebaseUser.displayName,
      );

      final user = PlantlyUser(
        id: firebaseUser.uid,
        username: generatedUsername,
        name: names.$1,
        surname: names.$2,
        email: email,
        country: '',
        city: '',
        imageUrl: firebaseUser.photoURL,
        createdAt: DateTime.now().toUtc(),
        updatedAt: DateTime.now().toUtc(),
      );

      await createUserProfile(user);
      return user;
    } on UserRepositoryException {
      rethrow;
    } catch (_) {
      throw const UserRepositoryException(
        'Errore durante la preparazione del profilo Google',
      );
    }
  }

  // ── Profile completeness check ──────────────────────────────────────────

  bool isProfileComplete(PlantlyUser user) {
    return user.username.trim().isNotEmpty &&
        user.country.trim().isNotEmpty &&
        user.city.trim().isNotEmpty;
  }

  // ── Email resolution (username login) ──────────────────────────────────

  Future<String> resolveEmailFromIdentifier(String identifier) async {
    final cleaned = identifier.trim();

    if (cleaned.isEmpty) {
      throw const UserRepositoryException('Inserisci email o username');
    }

    if (_looksLikeEmail(cleaned)) {
      return cleaned;
    }

    final normalized = _normalizeUsername(cleaned);

    try {
      final snapshot = await _usernamesCollection.doc(normalized).get();

      if (!snapshot.exists) {
        throw const UserRepositoryException('Username non trovato');
      }

      final data = snapshot.data();
      final email = (data?['email'] as String?)?.trim();

      if (email == null || email.isEmpty) {
        throw const UserRepositoryException(
          'Profilo utente incompleto. Email non disponibile.',
        );
      }

      return email;
    } on UserRepositoryException {
      rethrow;
    } on FirebaseException catch (_) {
      throw const UserRepositoryException(
        'Errore durante la risoluzione dello username',
      );
    } catch (_) {
      throw const UserRepositoryException(
        'Errore imprevisto durante la risoluzione dello username',
      );
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────

  Future<String> _generateUniqueUsername({
    required String email,
    required String? displayName,
  }) async {
    final base = _buildUsernameBase(email: email, displayName: displayName);

    var candidate = base;
    var suffix = 1;

    while (await usernameExists(candidate)) {
      candidate = '$base$suffix';
      suffix++;
    }

    return candidate;
  }

  String _buildUsernameBase({
    required String email,
    required String? displayName,
  }) {
    final fromDisplayName = (displayName ?? '')
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), '.')
        .replaceAll(RegExp(r'[^a-z0-9._]'), '');

    if (fromDisplayName.isNotEmpty) {
      return fromDisplayName.length >= 3
          ? fromDisplayName
          : '${fromDisplayName}123';
    }

    final localPart = email.split('@').first.trim().toLowerCase();
    final normalizedLocalPart =
        localPart.replaceAll(RegExp(r'[^a-z0-9._]'), '');

    if (normalizedLocalPart.length >= 3) {
      return normalizedLocalPart;
    }

    return 'plantlyuser';
  }

  (String, String) _splitDisplayName(String? displayName) {
    final cleaned = (displayName ?? '').trim();
    if (cleaned.isEmpty) return ('', '');

    final parts = cleaned.split(RegExp(r'\s+'));
    if (parts.length == 1) return (parts.first, '');

    return (parts.first, parts.sublist(1).join(' '));
  }

  String _normalizeUsername(String username) => username.trim().toLowerCase();

  bool _looksLikeEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  PlantlyUser _fromFirestore(String id, Map<String, dynamic> data) {
    final normalized = Map<String, dynamic>.from(data);

    normalized['id'] = id;

    final createdAt = normalized['createdAt'];
    if (createdAt is Timestamp) {
      normalized['createdAt'] = createdAt.toDate().toUtc().toIso8601String();
    }

    final updatedAt = normalized['updatedAt'];
    if (updatedAt is Timestamp) {
      normalized['updatedAt'] = updatedAt.toDate().toUtc().toIso8601String();
    }

    return PlantlyUser.fromJson(normalized);
  }
}

class UserRepositoryException implements Exception {
  final String message;

  const UserRepositoryException(this.message);

  @override
  String toString() => 'UserRepositoryException(message: $message)';
}
