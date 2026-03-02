import '../../../data/models/responses/customer_model.dart';

abstract class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerLoaded extends CustomerState {
  final List<CustomerModel> customers;
  final int currentPage;
  final int lastPage;
  final bool hasNextPage;
  final String? search;
  final CustomerModel? selectedCustomer;

  CustomerLoaded({
    required this.customers,
    required this.currentPage,
    required this.lastPage,
    required this.hasNextPage,
    this.search,
    this.selectedCustomer,
  });

  CustomerLoaded copyWith({
    List<CustomerModel>? customers,
    int? currentPage,
    int? lastPage,
    bool? hasNextPage,
    String? search,
    CustomerModel? selectedCustomer,
    bool clearSelection = false,
  }) {
    return CustomerLoaded(
      customers: customers ?? this.customers,
      currentPage: currentPage ?? this.currentPage,
      lastPage: lastPage ?? this.lastPage,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      search: search ?? this.search,
      selectedCustomer: clearSelection ? null : (selectedCustomer ?? this.selectedCustomer),
    );
  }
}

class CustomerLoadingMore extends CustomerState {
  final List<CustomerModel> customers;
  final int currentPage;
  final int lastPage;
  final String? search;
  final CustomerModel? selectedCustomer;

  CustomerLoadingMore({
    required this.customers,
    required this.currentPage,
    required this.lastPage,
    this.search,
    this.selectedCustomer,
  });
}

class CustomerCreating extends CustomerState {}

class CustomerCreated extends CustomerState {
  final CustomerModel customer;

  CustomerCreated({required this.customer});
}

class CustomerError extends CustomerState {
  final String message;

  CustomerError({required this.message});
}

class CustomerCreateError extends CustomerState {
  final String message;

  CustomerCreateError({required this.message});
}
