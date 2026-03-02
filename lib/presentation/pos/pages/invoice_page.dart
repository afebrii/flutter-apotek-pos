import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/colors.dart';
import '../../../core/extensions/double_ext.dart';
import '../../../core/services/printer_service.dart';
import '../../../data/models/responses/sale_model.dart';
import '../bloc/sale/sale_bloc.dart';
import '../bloc/sale/sale_event.dart';
import '../bloc/sale/sale_state.dart';

class InvoicePage extends StatefulWidget {
  final int saleId;
  final String invoiceNumber;
  final double total;
  final double change;

  const InvoicePage({
    super.key,
    required this.saleId,
    required this.invoiceNumber,
    required this.total,
    required this.change,
  });

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  bool _isPrinting = false;
  SaleModel? _currentSale;

  @override
  void initState() {
    super.initState();
    // Fetch sale details
    context.read<SaleBloc>().add(SaleFetchById(id: widget.saleId));
  }

  void _goToHome() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> _printReceipt() async {
    final sale = _currentSale;
    if (sale == null) return;

    setState(() => _isPrinting = true);

    final printerService = PrinterService();
    final prefs = await SharedPreferences.getInstance();

    // Get store info from receipt settings
    final storeName = prefs.getString('receipt_header') ?? 'APOTEK';
    final storeAddress = prefs.getString('store_address');
    final storePhone = prefs.getString('store_phone');

    // Convert sale items to print items
    final printItems = sale.items.map((item) {
      return PrintReceiptItem(
        name: item.product?.name ?? 'Produk',
        qty: item.quantity,
        price: double.tryParse(item.price) ?? 0,
        subtotal: double.tryParse(item.subtotal) ?? 0,
      );
    }).toList();

    final success = await printerService.printReceipt(
      storeName: storeName,
      storeAddress: storeAddress,
      storePhone: storePhone,
      cashierName: sale.cashier?.name,
      transactionNo: sale.invoiceNumber,
      transactionDate: DateTime.now(),
      items: printItems,
      subtotal: double.tryParse(sale.subtotal) ?? 0,
      discount: double.tryParse(sale.discount) ?? 0,
      total: widget.total,
      paid: double.tryParse(sale.paidAmount ?? '0') ?? widget.total,
      change: widget.change,
      paymentMethod: sale.payments.isNotEmpty
          ? sale.payments.first.paymentMethod?.name ?? 'Tunai'
          : 'Tunai',
      customerName: sale.customer?.name,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Transaksi Berhasil'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _goToHome,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: BlocBuilder<SaleBloc, SaleState>(
        builder: (context, state) {
          if (state is SaleLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          SaleModel? sale;
          if (state is SaleDetailLoaded) {
            sale = state.sale;
            _currentSale = sale;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Success icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 48,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Transaksi Berhasil!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No. Invoice: ${widget.invoiceNumber}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Receipt card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Center(
                        child: Column(
                          children: [
                            Text(
                              'APOTEK',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Struk Pembayaran',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Invoice info
                      _buildInfoRow('No. Invoice', widget.invoiceNumber),
                      if (sale != null) ...[
                        _buildInfoRow('Tanggal', sale.date),
                        if (sale.cashier != null)
                          _buildInfoRow('Kasir', sale.cashier!.name),
                        if (sale.customer != null)
                          _buildInfoRow('Pelanggan', sale.customer!.name),
                      ],
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Items
                      if (sale != null && sale.items.isNotEmpty) ...[
                        const Text(
                          'Detail Pembelian',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...sale.items.map((item) => _buildItemRow(item)),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                      ],

                      // Summary
                      if (sale != null) ...[
                        _buildSummaryRow(
                          'Subtotal',
                          (double.tryParse(sale.subtotal) ?? 0).currencyFormatRp,
                        ),
                        if (double.tryParse(sale.discount) != 0)
                          _buildSummaryRow(
                            'Diskon',
                            '-${(double.tryParse(sale.discount) ?? 0).currencyFormatRp}',
                            valueColor: AppColors.error,
                          ),
                        if (double.tryParse(sale.tax) != 0)
                          _buildSummaryRow(
                            'Pajak',
                            (double.tryParse(sale.tax) ?? 0).currencyFormatRp,
                          ),
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                      ],

                      // Total
                      _buildSummaryRow(
                        'Total',
                        widget.total.currencyFormatRp,
                        isBold: true,
                        valueColor: AppColors.primary,
                      ),

                      // Payment info
                      if (sale != null && sale.payments.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Pembayaran (${sale.payments.first.paymentMethod?.name ?? ""})',
                          (double.tryParse(sale.paidAmount ?? '0') ?? 0)
                              .currencyFormatRp,
                        ),
                      ],

                      if (widget.change > 0) ...[
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Kembalian',
                          widget.change.currencyFormatRp,
                          valueColor: AppColors.success,
                        ),
                      ],

                      const SizedBox(height: 24),
                      const Center(
                        child: Column(
                          children: [
                            Text(
                              'Terima kasih atas kunjungan Anda',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Semoga lekas sembuh',
                              style: TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isPrinting ? null : _printReceipt,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isPrinting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            : const Icon(Icons.print, size: 20),
                        label: Text(_isPrinting ? 'Mencetak...' : 'Cetak'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _goToHome,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Transaksi Baru',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(SaleItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.product?.name ?? 'Produk',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.quantity} x ${(double.tryParse(item.price) ?? 0).currencyFormatRp}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                (double.tryParse(item.subtotal) ?? 0).currencyFormatRp,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16 : 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
