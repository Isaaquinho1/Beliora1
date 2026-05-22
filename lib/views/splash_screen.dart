import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; 
import 'dart:async';
import 'dart:math' as math;
import 'login_screen.dart';

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

    Timer.periodic(const Duration(milliseconds: 4500), (timer) {
      if (mounted) {
        setState(() {
          _quoteIndex = (_quoteIndex + 1) % _quotes.length;
        });
      }
    });

    // Salto automático al Login tras 6 segundos
    Timer(const Duration(seconds: 6), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 1000),
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
    // Variables de respuesta para medidas dinámicas
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // 1. Fondo Animado
          AnimatedBuilder(
            animation: _liquidController,
            builder: (context, child) {
              return CustomPaint(
                painter: LiquidMercuryPainter(_liquidController.value),
                child: Container(),
              );
            },
          ),
          
          // 2. Viñetas para profundidad
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

          // 3. Contenido Principal Responsivo
          FadeTransition(
            opacity: _fadeController,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo SVG: Ocupa el 30% del alto de la pantalla
                  SizedBox(
                    height: screenHeight * 0.30,
                    width: screenWidth * 0.75,
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/images/logo_beliora.svg',
                        fit: BoxFit.contain,
                        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                      ),
                    ),
                  ),
                  
                  // Wordmark con tamaño dinámico
                  Text(
                    'BELIORA',
                    style: TextStyle(
                      fontFamily: 'Syne', 
                      fontSize: screenHeight * 0.038, // Escala con la pantalla
                      fontWeight: FontWeight.w700,
                      letterSpacing: 12,
                      color: Colors.white,
                    ),
                  ),
                  
                  // Espacio dinámico entre marca y frases (8% de la pantalla)
                  SizedBox(height: screenHeight * 0.08),
                  
                  // Bloque de Frases
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _quotes[_quoteIndex],
                        key: ValueKey(_quoteIndex),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: screenHeight * 0.018,
                          color: Colors.white70,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
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