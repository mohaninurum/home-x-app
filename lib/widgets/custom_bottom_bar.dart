import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import './custom_icon_widget.dart';

class CustomBottomBarItem {
  final String routeName;
  final String iconName;
  final String label;

  const CustomBottomBarItem({
    required this.routeName,
    required this.iconName,
    required this.label,
  });
}

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<CustomBottomBarItem> items = [
    CustomBottomBarItem(
      routeName: '/home-launcher-screen',
      iconName: 'home',
      label: 'Home',
    ),
    CustomBottomBarItem(
      routeName: '/icon-pack-settings-screen',
      iconName: 'palette',
      label: 'Icon Packs',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A3D26), Color(0xFF0D1F14)],
        ),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF4A7C59).withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 1.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;
              return GestureDetector(
                onTap: () => onTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.w),
                    color: isSelected
                        ? const Color(0xFF4A7C59).withValues(alpha: 0.3)
                        : Colors.transparent,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: item.iconName,
                        color: isSelected
                            ? const Color(0xFF8FBF9F)
                            : Colors.white.withValues(alpha: 0.5),
                        size: isSelected ? 26 : 22,
                      ),
                      SizedBox(height: 0.4.h),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF8FBF9F)
                              : Colors.white.withValues(alpha: 0.5),
                          fontSize: 9.sp,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
