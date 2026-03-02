import '../../../../data/models/requests/sale_request_model.dart';

abstract class SaleEvent {}

class SaleCreate extends SaleEvent {
  final SaleRequestModel request;

  SaleCreate({required this.request});
}

class SaleFetch extends SaleEvent {
  final String? date;
  final String? status;
  final int page;

  SaleFetch({
    this.date,
    this.status,
    this.page = 1,
  });
}

class SaleLoadMore extends SaleEvent {}

class SaleFetchById extends SaleEvent {
  final int id;

  SaleFetchById({required this.id});
}

class SaleVoid extends SaleEvent {
  final int saleId;
  final String reason;

  SaleVoid({required this.saleId, required this.reason});
}

class SaleFetchReceipt extends SaleEvent {
  final int saleId;

  SaleFetchReceipt({required this.saleId});
}

class SaleReset extends SaleEvent {}
