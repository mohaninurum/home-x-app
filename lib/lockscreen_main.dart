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

class LoveLockScreen extends StatefulWidget {
  const LoveLockScreen({super.key});

  @override
  State<LoveLockScreen> createState() => _LoveLockScreenState();
}

class _LoveLockScreenState extends State<LoveLockScreen> {
  static const MethodChannel _channel = MethodChannel('com.example.homexapp/lockscreen');
  final List<int> _pattern = [];
  final List<int> _correctPattern = [0, 1, 2, 5, 8]; // Example "L" shape pattern

  void _onPatternComplete(List<int> drawnPattern) {
    bool isMatch = true;
    if (drawnPattern.length != _correctPattern.length) {
      isMatch = false;
    } else {
      for (int i = 0; i < drawnPattern.length; i++) {
        if (drawnPattern[i] != _correctPattern[i]) {
          isMatch = false;
          break;
        }
      }
    }

    if (isMatch) {
      _unlockDevice();
    } else {
      setState(() {
        _pattern.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Incorrect Pattern. Try again! 💔", textAlign: TextAlign.center),
        backgroundColor: Colors.redAccent,
      ));
    }
  }

  Future<void> _unlockDevice() async {
    try {
      await _channel.invokeMethod('unlock');
    } catch (e) {
      // Ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // A dark base, can be couple photo
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Placeholder (Could load image from SharedPreferences in full version)
          ColorFiltered(
            colorFilter: ColorFilter.mode(Colors.pink.withOpacity(0.3), BlendMode.srcOver),
            child: Image.network(
              "https://images.unsplash.com/photo-1518199266791-5375a83190b7?q=80&w=1000",
              fit: BoxFit.cover,
            ),
          ),
          
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black54, Colors.transparent, Colors.black87],
              ),
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const SizedBox(height: 50),
              // Greeting
              const Text(
                "❤️ Good Morning My Love",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  shadows: [Shadow(color: Colors.pink, blurRadius: 10)],
                ),
              ),
              const Spacer(),
              
              // Custom Heart Pattern Element
              SizedBox(
                height: 350,
                width: 350,
                child: HeartPatternLock(
                  onPatternComplete: _onPatternComplete,
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ],
      ),
    );
  }
}

// Simple Pattern Lock implementation visually using Heart Icons
class HeartPatternLock extends StatefulWidget {
  final Function(List<int>) onPatternComplete;

  const HeartPatternLock({super.key, required this.onPatternComplete});

  @override
  State<HeartPatternLock> createState() => _HeartPatternLockState();
}

class _HeartPatternLockState extends State<HeartPatternLock> {
  final List<int> _selectedDots = [];
  final GlobalKey _gridKey = GlobalKey();
  
  void _handlePan(Offset position) {
    final RenderBox? renderBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    // Simplistic hit testing
    final double cellWidth = renderBox.size.width / 3;
    final double cellHeight = renderBox.size.height / 3;
    
    int col = (position.dx / cellWidth).floor();
    int row = (position.dy / cellHeight).floor();
    
    if (col >= 0 && col < 3 && row >= 0 && row < 3) {
      int index = row * 3 + col;
      if (!_selectedDots.contains(index)) {
        setState(() {
          _selectedDots.add(index);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => _handlePan(details.localPosition),
      onPanUpdate: (details) => _handlePan(details.localPosition),
      onPanEnd: (details) {
        widget.onPatternComplete(List.from(_selectedDots));
        setState(() {
          _selectedDots.clear();
        });
      },
      child: Container(
        key: _gridKey,
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 30,
            mainAxisSpacing: 30,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            bool isSelected = _selectedDots.contains(index);
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.pink.withOpacity(0.3) : Colors.transparent,
                border: Border.all(
                  color: isSelected ? Colors.pinkAccent : Colors.white54,
                  width: isSelected ? 3 : 1,
                )
              ),
              child: isSelected 
                ? const Icon(Icons.favorite, color: Colors.pinkAccent, size: 24)
                : const Icon(Icons.favorite_border, color: Colors.white54, size: 16),
            );
          },
        ),
      ),
    );
  }
}
