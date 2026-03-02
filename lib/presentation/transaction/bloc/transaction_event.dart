abstract class TransactionEvent {}

class TransactionFetch extends TransactionEvent {
  final String? date;
  final String? status;

  TransactionFetch({this.date, this.status});
}

class TransactionLoadMore extends TransactionEvent {}

class TransactionRefresh extends TransactionEvent {}

class TransactionFetchDetail extends TransactionEvent {
  final int id;

  TransactionFetchDetail({required this.id});
}
