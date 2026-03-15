import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../animated_analog_clock/animated_analog_clock.dart';
import '../providers.dart';
import '../../core/responsive_utils.dart';
import '../../domain/clock_customization.dart';

class CustomAnalogClockWidget extends ConsumerWidget {
  final double size;

  const CustomAnalogClockWidget({super.key, this.size = 150});

    final theme = ref.watch(themeMoodProvider);
    final customization = ref.watch(clockCustomizationProvider).value ?? const ClockCustomization();

    if (!customization.showClock) return const SizedBox.shrink();

    return Container(
      width: size.sw(context),
      height: size.sw(context),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: customization.borderWidth > 0 
            ? Border.all(
                color: customization.borderColorValue != null 
                    ? Color(customization.borderColorValue!) 
                    : theme.primaryColor,
                width: customization.borderWidth.sw(context),
              )
            : null,
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
  }
}
