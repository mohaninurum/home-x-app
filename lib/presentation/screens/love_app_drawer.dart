import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme_provider.dart';
import '../widgets/floating_app_icon.dart';
import '../widgets/animated_hearts_background.dart';
import '../widgets/gesture_drawing_detector.dart';

import '../../domain/app_info.dart';

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
      backgroundColor: wallpaperPath != null ? Colors.transparent : theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: wallpaperPath != null ? Colors.black54 : theme.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSearching = false;
                    _searchQuery = "";
                    _searchController.clear();
                  });
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onClose,
              ),
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Search apps...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              )
            : const Text('Apps', style: TextStyle(color: Colors.white)),
        actions: [
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          if (wallpaperPath != null)
            Positioned.fill(
              child: Image.file(
                File(wallpaperPath),
                fit: BoxFit.cover,
              ),
            ),
          if (wallpaperPath != null)
            Positioned.fill(
              child: Container(color: Colors.black45),
            ),
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
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
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
                      ref.read(homeAppsProvider.notifier).toggleApp(app.packageName);
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
                            width: 80,
                            height: 80,
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
                                size: 16,
                                shadows: [
                                  Shadow(color: theme.backgroundColor, blurRadius: 4),
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
            loading: () => Center(child: CircularProgressIndicator(color: theme.primaryColor)),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ],
      ),
    );
  }
}
