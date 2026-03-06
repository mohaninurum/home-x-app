import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/mood_theme.dart';

class MoodNotifier extends Notifier<MoodTheme> {
  @override
  MoodTheme build() {
    _loadMood();
    return MoodTheme.romantic; // Default synchronous state
  }

  Future<void> _loadMood() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMood = prefs.getString('saved_mood');
    if (savedMood != null) {
      final mood = AppMood.values.firstWhere(
        (e) => e.toString() == savedMood,
        orElse: () => AppMood.romantic,
      );
      state = MoodTheme.values.firstWhere((t) => t.mood == mood);
    }
  }

  Future<void> setMood(AppMood newMood) async {
    state = MoodTheme.values.firstWhere((t) => t.mood == newMood);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_mood', newMood.toString());
  }
}

final themeMoodProvider = NotifierProvider<MoodNotifier, MoodTheme>(() {
  return MoodNotifier();
});
