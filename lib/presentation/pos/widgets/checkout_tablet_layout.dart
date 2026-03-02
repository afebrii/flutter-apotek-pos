import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../core/extensions/double_ext.dart';
import '../../../data/datasources/payment_method_remote_datasource.dart';
import '../../../data/datasources/xendit_remote_datasource.dart';
import '../../../data/models/requests/sale_request_model.dart';
import '../../../data/models/requests/xendit_sale_request.dart';
import '../../../data/models/responses/customer_model.dart';
import '../../../data/models/responses/payment_method_model.dart';
import '../../../data/models/responses/xendit_status_response.dart';
import '../../customer/pages/customer_list_page.dart';
import '../../xendit/pages/xendit_payment_page.dart';
import '../../xendit/widgets/xendit_payment_method_selector.dart';
import '../bloc/checkout/checkout_bloc.dart';
import '../bloc/checkout/checkout_event.dart';
import '../bloc/checkout/checkout_state.dart';
import '../bloc/checkout/cart_item_model.dart';
import '../bloc/sale/sale_bloc.dart';
import '../bloc/sale/sale_event.dart';
import '../bloc/sale/sale_state.dart';
import 'invoice_tablet_layout.dart';

/// Tablet layout for Checkout with integrated payment
/// Left: Order items list (45%)
/// Right: Payment section (55%)
class CheckoutTabletLayout extends StatefulWidget {
  const CheckoutTabletLayout({super.key});

  @override
  State<CheckoutTabletLayout> createState() => _CheckoutTabletLayoutState();
}

class _CheckoutTabletLayoutState extends State<CheckoutTabletLayout> {
  final _notesController = TextEditingController();
  final _discountController = TextEditingController();
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();

  PaymentMethodModel? _selectedMethod;
  List<PaymentMethodModel> _paymentMethods = [];
  double _paidAmount = 0;

  // Xendit state
  bool _xenditEnabled = false;
  List<XenditPaymentMethod> _xenditMethods = [];
  String? _selectedXenditMethod;
  bool _useXendit = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
    _checkXenditStatus();

    final state = context.read<CheckoutBloc>().state;
    _notesController.text = state.notes ?? '';
    if (state.discount > 0) {
      _discountController.text = state.discount.toStringAsFixed(0);
    }

    // Pre-fill with exact amount
    _amountController.text = state.grandTotal.toStringAsFixed(0);
    _paidAmount = state.grandTotal;
  }

  Future<void> _loadPaymentMethods() async {
    // Start with default methods - filter out digital payment methods
    _paymentMethods = PaymentMethodModel.getDefaultMethods()
        .where((m) => !_isDigitalPaymentMethod(m.code))
        .toList();
    _selectedMethod = _paymentMethods.isNotEmpty ? _paymentMethods.first : null;

    // Try to fetch from API
    final result = await PaymentMethodRemoteDatasource().getPaymentMethods();
    result.fold(
      (error) {
        // Keep using default methods on error
      },
      (methods) {
        if (mounted && methods.isNotEmpty) {
          setState(() {
            // Filter out digital payment methods
            _paymentMethods = methods
                .where((m) => !_isDigitalPaymentMethod(m.code))
                .toList();
            _selectedMethod = _paymentMethods.isNotEmpty
                ? _paymentMethods.first
                : null;
          });
        }
      },
    );
  }

  bool _isDigitalPaymentMethod(String code) {
    const digitalCodes = ['QRIS', 'GOPAY', 'OVO', 'DANA', 'SHOPEEPAY', 'LINKAJA'];
    return digitalCodes.contains(code.toUpperCase());
  }

  Future<void> _checkXenditStatus() async {
    final result = await XenditRemoteDatasource().getStatus();
    result.fold(
      (error) {
        // Xendit not available
        if (mounted) {
          setState(() {
            _xenditEnabled = false;
          });
        }
      },
      (response) {
        if (mounted) {
          setState(() {
            _xenditEnabled = response.data.enabled;
            _xenditMethods = response.data.paymentMethods;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _discountController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  void _updateDiscount(String value) {
    final discount = double.tryParse(value) ?? 0;
    context.read<CheckoutBloc>().add(CheckoutSetDiscount(discount: discount));

    // Update paid amount to match new total
    final checkoutState = context.read<CheckoutBloc>().state;
    final newTotal = checkoutState.subtotal - discount + checkoutState.tax;
    setState(() {
      _paidAmount = newTotal;
      _amountController.text = newTotal.toStringAsFixed(0);
    });
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

  void _onAmountChanged(String value) {
    setState(() {
      _paidAmount = double.tryParse(value) ?? 0;
    });
  }

  void _onQuickAmount(double amount) {
    setState(() {
      _paidAmount = amount;
      _amountController.text = amount.toStringAsFixed(0);
    });
  }

  void _onPaymentMethodSelected(PaymentMethodModel method) {
    setState(() {
      _selectedMethod = method;
      _selectedXenditMethod = null;
      _useXendit = false;
      _referenceController.clear();
    });
  }

  void _onXenditMethodSelected(String methodCode) {
    setState(() {
      _selectedXenditMethod = methodCode;
      _selectedMethod = null;
      _useXendit = true;
      // For Xendit, paid amount is always exact total
      final checkoutState = context.read<CheckoutBloc>().state;
      _paidAmount = checkoutState.grandTotal;
      _amountController.text = checkoutState.grandTotal.toStringAsFixed(0);
    });
  }

  void _processPayment() {
    final checkoutState = context.read<CheckoutBloc>().state;

    // If using Xendit, process via Xendit
    if (_useXendit && _selectedXenditMethod != null) {
      _processXenditPayment(checkoutState);
      return;
    }

    if (_selectedMethod == null) {
      context.showErrorSnackBar('Pilih metode pembayaran');
      return;
    }

    if (_paidAmount < checkoutState.grandTotal) {
      context.showErrorSnackBar('Jumlah bayar kurang dari total');
      return;
    }

    // Reference number is optional for all payment methods

    final invalidItems =
        checkoutState.items.where((item) => item.batch == null || item.batch!.id == 0);
    if (invalidItems.isNotEmpty) {
      context.showErrorSnackBar('Beberapa produk tidak memiliki batch yang valid');
      return;
    }

    final items = checkoutState.items.map((item) {
      return SaleItemRequest(
        productId: item.product.id,
        batchId: item.batch!.id,
        unitId: item.product.baseUnit?.id,
        quantity: item.quantity,
        price: item.price,
        discount: item.discount,
      );
    }).toList();

    final payments = [
      PaymentRequest(
        paymentMethodId: _selectedMethod!.id,
        amount: _paidAmount,
        referenceNumber:
            _referenceController.text.isEmpty ? null : _referenceController.text,
      ),
    ];

    final request = SaleRequestModel(
      customerId: checkoutState.customerId,
      items: items,
      discount: checkoutState.discount,
      tax: checkoutState.tax,
      payments: payments,
      notes: checkoutState.notes,
    );

    context.read<SaleBloc>().add(SaleCreate(request: request));
  }

  void _processXenditPayment(CheckoutState checkoutState) {
    // Validate all items have valid batch
    final invalidItems = checkoutState.items.where((item) => item.batch == null || item.batch!.id == 0);
    if (invalidItems.isNotEmpty) {
      context.showErrorSnackBar('Beberapa produk tidak memiliki batch yang valid');
      return;
    }

    // Convert cart items to Xendit sale items
    final items = checkoutState.items.map<XenditSaleItem>((item) {
      return XenditSaleItem(
        productId: item.product.id,
        batchId: item.batch!.id,
        unitId: item.product.baseUnit?.id,
        quantity: item.quantity,
        price: item.price,
        discount: item.discount,
      );
    }).toList();

    final request = XenditSaleRequest(
      customerId: checkoutState.customerId,
      items: items,
      discount: checkoutState.discount,
      tax: checkoutState.tax,
      notes: checkoutState.notes,
      paymentMethodCode: _selectedXenditMethod!,
    );

    final grandTotal = checkoutState.grandTotal;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => XenditPaymentPage(
          saleRequest: request,
          totalAmount: grandTotal,
        ),
      ),
    ).then((result) {
      if (!mounted) return;

      if (result != null && result['success'] == true) {
        // Payment successful, clear cart and go to invoice
        context.read<CheckoutBloc>().add(CheckoutClear());
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InvoiceTabletLayout(
              saleId: result['sale_id'] ?? 0,
              invoiceNumber: result['invoice_number'] ?? '',
              total: (result['total'] as num?)?.toDouble() ?? grandTotal,
              change: 0, // No change for digital payment
            ),
          ),
        );
      } else if (result != null && result['cancelled'] == true) {
        // User cancelled, stay on payment page
        context.showErrorSnackBar('Pembayaran dibatalkan');
      } else if (result != null && result['expired'] == true) {
        // Payment expired
        context.showErrorSnackBar('Pembayaran kedaluwarsa');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SaleBloc, SaleState>(
      listener: (context, state) {
        if (state is SaleCreated) {
          context.read<CheckoutBloc>().add(CheckoutClear());

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => InvoiceTabletLayout(
                saleId: state.response.saleId ?? 0,
                invoiceNumber: state.response.invoiceNumber ?? '',
                total: double.tryParse(state.response.total ?? '0') ?? 0,
                change: state.response.changeAmount,
              ),
            ),
          );
        } else if (state is SaleCreateError) {
          context.showErrorSnackBar(state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Row(
          children: [
            // Left Panel - Order Items (45%)
            Expanded(
              flex: 45,
              child: _buildOrderPanel(),
            ),

            // Vertical Divider
            const VerticalDivider(width: 1, thickness: 1),

            // Right Panel - Payment (55%)
            Expanded(
              flex: 55,
              child: _buildPaymentPanel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderPanel() {
    return Container(
      color: AppColors.white,
      child: Column(
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
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    tooltip: 'Kembali',
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Detail Pesanan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Order Items
          Expanded(
            child: BlocBuilder<CheckoutBloc, CheckoutState>(
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

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return _buildOrderItem(item);
                  },
                );
              },
            ),
          ),

          // Customer & Notes Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border(
                top: BorderSide(color: AppColors.divider, width: 1),
              ),
            ),
            child: BlocBuilder<CheckoutBloc, CheckoutState>(
              builder: (context, state) {
                return Column(
                  children: [
                    // Customer selection
                    InkWell(
                      onTap: _selectCustomer,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border.all(
                            color: state.customerId != null
                                ? AppColors.primary
                                : AppColors.divider,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: state.customerId != null
                                    ? AppColors.primary.withValues(alpha: 0.1)
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.person_outline,
                                color: state.customerId != null
                                    ? AppColors.primary
                                    : AppColors.grey,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.customerId != null
                                        ? 'Pelanggan'
                                        : 'Pilih Pelanggan',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: state.customerId != null
                                          ? AppColors.textSecondary
                                          : AppColors.grey,
                                    ),
                                  ),
                                  if (state.customerName != null) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      state.customerName!,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            if (state.customerId != null)
                              GestureDetector(
                                onTap: _clearCustomer,
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: AppColors.grey,
                                ),
                              )
                            else
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.grey,
                                size: 20,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Notes & Discount Row
                    Row(
                      children: [
                        // Notes
                        Expanded(
                          child: TextField(
                            controller: _notesController,
                            decoration: InputDecoration(
                              hintText: 'Catatan',
                              prefixIcon: const Icon(Icons.note_outlined, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: AppColors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(fontSize: 13),
                            onChanged: _updateNotes,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Discount
                        SizedBox(
                          width: 150,
                          child: TextField(
                            controller: _discountController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            decoration: InputDecoration(
                              hintText: 'Diskon',
                              prefixIcon:
                                  const Icon(Icons.discount_outlined, size: 20),
                              prefixText: 'Rp ',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              filled: true,
                              fillColor: AppColors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            style: const TextStyle(fontSize: 13),
                            onChanged: _updateDiscount,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(CartItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.price.currencyFormatRp} x ${item.quantity} ${item.unitName}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (item.batch != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 11,
                        color: item.isBatchExpiringSoon
                            ? AppColors.warning
                            : AppColors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Batch: ${item.batch!.batchNumber}',
                        style: TextStyle(
                          fontSize: 10,
                          color: item.isBatchExpiringSoon
                              ? AppColors.warning
                              : AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Quantity Controls
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.divider),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildQuantityButton(
                  icon: Icons.remove,
                  onPressed: item.quantity > 1
                      ? () {
                          context.read<CheckoutBloc>().add(
                                CheckoutUpdateItem(
                                  productId: item.product.id,
                                  batchId: item.batch?.id,
                                  quantity: item.quantity - 1,
                                ),
                              );
                        }
                      : null,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '${item.quantity}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                _buildQuantityButton(
                  icon: Icons.add,
                  onPressed: () {
                    context.read<CheckoutBloc>().add(
                          CheckoutUpdateItem(
                            productId: item.product.id,
                            batchId: item.batch?.id,
                            quantity: item.quantity + 1,
                          ),
                        );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Subtotal & Remove
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.subtotal.currencyFormatRp,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  context.read<CheckoutBloc>().add(
                        CheckoutRemoveItem(
                          productId: item.product.id,
                          batchId: item.batch?.id,
                        ),
                      );
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 14,
          color: onPressed != null ? AppColors.primary : AppColors.grey,
        ),
      ),
    );
  }

  Widget _buildPaymentPanel() {
    final checkoutState = context.watch<CheckoutBloc>().state;
    final change = _paidAmount - checkoutState.grandTotal;

    return Container(
      color: AppColors.background,
      child: Column(
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
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.payment,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Pembayaran',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Payment Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildSummaryRow(
                          'Subtotal (${checkoutState.totalItems} item)',
                          checkoutState.subtotal.currencyFormatRp,
                        ),
                        if (checkoutState.discount > 0) ...[
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            'Diskon',
                            '-${checkoutState.discount.currencyFormatRp}',
                            valueColor: AppColors.error,
                          ),
                        ],
                        if (checkoutState.tax > 0) ...[
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            'Pajak',
                            checkoutState.tax.currencyFormatRp,
                          ),
                        ],
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Pembayaran',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              checkoutState.grandTotal.currencyFormatRp,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Xendit Digital Payment (if enabled)
                  if (_xenditEnabled) ...[
                    XenditPaymentMethodSelector(
                      selectedMethod: _selectedXenditMethod,
                      onSelected: _onXenditMethodSelected,
                      availableMethods: _xenditMethods,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Payment Method
                  const Text(
                    'Metode Pembayaran Lainnya',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _paymentMethods.map((method) {
                      final isSelected = _selectedMethod?.id == method.id && !_useXendit;
                      return GestureDetector(
                        onTap: () => _onPaymentMethodSelected(method),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.divider,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getPaymentIcon(method.name),
                                size: 20,
                                color: isSelected
                                    ? AppColors.white
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                method.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.white
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Amount Input (hide for Xendit)
                  if (!_useXendit) ...[
                  const Text(
                    'Jumlah Bayar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        prefixText: 'Rp ',
                        prefixStyle: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                      onChanged: _onAmountChanged,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Quick Amount Buttons
                  if (_selectedMethod?.isCash == true && !_useXendit) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildQuickAmountButton(checkoutState.grandTotal, 'Uang Pas'),
                        _buildQuickAmountButton(50000, null),
                        _buildQuickAmountButton(100000, null),
                        _buildQuickAmountButton(150000, null),
                        _buildQuickAmountButton(200000, null),
                        _buildQuickAmountButton(500000, null),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Reference Number (for non-cash, non-Xendit)
                  if (_selectedMethod?.isCash == false && !_useXendit) ...[
                    const Text(
                      'Nomor Referensi',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _referenceController,
                      decoration: InputDecoration(
                        hintText: 'Masukkan nomor referensi',
                        prefixIcon: const Icon(Icons.receipt_long_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  ], // End of !_useXendit block

                  // Xendit info message
                  if (_useXendit && _selectedXenditMethod != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.info.withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.info.withAlpha(75),
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.info),
                          SizedBox(height: 8),
                          Text(
                            'Pembayaran digital akan diproses via Xendit.\nAnda akan diarahkan ke halaman pembayaran.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.info,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Change Display (only for cash, not Xendit)
                  if (change >= 0 && _selectedMethod?.isCash == true && !_useXendit)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet,
                              color: AppColors.success,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kembalian',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.success,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  change.currencyFormatRp,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Process Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: BlocBuilder<SaleBloc, SaleState>(
                builder: (context, saleState) {
                  final isLoading = saleState is SaleCreating;
                  // Valid if: using Xendit with method selected, OR traditional method with sufficient amount
                  final isValidXendit = _useXendit && _selectedXenditMethod != null;
                  final isValidTraditional = !_useXendit &&
                      _paidAmount >= checkoutState.grandTotal &&
                      _selectedMethod != null;
                  final isValid = (isValidXendit || isValidTraditional) &&
                      checkoutState.isNotEmpty;

                  return SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isValid && !isLoading ? _processPayment : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor: AppColors.grey.withAlpha(75),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.white,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(_useXendit ? Icons.qr_code_2 : Icons.check_circle_outline, size: 22),
                                const SizedBox(width: 10),
                                Text(
                                  _useXendit
                                      ? 'Bayar dengan $_selectedXenditMethod'
                                      : 'Proses Pembayaran',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  checkoutState.grandTotal.currencyFormatRp,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  );
                },
              ),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAmountButton(double amount, String? label) {
    final isSelected = _paidAmount == amount;
    return GestureDetector(
      onTap: () => _onQuickAmount(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Text(
          label ?? amount.currencyFormatRp,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  IconData _getPaymentIcon(String name) {
    switch (name.toLowerCase()) {
      case 'tunai':
      case 'cash':
        return Icons.payments_outlined;
      case 'debit':
      case 'kartu debit':
        return Icons.credit_card;
      case 'kredit':
      case 'kartu kredit':
        return Icons.credit_score;
      case 'qris':
        return Icons.qr_code_2;
      case 'transfer':
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }
}
