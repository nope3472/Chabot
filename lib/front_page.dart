import 'package:chatbot_app/home_page.dart';
import 'package:chatbot_app/image_generator.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedBackgroundWithUI extends StatefulWidget {
  final Color startColor;
  final Color endColor;

  const AnimatedBackgroundWithUI({
    Key? key,
    this.startColor = const Color(0xFF1a1a2e),
    this.endColor = const Color(0xFF16213e),
  }) : super(key: key);

  @override
  _AnimatedBackgroundWithUIState createState() => _AnimatedBackgroundWithUIState();
}

class _AnimatedBackgroundWithUIState extends State<AnimatedBackgroundWithUI> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    for (int i = 0; i < 50; i++) {
      _particles.add(Particle());
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [widget.startColor, widget.endColor],
                    ),
                  ),
                  child: CustomPaint(
                    painter: ParticlePainter(_particles, _controller.value),
                  ),
                );
              },
            ),
          ),
          // Foreground content with image and buttons
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Image placeholder
                 Image.asset("lib/assets/back.png", width: 200, height: 200, fit: BoxFit.cover)

              ,
                const SizedBox(height: 30),
                // First button
                ElevatedButton(
                  onPressed: () {
                     Navigator.of(context).push(
                     MaterialPageRoute(
                    builder: (context) => Homepage(), // Pass the Homepage widget here
                    ));
                  },
                  child: const Text("Ask Chatbot"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 15),
                // Second button
                ElevatedButton(
                  onPressed: () {
                  
                     Navigator.of(context).push(
                     MaterialPageRoute(
                    builder: (context) => TextToImageScreen(), // Pass the Homepage widget here
                    ));
                 
                  },
                  child: const Text("Generate Image"),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Particle {
  double x;
  double y;
  double speedX;
  double speedY;
  double radius;

  Particle()
      : x = math.Random().nextDouble(),
        y = math.Random().nextDouble(),
        speedX = math.Random().nextDouble() * 0.005 + 0.001,
        speedY = math.Random().nextDouble() * 0.005 + 0.001,
        radius = math.Random().nextDouble() * 2 + 1;

  void updatePosition() {
    x += speedX;
    y += speedY;

    if (x > 1.0) x -= 1.0;
    if (y > 1.0) y -= 1.0;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;

  ParticlePainter(this.particles, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1;

    for (var particle in particles) {
      particle.updatePosition();

      var startPoint = Offset(particle.x * size.width, particle.y * size.height);

      canvas.drawLine(
        startPoint,
        Offset(startPoint.dx + 20, startPoint.dy + 20),
        paint,
      );

      canvas.drawCircle(startPoint, particle.radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
