import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ColorThemeWidget extends StatelessWidget {
  final double greenIntensity;
  final ValueChanged<double> onIntensityChanged;

  const ColorThemeWidget({
    super.key,
    required this.greenIntensity,
    required this.onIntensityChanged,
  });

  Color get _previewColor {
    return Color.lerp(
      AppTheme.secondaryLight,
      AppTheme.primaryVariantLight,
      greenIntensity,
    )!;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.elevationShadowLow,
        border: Border.all(
          color: AppTheme.primaryLight.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(3.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'palette',
                  color: AppTheme.primaryLight,
                  size: 18,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Green Palette Intensity',
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(
                      'Adjust the depth of the green tone',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: _previewColor,
                    inactiveTrackColor: _previewColor.withValues(alpha: 0.2),
                    thumbColor: _previewColor,
                    overlayColor: _previewColor.withValues(alpha: 0.15),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                    ),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: greenIntensity,
                    min: 0.0,
                    max: 1.0,
                    onChanged: onIntensityChanged,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              _ColorPreviewBall(color: _previewColor),
            ],
          ),
          SizedBox(height: 1.5.h),
          _ColorSwatchRow(
            selectedIntensity: greenIntensity,
            onSelected: onIntensityChanged,
          ),
        ],
      ),
    );
  }
}

class _ColorPreviewBall extends StatelessWidget {
  final Color color;
  const _ColorPreviewBall({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Color.lerp(color, Colors.white, 0.4)!,
            color,
            Color.lerp(color, Colors.black, 0.3)!,
          ],
          stops: const [0.0, 0.5, 1.0],
          center: const Alignment(-0.3, -0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
    );
  }
}

class _ColorSwatchRow extends StatelessWidget {
  final double selectedIntensity;
  final ValueChanged<double> onSelected;

  const _ColorSwatchRow({
    required this.selectedIntensity,
    required this.onSelected,
  });

  static const List<Map<String, dynamic>> _swatches = [
    {"label": "Mint", "value": 0.0},
    {"label": "Sage", "value": 0.25},
    {"label": "Forest", "value": 0.5},
    {"label": "Deep", "value": 0.75},
    {"label": "Dark", "value": 1.0},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: _swatches.map((swatch) {
        final double val = swatch["value"] as double;
        final bool isSelected = (selectedIntensity - val).abs() < 0.15;
        final Color swatchColor = Color.lerp(
          AppTheme.secondaryLight,
          AppTheme.primaryVariantLight,
          val,
        )!;
        return GestureDetector(
          onTap: () => onSelected(val),
          child: Column(
            children: [
              AnimatedContainer(
                duration: AppTheme.animationNormal,
                width: isSelected ? 36 : 28,
                height: isSelected ? 36 : 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: swatchColor,
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: swatchColor.withValues(alpha: 0.6),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                      : AppTheme.elevationShadowLow,
                  border: Border.all(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.3),
                    width: isSelected ? 2.5 : 1,
                  ),
                ),
                child: isSelected
                    ? Center(
                  child: CustomIconWidget(
                    iconName: 'check',
                    color: Colors.white,
                    size: 16,
                  ),
                )
                    : null,
              ),
              SizedBox(height: 0.5.h),
              Text(
                swatch["label"] as String,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isSelected
                      ? AppTheme.primaryLight
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
