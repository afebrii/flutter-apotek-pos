import '../../../data/models/responses/transaction_model.dart';

abstract class TransactionState {}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionModel> transactions;
  final int currentPage;
  final int lastPage;
  final int total;
  final bool isLoadingMore;
  final String? filterDate;
  final String? filterStatus;

  TransactionLoaded({
    required this.transactions,
    required this.currentPage,
    required this.lastPage,
    required this.total,
    this.isLoadingMore = false,
    this.filterDate,
    this.filterStatus,
  });

  bool get hasMore => currentPage < lastPage;

  TransactionLoaded copyWith({
    List<TransactionModel>? transactions,
    int? currentPage,
    int? lastPage,
    int? total,
    bool? isLoadingMore,
    String? filterDate,
    String? filterStatus,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      total: total ?? this.total,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      filterDate: filterDate ?? this.filterDate,
      filterStatus: filterStatus ?? this.filterStatus,
    );
  }
}

class TransactionError extends TransactionState {
  final String message;

  TransactionError({required this.message});
}

// Detail states
class TransactionDetailLoading extends TransactionState {}

class TransactionDetailLoaded extends TransactionState {
  final TransactionDetailModel transaction;

  TransactionDetailLoaded({required this.transaction});
}

class TransactionDetailError extends TransactionState {
  final String message;

  TransactionDetailError({required this.message});
}
