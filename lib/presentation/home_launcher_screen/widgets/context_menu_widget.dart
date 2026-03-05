import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class ContextMenuWidget extends StatelessWidget {
  final Offset offset;
  final String appName;
  final VoidCallback onDismiss;
  final VoidCallback onAppInfo;
  final VoidCallback onUninstall;
  final VoidCallback onHide;
  final VoidCallback onCreateFolder;

  const ContextMenuWidget({
    super.key,
    required this.offset,
    required this.appName,
    required this.onDismiss,
    required this.onAppInfo,
    required this.onUninstall,
    required this.onHide,
    required this.onCreateFolder,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    double left = offset.dx;
    double top = offset.dy;

    // Clamp to screen bounds
    if (left + 55.w > screenSize.width) {
      left = screenSize.width - 55.w - 4.w;
    }
    if (top + 30.h > screenSize.height) {
      top = screenSize.height - 30.h - 4.h;
    }
    if (left < 4.w) left = 4.w;
    if (top < 10.h) top = 10.h;

    return Positioned(
      left: left,
      top: top,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 55.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.w),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A3D26), Color(0xFF0D1F14)],
            ),
            border: Border.all(
              color: const Color(0xFF4A7C59).withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App name header
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(4.w),
                    topRight: Radius.circular(4.w),
                  ),
                  color: const Color(0xFF4A7C59).withValues(alpha: 0.3),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'apps',
                      color: const Color(0xFF8FBF9F),
                      size: 18,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        appName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              _buildMenuItem(
                iconName: 'info_outline',
                label: 'App Info',
                onTap: onAppInfo,
              ),
              _buildDivider(),
              _buildMenuItem(
                iconName: 'delete_outline',
                label: 'Uninstall',
                onTap: onUninstall,
                isDestructive: true,
              ),
              _buildDivider(),
              _buildMenuItem(
                iconName: 'visibility_off',
                label: 'Hide',
                onTap: onHide,
              ),
              _buildDivider(),
              _buildMenuItem(
                iconName: 'create_new_folder',
                label: 'Create Folder',
                onTap: onCreateFolder,
                isLast: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String iconName,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
    bool isLast = false,
  }) {
    final color = isDestructive ? const Color(0xFFFF4D4F) : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: isLast
            ? BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        )
            : null,
        child: Row(
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: isDestructive
                  ? const Color(0xFFFF4D4F)
                  : const Color(0xFF8FBF9F),
              size: 18,
            ),
            SizedBox(width: 3.w),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 0.5,
      color: const Color(0xFF4A7C59).withValues(alpha: 0.3),
    );
  }
}
