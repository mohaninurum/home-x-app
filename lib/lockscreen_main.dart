import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

@pragma('vm:entry-point')
void lockScreenMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LockScreenApp());
}

class LockScreenApp extends StatelessWidget {
  const LockScreenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoveLockScreen(),
    );
  }
}

// ─── Main Lock Screen ────────────────────────────────────────────────────────
class LoveLockScreen extends StatefulWidget {
  const LoveLockScreen({super.key});

  @override
  State<LoveLockScreen> createState() => _LoveLockScreenState();
}

class _LoveLockScreenState extends State<LoveLockScreen> {
  static const MethodChannel _channel =
      MethodChannel('com.example.homexapp/lockscreen');

  // Pin-tap based unlock to sidestep touch bugs with pattern draw
  final List<int> _correctPattern = [0, 1, 2, 5, 8];

  void _onPatternComplete(List<int> drawn) {
    if (_listsEqual(drawn, _correctPattern)) {
      _unlockDevice();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Incorrect Pattern 💔", textAlign: TextAlign.center),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 1),
      ));
    }
  }

  bool _listsEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  Future<void> _unlockDevice() async {
    try {
      await _channel.invokeMethod('unlock');
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Background: local deep gradient (no network call) ──────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D0014),
                  Color(0xFF1A0020),
                  Color(0xFF2D0035),
                  Color(0xFF1A000A),
                ],
                stops: [0.0, 0.35, 0.7, 1.0],
              ),
            ),
          ),

          // Decorative circles for depth
          Positioned(
            top: -80,
            right: -80,
            child: _GlowCircle(size: 300, color: const Color(0xFFE91E63)),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: _GlowCircle(size: 240, color: const Color(0xFF9C27B0)),
          ),

          // ── Content ────────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Time display
                _ClockWidget(),

                const SizedBox(height: 8),

                const Text(
                  "❤️ Draw pattern to unlock",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 0.5,
                  ),
                ),

                const Spacer(),

                // Pattern grid
                SizedBox(
                  width: math.min(size.width * 0.8, 320),
                  height: math.min(size.width * 0.8, 320),
                  child: HeartPatternLock(
                    onPatternComplete: _onPatternComplete,
                  ),
                ),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Simple Clock ────────────────────────────────────────────────────────────
class _ClockWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final min  = now.minute.toString().padLeft(2, '0');
    final days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    final date = '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';

    return Column(
      children: [
        Text(
          '$hour:$min',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 72,
            fontWeight: FontWeight.w100,
            letterSpacing: -2,
          ),
        ),
        Text(
          date,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

// ─── Glowing circle decoration ───────────────────────────────────────────────
class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(0.35), Colors.transparent],
        ),
      ),
    );
  }
}

// ─── Pattern Lock Widget ──────────────────────────────────────────────────────
// Uses a Stack + CustomPaint instead of GridView so pan gestures work correctly.
class HeartPatternLock extends StatefulWidget {
  final void Function(List<int>) onPatternComplete;
  const HeartPatternLock({super.key, required this.onPatternComplete});

  @override
  State<HeartPatternLock> createState() => _HeartPatternLockState();
}

class _HeartPatternLockState extends State<HeartPatternLock> {
  final List<int> _selected = [];
  Offset? _currentDrag;

  // Hit test: which dot is at local offset?
  int? _dotAt(Offset pos, Size size) {
    final double cellW = size.width / 3;
    final double cellH = size.height / 3;
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        final cx = (col + 0.5) * cellW;
        final cy = (row + 0.5) * cellH;
        final dist = (pos - Offset(cx, cy)).distance;
        if (dist < cellW * 0.4) {
          return row * 3 + col;
        }
      }
    }
    return null;
  }

  void _onPanStart(DragStartDetails d, Size size) {
    final idx = _dotAt(d.localPosition, size);
    if (idx != null) {
      setState(() {
        _selected.clear();
        _selected.add(idx);
        _currentDrag = d.localPosition;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails d, Size size) {
    final idx = _dotAt(d.localPosition, size);
    setState(() {
      _currentDrag = d.localPosition;
      if (idx != null && !_selected.contains(idx)) {
        _selected.add(idx);
      }
    });
  }

  void _onPanEnd(DragEndDetails d) {
    final result = List<int>.from(_selected);
    setState(() {
      _selected.clear();
      _currentDrag = null;
    });
    if (result.isNotEmpty) {
      widget.onPatternComplete(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (ctx, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: (d) => _onPanStart(d, size),
        onPanUpdate: (d) => _onPanUpdate(d, size),
        onPanEnd: _onPanEnd,
        child: CustomPaint(
          painter: _PatternPainter(
            selected: _selected,
            dragPoint: _currentDrag,
            size: size,
          ),
          child: _DotsGrid(selected: _selected, gridSize: size),
        ),
      );
    });
  }
}

// ── Dots drawn as a Stack of Positioned widgets ───────────────────────────────
class _DotsGrid extends StatelessWidget {
  final List<int> selected;
  final Size gridSize;
  const _DotsGrid({required this.selected, required this.gridSize});

  @override
  Widget build(BuildContext context) {
    final double cellW = gridSize.width / 3;
    final double cellH = gridSize.height / 3;
    const double dotSize = 52;

    return Stack(
      children: List.generate(9, (idx) {
        final row = idx ~/ 3;
        final col = idx % 3;
        final cx = (col + 0.5) * cellW;
        final cy = (row + 0.5) * cellH;
        final isOn = selected.contains(idx);

        return Positioned(
          left: cx - dotSize / 2,
          top: cy - dotSize / 2,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: dotSize,
            height: dotSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOn
                  ? Colors.pink.withOpacity(0.25)
                  : Colors.white.withOpacity(0.08),
              border: Border.all(
                color: isOn ? Colors.pinkAccent : Colors.white38,
                width: isOn ? 2.5 : 1.5,
              ),
              boxShadow: isOn
                  ? [
                      BoxShadow(
                        color: Colors.pinkAccent.withOpacity(0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              isOn ? Icons.favorite : Icons.favorite_border,
              color: isOn ? Colors.pinkAccent : Colors.white38,
              size: isOn ? 24 : 18,
            ),
          ),
        );
      }),
    );
  }
}

// ── Lines connecting drawn dots ───────────────────────────────────────────────
class _PatternPainter extends CustomPainter {
  final List<int> selected;
  final Offset? dragPoint;
  final Size size;

  const _PatternPainter({
    required this.selected,
    required this.dragPoint,
    required this.size,
  });

  Offset _center(int idx) {
    final double cellW = size.width / 3;
    final double cellH = size.height / 3;
    final row = idx ~/ 3;
    final col = idx % 3;
    return Offset((col + 0.5) * cellW, (row + 0.5) * cellH);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.pinkAccent.withOpacity(0.7)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < selected.length - 1; i++) {
      canvas.drawLine(_center(selected[i]), _center(selected[i + 1]), paint);
    }

    // Line from last dot to current finger position
    if (selected.isNotEmpty && dragPoint != null) {
      final lastPaint = Paint()
        ..color = Colors.pinkAccent.withOpacity(0.35)
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(_center(selected.last), dragPoint!, lastPaint);
    }
  }

  @override
  bool shouldRepaint(_PatternPainter old) =>
      old.selected != selected || old.dragPoint != dragPoint;
}
