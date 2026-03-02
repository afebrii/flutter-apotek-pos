import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/constants/colors.dart';
import '../../../core/extensions/build_context_ext.dart';
import '../../../core/extensions/double_ext.dart';
import '../../../data/datasources/xendit_remote_datasource.dart';
import '../../../data/models/requests/xendit_sale_request.dart';
import '../../../data/models/responses/xendit_sale_response.dart';
import '../bloc/xendit_bloc.dart';
import '../bloc/xendit_event.dart';
import '../bloc/xendit_state.dart';

class XenditPaymentPage extends StatefulWidget {
  final XenditSaleRequest saleRequest;
  final double totalAmount;

  const XenditPaymentPage({
    super.key,
    required this.saleRequest,
    required this.totalAmount,
  });

  @override
  State<XenditPaymentPage> createState() => _XenditPaymentPageState();
}

class _XenditPaymentPageState extends State<XenditPaymentPage> {
  late XenditBloc _xenditBloc;
  late WebViewController _webViewController;

  int? _transactionId;
  XenditSaleData? _saleData;
  bool _isWebViewReady = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initWebViewController();
    _xenditBloc = XenditBloc(XenditRemoteDatasource());
    _xenditBloc.add(XenditCreateSale(widget.saleRequest));
  }

  void _initWebViewController() {
    const params = PlatformWebViewControllerCreationParams();
    _webViewController = WebViewController.fromPlatformCreationParams(params);
    _webViewController
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView loading: $progress%');
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() => _isLoading = true);
            }
            debugPrint('Page started: $url');
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
            debugPrint('Page finished: $url');
          },
          onNavigationRequest: (NavigationRequest request) {
            debugPrint('Navigation request: ${request.url}');

            // Handle Xendit callback URLs
            if (request.url.contains('success') || request.url.contains('completed')) {
              _handlePaymentSuccess();
              return NavigationDecision.prevent;
            } else if (request.url.contains('failure') || request.url.contains('failed')) {
              _handlePaymentFailure();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onUrlChange: (change) {
            debugPrint('URL changed: ${change.url}');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.errorCode} - ${error.description}');
          },
        ),
      );
  }

  @override
  void dispose() {
    _xenditBloc.add(XenditStopPolling());
    _xenditBloc.close();
    super.dispose();
  }

  void _loadPaymentUrl(String url) {
    _webViewController.loadRequest(Uri.parse(url));
    setState(() => _isWebViewReady = true);
  }

  void _handlePaymentSuccess() {
    // Check actual payment status from server
    if (_transactionId != null) {
      _xenditBloc.add(XenditCheckPaymentStatus(_transactionId!));
    }
  }

  void _handlePaymentFailure() {
    context.showErrorSnackBar('Pembayaran gagal atau dibatalkan');
    Navigator.of(context).pop({'failed': true});
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Batalkan Pembayaran?'),
        content: const Text('Apakah Anda yakin ingin membatalkan pembayaran ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (_transactionId != null) {
                _xenditBloc.add(XenditCancelPayment(_transactionId!));
              } else {
                Navigator.of(context).pop({'cancelled': true});
              }
            },
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(int? saleId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Pembayaran Berhasil'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Pembayaran telah diterima.'),
            const SizedBox(height: 16),
            Text(
              widget.totalAmount.currencyFormatRp,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.of(context).pop({
                'success': true,
                'sale_id': saleId,
                'invoice_number': _saleData?.invoiceNumber,
                'total': _saleData?.total ?? widget.totalAmount,
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.timer_off, color: Colors.orange, size: 32),
            SizedBox(width: 12),
            Text('Kedaluwarsa'),
          ],
        ),
        content: const Text('Waktu pembayaran telah habis.\nSilakan buat transaksi baru.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.of(context).pop({'expired': true});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _xenditBloc,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            _showCancelDialog();
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              'Pembayaran ${widget.saleRequest.paymentMethodCode}',
              style: const TextStyle(fontSize: 16),
            ),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: _showCancelDialog,
            ),
            actions: [
              if (_isWebViewReady)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => _webViewController.reload(),
                  tooltip: 'Refresh',
                ),
              if (_transactionId != null)
                IconButton(
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed: () {
                    _xenditBloc.add(XenditCheckPaymentStatus(_transactionId!));
                  },
                  tooltip: 'Cek Status',
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(50),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.primary.withAlpha(25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran:',
                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                    ),
                    Text(
                      widget.totalAmount.currencyFormatRp,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: BlocConsumer<XenditBloc, XenditState>(
            listener: (context, state) {
              if (state is XenditSaleCreated) {
                _saleData = state.sale;
                _transactionId = state.sale.xendit.transactionId;
                final invoiceUrl = state.sale.xendit.invoiceUrl;
                _loadPaymentUrl(invoiceUrl);
                // Start polling for payment status
                _xenditBloc.add(XenditStartPolling(_transactionId!));
              } else if (state is XenditPaymentSuccess) {
                _showSuccessDialog(state.data.saleId);
              } else if (state is XenditPaymentExpired) {
                _showExpiredDialog();
              } else if (state is XenditPaymentCancelled) {
                Navigator.of(context).pop({'cancelled': true});
              } else if (state is XenditSaleError) {
                context.showErrorSnackBar(state.message);
              }
            },
            builder: (context, state) {
              // Show loading while creating transaction
              if (state is XenditLoading) {
                return _buildLoading('Membuat transaksi...');
              }

              // Show error
              if (state is XenditSaleError) {
                return _buildError(state.message);
              }

              // Show WebView when ready
              if (_isWebViewReady) {
                return Stack(
                  children: [
                    WebViewWidget(controller: _webViewController),
                    if (_isLoading)
                      Container(
                        color: Colors.white,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                  ],
                );
              }

              // Default loading
              return _buildLoading('Memuat halaman pembayaran...');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoading(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 80, color: Colors.red),
            const SizedBox(height: 24),
            const Text(
              'Terjadi Kesalahan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop({'error': true}),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text('Kembali'),
            ),
          ],
        ),
      ),
    );
  }
}
