import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../animated_analog_clock/animated_analog_clock.dart';
import '../providers.dart';
import '../theme_provider.dart';
import '../../core/responsive_utils.dart';
import '../../domain/clock_customization.dart';
import 'neo_moving_border.dart';

class CustomAnalogClockWidget extends ConsumerWidget {
  final double size;
  final ClockCustomization? customizationOverride;

  const CustomAnalogClockWidget({
    super.key, 
    this.size = 150,
    this.customizationOverride,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeMoodProvider);
    final customization = customizationOverride ?? (ref.watch(clockCustomizationProvider).value ?? const ClockCustomization());

    if (!customization.showClock && customizationOverride == null) return const SizedBox.shrink();

    final clockWidget = Container(
      width: size.sw(context),
      height: size.sw(context),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: customization.neoEffectEnabled 
            ? null 
            : (customization.borderWidth > 0 
                ? Border.all(
                    color: customization.borderColorValue != null 
                        ? Color(customization.borderColorValue!) 
                        : theme.primaryColor,
                    width: (customization.borderWidth * (size / 150)).sw(context),
                  )
                : null),
      ),
      child: AnimatedAnalogClock(
        size: size.sw(context),
        dialType: customization.dialType,
        backgroundColor: customization.backgroundColorValue != null 
            ? Color(customization.backgroundColorValue!) 
            : Colors.transparent,
        backgroundImage: customization.backgroundImagePath != null 
            ? FileImage(File(customization.backgroundImagePath!)) 
            : null,
        hourHandColor: customization.hourHandColorValue != null 
            ? Color(customization.hourHandColorValue!) 
            : null,
        minuteHandColor: customization.minuteHandColorValue != null 
            ? Color(customization.minuteHandColorValue!) 
            : null,
        secondHandColor: Color(customization.secondHandColorValue),
        hourDashColor: customization.hourDashColorValue != null 
            ? Color(customization.hourDashColorValue!) 
            : null,
        minuteDashColor: customization.minuteDashColorValue != null 
            ? Color(customization.minuteDashColorValue!) 
            : null,
        centerDotColor: customization.centerDotColorValue != null 
            ? Color(customization.centerDotColorValue!) 
            : null,
        numberColor: customization.numberColorValue != null 
            ? Color(customization.numberColorValue!) 
            : null,
        showSecondHand: customization.showSecondHand,
        extendHourHand: customization.extendHourHand,
        extendMinuteHand: customization.extendMinuteHand,
        extendSecondHand: customization.extendSecondHand,
      ),
    );

    if (customization.neoEffectEnabled) {
      return NeoMovingBorder(
        isCircle: true,
        borderWidth: (customization.neoBorderWidth * (size / 150)).sw(context),
        primaryColor: theme.secondaryColor,
        secondaryColor: theme.primaryColor,
        child: clockWidget,
      );
    }

    return clockWidget;
  }
}
