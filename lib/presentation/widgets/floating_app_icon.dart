import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/app_info.dart';
import '../providers.dart';

class FloatingAppIcon extends ConsumerStatefulWidget {
  final AppInfo app;
  const FloatingAppIcon({super.key, required this.app});

  @override
  ConsumerState<FloatingAppIcon> createState() => _FloatingAppIconState();
}

class _FloatingAppIconState extends ConsumerState<FloatingAppIcon> {
  late double xPos;
  late double yPos;

  @override
  void initState() {
    super.initState();
    xPos = widget.app.xPos;
    yPos = widget.app.yPos;
  }

  void _savePosition(double x, double y) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('${widget.app.packageName}_x', x);
    await prefs.setDouble('${widget.app.packageName}_y', y);
  }

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle, // Romantic aesthetic base shape
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
            image: DecorationImage(
              image: MemoryImage(widget.app.iconBytes),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.app.label,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 12,
            shadows: [Shadow(color: Colors.white, blurRadius: 4)],
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    return Positioned(
      left: xPos,
      top: yPos,
      child: GestureDetector(
        onTap: () {
          ref.read(nativeAppServiceProvider).launchApp(widget.app.packageName);
        },
        child: Draggable(
          feedback: Material(
            color: Colors.transparent,
            child: Opacity(opacity: 0.7, child: iconWidget),
          ),
          childWhenDragging: const SizedBox.shrink(),
          onDragEnd: (details) {
            // Adjust offset to avoid status bar / navbar jumps
            setState(() {
              xPos = details.offset.dx;
              yPos = details.offset.dy;
            });
            _savePosition(xPos, yPos);
          },
          child: iconWidget,
        ),
      ),
    );
  }
}
