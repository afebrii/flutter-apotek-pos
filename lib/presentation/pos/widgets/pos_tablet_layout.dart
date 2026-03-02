import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/search_input.dart';
import '../../../core/components/loading_indicator.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../core/utils/screen_size.dart';
import '../bloc/product/product_bloc.dart';
import '../bloc/product/product_event.dart';
import '../bloc/product/product_state.dart';
import '../bloc/category/category_bloc.dart';
import '../bloc/category/category_event.dart';
import '../bloc/category/category_state.dart';
import '../bloc/checkout/checkout_bloc.dart';
import '../bloc/checkout/checkout_event.dart';
import '../pages/checkout_page.dart';
import 'product_card.dart';
import 'category_chip.dart';
import 'cart_panel_widget.dart';

/// Tablet layout for POS page with split-screen (65% products | 35% cart)
class POSTabletLayout extends StatefulWidget {
  const POSTabletLayout({super.key});

  @override
  State<POSTabletLayout> createState() => _POSTabletLayoutState();
}

class _POSTabletLayoutState extends State<POSTabletLayout> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadData() {
    context.read<CategoryBloc>().add(CategoryFetch());
    context.read<ProductBloc>().add(ProductFetch());
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductBloc>().add(ProductLoadMore());
    }
  }

  void _onSearch(String query) {
    final categoryState = context.read<CategoryBloc>().state;
    int? categoryId;
    if (categoryState is CategoryLoaded) {
      categoryId = categoryState.selectedCategoryId;
    }

    context.read<ProductBloc>().add(
          ProductFetch(
            search: query.isEmpty ? null : query,
            categoryId: categoryId,
          ),
        );
  }

  void _onCategorySelected(int? categoryId) {
    context.read<CategoryBloc>().add(CategorySelect(categoryId));
    context.read<ProductBloc>().add(
          ProductFetch(
            search: _searchController.text.isEmpty
                ? null
                : _searchController.text,
            categoryId: categoryId,
          ),
        );
  }

  void _goToCheckout() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CheckoutPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kasir'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Row(
        children: [
          // Left Panel - Products (65%)
          Expanded(
            flex: 65,
            child: Container(
              color: AppColors.background,
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: AppColors.white,
                    child: SearchInput(
                      controller: _searchController,
                      hintText: 'Cari produk...',
                      onChanged: (value) {
                        Future.delayed(const Duration(milliseconds: 500), () {
                          if (_searchController.text == value) {
                            _onSearch(value);
                          }
                        });
                      },
                      onSubmitted: _onSearch,
                      onClear: () => _onSearch(''),
                    ),
                  ),

                  // Category Tabs
                  BlocBuilder<CategoryBloc, CategoryState>(
                    builder: (context, state) {
                      if (state is CategoryLoaded) {
                        return Container(
                          color: AppColors.white,
                          padding: const EdgeInsets.only(bottom: 12),
                          child: CategoryChipList(
                            categories: state.categories,
                            selectedCategoryId: state.selectedCategoryId,
                            onCategorySelected: _onCategorySelected,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // Product Grid (4 columns for tablet)
                  Expanded(
                    child: BlocConsumer<ProductBloc, ProductState>(
                      listener: (context, state) {
                        if (state is ProductError) {
                          context.showErrorSnackBar(state.message);
                        } else if (state is ProductBarcodeFound) {
                          context.read<CheckoutBloc>().add(
                                CheckoutAddItem(product: state.product),
                              );
                          context.showSuccessSnackBar(
                            '${state.product.name} ditambahkan ke keranjang',
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is ProductLoading) {
                          return const LoadingPage(message: 'Memuat produk...');
                        }

                        if (state is ProductError) {
                          return ErrorState(
                            message: state.message,
                            onRetry: _loadData,
                          );
                        }

                        if (state is ProductLoaded ||
                            state is ProductLoadingMore) {
                          final products = state is ProductLoaded
                              ? state.products
                              : (state as ProductLoadingMore).products;

                          if (products.isEmpty) {
                            return const EmptyState(
                              icon: Icons.inventory_2_outlined,
                              title: 'Produk tidak ditemukan',
                              subtitle: 'Coba ubah kata kunci pencarian',
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: () async => _loadData(),
                            child: GridView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount:
                                    ScreenSize.posGridColumns(context),
                                childAspectRatio: 0.85,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                              ),
                              itemCount: products.length +
                                  (state is ProductLoadingMore ? 1 : 0),
                              itemBuilder: (context, index) {
                                if (index >= products.length) {
                                  return const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16),
                                      child: CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                final product = products[index];
                                return ProductCard(
                                  product: product,
                                  onTap: () {
                                    context.read<CheckoutBloc>().add(
                                          CheckoutAddItem(product: product),
                                        );
                                  },
                                );
                              },
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Vertical Divider
          const VerticalDivider(width: 1, thickness: 1),

          // Right Panel - Cart (35%)
          Expanded(
            flex: 35,
            child: CartPanelWidget(
              onCheckout: _goToCheckout,
            ),
          ),
        ],
      ),
    );
  }
}
