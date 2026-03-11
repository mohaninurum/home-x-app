import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/app_info.dart';
import '../providers.dart';
import '../theme_provider.dart';
import '../../core/mood_theme.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

Uint8List removeWhiteBackground(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image == null) return bytes;

  const int threshold = 220;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);

      int r = pixel.r.toInt();
      int g = pixel.g.toInt();
      int b = pixel.b.toInt();

      // white distance detect
      int diff = (255 - r) + (255 - g) + (255 - b);

      if (r > threshold && g > threshold && b > threshold) {
        // fully transparent
        image.setPixelRgba(x, y, r, g, b, 0);
      } else if (diff < 120) {
        // smooth edge transparency
        int alpha = (diff * 2).clamp(0, 255);
        image.setPixelRgba(x, y, r, g, b, alpha);
      }
    }
  }

  return Uint8List.fromList(img.encodePng(image));
}

class StyledAppIcon extends StatelessWidget {
  final AppInfo app;
  final MoodTheme theme;
  final Uint8List iconBytes;

  const StyledAppIcon({
    super.key,
    required this.app,
    required this.theme,
    required this.iconBytes,
  });

  @override
  Widget build(BuildContext context) {
    const double pulseValue = 1.0;
    final double glowSpread = theme.mood == AppMood.hologram ? 4.0 : 1.0;
    final double glowBlur = theme.mood == AppMood.hologram ? 20.0 : 10.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor.withOpacity(0.6),
                theme.backgroundColor,
                theme.secondaryColor.withOpacity(0.2),
              ],
            ),
            boxShadow: [
              // Outer Glow (Hologram style)
              BoxShadow(
                color: theme.iconHighlightColor.withOpacity(
                  0.5 * (theme.mood == AppMood.hologram ? pulseValue : 1.0),
                ),
                blurRadius: glowBlur,
                spreadRadius: glowSpread,
              ),
              // Ambient 3D Drop shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                offset: const Offset(6, 10),
                blurRadius: 15,
              ),
              // Sharp ground contact shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                offset: const Offset(2, 3),
                blurRadius: 4,
              ),
              // Top-left outer rim highlight
              BoxShadow(
                color: Colors.white.withOpacity(0.6),
                offset: const Offset(-2, -2),
                blurRadius: 4,
              ),
            ],
            border: Border.all(
              color: theme.mood == AppMood.hologram
                  ? theme.primaryColor.withOpacity(0.8)
                  : Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.5),
                  Colors.white.withOpacity(0.0),
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.4),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            padding: const EdgeInsets.all(12),
            child: Image.memory(
              iconBytes,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: theme.mood == AppMood.hologram
              ? BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.3),
                    width: 0.5,
                  ),
                )
              : null,
          child: Text(
            app.label,
            style: TextStyle(
              color: theme.mood == AppMood.hologram
                  ? theme.primaryColor
                  : Colors.black87,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: theme.backgroundColor, blurRadius: 2),
                if (theme.mood == AppMood.hologram)
                  Shadow(
                    color: theme.primaryColor.withOpacity(0.5),
                    blurRadius: 8,
                  ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class StyledAppIconTwo extends StatelessWidget {
  final AppInfo app;
  final MoodTheme theme;
  final Uint8List iconBytes;

  const StyledAppIconTwo({
    super.key,
    required this.app,
    required this.theme,
    required this.iconBytes,
  });

  @override
  Widget build(BuildContext context) {
    const double pulseValue = 1.0;
    final double glowSpread = theme.mood == AppMood.hologram ? 4.0 : 1.0;
    final double glowBlur = theme.mood == AppMood.hologram ? 20.0 : 10.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor.withOpacity(0.4),
                theme.secondaryColor.withOpacity(0.1),
              ],
            ),
            boxShadow: [
              // Outer Glow (Hologram style)
              BoxShadow(
                color: theme.iconHighlightColor.withOpacity(
                  0.5 * (theme.mood == AppMood.hologram ? pulseValue : 1.0),
                ),
                blurRadius: glowBlur,
                spreadRadius: glowSpread,
              ),
              // Bottom Shadow (Depth/Skeuomorphism)
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                offset: const Offset(4, 4),
                blurRadius: 8,
              ),
              // Inner Highlight (Top Edge - Skeuomorphism)
              BoxShadow(
                color: Colors.white.withOpacity(0.4),
                offset: const Offset(-2, -2),
                blurRadius: 4,
              ),
            ],
            border: Border.all(
              color: theme.mood == AppMood.hologram
                  ? theme.primaryColor.withOpacity(0.8)
                  : Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: MemoryImage(iconBytes),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: theme.mood == AppMood.hologram
              ? BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: theme.primaryColor.withOpacity(0.3),
                    width: 0.5,
                  ),
                )
              : null,
          child: Text(
            app.label,
            style: TextStyle(
              color: theme.mood == AppMood.hologram
                  ? theme.primaryColor
                  : Colors.black87,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: theme.backgroundColor, blurRadius: 2),
                if (theme.mood == AppMood.hologram)
                  Shadow(
                    color: theme.primaryColor.withOpacity(0.5),
                    blurRadius: 8,
                  ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class FloatingAppIcon extends ConsumerStatefulWidget {
  final AppInfo app;
  final bool isFloating;
  final VoidCallback? onLongPress;

  const FloatingAppIcon({
    super.key,
    required this.app,
    this.isFloating = true,
    this.onLongPress,
  });

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
    if (!widget.isFloating) {
      return GestureDetector(
        onTap: () {
          ref.read(nativeAppServiceProvider).launchApp(widget.app.packageName);
        },
        onLongPress: widget.onLongPress,
        child: AppIconContent(app: widget.app),
      );
    }

    return Positioned(
      left: xPos,
      top: yPos,
      child: GestureDetector(
        onTap: () {
          ref.read(nativeAppServiceProvider).launchApp(widget.app.packageName);
        },
        onLongPress: () {
          if (widget.onLongPress != null) {
            widget.onLongPress!();
            return;
          }
          final theme = ref.read(themeMoodProvider);
          showModalBottomSheet(
            context: context,
            backgroundColor: theme.backgroundColor,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.delete_outline,
                      color: theme.primaryColor,
                    ),
                    title: Text(
                      "Remove from Home",
                      style: TextStyle(color: theme.primaryColor),
                    ),
                    onTap: () {
                      ref
                          .read(homeAppsProvider.notifier)
                          .removeApp(widget.app.packageName);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: Draggable(
          feedback: Material(
            color: Colors.transparent,
            child: Opacity(opacity: 0.7, child: AppIconContent(app: widget.app)),
          ),
          childWhenDragging: const SizedBox.shrink(),
          onDragEnd: (details) {
            setState(() {
              xPos = details.offset.dx;
              yPos = details.offset.dy;
            });
            _savePosition(xPos, yPos);
          },
          child: AppIconContent(app: widget.app),
        ),
      ),
    );
  }
}

class AppIconContent extends ConsumerWidget {
  final AppInfo app;
  const AppIconContent({super.key, required this.app});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeMoodProvider);
    final iconStyle = ref.watch(iconStyleProvider).value ?? AppIconStyle.box;
    final iconBytes = removeWhiteBackground(app.iconBytes);

    return iconStyle == AppIconStyle.box
        ? StyledAppIcon(app: app, theme: theme, iconBytes: iconBytes)
        : StyledAppIconTwo(app: app, theme: theme, iconBytes: iconBytes);
  }
}
