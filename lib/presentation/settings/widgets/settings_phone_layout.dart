import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/models/responses/user_model.dart';
import '../pages/profile_page.dart';
import '../pages/store_settings_page.dart';
import '../pages/receipt_settings_page.dart';
import '../pages/printer_settings_page.dart';
import '../pages/about_page.dart';

/// Phone layout for Settings with full screen navigation
class SettingsPhoneLayout extends StatefulWidget {
  const SettingsPhoneLayout({super.key});

  @override
  State<SettingsPhoneLayout> createState() => _SettingsPhoneLayoutState();
}

class _SettingsPhoneLayoutState extends State<SettingsPhoneLayout> {
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthLocalDatasource().getUser();
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileCard(),
          const SizedBox(height: 24),
          _buildSectionHeader('Umum'),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.person,
              label: 'Profil Saya',
              subtitle: 'Ubah nama, email, password',
              onTap: () {
                context.push(const ProfilePage());
              },
            ),
            _buildSettingItem(
              icon: Icons.store,
              label: 'Informasi Toko',
              subtitle: 'Nama toko, alamat, telepon',
              onTap: () {
                context.push(const StoreSettingsPage());
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('Transaksi'),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.print,
              label: 'Printer Bluetooth',
              subtitle: 'Hubungkan printer thermal',
              onTap: () {
                context.push(const PrinterSettingsPage());
              },
            ),
            _buildSettingItem(
              icon: Icons.receipt_long,
              label: 'Pengaturan Struk',
              subtitle: 'Format struk, header, footer',
              onTap: () {
                context.push(const ReceiptSettingsPage());
              },
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionHeader('Lainnya'),
          const SizedBox(height: 8),
          _buildSettingsCard([
            _buildSettingItem(
              icon: Icons.info_outline,
              label: 'Tentang Aplikasi',
              subtitle: 'Versi, lisensi, developer',
              onTap: () {
                context.push(const AboutPage());
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.primary,
              child: Text(
                _user?.name.isNotEmpty == true
                    ? _user!.name[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _user?.name ?? 'User',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getRoleColor(_user?.role).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getRoleLabel(_user?.role),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _getRoleColor(_user?.role),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> items) {
    return Card(
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: AppColors.primary,
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
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.grey,
                ),
          ],
        ),
      ),
    );
  }

  Color _getRoleColor(String? role) {
    switch (role) {
      case 'admin':
        return AppColors.primary;
      case 'owner':
        return AppColors.info;
      case 'cashier':
        return AppColors.success;
      default:
        return AppColors.grey;
    }
  }

  String _getRoleLabel(String? role) {
    switch (role) {
      case 'admin':
        return 'Admin';
      case 'owner':
        return 'Pemilik';
      case 'cashier':
        return 'Kasir';
      default:
        return 'User';
    }
  }
}
