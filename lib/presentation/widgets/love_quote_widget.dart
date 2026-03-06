import 'package:flutter/material.dart';
import 'dart:math';

class LoveQuoteWidget extends StatefulWidget {
  const LoveQuoteWidget({super.key});

  @override
  State<LoveQuoteWidget> createState() => _LoveQuoteWidgetState();
}

class _LoveQuoteWidgetState extends State<LoveQuoteWidget> {
  final List<String> _quotes = [
    "Every moment with you feels like a beautiful dream.",
    "I love you more than words can say.",
    "You are my today and all of my tomorrows.",
    "Together is my favorite place to be.",
    "I look at you and see the rest of my life in front of my eyes.",
    "You're the closest to heaven that I'll ever be.",
    "I am entirely yours.",
    "Even when we are apart, I am always with you.",
    "My heart is and always will be yours.",
    "I love you more than I have ever found a way to say to you.",
  ];

  late String _currentQuote;

  @override
  void initState() {
    super.initState();
    _currentQuote = _quotes[Random().nextInt(_quotes.length)];
  }

  void _nextQuote() {
    setState(() {
      _currentQuote = _quotes[Random().nextInt(_quotes.length)];
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _nextQuote,
      child: Container(
        width: 250,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.pink.shade50.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4)
            )
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.format_quote, color: Colors.pinkAccent, size: 24),
            const SizedBox(height: 8),
            Text(
              _currentQuote,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.pink,
                fontSize: 14,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "– AI Love Quote Generator",
              style: TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
