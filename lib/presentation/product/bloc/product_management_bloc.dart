import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/product_remote_datasource.dart';
import 'product_management_event.dart';
import 'product_management_state.dart';

class ProductManagementBloc extends Bloc<ProductManagementEvent, ProductManagementState> {
  final ProductRemoteDatasource _datasource;

  ProductManagementBloc({ProductRemoteDatasource? datasource})
      : _datasource = datasource ?? ProductRemoteDatasource(),
        super(ProductManagementInitial()) {
    on<ProductManagementFetch>(_onFetch);
    on<ProductManagementLoadMore>(_onLoadMore);
    on<ProductManagementRefresh>(_onRefresh);
    on<ProductManagementSearch>(_onSearch);
    on<ProductManagementFetchDetail>(_onFetchDetail);
  }

  Future<void> _onFetch(
    ProductManagementFetch event,
    Emitter<ProductManagementState> emit,
  ) async {
    emit(ProductManagementLoading());

    final result = await _datasource.getProducts(
      search: event.search,
      categoryId: event.categoryId,
      page: 1,
    );

    result.fold(
      (error) => emit(ProductManagementError(message: error)),
      (response) => emit(ProductManagementLoaded(
        products: response.products,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        total: response.total,
        searchQuery: event.search,
        categoryId: event.categoryId,
      )),
    );
  }

  Future<void> _onLoadMore(
    ProductManagementLoadMore event,
    Emitter<ProductManagementState> emit,
  ) async {
    if (state is! ProductManagementLoaded) return;

    final currentState = state as ProductManagementLoaded;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await _datasource.getProducts(
      search: currentState.searchQuery,
      categoryId: currentState.categoryId,
      page: currentState.currentPage + 1,
    );

    // Re-check state after async
    if (state is! ProductManagementLoaded) return;
    final updatedState = state as ProductManagementLoaded;

    result.fold(
      (error) => emit(updatedState.copyWith(isLoadingMore: false)),
      (response) {
        final allProducts = [
          ...updatedState.products,
          ...response.products,
        ];
        emit(ProductManagementLoaded(
          products: allProducts,
          currentPage: response.currentPage,
          lastPage: response.lastPage,
          total: response.total,
          searchQuery: updatedState.searchQuery,
          categoryId: updatedState.categoryId,
        ));
      },
    );
  }

  Future<void> _onRefresh(
    ProductManagementRefresh event,
    Emitter<ProductManagementState> emit,
  ) async {
    String? search;
    int? categoryId;

    if (state is ProductManagementLoaded) {
      final currentState = state as ProductManagementLoaded;
      search = currentState.searchQuery;
      categoryId = currentState.categoryId;
    }

    add(ProductManagementFetch(search: search, categoryId: categoryId));
  }

  Future<void> _onSearch(
    ProductManagementSearch event,
    Emitter<ProductManagementState> emit,
  ) async {
    add(ProductManagementFetch(search: event.query));
  }

  Future<void> _onFetchDetail(
    ProductManagementFetchDetail event,
    Emitter<ProductManagementState> emit,
  ) async {
    emit(ProductDetailLoading());

    final result = await _datasource.getProductById(event.id);

    result.fold(
      (error) => emit(ProductDetailError(message: error)),
      (product) => emit(ProductDetailLoaded(product: product)),
    );
  }
}
