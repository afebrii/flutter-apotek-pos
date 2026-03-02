import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/models/responses/user_model.dart';

class StoreSettingsPage extends StatefulWidget {
  const StoreSettingsPage({super.key});

  @override
  State<StoreSettingsPage> createState() => _StoreSettingsPageState();
}

class _StoreSettingsPageState extends State<StoreSettingsPage> {
  StoreModel? _store;
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  Future<void> _loadStore() async {
    final user = await AuthLocalDatasource().getUser();
    if (mounted) {
      setState(() {
        _user = user;
        _store = user?.store;
        _isLoading = false;
      });
    }
  }

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _store == null
              ? _buildNoStoreInfo()
              : _buildStoreInfo(),
    );
  }

  Widget _buildNoStoreInfo() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.store_outlined,
              size: 80,
              color: AppColors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum Ada Toko',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Akun Anda belum terhubung dengan toko manapun. Hubungi admin untuk menambahkan Anda ke toko.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreInfo() {
    final isAdmin = _user?.role == 'admin' || _user?.role == 'owner';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Store header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.store,
                      size: 40,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _store?.name ?? '',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Store details
          Card(
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.badge_outlined,
                  label: 'ID Toko',
                  value: '${_store?.id ?? '-'}',
                ),
                const Divider(height: 1),
                _buildInfoRow(
                  icon: Icons.store_outlined,
                  label: 'Nama Toko',
                  value: _store?.name ?? '-',
                ),
                const Divider(height: 1),
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Alamat',
                  value: _store?.address ?? 'Belum diatur',
                ),
                const Divider(height: 1),
                _buildInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Telepon',
                  value: _store?.phone ?? 'Belum diatur',
                ),
              ],
            ),
          ),

          if (!isAdmin) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Hubungi admin untuk mengubah informasi toko',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.info.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.showSnackBar(
                      'Fitur edit toko akan segera hadir di versi berikutnya');
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Informasi Toko'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.greyLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
