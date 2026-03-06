import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GestureDrawingDetector extends StatefulWidget {
  final Widget child;
  const GestureDrawingDetector({super.key, required this.child});

  @override
  State<GestureDrawingDetector> createState() => _GestureDrawingDetectorState();
}

class _GestureDrawingDetectorState extends State<GestureDrawingDetector> {
  final List<Offset> _points = [];
  bool _isDrawing = false;

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDrawing = true;
      _points.clear();
      _points.add(details.localPosition);
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _points.add(details.localPosition);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _isDrawing = false;
    });
    _analyzeGesture();
  }

  void _analyzeGesture() {
    if (_points.length < 20) return;

    double minX = _points[0].dx;
    double maxX = _points[0].dx;
    double minY = _points[0].dy;
    double maxY = _points[0].dy;

    for (var p in _points) {
      if (p.dx < minX) minX = p.dx;
      if (p.dx > maxX) maxX = p.dx;
      if (p.dy < minY) minY = p.dy;
      if (p.dy > maxY) maxY = p.dy;
    }

    double width = maxX - minX;
    double height = maxY - minY;

    if (width > 50 && height > 50) {
      _launchWhatsApp();
    }
  }

  Future<void> _launchWhatsApp() async {
    final Uri whatsappUrl = Uri.parse("whatsapp://send?phone=");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: Stack(
        children: [
          widget.child,
          if (_isDrawing)
            CustomPaint(
              size: Size.infinite,
              painter: DrawingPainter(_points),
            ),
        ],
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<Offset> points;
  DrawingPainter(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.pinkAccent
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
        canvas.drawLine(points[i], points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant DrawingPainter oldDelegate) => true;
}
