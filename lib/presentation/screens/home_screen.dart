import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../providers.dart';
import '../../domain/app_info.dart';
import '../widgets/floating_app_icon.dart';
import '../widgets/animated_hearts_background.dart';
import '../widgets/romantic_clock_widget.dart';
import '../widgets/notification_simulation_widget.dart';
import 'hidden_apps_screen.dart';
import 'couple_mode_screen.dart';
import 'memory_timeline_screen.dart';
import 'love_app_drawer.dart';
import 'secret_gallery_screen.dart';
import 'settings_screen.dart';
import '../widgets/gesture_drawing_detector.dart';
import '../widgets/app_tile_widget.dart';
import 'app_picker_dialog.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _drawerController;
  late Animation<Offset> _drawerOffset;
  bool _showAddWidgetButton = false;
  Offset _lastLongPressPos = Offset.zero;

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _drawerOffset = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _drawerController,
      curve: Curves.easeOut,
    ));
  }

  void _toggleDrawer() {
    if (_drawerController.isCompleted) {
      _drawerController.reverse();
    } else {
      _drawerController.forward();
    }
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appsAsyncValue = ref.watch(appsProvider);
    final wallpaperPath = ref.watch(wallpaperProvider).value;
    final widgetPositions = ref.watch(widgetPositionProvider).value ?? {};

    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_drawerController.isCompleted) {
            _toggleDrawer();
          }
        },
        child: DragTarget<AppInfo>(
        onAcceptWithDetails: (details) {
          final renderBox = context.findRenderObject() as RenderBox;
          final localPos = renderBox.globalToLocal(details.offset);
          ref.read(homeAppsProvider.notifier).addAppAt(
                details.data.packageName,
                localPos.dx,
                localPos.dy,
              );
        },
        builder: (context, candidateData, rejectedData) {
          return Stack(
            children: [
              // 0. Custom Wallpaper (Base Layer)
              if (wallpaperPath != null)
                Positioned.fill(
                  child: Image.file(File(wallpaperPath), fit: BoxFit.cover),
                ),

              // 1. Dynamic Wallpaper with Drawing Support
              const Positioned.fill(
                child: GestureDrawingDetector(child: AnimatedHeartsBackground()),
              ),

              // 2. Gesture Detector for Workspace Level Gestures
              GestureDetector(
                onLongPress: () {}, // Handled by LongPressDetails
                onLongPressStart: (details) {
                  setState(() {
                    _lastLongPressPos = details.localPosition;
                    _showAddWidgetButton = true;
                  });
                },
                onTap: () {
                  if (_showAddWidgetButton) {
                    setState(() {
                      _showAddWidgetButton = false;
                    });
                  }
                },
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! > 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MemoryTimelineScreen(),
                      ),
                    );
                  }
                },
                onDoubleTap: () {
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CoupleModeScreen(),
                        ),
                      );
                    } else if (details.primaryVelocity! > 1000) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SecretGalleryScreen(),
                        ),
                      );
                    } else if (details.primaryVelocity! > 0) {
                      _toggleDrawer();
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
                      final homeAppsList = ref.watch(homeAppsListProvider).value ?? [];

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
                          // Draggable Romantic Clock
                          Positioned(
                            top: widgetPositions['clock']?.dy ?? 80,
                            left: widgetPositions['clock']?.dx ?? 20,
                            child: Draggable(
                              feedback: Material(
                                color: Colors.transparent,
                                child: Opacity(
                                  opacity: 0.7,
                                  child: const RomanticClockWidget(),
                                ),
                              ),
                              onDragEnd: (details) {
                                final renderBox = context.findRenderObject() as RenderBox;
                                final localPos = renderBox.globalToLocal(details.offset);
                                ref.read(widgetPositionProvider.notifier).updatePosition('clock', localPos);
                              },
                              childWhenDragging: Opacity(
                                opacity: 0.3,
                                child: const RomanticClockWidget(),
                              ),
                              child: const RomanticClockWidget(),
                            ),
                          ),

                          // Floating Apps
                          for (var app in floatingApps)
                            FloatingAppIcon(app: app, isFloating: true),

                          // Bottom Dock
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
                                    onTap: () => _showAppPicker(isWidget: false),
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

                          // Dynamic App Widgets
                          ...ref.watch(homeWidgetsProvider).when(
                                data: (widgets) => widgets.map((w) => Positioned(
                                      left: w.x,
                                      top: w.y,
                                      child: Draggable(
                                        feedback: Material(
                                          color: Colors.transparent,
                                          child: Opacity(
                                            opacity: 0.7,
                                            child: AppTileWidget(widgetData: w),
                                          ),
                                        ),
                                        childWhenDragging: const SizedBox.shrink(),
                                        onDragEnd: (details) {
                                          final renderBox = context.findRenderObject() as RenderBox;
                                          final localPos = renderBox.globalToLocal(details.offset);
                                          ref.read(homeWidgetsProvider.notifier).updatePosition(w.id, localPos.dx, localPos.dy);
                                        },
                                        child: AppTileWidget(
                                          widgetData: w,
                                          onLongPress: () {
                                            _showWidgetOptions(w.id);
                                          },
                                        ),
                                      ),
                                    )),
                                loading: () => [],
                                error: (_, __) => [],
                              ),

                          // Add Widget Button
                          if (_showAddWidgetButton)
                            Positioned(
                              left: _lastLongPressPos.dx - 60,
                              top: _lastLongPressPos.dy - 25,
                              child: GestureDetector(
                                onTap: () => _showAppPicker(isWidget: true),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(50),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.add, color: Colors.pinkAccent),
                                      SizedBox(width: 8),
                                      Text(
                                        "Add Widget",
                                        style: TextStyle(
                                          color: Colors.pinkAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
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

              // All Apps Button
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: _toggleDrawer,
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

              // Settings Button
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
                
              SlideTransition(
                position: _drawerOffset,
                child: LoveAppDrawer(onClose: _toggleDrawer),
              ),
            ],
          );
        },
      ),
    ),
  );
}

  void _showAppPicker({required bool isWidget}) async {
    final packageName = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AppPickerDialog(),
    );

    if (packageName != null) {
      if (!isWidget) {
        // Simple app addition
        ref.read(homeAppsProvider.notifier).addApp(packageName);
        return;
      }

      String? photoPath;
      
      // Check if it's a photos app to prompt for an image
      final apps = ref.read(appsProvider).value ?? [];
      final app = apps.firstWhere((a) => a.packageName == packageName);
      final isPhotos = app.label.toLowerCase().contains('photo') ||
          app.packageName.toLowerCase().contains('gallery') ||
          app.packageName.toLowerCase().contains('photos');

      if (isPhotos) {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          photoPath = pickedFile.path;
        }
      }

      ref.read(homeWidgetsProvider.notifier).addWidget(
            packageName,
            _lastLongPressPos.dx - 80,
            _lastLongPressPos.dy - 80,
            imagePath: photoPath,
          );
      setState(() {
        _showAddWidgetButton = false;
      });
    }
  }

void _showWidgetOptions(String id) {
  showModalBottomSheet(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Remove Widget'),
            onTap: () {
              ref.read(homeWidgetsProvider.notifier).removeWidget(id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}
}
