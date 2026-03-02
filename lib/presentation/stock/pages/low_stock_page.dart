import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/loading_indicator.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../data/datasources/dashboard_remote_datasource.dart';
import '../../../data/models/responses/dashboard_model.dart';
import '../../product/pages/product_detail_page.dart';

class LowStockPage extends StatefulWidget {
  const LowStockPage({super.key});

  @override
  State<LowStockPage> createState() => _LowStockPageState();
}

class _LowStockPageState extends State<LowStockPage> {
  final DashboardRemoteDatasource _datasource = DashboardRemoteDatasource();
  List<LowStockProductModel> _products = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await _datasource.getLowStockProducts();

    if (mounted) {
      result.fold(
        (error) => setState(() {
          _error = error;
          _isLoading = false;
        }),
        (products) => setState(() {
          _products = products;
          _isLoading = false;
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stok Rendah'),
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

    if (_products.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: Column(
        children: [
          // Summary bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.warning.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber,
                  color: AppColors.warning,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_products.length} produk dengan stok rendah',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _products.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final product = _products[index];
                return _buildProductItem(product);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
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
          const Text(
            'Semua stok aman',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tidak ada produk dengan stok rendah',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(LowStockProductModel product) {
    final stockPercentage = product.minStock > 0
        ? (product.totalStock / product.minStock).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      child: InkWell(
        onTap: () {
          context.push(ProductDetailPage(productId: product.id));
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Stock indicator
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _getStockColor(stockPercentage).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${product.totalStock}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _getStockColor(stockPercentage),
                      ),
                    ),
                    Text(
                      'stok',
                      style: TextStyle(
                        fontSize: 10,
                        color: _getStockColor(stockPercentage),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),

              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
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
                        Text(
                          product.code,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (product.category != null) ...[
                          const Text(
                            ' • ',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Flexible(
                            child: Text(
                              product.category!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Progress bar
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: stockPercentage,
                              backgroundColor: AppColors.greyLight,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getStockColor(stockPercentage),
                              ),
                              minHeight: 6,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Min: ${product.minStock}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Deficit badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      '-${product.deficit}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.error,
                      ),
                    ),
                    const Text(
                      'kurang',
                      style: TextStyle(
                        fontSize: 9,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStockColor(double percentage) {
    if (percentage <= 0.25) return AppColors.error;
    if (percentage <= 0.5) return AppColors.warning;
    return AppColors.success;
  }
}
