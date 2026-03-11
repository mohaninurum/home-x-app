import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mood_theme.dart';
import '../theme_provider.dart';

import '../providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeMoodProvider);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.backgroundColor,
        foregroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Selection Section
          Text(
            'APPEARANCE',
            style: TextStyle(
              color: theme.primaryColor.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
            ),
            child: Column(
              children: MoodTheme.values.map((currentMoodTheme) {
                final isSelected = theme.mood == currentMoodTheme.mood;
                return ListTile(
                  leading: Icon(
                    Icons.favorite,
                    color: currentMoodTheme.primaryColor,
                  ),
                  title: Text(
                    currentMoodTheme.title,
                    style: TextStyle(color: theme.primaryColor),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: theme.secondaryColor)
                      : null,
                  onTap: () {
                    ref.read(themeMoodProvider.notifier).setMood(currentMoodTheme.mood);
                  },
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 24),

          // System Settings Section
          Text(
            'SYSTEM',
            style: TextStyle(
              color: theme.primaryColor.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
            ),
            child: ListTile(
              leading: Icon(Icons.home_filled, color: theme.primaryColor),
              title: Text(
                'Set Default Launcher',
                style: TextStyle(color: theme.primaryColor),
              ),
              subtitle: Text(
                'Make Home-X your main home screen',
                style: TextStyle(color: theme.primaryColor.withOpacity(0.7), fontSize: 12),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: theme.primaryColor, size: 16),
              onTap: () {
                ref.read(nativeAppServiceProvider).openDefaultLauncherSettings();
              },
            ),
          ),
          
          // Future settings placeholders can go here
          Text(
            'ABOUT',
            style: TextStyle(
              color: theme.primaryColor.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
            ),
            child: ListTile(
              leading: Icon(Icons.info_outline, color: theme.primaryColor),
              title: Text(
                'Home-X App',
                style: TextStyle(color: theme.primaryColor),
              ),
              subtitle: Text(
                'Version 1.0.0',
                style: TextStyle(color: theme.primaryColor.withOpacity(0.7)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
