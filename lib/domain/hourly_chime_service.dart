import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../presentation/providers.dart';

class HourlyChimeService {
  final FlutterTts _flutterTts = FlutterTts();
  final Ref ref;
  Timer? _timer;
  int _lastSpokenHour = -1;

  HourlyChimeService(this.ref) {
    _initTts();
    _startTimer();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("hi-IN");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  void _startTimer() {
    // Check the time every minute
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      
      // If it's the exact start of a new hour (0 minutes, 0 seconds)
      if (now.minute == 0 && now.second == 0) {
        // Prevent speaking multiple times for the same hour
        if (_lastSpokenHour != now.hour) {
          final isEnabled = ref.read(clockCustomizationProvider).value?.hourlyChimeEnabled ?? false;
          if (isEnabled) {
            _speakTime(now.hour);
          }
          _lastSpokenHour = now.hour;
        }
      }
    });
  }

  String _getHindiHourWord(int hour24) {
    int hour12 = hour24 % 12;
    if (hour12 == 0) hour12 = 12;

    const hindiNumbers = {
      1: "एक",
      2: "दो",
      3: "तीन",
      4: "चार",
      5: "पाँच",
      6: "छह",
      7: "सात",
      8: "आठ",
      9: "नौ",
      10: "दस",
      11: "ग्यारह",
      12: "बारह",
    };

    return hindiNumbers[hour12] ?? hour12.toString();
  }

  Future<void> _speakTime(int hour24) async {
    final customization = ref.read(clockCustomizationProvider).value;
    final speakType = customization?.speakType ?? SpeakType.hindi;
    final hindiWord = _getHindiHourWord(hour24);
    
    String text;
    if (speakType == SpeakType.rathvi) {
      text = "हिमी $hindiWord बज गया";
    } else {
      text = "अभी $hindiWord बज गए हैं";
    }
    
    await _flutterTts.speak(text);
  }

  void dispose() {
    _timer?.cancel();
    _flutterTts.stop();
  }
}

final hourlyChimeProvider = Provider<HourlyChimeService>((ref) {
  final service = HourlyChimeService(ref);
  ref.onDispose(() => service.dispose());
  return service;
});
