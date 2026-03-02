import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/loading_indicator.dart';
import '../../../core/extensions/double_ext.dart';
import '../../../data/datasources/product_remote_datasource.dart';
import '../../../data/models/responses/product_model.dart';
import '../bloc/product_management_bloc.dart';
import '../bloc/product_management_event.dart';
import '../bloc/product_management_state.dart';

class ProductDetailPage extends StatelessWidget {
  final int productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductManagementBloc(
        datasource: ProductRemoteDatasource(),
      )..add(ProductManagementFetchDetail(id: productId)),
      child: const _ProductDetailView(),
    );
  }
}

class _ProductDetailView extends StatelessWidget {
  const _ProductDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<ProductManagementBloc, ProductManagementState>(
        builder: (context, state) {
          if (state is ProductDetailLoading) {
            return const LoadingPage(message: 'Memuat detail...');
          }

          if (state is ProductDetailError) {
            return ErrorState(
              message: state.message,
              onRetry: () => Navigator.pop(context),
            );
          }

          if (state is ProductDetailLoaded) {
            return _buildContent(context, state.product);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, ProductModel product) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product header card
          _buildHeaderCard(product),
          const SizedBox(height: 16),

          // Price info
          _buildSectionHeader('Informasi Harga'),
          const SizedBox(height: 8),
          _buildPriceCard(product),
          const SizedBox(height: 16),

          // Stock info
          _buildSectionHeader('Informasi Stok'),
          const SizedBox(height: 8),
          _buildStockCard(product),
          const SizedBox(height: 16),

          // Batches
          if (product.batches.isNotEmpty) ...[
            _buildSectionHeader('Batch Tersedia (${product.batches.length})'),
            const SizedBox(height: 8),
            _buildBatchesList(product.batches),
            const SizedBox(height: 16),
          ],

          // Unit conversions
          if (product.unitConversions.isNotEmpty) ...[
            _buildSectionHeader('Konversi Satuan'),
            const SizedBox(height: 8),
            _buildUnitConversions(product),
            const SizedBox(height: 16),
          ],

          // Description
          if (product.description != null && product.description!.isNotEmpty) ...[
            _buildSectionHeader('Deskripsi'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  product.description!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderCard(ProductModel product) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and prescription badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (product.requiresPrescription)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.medical_services,
                          size: 12,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Resep',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            if (product.genericName != null) ...[
              const SizedBox(height: 4),
              Text(
                product.genericName!,
                style: const TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const Divider(height: 24),

            // Codes
            _buildInfoRow('Kode Produk', product.code),
            if (product.barcode != null && product.barcode!.isNotEmpty)
              _buildInfoRow('Barcode', product.barcode!),
            if (product.kfaCode != null && product.kfaCode!.isNotEmpty)
              _buildInfoRow('Kode KFA', product.kfaCode!),

            // Category
            if (product.category != null)
              _buildInfoRow('Kategori', product.category!.name),

            // Unit
            if (product.baseUnit != null)
              _buildInfoRow('Satuan Dasar', product.baseUnit!.name),

            // Rack location
            if (product.rackLocation != null && product.rackLocation!.isNotEmpty)
              _buildInfoRow('Lokasi Rak', product.rackLocation!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildPriceCard(ProductModel product) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Harga Beli',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.purchasePriceAmount.currencyFormatRp,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1,
              height: 40,
              color: AppColors.divider,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Harga Jual',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.sellingPriceAmount.currencyFormatRp,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
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

  Widget _buildStockCard(ProductModel product) {
    final stockColor = product.totalStock == 0
        ? AppColors.error
        : product.isLowStock
            ? AppColors.warning
            : AppColors.success;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Current stock
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: stockColor.withValues(alpha: 0.1),
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
                            color: stockColor,
                          ),
                        ),
                        Text(
                          product.baseUnit?.name ?? 'pcs',
                          style: TextStyle(
                            fontSize: 10,
                            color: stockColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Stok Saat Ini',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Min stock
            Expanded(
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${product.minStock}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Stok Minimum',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Max stock
            if (product.maxStock != null)
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${product.maxStock}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Stok Maksimum',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
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

  Widget _buildBatchesList(List<BatchModel> batches) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: batches.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final batch = batches[index];
          return _buildBatchItem(batch);
        },
      ),
    );
  }

  Widget _buildBatchItem(BatchModel batch) {
    Color statusColor = AppColors.success;
    String statusText = 'Aktif';

    if (batch.isExpired) {
      statusColor = AppColors.error;
      statusText = 'Expired';
    } else if (batch.isExpiringSoon) {
      statusColor = AppColors.warning;
      statusText = 'Segera Expired';
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          // Stock
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${batch.stock}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Batch info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batch.batchNumber,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Exp: ${_formatDate(batch.expiredDate)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitConversions(ProductModel product) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: product.unitConversions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final conv = product.unitConversions[index];
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '1 ${conv.unit?.name ?? '-'} = ${conv.conversionValue.toStringAsFixed(0)} ${product.baseUnit?.name ?? 'pcs'}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Text(
                  conv.sellingPriceAmount.currencyFormatRp,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          );
        },
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
