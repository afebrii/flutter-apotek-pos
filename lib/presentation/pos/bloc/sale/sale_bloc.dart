import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/datasources/sale_remote_datasource.dart';
import 'sale_event.dart';
import 'sale_state.dart';

class SaleBloc extends Bloc<SaleEvent, SaleState> {
  final SaleRemoteDatasource _datasource;

  SaleBloc({SaleRemoteDatasource? datasource})
      : _datasource = datasource ?? SaleRemoteDatasource(),
        super(SaleInitial()) {
    on<SaleCreate>(_onCreateSale);
    on<SaleFetch>(_onFetchSales);
    on<SaleLoadMore>(_onLoadMore);
    on<SaleFetchById>(_onFetchById);
    on<SaleVoid>(_onVoidSale);
    on<SaleFetchReceipt>(_onFetchReceipt);
    on<SaleReset>(_onReset);
  }

  Future<void> _onCreateSale(SaleCreate event, Emitter<SaleState> emit) async {
    emit(SaleCreating());

    final result = await _datasource.createSale(event.request);

    if (result.isLeft()) {
      final error = result.fold((l) => l, (r) => '');
      emit(SaleCreateError(message: error));
    } else {
      final response = result.fold((l) => null, (r) => r);
      if (response != null) {
        emit(SaleCreated(response: response));
      } else {
        emit(SaleCreateError(message: 'Gagal membuat transaksi'));
      }
    }
  }

  Future<void> _onFetchSales(SaleFetch event, Emitter<SaleState> emit) async {
    emit(SaleLoading());

    final result = await _datasource.getSales(
      date: event.date,
      status: event.status,
      page: event.page,
    );

    if (result.isLeft()) {
      final error = result.fold((l) => l, (r) => '');
      emit(SaleError(message: error));
    } else {
      final response = result.fold((l) => null, (r) => r);
      if (response != null) {
        emit(SaleLoaded(
          sales: response.sales,
          currentPage: response.currentPage,
          lastPage: response.lastPage,
          hasNextPage: response.hasNextPage,
          date: event.date,
          status: event.status,
        ));
      } else {
        emit(SaleError(message: 'Gagal memuat data transaksi'));
      }
    }
  }

  Future<void> _onLoadMore(SaleLoadMore event, Emitter<SaleState> emit) async {
    final currentState = state;
    if (currentState is! SaleLoaded) return;
    if (!currentState.hasNextPage) return;

    emit(SaleLoadingMore(
      sales: currentState.sales,
      currentPage: currentState.currentPage,
      lastPage: currentState.lastPage,
      date: currentState.date,
      status: currentState.status,
    ));

    final result = await _datasource.getSales(
      date: currentState.date,
      status: currentState.status,
      page: currentState.currentPage + 1,
    );

    if (result.isLeft()) {
      // Revert to previous state on error
      emit(SaleLoaded(
        sales: currentState.sales,
        currentPage: currentState.currentPage,
        lastPage: currentState.lastPage,
        hasNextPage: currentState.hasNextPage,
        date: currentState.date,
        status: currentState.status,
      ));
    } else {
      final response = result.fold((l) => null, (r) => r);
      if (response != null) {
        final allSales = [...currentState.sales, ...response.sales];
        emit(SaleLoaded(
          sales: allSales,
          currentPage: response.currentPage,
          lastPage: response.lastPage,
          hasNextPage: response.hasNextPage,
          date: currentState.date,
          status: currentState.status,
        ));
      } else {
        emit(SaleLoaded(
          sales: currentState.sales,
          currentPage: currentState.currentPage,
          lastPage: currentState.lastPage,
          hasNextPage: currentState.hasNextPage,
          date: currentState.date,
          status: currentState.status,
        ));
      }
    }
  }

  Future<void> _onFetchById(
      SaleFetchById event, Emitter<SaleState> emit) async {
    emit(SaleLoading());

    final result = await _datasource.getSaleById(event.id);

    if (result.isLeft()) {
      final error = result.fold((l) => l, (r) => '');
      emit(SaleError(message: error));
    } else {
      final sale = result.fold((l) => null, (r) => r);
      if (sale != null) {
        emit(SaleDetailLoaded(sale: sale));
      } else {
        emit(SaleError(message: 'Transaksi tidak ditemukan'));
      }
    }
  }

  void _onReset(SaleReset event, Emitter<SaleState> emit) {
    emit(SaleInitial());
  }

  Future<void> _onVoidSale(SaleVoid event, Emitter<SaleState> emit) async {
    emit(SaleVoiding());

    final result = await _datasource.voidSale(event.saleId, event.reason);

    if (result.isLeft()) {
      final error = result.fold((l) => l, (r) => '');
      emit(SaleVoidError(message: error));
    } else {
      final response = result.fold((l) => null, (r) => r);
      if (response != null) {
        emit(SaleVoided(response: response));
      } else {
        emit(SaleVoidError(message: 'Gagal membatalkan transaksi'));
      }
    }
  }

  Future<void> _onFetchReceipt(SaleFetchReceipt event, Emitter<SaleState> emit) async {
    emit(SaleLoading());

    final result = await _datasource.getReceipt(event.saleId);

    if (result.isLeft()) {
      final error = result.fold((l) => l, (r) => '');
      emit(SaleError(message: error));
    } else {
      final receipt = result.fold((l) => null, (r) => r);
      if (receipt != null) {
        emit(SaleReceiptLoaded(receipt: receipt));
      } else {
        emit(SaleError(message: 'Gagal memuat data receipt'));
      }
    }
  }
}
