import 'package:flutter/material.dart';

class SpaceHeight extends StatelessWidget {
  final double height;

  const SpaceHeight(this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}

class SpaceWidth extends StatelessWidget {
  final double width;

  const SpaceWidth(this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width);
  }
}

// Common spacing constants
class Spacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}
