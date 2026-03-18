import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // 1. Escuchar cambios en el estado de autenticación
  Stream<User?> get user => _auth.authStateChanges();

  // 2. Iniciar sesión con Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Iniciar el flujo de login de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // El usuario canceló

      // Obtener los detalles de la autenticación
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Crear una nueva credencial para Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Una vez logueado, devolver la credencial de Firebase
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Error en Google Sign-In: $e");
      return null;
    }
  }

  // 3. Iniciar sesión con Email y Contraseña
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      debugPrint("Error de Firebase Auth: ${e.code}");
      return null;
    }
  }

  // 4. Cerrar Sesión
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}