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
import '../../../data/models/responses/payment_method_model.dart';
import '../../../data/models/responses/xendit_status_response.dart';
import '../bloc/checkout/checkout_bloc.dart';
import '../bloc/checkout/checkout_event.dart';
import '../bloc/checkout/checkout_state.dart';
import '../bloc/sale/sale_bloc.dart';
import '../bloc/sale/sale_event.dart';
import '../bloc/sale/sale_state.dart';
import '../../xendit/pages/xendit_payment_page.dart';
import '../../xendit/widgets/xendit_payment_method_selector.dart';
import 'invoice_page.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
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

    // Pre-fill with exact amount
    final checkoutState = context.read<CheckoutBloc>().state;
    _amountController.text = checkoutState.grandTotal.toStringAsFixed(0);
    _paidAmount = checkoutState.grandTotal;
  }

  Future<void> _loadPaymentMethods() async {
    // Start with default methods - filter out digital payment methods
    // since they will be handled by Xendit if enabled
    _paymentMethods = PaymentMethodModel.getDefaultMethods()
        .where((m) => !_isDigitalPaymentMethod(m.code))
        .toList();
    _selectedMethod = _paymentMethods.first;

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
        // Xendit not available, just use regular payment
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
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
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

    // Validate all items have valid batch
    final invalidItems = checkoutState.items.where((item) => item.batch == null || item.batch!.id == 0);
    if (invalidItems.isNotEmpty) {
      context.showErrorSnackBar('Beberapa produk tidak memiliki batch yang valid');
      return;
    }

    // Create sale request
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
        referenceNumber: _referenceController.text.isEmpty
            ? null
            : _referenceController.text,
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
            builder: (context) => InvoicePage(
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
    final checkoutState = context.watch<CheckoutBloc>().state;
    final change = _paidAmount - checkoutState.grandTotal;

    return BlocListener<SaleBloc, SaleState>(
      listener: (context, state) {
        if (state is SaleCreated) {
          // Clear cart
          context.read<CheckoutBloc>().add(CheckoutClear());

          // Navigate to invoice
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => InvoicePage(
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
        appBar: AppBar(
          title: const Text('Pembayaran'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total to pay
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Total Pembayaran',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            checkoutState.grandTotal.currencyFormatRp,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
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

                    // Traditional Payment methods
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
                      spacing: 8,
                      runSpacing: 8,
                      children: _paymentMethods.map((method) {
                        final isSelected = _selectedMethod?.id == method.id && !_useXendit;
                        return ChoiceChip(
                          label: Text(method.name),
                          selected: isSelected,
                          onSelected: (_) => _onPaymentMethodSelected(method),
                          selectedColor: AppColors.primary.withValues(alpha: 0.2),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // Amount input
                    const Text(
                      'Jumlah Bayar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        prefixStyle: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: AppColors.white,
                      ),
                      onChanged: _onAmountChanged,
                    ),
                    const SizedBox(height: 12),

                    // Quick amount buttons (only for cash, not for Xendit)
                    if (_selectedMethod?.isCash == true && !_useXendit) ...[
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildQuickAmountButton(checkoutState.grandTotal),
                          _buildQuickAmountButton(50000),
                          _buildQuickAmountButton(100000),
                          _buildQuickAmountButton(150000),
                          _buildQuickAmountButton(200000),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Reference number (for non-cash, non-Xendit)
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Xendit info message
                    if (_useXendit && _selectedXenditMethod != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.info.withValues(alpha: 0.3),
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

                    // Change display (only for cash)
                    if (change >= 0 && _selectedMethod?.isCash == true && !_useXendit) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
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
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Process button
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
                child: BlocBuilder<SaleBloc, SaleState>(
                  builder: (context, saleState) {
                    final isLoading = saleState is SaleCreating;
                    // Valid if: using Xendit with method selected, OR traditional method with sufficient amount
                    final isValidXendit = _useXendit && _selectedXenditMethod != null;
                    final isValidTraditional = !_useXendit &&
                        _paidAmount >= checkoutState.grandTotal &&
                        _selectedMethod != null;
                    final isValid = isValidXendit || isValidTraditional;

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isValid && !isLoading ? _processPayment : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor: AppColors.grey.withValues(alpha: 0.3),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : Text(
                                _useXendit
                                    ? 'Bayar dengan $_selectedXenditMethod'
                                    : 'Proses Pembayaran',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountButton(double amount) {
    final isSelected = _paidAmount == amount;
    return InkWell(
      onTap: () => _onQuickAmount(amount),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          amount.currencyFormatRp,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
