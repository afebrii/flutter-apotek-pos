import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/datasources/product_remote_datasource.dart';
import '../../../../data/models/responses/product_model.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRemoteDatasource _productRemoteDatasource;

  String? _currentSearch;
  int? _currentCategoryId;

  ProductBloc(this._productRemoteDatasource) : super(ProductInitial()) {
    on<ProductFetch>(_onFetch);
    on<ProductLoadMore>(_onLoadMore);
    on<ProductSearchByBarcode>(_onSearchByBarcode);
    on<ProductReset>(_onReset);
  }

  Future<void> _onFetch(
    ProductFetch event,
    Emitter<ProductState> emit,
  ) async {
    _currentSearch = event.search;
    _currentCategoryId = event.categoryId;

    emit(ProductLoading());

    final result = await _productRemoteDatasource.getProducts(
      search: event.search,
      categoryId: event.categoryId,
      page: 1,
    );

    if (result.isLeft()) {
      final error = result.fold((l) => l, (r) => '');
      emit(ProductError(error));
    } else {
      final response = result.fold((l) => null, (r) => r);
      if (response != null) {
        emit(ProductLoaded(
          products: response.products,
          currentPage: response.currentPage,
          lastPage: response.lastPage,
          hasNextPage: response.hasNextPage,
          search: event.search,
          categoryId: event.categoryId,
        ));
      }
    }
  }

  Future<void> _onLoadMore(
    ProductLoadMore event,
    Emitter<ProductState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ProductLoaded) return;
    if (!currentState.hasNextPage) return;
    if (currentState is ProductLoadingMore) return;

    emit(ProductLoadingMore(
      products: currentState.products,
      currentPage: currentState.currentPage,
      lastPage: currentState.lastPage,
      hasNextPage: currentState.hasNextPage,
      search: currentState.search,
      categoryId: currentState.categoryId,
    ));

    final result = await _productRemoteDatasource.getProducts(
      search: _currentSearch,
      categoryId: _currentCategoryId,
      page: currentState.currentPage + 1,
    );

    if (result.isLeft()) {
      // On error, revert to previous state
      emit(currentState);
    } else {
      final response = result.fold((l) => null, (r) => r);
      if (response != null) {
        final List<ProductModel> allProducts = [
          ...currentState.products,
          ...response.products,
        ];
        emit(ProductLoaded(
          products: allProducts,
          currentPage: response.currentPage,
          lastPage: response.lastPage,
          hasNextPage: response.hasNextPage,
          search: _currentSearch,
          categoryId: _currentCategoryId,
        ));
      }
    }
  }

  Future<void> _onSearchByBarcode(
    ProductSearchByBarcode event,
    Emitter<ProductState> emit,
  ) async {
    final result = await _productRemoteDatasource.searchByBarcode(event.barcode);

    if (result.isLeft()) {
      final error = result.fold((l) => l, (r) => '');
      emit(ProductError(error));
    } else {
      final product = result.fold((l) => null, (r) => r);
      if (product != null) {
        emit(ProductBarcodeFound(product));
      }
    }
  }

  void _onReset(
    ProductReset event,
    Emitter<ProductState> emit,
  ) {
    _currentSearch = null;
    _currentCategoryId = null;
    emit(ProductInitial());
  }
}
