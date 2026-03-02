import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/extensions/double_ext.dart';
import '../bloc/checkout/cart_item_model.dart';

class CartItemWidget extends StatelessWidget {
  final CartItemModel item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      item.price.currencyFormatRp,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      ' / ${item.unitName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
                if (item.batch != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Batch: ${item.batch!.batchNumber}',
                    style: TextStyle(
                      fontSize: 11,
                      color: item.isBatchExpiringSoon
                          ? AppColors.warning
                          : AppColors.textHint,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Quantity controls
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Subtotal
              Text(
                item.subtotal.currencyFormatRp,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              // Quantity buttons
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.greyLight),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildQuantityButton(
                      icon: item.quantity > 1 ? Icons.remove : Icons.delete,
                      color: item.quantity > 1 ? AppColors.textPrimary : AppColors.error,
                      onTap: () {
                        if (item.quantity > 1) {
                          onQuantityChanged(item.quantity - 1);
                        } else {
                          onRemove();
                        }
                      },
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 40),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    _buildQuantityButton(
                      icon: Icons.add,
                      color: AppColors.primary,
                      onTap: () => onQuantityChanged(item.quantity + 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }
}
