import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../../domain/app_info.dart';
import 'floating_app_icon.dart';

class AppTileWidget extends ConsumerWidget {
  final HomeWidget widgetData;
  final VoidCallback? onLongPress;

  const AppTileWidget({
    super.key,
    required this.widgetData,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(appsProvider);

    return appsAsync.when(
      data: (apps) {
        final app = apps.firstWhere(
          (a) => a.packageName == widgetData.packageName,
          orElse: () => AppInfo(
            packageName: widgetData.packageName,
            label: 'Unknown',
            iconBytes: Uint8List(0),
          ),
        );

        final isPhotos = app.label.toLowerCase().contains('photo') ||
            app.packageName.toLowerCase().contains('gallery') ||
            app.packageName.toLowerCase().contains('photos');

        return GestureDetector(
          onLongPress: onLongPress,
          child: Container(
            width: 160,
            height: 160,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withAlpha(50),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widgetData.imagePath != null)
                  _buildPhotoFrame(app, widgetData.imagePath!)
                else if (isPhotos)
                  _buildPhotoFrame(app, null)
                else
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: AppIconContent(app: app),
                  ),
                const SizedBox(height: 12),
                Text(
                  app.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox(
        width: 160,
        height: 160,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildPhotoFrame(AppInfo app, String? imagePath) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(30),
            blurRadius: 5,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    ),
                  )
                : AppIconContent(app: app),
          ),
          const SizedBox(height: 4),
          Container(
            width: 40,
            height: 2,
            color: Colors.grey.withAlpha(50),
          ),
        ],
      ),
    );
  }
}
