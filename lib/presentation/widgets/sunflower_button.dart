import 'package:flutter/material.dart';
import 'package:rive/rive.dart' as rive;

class SunflowerButton extends StatelessWidget {
  const SunflowerButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100, // Explicit height to constrain Rive animation bounds
      child: const rive.RiveAnimation.asset(
        'assets/rive/sunflower-button.riv',
        fit: BoxFit.contain,
      ),
    );
  }
}
