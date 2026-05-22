import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// HomeScreen — Pantalla principal de Azendyn
/// Por ahora muestra los 3 modos y el usuario logueado.
/// Aquí se irán agregando las tarjetas de Relax / Motivate / Stoic.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  
  // Modo seleccionado: 0=Relax, 1=Motivate, 2=Stoic
  int _selectedMode = 0;

  // Configuración visual de cada modo
  final List<Map<String, dynamic>> _modes = [
    {
      'name': 'Relax',
      'color': Colors.white,
      'bgColor': const Color(0xFF1A1A1A),
      'description': 'Encuentra calma en este momento',
    },
    {
      'name': 'Motivate',
      'color': const Color(0xFFF0C040),
      'bgColor': const Color(0xFF1A1500),
      'description': 'Activa tu energía y enfoque',
    },
    {
      'name': 'Stoic',
      'color': const Color(0xFFFF0C34),
      'bgColor': const Color(0xFF1A0005),
      'description': 'Fortaleza ante la adversidad',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final mode = _modes[_selectedMode];
    final modeColor = mode['color'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── HEADER ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AZENDYN',
                        style: TextStyle(
                          fontFamily: 'Syne',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 4,
                          color: modeColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Hola, ${user?.displayName ?? user?.email?.split('@')[0] ?? 'usuario'}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  // Botón de cerrar sesión (temporal para pruebas)
                  GestureDetector(
                    onTap: () async {
                      await _authService.signOut();
                      // AuthWrapper detecta el logout automáticamente
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Icon(
                        Icons.logout,
                        color: Colors.white38,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // ── SELECTOR DE MODO ────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: List.generate(_modes.length, (index) {
                  final isSelected = _selectedMode == index;
                  final color = _modes[index]['color'] as Color;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMode = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.12)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: isSelected
                                ? color.withValues(alpha: 0.6)
                                : Colors.white10,
                          ),
                        ),
                        child: Text(
                          _modes[index]['name'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? color : Colors.white38,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 40),

            // ── DESCRIPCIÓN DEL MODO ─────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Text(
                  mode['description'],
                  key: ValueKey(_selectedMode),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w300,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
              ),
            ),

            const Spacer(),

            // ── BOTÓN GENERAR SESIÓN ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: GestureDetector(
                onTap: () {
                  // TODO: navegar a GenerateScreen
                  // Navigator.push(context, MaterialPageRoute(
                  //   builder: (_) => GenerateScreen(mode: _selectedMode),
                  // ));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('GenerateScreen — próximamente'),
                      backgroundColor: Color(0xFF1A1A1A),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    color: modeColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: modeColor.withValues(alpha: 0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'GENERAR SESIÓN',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                        color: _selectedMode == 0
                            ? Colors.black
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}