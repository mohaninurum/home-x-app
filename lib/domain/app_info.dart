import 'dart:typed_data';

class AppInfo {
  final String packageName;
  final String label;
  final Uint8List iconBytes;
  double xPos;
  double yPos;

  AppInfo({
    required this.packageName,
    required this.label,
    required this.iconBytes,
    this.xPos = 0.0,
    this.yPos = 0.0,
  });

  factory AppInfo.fromMap(Map<Object?, Object?> map) {
    return AppInfo(
      packageName: map['packageName'] as String,
      label: map['label'] as String,
      iconBytes: map['icon'] as Uint8List,
    );
  }
}
