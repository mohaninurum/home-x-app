import '../../animated_analog_clock/animated_analog_clock.dart';

class ClockCustomization {
  final DialType dialType;
  final String? backgroundImagePath;
  final int? backgroundColorValue;
  final int? hourHandColorValue;
  final int? minuteHandColorValue;
  final int secondHandColorValue;
  final int? hourDashColorValue;
  final int? minuteDashColorValue;
  final int? centerDotColorValue;
  final int? numberColorValue;
  final bool showSecondHand;
  final bool extendHourHand;
  final bool extendMinuteHand;
  final bool extendSecondHand;
  final bool hourlyChimeEnabled;

  const ClockCustomization({
    this.dialType = DialType.dashes,
    this.backgroundImagePath,
    this.backgroundColorValue,
    this.hourHandColorValue,
    this.minuteHandColorValue,
    this.secondHandColorValue = 0xFFFA1E1E,
    this.hourDashColorValue,
    this.minuteDashColorValue,
    this.centerDotColorValue,
    this.numberColorValue,
    this.showSecondHand = true,
    this.extendHourHand = false,
    this.extendMinuteHand = false,
    this.extendSecondHand = true,
    this.hourlyChimeEnabled = false,
  });

  ClockCustomization copyWith({
    DialType? dialType,
    String? backgroundImagePath,
    int? backgroundColorValue,
    int? hourHandColorValue,
    int? minuteHandColorValue,
    int? secondHandColorValue,
    int? hourDashColorValue,
    int? minuteDashColorValue,
    int? centerDotColorValue,
    int? numberColorValue,
    bool? showSecondHand,
    bool? extendHourHand,
    bool? extendMinuteHand,
    bool? extendSecondHand,
    bool? hourlyChimeEnabled,
    bool clearBackgroundImage = false,
    bool clearBackgroundColor = false,
    bool clearHourHandColor = false,
    bool clearMinuteHandColor = false,
    bool clearHourDashColor = false,
    bool clearMinuteDashColor = false,
    bool clearCenterDotColor = false,
    bool clearNumberColor = false,
  }) {
    return ClockCustomization(
      dialType: dialType ?? this.dialType,
      backgroundImagePath: clearBackgroundImage ? null : (backgroundImagePath ?? this.backgroundImagePath),
      backgroundColorValue: clearBackgroundColor ? null : (backgroundColorValue ?? this.backgroundColorValue),
      hourHandColorValue: clearHourHandColor ? null : (hourHandColorValue ?? this.hourHandColorValue),
      minuteHandColorValue: clearMinuteHandColor ? null : (minuteHandColorValue ?? this.minuteHandColorValue),
      secondHandColorValue: secondHandColorValue ?? this.secondHandColorValue,
      hourDashColorValue: clearHourDashColor ? null : (hourDashColorValue ?? this.hourDashColorValue),
      minuteDashColorValue: clearMinuteDashColor ? null : (minuteDashColorValue ?? this.minuteDashColorValue),
      centerDotColorValue: clearCenterDotColor ? null : (centerDotColorValue ?? this.centerDotColorValue),
      numberColorValue: clearNumberColor ? null : (numberColorValue ?? this.numberColorValue),
      showSecondHand: showSecondHand ?? this.showSecondHand,
      extendHourHand: extendHourHand ?? this.extendHourHand,
      extendMinuteHand: extendMinuteHand ?? this.extendMinuteHand,
      extendSecondHand: extendSecondHand ?? this.extendSecondHand,
      hourlyChimeEnabled: hourlyChimeEnabled ?? this.hourlyChimeEnabled,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'dialType': dialType.index,
      'backgroundImagePath': backgroundImagePath,
      'backgroundColorValue': backgroundColorValue,
      'hourHandColorValue': hourHandColorValue,
      'minuteHandColorValue': minuteHandColorValue,
      'secondHandColorValue': secondHandColorValue,
      'hourDashColorValue': hourDashColorValue,
      'minuteDashColorValue': minuteDashColorValue,
      'centerDotColorValue': centerDotColorValue,
      'numberColorValue': numberColorValue,
      'showSecondHand': showSecondHand,
      'extendHourHand': extendHourHand,
      'extendMinuteHand': extendMinuteHand,
      'extendSecondHand': extendSecondHand,
      'hourlyChimeEnabled': hourlyChimeEnabled,
    };
  }

  factory ClockCustomization.fromMap(Map<String, dynamic> map) {
    return ClockCustomization(
      dialType: DialType.values[map['dialType'] as int? ?? 0],
      backgroundImagePath: map['backgroundImagePath'] as String?,
      backgroundColorValue: map['backgroundColorValue'] as int?,
      hourHandColorValue: map['hourHandColorValue'] as int?,
      minuteHandColorValue: map['minuteHandColorValue'] as int?,
      secondHandColorValue: map['secondHandColorValue'] as int? ?? 0xFFFA1E1E,
      hourDashColorValue: map['hourDashColorValue'] as int?,
      minuteDashColorValue: map['minuteDashColorValue'] as int?,
      centerDotColorValue: map['centerDotColorValue'] as int?,
      numberColorValue: map['numberColorValue'] as int?,
      showSecondHand: map['showSecondHand'] as bool? ?? true,
      extendHourHand: map['extendHourHand'] as bool? ?? false,
      extendMinuteHand: map['extendMinuteHand'] as bool? ?? false,
      extendSecondHand: map['extendSecondHand'] as bool? ?? true,
      hourlyChimeEnabled: map['hourlyChimeEnabled'] as bool? ?? false,
    );
  }
}
