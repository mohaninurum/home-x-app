import 'package:flutter/material.dart';
import 'dart:math' as math;

class NeoMovingBorder extends StatefulWidget {
  final Widget child;
  final double borderWidth;
  final Color primaryColor;
  final Color secondaryColor;
  final double speed;
  final bool isCircle;
  final BorderRadius? borderRadius;

  const NeoMovingBorder({
    super.key,
    required this.child,
    this.borderWidth = 4.0,
    this.primaryColor = Colors.pinkAccent,
    this.secondaryColor = Colors.cyanAccent,
    this.speed = 1.0,
    this.isCircle = false,
    this.borderRadius,
  });

  @override
  State<NeoMovingBorder> createState() => _NeoMovingBorderState();
}

class _NeoMovingBorderState extends State<NeoMovingBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: (2000 / widget.speed).round()),
    )..repeat();
  }

  @override
  void didUpdateWidget(NeoMovingBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.speed != widget.speed) {
      _controller.duration = Duration(milliseconds: (2000 / widget.speed).round());
      if (_controller.isAnimating) {
        _controller.repeat();
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          foregroundPainter: _NeoBorderPainter(
            animationValue: _controller.value,
            borderWidth: widget.borderWidth,
            primaryColor: widget.primaryColor,
            secondaryColor: widget.secondaryColor,
            isCircle: widget.isCircle,
            borderRadius: widget.borderRadius ?? BorderRadius.circular(0),
          ),
          child: widget.child,
        );
      },
    );
  }
}

class _NeoBorderPainter extends CustomPainter {
  final double animationValue;
  final double borderWidth;
  final Color primaryColor;
  final Color secondaryColor;
  final bool isCircle;
  final BorderRadius borderRadius;

  _NeoBorderPainter({
    required this.animationValue,
    required this.borderWidth,
    required this.primaryColor,
    required this.secondaryColor,
    required this.isCircle,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint paint = Paint()
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double rotation = animationValue * 2 * math.pi;

    final Gradient gradient = SweepGradient(
      center: Alignment.center,
      startAngle: 0.0,
      endAngle: 2 * math.pi,
      colors: [
        primaryColor,
        secondaryColor,
        primaryColor,
      ],
      transform: GradientRotation(rotation),
    );

    paint.shader = gradient.createShader(rect);

    if (isCircle) {
      canvas.drawOval(rect.deflate(borderWidth / 2), paint);
    } else {
      final RRect rrect = borderRadius.toRRect(rect).deflate(borderWidth / 2);
      canvas.drawRRect(rrect, paint);
    }

    // Add a subtle glow effect
    final Paint glowPaint = Paint()
      ..strokeWidth = borderWidth * 1.5
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..shader = paint.shader;
    
    if (isCircle) {
      canvas.drawOval(rect.deflate(borderWidth / 2), glowPaint);
    } else {
      final RRect rrect = borderRadius.toRRect(rect).deflate(borderWidth / 2);
      canvas.drawRRect(rrect, glowPaint);
    }
  }

  @override
  bool shouldRepaint(_NeoBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        oldDelegate.isCircle != isCircle ||
        oldDelegate.borderRadius != borderRadius;
  }
}
