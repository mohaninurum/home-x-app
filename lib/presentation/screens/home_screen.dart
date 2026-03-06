import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../widgets/floating_app_icon.dart';
import '../widgets/animated_hearts_background.dart';
import '../widgets/theme_selector_dialog.dart';
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
    Future.microtask(() => ref.read(nativeAppServiceProvider).startLockService());
  }

  @override
  Widget build(BuildContext context) {
    final appsAsyncValue = ref.watch(appsProvider);
    
    return Scaffold(
      body: Stack(
        children: [
          // 1. Dynamic Wallpaper with Drawing Support
          const GestureDrawingDetector(
            child: AnimatedHeartsBackground(),
          ),

          // 2. Gesture Detector for Workspace Level Gestures
          GestureDetector(
            onLongPress: () {
               showDialog(
                 context: context, 
                 builder: (context) => const ThemeSelectorDialog()
               );
            },
            onHorizontalDragEnd: (details) {
               if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
                 // Swipe Right -> Memory Timeline
                 Navigator.push(context, MaterialPageRoute(builder: (context) => const MemoryTimelineScreen()));
               }
            },
            onDoubleTap: () {
               // Double Tap configures entry into hidden space
               Navigator.push(context, MaterialPageRoute(builder: (context) => const HiddenAppsScreen()));
            },
            onVerticalDragEnd: (details) {
               if (details.primaryVelocity != null) {
                  if (details.primaryVelocity! < 0) {
                    // Swipe Up -> Couple Mode
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const CoupleModeScreen()));
                  } else if (details.primaryVelocity! > 1000) {
                    // Fast Swipe Down -> Secret Gallery
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SecretGalleryScreen()));
                  } else if (details.primaryVelocity! > 0) {
                    // Swipe Down -> Love App Drawer
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoveAppDrawer()));
                  }
               }
            },
            child: Container(color: Colors.transparent),
          ),
          
          // 3. Floating Icons Layout
          appsAsyncValue.when(
            data: (apps) {
              if (apps.isEmpty) {
                return const Center(child: Text("No apps found or lack permission", style: TextStyle(color: Colors.white)));
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
                  const Positioned(
                    bottom: 120,
                    left: 20,
                    right: 20,
                    child: Center(child: LoveQuoteWidget()),
                  ),
                  const Positioned(
                    top: 250,
                    left: 20,
                    child: CoupleGoalsWidget(),
                  ),
                  const Positioned(
                    top: 450,
                    right: 20,
                    child: LoveNotesWidget(),
                  ),
                  // Floating Draggable Apps
                  ...apps.map((app) => FloatingAppIcon(app: app)),

                  // Top level notification visualizer
                  const NotificationSimulationWidget(),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
            error: (err, stack) => Center(child: Text('Error loading apps: $err', style: const TextStyle(color: Colors.white))),
          ),
        ],
      ),
    );
  }
}
