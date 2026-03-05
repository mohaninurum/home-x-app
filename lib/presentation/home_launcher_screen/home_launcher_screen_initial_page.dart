import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/app_icon_widget.dart';
import './widgets/context_menu_widget.dart';
import './widgets/dock_widget.dart';
import './widgets/home_page_indicator_widget.dart';

class HomeLauncherScreenInitialPage extends StatefulWidget {
  const HomeLauncherScreenInitialPage({super.key});

  @override
  State<HomeLauncherScreenInitialPage> createState() =>
      _HomeLauncherScreenInitialPageState();
}

class _HomeLauncherScreenInitialPageState
    extends State<HomeLauncherScreenInitialPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  int? _longPressedIndex;
  Offset? _contextMenuOffset;
  bool _showContextMenu = false;
  int? _contextMenuAppIndex;

  final List<Map<String, dynamic>> _dockApps = [
    {
      "name": "Phone",
      "iconName": "phone",
      "color": const Color(0xFF4A7C59),
      "bgColor": const Color(0xFF2D5A3D),
    },
    {
      "name": "Messages",
      "iconName": "message",
      "color": const Color(0xFF8FBF9F),
      "bgColor": const Color(0xFF4A7C59),
    },
    {
      "name": "Camera",
      "iconName": "camera_alt",
      "color": const Color(0xFFFFFFFF),
      "bgColor": const Color(0xFF2D5A3D),
    },
    {
      "name": "Browser",
      "iconName": "language",
      "color": const Color(0xFF8FBF9F),
      "bgColor": const Color(0xFF4A7C59),
    },
  ];

  final List<List<Map<String, dynamic>>> _pages = [
    [
      {
        "name": "Calendar",
        "iconName": "calendar_today",
        "color": const Color(0xFF4A7C59),
        "bgColor": const Color(0xFFE8F5EC),
      },
      {
        "name": "Maps",
        "iconName": "map",
        "color": const Color(0xFF2D5A3D),
        "bgColor": const Color(0xFFD0EBD8),
      },
      {
        "name": "Music",
        "iconName": "music_note",
        "color": const Color(0xFF4A7C59),
        "bgColor": const Color(0xFFE8F5EC),
      },
      {
        "name": "Photos",
        "iconName": "photo_library",
        "color": const Color(0xFF2D5A3D),
        "bgColor": const Color(0xFFD0EBD8),
      },
      {
        "name": "Settings",
        "iconName": "settings",
        "color": const Color(0xFF4A7C59),
        "bgColor": const Color(0xFFE8F5EC),
      },
      {
        "name": "Mail",
        "iconName": "mail",
        "color": const Color(0xFF2D5A3D),
        "bgColor": const Color(0xFFD0EBD8),
      },
      {
        "name": "Clock",
        "iconName": "access_time",
        "color": const Color(0xFF4A7C59),
        "bgColor": const Color(0xFFE8F5EC),
      },
      {
        "name": "Weather",
        "iconName": "wb_sunny",
        "color": const Color(0xFF2D5A3D),
        "bgColor": const Color(0xFFD0EBD8),
      },
      {
        "name": "Notes",
        "iconName": "note",
        "color": const Color(0xFF4A7C59),
        "bgColor": const Color(0xFFE8F5EC),
      },
      {
        "name": "Calculator",
        "iconName": "calculate",
        "color": const Color(0xFF2D5A3D),
        "bgColor": const Color(0xFFD0EBD8),
      },
      {
        "name": "Contacts",
        "iconName": "contacts",
        "color": const Color(0xFF4A7C59),
        "bgColor": const Color(0xFFE8F5EC),
      },
      {
        "name": "Files",
        "iconName": "folder",
        "color": const Color(0xFF2D5A3D),
        "bgColor": const Color(0xFFD0EBD8),
      },
      {
        "name": "Store",
        "iconName": "store",
        "color": const Color(0xFF4A7C59),
        "bgColor": const Color(0xFFE8F5EC),
      },
      {
        "name": "Health",
        "iconName": "favorite",
        "color": const Color(0xFF2D5A3D),
        "bgColor": const Color(0xFFD0EBD8),
      },
      {
        "name": "Wallet",
        "iconName": "account_balance_wallet",
        "color": const Color(0xFF4A7C59),
        "bgColor": const Color(0xFFE8F5EC),
      },
      {
        "name": "Podcasts",
        "iconName": "podcasts",
        "color": const Color(0xFF2D5A3D),
        "bgColor": const Color(0xFFD0EBD8),
      },
    ],
    [
      {
        "name": "Videos",
        "iconName": "video_library",
        "color": const Color(0xFF4A7C59),
        "bgColor": const Color(0xFFE8F5EC),
      },
      {
        "name": "Books",
        "iconName": "menu_book",
        "color": const Color(0xFF2D5A3D),
        "bgColor": const Color(0xFFD0EBD8),
      },
      {
        "name": "Travel",
        "iconName": "flight",
        "color": const Color(0xFF4A7C59),
        "bgColor": const Color(0xFFE8F5EC),
      },
      {
        "name": "News",
        "iconName": "newspaper",
        "color": const Color(0xFF2D5A3D),
        "bgColor": const Color(0xFFD0EBD8),
      },
      {
        "name": "Games",
        "iconName": "sports_esports",
        "color": const Color(0xFF4A7C59),
        "bgColor": const Color(0xFFE8F5EC),
      },
      {
        "name": "Finance",
        "iconName": "bar_chart",
        "color": const Color(0xFF2D5A3D),
        "bgColor": const Color(0xFFD0EBD8),
      },
      {
        "name": "Shopping",
        "iconName": "shopping_bag",
        "color": const Color(0xFF4A7C59),
        "bgColor": const Color(0xFFE8F5EC),
      },
      {
        "name": "Social",
        "iconName": "people",
        "color": const Color(0xFF2D5A3D),
        "bgColor": const Color(0xFFD0EBD8),
      },
      {
        "name": "Fitness",
        "iconName": "fitness_center",
        "color": const Color(0xFF4A7C59),
        "bgColor": const Color(0xFFE8F5EC),
      },
      {
        "name": "Food",
        "iconName": "restaurant",
        "color": const Color(0xFF2D5A3D),
        "bgColor": const Color(0xFFD0EBD8),
      },
      {
        "name": "Work",
        "iconName": "work",
        "color": const Color(0xFF4A7C59),
        "bgColor": const Color(0xFFE8F5EC),
      },
      {
        "name": "Security",
        "iconName": "security",
        "color": const Color(0xFF2D5A3D),
        "bgColor": const Color(0xFFD0EBD8),
      },
    ],
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onIconLongPress(int index, Offset offset) {
    HapticFeedback.mediumImpact();
    setState(() {
      _longPressedIndex = index;
      _contextMenuOffset = offset;
      _showContextMenu = true;
      _contextMenuAppIndex = index;
    });
  }

  void _dismissContextMenu() {
    setState(() {
      _showContextMenu = false;
      _longPressedIndex = null;
      _contextMenuAppIndex = null;
    });
  }

  void _onIconTap(Map<String, dynamic> app) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Launching ${app["name"]}...'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentPageApps = _pages[_currentPage];

    return Scaffold(
      body: GestureDetector(
        onTap: _showContextMenu ? _dismissContextMenu : null,
        child: Stack(
          children: [
            // Wallpaper background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0D1F14),
                    Color(0xFF1A3D26),
                    Color(0xFF2D5A3D),
                    Color(0xFF1A2E20),
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
            // Subtle texture overlay
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0.0, -0.5),
                  radius: 1.2,
                  colors: [
                    const Color(0xFF4A7C59).withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
                child: Column(
                  children: [
                    // Status bar area with time
                    _buildStatusBar(theme),
                    SizedBox(height: 1.h),
                    // Main icon grid
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _pages.length,
                        onPageChanged: (index) {
                          setState(() => _currentPage = index);
                        },
                        itemBuilder: (context, pageIndex) {
                          return _buildIconGrid(
                            _pages[pageIndex],
                            theme,
                            pageIndex,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 1.h),
                    // Page indicator
                    HomePageIndicatorWidget(
                      pageCount: _pages.length,
                      currentPage: _currentPage,
                    ),
                    SizedBox(height: 2.h),
                    // Dock
                    DockWidget(dockApps: _dockApps, onAppTap: _onIconTap),
                    SizedBox(height: 1.h),
                  ],
                ),
              ),
            ),
            // Context menu overlay
            _showContextMenu && _contextMenuOffset != null
                ? ContextMenuWidget(
              offset: _contextMenuOffset!,
              appName: _contextMenuAppIndex != null
                  ? (currentPageApps[_contextMenuAppIndex!]["name"]
              as String)
                  : '',
              onDismiss: _dismissContextMenu,
              onAppInfo: () {
                _dismissContextMenu();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('App Info')));
              },
              onUninstall: () {
                _dismissContextMenu();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Uninstall')),
                );
              },
              onHide: () {
                _dismissContextMenu();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Hidden')));
              },
              onCreateFolder: () {
                _dismissContextMenu();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Folder Created')),
                );
              },
            )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBar(ThemeData theme) {
    final now = DateTime.now();
    final hour = now.hour > 12
        ? now.hour - 12
        : (now.hour == 0 ? 12 : now.hour);
    final minute = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$hour:$minute $ampm',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 4),
            ],
          ),
        ),
        Row(
          children: [
            CustomIconWidget(
              iconName: 'signal_cellular_alt',
              color: Colors.white,
              size: 16,
            ),
            SizedBox(width: 1.w),
            CustomIconWidget(iconName: 'wifi', color: Colors.white, size: 16),
            SizedBox(width: 1.w),
            CustomIconWidget(
              iconName: 'battery_full',
              color: Colors.white,
              size: 16,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconGrid(
      List<Map<String, dynamic>> apps,
      ThemeData theme,
      int pageIndex,
      ) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 0.75,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        final isLongPressed =
            _longPressedIndex == index && _currentPage == pageIndex;
        return AppIconWidget(
          appData: app,
          isLongPressed: isLongPressed,
          onTap: () => _onIconTap(app),
          onLongPress: (offset) => _onIconLongPress(index, offset),
        );
      },
    );
  }
}
