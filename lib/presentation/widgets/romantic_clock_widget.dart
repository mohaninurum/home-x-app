import 'package:flutter/material.dart';
import 'dart:async';

class RomanticClockWidget extends StatefulWidget {
  const RomanticClockWidget({super.key});

  @override
  State<RomanticClockWidget> createState() => _RomanticClockWidgetState();
}

class _RomanticClockWidgetState extends State<RomanticClockWidget> {
  late Timer _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _now = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 1.5),
        boxShadow: const [
           BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${_formatTime(_now.hour)}:${_formatTime(_now.minute)}",
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 2.0,
              shadows: [Shadow(color: Colors.pinkAccent, blurRadius: 15)],
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Time spent loving you.",
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.white70,
            ),
          )
        ],
      ),
    );
  }
}
