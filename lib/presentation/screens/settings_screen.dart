import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/mood_theme.dart';
import '../theme_provider.dart';
import '../providers.dart';
import '../../core/responsive_utils.dart';
import 'icon_customization_screen.dart';
import 'clock_customization_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeMoodProvider);
    final wallpaperPath = ref.watch(wallpaperProvider).value;

    Future<void> pickWallpaper() async {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        ref.read(wallpaperProvider.notifier).setWallpaper(picked.path);
      }
    }

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: theme.backgroundColor,
        foregroundColor: theme.primaryColor,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0.sw(context)),
        children: [
          // Theme Selection Section
          Text(
            'APPEARANCE',
            style: TextStyle(
              color: theme.primaryColor.withOpacity(0.7),
              fontSize: 12.wsp(context),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5.sw(context),
            ),
          ),
          SizedBox(height: 8.sh(context)),
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
                    style: TextStyle(color: theme.primaryColor, fontSize: 16.wsp(context)),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: theme.secondaryColor)
                      : null,
                  onTap: () {
                    ref
                        .read(themeMoodProvider.notifier)
                        .setMood(currentMoodTheme.mood);
                  },
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 24.sh(context)),

          // Icon Style Selection Section
          Text(
            'ICON STYLE',
            style: TextStyle(
              color: theme.primaryColor.withOpacity(0.7),
              fontSize: 12.wsp(context),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5.sw(context),
            ),
          ),
          SizedBox(height: 8.sh(context)),
          ref
              .watch(iconStyleProvider)
              .when(
                data: (currentStyle) => Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12.sw(context)),
                    border: Border.all(
                      color: theme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: AppIconStyle.values.map((style) {
                      final isSelected = currentStyle == style;
                      return ListTile(
                        leading: Icon(
                          style == AppIconStyle.box
                              ? Icons.check_box_outline_blank
                              : Icons.circle_outlined,
                          color: theme.primaryColor,
                        ),
                        title: Text(
                          style == AppIconStyle.box
                              ? '3D Box (StyledAppIcon)'
                              : 'Circle (StyledAppIconTwo)',
                          style: TextStyle(color: theme.primaryColor, fontSize: 16.wsp(context)),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.radio_button_checked,
                                color: theme.secondaryColor,
                              )
                            : Icon(
                                Icons.radio_button_off,
                                color: theme.primaryColor.withOpacity(0.3),
                              ),
                        onTap: () {
                          ref.read(iconStyleProvider.notifier).setStyle(style);
                        },
                      );
                    }).toList(),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Text('Error loading style: $err'),
              ),

          SizedBox(height: 16.sh(context)),

          // Customization Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor.withOpacity(0.1),
              foregroundColor: theme.primaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: 20.sw(context),
                vertical: 16.sh(context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.sw(context)),
                side: BorderSide(
                  color: theme.primaryColor.withOpacity(0.3),
                ),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const IconCustomizationScreen(),
                ),
              );
            },
            icon: Icon(Icons.tune, size: 24.sw(context)),
            label: Text(
              "Advanced Customization",
              style: TextStyle(
                fontSize: 16.wsp(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          SizedBox(height: 16.sh(context)),

          // Clock Customization Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor.withOpacity(0.1),
              foregroundColor: theme.primaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: 20.sw(context),
                vertical: 16.sh(context),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.sw(context)),
                side: BorderSide(
                  color: theme.primaryColor.withOpacity(0.3),
                ),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ClockCustomizationScreen(),
                ),
              );
            },
            icon: Icon(Icons.access_time, size: 24.sw(context)),
            label: Text(
              "Clock Customization",
              style: TextStyle(
                fontSize: 16.wsp(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          SizedBox(height: 24.sh(context)),

          // ── Wallpaper Section ─────────────────────────────────────────

          Text(
            'WALLPAPER',
            style: TextStyle(
              color: theme.primaryColor.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 8.sh(context)),
          Container(
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                // Current wallpaper preview
                if (wallpaperPath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(12.sw(context)),
                    ),
                    child: SizedBox(
                      height: 120.sh(context),
                      width: double.infinity,
                      child: Image.file(
                        File(wallpaperPath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                // Pick image tile
                ListTile(
                  leading: Icon(Icons.wallpaper, color: theme.primaryColor),
                  title: Text(
                    wallpaperPath != null
                        ? 'Change Wallpaper'
                        : 'Set Wallpaper',
                    style: TextStyle(color: theme.primaryColor, fontSize: 16.wsp(context)),
                  ),
                  subtitle: Text(
                    'Applied to Home Screen & App Drawer',
                    style: TextStyle(
                      color: theme.primaryColor.withOpacity(0.6),
                      fontSize: 12.wsp(context),
                    ),
                  ),
                  trailing: Icon(
                    Icons.photo_library_outlined,
                    color: theme.primaryColor,
                  ),
                  onTap: pickWallpaper,
                ),
                // Clear wallpaper tile
                if (wallpaperPath != null)
                  ListTile(
                    leading: Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    title: const Text(
                      'Remove Wallpaper',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                    onTap: () {
                      ref.read(wallpaperProvider.notifier).clearWallpaper();
                    },
                  ),
              ],
            ),
          ),

          SizedBox(height: 24.sh(context)),

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
          SizedBox(height: 8.sh(context)),
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
                style: TextStyle(color: theme.primaryColor, fontSize: 16.wsp(context)),
              ),
              subtitle: Text(
                'Make Home-X your main home screen',
                style: TextStyle(
                  color: theme.primaryColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: theme.primaryColor,
                size: 16.sw(context),
              ),
              onTap: () {
                ref
                    .read(nativeAppServiceProvider)
                    .openDefaultLauncherSettings();
              },
            ),
          ),

          SizedBox(height: 12.sh(context)),

          // Customization Toggles
          Container(
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final showDock = ref.watch(dockVisibilityProvider).value ?? true;
                    return SwitchListTile(
                      secondary: Icon(Icons.dock, color: theme.primaryColor),
                      title: Text(
                        'Show Bottom Dock',
                        style: TextStyle(color: theme.primaryColor, fontSize: 16.wsp(context)),
                      ),
                      value: showDock,
                      activeColor: theme.secondaryColor,
                      onChanged: (value) {
                        ref.read(dockVisibilityProvider.notifier).setEnabled(value);
                      },
                    );
                  },
                ),
                Divider(color: theme.primaryColor.withOpacity(0.2), height: 1),
                Consumer(
                  builder: (context, ref, _) {
                    final showAddBtn = ref.watch(addButtonVisibilityProvider).value ?? true;
                    return SwitchListTile(
                      secondary: Icon(Icons.add_circle_outline, color: theme.primaryColor),
                      title: Text(
                        'Show Add Button',
                        style: TextStyle(color: theme.primaryColor, fontSize: 16.wsp(context)),
                      ),
                      value: showAddBtn,
                      activeColor: theme.secondaryColor,
                      onChanged: (value) {
                        ref.read(addButtonVisibilityProvider.notifier).setEnabled(value);
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 12.sh(context)),

          // Heart Animation Toggle
          Container(
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.primaryColor.withOpacity(0.2)),
            ),
            child: Consumer(
              builder: (context, ref, _) {
                final showHearts = ref.watch(heartAnimationProvider).value ?? true;
                return SwitchListTile(
                  secondary: Icon(Icons.favorite, color: theme.primaryColor),
                  title: Text(
                    'Heart Animation',
                    style: TextStyle(color: theme.primaryColor, fontSize: 16.wsp(context)),
                  ),
                  subtitle: Text(
                    'Show floating hearts on Home Screen',
                    style: TextStyle(
                      color: theme.primaryColor.withOpacity(0.7),
                      fontSize: 12.wsp(context),
                    ),
                  ),
                  value: showHearts,
                  activeColor: theme.secondaryColor,
                  onChanged: (value) {
                    ref.read(heartAnimationProvider.notifier).setEnabled(value);
                  },
                );
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
                style: TextStyle(color: theme.primaryColor, fontSize: 16.wsp(context)),
              ),
              subtitle: Text(
                'Version 1.0.0',
                style: TextStyle(color: theme.primaryColor.withOpacity(0.7)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
