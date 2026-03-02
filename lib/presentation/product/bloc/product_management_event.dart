abstract class ProductManagementEvent {}

class ProductManagementFetch extends ProductManagementEvent {
  final String? search;
  final int? categoryId;

  ProductManagementFetch({this.search, this.categoryId});
}

class ProductManagementLoadMore extends ProductManagementEvent {}

class ProductManagementRefresh extends ProductManagementEvent {}

class ProductManagementSearch extends ProductManagementEvent {
  final String query;

  ProductManagementSearch({required this.query});
}

class ProductManagementFetchDetail extends ProductManagementEvent {
  final int id;

  ProductManagementFetchDetail({required this.id});
}
