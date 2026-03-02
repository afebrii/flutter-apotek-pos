import 'package:flutter/material.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../widgets/checkout_phone_layout.dart';
import '../widgets/checkout_tablet_layout.dart';

class CheckoutPage extends StatelessWidget {
  const CheckoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveLayout(
      phone: CheckoutPhoneLayout(),
      tablet: CheckoutTabletLayout(),
    );
  }
}
