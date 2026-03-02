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

/// Tablet layout for Invoice/Transaction Success
/// Two-column grid layout: Left (success + actions) | Right (receipt)
class InvoiceTabletLayout extends StatefulWidget {
  final int saleId;
  final String invoiceNumber;
  final double total;
  final double change;

  const InvoiceTabletLayout({
    super.key,
    required this.saleId,
    required this.invoiceNumber,
    required this.total,
    required this.change,
  });

  @override
  State<InvoiceTabletLayout> createState() => _InvoiceTabletLayoutState();
}

class _InvoiceTabletLayoutState extends State<InvoiceTabletLayout>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isPrinting = false;

  @override
  void initState() {
    super.initState();
    context.read<SaleBloc>().add(SaleFetchById(id: widget.saleId));

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _goToHome() {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> _printReceipt(SaleModel? sale) async {
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
      body: SafeArea(
        child: BlocBuilder<SaleBloc, SaleState>(
          builder: (context, state) {
            SaleModel? sale;
            if (state is SaleDetailLoaded) {
              sale = state.sale;
            }

            return Row(
              children: [
                // Left Panel - Success Info & Actions (45%)
                Expanded(
                  flex: 45,
                  child: Container(
                    color: AppColors.primary,
                    child: AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: _buildSuccessPanel(sale),
                    ),
                  ),
                ),

                // Right Panel - Receipt (55%)
                Expanded(
                  flex: 55,
                  child: Container(
                    color: AppColors.white,
                    child: _buildReceiptPanel(state, sale),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSuccessPanel(SaleModel? sale) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
          // Success Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_circle,
              size: 80,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 32),

          // Success Message
          const Text(
            'Transaksi Berhasil!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'No. Invoice',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.invoiceNumber,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 32),

          // Total & Change Cards
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      widget.total.currencyFormatRp,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
                if (widget.change > 0) ...[
                  const SizedBox(height: 12),
                  Container(
                    height: 1,
                    color: AppColors.white.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Kembalian',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      Text(
                        widget.change.currencyFormatRp,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Action Buttons
          Row(
            children: [
              // Print Button
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed:
                        _isPrinting ? null : () => _printReceipt(sale),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      side: const BorderSide(
                        color: AppColors.white,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: _isPrinting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Icon(Icons.print, size: 22),
                    label: Text(
                      _isPrinting ? 'Mencetak...' : 'Cetak Struk',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // New Transaction Button
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _goToHome,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.add_shopping_cart, size: 22),
                    label: const Text(
                      'Transaksi Baru',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Close button
          TextButton.icon(
            onPressed: _goToHome,
            icon: Icon(
              Icons.close,
              size: 18,
              color: AppColors.white.withValues(alpha: 0.7),
            ),
            label: Text(
              'Tutup',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.white.withValues(alpha: 0.7),
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildReceiptPanel(SaleState state, SaleModel? sale) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.divider, width: 1),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Detail Struk',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // Receipt Content
        Expanded(
          child: state is SaleLoading
              ? const Center(child: CircularProgressIndicator())
              : sale == null
                  ? const Center(child: Text('Memuat data...'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            // Store Header
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.local_pharmacy,
                                      color: AppColors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'APOTEK',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                      Text(
                                        'Struk Pembayaran',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Invoice Info
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  _buildInfoRow('No. Invoice', widget.invoiceNumber),
                                  _buildInfoRow('Tanggal', sale.date),
                                  if (sale.cashier != null)
                                    _buildInfoRow('Kasir', sale.cashier!.name),
                                  if (sale.customer != null)
                                    _buildInfoRow('Pelanggan', sale.customer!.name),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Items
                            if (sale.items.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                  ],
                                ),
                              ),
                            const SizedBox(height: 20),

                            // Summary
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  _buildSummaryRow(
                                    'Subtotal',
                                    (double.tryParse(sale.subtotal) ?? 0)
                                        .currencyFormatRp,
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
                                      (double.tryParse(sale.tax) ?? 0)
                                          .currencyFormatRp,
                                    ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Divider(),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        widget.total.currencyFormatRp,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (sale.payments.isNotEmpty)
                                    _buildSummaryRow(
                                      'Pembayaran (${sale.payments.first.paymentMethod?.name ?? ""})',
                                      (double.tryParse(sale.paidAmount ?? '0') ??
                                              0)
                                          .currencyFormatRp,
                                    ),
                                  if (widget.change > 0)
                                    _buildSummaryRow(
                                      'Kembalian',
                                      widget.change.currencyFormatRp,
                                      valueColor: AppColors.success,
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Footer Message
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Column(
                                children: [
                                  Text(
                                    'Terima kasih atas kunjungan Anda',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Semoga lekas sembuh',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      color: AppColors.textHint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
        ),
      ],
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
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
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
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
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
                const SizedBox(height: 2),
                Text(
                  '${item.quantity} x ${(double.tryParse(item.price) ?? 0).currencyFormatRp}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            (double.tryParse(item.subtotal) ?? 0).currencyFormatRp,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
