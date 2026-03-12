import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme_provider.dart';
import '../widgets/floating_app_icon.dart';
import '../widgets/animated_hearts_background.dart';
import '../widgets/gesture_drawing_detector.dart';

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

  @override
  Widget build(BuildContext context) {
    final appsAsync = ref.watch(appsProvider);
    final theme = ref.watch(themeMoodProvider);
    final homeApps = ref.watch(homeAppsProvider).value ?? {};
    final nativeService = ref.read(nativeAppServiceProvider);
    final wallpaperPath = ref.watch(wallpaperProvider).value;

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
                return app.label.toLowerCase().contains(_searchQuery);
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
                  crossAxisCount: 4,
                  crossAxisSpacing: 6.sw(context),
                  mainAxisSpacing: 5.sw(context),
                ),
                itemCount: filteredApps.length,
                itemBuilder: (context, index) {
                  final app = filteredApps[index];
                  final isOnHome = homeApps.contains(app.packageName);

                  return InkWell(
                    onTap: () {
                      nativeService.launchApp(app.packageName);
                    },
                    onLongPress: () {
                      ref
                          .read(homeAppsProvider.notifier)
                          .toggleApp(app.packageName);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isOnHome ? 'Removed from Home' : 'Added to Home',
                          ),
                          backgroundColor: theme.primaryColor,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: LongPressDraggable<AppInfo>(
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
