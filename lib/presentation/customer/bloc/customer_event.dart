import '../../../data/models/requests/customer_request_model.dart';

abstract class CustomerEvent {}

class CustomerFetch extends CustomerEvent {
  final String? search;
  final int page;

  CustomerFetch({this.search, this.page = 1});
}

class CustomerLoadMore extends CustomerEvent {}

class CustomerSearch extends CustomerEvent {
  final String query;

  CustomerSearch({required this.query});
}

class CustomerCreate extends CustomerEvent {
  final CustomerRequestModel request;

  CustomerCreate({required this.request});
}

class CustomerSelect extends CustomerEvent {
  final int? customerId;
  final String? customerName;

  CustomerSelect({this.customerId, this.customerName});
}

class CustomerClearSelection extends CustomerEvent {}
