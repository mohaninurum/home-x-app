import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/responsive_utils.dart';

class WidgetSelectionDialog extends StatelessWidget {
  const WidgetSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40.sw(context))),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.45,
          color: Colors.black.withOpacity(0.65),
          child: Column(
            children: [
              SizedBox(height: 15.sh(context)),
              Container(
                width: 50.sw(context),
                height: 5.sh(context),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10.sw(context)),
                ),
              ),
              SizedBox(height: 30.sh(context)),
              Text(
                'Choose Widget Type',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.wsp(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30.sh(context)),
              ListTile(
                leading: const Icon(Icons.apps, color: Colors.pinkAccent, size: 36),
                title: const Text('App Shortcut', style: TextStyle(color: Colors.white, fontSize: 18)),
                subtitle: const Text('Add an app with custom size and icon', style: TextStyle(color: Colors.white70)),
                onTap: () => Navigator.pop(context, 'app'),
              ),
              const Divider(color: Colors.white24, indent: 20, endIndent: 20),
              ListTile(
                leading: const Icon(Icons.widgets, color: Colors.cyanAccent, size: 36),
                title: const Text('System Widget', style: TextStyle(color: Colors.white, fontSize: 18)),
                subtitle: const Text('Add Clock, Weather, or Battery widgets', style: TextStyle(color: Colors.white70)),
                onTap: () => Navigator.pop(context, 'system'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SystemWidgetPicker extends StatelessWidget {
  const SystemWidgetPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(40.sw(context))),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          color: Colors.black.withOpacity(0.65),
          padding: EdgeInsets.all(20.sw(context)),
          child: Column(
            children: [
              Container(
                width: 50.sw(context),
                height: 5.sh(context),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10.sw(context)),
                ),
              ),
              SizedBox(height: 20.sh(context)),
              Text(
                'System Widgets',
                style: TextStyle(color: Colors.white, fontSize: 24.wsp(context), fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20.sh(context)),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15.sw(context),
                  mainAxisSpacing: 15.sh(context),
                  children: [
                    _buildOption(context, 'Clock', Icons.access_time, Colors.orangeAccent, 'clock'),
                    _buildOption(context, 'Weather', Icons.cloud, Colors.blueAccent, 'weather'),
                    _buildOption(context, 'Battery', Icons.battery_full, Colors.greenAccent, 'battery'),
                    _buildOption(context, 'Control Panel', Icons.tune, Colors.purpleAccent, 'control_panel'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(BuildContext context, String title, IconData icon, Color color, String type) {
    return GestureDetector(
      onTap: () => Navigator.pop(context, type),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            SizedBox(height: 10.sh(context)),
            Text(title, style: TextStyle(color: Colors.white, fontSize: 16.wsp(context), fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
