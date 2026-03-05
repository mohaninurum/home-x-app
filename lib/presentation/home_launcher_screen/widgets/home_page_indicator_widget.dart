import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class HomePageIndicatorWidget extends StatelessWidget {
  final int pageCount;
  final int currentPage;

  const HomePageIndicatorWidget({
    super.key,
    required this.pageCount,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        final isActive = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          width: isActive ? 5.w : 2.w,
          height: 2.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1.w),
            color: isActive
                ? Colors.white
                : Colors.white.withValues(alpha: 0.4),
            boxShadow: isActive
                ? [
              BoxShadow(
                color: const Color(0xFF8FBF9F).withValues(alpha: 0.6),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ]
                : null,
          ),
        );
      }),
    );
  }
}
