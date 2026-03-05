import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class CustomizationOptionsWidget extends StatelessWidget {
  final double iconSize;
  final double shadowIntensity;
  final bool glossyEffect;
  final ValueChanged<double> onIconSizeChanged;
  final ValueChanged<double> onShadowIntensityChanged;
  final ValueChanged<bool> onGlossyToggled;

  const CustomizationOptionsWidget({
    super.key,
    required this.iconSize,
    required this.shadowIntensity,
    required this.glossyEffect,
    required this.onIconSizeChanged,
    required this.onShadowIntensityChanged,
    required this.onGlossyToggled,
  });

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
      child: Column(
        children: [
          _SliderOption(
            iconName: 'open_with',
            label: 'Icon Size',
            value: iconSize,
            min: 36.0,
            max: 80.0,
            displayValue: '${iconSize.round()} px',
            onChanged: onIconSizeChanged,
            previewWidget: _IconSizePreview(size: iconSize),
          ),
          Divider(
            height: 1,
            color: AppTheme.primaryLight.withValues(alpha: 0.1),
            indent: 16,
            endIndent: 16,
          ),
          _SliderOption(
            iconName: 'blur_on',
            label: 'Shadow Intensity',
            value: shadowIntensity,
            min: 0.0,
            max: 1.0,
            displayValue: '${(shadowIntensity * 100).round()}%',
            onChanged: onShadowIntensityChanged,
            previewWidget: _ShadowPreview(intensity: shadowIntensity),
          ),
          Divider(
            height: 1,
            color: AppTheme.primaryLight.withValues(alpha: 0.1),
            indent: 16,
            endIndent: 16,
          ),
          _ToggleOption(
            iconName: 'auto_awesome',
            label: 'Glossy Effect',
            subtitle: 'Adds realistic shine to icons',
            value: glossyEffect,
            onChanged: onGlossyToggled,
          ),
        ],
      ),
    );
  }
}

class _SliderOption extends StatelessWidget {
  final String iconName;
  final String label;
  final double value;
  final double min;
  final double max;
  final String displayValue;
  final ValueChanged<double> onChanged;
  final Widget previewWidget;

  const _SliderOption({
    required this.iconName,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.displayValue,
    required this.onChanged,
    required this.previewWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
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
                  iconName: iconName,
                  color: AppTheme.primaryLight,
                  size: 18,
                ),
              ),
              SizedBox(width: 2.w),
              Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  displayValue,
                  style: TextStyle(
                    color: AppTheme.primaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              previewWidget,
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryLight,
              inactiveTrackColor: AppTheme.primaryLight.withValues(alpha: 0.2),
              thumbColor: AppTheme.primaryLight,
              overlayColor: AppTheme.primaryLight.withValues(alpha: 0.15),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String iconName;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleOption({
    required this.iconName,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.all(3.w),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: AppTheme.primaryLight,
              size: 18,
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.titleSmall),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          _SkeuomorphicSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _SkeuomorphicSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SkeuomorphicSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: AppTheme.animationNormal,
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: value
              ? const LinearGradient(
            colors: [AppTheme.secondaryLight, AppTheme.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : LinearGradient(
            colors: [Colors.grey.shade300, Colors.grey.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: value
                  ? AppTheme.primaryLight.withValues(alpha: 0.4)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: AnimatedAlign(
          duration: AppTheme.animationNormal,
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: AppTheme.elevationShadowLow,
            ),
          ),
        ),
      ),
    );
  }
}

class _IconSizePreview extends StatelessWidget {
  final double size;
  const _IconSizePreview({required this.size});

  @override
  Widget build(BuildContext context) {
    final previewSize = (size / 80 * 36).clamp(18.0, 36.0);
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: previewSize,
        height: previewSize,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(previewSize * 0.25),
          gradient: const LinearGradient(
            colors: [AppTheme.secondaryLight, AppTheme.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: AppTheme.elevationShadowLow,
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: 'apps',
            color: Colors.white,
            size: previewSize * 0.55,
          ),
        ),
      ),
    );
  }
}

class _ShadowPreview extends StatelessWidget {
  final double intensity;
  const _ShadowPreview({required this.intensity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: AppTheme.primaryLight,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryVariantLight.withValues(alpha: intensity),
              blurRadius: 8 * intensity,
              offset: Offset(0, 4 * intensity),
            ),
          ],
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: 'star',
            color: Colors.white,
            size: 14,
          ),
        ),
      ),
    );
  }
}
