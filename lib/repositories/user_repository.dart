import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../features/user/user.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

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
    final snapshot = await _usersCollection.doc(userId).get();
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    if (data == null) return null;
    return _fromFirestore(snapshot.id, data);
  }

  // ── Username ────────────────────────────────────────────────────────────

  Future<bool> usernameExists(String username) async {
    final normalized = _normalizeUsername(username);
    if (normalized.isEmpty) return false;

    final result = await _usersCollection
        .where('username_lowercase', isEqualTo: normalized)
        .limit(1)
        .get();

    return result.docs.isNotEmpty;
  }

  // ── Write ───────────────────────────────────────────────────────────────

  Future<void> createUserProfile(PlantlyUser user) async {
    final now = DateTime.now().toUtc();
    await _usersCollection.doc(user.id).set({
      'id': user.id,
      'username': user.username.trim(),
      'username_lowercase': _normalizeUsername(user.username),
      'name': user.name.trim(),
      'surname': user.surname.trim(),
      'email': user.email.trim(),
      'country': user.country.trim(),
      'city': user.city.trim(),
      'imageUrl': user.imageUrl,
      'bio': user.bio,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
    });
  }

  Future<void> updateUserProfile(PlantlyUser user) async {
    await _usersCollection.doc(user.id).update({
      'username': user.username.trim(),
      'username_lowercase': _normalizeUsername(user.username),
      'name': user.name.trim(),
      'surname': user.surname.trim(),
      'email': user.email.trim(),
      'country': user.country.trim(),
      'city': user.city.trim(),
      'imageUrl': user.imageUrl,
      'bio': user.bio,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    });
  }

  // ── Google Sign-In profile bootstrap ───────────────────────────────────

  /// Ensures a Firestore document exists for a Google-authenticated user.
  ///
  /// - If the document already exists it is returned as-is (even if
  ///   incomplete — callers are responsible for checking completeness via
  ///   [isProfileComplete]).
  /// - If the document does not exist, a partial profile is created from
  ///   whatever Firebase/Google provides (name, email, photo). Fields that
  ///   Google cannot supply (country, city) are stored as empty strings.
  ///   The username is auto-generated to be unique so the document is
  ///   always insertable, but the caller should still route the user to
  ///   profile completion because country and city will be blank.
  Future<PlantlyUser> ensureGoogleUserProfile(fb.User firebaseUser) async {
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
    );

    await createUserProfile(user);
    return user;
  }

  // ── Profile completeness check ──────────────────────────────────────────

  /// Returns true when all required user-facing fields are present and
  /// non-empty.
  ///
  /// This is intentionally a pure helper method (no async, no Firestore
  /// call) so it can be used cheaply by Cubits after they already have a
  /// [PlantlyUser] in hand.
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
    final result = await _usersCollection
        .where('username_lowercase', isEqualTo: normalized)
        .limit(1)
        .get();

    if (result.docs.isEmpty) {
      throw const UserRepositoryException('Username non trovato');
    }

    final data = result.docs.first.data();
    final email = (data['email'] as String?)?.trim();
    if (email == null || email.isEmpty) {
      throw const UserRepositoryException(
        'Profilo utente incompleto. Email non disponibile.',
      );
    }

    return email;
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

  String _normalizeUsername(String username) =>
      username.trim().toLowerCase();

  bool _looksLikeEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  PlantlyUser _fromFirestore(String id, Map<String, dynamic> data) {
    return PlantlyUser(
      id: id,
      username: (data['username'] ?? '') as String,
      name: (data['name'] ?? '') as String,
      surname: (data['surname'] ?? '') as String,
      email: (data['email'] ?? '') as String,
      country: (data['country'] ?? '') as String,
      city: (data['city'] ?? '') as String,
      imageUrl: data['imageUrl'] as String?,
      bio: data['bio'] as String?,
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
  }
}

class UserRepositoryException implements Exception {
  final String message;

  const UserRepositoryException(this.message);

  @override
  String toString() => message;
}
