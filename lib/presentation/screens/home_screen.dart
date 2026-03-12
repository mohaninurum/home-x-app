import 'dart:io';
import 'dart:ui';
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
import '../theme_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _drawerController;
  late Animation<Offset> _drawerOffset;
  bool _showAddWidgetButton = false;
  Offset _lastLongPressPos = Offset.zero;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _drawerOffset = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _drawerController, curve: Curves.easeOut),
        );
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
    _searchController.dispose();
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
            ref
                .read(homeAppsProvider.notifier)
                .addAppAt(details.data.packageName, localPos.dx, localPos.dy);
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
                  child: GestureDrawingDetector(
                    child: AnimatedHeartsBackground(),
                  ),
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
                        // Swipe UP
                        _toggleDrawer();
                      } else if (details.primaryVelocity! > 1000) {
                        // Fast Swipe DOWN
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SecretGalleryScreen(),
                          ),
                        );
                      } else if (details.primaryVelocity! > 0) {
                        // Swipe DOWN
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const CoupleModeScreen(),
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
                        final homeAppsList =
                            ref.watch(homeAppsListProvider).value ?? [];

                        final List<AppInfo> allFloatingApps = List.from(
                          homeAppsList,
                        );

                        // Compute initial placement for unset apps
                        final screenWidth = MediaQuery.of(context).size.width;
                        final screenHeight = MediaQuery.of(context).size.height;

                        final unsetApps = allFloatingApps
                            .where((a) => a.yPos <= 0)
                            .toList();
                        if (unsetApps.isNotEmpty) {
                          final totalWidth =
                              unsetApps.length * 60.0 +
                              (unsetApps.length - 1) *
                                  20; // 60 width + 20 margin
                          final startX = (screenWidth - totalWidth) / 2;
                          final dockY =
                              screenHeight - 170.0; // Dock vertical position

                          for (int i = 0; i < unsetApps.length; i++) {
                            unsetApps[i].xPos = startX + (i * 80.0);
                            unsetApps[i].yPos = dockY;
                          }
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
                                  final renderBox =
                                      context.findRenderObject() as RenderBox;
                                  final localPos = renderBox.globalToLocal(
                                    details.offset,
                                  );
                                  ref
                                      .read(widgetPositionProvider.notifier)
                                      .updatePosition('clock', localPos);
                                },
                                childWhenDragging: Opacity(
                                  opacity: 0.3,
                                  child: const RomanticClockWidget(),
                                ),
                                child: const RomanticClockWidget(),
                              ),
                            ),

                            // Bottom Dock Background and Add Button
                            Positioned(
                              bottom: 25,
                              left: 0,
                              right: 0,
                              child: Container(
                                height: 80,
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
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: Stack(
                                  children: [
                                    // Right-aligned Add Button inside Dock Background
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: GestureDetector(
                                        onTap: () =>
                                            _showAppPicker(isWidget: false),
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
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // All Floating Apps (Including initial dock apps)
                            for (var app in allFloatingApps)
                              FloatingAppIcon(
                                app: app,
                                isFloating: true,
                                showLabel: false,
                                onLongPress: () {
                                  final theme = ref.read(themeMoodProvider);
                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: theme.backgroundColor,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                    ),
                                    builder: (context) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ListTile(
                                            leading: Icon(
                                              Icons.delete_outline,
                                              color: theme.primaryColor,
                                            ),
                                            title: Text(
                                              "Remove from Home",
                                              style: TextStyle(
                                                color: theme.primaryColor,
                                              ),
                                            ),
                                            onTap: () {
                                              ref
                                                  .read(
                                                    homeAppsProvider.notifier,
                                                  )
                                                  .removeApp(app.packageName);
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                            // Top level notification visualizer
                            const NotificationSimulationWidget(),

                            // Dynamic App Widgets
                            ...ref
                                .watch(homeWidgetsProvider)
                                .when(
                                  data: (widgets) => widgets.map(
                                    (w) => Positioned(
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
                                        childWhenDragging:
                                            const SizedBox.shrink(),
                                        onDragEnd: (details) {
                                          final renderBox =
                                              context.findRenderObject()
                                                  as RenderBox;
                                          final localPos = renderBox
                                              .globalToLocal(details.offset);
                                          ref
                                              .read(
                                                homeWidgetsProvider.notifier,
                                              )
                                              .updatePosition(
                                                w.id,
                                                localPos.dx,
                                                localPos.dy,
                                              );
                                        },
                                        child: AppTileWidget(
                                          widgetData: w,
                                          onLongPress: () {
                                            _showWidgetOptions(w.id);
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
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
                                        Icon(
                                          Icons.add,
                                          color: Colors.pinkAccent,
                                        ),
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

                // Search Bar & Settings
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 20,
                  right: 20,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(40),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white.withAlpha(50),
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value.toLowerCase();
                                _isSearching = value.isNotEmpty;
                              });
                            },
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: "Search apps...",
                              hintStyle: TextStyle(
                                color: Colors.white.withAlpha(150),
                              ),
                              prefixIcon: const Icon(
                                Icons.search,
                                color: Colors.white70,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                              ),
                              suffixIcon: _isSearching
                                  ? IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white70,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isSearching = false;
                                          _searchQuery = "";
                                          _searchController.clear();
                                        });
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white70),
                        onPressed: () {
                          Navigator.pushNamed(context, '/settings');
                        },
                      ),
                    ],
                  ),
                ),

                // Search Results Overlay
                if (_isSearching)
                  Positioned.fill(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _isSearching = false;
                          _searchQuery = "";
                          _searchController.clear();
                        });
                      },
                      child: Container(
                        color: Colors.black26,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Column(
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).padding.top + 65,
                              ),
                              Expanded(
                                child: Consumer(
                                  builder: (context, ref, _) {
                                    final allApps =
                                        ref.watch(appsProvider).value ?? [];
                                    final results = allApps
                                        .where(
                                          (app) => app.label
                                              .toLowerCase()
                                              .contains(_searchQuery),
                                        )
                                        .toList();

                                    if (results.isEmpty) {
                                      return const Center(
                                        child: Text(
                                          "No apps found",
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                          ),
                                        ),
                                      );
                                    }

                                    return ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      itemCount: results.length,
                                      itemBuilder: (context, index) {
                                        final app = results[index];
                                        return ListTile(
                                          leading: SizedBox(
                                            width: 40,
                                            height: 40,
                                            child: AppIconContent(
                                              app: app,
                                              showLabel: false,
                                              size: 40,
                                            ),
                                          ),
                                          title: Text(
                                            app.label,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          onTap: () {
                                            ref
                                                .read(nativeAppServiceProvider)
                                                .launchApp(app.packageName);
                                            setState(() {
                                              _isSearching = false;
                                              _searchQuery = "";
                                              _searchController.clear();
                                            });
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 30,
                    ),
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
      final isPhotos =
          app.label.toLowerCase().contains('photo') ||
          app.packageName.toLowerCase().contains('gallery') ||
          app.packageName.toLowerCase().contains('photos');

      if (isPhotos) {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          photoPath = pickedFile.path;
        }
      }

      ref
          .read(homeWidgetsProvider.notifier)
          .addWidget(
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
