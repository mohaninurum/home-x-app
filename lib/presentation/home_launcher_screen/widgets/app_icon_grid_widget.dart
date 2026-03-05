import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AppIconGridWidget extends StatelessWidget {
  final List<Map<String, dynamic>> apps;
  final AnimationController entranceController;
  final Function(Map<String, dynamic>) onAppTap;

  const AppIconGridWidget({
    super.key,
    required this.apps,
    required this.entranceController,
    required this.onAppTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.5.h,
        childAspectRatio: 0.75,
      ),
      itemCount: apps.length,
      itemBuilder: (context, index) {
        final delay = index * 0.05;
        final animation = CurvedAnimation(
          parent: entranceController,
          curve: Interval(
            delay.clamp(0.0, 0.8),
            (delay + 0.3).clamp(0.0, 1.0),
            curve: Curves.elasticOut,
          ),
        );
        return AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform.scale(
              scale: animation.value,
              child: Opacity(
                opacity: animation.value.clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: _SkeuomorphicAppIcon(
            app: apps[index],
            onTap: () => onAppTap(apps[index]),
          ),
        );
      },
    );
  }
}

class _SkeuomorphicAppIcon extends StatefulWidget {
  final Map<String, dynamic> app;
  final VoidCallback onTap;

  const _SkeuomorphicAppIcon({required this.app, required this.onTap});

  @override
  State<_SkeuomorphicAppIcon> createState() => _SkeuomorphicAppIconState();
}

class _SkeuomorphicAppIconState extends State<_SkeuomorphicAppIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color baseColor = widget.app["color"] as Color;
    final Color accentColor = widget.app["accentColor"] as Color;

    return GestureDetector(
      onTapDown: (_) => _pressController.forward(),
      onTapUp: (_) {
        _pressController.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressController.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnim.value, child: child);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.5.w),
                boxShadow: [
                  BoxShadow(
                    color: baseColor.withValues(alpha: 0.6),
                    blurRadius: 10,
                    spreadRadius: 2,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(-2, -2),
                  ),
                ],
              ),
              child: CustomPaint(
                painter: _AppIconPainter(
                  baseColor: baseColor,
                  accentColor: accentColor,
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: widget.app["iconName"] as String,
                    color: Colors.white.withValues(alpha: 0.95),
                    size: 7.w,
                  ),
                ),
              ),
            ),
            SizedBox(height: 0.8.h),
            Text(
              widget.app["name"] as String,
              style: TextStyle(
                fontSize: 9.sp,
                color: Colors.white.withValues(alpha: 0.9),
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.6),
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

class _AppIconPainter extends CustomPainter {
  final Color baseColor;
  final Color accentColor;

  _AppIconPainter({required this.baseColor, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width * 0.22;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    // Base gradient
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          baseColor.withValues(alpha: 0.9),
          baseColor,
          Color.lerp(baseColor, Colors.black, 0.3)!,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect);
    canvas.drawRRect(rrect, basePaint);

    // Glossy top highlight
    final glossRect = Rect.fromLTWH(
      size.width * 0.1,
      size.height * 0.05,
      size.width * 0.8,
      size.height * 0.45,
    );
    final glossRRect = RRect.fromRectAndRadius(
      glossRect,
      Radius.circular(radius * 0.8),
    );
    final glossPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.white.withValues(alpha: 0.35),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(glossRect);
    canvas.drawRRect(glossRRect, glossPaint);

    // Rim highlight
    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0.0),
          Colors.black.withValues(alpha: 0.2),
        ],
      ).createShader(rect);
    canvas.drawRRect(rrect.deflate(0.75), rimPaint);

    // Bottom shadow inner
    final bottomShadowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.25)],
        stops: const [0.6, 1.0],
      ).createShader(rect);
    canvas.drawRRect(rrect, bottomShadowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
