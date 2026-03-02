import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/search_input.dart';
import '../../../core/components/loading_indicator.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import 'customer_list_item.dart';
import 'add_customer_dialog.dart';

/// Phone layout for Customer List with navigation
class CustomerPhoneLayout extends StatefulWidget {
  final bool selectionMode;

  const CustomerPhoneLayout({
    super.key,
    this.selectionMode = false,
  });

  @override
  State<CustomerPhoneLayout> createState() => _CustomerPhoneLayoutState();
}

class _CustomerPhoneLayoutState extends State<CustomerPhoneLayout> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<CustomerBloc>().add(CustomerLoadMore());
    }
  }

  void _onSearch(String query) {
    context.read<CustomerBloc>().add(CustomerSearch(query: query));
  }

  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddCustomerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectionMode ? 'Pilih Pelanggan' : 'Pelanggan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddCustomerDialog,
          ),
        ],
      ),
      body: BlocConsumer<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerCreated) {
            context.showSuccessSnackBar('Pelanggan berhasil ditambahkan');
            if (widget.selectionMode) {
              Navigator.pop(context, state.customer);
            }
          } else if (state is CustomerCreateError) {
            context.showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Search bar
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.white,
                child: SearchInput(
                  controller: _searchController,
                  hintText: 'Cari nama atau telepon...',
                  onChanged: (value) {
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (_searchController.text == value) {
                        _onSearch(value);
                      }
                    });
                  },
                  onSubmitted: _onSearch,
                  onClear: () => _onSearch(''),
                ),
              ),

              // Customer list
              Expanded(
                child: _buildContent(state),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddCustomerDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.white),
      ),
    );
  }

  Widget _buildContent(CustomerState state) {
    if (state is CustomerLoading) {
      return const LoadingPage(message: 'Memuat pelanggan...');
    }

    if (state is CustomerError) {
      return ErrorState(
        message: state.message,
        onRetry: () => context.read<CustomerBloc>().add(CustomerFetch()),
      );
    }

    if (state is CustomerLoaded || state is CustomerLoadingMore) {
      final customers = state is CustomerLoaded
          ? state.customers
          : (state as CustomerLoadingMore).customers;

      if (customers.isEmpty) {
        return const EmptyState(
          icon: Icons.people_outline,
          title: 'Tidak ada pelanggan',
          subtitle: 'Tambahkan pelanggan baru dengan tombol +',
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<CustomerBloc>().add(CustomerFetch());
        },
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: customers.length + (state is CustomerLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= customers.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final customer = customers[index];
            return CustomerListItem(
              customer: customer,
              onTap: widget.selectionMode
                  ? () => Navigator.pop(context, customer)
                  : null,
            );
          },
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
