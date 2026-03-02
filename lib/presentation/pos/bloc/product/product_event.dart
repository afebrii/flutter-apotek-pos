abstract class ProductEvent {}

class ProductFetch extends ProductEvent {
  final String? search;
  final int? categoryId;
  final bool refresh;

  ProductFetch({
    this.search,
    this.categoryId,
    this.refresh = false,
  });
}

class ProductLoadMore extends ProductEvent {}

class ProductSearchByBarcode extends ProductEvent {
  final String barcode;

  ProductSearchByBarcode(this.barcode);
}

class ProductReset extends ProductEvent {}
