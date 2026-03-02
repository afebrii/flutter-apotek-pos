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
import 'product_detail_panel.dart';

/// Tablet layout for Product List with master-detail pattern
/// Left: Product list (40%) | Right: Product detail (60%)
class ProductTabletLayout extends StatefulWidget {
  const ProductTabletLayout({super.key});

  @override
  State<ProductTabletLayout> createState() => _ProductTabletLayoutState();
}

class _ProductTabletLayoutState extends State<ProductTabletLayout> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  ProductModel? _selectedProduct;
  bool _isLoadingDetail = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductManagementBloc>().add(ProductManagementLoadMore());
    }
  }

  void _onSearch(String query) {
    context.read<ProductManagementBloc>().add(ProductManagementSearch(query: query));
    setState(() {
      _selectedProduct = null;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<ProductManagementBloc>().add(ProductManagementFetch());
    setState(() {
      _selectedProduct = null;
    });
  }

  Future<void> _selectProduct(ProductModel product) async {
    setState(() {
      _isLoadingDetail = true;
      _selectedProduct = product;
    });

    // Fetch full product detail
    final datasource = ProductRemoteDatasource();
    final result = await datasource.getProductById(product.id);

    if (mounted) {
      result.fold(
        (error) {
          setState(() {
            _isLoadingDetail = false;
          });
        },
        (fullProduct) {
          setState(() {
            _selectedProduct = fullProduct;
            _isLoadingDetail = false;
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Panel - Product List (40%)
          Expanded(
            flex: 40,
            child: _buildListPanel(),
          ),

          // Vertical Divider
          const VerticalDivider(width: 1, thickness: 1),

          // Right Panel - Product Detail (60%)
          Expanded(
            flex: 60,
            child: Container(
              color: AppColors.white,
              child: _buildDetailPanel(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListPanel() {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primary,
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Title row
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: AppColors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Daftar Produk',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        context.read<ProductManagementBloc>().add(ProductManagementRefresh());
                      },
                      icon: const Icon(Icons.refresh, color: AppColors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari produk...',
                      hintStyle: const TextStyle(color: AppColors.textHint),
                      prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: _clearSearch,
                              icon: const Icon(Icons.close, color: AppColors.grey),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: _onSearch,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Product list
        Expanded(
          child: BlocBuilder<ProductManagementBloc, ProductManagementState>(
            builder: (context, state) {
              if (state is ProductManagementLoading) {
                return const LoadingPage(message: 'Memuat produk...');
              }

              if (state is ProductManagementError) {
                return ErrorState(
                  message: state.message,
                  onRetry: () {
                    context.read<ProductManagementBloc>().add(ProductManagementFetch());
                  },
                );
              }

              if (state is ProductManagementLoaded) {
                if (state.products.isEmpty) {
                  return _buildEmptyState(state.searchQuery);
                }

                return Column(
                  children: [
                    // Summary bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      color: AppColors.background,
                      child: Row(
                        children: [
                          Text(
                            '${state.total} produk',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (state.searchQuery != null &&
                              state.searchQuery!.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _clearSearch,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '"${state.searchQuery}"',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.close,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // List
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          context.read<ProductManagementBloc>().add(ProductManagementRefresh());
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(12),
                          itemCount: state.products.length + (state.hasMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index >= state.products.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }

                            final product = state.products[index];
                            final isSelected = _selectedProduct?.id == product.id;

                            return _buildProductItem(product, isSelected);
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductItem(ProductModel product, bool isSelected) {
    final stockColor = product.totalStock == 0
        ? AppColors.error
        : product.isLowStock
            ? AppColors.warning
            : AppColors.success;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _selectProduct(product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Stock indicator
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: stockColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${product.totalStock}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: stockColor,
                      ),
                    ),
                    Text(
                      product.baseUnit?.name ?? 'pcs',
                      style: TextStyle(
                        fontSize: 9,
                        color: stockColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (product.requiresPrescription)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Rx',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.code}${product.category != null ? ' • ${product.category!.name}' : ''}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.sellingPriceAmount.currencyFormatRp,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: AppColors.white,
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.grey,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailPanel() {
    if (_selectedProduct == null) {
      return const ProductDetailEmptyPanel();
    }

    if (_isLoadingDetail) {
      return const ProductDetailLoadingPanel();
    }

    return ProductDetailPanel(product: _selectedProduct!);
  }

  Widget _buildEmptyState(String? searchQuery) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: AppColors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery != null && searchQuery.isNotEmpty
                ? 'Produk tidak ditemukan'
                : 'Belum ada produk',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery != null && searchQuery.isNotEmpty
                ? 'Coba kata kunci lain'
                : 'Produk akan muncul di sini',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
