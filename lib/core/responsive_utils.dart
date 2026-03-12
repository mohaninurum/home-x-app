import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double referenceWidth = 390.0; // iPhone 12/13/14/15 width
  static const double referenceHeight = 844.0;

  static double scaleWidth(BuildContext context, double width) {
    final screenWidth = MediaQuery.of(context).size.width;
    return width * (screenWidth / referenceWidth);
  }

  static double scaleHeight(BuildContext context, double height) {
    final screenHeight = MediaQuery.of(context).size.height;
    return height * (screenHeight / referenceHeight);
  }

  static double sp(BuildContext context, double size) {
    return scaleWidth(context, size);
  }
}

extension ResponsiveExtension on num {
  double sw(BuildContext context) => ResponsiveUtils.scaleWidth(context, toDouble());
  double sh(BuildContext context) => ResponsiveUtils.scaleHeight(context, toDouble());
  double wsp(BuildContext context) => ResponsiveUtils.sp(context, toDouble());
}
