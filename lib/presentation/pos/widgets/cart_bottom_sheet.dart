import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/buttons.dart';
import '../../../core/extensions/double_ext.dart';
import '../bloc/checkout/checkout_bloc.dart';
import '../bloc/checkout/checkout_event.dart';
import '../bloc/checkout/checkout_state.dart';
import 'cart_item_widget.dart';

class CartBottomSheet extends StatelessWidget {
  final VoidCallback onCheckout;

  const CartBottomSheet({
    super.key,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CheckoutBloc, CheckoutState>(
      builder: (context, state) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.greyLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Keranjang (${state.totalItems})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (state.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          context.read<CheckoutBloc>().add(CheckoutClear());
                        },
                        child: const Text(
                          'Hapus Semua',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                  ],
                ),
              ),

              const Divider(),

              // Cart items
              if (state.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 64,
                        color: AppColors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Keranjang kosong',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.items.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return CartItemWidget(
                        item: item,
                        onQuantityChanged: (quantity) {
                          context.read<CheckoutBloc>().add(
                                CheckoutUpdateQuantity(
                                  index: index,
                                  quantity: quantity,
                                ),
                              );
                        },
                        onRemove: () {
                          context.read<CheckoutBloc>().add(
                                CheckoutRemoveItem(index: index),
                              );
                        },
                      );
                    },
                  ),
                ),

              // Footer
              if (state.isNotEmpty) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Subtotal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            state.subtotal.currencyFormatRp,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (state.discount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Diskon',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.error,
                              ),
                            ),
                            Text(
                              '-${state.discount.currencyFormatRp}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            state.grandTotal.currencyFormatRp,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Button.filled(
                        onPressed: onCheckout,
                        label: 'Bayar',
                        icon: Icons.payment,
                        width: double.infinity,
                        height: 52,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
