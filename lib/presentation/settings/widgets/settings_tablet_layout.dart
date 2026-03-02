import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/models/responses/user_model.dart';
import 'settings_content_panels.dart';

enum SettingsSection {
  profile,
  store,
  printer,
  receipt,
  about,
}

/// Tablet layout for Settings with two-column layout (35% menu | 65% content)
class SettingsTabletLayout extends StatefulWidget {
  const SettingsTabletLayout({super.key});

  @override
  State<SettingsTabletLayout> createState() => _SettingsTabletLayoutState();
}

class _SettingsTabletLayoutState extends State<SettingsTabletLayout> {
  UserModel? _user;
  SettingsSection _selectedSection = SettingsSection.profile;

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
      body: Row(
        children: [
          // Left Panel - Settings Menu (35%)
          Expanded(
            flex: 35,
            child: Container(
              color: AppColors.background,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildProfileCard(),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Umum'),
                  const SizedBox(height: 8),
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.person,
                      label: 'Profil Saya',
                      section: SettingsSection.profile,
                    ),
                    _buildMenuItem(
                      icon: Icons.store,
                      label: 'Informasi Toko',
                      section: SettingsSection.store,
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Transaksi'),
                  const SizedBox(height: 8),
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.print,
                      label: 'Printer Bluetooth',
                      section: SettingsSection.printer,
                    ),
                    _buildMenuItem(
                      icon: Icons.receipt_long,
                      label: 'Pengaturan Struk',
                      section: SettingsSection.receipt,
                    ),
                  ]),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Lainnya'),
                  const SizedBox(height: 8),
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.info_outline,
                      label: 'Tentang Aplikasi',
                      section: SettingsSection.about,
                    ),
                  ]),
                ],
              ),
            ),
          ),

          // Vertical Divider
          const VerticalDivider(width: 1, thickness: 1),

          // Right Panel - Settings Content (65%)
          Expanded(
            flex: 65,
            child: Container(
              color: AppColors.white,
              child: _buildContentPanel(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentPanel() {
    switch (_selectedSection) {
      case SettingsSection.profile:
        return ProfileContentPanel(
          onProfileUpdated: _loadUser,
        );
      case SettingsSection.store:
        return const StoreContentPanel();
      case SettingsSection.printer:
        return const PrinterContentPanel();
      case SettingsSection.receipt:
        return const ReceiptContentPanel();
      case SettingsSection.about:
        return const AboutContentPanel();
    }
  }

  Widget _buildProfileCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary,
              child: Text(
                _user?.name.isNotEmpty == true
                    ? _user!.name[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _user?.name ?? 'User',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _user?.email ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getRoleColor(_user?.role).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getRoleLabel(_user?.role),
                      style: TextStyle(
                        fontSize: 10,
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
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildMenuCard(List<Widget> items) {
    return Card(
      child: Column(
        children: items,
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required SettingsSection section,
  }) {
    final isSelected = _selectedSection == section;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSection = section;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
          border: isSelected
              ? Border(
                  left: BorderSide(color: AppColors.primary, width: 3),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color:
                      isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.primary,
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
