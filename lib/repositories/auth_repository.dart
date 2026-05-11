import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  AuthRepository({
    fb.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final fb.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  Future<void>? _googleInitialization;

  fb.User? get currentUser => _firebaseAuth.currentUser;

  Stream<fb.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<fb.User> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Utente non disponibile dopo il login.');
    }

    return user;
  }

  Future<fb.User> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw Exception('Utente non disponibile dopo la registrazione.');
    }

    final cleanDisplayName = displayName?.trim();
    if (cleanDisplayName != null && cleanDisplayName.isNotEmpty) {
      await user.updateDisplayName(cleanDisplayName);
      await user.reload();
      final reloadedUser = _firebaseAuth.currentUser;
      if (reloadedUser != null) {
        return reloadedUser;
      }
    }

    return user;
  }

  Future<GoogleAuthResult> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = fb.GoogleAuthProvider();
      final credential = await _firebaseAuth.signInWithPopup(provider);
      final user = credential.user;

      if (user == null) {
        throw Exception('Utente non disponibile dopo l’accesso con Google.');
      }

      return GoogleAuthResult(
        user: user,
        isNewUser: credential.additionalUserInfo?.isNewUser ?? false,
      );
    }

    await _initializeGoogleSignIn();

    final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
    final googleAuth = googleUser.authentication;

    final authCredential = fb.GoogleAuthProvider.credential(
      idToken: googleAuth.idToken,
    );

    final credential = await _firebaseAuth.signInWithCredential(authCredential);
    final user = credential.user;

    if (user == null) {
      throw Exception('Utente non disponibile dopo l’accesso con Google.');
    }

    return GoogleAuthResult(
      user: user,
      isNewUser: credential.additionalUserInfo?.isNewUser ?? false,
    );
  }

  Future<void> signOut() async {
    await Future.wait([
      _firebaseAuth.signOut(),
      _signOutFromGoogleSafely(),
    ]);
  }

  Future<void> _initializeGoogleSignIn() {
    _googleInitialization ??= _googleSignIn.initialize();
    return _googleInitialization!;
  }

  Future<void> _signOutFromGoogleSafely() async {
    try {
      await _googleSignIn.signOut();
    } catch (e, stackTrace) {
      debugPrint('Errore durante Google sign out: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}

class GoogleAuthResult {
  const GoogleAuthResult({
    required this.user,
    required this.isNewUser,
  });

  final fb.User user;
  final bool isNewUser;
}