import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── 1. Stream de estado de auth ──────────────────────────
  Stream<User?> get user => _auth.authStateChanges();

  // ── 2. Registro con Email y Contraseña ───────────────────
  Future<UserCredential?> signUpWithEmail(String email, String password, String name) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Actualizar el nombre en Firebase Auth
      await credential.user?.updateDisplayName(name);

      // Crear documento del usuario en Firestore
      await _createUserDoc(credential.user!, name: name);

      return credential;
    } on FirebaseAuthException catch (e) {
      debugPrint("Error al registrar: ${e.code}");
      rethrow; // Lo manejamos en la UI
    }
  }

  // ── 3. Login con Email y Contraseña ──────────────────────
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint("Error de Firebase Auth: ${e.code}");
      rethrow;
    }
  }

  // ── 4. Login con Google ───────────────────────────────────
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);

      // Si es usuario nuevo, crear su documento en Firestore
      if (result.additionalUserInfo?.isNewUser == true) {
        await _createUserDoc(result.user!);
      }

      return result;
    } catch (e) {
      debugPrint("Error en Google Sign-In: $e");
      return null;
    }
  }

  // ── 5. Cerrar Sesión ─────────────────────────────────────
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ── HELPER: Crear documento en Firestore al registrarse ──
  // Estructura: users/{uid}
  Future<void> _createUserDoc(User user, {String? name}) async {
    final docRef = _db.collection('users').doc(user.uid);
    final exists = (await docRef.get()).exists;

    if (!exists) {
      await docRef.set({
        'uid': user.uid,
        'name': name ?? user.displayName ?? '',
        'email': user.email ?? '',
        'plan': 'free',              // free | premium | early_adopter
        'sessionsThisMonth': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      });
    }
  }
}