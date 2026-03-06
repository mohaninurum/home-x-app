import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mood_theme.dart';
import '../theme_provider.dart';

class ThemeSelectorDialog extends ConsumerWidget {
  const ThemeSelectorDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeMoodProvider);

    return AlertDialog(
      backgroundColor: currentTheme.backgroundColor,
      title: Text("Select Relationship Mood", style: TextStyle(color: currentTheme.primaryColor)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: MoodTheme.values.map((theme) {
            return ListTile(
              leading: Icon(
                Icons.favorite,
                color: theme.primaryColor,
              ),
              title: Text(theme.title, style: TextStyle(color: currentTheme.primaryColor)),
              trailing: currentTheme.mood == theme.mood 
                  ? Icon(Icons.check, color: theme.secondaryColor) 
                  : null,
              onTap: () {
                ref.read(themeMoodProvider.notifier).setMood(theme.mood);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
