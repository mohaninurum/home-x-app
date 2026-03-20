import 'dart:io';
import '../widgets/neo_moving_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/mood_theme.dart';
import '../theme_provider.dart';
import '../providers.dart';
import '../../core/responsive_utils.dart';
import 'icon_customization_screen.dart';
import 'clock_customization_screen.dart';
import '../../domain/clock_customization.dart';

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
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 16.wsp(context),
                    ),
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
                side: BorderSide(color: theme.primaryColor.withOpacity(0.3)),
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
                side: BorderSide(color: theme.primaryColor.withOpacity(0.3)),
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
                    style: TextStyle(
                      color: theme.primaryColor,
                      fontSize: 16.wsp(context),
                    ),
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
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 16.wsp(context),
                ),
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

          SizedBox(height: 24.sh(context)),

          // --- Home Screen Section ---
          Text(
            'HOME SCREEN',
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
              children: [
                // Add Button Toggle
                Consumer(
                  builder: (context, ref, _) {
                    final showAddBtn =
                        ref.watch(addButtonVisibilityProvider).value ?? true;
                    return SwitchListTile(
                      secondary: Icon(
                        Icons.add_circle_outline,
                        color: theme.primaryColor,
                      ),
                      title: Text(
                        'Show Add Button',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 16.wsp(context),
                        ),
                      ),
                      value: showAddBtn,
                      activeThumbColor: theme.secondaryColor,
                      onChanged: (value) {
                        ref
                            .read(addButtonVisibilityProvider.notifier)
                            .setEnabled(value);
                      },
                    );
                  },
                ),
                Divider(height: 1, color: theme.primaryColor.withOpacity(0.1)),
                // Heart Animation Toggle
                Consumer(
                  builder: (context, ref, _) {
                    final showHearts =
                        ref.watch(heartAnimationProvider).value ?? true;
                    return SwitchListTile(
                      secondary: Icon(
                        Icons.favorite,
                        color: theme.primaryColor,
                      ),
                      title: Text(
                        'Heart Animation',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 16.wsp(context),
                        ),
                      ),
                      subtitle: Text(
                        'Show floating hearts',
                        style: TextStyle(
                          color: theme.primaryColor.withOpacity(0.7),
                          fontSize: 12.wsp(context),
                        ),
                      ),
                      value: showHearts,
                      activeThumbColor: theme.secondaryColor,
                      onChanged: (value) {
                        ref
                            .read(heartAnimationProvider.notifier)
                            .setEnabled(value);
                      },
                    );
                  },
                ),
                Divider(height: 1, color: theme.primaryColor.withOpacity(0.1)),
                // Clock Visibility Toggle
                Consumer(
                  builder: (context, ref, _) {
                    final customization =
                        ref.watch(clockCustomizationProvider).value ??
                        const ClockCustomization();
                    return SwitchListTile(
                      secondary: Icon(
                        Icons.access_time,
                        color: theme.primaryColor,
                      ),
                      title: Text(
                        'Show Watch',
                        style: TextStyle(
                          color: theme.primaryColor,
                          fontSize: 16.wsp(context),
                        ),
                      ),
                      subtitle: Text(
                        'Display analog clock',
                        style: TextStyle(
                          color: theme.primaryColor.withOpacity(0.7),
                          fontSize: 12.wsp(context),
                        ),
                      ),
                      value: customization.showClock,
                      activeThumbColor: theme.secondaryColor,
                      onChanged: (value) {
                        ref
                            .read(clockCustomizationProvider.notifier)
                            .updateCustomization(
                              customization.copyWith(showClock: value),
                            );
                      },
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 24.sh(context)),

          // Home Screen Neo Border Section
          Text(
            'HOME SCREEN NEO BORDER',
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
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final neoSettings =
                        ref.watch(homeScreenNeoProvider).value ??
                        const HomeScreenNeoSettings();
                    return Column(
                      children: [
                        SwitchListTile(
                          secondary: Icon(
                            Icons.auto_awesome,
                            color: theme.primaryColor,
                          ),
                          title: Text(
                            'Enable Neo Border',
                            style: TextStyle(
                              color: theme.primaryColor,
                              fontSize: 16.wsp(context),
                            ),
                          ),
                          value: neoSettings.enabled,
                          activeThumbColor: theme.secondaryColor,
                          onChanged: (value) {
                            ref
                                .read(homeScreenNeoProvider.notifier)
                                .setEnabled(value);
                          },
                        ),
                        if (neoSettings.enabled) ...[
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Border Width: ${neoSettings.borderWidth.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontSize: 14.wsp(context),
                                  ),
                                ),
                                Slider(
                                  value: neoSettings.borderWidth,
                                  min: 1,
                                  max: 20,
                                  divisions: 19,
                                  activeColor: theme.secondaryColor,
                                  onChanged: (val) => ref
                                      .read(homeScreenNeoProvider.notifier)
                                      .setBorderWidth(val),
                                ),
                                SizedBox(height: 8.sh(context)),
                                Text(
                                  'Animation Speed: ${neoSettings.speed.toStringAsFixed(1)}',
                                  style: TextStyle(
                                    color: theme.primaryColor,
                                    fontSize: 14.wsp(context),
                                  ),
                                ),
                                Slider(
                                  value: neoSettings.speed,
                                  min: 0.5,
                                  max: 5.0,
                                  divisions: 45,
                                  activeColor: theme.secondaryColor,
                                  onChanged: (val) => ref
                                      .read(homeScreenNeoProvider.notifier)
                                      .setSpeed(val),
                                ),
                                SizedBox(height: 16.sh(context)),
                                // Preview
                                Text(
                                  'Preview',
                                  style: TextStyle(
                                    color: theme.primaryColor.withOpacity(0.7),
                                    fontSize: 12.wsp(context),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.sh(context)),
                                Center(
                                  child: Container(
                                    width: 200.sw(context),
                                    height: 120.sh(context),
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.black12,
                                    ),
                                    child: NeoMovingBorder(
                                      borderWidth: neoSettings.borderWidth,
                                      primaryColor: Color(
                                        neoSettings.primaryColorValue,
                                      ),
                                      secondaryColor: Color(
                                        neoSettings.secondaryColorValue,
                                      ),
                                      speed: neoSettings.speed,
                                      child: Center(
                                        child: Text(
                                          'PREVIEW',
                                          style: TextStyle(
                                            color: theme.primaryColor
                                                .withOpacity(0.5),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.sh(context)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 24.sh(context)),

          // Drawer Grid Size Section
          Text(
            'DRAWER SETTINGS',
            style: TextStyle(
              color: theme.primaryColor.withOpacity(0.7),
              fontSize: 12.wsp(context),
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5.sw(context),
            ),
          ),
          SizedBox(height: 8.sh(context)),
          ref
              .watch(gridSizeProvider)
              .when(
                data: (currentGridSize) => Container(
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12.sw(context)),
                    border: Border.all(
                      color: theme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [4, 5].map((size) {
                      final isSelected = currentGridSize == size;
                      return ListTile(
                        leading: Icon(
                          size == 4 ? Icons.grid_4x4 : Icons.grid_view,
                          color: theme.primaryColor,
                        ),
                        title: Text(
                          '$size × $size Grid',
                          style: TextStyle(
                            color: theme.primaryColor,
                            fontSize: 16.wsp(context),
                          ),
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
                          ref.read(gridSizeProvider.notifier).setGridSize(size);
                        },
                      );
                    }).toList(),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error loading grid size: $err'),
              ),

          SizedBox(height: 24.sh(context)),

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
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 16.wsp(context),
                ),
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
