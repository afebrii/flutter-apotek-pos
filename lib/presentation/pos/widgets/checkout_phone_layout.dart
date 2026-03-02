import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/extensions/double_ext.dart';
import '../../../data/models/responses/customer_model.dart';
import '../../customer/pages/customer_list_page.dart';
import '../bloc/checkout/checkout_bloc.dart';
import '../bloc/checkout/checkout_event.dart';
import '../bloc/checkout/checkout_state.dart';
import '../widgets/checkout_item_widget.dart';
import '../pages/payment_page.dart';

/// Phone layout for Checkout page
class CheckoutPhoneLayout extends StatefulWidget {
  const CheckoutPhoneLayout({super.key});

  @override
  State<CheckoutPhoneLayout> createState() => _CheckoutPhoneLayoutState();
}

class _CheckoutPhoneLayoutState extends State<CheckoutPhoneLayout> {
  final _notesController = TextEditingController();
  final _discountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = context.read<CheckoutBloc>().state;
    _notesController.text = state.notes ?? '';
    if (state.discount > 0) {
      _discountController.text = state.discount.toStringAsFixed(0);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _updateDiscount(String value) {
    final discount = double.tryParse(value) ?? 0;
    context.read<CheckoutBloc>().add(CheckoutSetDiscount(discount: discount));
  }

  void _updateNotes(String value) {
    context.read<CheckoutBloc>().add(CheckoutSetNotes(notes: value));
  }

  Future<void> _selectCustomer() async {
    final customer = await Navigator.push<CustomerModel>(
      context,
      MaterialPageRoute(
        builder: (context) => const CustomerListPage(selectionMode: true),
      ),
    );

    if (customer != null && mounted) {
      context.read<CheckoutBloc>().add(
            CheckoutSetCustomer(
              customerId: customer.id,
              customerName: customer.name,
            ),
          );
    }
  }

  void _clearCustomer() {
    context.read<CheckoutBloc>().add(
          CheckoutSetCustomer(customerId: null, customerName: null),
        );
  }

  void _proceedToPayment() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaymentPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<CheckoutBloc, CheckoutState>(
        builder: (context, state) {
          if (state.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 64,
                    color: AppColors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Keranjang kosong',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Cart items list
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return CheckoutItemWidget(
                      item: item,
                      onQuantityChanged: (quantity) {
                        context.read<CheckoutBloc>().add(
                              CheckoutUpdateItem(
                                productId: item.product.id,
                                batchId: item.batch?.id,
                                quantity: quantity,
                              ),
                            );
                      },
                      onRemove: () {
                        context.read<CheckoutBloc>().add(
                              CheckoutRemoveItem(
                                productId: item.product.id,
                                batchId: item.batch?.id,
                              ),
                            );
                      },
                    );
                  },
                ),
              ),

              // Customer & Notes section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border(
                    top: BorderSide(
                      color: AppColors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer selection
                    InkWell(
                      onTap: _selectCustomer,
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.grey.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: state.customerId != null
                                  ? AppColors.primary
                                  : AppColors.grey,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                state.customerName ?? 'Pilih Pelanggan (opsional)',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: state.customerId != null
                                      ? AppColors.textPrimary
                                      : AppColors.grey,
                                ),
                              ),
                            ),
                            if (state.customerId != null)
                              GestureDetector(
                                onTap: _clearCustomer,
                                child: const Icon(
                                  Icons.close,
                                  size: 20,
                                  color: AppColors.grey,
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
                    const SizedBox(height: 12),

                    // Notes field
                    TextField(
                      controller: _notesController,
                      decoration: InputDecoration(
                        hintText: 'Catatan (opsional)',
                        prefixIcon: const Icon(Icons.note_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      onChanged: _updateNotes,
                    ),
                    const SizedBox(height: 12),

                    // Discount field
                    TextField(
                      controller: _discountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Diskon (Rp)',
                        prefixIcon: const Icon(Icons.discount_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      onChanged: _updateDiscount,
                    ),
                  ],
                ),
              ),

              // Summary section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    children: [
                      // Subtotal
                      _buildSummaryRow(
                        'Subtotal (${state.totalItems} item)',
                        state.subtotal.currencyFormatRp,
                      ),
                      if (state.discount > 0) ...[
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Diskon',
                          '-${state.discount.currencyFormatRp}',
                          valueColor: AppColors.error,
                        ),
                      ],
                      if (state.tax > 0) ...[
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Pajak',
                          state.tax.currencyFormatRp,
                        ),
                      ],
                      const Divider(height: 24),
                      // Grand total
                      _buildSummaryRow(
                        'Total',
                        state.grandTotal.currencyFormatRp,
                        isBold: true,
                        valueColor: AppColors.primary,
                      ),
                      const SizedBox(height: 16),
                      // Proceed button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _proceedToPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Lanjut ke Pembayaran',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
