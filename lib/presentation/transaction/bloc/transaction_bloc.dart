import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/transaction_remote_datasource.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRemoteDatasource _datasource;

  TransactionBloc({TransactionRemoteDatasource? datasource})
      : _datasource = datasource ?? TransactionRemoteDatasource(),
        super(TransactionInitial()) {
    on<TransactionFetch>(_onFetch);
    on<TransactionLoadMore>(_onLoadMore);
    on<TransactionRefresh>(_onRefresh);
    on<TransactionFetchDetail>(_onFetchDetail);
  }

  Future<void> _onFetch(
    TransactionFetch event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());

    final result = await _datasource.getTransactions(
      date: event.date,
      status: event.status,
      page: 1,
    );

    result.fold(
      (error) => emit(TransactionError(message: error)),
      (response) => emit(TransactionLoaded(
        transactions: response.transactions,
        currentPage: response.currentPage,
        lastPage: response.lastPage,
        total: response.total,
        filterDate: event.date,
        filterStatus: event.status,
      )),
    );
  }

  Future<void> _onLoadMore(
    TransactionLoadMore event,
    Emitter<TransactionState> emit,
  ) async {
    if (state is! TransactionLoaded) return;

    final currentState = state as TransactionLoaded;
    if (!currentState.hasMore || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await _datasource.getTransactions(
      date: currentState.filterDate,
      status: currentState.filterStatus,
      page: currentState.currentPage + 1,
    );

    // Re-check state after async
    if (state is! TransactionLoaded) return;
    final updatedState = state as TransactionLoaded;

    result.fold(
      (error) => emit(updatedState.copyWith(isLoadingMore: false)),
      (response) {
        final allTransactions = [
          ...updatedState.transactions,
          ...response.transactions,
        ];
        emit(TransactionLoaded(
          transactions: allTransactions,
          currentPage: response.currentPage,
          lastPage: response.lastPage,
          total: response.total,
          filterDate: updatedState.filterDate,
          filterStatus: updatedState.filterStatus,
        ));
      },
    );
  }

  Future<void> _onRefresh(
    TransactionRefresh event,
    Emitter<TransactionState> emit,
  ) async {
    String? date;
    String? status;

    if (state is TransactionLoaded) {
      final currentState = state as TransactionLoaded;
      date = currentState.filterDate;
      status = currentState.filterStatus;
    }

    add(TransactionFetch(date: date, status: status));
  }

  Future<void> _onFetchDetail(
    TransactionFetchDetail event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionDetailLoading());

    final result = await _datasource.getTransactionDetail(event.id);

    result.fold(
      (error) => emit(TransactionDetailError(message: error)),
      (transaction) => emit(TransactionDetailLoaded(transaction: transaction)),
    );
  }
}
