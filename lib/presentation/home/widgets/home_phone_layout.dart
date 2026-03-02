import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/loading_indicator.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../data/models/responses/shift_model.dart';
import '../../auth/bloc/logout/logout_bloc.dart';
import '../../auth/bloc/logout/logout_state.dart';
import '../../auth/pages/login_page.dart';
import '../../shift/bloc/shift_bloc.dart';
import '../../shift/bloc/shift_event.dart';
import '../../shift/bloc/shift_state.dart';
import '../../shift/widgets/open_shift_dialog.dart';
import '../../shift/widgets/close_shift_dialog.dart';
import '../../shift/widgets/shift_info_widget.dart';
import '../../pos/pages/pos_page.dart';
import '../../customer/pages/customer_list_page.dart';
import '../../dashboard/pages/dashboard_page.dart';
import '../../transaction/pages/transaction_history_page.dart';
import '../../product/pages/product_list_page.dart';
import '../../report/pages/report_page.dart';
import 'drawer_widget.dart';

/// Phone layout for Home with drawer navigation
class HomePhoneLayout extends StatefulWidget {
  const HomePhoneLayout({super.key});

  @override
  State<HomePhoneLayout> createState() => _HomePhoneLayoutState();
}

class _HomePhoneLayoutState extends State<HomePhoneLayout> {
  ShiftModel? _currentShift;

  @override
  void initState() {
    super.initState();
    _checkShift();
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
        appBar: AppBar(
          title: const Text('Apotek POS'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _checkShift,
              tooltip: 'Refresh',
            ),
          ],
        ),
        drawer: DrawerWidget(
          onOpenShiftRequired: _showOpenShiftDialog,
        ),
        body: BlocConsumer<ShiftBloc, ShiftState>(
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

            return RefreshIndicator(
              onRefresh: () async => _checkShift(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Shift info or required
                    if (_currentShift != null)
                      ShiftInfoWidget(
                        shift: _currentShift!,
                        onClose: _showCloseShiftDialog,
                      )
                    else
                      ShiftRequiredWidget(
                        onOpen: _showOpenShiftDialog,
                      ),

                    const SizedBox(height: 24),

                    // Quick actions
                    if (_currentShift != null) ...[
                      const Text(
                        'Menu Utama',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildMenuGrid(),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        _buildMenuItem(
          icon: Icons.point_of_sale,
          label: 'Kasir',
          color: AppColors.primary,
          onTap: () {
            context.push(const POSPage());
          },
        ),
        _buildMenuItem(
          icon: Icons.history,
          label: 'Transaksi',
          color: AppColors.info,
          onTap: () {
            context.push(const TransactionHistoryPage());
          },
        ),
        _buildMenuItem(
          icon: Icons.inventory_2,
          label: 'Produk',
          color: AppColors.success,
          onTap: () {
            context.push(const ProductListPage());
          },
        ),
        _buildMenuItem(
          icon: Icons.people,
          label: 'Pelanggan',
          color: AppColors.secondary,
          onTap: () {
            context.push(const CustomerListPage());
          },
        ),
        _buildMenuItem(
          icon: Icons.dashboard,
          label: 'Dashboard',
          color: AppColors.warning,
          onTap: () {
            context.push(const DashboardPage());
          },
        ),
        _buildMenuItem(
          icon: Icons.bar_chart,
          label: 'Laporan',
          color: AppColors.info,
          onTap: () {
            context.push(const ReportPage());
          },
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
