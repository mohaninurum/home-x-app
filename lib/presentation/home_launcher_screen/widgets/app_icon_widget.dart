import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AppIconWidget extends StatefulWidget {
  final Map<String, dynamic> appData;
  final bool isLongPressed;
  final VoidCallback onTap;
  final Function(Offset) onLongPress;

  const AppIconWidget({
    super.key,
    required this.appData,
    required this.isLongPressed,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<AppIconWidget> createState() => _AppIconWidgetState();
}

class _AppIconWidgetState extends State<AppIconWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnim;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animController.forward();
    HapticFeedback.selectionClick();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animController.reverse();
    widget.onTap();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animController.reverse();
  }

  void _handleLongPress() {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset offset = box.localToGlobal(Offset.zero);
    widget.onLongPress(offset);
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.appData["bgColor"] as Color;
    final iconColor = widget.appData["color"] as Color;
    final iconName = widget.appData["iconName"] as String;
    final appName = widget.appData["name"] as String;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onLongPress: _handleLongPress,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 3D Skeuomorphic Icon
            Container(
              width: 14.w,
              height: 14.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.w),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    bgColor.withValues(alpha: 0.95),
                    bgColor,
                    bgColor.withValues(alpha: 0.85),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                    spreadRadius: 1,
                  ),
                  BoxShadow(
                    color: const Color(0xFF4A7C59).withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 0.5,
                ),
              ),
              child: Stack(
                children: [
                  // Glossy highlight overlay
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
                            Colors.white.withValues(alpha: 0.35),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Icon
                  Center(
                    child: CustomIconWidget(
                      iconName: iconName,
                      color: iconColor,
                      size: 7.w,
                    ),
                  ),
                  // Inner shadow bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 3.w,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(3.w),
                          bottomRight: Radius.circular(3.w),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.2),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Long press highlight
                  widget.isLongPressed
                      ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.w),
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                  )
                      : const SizedBox.shrink(),
                ],
              ),
            ),
            SizedBox(height: 0.8.h),
            // App name
            Text(
              appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 9.sp,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.7),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
