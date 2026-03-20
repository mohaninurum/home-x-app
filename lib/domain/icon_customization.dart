class IconCustomization {
  final double sizeMultiplier;
  final double shadowMultiplier;
  final double borderRadiusMultiplier;
  final double textSizeMultiplier;
  final double spacingMultiplier;
  final int? backgroundColorValue; // Null means default theme gradient

  const IconCustomization({
    this.sizeMultiplier = 1.0,
    this.shadowMultiplier = 1.0,
    this.borderRadiusMultiplier = 1.0,
    this.textSizeMultiplier = 1.0,
    this.spacingMultiplier = 1.0,
    this.backgroundColorValue,
  });

  Map<String, dynamic> toMap() {
    return {
      'sizeMultiplier': sizeMultiplier,
      'shadowMultiplier': shadowMultiplier,
      'borderRadiusMultiplier': borderRadiusMultiplier,
      'textSizeMultiplier': textSizeMultiplier,
      'spacingMultiplier': spacingMultiplier,
      'backgroundColorValue': backgroundColorValue,
    };
  }

  factory IconCustomization.fromMap(Map<String, dynamic> map) {
    return IconCustomization(
      sizeMultiplier: (map['sizeMultiplier'] as num?)?.toDouble() ?? 1.0,
      shadowMultiplier: (map['shadowMultiplier'] as num?)?.toDouble() ?? 1.0,
      borderRadiusMultiplier:
          (map['borderRadiusMultiplier'] as num?)?.toDouble() ?? 1.0,
      textSizeMultiplier:
          (map['textSizeMultiplier'] as num?)?.toDouble() ?? 1.0,
      spacingMultiplier: (map['spacingMultiplier'] as num?)?.toDouble() ?? 1.0,
      backgroundColorValue: map['backgroundColorValue'] as int?,
    );
  }

  IconCustomization copyWith({
    double? sizeMultiplier,
    double? shadowMultiplier,
    double? borderRadiusMultiplier,
    double? textSizeMultiplier,
    double? spacingMultiplier,
    int? backgroundColorValue,
    bool clearBackgroundColor = false, // Helper to specifically nullify
  }) {
    return IconCustomization(
      sizeMultiplier: sizeMultiplier ?? this.sizeMultiplier,
      shadowMultiplier: shadowMultiplier ?? this.shadowMultiplier,
      borderRadiusMultiplier:
          borderRadiusMultiplier ?? this.borderRadiusMultiplier,
      textSizeMultiplier: textSizeMultiplier ?? this.textSizeMultiplier,
      spacingMultiplier: spacingMultiplier ?? this.spacingMultiplier,
      backgroundColorValue: clearBackgroundColor
          ? null
          : (backgroundColorValue ?? this.backgroundColorValue),
    );
  }
}
