import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/responses/dashboard_model.dart';

class ExpiringList extends StatelessWidget {
  final List<ExpiringBatchModel> batches;

  const ExpiringList({
    super.key,
    required this.batches,
  });

  @override
  Widget build(BuildContext context) {
    if (batches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 64,
              color: AppColors.success.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tidak ada produk kadaluarsa',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: batches.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final batch = batches[index];
        return _buildBatchItem(batch);
      },
    );
  }

  Widget _buildBatchItem(ExpiringBatchModel batch) {
    final isExpired = batch.isExpired;
    final days = batch.daysUntilExpiry.abs();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isExpired
            ? AppColors.error.withValues(alpha: 0.05)
            : AppColors.white,
      ),
      child: Row(
        children: [
          // Expiry indicator
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isExpired
                  ? AppColors.error.withValues(alpha: 0.1)
                  : AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                isExpired ? Icons.error : Icons.schedule,
                size: 20,
                color: isExpired ? AppColors.error : AppColors.warning,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Batch info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batch.product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Batch: ${batch.batchNumber}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Text(
                      ' • ',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      'Stok: ${batch.stock}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Expiry info
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                batch.expiredDate,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: isExpired
                      ? AppColors.error.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isExpired ? 'Expired $days hari' : '$days hari lagi',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isExpired ? AppColors.error : AppColors.warning,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
