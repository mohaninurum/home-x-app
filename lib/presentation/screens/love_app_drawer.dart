import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme_provider.dart';
import '../widgets/floating_app_icon.dart';
import '../../core/mood_theme.dart';

class LoveAppDrawer extends ConsumerWidget {
  const LoveAppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(appsProvider);
    final theme = ref.watch(themeMoodProvider);
    final iconStyle = ref.watch(iconStyleProvider).value ?? AppIconStyle.box;
    final homeApps = ref.watch(homeAppsProvider).value ?? {};
    final nativeService = ref.read(nativeAppServiceProvider);
    final wallpaperPath = ref.watch(wallpaperProvider).value;

    return Scaffold(
      backgroundColor: wallpaperPath != null ? Colors.transparent : theme.backgroundColor,
      appBar: AppBar(
        title: const Text('Apps', style: TextStyle(color: Colors.white)),
        backgroundColor: wallpaperPath != null ? Colors.black54 : theme.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
          appsAsync.when(
        data: (apps) {
          if (apps.isEmpty) {
            return const Center(
              child: Text(
                "No apps found",
                style: TextStyle(color: Colors.black54),
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
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
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
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    iconStyle == AppIconStyle.box
                        ? StyledAppIcon(
                            app: app,
                            theme: theme,
                            iconBytes: removeWhiteBackground(app.iconBytes),
                          )
                        : StyledAppIconTwo(
                            app: app,
                            theme: theme,
                            iconBytes: removeWhiteBackground(app.iconBytes),
                          ),
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
              );
            },
          );
        },
        loading: () =>
            Center(child: CircularProgressIndicator(color: theme.primaryColor)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    ]),
    );
  }
}
