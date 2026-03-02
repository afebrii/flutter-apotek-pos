import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/loading_indicator.dart';
import '../../../core/extensions/double_ext.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import 'summary_card.dart';
import 'low_stock_list.dart';
import 'expiring_list.dart';

/// Tablet layout for Dashboard with split-screen (60% main | 40% sidebar)
class DashboardTabletLayout extends StatefulWidget {
  const DashboardTabletLayout({super.key});

  @override
  State<DashboardTabletLayout> createState() => _DashboardTabletLayoutState();
}

class _DashboardTabletLayoutState extends State<DashboardTabletLayout> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(DashboardFetch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DashboardBloc>().add(DashboardRefresh());
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const LoadingPage(message: 'Memuat dashboard...');
          }

          if (state is DashboardError) {
            return ErrorState(
              message: state.message,
              onRetry: () {
                context.read<DashboardBloc>().add(DashboardFetch());
              },
            );
          }

          if (state is DashboardLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(DashboardRefresh());
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column (60%) - Main Stats
                  Expanded(
                    flex: 60,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummarySection(state),
                          const SizedBox(height: 24),
                          _buildLowStockSection(state),
                        ],
                      ),
                    ),
                  ),

                  // Vertical Divider
                  const VerticalDivider(width: 1, thickness: 1),

                  // Right Column (40%) - Alerts
                  Expanded(
                    flex: 40,
                    child: Container(
                      color: AppColors.white,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildExpiringSection(state),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSummarySection(DashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Hari Ini',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        // 4 columns for tablet
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                icon: Icons.shopping_cart,
                label: 'Transaksi',
                value: '${state.summary.todaySales.count}',
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryCard(
                icon: Icons.attach_money,
                label: 'Penjualan',
                value: state.summary.todaySales.total.currencyFormatRp,
                color: AppColors.success,
                isCompact: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryCard(
                icon: Icons.inventory,
                label: 'Stok Rendah',
                value: '${state.summary.lowStockProducts}',
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SummaryCard(
                icon: Icons.event_busy,
                label: 'Kadaluarsa',
                value:
                    '${state.summary.expiringSoon + state.summary.expiredProducts}',
                subtitle: state.summary.expiredProducts > 0
                    ? '${state.summary.expiredProducts} expired'
                    : null,
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLowStockSection(DashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.inventory_2,
                size: 20,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Stok Rendah',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (state.summary.lowStockProducts > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${state.summary.lowStockProducts} produk',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warning,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.divider),
          ),
          child: state.isLoadingLowStock
              ? const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              : LowStockList(products: state.lowStockProducts),
        ),
      ],
    );
  }

  Widget _buildExpiringSection(DashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.warning_amber,
                size: 20,
                color: AppColors.error,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Produk Kadaluarsa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (state.summary.expiringSoon + state.summary.expiredProducts > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${state.summary.expiringSoon + state.summary.expiredProducts} batch',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppColors.divider),
          ),
          child: state.isLoadingExpiring
              ? const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              : ExpiringList(batches: state.expiringBatches),
        ),
      ],
    );
  }
}
