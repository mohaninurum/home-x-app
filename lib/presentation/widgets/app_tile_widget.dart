import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';
import '../../domain/app_info.dart';
import 'floating_app_icon.dart';
import '../../core/responsive_utils.dart';

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

        final labelLower = app.label.toLowerCase();
        final packageLower = app.packageName.toLowerCase();

        final isPhotos = labelLower.contains('photo') ||
            packageLower.contains('gallery') ||
            packageLower.contains('photos');

        final isGoogleSearch = labelLower.contains('google') && !labelLower.contains('youtube') && !labelLower.contains('photo');
        final isYouTube = labelLower.contains('youtube');

        Widget content;

        if (widgetData.imagePath != null || isPhotos) {
          content = _buildModernPhotoWidget(context, app, widgetData.imagePath);
        } else if (isGoogleSearch) {
          content = _buildGoogleSearchWidget(context);
        } else if (isYouTube) {
          content = _buildYouTubeWidget(context);
        } else {
          content = _buildGenericWidget(context, app);
        }

        return GestureDetector(
          onLongPress: onLongPress,
          child: content,
        );
      },
      loading: () => SizedBox(
        width: 160.sw(context),
        height: 160.sw(context),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildGoogleSearchWidget(BuildContext context) {
    return Container(
      width: 320.sw(context),
      height: 60.sw(context),
      padding: EdgeInsets.symmetric(horizontal: 20.sw(context)),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E),
        borderRadius: BorderRadius.circular(30.sw(context)),
      ),
      child: Row(
        children: [
          // Google 'G' Icon (simulated)
          Container(
            padding: EdgeInsets.all(4.sw(context)),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.g_mobiledata, color: Colors.blue, size: 24.sw(context)),
          ),
          SizedBox(width: 12.sw(context)),
          Expanded(
            child: Text(
              "Search",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16.wsp(context),
              ),
            ),
          ),
          Icon(Icons.mic, color: Colors.white70, size: 22.sw(context)),
          SizedBox(width: 16.sw(context)),
          Icon(Icons.travel_explore, color: Colors.white70, size: 22.sw(context)),
          SizedBox(width: 16.sw(context)),
          Icon(Icons.camera_alt_outlined, color: Colors.white70, size: 22.sw(context)),
        ],
      ),
    );
  }

  Widget _buildYouTubeWidget(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // YouTube Search Pill
        Container(
          width: 340.sw(context),
          height: 60.sw(context),
          padding: EdgeInsets.symmetric(horizontal: 20.sw(context)),
          decoration: BoxDecoration(
            color: const Color(0xFF38383A),
            borderRadius: BorderRadius.circular(30.sw(context)),
          ),
          child: Row(
            children: [
              Icon(Icons.play_circle_fill, color: Colors.white, size: 28.sw(context)),
              SizedBox(width: 12.sw(context)),
              Expanded(
                child: Text(
                  "Search YouTube",
                  style: TextStyle(color: Colors.white, fontSize: 16.wsp(context)),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.sw(context)),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mic, color: Colors.white, size: 20.sw(context)),
              ),
            ],
          ),
        ),
        SizedBox(height: 15.sw(context)),
        // YouTube Action Grid
        Container(
          width: 340.sw(context),
          height: 100.sw(context),
          padding: EdgeInsets.symmetric(horizontal: 10.sw(context), vertical: 15.sw(context)),
          decoration: BoxDecoration(
            color: const Color(0xFF38383A),
            borderRadius: BorderRadius.circular(20.sw(context)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildYouTubeAction(context, Icons.home_outlined, "Home"),
              _buildYouTubeAction(context, Icons.play_arrow_outlined, "Shorts"),
              _buildYouTubeAction(context, Icons.subscriptions_outlined, "Subscriptions"),
              _buildYouTubeAction(context, Icons.video_library_outlined, "Library"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildYouTubeAction(BuildContext context, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: Colors.white, size: 26.sw(context)),
        SizedBox(height: 6.sw(context)),
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 11.wsp(context)),
        ),
      ],
    );
  }

  Widget _buildModernPhotoWidget(BuildContext context, AppInfo app, String? imagePath) {
    final now = DateTime.now();
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final dateString = "${now.day} ${months[now.month - 1]} ${now.year}";

    return Container(
      width: 180.sw(context),
      height: 180.sw(context),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(24.sw(context)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.sw(context)),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imagePath != null)
              Image.file(File(imagePath), fit: BoxFit.cover)
            else
              Container(
                color: Colors.grey.shade800,
                child: Center(
                  child: SizedBox(
                    width: 70.sw(context),
                    height: 70.sw(context),
                    child: AppIconContent(app: app, showLabel: false),
                  ),
                ),
              ),
            // Date Overlay at the bottom
            Positioned(
              bottom: 12.sw(context),
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  dateString,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.wsp(context),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    shadows: const [
                      Shadow(color: Colors.black54, blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenericWidget(BuildContext context, AppInfo app) {
    return Container(
      width: 160.sw(context),
      height: 160.sw(context),
      padding: EdgeInsets.all(12.sw(context)),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(24.sw(context)),
        border: Border.all(
          color: Colors.white.withAlpha(50),
          width: 1.5.sw(context),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          width: 80.sw(context),
          height: 80.sw(context),
          child: AppIconContent(app: app, showLabel: false),
        ),
      ),
    );
  }
}
