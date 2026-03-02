import '../../../../data/models/responses/product_model.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductModel> products;
  final int currentPage;
  final int lastPage;
  final bool hasNextPage;
  final String? search;
  final int? categoryId;

  ProductLoaded({
    required this.products,
    required this.currentPage,
    required this.lastPage,
    required this.hasNextPage,
    this.search,
    this.categoryId,
  });

  ProductLoaded copyWith({
    List<ProductModel>? products,
    int? currentPage,
    int? lastPage,
    bool? hasNextPage,
    String? search,
    int? categoryId,
  }) {
    return ProductLoaded(
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      search: search ?? this.search,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

class ProductLoadingMore extends ProductLoaded {
  ProductLoadingMore({
    required super.products,
    required super.currentPage,
    required super.lastPage,
    required super.hasNextPage,
    super.search,
    super.categoryId,
  });
}

class ProductBarcodeFound extends ProductState {
  final ProductModel product;

  ProductBarcodeFound(this.product);
}

class ProductError extends ProductState {
  final String message;

  ProductError(this.message);
}
