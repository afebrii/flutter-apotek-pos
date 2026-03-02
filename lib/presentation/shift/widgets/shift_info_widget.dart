import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/extensions/date_time_ext.dart';
import '../../../core/extensions/double_ext.dart';
import '../../../data/models/responses/shift_model.dart';

class ShiftInfoWidget extends StatelessWidget {
  final ShiftModel shift;
  final VoidCallback? onClose;

  const ShiftInfoWidget({
    super.key,
    required this.shift,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.success,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.access_time,
              color: AppColors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Shift Aktif',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Mulai: ${shift.openingTime.toFormattedTime}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Modal: ${shift.openingCashAmount.currencyFormatRp}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (onClose != null)
            TextButton(
              onPressed: onClose,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.warning,
              ),
              child: const Text('Tutup'),
            ),
        ],
      ),
    );
  }
}

class ShiftRequiredWidget extends StatelessWidget {
  final VoidCallback onOpen;

  const ShiftRequiredWidget({
    super.key,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warning,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'Shift Belum Dibuka',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Anda harus membuka shift terlebih dahulu sebelum dapat melakukan transaksi',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Buka Shift'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
