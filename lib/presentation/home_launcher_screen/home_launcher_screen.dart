import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../widgets/custom_bottom_bar.dart';
import './home_launcher_screen_initial_page.dart';

class HomeLauncherScreen extends StatefulWidget {
  const HomeLauncherScreen({super.key});

  @override
  HomeLauncherScreenState createState() => HomeLauncherScreenState();
}

class HomeLauncherScreenState extends State<HomeLauncherScreen> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  int currentIndex = 0;

  final List routes = ['/home-launcher-screen', '/icon-pack-settings-screen'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Navigator(
        key: navigatorKey,
        initialRoute: '/home-launcher-screen',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/home-launcher-screen' || '/':
              return MaterialPageRoute(
                builder: (context) => const HomeLauncherScreenInitialPage(),
                settings: settings,
              );
            default:
              if (AppRoutes.routes.containsKey(settings.name)) {
                return MaterialPageRoute(
                  builder: AppRoutes.routes[settings.name]!,
                  settings: settings,
                );
              }
              return null;
          }
        },
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: currentIndex,
        onTap: (index) {
          if (!AppRoutes.routes.containsKey(routes[index])) {
            return;
          }
          if (currentIndex != index) {
            setState(() => currentIndex = index);
            navigatorKey.currentState?.pushReplacementNamed(routes[index]);
          }
        },
      ),
    );
  }
}
