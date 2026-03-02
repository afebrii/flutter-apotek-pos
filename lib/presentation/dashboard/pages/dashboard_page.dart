import 'package:flutter/material.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../widgets/dashboard_phone_layout.dart';
import '../widgets/dashboard_tablet_layout.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      phone: DashboardPhoneLayout(),
      tablet: DashboardTabletLayout(),
    );
  }
}
