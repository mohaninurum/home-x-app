import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/app_info.dart';
import '../domain/icon_customization.dart';
import '../data/native_app_service.dart';
import '../core/mood_theme.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/material.dart' show Offset;
import '../domain/clock_customization.dart';

Uint8List removeWhiteBackground(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  if (image == null) return bytes;

  const int threshold = 220;

  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);

      int r = pixel.r.toInt();
      int g = pixel.g.toInt();
      int b = pixel.b.toInt();

      // white distance detect
      int diff = (255 - r) + (255 - g) + (255 - b);

      if (r > threshold && g > threshold && b > threshold) {
        // fully transparent
        image.setPixelRgba(x, y, r, g, b, 0);
      } else if (diff < 120) {
        // smooth edge transparency
        int alpha = (diff * 2).clamp(0, 255);
        image.setPixelRgba(x, y, r, g, b, alpha);
      }
    }
  }

  return Uint8List.fromList(img.encodePng(image));
}

final nativeAppServiceProvider = Provider<NativeAppService>((ref) {
  return NativeAppService();
});

final uploadingIconsProvider = NotifierProvider<UploadingIconsNotifier, Set<String>>(() {
  return UploadingIconsNotifier();
});

class UploadingIconsNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => {};

  void startUploading(String packageName) {
    state = {...state, packageName};
  }

  void stopUploading(String packageName) {
    state = state.where((e) => e != packageName).toSet();
  }

  void update(Set<String> newSet) {
    state = newSet;
  }
}

/// Provider for app icon style settings
class IconStyleNotifier extends AsyncNotifier<AppIconStyle> {
  static const _key = 'app_icon_style';

  @override
  Future<AppIconStyle> build() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_key) ?? 0; // Default to box (0)
    return AppIconStyle.values[index];
  }

  Future<void> setStyle(AppIconStyle style) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, style.index);
    state = AsyncData(style);
  }
}

final iconStyleProvider =
    AsyncNotifierProvider<IconStyleNotifier, AppIconStyle>(() {
      return IconStyleNotifier();
    });

/// Provider for global app icon customization settings
class IconCustomizationNotifier extends AsyncNotifier<IconCustomization> {
  static const _key = 'app_icon_customization';

  @override
  Future<IconCustomization> build() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr != null) {
      try {
        return IconCustomization.fromMap(jsonDecode(jsonStr));
      } catch (e) {
        // Fallback to default
      }
    }
    return const IconCustomization();
  }

  Future<void> updateCustomization({
    double? sizeMultiplier,
    double? shadowMultiplier,
    double? borderRadiusMultiplier,
    double? textSizeMultiplier,
    double? spacingMultiplier,
    int? backgroundColorValue,
    bool clearBackgroundColor = false,
  }) async {
    final current = state.value ?? const IconCustomization();
    final updated = current.copyWith(
      sizeMultiplier: sizeMultiplier,
      shadowMultiplier: shadowMultiplier,
      borderRadiusMultiplier: borderRadiusMultiplier,
      textSizeMultiplier: textSizeMultiplier,
      spacingMultiplier: spacingMultiplier,
      backgroundColorValue: backgroundColorValue,
      clearBackgroundColor: clearBackgroundColor,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(updated.toMap()));
    state = AsyncData(updated);
  }

  Future<void> resetToDefaults() async {
    const defaultSettings = IconCustomization();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(defaultSettings.toMap()));
    state = const AsyncData(defaultSettings);
  }
}

final iconCustomizationProvider =
    AsyncNotifierProvider<IconCustomizationNotifier, IconCustomization>(() {
      return IconCustomizationNotifier();
    });

/// Provider for global analog clock customization settings
class ClockCustomizationNotifier extends AsyncNotifier<ClockCustomization> {
  static const _key = 'clock_customization';

  @override
  Future<ClockCustomization> build() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr != null) {
      try {
        return ClockCustomization.fromMap(jsonDecode(jsonStr));
      } catch (e) {
        // Fallback to default
      }
    }
    return const ClockCustomization();
  }

  Future<void> updateCustomization(ClockCustomization newCustomization) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(newCustomization.toMap()));
    state = AsyncData(newCustomization);
  }

  Future<void> resetToDefaults() async {
    const defaultSettings = ClockCustomization();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(defaultSettings.toMap()));
    state = const AsyncData(defaultSettings);
  }
}

final clockCustomizationProvider =
    AsyncNotifierProvider<ClockCustomizationNotifier, ClockCustomization>(() {
      return ClockCustomizationNotifier();
    });

final appsProvider = FutureProvider<List<AppInfo>>((ref) async {
  final service = ref.watch(nativeAppServiceProvider);
  final apps = await service.getInstalledApps();

  // Load saved settings
  final prefs = await SharedPreferences.getInstance();
  for (var app in apps) {
    app.xPos = prefs.getDouble('${app.packageName}_x') ?? -1.0;
    app.yPos = prefs.getDouble('${app.packageName}_y') ?? -1.0;
    app.customImagePath = prefs.getString('${app.packageName}_icon_path');
  }
  return apps;
});

class IconImageNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> setCustomIcon(String packageName, String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${packageName}_icon_path', path);
    ref.invalidate(appsProvider);
    ref.invalidate(homeAppsListProvider);
  }

  Future<void> clearCustomIcon(String packageName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('${packageName}_icon_path');
    ref.invalidate(appsProvider);
    ref.invalidate(homeAppsListProvider);
  }
}

final iconImageProvider = NotifierProvider<IconImageNotifier, void>(() {
  return IconImageNotifier();
});



/// Provider for package names of apps that should appear on the Home Screen
class HomeAppsNotifier extends AsyncNotifier<Set<String>> {
  static const _key = 'home_screen_apps';

  @override
  Future<Set<String>> build() async {
    final prefs = await SharedPreferences.getInstance();

    final hasInitialized = prefs.getBool('has_initialized_defaults') ?? false;
    if (!hasInitialized) {
      await prefs.setStringList(_key, []);
      await prefs.setBool('has_initialized_defaults', true);
      return {};
    }

    final list = prefs.getStringList(_key) ?? [];
    return list.toSet();
  }

  Future<void> addApp(String packageName) async {
    final prefs = await SharedPreferences.getInstance();

    // Assign a default position if not set
    if (!prefs.containsKey('${packageName}_x')) {
      await prefs.setDouble('${packageName}_x', 150.0);
      await prefs.setDouble('${packageName}_y', 300.0);

      final currentApps = ref.read(appsProvider).value;
      if (currentApps != null) {
        try {
          final app = currentApps.firstWhere(
            (a) => a.packageName == packageName,
          );
          app.xPos = 150.0;
          app.yPos = 300.0;
        } catch (_) {}
      }
    }

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

  Future<void> addAppAt(String packageName, double x, double y) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('${packageName}_x', x);
    await prefs.setDouble('${packageName}_y', y);

    final current = state.value ?? {};

    if (!current.contains(packageName)) {
      final updated = {...current, packageName};
      await prefs.setStringList(_key, updated.toList());

      state = AsyncData(updated);
    } else {
      state = AsyncData(current);
    }
    // ref.invalidate(homeAppsListProvider);
    // ref.invalidate(homeAppsListProvider); // Removed to prevent circular dependency
  }
  // Future<void> addAppAt(String packageName, double x, double y) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setDouble('${packageName}_x', x);
  //   await prefs.setDouble('${packageName}_y', y);

  //   final currentApps = ref.read(appsProvider).value;
  //   if (currentApps != null) {
  //     try {
  //       final app = currentApps.firstWhere((a) => a.packageName == packageName);
  //       app.xPos = x;
  //       app.yPos = y;
  //     } catch (_) {}
  //   }

  //   final current = state.value ?? {};
  //   if (!current.contains(packageName)) {
  //     final updated = {...current, packageName};
  //     await prefs.setStringList(_key, updated.toList());
  //     state = AsyncData(updated);
  //   } else {
  //     state = AsyncData(current);
  //     ref.invalidate(homeAppsListProvider);
  //   }
  // }
}

final homeAppsProvider = AsyncNotifierProvider<HomeAppsNotifier, Set<String>>(
  () {
    return HomeAppsNotifier();
  },
);

/// Provider for package names of apps that are hidden from the main drawer
class HiddenAppsNotifier extends AsyncNotifier<Set<String>> {
  static const _key = 'hidden_apps';

  @override
  Future<Set<String>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.toSet();
  }

  Future<void> hideApp(String packageName) async {
    final prefs = await SharedPreferences.getInstance();
    final current = state.value ?? {};
    final updated = {...current, packageName};
    await prefs.setStringList(_key, updated.toList());
    state = AsyncData(updated);

    // Also remove from home screen if it was there
    ref.read(homeAppsProvider.notifier).removeApp(packageName);
  }

  Future<void> unhideApp(String packageName) async {
    final prefs = await SharedPreferences.getInstance();
    final current = state.value ?? {};
    final updated = current.where((id) => id != packageName).toSet();
    await prefs.setStringList(_key, updated.toList());
    state = AsyncData(updated);
  }

  Future<void> toggleHide(String packageName) async {
    final current = state.value ?? {};
    if (current.contains(packageName)) {
      await unhideApp(packageName);
    } else {
      await hideApp(packageName);
    }
  }
}

final hiddenAppsProvider = AsyncNotifierProvider<HiddenAppsNotifier, Set<String>>(
  () => HiddenAppsNotifier(),
);

/// Provider for AppInfo objects that are ON the Home Screen
final homeAppsListProvider = FutureProvider<List<AppInfo>>((ref) async {
  final allApps = await ref.watch(appsProvider.future);
  final homePackageNames = ref.watch(homeAppsProvider).value ?? {};

  return allApps
      .where((app) => homePackageNames.contains(app.packageName))
      .toList();
});

/// Provider for the custom wallpaper image path
class WallpaperNotifier extends AsyncNotifier<String?> {
  static const _key = 'wallpaper_path';

  @override
  Future<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> setWallpaper(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final appDir = await getApplicationDocumentsDirectory();
    final file = File(path);
    final extension = path.contains('.') ? path.split('.').last : 'jpg';
    final savedPath = '${appDir.path}/wallpaper.$extension';

    // Copy to permanent storage
    if (await file.exists()) {
      await file.copy(savedPath);
    }

    await prefs.setString(_key, savedPath);
    state = AsyncData(savedPath);
  }

  Future<void> clearWallpaper() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    state = const AsyncData(null);
  }
}

final wallpaperProvider = AsyncNotifierProvider<WallpaperNotifier, String?>(() {
  return WallpaperNotifier();
});

/// Provider for widget positions (clock, quote, etc.)
class WidgetPositionNotifier extends AsyncNotifier<Map<String, Offset>> {
  static const _keyPrefix = 'widget_pos_';

  @override
  Future<Map<String, Offset>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_keyPrefix));
    final Map<String, Offset> positions = {};
    for (var key in keys) {
      final widgetId = key.replaceFirst(_keyPrefix, '').split('_').first;
      final x = prefs.getDouble('${_keyPrefix}${widgetId}_x') ?? 0.0;
      final y = prefs.getDouble('${_keyPrefix}${widgetId}_y') ?? 0.0;
      positions[widgetId] = Offset(x, y);
    }
    return positions;
  }

  Future<void> updatePosition(String widgetId, Offset offset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('${_keyPrefix}${widgetId}_x', offset.dx);
    await prefs.setDouble('${_keyPrefix}${widgetId}_y', offset.dy);

    final current = state.value ?? {};
    final updated = Map<String, Offset>.from(current)..[widgetId] = offset;
    state = AsyncData(updated);
  }
}

final widgetPositionProvider =
    AsyncNotifierProvider<WidgetPositionNotifier, Map<String, Offset>>(() {
      return WidgetPositionNotifier();
    });

/// Model for widgets placed on the home screen
class HomeWidget {
  final String id;
  final String packageName;
  final double x;
  final double y;
  final String? imagePath;

  HomeWidget({
    required this.id,
    required this.packageName,
    this.x = 0,
    this.y = 0,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'packageName': packageName,
      'x': x,
      'y': y,
      'imagePath': imagePath,
    };
  }

  factory HomeWidget.fromMap(Map<String, dynamic> map) {
    return HomeWidget(
      id: map['id'] as String,
      packageName: map['packageName'] as String,
      x: (map['x'] as num).toDouble(),
      y: (map['y'] as num).toDouble(),
      imagePath: map['imagePath'] as String?,
    );
  }

  HomeWidget copyWith({double? x, double? y, String? imagePath}) {
    return HomeWidget(
      id: id,
      packageName: packageName,
      x: x ?? this.x,
      y: y ?? this.y,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

/// Provider for dynamic app widgets on the home screen
class HomeWidgetsNotifier extends AsyncNotifier<List<HomeWidget>> {
  static const _key = 'home_widgets_data';

  @override
  Future<List<HomeWidget>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> data = prefs.getStringList(_key) ?? [];
    return data.map((item) => HomeWidget.fromMap(jsonDecode(item))).toList();
  }

  Future<void> addWidget(
    String packageName,
    double x,
    double y, {
    String? imagePath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final current = state.value ?? [];
    final newWidget = HomeWidget(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      packageName: packageName,
      x: x,
      y: y,
      imagePath: imagePath,
    );
    final updated = [...current, newWidget];
    await prefs.setStringList(
      _key,
      updated.map((w) => jsonEncode(w.toMap())).toList(),
    );
    state = AsyncData(updated);
  }

  Future<void> updatePosition(String id, double x, double y) async {
    final prefs = await SharedPreferences.getInstance();
    final current = state.value ?? [];
    final updated = current.map((w) {
      if (w.id == id) {
        return w.copyWith(x: x, y: y);
      }
      return w;
    }).toList();
    await prefs.setStringList(
      _key,
      updated.map((w) => jsonEncode(w.toMap())).toList(),
    );
    state = AsyncData(updated);
  }

  Future<void> removeWidget(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final current = state.value ?? [];
    final updated = current.where((w) => w.id != id).toList();
    await prefs.setStringList(
      _key,
      updated.map((w) => jsonEncode(w.toMap())).toList(),
    );
    state = AsyncData(updated);
  }
}

final homeWidgetsProvider =
    AsyncNotifierProvider<HomeWidgetsNotifier, List<HomeWidget>>(() {
      return HomeWidgetsNotifier();
    });

/// Cache for processed app icons to avoid lag in build()
final processedIconProvider = FutureProvider.family<Uint8List, Uint8List>((
  ref,
  originalBytes,
) async {
  // Use compute or similar for heavy processing in a real app,
  // but provider caching already helps significantly by only running once.
  return removeWhiteBackground(originalBytes);
});

/// Provider for heart animation setting
class HeartAnimationNotifier extends AsyncNotifier<bool> {
  static const _key = 'show_heart_animation';

  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true; // Default to true
  }

  Future<void> toggle() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !(state.value ?? true);
    await prefs.setBool(_key, newValue);
    state = AsyncData(newValue);
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
    state = AsyncData(enabled);
  }
}

final heartAnimationProvider =
    AsyncNotifierProvider<HeartAnimationNotifier, bool>(() {
      return HeartAnimationNotifier();
    });

/// Provider for edit mode state
class EditModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }

  void setEditMode(bool value) {
    state = value;
  }
}

final editModeProvider = NotifierProvider<EditModeNotifier, bool>(() {
  return EditModeNotifier();
});



/// Provider for add button visibility
class AddButtonVisibilityNotifier extends AsyncNotifier<bool> {
  static const _key = 'show_add_button';

  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true; // Default to true
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, enabled);
    state = AsyncData(enabled);
  }
}

final addButtonVisibilityProvider =
    AsyncNotifierProvider<AddButtonVisibilityNotifier, bool>(() {
      return AddButtonVisibilityNotifier();
    });

/// Provider for app drawer grid size (cross axis count)
class GridSizeNotifier extends AsyncNotifier<int> {
  static const _key = 'grid_size';

  @override
  Future<int> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 4; // Default to 4x4
  }

  Future<void> setGridSize(int size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, size);
    state = AsyncData(size);
  }
}

final gridSizeProvider = AsyncNotifierProvider<GridSizeNotifier, int>(() {
  return GridSizeNotifier();
});

/// Settings for Home Screen Neo Moving Border
class HomeScreenNeoSettings {
  final bool enabled;
  final double borderWidth;
  final int primaryColorValue;
  final int secondaryColorValue;
  final double speed;

  const HomeScreenNeoSettings({
    this.enabled = false,
    this.borderWidth = 4.0,
    this.primaryColorValue = 0xFFFF1E1E, // Red
    this.secondaryColorValue = 0xFF1E90FF, // Blue
    this.speed = 1.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'borderWidth': borderWidth,
      'primaryColorValue': primaryColorValue,
      'secondaryColorValue': secondaryColorValue,
      'speed': speed,
    };
  }

  factory HomeScreenNeoSettings.fromMap(Map<String, dynamic> map) {
    return HomeScreenNeoSettings(
      enabled: map['enabled'] as bool? ?? false,
      borderWidth: (map['borderWidth'] as num?)?.toDouble() ?? 4.0,
      primaryColorValue: map['primaryColorValue'] as int? ?? 0xFFFF1E1E,
      secondaryColorValue: map['secondaryColorValue'] as int? ?? 0xFF1E90FF,
      speed: (map['speed'] as num?)?.toDouble() ?? 1.0,
    );
  }

  HomeScreenNeoSettings copyWith({
    bool? enabled,
    double? borderWidth,
    int? primaryColorValue,
    int? secondaryColorValue,
    double? speed,
  }) {
    return HomeScreenNeoSettings(
      enabled: enabled ?? this.enabled,
      borderWidth: borderWidth ?? this.borderWidth,
      primaryColorValue: primaryColorValue ?? this.primaryColorValue,
      secondaryColorValue: secondaryColorValue ?? this.secondaryColorValue,
      speed: speed ?? this.speed,
    );
  }
}

class NeoScreenBorderNotifier extends AsyncNotifier<HomeScreenNeoSettings> {
  static const _key = 'home_screen_neo_settings';

  @override
  Future<HomeScreenNeoSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr != null) {
      try {
        return HomeScreenNeoSettings.fromMap(jsonDecode(jsonStr));
      } catch (_) {}
    }
    return const HomeScreenNeoSettings();
  }

  Future<void> updateSettings(HomeScreenNeoSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(settings.toMap()));
    state = AsyncData(settings);
  }

  Future<void> setEnabled(bool enabled) async {
    final current = state.value ?? const HomeScreenNeoSettings();
    await updateSettings(current.copyWith(enabled: enabled));
  }

  Future<void> setBorderWidth(double width) async {
    final current = state.value ?? const HomeScreenNeoSettings();
    await updateSettings(current.copyWith(borderWidth: width));
  }

  Future<void> setSpeed(double speed) async {
    final current = state.value ?? const HomeScreenNeoSettings();
    await updateSettings(current.copyWith(speed: speed));
  }
}

final homeScreenNeoProvider = AsyncNotifierProvider<NeoScreenBorderNotifier, HomeScreenNeoSettings>(() {
  return NeoScreenBorderNotifier();
});


