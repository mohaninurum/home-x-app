import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/color_theme_widget.dart';
import './widgets/customization_options_widget.dart';
import './widgets/download_packs_widget.dart';
import './widgets/icon_pack_card_widget.dart';
import './widgets/pack_preview_modal_widget.dart';

class IconPackSettingsScreen extends StatefulWidget {
  const IconPackSettingsScreen({super.key});

  @override
  State<IconPackSettingsScreen> createState() => _IconPackSettingsScreenState();
}

class _IconPackSettingsScreenState extends State<IconPackSettingsScreen> {
  double _iconSize = 56.0;
  double _shadowIntensity = 0.7;
  bool _glossyEffect = true;
  double _greenIntensity = 0.8;
  int? _previewPackIndex;

  final List<Map<String, dynamic>> _iconPacks = [
    {
      "id": 1,
      "name": "Skeuomorph Classic",
      "iconCount": 128,
      "installed": true,
      "active": true,
      "size": "45 MB",
      "thumbnail":
      "https://img.rocket.new/generatedImages/rocket_gen_img_1be848215-1772708754166.png",
      "semanticLabel":
      "Classic skeuomorphic icon pack with realistic 3D green-toned icons",
      "sampleIcons": [
        {"icon": "phone", "label": "Phone"},
        {"icon": "camera_alt", "label": "Camera"},
        {"icon": "message", "label": "Messages"},
        {"icon": "settings", "label": "Settings"},
        {"icon": "mail", "label": "Mail"},
        {"icon": "map", "label": "Maps"},
      ],
    },
    {
      "id": 2,
      "name": "Nature 3D",
      "iconCount": 96,
      "installed": true,
      "active": false,
      "size": "38 MB",
      "thumbnail":
      "https://img.rocket.new/generatedImages/rocket_gen_img_1e2def019-1772708755921.png",
      "semanticLabel":
      "Nature-themed 3D icon pack with organic textures and green tones",
      "sampleIcons": [
        {"icon": "eco", "label": "Nature"},
        {"icon": "wb_sunny", "label": "Weather"},
        {"icon": "terrain", "label": "Maps"},
        {"icon": "local_florist", "label": "Garden"},
        {"icon": "water_drop", "label": "Water"},
        {"icon": "forest", "label": "Forest"},
      ],
    },
    {
      "id": 3,
      "name": "Emerald Pro",
      "iconCount": 200,
      "installed": false,
      "active": false,
      "size": "72 MB",
      "thumbnail":
      "https://img.rocket.new/generatedImages/rocket_gen_img_1a8828191-1772708759223.png",
      "semanticLabel":
      "Premium emerald-themed icon pack with deep green glossy 3D icons",
      "sampleIcons": [
        {"icon": "diamond", "label": "Gems"},
        {"icon": "star", "label": "Favorites"},
        {"icon": "bolt", "label": "Power"},
        {"icon": "shield", "label": "Security"},
        {"icon": "workspace_premium", "label": "Premium"},
        {"icon": "auto_awesome", "label": "Magic"},
      ],
    },
    {
      "id": 4,
      "name": "Forest Dark",
      "iconCount": 150,
      "installed": false,
      "active": false,
      "size": "55 MB",
      "thumbnail":
      "https://img.rocket.new/generatedImages/rocket_gen_img_1f0130553-1772708754851.png",
      "semanticLabel":
      "Dark forest-themed icon pack with deep shadows and rich green tones",
      "sampleIcons": [
        {"icon": "nightlight", "label": "Night"},
        {"icon": "dark_mode", "label": "Dark"},
        {"icon": "visibility", "label": "Vision"},
        {"icon": "explore", "label": "Explore"},
        {"icon": "navigation", "label": "Navigate"},
        {"icon": "my_location", "label": "Location"},
      ],
    },
  ];

  void _togglePack(int index, bool value) {
    HapticFeedback.lightImpact();
    setState(() {
      for (int i = 0; i < _iconPacks.length; i++) {
        _iconPacks[i]["active"] = false;
      }
      if (value) {
        _iconPacks[index]["active"] = true;
      }
    });
  }

  void _openPreview(int index) {
    HapticFeedback.mediumImpact();
    setState(() => _previewPackIndex = index);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PackPreviewModalWidget(
        pack: _iconPacks[index],
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _applyChanges() {
    HapticFeedback.heavyImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Icon pack settings applied successfully!'),
        backgroundColor: AppTheme.primaryLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Icon Pack Settings',
        variant: CustomAppBarVariant.primary,
        showBackButton: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 3.w),
            child: _ApplyButton(onPressed: _applyChanges),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 4.w),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(title: 'Available Icon Packs', theme: theme),
                SizedBox(height: 1.5.h),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _iconPacks.length,
                  separatorBuilder: (_, __) => SizedBox(height: 1.5.h),
                  itemBuilder: (context, index) => IconPackCardWidget(
                    pack: _iconPacks[index],
                    onToggle: (val) => _togglePack(index, val),
                    onTap: () => _openPreview(index),
                  ),
                ),
                SizedBox(height: 3.h),
                _SectionHeader(title: 'Customization', theme: theme),
                SizedBox(height: 1.5.h),
                CustomizationOptionsWidget(
                  iconSize: _iconSize,
                  shadowIntensity: _shadowIntensity,
                  glossyEffect: _glossyEffect,
                  onIconSizeChanged: (v) {
                    HapticFeedback.selectionClick();
                    setState(() => _iconSize = v);
                  },
                  onShadowIntensityChanged: (v) {
                    HapticFeedback.selectionClick();
                    setState(() => _shadowIntensity = v);
                  },
                  onGlossyToggled: (v) {
                    HapticFeedback.lightImpact();
                    setState(() => _glossyEffect = v);
                  },
                ),
                SizedBox(height: 3.h),
                _SectionHeader(title: 'Color Theme', theme: theme),
                SizedBox(height: 1.5.h),
                ColorThemeWidget(
                  greenIntensity: _greenIntensity,
                  onIntensityChanged: (v) {
                    HapticFeedback.selectionClick();
                    setState(() => _greenIntensity = v);
                  },
                ),
                SizedBox(height: 3.h),
                _SectionHeader(title: 'Discover More', theme: theme),
                SizedBox(height: 1.5.h),
                const DownloadPacksWidget(),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final ThemeData theme;
  const _SectionHeader({required this.title, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(2),
            boxShadow: AppTheme.elevationShadowLow,
          ),
        ),
        SizedBox(width: 2.w),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _ApplyButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _ApplyButton({required this.onPressed});

  @override
  State<_ApplyButton> createState() => _ApplyButtonState();
}

class _ApplyButtonState extends State<_ApplyButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: AppTheme.animationFast);
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.secondaryLight,
                AppTheme.primaryLight,
                AppTheme.primaryVariantLight,
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: AppTheme.elevationShadowMedium,
            border: Border.all(
              color: AppTheme.secondaryLight.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Text(
            'Apply',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13.sp,
            ),
          ),
        ),
      ),
    );
  }
}
