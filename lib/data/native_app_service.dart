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

  Future<void> openAppInfo(String packageName) async {
    try {
      await _channel.invokeMethod('openAppInfo', {'packageName': packageName});
    } on PlatformException catch (e) {
      print("Failed to open app info: '${e.message}'.");
    }
  }

  Future<void> startLockService() async {
    try {
      await _channel.invokeMethod('startLockService');
    } catch (e) {
      print("Failed to start lock service: $e");
    }
  }

  Future<bool> openDefaultLauncherSettings() async {
    try {
      final bool result = await _channel.invokeMethod('openDefaultLauncherSettings');
      return result;
    } on PlatformException catch (e) {
      print("Failed to open launcher settings: '${e.message}'.");
      return false;
    }
  }

  Future<bool> uninstallApp(String packageName) async {
    try {
      final bool result = await _channel.invokeMethod('uninstallApp', {'packageName': packageName});
      return result;
    } on PlatformException catch (e) {
      print("Failed to uninstall app: '${e.message}'.");
      return false;
    }
  }

  Future<bool> openNotificationPanel() async {
    try {
      final bool result = await _channel.invokeMethod('openNotificationPanel');
      return result;
    } on PlatformException catch (e) {
      print("Failed to open notification panel: '${e.message}'.");
      return false;
    }
  }
}

