import 'package:flutter/material.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../widgets/home_phone_layout.dart';
import '../widgets/home_tablet_layout.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      phone: HomePhoneLayout(),
      tablet: HomeTabletLayout(),
    );
  }
}
