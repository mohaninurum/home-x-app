import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../theme_provider.dart';

class FloatingHeartParticle {
  double x;
  double y;
  double size;
  double opacity;
  double speedY;
  double oscillationSpeed;
  double oscillationAmount;

  FloatingHeartParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speedY,
    required this.oscillationSpeed,
    required this.oscillationAmount,
  });
}

class AnimatedHeartsBackground extends ConsumerStatefulWidget {
  const AnimatedHeartsBackground({super.key});

  @override
  ConsumerState<AnimatedHeartsBackground> createState() => _AnimatedHeartsBackgroundState();
}

class _AnimatedHeartsBackgroundState extends ConsumerState<AnimatedHeartsBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<FloatingHeartParticle> _particles = [];
  final Random _random = Random();
  final int _particleCount = 20;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _initialized = true;
      _initParticles();
    }
  }

  void _initParticles() {
    final size = MediaQuery.of(context).size;
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(_generateParticle(size.height, randomizeY: true));
    }
  }

  FloatingHeartParticle _generateParticle(double screenHeight, {bool randomizeY = false}) {
    final size = MediaQuery.of(context).size;
    return FloatingHeartParticle(
      x: _random.nextDouble() * size.width,
      y: randomizeY ? _random.nextDouble() * screenHeight : screenHeight + 50,
      size: _random.nextDouble() * 20 + 10,
      opacity: _random.nextDouble() * 0.5 + 0.1,
      speedY: _random.nextDouble() * 1.5 + 0.5,
      oscillationSpeed: _random.nextDouble() * 0.05 + 0.01,
      oscillationAmount: _random.nextDouble() * 30 + 10,
    );
  }

  void _updateParticles(Size screenSize) {
    for (int i = 0; i < _particles.length; i++) {
      _particles[i].y -= _particles[i].speedY;
      if (_particles[i].y < -50) {
        _particles[i] = _generateParticle(screenSize.height);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeMoodProvider);
    final screenSize = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: theme.backgroundGradients.length >= 2
              ? theme.backgroundGradients
              : [theme.backgroundColor, theme.backgroundColor],
        ),
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          _updateParticles(screenSize);
          return CustomPaint(
            painter: HeartsPainter(
              List.from(_particles), // snapshot to avoid mutation during paint
              theme.primaryColor,
              theme.secondaryColor,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class HeartsPainter extends CustomPainter {
  final List<FloatingHeartParticle> particles;
  final Color color1;
  final Color color2;

  HeartsPainter(this.particles, this.color1, this.color2);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = Color.lerp(color1, color2, particle.y / size.height)!
            .withOpacity(particle.opacity)
        ..style = PaintingStyle.fill;

      double oscX = particle.x +
          sin(particle.y * particle.oscillationSpeed) * particle.oscillationAmount;

      _drawHeart(canvas, Offset(oscX, particle.y), particle.size, paint);
    }
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size / 4);
    path.cubicTo(
        center.dx - size, center.dy - size * 0.75,
        center.dx - size * 0.5, center.dy - size,
        center.dx, center.dy - size * 0.1);
    path.cubicTo(
        center.dx + size * 0.5, center.dy - size,
        center.dx + size, center.dy - size * 0.75,
        center.dx, center.dy + size / 4);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant HeartsPainter oldDelegate) => true;
}
