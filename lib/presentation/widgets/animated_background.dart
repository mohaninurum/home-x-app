import 'package:flutter/material.dart';

class FloatingHeartsBackground extends StatefulWidget {
  const FloatingHeartsBackground({super.key});

  @override
  State<FloatingHeartsBackground> createState() => _FloatingHeartsBackgroundState();
}

class _FloatingHeartsBackgroundState extends State<FloatingHeartsBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: HeartsPainter(_controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

class HeartsPainter extends CustomPainter {
  final double animationValue;

  HeartsPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw some static gradients first
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFFE91E63).withOpacity(0.4),
        const Color(0xFFFCE4EC).withOpacity(0.8),
        const Color(0xFFFF1744).withOpacity(0.3),
      ],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    // Draw floating simple hearts
    for (int i = 0; i < 5; i++) {
      double yPos = size.height - ((size.height * animationValue + (i * 100)) % size.height);
      double xPos = (size.width / 5) * i + 50 * (i % 2 == 0 ? 1 : -1);
      
      _drawHeart(canvas, xPos, yPos, 40, paint);
    }
  }

  void _drawHeart(Canvas canvas, double x, double y, double size, Paint paint) {
    final path = Path();
    path.moveTo(x, y + size / 4);
    path.cubicTo(
        x - size, y - size / 2,
        x - size / 2, y - size,
        x, y - size / 3);
    path.cubicTo(
        x + size / 2, y - size,
        x + size, y - size / 2,
        x, y + size / 4);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant HeartsPainter oldDelegate) => true;
}
