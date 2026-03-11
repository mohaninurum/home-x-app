import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/app_info.dart';
import '../data/native_app_service.dart';

final nativeAppServiceProvider = Provider<NativeAppService>((ref) {
  return NativeAppService();
});

final appsProvider = FutureProvider<List<AppInfo>>((ref) async {
  final service = ref.watch(nativeAppServiceProvider);
  final apps = await service.getInstalledApps();
  
  // Load saved positions
  final prefs = await SharedPreferences.getInstance();
  for (var app in apps) {
    app.xPos = prefs.getDouble('${app.packageName}_x') ?? 0.0;
    app.yPos = prefs.getDouble('${app.packageName}_y') ?? 0.0;
  }
  return apps;
});

/// Provider for package names of apps that should appear on the Home Screen
class HomeAppsNotifier extends AsyncNotifier<Set<String>> {
  static const _key = 'home_screen_apps';

  @override
  Future<Set<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.toSet();
  }

  Future<void> addApp(String packageName) async {
    final prefs = await SharedPreferences.getInstance();
    final current = state.value ?? {};
    final updated = {...current, packageName};
    await prefs.setStringList(_key, updated.toList());
    state = AsyncData(updated);
  }

  Future<void> removeApp(String packageName) async {
    final prefs = await SharedPreferences.getInstance();
    final current = state.value ?? {};
    final updated = current.where((id) => id != packageName).toSet();
    await prefs.setStringList(_key, updated.toList());
    state = AsyncData(updated);
  }

  Future<void> toggleApp(String packageName) async {
    final current = state.value ?? {};
    if (current.contains(packageName)) {
      await removeApp(packageName);
    } else {
      await addApp(packageName);
    }
  }
}

final homeAppsProvider = AsyncNotifierProvider<HomeAppsNotifier, Set<String>>(() {
  return HomeAppsNotifier();
});

/// Provider for AppInfo objects that are ON the Home Screen
final homeAppsListProvider = FutureProvider<List<AppInfo>>((ref) async {
  final allApps = await ref.watch(appsProvider.future);
  final homePackageNames = ref.watch(homeAppsProvider).value ?? {};
  
  return allApps.where((app) => homePackageNames.contains(app.packageName)).toList();
});

