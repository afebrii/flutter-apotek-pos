import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/colors.dart';
import '../../../core/components/loading_indicator.dart';
import '../../../core/extensions/double_ext.dart';
import '../../../core/services/printer_service.dart';
import '../../../data/datasources/transaction_remote_datasource.dart';
import '../../../data/models/responses/transaction_model.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';

class TransactionDetailPage extends StatelessWidget {
  final int transactionId;

  const TransactionDetailPage({
    super.key,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionBloc(
        datasource: TransactionRemoteDatasource(),
      )..add(TransactionFetchDetail(id: transactionId)),
      child: const _TransactionDetailView(),
    );
  }
}

class _TransactionDetailView extends StatefulWidget {
  const _TransactionDetailView();

  @override
  State<_TransactionDetailView> createState() => _TransactionDetailViewState();
}

class _TransactionDetailViewState extends State<_TransactionDetailView> {
  bool _isPrinting = false;

  Future<void> _printReceipt(TransactionDetailModel transaction) async {
    setState(() => _isPrinting = true);

    final printerService = PrinterService();
    final prefs = await SharedPreferences.getInstance();

    // Get store info from receipt settings
    final storeName = prefs.getString('receipt_header') ?? 'APOTEK';
    final storeAddress = prefs.getString('store_address');
    final storePhone = prefs.getString('store_phone');

    // Convert transaction items to print items
    final printItems = transaction.items.map((item) {
      return PrintReceiptItem(
        name: item.product.name,
        qty: item.quantity,
        price: item.price,
        subtotal: item.subtotal,
      );
    }).toList();

    // Parse transaction date
    DateTime transactionDate;
    try {
      transactionDate = DateTime.parse(transaction.date);
    } catch (e) {
      transactionDate = DateTime.now();
    }

    final success = await printerService.printReceipt(
      storeName: storeName,
      storeAddress: storeAddress,
      storePhone: storePhone,
      cashierName: transaction.cashier.name,
      transactionNo: transaction.invoiceNumber,
      transactionDate: transactionDate,
      items: printItems,
      subtotal: transaction.subtotal,
      discount: transaction.discount,
      total: transaction.total,
      paid: transaction.paidAmount,
      change: transaction.changeAmount,
      paymentMethod: transaction.payments.isNotEmpty
          ? transaction.payments.first.paymentMethod?.name ?? 'Tunai'
          : 'Tunai',
      customerName: transaction.customer?.name,
    );

    if (mounted) {
      setState(() => _isPrinting = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Struk berhasil dicetak'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mencetak struk. Pastikan printer terhubung.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Transaksi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          BlocBuilder<TransactionBloc, TransactionState>(
            builder: (context, state) {
              if (state is TransactionDetailLoaded) {
                return IconButton(
                  icon: _isPrinting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Icon(Icons.print),
                  tooltip: 'Cetak Struk',
                  onPressed: _isPrinting
                      ? null
                      : () => _printReceipt(state.transaction),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionDetailLoading) {
            return const LoadingPage(message: 'Memuat detail...');
          }

          if (state is TransactionDetailError) {
            return ErrorState(
              message: state.message,
              onRetry: () {
                // Can't retry without knowing the ID
                Navigator.pop(context);
              },
            );
          }

          if (state is TransactionDetailLoaded) {
            return _buildContent(context, state.transaction);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, TransactionDetailModel transaction) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Invoice info card
          _buildInvoiceCard(transaction),
          const SizedBox(height: 16),

          // Items section
          _buildSectionHeader('Item Pembelian'),
          const SizedBox(height: 8),
          _buildItemsList(transaction.items),
          const SizedBox(height: 16),

          // Payment summary
          _buildSectionHeader('Ringkasan Pembayaran'),
          const SizedBox(height: 8),
          _buildPaymentSummary(transaction),
          const SizedBox(height: 16),

          // Payment methods
          if (transaction.payments.isNotEmpty) ...[
            _buildSectionHeader('Metode Pembayaran'),
            const SizedBox(height: 8),
            _buildPaymentMethods(transaction.payments),
            const SizedBox(height: 16),
          ],

          // Notes
          if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
            _buildSectionHeader('Catatan'),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  transaction.notes!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(TransactionDetailModel transaction) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Invoice number and status
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'No. Invoice',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        transaction.invoiceNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(transaction.status),
              ],
            ),
            const Divider(height: 24),

            // Date
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Tanggal',
              value: _formatDate(transaction.date),
            ),
            const SizedBox(height: 8),

            // Cashier
            _buildInfoRow(
              icon: Icons.person,
              label: 'Kasir',
              value: transaction.cashier.name,
            ),

            // Customer
            if (transaction.customer != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.person_outline,
                label: 'Pelanggan',
                value: transaction.customer!.name,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.grey),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status.toLowerCase()) {
      case 'completed':
        color = AppColors.success;
        label = 'Selesai';
        break;
      case 'pending':
        color = AppColors.warning;
        label = 'Pending';
        break;
      case 'cancelled':
        color = AppColors.error;
        label = 'Dibatalkan';
        break;
      default:
        color = AppColors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildItemsList(List<TransactionItem> items) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quantity badge
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${item.price.currencyFormatRp} x ${item.quantity}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (item.batchNumber != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Batch: ${item.batchNumber}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Subtotal
                Text(
                  item.subtotal.currencyFormatRp,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentSummary(TransactionDetailModel transaction) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSummaryRow('Subtotal', transaction.subtotal),
            if (transaction.discount > 0) ...[
              const SizedBox(height: 8),
              _buildSummaryRow('Diskon', -transaction.discount, isDiscount: true),
            ],
            if (transaction.tax > 0) ...[
              const SizedBox(height: 8),
              _buildSummaryRow('Pajak', transaction.tax),
            ],
            const Divider(height: 16),
            _buildSummaryRow('Total', transaction.total, isTotal: true),
            const SizedBox(height: 8),
            _buildSummaryRow('Dibayar', transaction.paidAmount),
            const SizedBox(height: 8),
            _buildSummaryRow('Kembalian', transaction.changeAmount, isChange: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isTotal = false,
    bool isDiscount = false,
    bool isChange = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          isDiscount ? '- ${amount.abs().currencyFormatRp}' : amount.currencyFormatRp,
          style: TextStyle(
            fontSize: isTotal ? 18 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: isTotal
                ? AppColors.primary
                : isDiscount
                    ? AppColors.error
                    : isChange
                        ? AppColors.success
                        : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods(List<TransactionPayment> payments) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: payments.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final payment = payments[index];
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.payment,
                    size: 18,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.paymentMethod?.name ?? 'Cash',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (payment.reference != null &&
                          payment.reference!.isNotEmpty)
                        Text(
                          'Ref: ${payment.reference}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  payment.amount.currencyFormatRp,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
