import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/app_info.dart';
import '../providers.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

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




  Uint8List removeBackgroundSmooth(Uint8List bytes) {
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;

    // 4 corner pixels se background detect
    final p1 = image.getPixel(0, 0);
    final p2 = image.getPixel(image.width - 1, 0);
    final p3 = image.getPixel(0, image.height - 1);
    final p4 = image.getPixel(image.width - 1, image.height - 1);

    int bgR = ((p1.r + p2.r + p3.r + p4.r) / 4).round();
    int bgG = ((p1.g + p2.g + p3.g + p4.g) / 4).round();
    int bgB = ((p1.b + p2.b + p3.b + p4.b) / 4).round();

    const double threshold = 60;
    const double smoothRange = 80;

    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);

        int r = pixel.r.toInt();
        int g = pixel.g.toInt();
        int b = pixel.b.toInt();

        // Euclidean color distance
        double diff = sqrt(
          pow(r - bgR, 2) +
              pow(g - bgG, 2) +
              pow(b - bgB, 2),
        );

        if (diff < threshold) {
          // pure background
          image.setPixelRgba(x, y, r, g, b, 0);
        } else if (diff < threshold + smoothRange) {
          // smooth transition
          double t = (diff - threshold) / smoothRange;
          int alpha = (t * 255).clamp(0, 255).toInt();
          image.setPixelRgba(x, y, r, g, b, alpha);
        }
      }
    }

    return Uint8List.fromList(img.encodePng(image));
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
              image: MemoryImage(removeBackgroundSmooth(widget.app.iconBytes) ),
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
