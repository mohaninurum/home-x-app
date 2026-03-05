import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/icon_pack_settings_screen/icon_pack_settings_screen.dart';
import '../presentation/home_launcher_screen/home_launcher_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String iconPackSettings = '/icon-pack-settings-screen';
  static const String homeLauncher = '/home-launcher-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    iconPackSettings: (context) => const IconPackSettingsScreen(),
    homeLauncher: (context) => const HomeLauncherScreen(),
    // TODO: Add your other routes here
  };
}

