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
