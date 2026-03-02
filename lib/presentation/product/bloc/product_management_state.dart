import '../../../data/models/responses/product_model.dart';

abstract class ProductManagementState {}

class ProductManagementInitial extends ProductManagementState {}

class ProductManagementLoading extends ProductManagementState {}

class ProductManagementLoaded extends ProductManagementState {
  final List<ProductModel> products;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool isLoadingMore;
  final String? searchQuery;
  final int? categoryId;

  ProductManagementLoaded({
    required this.products,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.isLoadingMore = false,
    this.searchQuery,
    this.categoryId,
  });

  bool get hasMore => currentPage < lastPage;

  ProductManagementLoaded copyWith({
    List<ProductModel>? products,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? isLoadingMore,
    String? searchQuery,
    int? categoryId,
  }) {
    return ProductManagementLoaded(
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

class ProductManagementError extends ProductManagementState {
  final String message;

  ProductManagementError({required this.message});
}

// Detail states
class ProductDetailLoading extends ProductManagementState {}

class ProductDetailLoaded extends ProductManagementState {
  final ProductModel product;

  ProductDetailLoaded({required this.product});
}

class ProductDetailError extends ProductManagementState {
  final String message;

  ProductDetailError({required this.message});
}
