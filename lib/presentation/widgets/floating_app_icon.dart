import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import '../../domain/app_info.dart';
import '../providers.dart';
import '../theme_provider.dart';
import '../../core/mood_theme.dart';
import '../../core/responsive_utils.dart';


class StyledAppIcon extends StatelessWidget {
  final AppInfo app;
  final MoodTheme theme;
  final Uint8List iconBytes;
  final bool showLabel;
  final double size;

  const StyledAppIcon({
    super.key,
    required this.app,
    required this.theme,
    required this.iconBytes,
    this.showLabel = true,
    this.size = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    final double scaledSize = size.sw(context);
    const double pulseValue = 1.0;
    final double glowSpread = theme.mood == AppMood.hologram ? 4.0 : 1.0;
    final double glowBlur = theme.mood == AppMood.hologram ? 20.0 : 10.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: scaledSize,
          height: scaledSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(scaledSize * 0.25),
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
                offset: Offset(size * 0.09, size * 0.15),
                blurRadius: size * 0.23,
              ),
              // Sharp ground contact shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                offset: Offset(size * 0.03, size * 0.05),
                blurRadius: size * 0.06,
              ),
              // Top-left outer rim highlight
              BoxShadow(
                color: Colors.white.withOpacity(0.6),
                offset: Offset(-scaledSize * 0.03, -scaledSize * 0.03),
                blurRadius: scaledSize * 0.06,
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
              borderRadius: BorderRadius.circular(size * 0.22),
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
            padding: EdgeInsets.all(scaledSize * 0.18),
            child: Image.memory(
              iconBytes,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
        if (showLabel) ...[
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
      ],
    );
  }
}

class StyledAppIconTwo extends StatelessWidget {
  final AppInfo app;
  final MoodTheme theme;
  final Uint8List iconBytes;
  final bool showLabel;
  final double size;

  const StyledAppIconTwo({
    super.key,
    required this.app,
    required this.theme,
    required this.iconBytes,
    this.showLabel = true,
    this.size = 64.0,
  });

  @override
  Widget build(BuildContext context) {
    final double scaledSize = size.sw(context);
    const double pulseValue = 1.0;
    final double glowSpread = theme.mood == AppMood.hologram ? 4.0 : 1.0;
    final double glowBlur = theme.mood == AppMood.hologram ? 20.0 : 10.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
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
                offset: Offset(size * 0.06, size * 0.06),
                blurRadius: size * 0.12,
              ),
              // Inner Highlight (Top Edge - Skeuomorphism)
              BoxShadow(
                color: Colors.white.withOpacity(0.4),
                offset: Offset(-scaledSize * 0.03, -scaledSize * 0.03),
                blurRadius: scaledSize * 0.06,
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
            margin: EdgeInsets.all(scaledSize * 0.12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: MemoryImage(iconBytes),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        if (showLabel) ...[
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
      ],
    );
  }
}

class FloatingAppIcon extends ConsumerStatefulWidget {
  final AppInfo app;
  final bool isFloating;
  final VoidCallback? onLongPress;
  final bool showLabel;

  const FloatingAppIcon({
    super.key,
    required this.app,
    this.isFloating = true,
    this.onLongPress,
    this.showLabel = false,
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

  Future<void> _savePosition(double x, double y) async {
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

    final screenHeight = MediaQuery.of(context).size.height;
    // Dynamic size scaling: Shrink to 52.0 if in the dock area (bottom 190px)
    final double iconSize = yPos > (screenHeight - 190.sh(context)) ? 52.0.sw(context) : 64.0.sw(context);

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
        child: Draggable<AppInfo>(
          data: widget.app,
          feedback: Material(
            color: Colors.transparent,
            child: Opacity(
              opacity: 0.7,
              child: AppIconContent(
                app: widget.app,
                showLabel: widget.showLabel,
                size: iconSize,
              ),
            ),
          ),
          childWhenDragging: const SizedBox.shrink(),
          onDragEnd: (details) async {
            final RenderBox stackBox = context.findAncestorRenderObjectOfType<RenderBox>()!;
            final localPos = stackBox.globalToLocal(details.offset);
            
            setState(() {
              xPos = localPos.dx;
              yPos = localPos.dy;
            });
            widget.app.xPos = xPos;
            widget.app.yPos = yPos;
            await _savePosition(xPos, yPos);
          },
          child: AppIconContent(app: widget.app, showLabel: widget.showLabel, size: iconSize),
        ),
      ),
    );
  }
}

class AppIconContent extends ConsumerWidget {
  final AppInfo app;
  final bool showLabel;
  final double size;
  const AppIconContent({super.key, required this.app, this.showLabel = true, this.size = 64.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeMoodProvider);
    final iconStyle = ref.watch(iconStyleProvider).value ?? AppIconStyle.box;
    final processedIcon = ref.watch(processedIconProvider(app.iconBytes));

    return processedIcon.when(
      data: (iconBytes) => iconStyle == AppIconStyle.box
          ? StyledAppIcon(app: app, theme: theme, iconBytes: iconBytes, showLabel: showLabel, size: size)
          : StyledAppIconTwo(app: app, theme: theme, iconBytes: iconBytes, showLabel: showLabel, size: size),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => iconStyle == AppIconStyle.box
          ? StyledAppIcon(app: app, theme: theme, iconBytes: app.iconBytes, showLabel: showLabel, size: size)
          : StyledAppIconTwo(app: app, theme: theme, iconBytes: app.iconBytes, showLabel: showLabel, size: size),
    );
  }
}
