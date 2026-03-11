import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../../domain/app_info.dart';
import '../widgets/floating_app_icon.dart';
import '../widgets/animated_hearts_background.dart';

import '../widgets/romantic_clock_widget.dart';
import '../widgets/love_quote_widget.dart';
import '../widgets/couple_goals_widget.dart';
import '../widgets/love_notes_widget.dart';
import '../widgets/notification_simulation_widget.dart';
import 'hidden_apps_screen.dart';
import 'couple_mode_screen.dart';
import 'memory_timeline_screen.dart';
import 'love_app_drawer.dart';
import 'secret_gallery_screen.dart';
import 'settings_screen.dart';
import '../widgets/gesture_drawing_detector.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Start native lock screen listening service when launcher boots
    // Future.microtask(
    //   () => ref.read(nativeAppServiceProvider).startLockService(),
    // );
  }

  @override
  Widget build(BuildContext context) {
    final appsAsyncValue = ref.watch(appsProvider);
    final wallpaperPath = ref.watch(wallpaperProvider).value;

    return Scaffold(
      body: Stack(
        children: [
          // 0. Custom Wallpaper (Base Layer)
          if (wallpaperPath != null)
            Positioned.fill(
              child: Image.file(File(wallpaperPath), fit: BoxFit.cover),
            ),

          // 1. Dynamic Wallpaper with Drawing Support
          const GestureDrawingDetector(child: AnimatedHeartsBackground()),

          // 2. Gesture Detector for Workspace Level Gestures
          GestureDetector(
            onLongPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! > 0) {
                // Swipe Right -> Memory Timeline
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MemoryTimelineScreen(),
                  ),
                );
              }
            },
            onDoubleTap: () {
              // Double Tap configures entry into hidden space
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HiddenAppsScreen(),
                ),
              );
            },
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null) {
                if (details.primaryVelocity! < 0) {
                  // Swipe Up -> Couple Mode
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CoupleModeScreen(),
                    ),
                  );
                } else if (details.primaryVelocity! > 1000) {
                  // Fast Swipe Down -> Secret Gallery
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SecretGalleryScreen(),
                    ),
                  );
                } else if (details.primaryVelocity! > 0) {
                  // Swipe Down -> Love App Drawer
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoveAppDrawer(),
                    ),
                  );
                }
              }
            },
            child: Container(color: Colors.transparent),
          ),

          // 3. Floating Icons and Widgets Layout
          appsAsyncValue.when(
            data: (allApps) {
              return Consumer(
                builder: (context, ref, _) {
                  final homeAppsNames = ref.watch(homeAppsProvider).value ?? {};
                  final homeAppsList =
                      ref.watch(homeAppsListProvider).value ?? [];

                  // Logic: If no home apps selected, default to first 4 from all apps for dock
                  // If home apps selected: first 4 go to dock, others are floating
                  final List<AppInfo> dockApps;
                  final List<AppInfo> floatingApps;

                  if (homeAppsNames.isEmpty) {
                    dockApps = allApps.take(4).toList();
                    floatingApps = [];
                  } else {
                    dockApps = homeAppsList.take(4).toList();
                    floatingApps = homeAppsList.length > 4
                        ? homeAppsList.sublist(4)
                        : [];
                  }

                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Base Romantic Widgets
                      const Positioned(
                        top: 80,
                        left: 20,
                        right: 20,
                        child: Center(child: RomanticClockWidget()),
                      ),
                      // const Positioned(
                      //   bottom: 220, // Adjusted for dock
                      //   left: 20,
                      //   right: 20,
                      //   child: Center(child: LoveQuoteWidget()),
                      // ),
                      // const Positioned(
                      //   top: 250,
                      //   left: 20,
                      //   child: CoupleGoalsWidget(),
                      // ),
                      // const Positioned(
                      //   top: 450,
                      //   right: 20,
                      //   child: LoveNotesWidget(),
                      // ),

                      // Floating Apps
                      for (var app in floatingApps)
                        FloatingAppIcon(app: app, isFloating: true),

                      // Bottom Dock (Managed Apps)
                      Positioned(
                        bottom: 95,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withAlpha(30),
                            ),
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              for (var app in dockApps)
                                SizedBox(
                                  width: 60,
                                  height: 90,
                                  child: FloatingAppIcon(
                                    app: app,
                                    isFloating: false,
                                    onLongPress: () {
                                      ref
                                          .read(homeAppsProvider.notifier)
                                          .removeApp(app.packageName);
                                    },
                                  ),
                                ),

                              // Add Button
                              GestureDetector(
                                onTap: () async {
                                  final selected = await showDialog<AppInfo>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text("Add to Home"),
                                      backgroundColor: Theme.of(
                                        context,
                                      ).cardColor,
                                      content: SizedBox(
                                        width: double.maxFinite,
                                        height: 350,
                                        child: ListView.builder(
                                          itemCount: allApps.length,
                                          itemBuilder: (context, index) {
                                            final app = allApps[index];
                                            if (homeAppsNames.contains(
                                              app.packageName,
                                            ))
                                              return const SizedBox.shrink();
                                            return ListTile(
                                              leading: Image.memory(
                                                app.iconBytes,
                                                width: 32,
                                              ),
                                              title: Text(app.label),
                                              onTap: () =>
                                                  Navigator.pop(context, app),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                  if (selected != null) {
                                    ref
                                        .read(homeAppsProvider.notifier)
                                        .addApp(selected.packageName);
                                  }
                                },
                                child: Container(
                                  width: 55,
                                  height: 55,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(40),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Top level notification visualizer
                      const NotificationSimulationWidget(),
                    ],
                  );
                },
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
            error: (err, _) => Center(
              child: Text(
                'Error: $err',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),

          // All Apps Button (Bottom-Center, above Dock)
          Positioned(
            bottom: 20, // Positioned above the dock
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoveAppDrawer(),
                    ),
                  );
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(80),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withAlpha(30),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.apps, color: Colors.white, size: 32),
                ),
              ),
            ),
          ),

          // Settings Button (Top-Right)
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 30),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
