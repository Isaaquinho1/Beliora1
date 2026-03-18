import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 
import 'dart:async';
import 'dart:math' as math;
import 'login_screen.dart'; // Importamos la futura pantalla de login

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _liquidController;
  int _quoteIndex = 0;
  
  final List<String> _quotes = [
    "\"Where maps melt,\nyour true path takes shape.\"",
    "\"Eres suficiente,\njusto como estás hoy.\"",
    "\"Hoy fue difícil.\nBien. Eso es información.\"",
  ];

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _liquidController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Ciclo de frases
    Timer.periodic(const Duration(milliseconds: 4500), (timer) {
      if (mounted) {
        setState(() {
          _quoteIndex = (_quoteIndex + 1) % _quotes.length;
        });
      }
    });

    // [PASO FINAL SEMANA 2] Salto automático al Login tras 6 segundos
    Timer(const Duration(seconds: 6), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1500),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _liquidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _liquidController,
            builder: (context, child) {
              return CustomPaint(
                painter: LiquidMercuryPainter(_liquidController.value),
                child: Container(),
              );
            },
          ),
          
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                  Colors.black.withValues(alpha: 0.9),
                ],
                stops: const [0.2, 0.6, 1.0],
              ),
            ),
          ),

          FadeTransition(
            opacity: _fadeController,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo SVG - Altura reducida para eliminar el espacio vacío
                  SizedBox(
                    width: 420,
                    height: 280, // Reducido de 450 a 280 para "pegar" el texto
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/logo_beliora.svg',
                        width: 420,
                        height: 420, // El SVG mantiene su escala masiva
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  
                  // Quitamos cualquier SizedBox intermedio
                  const Text(
                    'BELIORA',
                    style: TextStyle(
                      fontFamily: 'Syne', 
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 14,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 50), // Espacio equilibrado hacia las frases
                  
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _quotes[_quoteIndex],
                        key: ValueKey(_quoteIndex),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 16,
                          color: Colors.white70,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 25),
                  const LoadingDots(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- CLASES DE DIBUJO ---
class LiquidMercuryPainter extends CustomPainter {
  final double animationValue;
  LiquidMercuryPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 50);
    final random = math.Random(42);

    for (int i = 0; i < 6; i++) {
      final speed = 0.2 + random.nextDouble();
      final x = size.width * (0.5 + 0.3 * math.sin(animationValue * 2 * math.pi * speed + i));
      final y = size.height * (0.4 + 0.2 * math.cos(animationValue * 2 * math.pi * speed * 0.7 + i));
      
      paint.color = Color.lerp(
        const Color(0xFF4A4A4E), 
        const Color(0xFF9A9A9F), 
        random.nextDouble()
      )!.withValues(alpha: 0.25);

      canvas.drawCircle(Offset(x, y), 150 + 50 * math.sin(animationValue * math.pi), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LoadingDots extends StatefulWidget {
  const LoadingDots({super.key});

  @override
  State<LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<LoadingDots> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final delay = index * 0.3;
            final val = math.sin((_controller.value * 2 * math.pi) - delay).abs();
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.2 + 0.6 * val),
              ),
            );
          },
        );
      }),
    );
  }
}