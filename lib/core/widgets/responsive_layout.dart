import 'package:flutter/material.dart';
import '../utils/screen_size.dart';

/// Widget that renders different layouts based on device type
class ResponsiveLayout extends StatelessWidget {
  final Widget phone;
  final Widget? tablet;

  const ResponsiveLayout({
    super.key,
    required this.phone,
    this.tablet,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ScreenSize.getDeviceType(context);

        switch (deviceType) {
          case DeviceType.phone:
            return phone;
          case DeviceType.tablet:
            return tablet ?? phone;
        }
      },
    );
  }
}

/// Widget that provides builder pattern for responsive layouts
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceType = ScreenSize.getDeviceType(context);
        return builder(context, deviceType);
      },
    );
  }
}

/// Helper class for responsive values
class ResponsiveValue<T> {
  final T phone;
  final T? tablet;

  const ResponsiveValue({
    required this.phone,
    this.tablet,
  });

  T resolve(BuildContext context) {
    final deviceType = ScreenSize.getDeviceType(context);
    switch (deviceType) {
      case DeviceType.phone:
        return phone;
      case DeviceType.tablet:
        return tablet ?? phone;
    }
  }
}
