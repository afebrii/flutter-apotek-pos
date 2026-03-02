import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/loading_indicator.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../data/datasources/dashboard_remote_datasource.dart';
import '../../../data/models/responses/dashboard_model.dart';
import '../../product/pages/product_detail_page.dart';

class ExpiringPage extends StatefulWidget {
  const ExpiringPage({super.key});

  @override
  State<ExpiringPage> createState() => _ExpiringPageState();
}

class _ExpiringPageState extends State<ExpiringPage>
    with SingleTickerProviderStateMixin {
  final DashboardRemoteDatasource _datasource = DashboardRemoteDatasource();
  late TabController _tabController;
  List<ExpiringBatchModel> _batches = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _datasource.getExpiringBatches();

    if (mounted) {
      result.fold(
        (error) => setState(() {
          _error = error;
          _isLoading = false;
        }),
        (batches) => setState(() {
          _batches = batches;
          _isLoading = false;
        }),
      );
    }
  }

  List<ExpiringBatchModel> get _expiredBatches =>
      _batches.where((b) => b.isExpired).toList();

  List<ExpiringBatchModel> get _expiringSoonBatches =>
      _batches.where((b) => !b.isExpired).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kadaluarsa'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white,
          unselectedLabelColor: AppColors.white.withValues(alpha: 0.7),
          indicatorColor: AppColors.white,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Segera Expired'),
                  if (_expiringSoonBatches.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_expiringSoonBatches.length}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Sudah Expired'),
                  if (_expiredBatches.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_expiredBatches.length}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingPage(message: 'Memuat data...');
    }

    if (_error != null) {
      return ErrorState(
        message: _error!,
        onRetry: _loadData,
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildBatchList(_expiringSoonBatches, isExpired: false),
        _buildBatchList(_expiredBatches, isExpired: true),
      ],
    );
  }

  Widget _buildBatchList(List<ExpiringBatchModel> batches, {required bool isExpired}) {
    if (batches.isEmpty) {
      return _buildEmptyState(isExpired);
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: batches.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final batch = batches[index];
          return _buildBatchItem(batch);
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isExpired) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color: AppColors.success.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isExpired
                ? 'Tidak ada produk expired'
                : 'Tidak ada produk mendekati kadaluarsa',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isExpired
                ? 'Semua produk masih dalam masa berlaku'
                : 'Tidak ada batch yang akan expired dalam 30 hari',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBatchItem(ExpiringBatchModel batch) {
    final isExpired = batch.isExpired;
    final days = batch.daysUntilExpiry.abs();
    final statusColor = isExpired ? AppColors.error : AppColors.warning;

    return Card(
      child: InkWell(
        onTap: () {
          context.push(ProductDetailPage(productId: batch.product.id));
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: statusColor,
                width: 4,
              ),
            ),
          ),
          child: Row(
            children: [
              // Expiry indicator
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isExpired ? Icons.error : Icons.schedule,
                      size: 24,
                      color: statusColor,
                    ),
                    Text(
                      '$days',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Batch info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batch.product.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.greyLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            batch.batchNumber,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Stok: ${batch.stock}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.event,
                          size: 14,
                          color: AppColors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(batch.expiredDate),
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isExpired ? 'Expired\n$days hari' : '$days hari\nlagi',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
