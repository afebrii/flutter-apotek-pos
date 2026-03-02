import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tentang Aplikasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 32),

            // App icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_pharmacy,
                size: 50,
                color: AppColors.white,
              ),
            ),

            const SizedBox(height: 24),

            // App name
            const Text(
              'Apotek POS',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Point of Sale untuk Apotek',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 8),

            // Version
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.greyLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Versi 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // App info
            Card(
              child: Column(
                children: [
                  _buildInfoItem(
                    icon: Icons.info_outline,
                    label: 'Versi Aplikasi',
                    value: '1.0.0',
                  ),
                  const Divider(height: 1),
                  _buildInfoItem(
                    icon: Icons.build_outlined,
                    label: 'Build Number',
                    value: '1',
                  ),
                  const Divider(height: 1),
                  _buildInfoItem(
                    icon: Icons.phone_android,
                    label: 'Platform',
                    value: 'Flutter',
                  ),
                  const Divider(height: 1),
                  _buildInfoItem(
                    icon: Icons.storage_outlined,
                    label: 'Backend',
                    value: 'Laravel',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Features
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fitur Utama',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem(Icons.point_of_sale, 'Point of Sale'),
                    _buildFeatureItem(Icons.inventory_2, 'Manajemen Produk'),
                    _buildFeatureItem(Icons.people, 'Manajemen Pelanggan'),
                    _buildFeatureItem(Icons.access_time, 'Manajemen Shift'),
                    _buildFeatureItem(Icons.receipt_long, 'Riwayat Transaksi'),
                    _buildFeatureItem(Icons.bar_chart, 'Laporan Penjualan'),
                    _buildFeatureItem(Icons.warning_amber, 'Alert Stok Rendah'),
                    _buildFeatureItem(Icons.event_busy, 'Alert Kadaluarsa'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Developer info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text(
                      'Dikembangkan oleh',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.code,
                            size: 20,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Developer Team',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Copyright
            Text(
              '© ${DateTime.now().year} Apotek POS',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'All rights reserved',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textHint,
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
