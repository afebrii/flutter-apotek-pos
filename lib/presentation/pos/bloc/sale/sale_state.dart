import '../../../../data/models/responses/sale_model.dart';
import '../../../../data/models/responses/receipt_model.dart';
import '../../../../data/datasources/sale_remote_datasource.dart';

abstract class SaleState {}

class SaleInitial extends SaleState {}

class SaleLoading extends SaleState {}

class SaleCreating extends SaleState {}

class SaleCreated extends SaleState {
  final CreateSaleResponse response;

  SaleCreated({required this.response});
}

class SaleCreateError extends SaleState {
  final String message;

  SaleCreateError({required this.message});
}

class SaleLoaded extends SaleState {
  final List<SaleModel> sales;
  final int currentPage;
  final int lastPage;
  final bool hasNextPage;
  final String? date;
  final String? status;

  SaleLoaded({
    required this.sales,
    required this.currentPage,
    required this.lastPage,
    required this.hasNextPage,
    this.date,
    this.status,
  });
}

class SaleLoadingMore extends SaleState {
  final List<SaleModel> sales;
  final int currentPage;
  final int lastPage;
  final String? date;
  final String? status;

  SaleLoadingMore({
    required this.sales,
    required this.currentPage,
    required this.lastPage,
    this.date,
    this.status,
  });
}

class SaleDetailLoaded extends SaleState {
  final SaleModel sale;

  SaleDetailLoaded({required this.sale});
}

class SaleVoiding extends SaleState {}

class SaleVoided extends SaleState {
  final VoidSaleResponse response;

  SaleVoided({required this.response});
}

class SaleVoidError extends SaleState {
  final String message;

  SaleVoidError({required this.message});
}

class SaleReceiptLoaded extends SaleState {
  final ReceiptModel receipt;

  SaleReceiptLoaded({required this.receipt});
}

class SaleError extends SaleState {
  final String message;

  SaleError({required this.message});
}
