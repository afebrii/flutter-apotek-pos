import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/loading_indicator.dart';
import '../../../data/datasources/store_remote_datasource.dart';
import '../bloc/store_bloc.dart';
import '../bloc/store_event.dart';
import '../bloc/store_state.dart';

class StoreInfoPage extends StatelessWidget {
  const StoreInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StoreBloc(
        datasource: StoreRemoteDatasource(),
      )..add(StoreAndSettingsFetch()),
      child: const _StoreInfoContent(),
    );
  }
}

class _StoreInfoContent extends StatelessWidget {
  const _StoreInfoContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Informasi Toko'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<StoreBloc, StoreState>(
        builder: (context, state) {
          if (state is StoreLoading) {
            return const LoadingPage(message: 'Memuat data toko...');
          }

          if (state is StoreError) {
            return ErrorState(
              message: state.message,
              onRetry: () => context.read<StoreBloc>().add(StoreAndSettingsFetch()),
            );
          }

          if (state is StoreLoaded) {
            final store = state.store;
            final settings = state.settings;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<StoreBloc>().add(StoreAndSettingsFetch());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Store Logo & Name
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(25),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: store.logo != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.network(
                                      store.logo!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => const Icon(
                                        Icons.store,
                                        size: 48,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.store,
                                    size: 48,
                                    color: AppColors.primary,
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            store.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (store.code != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Kode: ${store.code}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Store Info Section
                    _buildSectionCard(
                      title: 'Informasi Toko',
                      icon: Icons.store_outlined,
                      children: [
                        _buildInfoRow('Alamat', store.address ?? '-'),
                        _buildInfoRow('Telepon', store.phone ?? '-'),
                        _buildInfoRow('Email', store.email ?? '-'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // License Section
                    _buildSectionCard(
                      title: 'Izin & Lisensi',
                      icon: Icons.verified_outlined,
                      children: [
                        _buildInfoRow('Nomor SIA', store.siaNumber ?? '-'),
                        _buildInfoRow('Nomor SIPA', store.sipaNumber ?? '-'),
                        _buildInfoRow('Apoteker', store.pharmacistName ?? '-'),
                        _buildInfoRow('SIPA Apoteker', store.pharmacistSipa ?? '-'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Settings Section
                    if (settings != null) ...[
                      _buildSectionCard(
                        title: 'Pengaturan POS',
                        icon: Icons.settings_outlined,
                        children: [
                          _buildInfoRow('Tarif Pajak', '${settings.pos.taxRate}%'),
                          _buildInfoRow('Diskon Default', '${settings.pos.defaultDiscount}%'),
                          _buildInfoRow(
                            'Stok Negatif',
                            settings.pos.allowNegativeStock ? 'Diizinkan' : 'Tidak Diizinkan',
                          ),
                          _buildInfoRow(
                            'Verifikasi Resep',
                            settings.pos.requirePrescriptionVerification ? 'Wajib' : 'Tidak Wajib',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildSectionCard(
                        title: 'Pengaturan Receipt',
                        icon: Icons.receipt_long_outlined,
                        children: [
                          _buildInfoRow('Ukuran Kertas', settings.receipt.paperSize),
                          _buildInfoRow(
                            'Tampilkan Logo',
                            settings.receipt.showLogo ? 'Ya' : 'Tidak',
                          ),
                          _buildInfoRow('Footer', settings.receipt.receiptFooter),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildSectionCard(
                        title: 'Pengaturan Notifikasi',
                        icon: Icons.notifications_outlined,
                        children: [
                          _buildInfoRow(
                            'Batas Stok Rendah',
                            '${settings.notification.lowStockThreshold} unit',
                          ),
                          _buildInfoRow(
                            'Peringatan Kadaluarsa',
                            '${settings.notification.expiryWarningDays} hari sebelum',
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
