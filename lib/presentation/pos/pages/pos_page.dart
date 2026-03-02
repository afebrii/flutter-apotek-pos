import 'package:flutter/material.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../widgets/pos_phone_layout.dart';
import '../widgets/pos_tablet_layout.dart';

class POSPage extends StatelessWidget {
  const POSPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      phone: POSPhoneLayout(),
      tablet: POSTabletLayout(),
    );
  }
}
