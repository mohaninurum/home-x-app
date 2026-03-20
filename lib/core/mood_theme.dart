import 'package:flutter/material.dart';

enum AppMood { romantic, passion, cute, nightLove, hologram, morning, afternoon, evening, night }

enum AppIconStyle { box }

class MoodTheme {
  final AppMood mood;
  final String title;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color iconHighlightColor;
  final List<Color> backgroundGradients;

  const MoodTheme({
    required this.mood,
    required this.title,
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.iconHighlightColor,
    required this.backgroundGradients,
  });

  ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: (mood == AppMood.nightLove || mood == AppMood.night || mood == AppMood.hologram) ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        background: backgroundColor,
      ),
      scaffoldBackgroundColor: Colors.transparent, // Custom gradient support
      fontFamily: 'Roboto',
    );
  }

  static const romantic = MoodTheme(
    mood: AppMood.romantic,
    title: "Romantic",
    primaryColor: Color(0xFFE91E63),
    secondaryColor: Color(0xFFFF1744),
    backgroundColor: Color(0xFFFCE4EC),
    iconHighlightColor: Color(0xFFFF4081),
    backgroundGradients: [Color(0x66E91E63), Color(0xCCFCE4EC), Color(0x4DFF1744)],
  );

  static const passion = MoodTheme(
    mood: AppMood.passion,
    title: "Passion",
    primaryColor: Color(0xFFD50000),
    secondaryColor: Color(0xFF880E4F),
    backgroundColor: Color(0xFFFFEBEE),
    iconHighlightColor: Color(0xFFFF1744),
    backgroundGradients: [Color(0x80D50000), Color(0x99FF8A80), Color(0x4D880E4F)],
  );

  static const cute = MoodTheme(
    mood: AppMood.cute,
    title: "Cute",
    primaryColor: Color(0xFFF06292),
    secondaryColor: Color(0xFFFFA726),
    backgroundColor: Color(0xFFFFF0F5),
    iconHighlightColor: Color(0xFFF48FB1),
    backgroundGradients: [Color(0x66F06292), Color(0xCCFFF0F5), Color(0x4DFFB74D)],
  );

  static const nightLove = MoodTheme(
    mood: AppMood.nightLove,
    title: "Night Love",
    primaryColor: Color(0xFFC2185B),
    secondaryColor: Color(0xFFFF4081),
    backgroundColor: Color(0xFF15040A),
    iconHighlightColor: Color(0xFFE91E63),
    backgroundGradients: [Color(0x80C2185B), Color(0xFF1A050D), Color(0x4D4A148C)],
  );

  static const hologram = MoodTheme(
    mood: AppMood.hologram,
    title: "Hologram",
    primaryColor: Color(0xFF00E5FF),
    secondaryColor: Color(0xFFD500F9),
    backgroundColor: Color(0xFF0A0E17),
    iconHighlightColor: Color(0xFF1DE9B6),
    backgroundGradients: [Color(0x8000E5FF), Color(0xFF0A0E17), Color(0x66D500F9)],
  );

  static const morning = MoodTheme(
    mood: AppMood.morning,
    title: "Morning Light",
    primaryColor: Color(0xFFFBC02D),
    secondaryColor: Color(0xFF4FC3F7),
    backgroundColor: Color(0xFFFFFDE7),
    iconHighlightColor: Color(0xFFFFEB3B),
    backgroundGradients: [Color(0x80FBC02D), Color(0xCCFFFDE7), Color(0x4D4FC3F7)],
  );

  static const afternoon = MoodTheme(
    mood: AppMood.afternoon,
    title: "Afternoon Sky",
    primaryColor: Color(0xFF0288D1),
    secondaryColor: Color(0xFF00BCD4),
    backgroundColor: Color(0xFFE1F5FE),
    iconHighlightColor: Color(0xFF4FC3F7),
    backgroundGradients: [Color(0x800288D1), Color(0xCCE1F5FE), Color(0x4D00BCD4)],
  );

  static const evening = MoodTheme(
    mood: AppMood.evening,
    title: "Evening Sunset",
    primaryColor: Color(0xFFFF7043),
    secondaryColor: Color(0xFFAB47BC),
    backgroundColor: Color(0xFFFBE9E7),
    iconHighlightColor: Color(0xFFFF8A65),
    backgroundGradients: [Color(0x80FF7043), Color(0xCCFBE9E7), Color(0x4DAB47BC)],
  );

  static const night = MoodTheme(
    mood: AppMood.night,
    title: "Night Glow",
    primaryColor: Color(0xFF303F9F),
    secondaryColor: Color(0xFF512DA8),
    backgroundColor: Color(0xFF090B10),
    iconHighlightColor: Color(0xFF5C6BC0),
    backgroundGradients: [Color(0x80303F9F), Color(0xFF090B10), Color(0x4D512DA8)],
  );

  static List<MoodTheme> get values => [
    romantic, passion, cute, nightLove, hologram, 
    morning, afternoon, evening, night
  ];
}
