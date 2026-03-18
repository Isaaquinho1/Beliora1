import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart'; // Importamos la lógica

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Instanciamos el servicio de autenticación
  final AuthService _authService = AuthService();
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 80),
            
            // Logo e Identidad
            SvgPicture.asset(
              'assets/images/logo_beliora.svg',
              width: 100,
              height: 100,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            const Text(
              'BELIORA',
              style: TextStyle(
                fontFamily: 'Syne',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 8,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 60),

            // Formulario
            _buildTextField(
              controller: _emailController,
              hint: 'Correo electrónico',
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: 15),
            _buildTextField(
              controller: _passwordController,
              hint: 'Contraseña',
              icon: Icons.lock_outline,
              isPassword: true,
            ),

            const SizedBox(height: 40),

            // Botón NEÓN conectado a Email Login
            Container(
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.5), 
                    blurRadius: 20, 
                    spreadRadius: 2, 
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  elevation: 0, 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: () async {
                  // Llamada al servicio
                  final user = await _authService.signInWithEmail(
                    _emailController.text, 
                    _passwordController.text
                  );
                  if (user != null) {
                    debugPrint("Login exitoso con Email");
                  }
                },
                child: const Text(
                  'ENTRAR',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 50),

            const Row(
              children: [
                Expanded(child: Divider(color: Colors.white10)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text('o continuar con', style: TextStyle(color: Colors.white38, fontSize: 12)),
                ),
                Expanded(child: Divider(color: Colors.white10)),
              ],
            ),

            const SizedBox(height: 40),

            // Botones Sociales conectados
            _buildSocialButton(
              text: 'Entrar con Apple',
              icon: Icons.apple,
              color: Colors.black,
              textColor: Colors.white,
              borderColor: Colors.white10,
              onPressed: () {
                debugPrint('Próximamente: Apple Login');
              },
            ),
            
            const SizedBox(height: 15),
            
            _buildSocialButton(
              text: 'Entrar con Google',
              icon: Icons.g_mobiledata_rounded,
              color: Colors.black,
              textColor: Colors.white,
              borderColor: Colors.white10,
              onPressed: () async {
                // Llamada al servicio de Google
                final user = await _authService.signInWithGoogle();
                if (user != null) {
                  debugPrint("Bienvenido: ${user.user?.displayName}");
                }
              },
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helpers (Se mantienen igual para conservar tu diseño impecable)
  Widget _buildSocialButton({
    required String text, 
    required IconData icon, 
    required Color color, 
    required Color textColor, 
    required Color borderColor,
    required VoidCallback onPressed
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Text(
              text, 
              style: const TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, 
    required String hint, 
    required IconData icon, 
    bool isPassword = false
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white38),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}