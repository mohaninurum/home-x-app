import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class SettingsSectionWidget extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const SettingsSectionWidget({
    super.key,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.w),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A3D28).withValues(alpha: 0.7),
            const Color(0xFF0D2B1A).withValues(alpha: 0.85),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF4A7C59).withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11.sp,
                color: const Color(0xFF8FBF9F),
                fontWeight: FontWeight.w700,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 1.h),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF4A7C59).withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            SizedBox(height: 0.5.h),
            ...children,
          ],
        ),
      ),
    );
  }
}
