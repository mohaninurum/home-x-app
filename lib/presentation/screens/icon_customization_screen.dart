import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';
import '../providers.dart';
import '../theme_provider.dart';
import '../../domain/icon_customization.dart';
import '../widgets/floating_app_icon.dart';
import '../../core/responsive_utils.dart';
import '../../domain/app_info.dart';

class IconCustomizationScreen extends ConsumerWidget {
  const IconCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeMoodProvider);
    final customization =
        ref.watch(iconCustomizationProvider).value ?? const IconCustomization();
    final apps = ref.watch(appsProvider).value ?? [];

    // Pick the first app for preview, or a fallback.
    final AppInfo previewApp = apps.isNotEmpty
        ? apps.first
        : AppInfo(
            packageName: 'com.example.preview',
            label: 'Preview App',
            iconBytes: Uint8List(0),
          );

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Customize Icons",
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 20.wsp(context),
            letterSpacing: 1.0,
          ),
        ),
        iconTheme: IconThemeData(color: theme.primaryColor),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Professional Preview Area
            Container(
              height: 220.sh(context),
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                horizontal: 20.sw(context),
                vertical: 10.sh(context),
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: BorderRadius.circular(30.sw(context)),
                border: Border.all(
                  color: Colors.white.withOpacity(0.08),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.primaryColor.withOpacity(0.05),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30.sw(context)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Subtle background grid or gradient effect could go here
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 150.sw(context),
                          height: 150.sw(context),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.primaryColor.withOpacity(0.15),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -40,
                        left: -60,
                        child: Container(
                          width: 120.sw(context),
                          height: 120.sw(context),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.secondaryColor.withOpacity(0.1),
                          ),
                        ),
                      ),
                      // Core Preview
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "LIVE PREVIEW",
                            style: TextStyle(
                              color: theme.primaryColor.withOpacity(0.8),
                              fontSize: 12.wsp(context),
                              letterSpacing: 2.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 20.sh(context)),
                          SizedBox(
                            width: 150.sw(context), // Extended size for safety
                            height: 120.sh(context),
                            child: Center(
                              child: AppIconContent(
                                app: previewApp,
                                showLabel: true,
                                size: 55.sw(context), // Scaled base size
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.sh(context)),
            // Controls List
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 20.sw(context),
                  vertical: 10.sh(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildGlassCard(
                      context: context,
                      theme: theme,
                      title: "Shape & Sizing",
                      icon: Icons.aspect_ratio_rounded,
                      children: [
                        _buildSlider(
                          context: context,
                          theme: theme,
                          label: "Icon Scale",
                          value: customization.sizeMultiplier,
                          min: 0.5,
                          max: 1.5,
                          onChanged: (val) => ref
                              .read(iconCustomizationProvider.notifier)
                              .updateCustomization(sizeMultiplier: val),
                        ),
                        SizedBox(height: 20.sh(context)),
                        _buildSlider(
                          context: context,
                          theme: theme,
                          label: "Corner Radius (Box)",
                          value: customization.borderRadiusMultiplier,
                          min: 0.0,
                          max: 2.0,
                          onChanged: (val) => ref
                              .read(iconCustomizationProvider.notifier)
                              .updateCustomization(borderRadiusMultiplier: val),
                        ),
                      ],
                    ),

                    _buildGlassCard(
                      context: context,
                      theme: theme,
                      title: "Depth & Lighting",
                      icon: Icons.flare_rounded,
                      children: [
                        _buildSlider(
                          context: context,
                          theme: theme,
                          label: "Shadow Intensity",
                          value: customization.shadowMultiplier,
                          min: 0.0,
                          max: 2.0,
                          onChanged: (val) => ref
                              .read(iconCustomizationProvider.notifier)
                              .updateCustomization(shadowMultiplier: val),
                        ),
                      ],
                    ),

                    _buildGlassCard(
                      context: context,
                      theme: theme,
                      title: "Typography",
                      icon: Icons.format_size_rounded,
                      children: [
                        _buildSlider(
                          context: context,
                          theme: theme,
                          label: "Label Size",
                          value: customization.textSizeMultiplier,
                          min: 0.5,
                          max: 2.0,
                          onChanged: (val) => ref
                              .read(iconCustomizationProvider.notifier)
                              .updateCustomization(textSizeMultiplier: val),
                        ),
                        SizedBox(height: 20.sh(context)),
                        _buildSlider(
                          context: context,
                          theme: theme,
                          label: "Vertical Spacing",
                          value: customization.spacingMultiplier,
                          min: 0.0,
                          max: 3.0,
                          onChanged: (val) => ref
                              .read(iconCustomizationProvider.notifier)
                              .updateCustomization(spacingMultiplier: val),
                        ),
                      ],
                    ),

                    _buildGlassCard(
                      context: context,
                      theme: theme,
                      title: "Aesthetics",
                      icon: Icons.palette_rounded,
                      children: [
                        _buildColorPicker(
                          context: context,
                          theme: theme,
                          customization: customization,
                          ref: ref,
                        ),
                      ],
                    ),

                    SizedBox(height: 20.sh(context)),

                    // Reset Button
                    Container(
                      margin: EdgeInsets.only(
                        bottom: 40.sh(context),
                        top: 10.sh(context),
                      ),
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.primaryColor,
                          side: BorderSide(
                            color: theme.primaryColor.withOpacity(0.2),
                          ),
                          padding: EdgeInsets.symmetric(
                            vertical: 18.sh(context),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.sw(context)),
                          ),
                          backgroundColor: theme.primaryColor.withOpacity(0.05),
                        ),
                        onPressed: () {
                          ref
                              .read(iconCustomizationProvider.notifier)
                              .resetToDefaults();
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        label: Text(
                          "Reset to Defaults",
                          style: TextStyle(
                            fontSize: 16.wsp(context),
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({
    required BuildContext context,
    required dynamic theme,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.sh(context)),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03), // Subtle base
        borderRadius: BorderRadius.circular(25.sw(context)),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.sw(context)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: EdgeInsets.all(24.sw(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.sw(context)),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.sw(context)),
                      ),
                      child: Icon(
                        icon,
                        color: theme.primaryColor,
                        size: 18.sw(context),
                      ),
                    ),
                    SizedBox(width: 15.sw(context)),
                    Text(
                      title,
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: 17.wsp(context),
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25.sh(context)),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required BuildContext context,
    required dynamic theme,
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 15.wsp(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.sw(context),
                vertical: 4.sh(context),
              ),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10.sw(context)),
                border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
              ),
              child: Text(
                "${(value * 100).toInt()}%",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.wsp(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.sh(context)),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: theme.primaryColor,
            inactiveTrackColor: Colors.white.withOpacity(0.1),
            thumbColor: Colors.white,
            overlayColor: theme.primaryColor.withOpacity(0.2),
            trackHeight: 6.sh(context),
            thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 8.sw(context),
            ),
            overlayShape: RoundSliderOverlayShape(
              overlayRadius: 20.sw(context),
            ),
          ),
          child: Slider(value: value, min: min, max: max, onChanged: onChanged),
        ),
      ],
    );
  }

  Widget _buildColorPicker({
    required BuildContext context,
    required dynamic theme,
    required IconCustomization customization,
    required WidgetRef ref,
  }) {
    final List<Color> presetColors = [
      Colors.black,
      Colors.white,
      Colors.redAccent,
      Colors.blueAccent,
      Colors.greenAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.tealAccent,
      Colors.pinkAccent,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Solid Background Cache",
              style: TextStyle(
                color: theme.primaryColor,
                fontSize: 15.wsp(context),
                fontWeight: FontWeight.w500,
              ),
            ),
            if (customization.backgroundColorValue != null)
              GestureDetector(
                onTap: () => ref
                    .read(iconCustomizationProvider.notifier)
                    .updateCustomization(clearBackgroundColor: true),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.sw(context),
                    vertical: 6.sh(context),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10.sw(context)),
                  ),
                  child: Text(
                    "Clear (Use Gradient)",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12.wsp(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 15.sh(context)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: presetColors.map((color) {
              final isSelected =
                  customization.backgroundColorValue == color.value;
              return GestureDetector(
                onTap: () {
                  ref
                      .read(iconCustomizationProvider.notifier)
                      .updateCustomization(backgroundColorValue: color.value);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.only(right: 15.sw(context)),
                  width: isSelected ? 48.sw(context) : 42.sw(context),
                  height: isSelected ? 48.sw(context) : 42.sw(context),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? theme.primaryColor
                          : Colors.white.withOpacity(0.1),
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: theme.primaryColor.withOpacity(0.6),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: color == Colors.white
                              ? Colors.black
                              : Colors.white,
                          size: 20.sw(context),
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
