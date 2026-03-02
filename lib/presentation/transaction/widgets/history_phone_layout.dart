import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/loading_indicator.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../pages/transaction_detail_page.dart';
import 'transaction_list_item.dart';

/// Phone layout for Transaction History with full screen list
class HistoryPhoneLayout extends StatefulWidget {
  const HistoryPhoneLayout({super.key});

  @override
  State<HistoryPhoneLayout> createState() => _HistoryPhoneLayoutState();
}

class _HistoryPhoneLayoutState extends State<HistoryPhoneLayout> {
  final ScrollController _scrollController = ScrollController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TransactionBloc>().add(TransactionLoadMore());
    }
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && mounted) {
      setState(() {
        _selectedDate = picked;
      });
      final dateStr =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      context.read<TransactionBloc>().add(TransactionFetch(date: dateStr));
    }
  }

  void _clearFilter() {
    setState(() {
      _selectedDate = null;
    });
    context.read<TransactionBloc>().add(TransactionFetch());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showDatePicker,
            tooltip: 'Filter Tanggal',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TransactionBloc>().add(TransactionRefresh());
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedDate != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppColors.primary.withValues(alpha: 0.1),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tanggal: ${_formatDate(_selectedDate!)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _clearFilter,
                    child: const Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                if (state is TransactionLoading) {
                  return const LoadingPage(message: 'Memuat transaksi...');
                }

                if (state is TransactionError) {
                  return ErrorState(
                    message: state.message,
                    onRetry: () {
                      context.read<TransactionBloc>().add(TransactionFetch());
                    },
                  );
                }

                if (state is TransactionLoaded) {
                  if (state.transactions.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<TransactionBloc>().add(TransactionRefresh());
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          state.transactions.length + (state.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index >= state.transactions.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final transaction = state.transactions[index];
                        return TransactionListItem(
                          transaction: transaction,
                          onTap: () {
                            context.push(
                              TransactionDetailPage(
                                  transactionId: transaction.id),
                            );
                          },
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: AppColors.grey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada transaksi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedDate != null
                ? 'Tidak ada transaksi pada tanggal ini'
                : 'Transaksi akan muncul di sini',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
