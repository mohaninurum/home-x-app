import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PreviewGridWidget extends StatelessWidget {
  final bool glossyEffects;
  final bool shadowEffects;
  final double iconSize;
  final double cornerRadius;

  const PreviewGridWidget({
    super.key,
    required this.glossyEffects,
    required this.shadowEffects,
    required this.iconSize,
    required this.cornerRadius,
  });

  static const List<Map<String, dynamic>> _previewIcons = [
    {"iconName": "camera_alt", "color": Color(0xFF2D5A3D)},
    {"iconName": "message", "color": Color(0xFF1A4A2E)},
    {"iconName": "phone", "color": Color(0xFF4A7C59)},
    {"iconName": "settings", "color": Color(0xFF2D5A3D)},
    {"iconName": "photo_library", "color": Color(0xFF1A3D28)},
    {"iconName": "music_note", "color": Color(0xFF0D2B1A)},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.w),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A3D28).withValues(alpha: 0.7),
            const Color(0xFF0D2B1A).withValues(alpha: 0.85),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF4A7C59).withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PREVIEW',
            style: TextStyle(
              fontSize: 10.sp,
              color: const Color(0xFF8FBF9F),
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _previewIcons.map((icon) {
              final Color baseColor = icon["color"] as Color;
              final double size = 12.w * iconSize;
              final double radius = size * 0.22 * (0.5 + cornerRadius * 0.5);

              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      baseColor.withValues(alpha: 0.9),
                      baseColor,
                      Color.lerp(baseColor, Colors.black, 0.3)!,
                    ],
                  ),
                  boxShadow: shadowEffects
                      ? [
                    BoxShadow(
                      color: baseColor.withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ]
                      : null,
                ),
                child: Stack(
                  children: [
                    glossyEffects
                        ? Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: size * 0.45,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(radius),
                            topRight: Radius.circular(radius),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    )
                        : const SizedBox.shrink(),
                    Center(
                      child: CustomIconWidget(
                        iconName: icon["iconName"] as String,
                        color: Colors.white.withValues(alpha: 0.9),
                        size: size * 0.5,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
