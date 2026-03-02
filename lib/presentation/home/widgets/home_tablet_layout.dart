import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/loading_indicator.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/datasources/dashboard_remote_datasource.dart';
import '../../../data/models/responses/shift_model.dart';
import '../../../data/models/responses/user_model.dart';
import '../../auth/bloc/logout/logout_bloc.dart';
import '../../auth/bloc/logout/logout_event.dart';
import '../../auth/bloc/logout/logout_state.dart';
import '../../auth/pages/login_page.dart';
import '../../shift/bloc/shift_bloc.dart';
import '../../shift/bloc/shift_event.dart';
import '../../shift/bloc/shift_state.dart';
import '../../shift/widgets/open_shift_dialog.dart';
import '../../shift/widgets/close_shift_dialog.dart';
import '../../pos/pages/pos_page.dart';
import '../../customer/pages/customer_list_page.dart';
import '../../dashboard/pages/dashboard_page.dart';
import '../../transaction/pages/transaction_history_page.dart';
import '../../product/pages/product_list_page.dart';
import '../../report/pages/report_page.dart';
import '../../stock/pages/low_stock_page.dart';
import '../../stock/pages/expiring_page.dart';
import '../../settings/pages/settings_page.dart';

/// Tablet layout for Home with permanent sidebar navigation
class HomeTabletLayout extends StatefulWidget {
  const HomeTabletLayout({super.key});

  @override
  State<HomeTabletLayout> createState() => _HomeTabletLayoutState();
}

class _HomeTabletLayoutState extends State<HomeTabletLayout> {
  ShiftModel? _currentShift;
  UserModel? _user;
  int _lowStockCount = 0;
  int _expiringCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadAlertCounts();
    _checkShift();
  }

  Future<void> _loadUser() async {
    final user = await AuthLocalDatasource().getUser();
    if (mounted) {
      setState(() {
        _user = user;
      });
    }
  }

  Future<void> _loadAlertCounts() async {
    final datasource = DashboardRemoteDatasource();

    final lowStockResult = await datasource.getLowStockProducts();
    if (mounted) {
      lowStockResult.fold(
        (error) {},
        (products) => setState(() {
          _lowStockCount = products.length;
        }),
      );
    }

    final expiringResult = await datasource.getExpiringBatches();
    if (mounted) {
      expiringResult.fold(
        (error) {},
        (batches) => setState(() {
          _expiringCount = batches.length;
        }),
      );
    }
  }

  void _checkShift() {
    context.read<ShiftBloc>().add(ShiftCheckCurrent());
  }

  void _showOpenShiftDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OpenShiftDialog(
        onSuccess: () {
          _checkShift();
        },
      ),
    );
  }

  void _showCloseShiftDialog() {
    if (_currentShift == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => CloseShiftDialog(
        currentShift: _currentShift!,
        onSuccess: () {
          _checkShift();
        },
      ),
    );
  }

  void _openKasir() {
    if (_currentShift == null) {
      // Show dialog to open shift first
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                ),
              ),
              const SizedBox(width: 12),
              const Text('Shift Belum Dibuka'),
            ],
          ),
          content: const Text(
            'Anda harus membuka shift terlebih dahulu sebelum dapat mengakses menu Kasir.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showOpenShiftDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Buka Shift'),
            ),
          ],
        ),
      );
      return;
    }

    // Shift is open, navigate to POS
    context.push(const POSPage());
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<LogoutBloc>().add(LogoutSubmitted());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LogoutBloc, LogoutState>(
      listener: (context, state) {
        if (state is LogoutSuccess) {
          context.pushAndRemoveUntil(
            const LoginPage(),
            (route) => false,
          );
        } else if (state is LogoutError) {
          context.showErrorSnackBar(state.message);
        }
      },
      child: Scaffold(
        body: Row(
          children: [
            // Permanent Sidebar Navigation
            _buildSidebar(),

            // Vertical Divider
            const VerticalDivider(width: 1, thickness: 1),

            // Main Content
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      color: AppColors.white,
      child: Column(
        children: [
          // App Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_pharmacy,
                      color: AppColors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Apotek POS',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          'v1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Navigation Menu (includes User Profile Card)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // User Profile Card
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          _user?.name.isNotEmpty == true
                              ? _user!.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 18,
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
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    _getRoleColor(_user?.role).withAlpha(25),
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

                // Menu items
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildSectionLabel('MENU UTAMA'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildNavItem(
                    icon: Icons.point_of_sale,
                    label: 'Kasir',
                    onTap: _openKasir,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildNavItem(
                    icon: Icons.history,
                    label: 'Riwayat Transaksi',
                    onTap: () => context.push(const TransactionHistoryPage()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildNavItem(
                    icon: Icons.dashboard,
                    label: 'Dashboard',
                    onTap: () => context.push(const DashboardPage()),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildSectionLabel('MANAJEMEN'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildNavItem(
                    icon: Icons.inventory_2,
                    label: 'Produk',
                    onTap: () => context.push(const ProductListPage()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildNavItem(
                    icon: Icons.people,
                    label: 'Pelanggan',
                    onTap: () => context.push(const CustomerListPage()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildNavItem(
                    icon: Icons.bar_chart,
                    label: 'Laporan',
                    onTap: () => context.push(const ReportPage()),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildSectionLabel('PERINGATAN'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildNavItem(
                    icon: Icons.warning_amber,
                    label: 'Stok Rendah',
                    badge: _lowStockCount > 0 ? '$_lowStockCount' : null,
                    badgeColor: AppColors.warning,
                    onTap: () => context.push(const LowStockPage()),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _buildNavItem(
                    icon: Icons.event_busy,
                    label: 'Kadaluarsa',
                    badge: _expiringCount > 0 ? '$_expiringCount' : null,
                    badgeColor: AppColors.error,
                    onTap: () => context.push(const ExpiringPage()),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

          // Footer
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildNavItem(
                    icon: Icons.settings,
                    label: 'Pengaturan',
                    onTap: () => context.push(const SettingsPage()),
                  ),
                  _buildNavItem(
                    icon: Icons.logout,
                    label: 'Logout',
                    textColor: AppColors.error,
                    iconColor: AppColors.error,
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textHint,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
    String? badge,
    Color? badgeColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: iconColor ?? AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? AppColors.textPrimary,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor ?? AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return BlocConsumer<ShiftBloc, ShiftState>(
      listener: (context, state) {
        if (state is ShiftActive) {
          setState(() {
            _currentShift = state.shift;
          });
        } else if (state is ShiftOpened) {
          setState(() {
            _currentShift = state.shift;
          });
        } else if (state is ShiftClosed || state is ShiftNotFound) {
          setState(() {
            _currentShift = null;
          });
        } else if (state is ShiftError) {
          context.showErrorSnackBar(state.message);
        }
      },
      builder: (context, state) {
        if (state is ShiftLoading) {
          return const LoadingPage(message: 'Memeriksa shift...');
        }

        return Column(
          children: [
            // Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.divider, width: 1),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    const Text(
                      'Beranda',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        _checkShift();
                        _loadAlertCounts();
                      },
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _checkShift();
                  _loadAlertCounts();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Shift Status Card
                      _buildShiftCard(),

                      if (_currentShift != null) ...[
                        const SizedBox(height: 32),

                        // Quick Actions Grid
                        const Text(
                          'Akses Cepat',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildQuickActionsGrid(),

                        const SizedBox(height: 32),

                        // Alerts Section
                        if (_lowStockCount > 0 || _expiringCount > 0) ...[
                          const Text(
                            'Peringatan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildAlertsRow(),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShiftCard() {
    if (_currentShift != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shift Aktif',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Modal: Rp ${_formatCurrency(_currentShift!.openingCash)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dibuka: ${_formatDateTime(_currentShift!.openingTime)}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showCloseShiftDialog,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Tutup Shift'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.warning_amber,
                color: AppColors.warning,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shift Belum Dibuka',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Buka shift terlebih dahulu untuk memulai transaksi',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              onPressed: _showOpenShiftDialog,
              icon: const Icon(Icons.login, size: 18),
              label: const Text('Buka Shift'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final actions = [
      _QuickAction(
        icon: Icons.point_of_sale,
        label: 'Kasir',
        subtitle: 'Buat transaksi baru',
        color: AppColors.primary,
        onTap: () => context.push(const POSPage()),
      ),
      _QuickAction(
        icon: Icons.history,
        label: 'Transaksi',
        subtitle: 'Lihat riwayat penjualan',
        color: AppColors.info,
        onTap: () => context.push(const TransactionHistoryPage()),
      ),
      _QuickAction(
        icon: Icons.inventory_2,
        label: 'Produk',
        subtitle: 'Kelola stok produk',
        color: AppColors.success,
        onTap: () => context.push(const ProductListPage()),
      ),
      _QuickAction(
        icon: Icons.people,
        label: 'Pelanggan',
        subtitle: 'Data pelanggan',
        color: AppColors.secondary,
        onTap: () => context.push(const CustomerListPage()),
      ),
      _QuickAction(
        icon: Icons.dashboard,
        label: 'Dashboard',
        subtitle: 'Ringkasan bisnis',
        color: AppColors.warning,
        onTap: () => context.push(const DashboardPage()),
      ),
      _QuickAction(
        icon: Icons.bar_chart,
        label: 'Laporan',
        subtitle: 'Analisis penjualan',
        color: AppColors.info,
        onTap: () => context.push(const ReportPage()),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildQuickActionCard(action);
      },
    );
  }

  Widget _buildQuickActionCard(_QuickAction action) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  action.icon,
                  size: 28,
                  color: action.color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      action.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: action.color.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsRow() {
    return Row(
      children: [
        if (_lowStockCount > 0)
          Expanded(
            child: _buildAlertCard(
              icon: Icons.warning_amber,
              label: 'Stok Rendah',
              count: _lowStockCount,
              color: AppColors.warning,
              onTap: () => context.push(const LowStockPage()),
            ),
          ),
        if (_lowStockCount > 0 && _expiringCount > 0)
          const SizedBox(width: 16),
        if (_expiringCount > 0)
          Expanded(
            child: _buildAlertCard(
              icon: Icons.event_busy,
              label: 'Akan Kadaluarsa',
              count: _expiringCount,
              color: AppColors.error,
              onTap: () => context.push(const ExpiringPage()),
            ),
          ),
      ],
    );
  }

  Widget _buildAlertCard({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color, width: 1.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.white, size: 24),
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
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count produk',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward,
                  color: color,
                  size: 18,
                ),
              ),
            ],
          ),
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

  String _formatCurrency(String amount) {
    final value = double.tryParse(amount) ?? 0;
    final parts = value.toStringAsFixed(2).split('.');
    final integerPart = parts[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    return '$integerPart,${parts[1]}';
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}, '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
