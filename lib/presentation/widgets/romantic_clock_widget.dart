import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/responsive_utils.dart';

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
      padding: EdgeInsets.symmetric(horizontal: 20.sw(context), vertical: 15.sw(context)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.sw(context)),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.3), width: 1.5.sw(context)),
        boxShadow: [
           BoxShadow(color: Colors.black12, blurRadius: 10.sw(context), offset: Offset(0, 5.sw(context)))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "${_formatTime(_now.hour)}:${_formatTime(_now.minute)}",
            style: TextStyle(
              fontSize: 48.wsp(context),
              fontWeight: FontWeight.w300,
              color: Colors.white,
              letterSpacing: 2.0.sw(context),
              shadows: [Shadow(color: Colors.pinkAccent, blurRadius: 15.sw(context))],
            ),
          ),
          SizedBox(height: 5.sw(context)),
          Text(
            "Time spent loving you.",
            style: TextStyle(
              fontSize: 12.wsp(context),
              fontStyle: FontStyle.italic,
              color: Colors.white70,
            ),
          )
        ],
      ),
    );
  }
}
