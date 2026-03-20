import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/mood_theme.dart';

class DynamicThemeModeNotifier extends Notifier<bool> {
  @override
  bool build() {
    _loadState();
    return false;
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('dynamic_theme_mode') ?? false;
  }

  void updateState(bool value) {
    state = value;
  }
}

final dynamicThemeModeProvider = NotifierProvider<DynamicThemeModeNotifier, bool>(() {
  return DynamicThemeModeNotifier();
});

class MoodNotifier extends Notifier<MoodTheme> {
  Timer? _timer;

  @override
  MoodTheme build() {
    _loadMood();
    
    ref.onDispose(() {
      _timer?.cancel();
    });

    return MoodTheme.romantic; // Default synchronous state
  }

  Future<void> _loadMood() async {
    final prefs = await SharedPreferences.getInstance();
    final isDynamic = prefs.getBool('dynamic_theme_mode') ?? false;

    if (isDynamic) {
        _startDynamicTimer();
        state = _getMoodForCurrentTime();
    } else {
      final savedMood = prefs.getString('saved_mood');
      if (savedMood != null) {
        final mood = AppMood.values.firstWhere(
          (e) => e.toString() == savedMood,
          orElse: () => AppMood.romantic,
        );
        state = MoodTheme.values.firstWhere((t) => t.mood == mood, orElse: () => MoodTheme.romantic);
      }
    }
  }

  void _startDynamicTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
       final newTheme = _getMoodForCurrentTime();
       if (state.mood != newTheme.mood) {
           state = newTheme;
       }
    });
  }

  MoodTheme _getMoodForCurrentTime() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return MoodTheme.morning;
    if (hour >= 12 && hour < 17) return MoodTheme.afternoon;
    if (hour >= 17 && hour < 20) return MoodTheme.evening;
    return MoodTheme.night;
  }

  Future<void> setDynamicMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dynamic_theme_mode', enabled);
    ref.read(dynamicThemeModeProvider.notifier).updateState(enabled);

    if (enabled) {
      state = _getMoodForCurrentTime();
      _startDynamicTimer();
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<void> setMood(AppMood newMood) async {
    state = MoodTheme.values.firstWhere((t) => t.mood == newMood);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_mood', newMood.toString());
    
    // Auto turn off dynamic themes when manually overridden
    await setDynamicMode(false);
  }
}

final themeMoodProvider = NotifierProvider<MoodNotifier, MoodTheme>(() {
  return MoodNotifier();
});
