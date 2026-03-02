import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/datasources/customer_remote_datasource.dart';
import '../../../data/models/responses/customer_model.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final CustomerRemoteDatasource _datasource;

  CustomerBloc({CustomerRemoteDatasource? datasource})
      : _datasource = datasource ?? CustomerRemoteDatasource(),
        super(CustomerInitial()) {
    on<CustomerFetch>(_onFetch);
    on<CustomerLoadMore>(_onLoadMore);
    on<CustomerSearch>(_onSearch);
    on<CustomerCreate>(_onCreate);
    on<CustomerSelect>(_onSelect);
    on<CustomerClearSelection>(_onClearSelection);
  }

  Future<void> _onFetch(CustomerFetch event, Emitter<CustomerState> emit) async {
    emit(CustomerLoading());

    final result = await _datasource.getCustomers(
      search: event.search,
      page: event.page,
    );

    if (result.isLeft()) {
      final error = result.fold((l) => l, (r) => '');
      emit(CustomerError(message: error));
    } else {
      final response = result.fold((l) => null, (r) => r);
      if (response != null) {
        emit(CustomerLoaded(
          customers: response.customers,
          currentPage: response.currentPage,
          lastPage: response.lastPage,
          hasNextPage: response.hasNextPage,
          search: event.search,
        ));
      } else {
        emit(CustomerError(message: 'Gagal memuat data pelanggan'));
      }
    }
  }

  Future<void> _onLoadMore(CustomerLoadMore event, Emitter<CustomerState> emit) async {
    final currentState = state;
    if (currentState is! CustomerLoaded) return;
    if (!currentState.hasNextPage) return;

    emit(CustomerLoadingMore(
      customers: currentState.customers,
      currentPage: currentState.currentPage,
      lastPage: currentState.lastPage,
      search: currentState.search,
      selectedCustomer: currentState.selectedCustomer,
    ));

    final result = await _datasource.getCustomers(
      search: currentState.search,
      page: currentState.currentPage + 1,
    );

    if (result.isLeft()) {
      emit(CustomerLoaded(
        customers: currentState.customers,
        currentPage: currentState.currentPage,
        lastPage: currentState.lastPage,
        hasNextPage: currentState.hasNextPage,
        search: currentState.search,
        selectedCustomer: currentState.selectedCustomer,
      ));
    } else {
      final response = result.fold((l) => null, (r) => r);
      if (response != null) {
        final allCustomers = [...currentState.customers, ...response.customers];
        emit(CustomerLoaded(
          customers: allCustomers,
          currentPage: response.currentPage,
          lastPage: response.lastPage,
          hasNextPage: response.hasNextPage,
          search: currentState.search,
          selectedCustomer: currentState.selectedCustomer,
        ));
      } else {
        emit(CustomerLoaded(
          customers: currentState.customers,
          currentPage: currentState.currentPage,
          lastPage: currentState.lastPage,
          hasNextPage: currentState.hasNextPage,
          search: currentState.search,
          selectedCustomer: currentState.selectedCustomer,
        ));
      }
    }
  }

  Future<void> _onSearch(CustomerSearch event, Emitter<CustomerState> emit) async {
    CustomerModel? selectedCustomer;
    if (state is CustomerLoaded) {
      selectedCustomer = (state as CustomerLoaded).selectedCustomer;
    }

    emit(CustomerLoading());

    final result = await _datasource.getCustomers(
      search: event.query.isEmpty ? null : event.query,
      page: 1,
    );

    if (result.isLeft()) {
      final error = result.fold((l) => l, (r) => '');
      emit(CustomerError(message: error));
    } else {
      final response = result.fold((l) => null, (r) => r);
      if (response != null) {
        emit(CustomerLoaded(
          customers: response.customers,
          currentPage: response.currentPage,
          lastPage: response.lastPage,
          hasNextPage: response.hasNextPage,
          search: event.query.isEmpty ? null : event.query,
          selectedCustomer: selectedCustomer,
        ));
      } else {
        emit(CustomerError(message: 'Gagal memuat data pelanggan'));
      }
    }
  }

  Future<void> _onCreate(CustomerCreate event, Emitter<CustomerState> emit) async {
    final previousState = state;
    emit(CustomerCreating());

    final result = await _datasource.createCustomer(event.request);

    if (result.isLeft()) {
      final error = result.fold((l) => l, (r) => '');
      emit(CustomerCreateError(message: error));
      // Restore previous state
      if (previousState is CustomerLoaded) {
        emit(previousState);
      }
    } else {
      final customer = result.fold((l) => null, (r) => r);
      if (customer != null) {
        emit(CustomerCreated(customer: customer));
        // Refresh list after creating
        add(CustomerFetch());
      } else {
        emit(CustomerCreateError(message: 'Gagal membuat pelanggan'));
        if (previousState is CustomerLoaded) {
          emit(previousState);
        }
      }
    }
  }

  void _onSelect(CustomerSelect event, Emitter<CustomerState> emit) {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      CustomerModel? customer;

      if (event.customerId != null) {
        customer = currentState.customers.firstWhere(
          (c) => c.id == event.customerId,
          orElse: () => CustomerModel(
            id: event.customerId!,
            name: event.customerName ?? '',
          ),
        );
      }

      emit(currentState.copyWith(selectedCustomer: customer));
    }
  }

  void _onClearSelection(CustomerClearSelection event, Emitter<CustomerState> emit) {
    if (state is CustomerLoaded) {
      final currentState = state as CustomerLoaded;
      emit(currentState.copyWith(clearSelection: true));
    }
  }
}
