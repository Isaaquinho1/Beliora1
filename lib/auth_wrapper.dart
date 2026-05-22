import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'views/home_screen.dart';
import 'views/login_screen.dart';
 
/// AuthWrapper escucha el stream de Firebase Auth en tiempo real.
/// Si hay usuario con sesión activa → HomeScreen
/// Si no hay sesión → LoginScreen
/// Esto funciona automáticamente: al hacer login o logout, Flutter navega solo.
 
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});
 
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
 
        // Estado de carga — Firebase todavía está verificando la sesión
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0A0A0A),
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 1.5,
              ),
            ),
          );
        }
 
        // Hay un usuario con sesión activa → ir al Home
        if (snapshot.hasData && snapshot.data != null) {
          return const HomeScreen();
        }
 
        // No hay sesión → ir al Login
        return const LoginScreen();
      },
    );
  }
}