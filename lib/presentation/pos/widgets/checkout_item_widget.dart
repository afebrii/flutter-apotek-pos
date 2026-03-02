import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/extensions/double_ext.dart';
import '../bloc/checkout/cart_item_model.dart';

class CheckoutItemWidget extends StatelessWidget {
  final CartItemModel item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CheckoutItemWidget({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product info row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product name & details
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
                    Text(
                      item.price.currencyFormatRp,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (item.batch != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 12,
                            color: item.isBatchExpiringSoon
                                ? AppColors.warning
                                : AppColors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Batch: ${item.batch!.batchNumber}',
                            style: TextStyle(
                              fontSize: 11,
                              color: item.isBatchExpiringSoon
                                  ? AppColors.warning
                                  : AppColors.grey,
                            ),
                          ),
                          if (item.batch!.expiredDate.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              'Exp: ${item.batch!.expiredDate}',
                              style: TextStyle(
                                fontSize: 11,
                                color: item.isBatchExpiringSoon
                                    ? AppColors.warning
                                    : AppColors.grey,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Remove button
              IconButton(
                onPressed: onRemove,
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 20,
                ),
                constraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                padding: EdgeInsets.zero,
              ),
            ],
          ),

          const Divider(height: 16),

          // Quantity and subtotal row
          Row(
            children: [
              // Quantity controls
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildQuantityButton(
                      icon: Icons.remove,
                      onPressed: item.quantity > 1
                          ? () => onQuantityChanged(item.quantity - 1)
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    _buildQuantityButton(
                      icon: Icons.add,
                      onPressed: () => onQuantityChanged(item.quantity + 1),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Unit
              Text(
                item.unitName,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
                ),
              ),

              const Spacer(),

              // Subtotal
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (item.discount > 0) ...[
                    Text(
                      (item.price * item.quantity).currencyFormatRp,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                  Text(
                    item.subtotal.currencyFormatRp,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 16,
          color: onPressed != null ? AppColors.primary : AppColors.grey,
        ),
      ),
    );
  }
}
