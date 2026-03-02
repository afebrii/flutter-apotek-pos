import 'package:flutter/material.dart';

enum DeviceType { phone, tablet }

class ScreenSize {
  // Breakpoints - Phone < 600px, Tablet >= 600px
  static const double phoneMaxWidth = 600;

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < phoneMaxWidth) return DeviceType.phone;
    return DeviceType.tablet;
  }

  static bool isPhone(BuildContext context) {
    return getDeviceType(context) == DeviceType.phone;
  }

  static bool isTablet(BuildContext context) {
    return getDeviceType(context) == DeviceType.tablet;
  }

  static T responsive<T>(
    BuildContext context, {
    required T phone,
    T? tablet,
  }) {
    final deviceType = getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return phone;
      case DeviceType.tablet:
        return tablet ?? phone;
    }
  }

  // Grid Columns
  static int gridColumns(BuildContext context) {
    return responsive(context, phone: 2, tablet: 3);
  }

  static int posGridColumns(BuildContext context) {
    return responsive(context, phone: 2, tablet: 4);
  }

  // Font Size
  static double fontSizeMultiplier(BuildContext context) {
    return responsive<double>(
      context,
      phone: 1.0,
      tablet: 1.1,
    );
  }

  static double fontSize(BuildContext context, {required double base}) {
    return base * fontSizeMultiplier(context);
  }

  // Padding
  static double get paddingSmall => 8.0;
  static double get paddingMedium => 16.0;
  static double get paddingLarge => 24.0;

  static EdgeInsets screenPadding(BuildContext context) {
    return responsive(
      context,
      phone: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
    );
  }

  static double responsivePadding(BuildContext context) {
    return responsive(context, phone: 16.0, tablet: 24.0);
  }

  static double spacing(BuildContext context, {double base = 16}) {
    return responsive(
      context,
      phone: base,
      tablet: base * 1.25,
    );
  }
}
