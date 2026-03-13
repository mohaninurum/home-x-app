import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers.dart';
import '../../domain/app_info.dart';
import '../../domain/hourly_chime_service.dart';
import 'package:rive/rive.dart' as rive;
import '../widgets/floating_app_icon.dart';
import '../widgets/animated_hearts_background.dart';
import '../widgets/custom_analog_clock_widget.dart';
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
import '../../core/responsive_utils.dart';

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
    final isEditMode = ref.watch(editModeProvider);
    final isDockVisible = ref.watch(dockVisibilityProvider).value ?? true;
    final isAddButtonVisible =
        ref.watch(addButtonVisibilityProvider).value ?? true;

    // Initialize the hourly chime service to listen in the background
    ref.watch(hourlyChimeProvider);

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

                        // Dock app layout logic coordinates
                        final screenWidth = MediaQuery.of(context).size.width;
                        final screenHeight = MediaQuery.of(context).size.height;
                        final dockThresholdY = screenHeight - 150.sh(context);

                        // Capture unset apps or previously misaligned dock apps (those sitting above dock)
                        // This absorbs any floating app near the dock into a clean layout
                        final dockApps = allFloatingApps
                            .where(
                              (a) =>
                                  a.yPos <= 0 ||
                                  (isDockVisible && a.yPos > dockThresholdY),
                            )
                            .toList();

                        if (dockApps.isNotEmpty) {
                          // Sort by existing X to maintain visual order
                          dockApps.sort((a, b) => a.xPos.compareTo(b.xPos));

                          final dockMargin = 20.sw(context);
                          final dockPadding = 15.sw(context);
                          final plusBtnWidth = 55.sh(
                            context,
                          ); // Fixed circular shape
                          final iconSize = 48.0.sw(context);

                          // Calculate the exact center of the space dedicated for apps
                          final appAreaStartX = dockMargin + dockPadding;
                          final appAreaEndX =
                              screenWidth -
                              dockMargin -
                              dockPadding -
                              plusBtnWidth -
                              10.sw(context);
                          final appAreaWidth = appAreaEndX - appAreaStartX;

                          final double spacing = dockApps.length > 3
                              ? 10.sw(context)
                              : 20.sw(context);
                          final double totalWidth =
                              dockApps.length * iconSize +
                              (dockApps.length - 1) * spacing;

                          final startX =
                              appAreaStartX + (appAreaWidth - totalWidth) / 2;
                          final dockY =
                              screenHeight -
                              91.0.sh(context); // Exact vertical center of dock

                          for (int i = 0; i < dockApps.length; i++) {
                            dockApps[i].xPos =
                                startX + (i * (iconSize + spacing));
                            dockApps[i].yPos = dockY;
                          }
                        }

                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            // Draggable Custom Clock
                            Positioned(
                              top: widgetPositions['clock']?.dy ?? 8,
                              left: widgetPositions['clock']?.dx ?? 20,
                              child: Draggable(
                                maxSimultaneousDrags: isEditMode ? 1 : 0,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: Opacity(
                                    opacity: 0.7,
                                    child: const CustomAnalogClockWidget(),
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
                                  child: const CustomAnalogClockWidget(),
                                ),
                                child: const CustomAnalogClockWidget(),
                              ),
                            ),

                            // Bottom Dock Background and Add Button
                            // --- Floating Widgets ---
                            Positioned(
                              bottom: 30,
                              left: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _toggleDrawer,
                                child: SizedBox(
                                  height:
                                      100, // Explicit height to constrain Rive animation bounds
                                  child: rive.RiveAnimation.asset(
                                    'assets/rive/sunflower-button.riv',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),

                            if (isDockVisible)
                              Positioned(
                                bottom: 25.sh(context),
                                left: 0,
                                right: 0,
                                child: DragTarget<AppInfo>(
                                  onWillAccept: (data) => data != null,
                                  onAccept: (data) async {
                                    // Snapping logic: align to center of dock
                                    final dockHeight = 80.sh(context);
                                    final iconSize = 52.sw(context);
                                    final dockTop =
                                        screenHeight - 105.sh(context);
                                    final snappedY =
                                        dockTop + (dockHeight - iconSize) / 2;

                                    // Find current x position relative to screen
                                    // For now, keep the drop xpos but snap y
                                    // In a more advanced version, we'd calculate grid cells inside the dock

                                    // Since FloatingAppIcon handles its own state for dragging on home_screen currently,
                                    // we might need to trigger a refresh or update provider.
                                    // However, the simple fix is to ensure the app state is updated.
                                    data.yPos = snappedY;

                                    // Persist
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setDouble(
                                      '${data.packageName}_y',
                                      snappedY,
                                    );

                                    // Trigger rebuild of icons
                                    // ref.invalidate(homeAppsListProvider); // Removed to prevent circular dependency
                                  },
                                  builder: (context, candidateData, rejectedData) {
                                    return Container(
                                      height: 75.sh(context),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 10.sh(context),
                                        horizontal: 15.sw(context),
                                      ),
                                      decoration: BoxDecoration(
                                        color: candidateData.isNotEmpty
                                            ? Colors.white.withAlpha(50)
                                            : Colors.white.withAlpha(25),
                                        borderRadius: BorderRadius.circular(
                                          25.sw(context),
                                        ),
                                        border: Border.all(
                                          color: candidateData.isNotEmpty
                                              ? Colors.white.withAlpha(60)
                                              : Colors.white.withAlpha(30),
                                          width: candidateData.isNotEmpty
                                              ? 2.0
                                              : 1.0,
                                        ),
                                      ),
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 20.sw(context),
                                      ),
                                      child: Stack(
                                        children: [
                                          // Placeholder or internal dock content could go here
                                        ],
                                      ),
                                    );
                                  },
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
                                        maxSimultaneousDrags: isEditMode
                                            ? 1
                                            : 0,
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
                  top: MediaQuery.of(context).padding.top + 10.sh(context),
                  left: 20.sw(context),
                  right: 60.sw(context),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          width: 20.sh(context),
                          height: 38.sh(context),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(5),
                            borderRadius: BorderRadius.circular(25.sw(context)),
                            border: Border.all(
                              color: Colors.white.withAlpha(30),
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
                              hintText: "Search",
                              hintStyle: TextStyle(
                                color: Colors.white.withAlpha(100),
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.white70,
                                size: 20.sw(context),
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 10.sh(context),
                              ),
                              suffixIcon: _isSearching
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.white70,
                                        size: 20.sw(context),
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
                      SizedBox(width: 14.sw(context)),
                      GestureDetector(
                        onTap: () {
                          ref.read(editModeProvider.notifier).toggle();
                        },
                        child: Container(
                          width: 35.sh(context),
                          height: 35.sh(context),
                          decoration: BoxDecoration(
                            color: isEditMode
                                ? Colors.white.withAlpha(50)
                                : Colors.white.withAlpha(10),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isEditMode ? Icons.done : Icons.edit,
                            color: Colors.white,
                            size: 23.sh(context),
                          ),
                        ),
                      ),
                      if (isAddButtonVisible) ...[
                        SizedBox(width: 14.sw(context)),
                        GestureDetector(
                          onTap: () => _showAppPicker(isWidget: false),
                          child: Container(
                            width: 35.sh(context),
                            height: 35.sh(context),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(10),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 30.sh(context),
                            ),
                          ),
                        ),
                      ],
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
                  top: MediaQuery.of(context).padding.top + 7.sh(context),
                  right: 10.sw(context),
                  child: IconButton(
                    icon: Icon(
                      Icons.settings,
                      color: Colors.white,
                      size: 30.sw(context),
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
