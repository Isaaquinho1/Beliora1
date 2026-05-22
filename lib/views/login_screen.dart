import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        // Quitamos el scroll si no es estrictamente necesario, 
        // pero lo dejamos con un physics para que no rebote feo
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Column(
            children: [
              // Espacio dinámico reducido al 3%
              SizedBox(height: screenSize.height * 0.03),
              
              // 1. Identidad Visual Compacta
              SvgPicture.asset(
                'assets/images/logo_beliora.svg',
                width: 65, // Reducido de 80 a 65
                height: 65,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              const SizedBox(height: 8),
              const Text(
                'BELIORA',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 6,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 30), // Reducido de 40 a 30

              // 2. Formulario de Email
              _buildTextField(
                controller: _emailController,
                hint: 'Correo electrónico',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _passwordController,
                hint: 'Contraseña',
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              const SizedBox(height: 25),

              // 3. Botón "ENTRAR" con efecto NEÓN (Más estilizado)
              Container(
                width: double.infinity,
                height: 52, // Reducido de 55 a 52
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.2), 
                      blurRadius: 15, 
                      spreadRadius: 1, 
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
                    await _authService.signInWithEmail(
                      _emailController.text, 
                      _passwordController.text
                    );
                  },
                  child: const Text(
                    'ENTRAR',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35), // Espacio hacia el divisor

              // 4. Divisor
              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.white10, indent: 10, endIndent: 10)),
                  Text('o continuar con', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  Expanded(child: Divider(color: Colors.white10, indent: 10, endIndent: 10)),
                ],
              ),

              const SizedBox(height: 25),

              // 5. Autenticaciones Sociales Compactas
              _buildSocialButton(
                text: 'Entrar con Apple',
                icon: Icons.apple,
                color: Colors.black,
                textColor: Colors.white,
                borderColor: Colors.white10,
                onPressed: () => debugPrint('Apple Login'),
              ),
              
              const SizedBox(height: 10),
              
              _buildSocialButton(
                text: 'Entrar con Google',
                icon: Icons.g_mobiledata_rounded,
                color: Colors.black,
                textColor: Colors.white,
                borderColor: Colors.white10,
                onPressed: () async {
                  await _authService.signInWithGoogle();
                },
              ),

              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }

  // Helpers optimizados para ahorrar espacio vertical
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
      height: 48, // Reducido de 50 a 48
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          side: BorderSide(color: borderColor),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: EdgeInsets.zero, // Minimiza padding interno
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22), // Icono ligeramente más pequeño
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
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
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        isDense: true, // CLAVE: Reduce la altura interna del TextField
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30), 
          borderSide: BorderSide.none
        ),
      ),
    );
  }
}