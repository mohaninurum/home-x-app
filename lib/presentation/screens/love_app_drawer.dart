import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../theme_provider.dart';

class LoveAppDrawer extends ConsumerWidget {
  const LoveAppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(appsProvider);
    final theme = ref.watch(themeMoodProvider);
    final nativeService = ref.read(nativeAppServiceProvider);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        title: const Text('Apps', style: TextStyle(color: Colors.white)),
        backgroundColor: theme.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: appsAsync.when(
        data: (apps) {
          if (apps.isEmpty) {
            return const Center(child: Text("No apps found", style: TextStyle(color: Colors.black54)));
          }
          
          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: apps.length,
            itemBuilder: (context, index) {
              final app = apps[index];
              return InkWell(
                onTap: () {
                  nativeService.launchApp(app.packageName);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipPath(
                      clipper: DrawerHeartClipper(),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        color: theme.primaryColor.withOpacity(0.2),
                        child: Image.memory(app.iconBytes, width: 48, height: 48, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      app.label,
                      style: TextStyle(color: theme.primaryColor, fontSize: 10, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: theme.primaryColor)),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class DrawerHeartClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double width = size.width;
    double height = size.height;
    Path path = Path();
    path.moveTo(0.5 * width, height * 0.35);
    path.cubicTo(0.2 * width, height * 0.1, -0.25 * width, height * 0.6, 0.5 * width, height);
    path.moveTo(0.5 * width, height * 0.35);
    path.cubicTo(0.8 * width, height * 0.1, 1.25 * width, height * 0.6, 0.5 * width, height);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
