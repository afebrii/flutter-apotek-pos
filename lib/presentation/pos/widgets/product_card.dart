import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/extensions/double_ext.dart';
import '../../../data/models/responses/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = product.totalStock <= 0;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: isOutOfStock ? null : onTap,
        child: Opacity(
          opacity: isOutOfStock ? 0.5 : 1.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image
              Expanded(
                flex: 3,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Image
                    product.image != null && product.image!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: product.image!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.background,
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.background,
                              child: const Icon(
                                Icons.medication_outlined,
                                size: 32,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.background,
                            child: const Icon(
                              Icons.medication_outlined,
                              size: 32,
                              color: AppColors.textSecondary,
                            ),
                          ),
                    // Badge overlay
                    if (product.requiresPrescription)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.prescription,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Resep',
                            style: TextStyle(
                              fontSize: 8,
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    // Out of stock overlay
                    if (isOutOfStock)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          color: AppColors.error.withValues(alpha: 0.9),
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: const Text(
                            'HABIS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              color: AppColors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Product info
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Price & Stock row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              product.sellingPriceAmount.currencyFormatRp,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isOutOfStock
                                  ? AppColors.error.withValues(alpha: 0.1)
                                  : product.isLowStock
                                      ? AppColors.warning.withValues(alpha: 0.1)
                                      : AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${product.totalStock}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isOutOfStock
                                    ? AppColors.error
                                    : product.isLowStock
                                        ? AppColors.warning
                                        : AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
