import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme_provider.dart';
import '../providers.dart';
import '../../core/responsive_utils.dart';

class ControlPanelWidget extends ConsumerWidget {
  const ControlPanelWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeMoodProvider);

    return ClipRRect(
      borderRadius: BorderRadius.circular(24.sw(context)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 240.sw(context),
          height: 80.sh(context),
          padding: EdgeInsets.symmetric(horizontal: 16.sw(context)),
          decoration: BoxDecoration(
            color: theme.backgroundColor.withOpacity(0.4),
            borderRadius: BorderRadius.circular(24.sw(context)),
            border: Border.all(
              color: theme.primaryColor.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                context,
                icon: Icons.wifi,
                color: theme.primaryColor,
                label: 'WiFi',
                onTap: () {
                  ref.read(nativeAppServiceProvider).openWifiSettings();
                },
              ),
              _buildControlButton(
                context,
                icon: Icons.bluetooth,
                color: theme.secondaryColor,
                label: 'Bluetooth',
                onTap: () {
                  ref.read(nativeAppServiceProvider).openBluetoothSettings();
                },
              ),
              _buildControlButton(
                context,
                icon: Icons.cell_tower,
                color: theme.iconHighlightColor,
                label: 'Data',
                onTap: () {
                  ref.read(nativeAppServiceProvider).openMobileDataSettings();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44.sw(context),
            height: 44.sw(context),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 24.sw(context),
            ),
          ),
          SizedBox(height: 4.sh(context)),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.wsp(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
