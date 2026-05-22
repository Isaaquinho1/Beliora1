import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLogin = true;   // true = Login, false = Registro
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Manejo de errores Firebase ───────────────────────────
  String _friendlyError(String code) {
    switch (code) {
      case 'user-not-found':     return 'No existe una cuenta con este correo.';
      case 'wrong-password':     return 'Contraseña incorrecta.';
      case 'invalid-credential': return 'Correo o contraseña incorrectos.';
      case 'email-already-in-use': return 'Este correo ya tiene una cuenta.';
      case 'weak-password':      return 'La contraseña debe tener al menos 6 caracteres.';
      case 'invalid-email':      return 'El correo no es válido.';
      default:                   return 'Algo salió mal. Intenta de nuevo.';
    }
  }

  // ── Acción principal (login o registro) ──────────────────
  Future<void> _handleSubmit() async {
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      if (_isLogin) {
        await _authService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        if (_nameController.text.trim().isEmpty) {
          setState(() { _errorMessage = 'Ingresa tu nombre.'; _isLoading = false; });
          return;
        }
        await _authService.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text.trim(),
          _nameController.text.trim(),
        );
      }
      // AuthWrapper detecta el cambio de sesión y navega automáticamente
    } on FirebaseAuthException catch (e) {
      setState(() { _errorMessage = _friendlyError(e.code); });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          child: Column(
            children: [
              SizedBox(height: screenSize.height * 0.04),

              // ── Logo ──────────────────────────────────────
              SvgPicture.asset(
                'assets/images/logo_beliora.svg',
                width: 60,
                height: 60,
                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              ),
              const SizedBox(height: 8),
              const Text(
                'AZENDYN',
                style: TextStyle(
                  fontFamily: 'Syne',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 6,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              // ── Toggle Login / Registro ───────────────────
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _toggleBtn('Iniciar sesión', _isLogin),
                    _toggleBtn('Crear cuenta', !_isLogin),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── Campo Nombre (solo en registro) ───────────
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                child: _isLogin
                    ? const SizedBox.shrink()
                    : Column(
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            hint: '¿Cómo te llamas?',
                            icon: Icons.person_outline,
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
              ),

              // ── Campos Email y Contraseña ─────────────────
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

              // ── Mensaje de error ──────────────────────────
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // ── Botón principal ───────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : Text(
                          _isLogin ? 'ENTRAR' : 'CREAR CUENTA',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            fontSize: 14,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 28),

              // ── Divisor (solo en login) ───────────────────
              if (_isLogin) ...[
                const Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white10)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'o continuar con',
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white10)),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSocialButton(
                  text: 'Entrar con Apple',
                  icon: Icons.apple,
                  onPressed: () => debugPrint('Apple Login — pendiente'),
                ),
                const SizedBox(height: 10),
                _buildSocialButton(
                  text: 'Entrar con Google',
                  icon: Icons.g_mobiledata_rounded,
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    await _authService.signInWithGoogle();
                    if (mounted) setState(() => _isLoading = false);
                  },
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Widgets helper ────────────────────────────────────────

  Widget _toggleBtn(String label, bool active) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _isLogin = label == 'Iniciar sesión';
          _errorMessage = null;
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? Colors.black : Colors.white38,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        isDense: true,
        prefixIcon: Icon(icon, color: Colors.white38, size: 20),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 10),
            Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }
}