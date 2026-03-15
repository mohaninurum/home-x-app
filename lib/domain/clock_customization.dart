import '../../animated_analog_clock/animated_analog_clock.dart';

enum SpeakType { hindi, rathvi }

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
  final SpeakType speakType;
  final bool showClock;
  final double borderWidth;
  final int? borderColorValue;

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
    this.speakType = SpeakType.hindi,
    this.showClock = true,
    this.borderWidth = 0.0,
    this.borderColorValue,
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
    SpeakType? speakType,
    bool? showClock,
    double? borderWidth,
    int? borderColorValue,
    bool clearBackgroundImage = false,
    bool clearBackgroundColor = false,
    bool clearHourHandColor = false,
    bool clearMinuteHandColor = false,
    bool clearHourDashColor = false,
    bool clearMinuteDashColor = false,
    bool clearCenterDotColor = false,
    bool clearNumberColor = false,
    bool clearBorderColor = false,
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
      speakType: speakType ?? this.speakType,
      showClock: showClock ?? this.showClock,
      borderWidth: borderWidth ?? this.borderWidth,
      borderColorValue: clearBorderColor ? null : (borderColorValue ?? this.borderColorValue),
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
      'speakType': speakType.index,
      'showClock': showClock,
      'borderWidth': borderWidth,
      'borderColorValue': borderColorValue,
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
      speakType: SpeakType.values[map['speakType'] as int? ?? 0],
      showClock: map['showClock'] as bool? ?? true,
      borderWidth: (map['borderWidth'] as num?)?.toDouble() ?? 0.0,
      borderColorValue: map['borderColorValue'] as int?,
    );
  }
}
