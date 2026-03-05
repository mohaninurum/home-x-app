import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class DockBarWidget extends StatelessWidget {
  final List<Map<String, dynamic>> dockApps;
  final Function(Map<String, dynamic>) onAppTap;

  const DockBarWidget({
    super.key,
    required this.dockApps,
    required this.onAppTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.w),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF4A7C59).withValues(alpha: 0.35),
            const Color(0xFF2D5A3D).withValues(alpha: 0.25),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF8FBF9F).withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF4A7C59).withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: dockApps.map((app) {
          return _DockIcon(app: app, onTap: () => onAppTap(app));
        }).toList(),
      ),
    );
  }
}

class _DockIcon extends StatefulWidget {
  final Map<String, dynamic> app;
  final VoidCallback onTap;

  const _DockIcon({required this.app, required this.onTap});

  @override
  State<_DockIcon> createState() => _DockIconState();
}

class _DockIconState extends State<_DockIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _bounceController;
  late Animation<double> _bounceAnim;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _bounceAnim = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color baseColor = widget.app["color"] as Color;
    final Color accentColor = widget.app["accentColor"] as Color;

    return GestureDetector(
      onTapDown: (_) => _bounceController.forward(),
      onTapUp: (_) {
        _bounceController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _bounceController.reverse(),
      child: AnimatedBuilder(
        animation: _bounceAnim,
        builder: (context, child) =>
            Transform.scale(scale: _bounceAnim.value, child: child),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 14.w,
              height: 14.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.w),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    baseColor.withValues(alpha: 0.9),
                    baseColor,
                    Color.lerp(baseColor, Colors.black, 0.3)!,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: baseColor.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  color: accentColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Stack(
                children: [
                  // Gloss
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 7.w,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(3.w),
                          topRight: Radius.circular(3.w),
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
                  ),
                  Center(
                    child: CustomIconWidget(
                      iconName: widget.app["iconName"] as String,
                      color: Colors.white.withValues(alpha: 0.95),
                      size: 6.5.w,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 0.5.h),
            Text(
              widget.app["name"] as String,
              style: TextStyle(
                fontSize: 8.sp,
                color: Colors.white.withValues(alpha: 0.85),
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
