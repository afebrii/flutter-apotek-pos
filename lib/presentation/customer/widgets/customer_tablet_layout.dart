import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/loading_indicator.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../data/models/responses/customer_model.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import 'customer_detail_panel.dart';
import 'add_customer_dialog.dart';

/// Tablet layout for Customer List with master-detail pattern
/// Left: Customer list (40%) | Right: Customer detail (60%)
class CustomerTabletLayout extends StatefulWidget {
  final bool selectionMode;

  const CustomerTabletLayout({
    super.key,
    this.selectionMode = false,
  });

  @override
  State<CustomerTabletLayout> createState() => _CustomerTabletLayoutState();
}

class _CustomerTabletLayoutState extends State<CustomerTabletLayout> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  CustomerModel? _selectedCustomer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
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
    setState(() {
      _selectedCustomer = null;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<CustomerBloc>().add(CustomerFetch());
    setState(() {
      _selectedCustomer = null;
    });
  }

  void _selectCustomer(CustomerModel customer) {
    if (widget.selectionMode) {
      Navigator.pop(context, customer);
    } else {
      setState(() {
        _selectedCustomer = customer;
      });
    }
  }

  void _showAddCustomerDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<CustomerBloc>(),
        child: const AddCustomerDialog(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomerCreated) {
            context.showSuccessSnackBar('Pelanggan berhasil ditambahkan');
            setState(() {
              _selectedCustomer = state.customer;
            });
            if (widget.selectionMode) {
              Navigator.pop(context, state.customer);
            }
          } else if (state is CustomerCreateError) {
            context.showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          return Row(
            children: [
              // Left Panel - Customer List (40%)
              Expanded(
                flex: 40,
                child: _buildListPanel(state),
              ),

              // Vertical Divider
              const VerticalDivider(width: 1, thickness: 1),

              // Right Panel - Customer Detail (60%)
              Expanded(
                flex: 60,
                child: Container(
                  color: AppColors.white,
                  child: _buildDetailPanel(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildListPanel(CustomerState state) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.primary,
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                // Title row
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: AppColors.white),
                    ),
                    Expanded(
                      child: Text(
                        widget.selectionMode ? 'Pilih Pelanggan' : 'Daftar Pelanggan',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _showAddCustomerDialog,
                      icon: const Icon(Icons.person_add, color: AppColors.white),
                    ),
                    IconButton(
                      onPressed: () {
                        context.read<CustomerBloc>().add(CustomerFetch());
                      },
                      icon: const Icon(Icons.refresh, color: AppColors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari nama atau telepon...',
                      hintStyle: const TextStyle(color: AppColors.textHint),
                      prefixIcon: const Icon(Icons.search, color: AppColors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              onPressed: _clearSearch,
                              icon: const Icon(Icons.close, color: AppColors.grey),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: _onSearch,
                    onChanged: (value) {
                      setState(() {});
                      // Debounce search
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (_searchController.text == value && value.isNotEmpty) {
                          _onSearch(value);
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Customer list
        Expanded(
          child: _buildCustomerList(state),
        ),
      ],
    );
  }

  Widget _buildCustomerList(CustomerState state) {
    if (state is CustomerLoading) {
      return const LoadingPage(message: 'Memuat pelanggan...');
    }

    if (state is CustomerError) {
      return ErrorState(
        message: state.message,
        onRetry: () {
          context.read<CustomerBloc>().add(CustomerFetch());
        },
      );
    }

    if (state is CustomerLoaded || state is CustomerLoadingMore) {
      final customers = state is CustomerLoaded
          ? state.customers
          : (state as CustomerLoadingMore).customers;
      final searchQuery = state is CustomerLoaded ? state.search : null;

      if (customers.isEmpty) {
        return _buildEmptyState(searchQuery);
      }

      return Column(
        children: [
          // Summary bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppColors.background,
            child: Row(
              children: [
                Text(
                  '${customers.length} pelanggan',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (searchQuery != null && searchQuery.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _clearSearch,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '"$searchQuery"',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.close,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<CustomerBloc>().add(CustomerFetch());
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: customers.length + (state is CustomerLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= customers.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final customer = customers[index];
                  final isSelected = _selectedCustomer?.id == customer.id;

                  return _buildCustomerItem(customer, isSelected);
                },
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildCustomerItem(CustomerModel customer, bool isSelected) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? const BorderSide(color: AppColors.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _selectCustomer(customer),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppColors.white : AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Customer info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          customer.phone ?? '-',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (customer.email != null && customer.email!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 14,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              customer.email!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: AppColors.white,
                  ),
                )
              else
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.grey,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailPanel() {
    if (_selectedCustomer == null) {
      return const CustomerDetailEmptyPanel();
    }

    return CustomerDetailPanel(customer: _selectedCustomer!);
  }

  Widget _buildEmptyState(String? searchQuery) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: AppColors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery != null && searchQuery.isNotEmpty
                ? 'Pelanggan tidak ditemukan'
                : 'Belum ada pelanggan',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery != null && searchQuery.isNotEmpty
                ? 'Coba kata kunci lain'
                : 'Tambahkan pelanggan baru',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
          if (searchQuery == null || searchQuery.isEmpty) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showAddCustomerDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('Tambah Pelanggan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
