import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme_provider.dart';
import '../widgets/floating_app_icon.dart';
import '../widgets/animated_hearts_background.dart';
import '../widgets/gesture_drawing_detector.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/app_info.dart';
import '../../core/responsive_utils.dart';

class LoveAppDrawer extends ConsumerStatefulWidget {
  final VoidCallback? onClose;

  const LoveAppDrawer({super.key, this.onClose});

  @override
  ConsumerState<LoveAppDrawer> createState() => _LoveAppDrawerState();
}

class _LoveAppDrawerState extends ConsumerState<LoveAppDrawer> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void Function() _onAppLongPress(
    AppInfo app,
    bool isOnHome,
    dynamic theme,
    dynamic nativeService,
  ) {
    return () async {
      final RenderBox button = context.findRenderObject() as RenderBox;
      final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
      final RelativeRect position = RelativeRect.fromRect(
        Rect.fromPoints(
          button.localToGlobal(Offset.zero, ancestor: overlay),
          button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
        ),
        Offset.zero & overlay.size,
      );

      final result = await showMenu<String>(
        context: context,
        position: position,
        color: theme.backgroundColor.withOpacity(0.95),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        items: [
          PopupMenuItem<String>(
            value: 'toggle_home',
            child: Row(
              children: [
                Icon(
                  isOnHome ? Icons.favorite_border : Icons.favorite,
                  color: theme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  isOnHome ? 'Remove from Home' : 'Add to Home',
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
          PopupMenuItem<String>(
            value: 'uninstall',
            child: Row(
              children: [
                const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                const SizedBox(width: 12),
                const Text(
                  'Uninstall',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      );

      if (result == 'toggle_home') {
        ref.read(homeAppsProvider.notifier).toggleApp(app.packageName);
      } else if (result == 'change_icon') {
        final picker = ImagePicker();
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          await ref.read(iconImageProvider.notifier).setCustomIcon(app.packageName, pickedFile.path);
        }
      } else if (result == 'reset_icon') {
        await ref.read(iconImageProvider.notifier).clearCustomIcon(app.packageName);
      } else if (result == 'uninstall') {
        nativeService.uninstallApp(app.packageName);
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    final appsAsync = ref.watch(appsProvider);
    final theme = ref.watch(themeMoodProvider);
    final homeApps = ref.watch(homeAppsProvider).value ?? {};
    final hiddenApps = ref.watch(hiddenAppsProvider).value ?? {};
    final nativeService = ref.read(nativeAppServiceProvider);
    final wallpaperPath = ref.watch(wallpaperProvider).value;
    final gridSize = ref.watch(gridSizeProvider).value ?? 4;

    return Scaffold(
      backgroundColor: wallpaperPath != null
          ? Colors.transparent
          : theme.backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65.sh(context)),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 5.sh(context),
                bottom: 10.sh(context),
                left: 15.sw(context),
                right: 15.sw(context),
              ),
              decoration: BoxDecoration(
                // Use a darker glass tint for strong contrast
                color: Colors.black.withAlpha(60),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withAlpha(20),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (!_isSearching)
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: widget.onClose,
                    ),
                  Expanded(
                    child: _isSearching
                        ? Container(
                            height: 40.sh(context),
                            padding: EdgeInsets.symmetric(horizontal: 15.sw(context)),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(20),
                              borderRadius: BorderRadius.circular(20.sw(context)),
                              border: Border.all(
                                color: Colors.white.withAlpha(30),
                                width: 0.5,
                              ),
                            ),
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: "Search apps...",
                                hintStyle: TextStyle(
                                  color: Colors.white.withAlpha(150),
                                ),
                                border: InputBorder.none,
                                icon: Icon(
                                  Icons.search,
                                  color: Colors.white70,
                                  size: 20.sw(context),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value.toLowerCase();
                                });
                              },
                            ),
                          )
                        : Text(
                            'All Apps',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.wsp(context),
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5.sw(context),
                              shadows: const [
                                Shadow(
                                  blurRadius: 2.0,
                                  color: Colors.black45,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                  ),
                  if (_isSearching)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () {
                        setState(() {
                          _isSearching = false;
                          _searchQuery = "";
                          _searchController.clear();
                        });
                      },
                    )
                  else
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withAlpha(30),
                          width: 0.5,
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _isSearching = true;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          if (wallpaperPath != null)
            Positioned.fill(
              child: Image.file(File(wallpaperPath), fit: BoxFit.cover),
            ),
          if (wallpaperPath != null)
            Positioned.fill(child: Container(color: Colors.black45)),
          if (wallpaperPath == null)
            const Positioned.fill(
              child: GestureDrawingDetector(child: AnimatedHeartsBackground()),
            ),
          appsAsync.when(
            data: (apps) {
              final filteredApps = apps.where((app) {
                final matchesSearch = app.label.toLowerCase().contains(_searchQuery);
                final isHidden = hiddenApps.contains(app.packageName);
                return matchesSearch && !isHidden;
              }).toList();

              if (filteredApps.isEmpty) {
                return const Center(
                  child: Text(
                    "No apps found",
                    style: TextStyle(color: Colors.white70),
                  ),
                );
              }

              return GridView.builder(
                padding: EdgeInsets.all(15.sw(context)),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: gridSize,
                  crossAxisSpacing: gridSize == 4 ? 6.sw(context) : 4.sw(context),
                  mainAxisSpacing: 5.sw(context),
                  childAspectRatio: gridSize == 4 ? 1.0 : 0.85,
                ),
                itemCount: filteredApps.length,
                itemBuilder: (context, index) {
                  final app = filteredApps[index];
                  final isOnHome = homeApps.contains(app.packageName);

                  return Draggable<AppInfo>(
                    data: app,
                    feedback: Material(
                      color: Colors.transparent,
                      child: Opacity(
                        opacity: 0.7,
                        child: SizedBox(
                          width: 80.sw(context),
                          height: 80.sw(context),
                          child: AppIconContent(app: app, showLabel: true),
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: AppIconContent(app: app, showLabel: true),
                    ),
                    child: InkWell(
                      onTap: () {
                        nativeService.launchApp(app.packageName);
                      },
                      onLongPress: _onAppLongPress(app, isOnHome, theme, nativeService),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AppIconContent(app: app, showLabel: true),
                          if (isOnHome)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Icon(
                                Icons.favorite,
                                color: theme.secondaryColor,
                                size: 16.sw(context),
                                shadows: [
                                  Shadow(
                                    color: theme.backgroundColor,
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => Center(
              child: CircularProgressIndicator(color: theme.primaryColor),
            ),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
    );
  }
}
