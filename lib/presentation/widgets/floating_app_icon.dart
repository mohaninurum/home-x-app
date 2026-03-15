import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../../domain/app_info.dart';
import '../../domain/icon_customization.dart';
import '../providers.dart';
import '../theme_provider.dart';
import '../../core/mood_theme.dart';
import '../../core/responsive_utils.dart';

class StyledAppIcon extends ConsumerWidget {
  final AppInfo app;
  final MoodTheme theme;
  final ImageProvider imageProvider;
  final bool showLabel;
  final double size;


  const StyledAppIcon({
    super.key,
    required this.app,
    required this.theme,
    required this.imageProvider,
    this.showLabel = true,
    this.size = 64.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customization = ref.watch(iconCustomizationProvider).value ?? const IconCustomization();
    final double customSize = (size * customization.sizeMultiplier);
    final double scaledSize = customSize.sw(context);
    
    // Calculate pulse, glow, and shadows with custom multipliers
    const double pulseValue = 1.0;
    final double shadowMult = customization.shadowMultiplier;
    final double glowSpread = (theme.mood == AppMood.hologram ? 4.0 : 1.0) * shadowMult;
    final double glowBlur = (theme.mood == AppMood.hologram ? 20.0 : 10.0) * shadowMult;
    
    // Border Radius with customization factor
    final double borderRadiusVal = scaledSize * 0.25 * customization.borderRadiusMultiplier;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: scaledSize,
          height: scaledSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadiusVal),
            color: customization.backgroundColorValue != null 
                ? Color(customization.backgroundColorValue!)
                : null,
            gradient: customization.backgroundColorValue == null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primaryColor.withOpacity(0.6),
                    theme.backgroundColor,
                    theme.secondaryColor.withOpacity(0.2),
                  ],
                )
              : null,
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
                offset: Offset(customSize * 0.09, customSize * 0.15) * shadowMult,
                blurRadius: customSize * 0.23 * shadowMult,
              ),
              // Sharp ground contact shadow
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                offset: Offset(customSize * 0.03, customSize * 0.05) * shadowMult,
                blurRadius: customSize * 0.06 * shadowMult,
              ),
              // Top-left outer rim highlight
              BoxShadow(
                color: Colors.white.withOpacity(0.6),
                offset: Offset(-scaledSize * 0.03, -scaledSize * 0.03) * shadowMult,
                blurRadius: scaledSize * 0.06 * shadowMult,
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
              borderRadius: BorderRadius.circular(customSize * 0.22 * customization.borderRadiusMultiplier),
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
            padding: EdgeInsets.all(app.customImagePath != null ? 0 : scaledSize * 0.18),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(app.customImagePath != null ? borderRadiusVal : customSize * 0.22 * customization.borderRadiusMultiplier),
              child: Image(
                image: imageProvider,
                fit: app.customImagePath != null ? BoxFit.cover : BoxFit.contain,
                filterQuality: FilterQuality.high,
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded || frame != null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.primaryColor,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        if (showLabel) ...[
          SizedBox(height: 8 * customization.spacingMultiplier),
          Flexible(
            child: Container(
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
                  fontSize: 10 * customization.textSizeMultiplier,
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
          ),
        ],
      ],
    );
  }
}

class StyledAppIconTwo extends ConsumerWidget {
  final AppInfo app;
  final MoodTheme theme;
  final ImageProvider imageProvider;
  final bool showLabel;
  final double size;


  const StyledAppIconTwo({
    super.key,
    required this.app,
    required this.theme,
    required this.imageProvider,
    this.showLabel = true,
    this.size = 64.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customization = ref.watch(iconCustomizationProvider).value ?? const IconCustomization();
    final double customSize = (size * customization.sizeMultiplier);
    final double scaledSize = customSize.sw(context);
    
    // Calculate pulse, glow, and shadows with custom multipliers
    const double pulseValue = 1.0;
    final double shadowMult = customization.shadowMultiplier;
    final double glowSpread = (theme.mood == AppMood.hologram ? 4.0 : 1.0) * shadowMult;
    final double glowBlur = (theme.mood == AppMood.hologram ? 20.0 : 10.0) * shadowMult;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: scaledSize,
          height: scaledSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: customization.backgroundColorValue != null 
                ? Color(customization.backgroundColorValue!)
                : null,
            gradient: customization.backgroundColorValue == null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.primaryColor.withOpacity(0.4),
                    theme.secondaryColor.withOpacity(0.1),
                  ],
                )
              : null,
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
                offset: Offset(customSize * 0.06, customSize * 0.06) * shadowMult,
                blurRadius: customSize * 0.12 * shadowMult,
              ),
              // Inner Highlight (Top Edge - Skeuomorphism)
              BoxShadow(
                color: Colors.white.withOpacity(0.4),
                offset: Offset(-scaledSize * 0.03, -scaledSize * 0.03) * shadowMult,
                blurRadius: scaledSize * 0.06 * shadowMult,
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
            margin: EdgeInsets.all(app.customImagePath != null ? 0 : scaledSize * 0.12),
            child: Image(
              image: imageProvider,
              fit: app.customImagePath != null ? BoxFit.cover : BoxFit.contain,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded || frame != null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.primaryColor,
                  ),
                );
              },
            ),
          ),
        ),
        if (showLabel) ...[
          SizedBox(height: 8 * customization.spacingMultiplier),
          Flexible(
            child: Container(
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
                  fontSize: 10 * customization.textSizeMultiplier,
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
    final isEditMode = ref.watch(editModeProvider);

    if (!widget.isFloating) {
      return GestureDetector(
        onTap: () {
          ref.read(nativeAppServiceProvider).launchApp(widget.app.packageName);
        },
        onLongPress: widget.onLongPress,
        child: AppIconContent(app: widget.app),
      );
    }

    final double iconSize = 64.0.sw(context);

    return Positioned(
      left: xPos,
      top: yPos,
      child: GestureDetector(
        onTap: () {
          ref.read(nativeAppServiceProvider).launchApp(widget.app.packageName);
        },
        onLongPress: () async {
          if (widget.onLongPress != null) {
            widget.onLongPress!();
            return;
          }
          final theme = ref.read(themeMoodProvider);
          final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
          final RenderBox button = context.findRenderObject() as RenderBox;
          final Offset position = button.localToGlobal(Offset.zero);

          final result = await showMenu<String>(
            context: context,
            position: RelativeRect.fromLTRB(
              position.dx,
              position.dy,
              overlay.size.width - position.dx,
              overlay.size.height - position.dy,
            ),
            color: theme.backgroundColor.withOpacity(0.95),
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            items: [
              PopupMenuItem<String>(
                value: 'remove',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: theme.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      "Remove from Home",
                      style: TextStyle(color: theme.primaryColor, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          );

          if (result == 'remove') {
            ref.read(homeAppsProvider.notifier).removeApp(widget.app.packageName);
          }
        },
        child: Draggable<AppInfo>(
          data: widget.app,
          maxSimultaneousDrags: isEditMode ? 1 : 0,
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
          child: AppIconContent(
            app: widget.app,
            showLabel: widget.showLabel,
            size: iconSize,
          ),
        ),
      ),
    );
  }
}

class AppIconContent extends ConsumerWidget {
  final AppInfo app;
  final bool showLabel;
  final double size;


  const AppIconContent({
    super.key,
    required this.app,
    this.showLabel = true,
    this.size = 64.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeMoodProvider);
    final iconStyle = ref.watch(iconStyleProvider).value ?? AppIconStyle.box;

    if (app.customImagePath != null) {
      final imageFile = File(app.customImagePath!);
      if (imageFile.existsSync()) {
        final imageProvider = FileImage(imageFile);
        return iconStyle == AppIconStyle.box
            ? StyledAppIcon(
                app: app,
                theme: theme,
                imageProvider: imageProvider,
                showLabel: showLabel,
                size: size,
              )
            : StyledAppIconTwo(
                app: app,
                theme: theme,
                imageProvider: imageProvider,
                showLabel: showLabel,
                size: size,
              );
      }
    }

    final processedIcon = ref.watch(processedIconProvider(app.iconBytes));

    return processedIcon.when(
      data: (iconBytes) => iconStyle == AppIconStyle.box
          ? StyledAppIcon(
              app: app,
              theme: theme,
              imageProvider: MemoryImage(iconBytes),
              showLabel: showLabel,
              size: size,
            )
          : StyledAppIconTwo(
              app: app,
              theme: theme,
              imageProvider: MemoryImage(iconBytes),
              showLabel: showLabel,
              size: size,
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => iconStyle == AppIconStyle.box
          ? StyledAppIcon(
              app: app,
              theme: theme,
              imageProvider: MemoryImage(app.iconBytes),
              showLabel: showLabel,
              size: size,
            )
          : StyledAppIconTwo(
              app: app,
              theme: theme,
              imageProvider: MemoryImage(app.iconBytes),
              showLabel: showLabel,
              size: size,
            ),
    );
  }
}
