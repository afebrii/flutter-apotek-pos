import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../data/datasources/auth_local_datasource.dart';
import '../../../data/datasources/dashboard_remote_datasource.dart';
import '../../../data/models/responses/shift_model.dart';
import '../../../data/models/responses/user_model.dart';
import '../../auth/bloc/logout/logout_bloc.dart';
import '../../auth/bloc/logout/logout_event.dart';
import '../../auth/bloc/logout/logout_state.dart';
import '../../auth/pages/login_page.dart';
import '../../pos/pages/pos_page.dart';
import '../../shift/bloc/shift_bloc.dart';
import '../../shift/bloc/shift_state.dart';
import '../../transaction/pages/transaction_history_page.dart';
import '../../product/pages/product_list_page.dart';
import '../../customer/pages/customer_list_page.dart';
import '../../dashboard/pages/dashboard_page.dart';
import '../../report/pages/report_page.dart';
import '../../stock/pages/low_stock_page.dart';
import '../../stock/pages/expiring_page.dart';
import '../../settings/pages/settings_page.dart';

class DrawerWidget extends StatefulWidget {
  final VoidCallback? onOpenShiftRequired;

  const DrawerWidget({super.key, this.onOpenShiftRequired});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  UserModel? _user;
  int _lowStockCount = 0;
  int _expiringCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadAlertCounts();
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

    // Fetch low stock count
    final lowStockResult = await datasource.getLowStockProducts();
    if (mounted) {
      lowStockResult.fold(
        (error) {},
        (products) => setState(() {
          _lowStockCount = products.length;
        }),
      );
    }

    // Fetch expiring count
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

  void _openKasir() {
    // Check shift status from BLoC
    final shiftState = context.read<ShiftBloc>().state;
    ShiftModel? currentShift;

    if (shiftState is ShiftActive) {
      currentShift = shiftState.shift;
    } else if (shiftState is ShiftOpened) {
      currentShift = shiftState.shift;
    }

    if (currentShift == null) {
      // Show dialog to open shift first
      showDialog(
        context: context,
        builder: (dialogContext) => AlertDialog(
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                widget.onOpenShiftRequired?.call();
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
        }
      },
      child: Drawer(
        child: Column(
          children: [
            // Header
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppColors.white,
                child: Text(
                  _user?.name.isNotEmpty == true
                      ? _user!.name[0].toUpperCase()
                      : 'A',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              accountName: Text(
                _user?.name ?? 'User',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              accountEmail: Text(
                _user?.email ?? '',
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildMenuItem(
                    icon: Icons.home,
                    label: 'Beranda',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildMenuItem(
                    icon: Icons.point_of_sale,
                    label: 'Kasir',
                    onTap: () {
                      Navigator.pop(context);
                      _openKasir();
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.history,
                    label: 'Riwayat Transaksi',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(const TransactionHistoryPage());
                    },
                  ),
                  const Divider(),
                  _buildMenuItem(
                    icon: Icons.inventory_2,
                    label: 'Produk',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(const ProductListPage());
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.people,
                    label: 'Pelanggan',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(const CustomerListPage());
                    },
                  ),
                  const Divider(),
                  _buildMenuItem(
                    icon: Icons.dashboard,
                    label: 'Dashboard',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(const DashboardPage());
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.bar_chart,
                    label: 'Laporan',
                    onTap: () {
                      Navigator.pop(context);
                      context.push(const ReportPage());
                    },
                  ),
                  const Divider(),
                  _buildMenuItem(
                    icon: Icons.warning_amber,
                    label: 'Stok Rendah',
                    badge: _lowStockCount > 0 ? '$_lowStockCount' : null,
                    badgeColor: AppColors.warning,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(const LowStockPage());
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.event_busy,
                    label: 'Kadaluarsa',
                    badge: _expiringCount > 0 ? '$_expiringCount' : null,
                    badgeColor: AppColors.error,
                    onTap: () {
                      Navigator.pop(context);
                      context.push(const ExpiringPage());
                    },
                  ),
                ],
              ),
            ),

            // Footer
            const Divider(height: 1),
            _buildMenuItem(
              icon: Icons.settings,
              label: 'Pengaturan',
              onTap: () {
                Navigator.pop(context);
                context.push(const SettingsPage());
              },
            ),
            _buildMenuItem(
              icon: Icons.logout,
              label: 'Logout',
              textColor: AppColors.error,
              iconColor: AppColors.error,
              onTap: () {
                Navigator.pop(context);
                _logout();
              },
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Apotek POS v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textHint,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
    String? badge,
    Color? badgeColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor ?? AppColors.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: textColor ?? AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: badge != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor ?? AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }
}
