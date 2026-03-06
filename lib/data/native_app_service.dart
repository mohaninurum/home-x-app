import 'package:flutter/services.dart';
import '../domain/app_info.dart';

class NativeAppService {
  static const MethodChannel _channel = MethodChannel('com.example.homexapp/launcher');

  Future<List<AppInfo>> getInstalledApps() async {
    try {
      final List<dynamic> result = await _channel.invokeMethod('getApps');
      return result.map((appMap) {
        return AppInfo.fromMap(appMap as Map<Object?, Object?>);
      }).toList();
    } on PlatformException catch (e) {
      print("Failed to get apps: '${e.message}'.");
      return [];
    }
  }

  Future<bool> launchApp(String packageName) async {
    try {
      final bool result = await _channel.invokeMethod('launchApp', {'packageName': packageName});
      return result;
    } on PlatformException catch (e) {
      print("Failed to launch app: '${e.message}'.");
      return false;
    }
  }

  Future<void> startLockService() async {
    try {
      await _channel.invokeMethod('startLockService');
    } catch (e) {
      print("Failed to start lock service: $e");
    }
  }
}
