import 'package:flutter/material.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../widgets/settings_phone_layout.dart';
import '../widgets/settings_tablet_layout.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      phone: SettingsPhoneLayout(),
      tablet: SettingsTabletLayout(),
    );
  }
}
