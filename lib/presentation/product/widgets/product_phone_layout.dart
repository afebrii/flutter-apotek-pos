import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/loading_indicator.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../bloc/product_management_bloc.dart';
import '../bloc/product_management_event.dart';
import '../bloc/product_management_state.dart';
import '../pages/product_detail_page.dart';
import 'product_list_item.dart';

/// Phone layout for Product List with navigation to detail page
class ProductPhoneLayout extends StatefulWidget {
  const ProductPhoneLayout({super.key});

  @override
  State<ProductPhoneLayout> createState() => _ProductPhoneLayoutState();
}

class _ProductPhoneLayoutState extends State<ProductPhoneLayout> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

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
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _isSearching = false;
    });
    context.read<ProductManagementBloc>().add(ProductManagementFetch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: AppColors.white),
                decoration: const InputDecoration(
                  hintText: 'Cari produk...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onSubmitted: _onSearch,
              )
            : const Text('Daftar Produk'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clearSearch,
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProductManagementBloc>().add(ProductManagementRefresh());
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductManagementBloc, ProductManagementState>(
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.surface,
                  child: Row(
                    children: [
                      Text(
                        'Total: ${state.total} produk',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (state.searchQuery != null && state.searchQuery!.isNotEmpty) ...[
                        const Spacer(),
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

                // Product list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<ProductManagementBloc>().add(ProductManagementRefresh());
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: state.products.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.products.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        final product = state.products[index];
                        return ProductListItem(
                          product: product,
                          onTap: () {
                            context.push(
                              ProductDetailPage(productId: product.id),
                            );
                          },
                        );
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
    );
  }

  Widget _buildEmptyState(String? searchQuery) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
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
