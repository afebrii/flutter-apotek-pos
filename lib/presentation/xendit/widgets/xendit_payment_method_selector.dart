import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/responses/xendit_status_response.dart';

class XenditPaymentMethodSelector extends StatelessWidget {
  final String? selectedMethod;
  final ValueChanged<String> onSelected;
  final List<XenditPaymentMethod>? availableMethods;

  const XenditPaymentMethodSelector({
    super.key,
    this.selectedMethod,
    required this.onSelected,
    this.availableMethods,
  });

  // Default methods if API doesn't return any
  static const List<Map<String, dynamic>> defaultMethods = [
    {
      'code': 'QRIS',
      'name': 'QRIS',
      'icon': Icons.qr_code_2,
      'color': Color(0xFF00D4AA)
    },
    {
      'code': 'GOPAY',
      'name': 'GoPay',
      'icon': Icons.account_balance_wallet,
      'color': Color(0xFF00AED6)
    },
    {
      'code': 'OVO',
      'name': 'OVO',
      'icon': Icons.account_balance_wallet,
      'color': Color(0xFF4C3494)
    },
    {
      'code': 'DANA',
      'name': 'DANA',
      'icon': Icons.account_balance_wallet,
      'color': Color(0xFF118EEA)
    },
    {
      'code': 'SHOPEEPAY',
      'name': 'ShopeePay',
      'icon': Icons.account_balance_wallet,
      'color': Color(0xFFEE4D2D)
    },
    {
      'code': 'LINKAJA',
      'name': 'LinkAja',
      'icon': Icons.account_balance_wallet,
      'color': Color(0xFFE82127)
    },
  ];

  IconData _getIconForCode(String code) {
    switch (code.toUpperCase()) {
      case 'QRIS':
        return Icons.qr_code_2;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color _getColorForCode(String code) {
    switch (code.toUpperCase()) {
      case 'QRIS':
        return const Color(0xFF00D4AA);
      case 'GOPAY':
        return const Color(0xFF00AED6);
      case 'OVO':
        return const Color(0xFF4C3494);
      case 'DANA':
        return const Color(0xFF118EEA);
      case 'SHOPEEPAY':
        return const Color(0xFFEE4D2D);
      case 'LINKAJA':
        return const Color(0xFFE82127);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use API methods if available, otherwise use defaults
    final methods = availableMethods != null && availableMethods!.isNotEmpty
        ? availableMethods!
            .map((m) => {
                  'code': m.code,
                  'name': m.name,
                  'icon': _getIconForCode(m.code),
                  'color': _getColorForCode(m.code),
                })
            .toList()
        : defaultMethods;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Pembayaran Digital (Xendit)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: methods.length,
          itemBuilder: (context, index) {
            final method = methods[index];
            final code = method['code'] as String;
            final isSelected = selectedMethod == code;
            final color = method['color'] as Color;

            return InkWell(
              onTap: () => onSelected(code),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withValues(alpha: 0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      method['icon'] as IconData,
                      size: 32,
                      color: isSelected ? color : Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      method['name'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? color : Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
