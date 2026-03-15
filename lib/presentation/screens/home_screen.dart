import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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
     FocusScope.of(context).unfocus();
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
                    FocusScope.of(context).unfocus();
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
                        ref.read(nativeAppServiceProvider).openNotificationPanel();
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



                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            // Draggable Custom Clock
                            if (ref.watch(clockCustomizationProvider).value?.showClock ?? true)
                            Positioned(
                              top: widgetPositions['clock']?.dy ?? (MediaQuery.of(context).padding.top + 60.sh(context)),
                              left: widgetPositions['clock']?.dx ?? (MediaQuery.of(context).size.width / 2 - 75.sw(context)),
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

                            // Bottom Dock Background
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



                            // All Floating Apps (Including initial dock apps)
                            for (var app in allFloatingApps)
                              FloatingAppIcon(
                                app: app,
                                isFloating: true,
                                showLabel: app.customImagePath != null, // Show title for custom icons
                                onLongPress: () async {
                                  final theme = ref.read(themeMoodProvider);
                                  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                                  
                                  final result = await showMenu<String>(
                                    context: context,
                                    position: RelativeRect.fromLTRB(
                                      _lastLongPressPos.dx,
                                      _lastLongPressPos.dy,
                                      overlay.size.width - _lastLongPressPos.dx,
                                      overlay.size.height - _lastLongPressPos.dy,
                                    ),
                                    color: theme.backgroundColor.withOpacity(0.95),
                                    elevation: 8,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    items: [
                                      PopupMenuItem<String>(
                                        value: 'remove',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline, color: theme.primaryColor, size: 20),
                                            const SizedBox(width: 12),
                                            Text(
                                              "Remove from Home",
                                              style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem<String>(
                                        value: 'change_icon',
                                        child: Row(
                                          children: [
                                            Icon(Icons.image_outlined, color: theme.primaryColor, size: 20),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Change Icon',
                                              style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (app.customImagePath != null)
                                        PopupMenuItem<String>(
                                          value: 'reset_icon',
                                          child: Row(
                                            children: [
                                              Icon(Icons.restore_outlined, color: theme.primaryColor, size: 20),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Reset Icon',
                                                style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  );

                                  if (result == 'remove') {
                                    ref.read(homeAppsProvider.notifier).removeApp(app.packageName);
                                  } else if (result == 'change_icon') {
                                    final picker = ImagePicker();
                                    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                                    if (pickedFile != null) {
                                      await ref.read(iconImageProvider.notifier).setCustomIcon(app.packageName, pickedFile.path);
                                    }
                                  } else if (result == 'reset_icon') {
                                    await ref.read(iconImageProvider.notifier).clearCustomIcon(app.packageName);
                                  }
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
                                          FocusScope.of(context).unfocus();
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
                          FocusScope.of(context).unfocus();
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
                                    final hiddenApps = ref.watch(hiddenAppsProvider).value ?? {};
                                    final results = allApps
                                        .where(
                                          (app) => app.label
                                              .toLowerCase()
                                              .contains(_searchQuery) &&
                                              !hiddenApps.contains(app.packageName),
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
                       FocusScope.of(context).unfocus();
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
