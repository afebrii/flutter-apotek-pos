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

/// Phone layout for Dashboard with single column layout
class DashboardPhoneLayout extends StatefulWidget {
  const DashboardPhoneLayout({super.key});

  @override
  State<DashboardPhoneLayout> createState() => _DashboardPhoneLayoutState();
}

class _DashboardPhoneLayoutState extends State<DashboardPhoneLayout>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    context.read<DashboardBloc>().add(DashboardFetch());
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {});
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
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
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummarySection(state),
                    const SizedBox(height: 24),
                    _buildTabSection(state),
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

  Widget _buildSummarySection(DashboardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Hari Ini',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
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
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                icon: Icons.attach_money,
                label: 'Penjualan',
                value: state.summary.todaySales.total.currencyFormatRp,
                color: AppColors.success,
                isCompact: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: SummaryCard(
                icon: Icons.inventory,
                label: 'Stok Rendah',
                value: '${state.summary.lowStockProducts}',
                color: AppColors.warning,
                onTap: () {
                  _tabController.animateTo(0);
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SummaryCard(
                icon: Icons.event_busy,
                label: 'Kadaluarsa',
                value:
                    '${state.summary.expiringSoon + state.summary.expiredProducts}',
                subtitle: state.summary.expiredProducts > 0
                    ? '${state.summary.expiredProducts} sudah expired'
                    : null,
                color: AppColors.error,
                onTap: () {
                  _tabController.animateTo(1);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabSection(DashboardLoaded state) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.grey,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(
                child: _buildTabLabel(
                  icon: Icons.inventory_2,
                  label: 'Stok Rendah',
                  count: state.summary.lowStockProducts,
                  badgeColor: AppColors.warning,
                ),
              ),
              Tab(
                child: _buildTabLabel(
                  icon: Icons.warning_amber,
                  label: 'Kadaluarsa',
                  count:
                      state.summary.expiringSoon + state.summary.expiredProducts,
                  badgeColor: AppColors.error,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        IndexedStack(
          index: _tabController.index,
          children: [
            state.isLoadingLowStock
                ? const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : LowStockList(products: state.lowStockProducts),
            state.isLoadingExpiring
                ? const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : ExpiringList(batches: state.expiringBatches),
          ],
        ),
      ],
    );
  }

  Widget _buildTabLabel({
    required IconData icon,
    required String label,
    required int count,
    required Color badgeColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        if (count > 0) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 9,
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
