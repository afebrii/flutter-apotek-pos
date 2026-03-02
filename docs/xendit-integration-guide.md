# Xendit Payment Integration Guide - Flutter Apotek POS

## Overview

Dokumentasi ini berisi panduan lengkap untuk mengintegrasikan Xendit Payment Gateway ke Flutter Apotek POS App. Backend API sudah siap di `https://apotek.jagofullstack.com`.

---

## API Endpoints

Base URL: `https://apotek.jagofullstack.com/api/v1`

### 1. Check Xendit Status
```
GET /xendit/status
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "enabled": true,
    "payment_methods": [
      {"code": "QRIS", "name": "QRIS", "icon": "qris"},
      {"code": "GOPAY", "name": "GoPay", "icon": "gopay"},
      {"code": "OVO", "name": "OVO", "icon": "ovo"},
      {"code": "DANA", "name": "DANA", "icon": "dana"},
      {"code": "SHOPEEPAY", "name": "ShopeePay", "icon": "shopeepay"},
      {"code": "LINKAJA", "name": "LinkAja", "icon": "linkaja"}
    ]
  }
}
```

### 2. Create Sale with Xendit Payment (Recommended)
```
POST /xendit/sale
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "customer_id": 1,
  "items": [
    {
      "product_id": 1,
      "batch_id": 1,
      "unit_id": null,
      "quantity": 2,
      "price": 15000,
      "discount": 0
    }
  ],
  "discount": 0,
  "tax": 0,
  "notes": "Catatan optional",
  "payment_method_code": "QRIS"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Invoice Xendit berhasil dibuat",
  "data": {
    "sale_id": 123,
    "invoice_number": "INV-20260109-0001",
    "total": 30000,
    "xendit": {
      "transaction_id": 1,
      "external_id": "INV-20260109060520-0650D2",
      "invoice_url": "https://checkout.xendit.co/web/xxxxxx",
      "status": "PENDING",
      "expires_at": "2026-01-09T07:05:20+07:00"
    }
  }
}
```

### 3. Create Invoice for Existing Sale
```
POST /xendit/invoice
Authorization: Bearer {token}
Content-Type: application/json
```

**Request Body:**
```json
{
  "sale_id": 123,
  "payment_method_code": "QRIS"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Invoice berhasil dibuat",
  "data": {
    "transaction_id": 1,
    "external_id": "INV-20260109060520-0650D2",
    "invoice_url": "https://checkout.xendit.co/web/xxxxxx",
    "amount": 30000,
    "status": "PENDING",
    "expires_at": "2026-01-09T07:05:20+07:00"
  }
}
```

### 4. Check Payment Status
```
GET /xendit/check/{transaction_id}
Authorization: Bearer {token}
```

**Response (Pending):**
```json
{
  "success": true,
  "data": {
    "status": "PENDING",
    "is_paid": false,
    "is_expired": false,
    "expires_at": "2026-01-09T07:05:20+07:00",
    "sale_id": 123
  }
}
```

**Response (Paid):**
```json
{
  "success": true,
  "data": {
    "status": "PAID",
    "is_paid": true,
    "is_expired": false,
    "paid_at": "2026-01-09T06:10:30+07:00",
    "payment_method": "QRIS",
    "payment_channel": "QRIS",
    "sale_id": 123
  }
}
```

### 5. Cancel Payment
```
POST /xendit/cancel/{transaction_id}
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "message": "Pembayaran berhasil dibatalkan"
}
```

### 6. List Transactions
```
GET /xendit/transactions?status=PAID&date=2026-01-09&per_page=15
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "external_id": "INV-20260109060520-0650D2",
      "sale": {
        "id": 123,
        "invoice_number": "INV-20260109-0001",
        "total": 30000
      },
      "amount": 30000,
      "payment_method": "QRIS",
      "payment_channel": "QRIS",
      "status": "PAID",
      "paid_at": "2026-01-09T06:10:30+07:00",
      "created_at": "2026-01-09T06:05:20+07:00"
    }
  ],
  "meta": {
    "current_page": 1,
    "last_page": 1,
    "per_page": 15,
    "total": 1
  }
}
```

---

## Implementation Steps

### Step 1: Create Models

**File: `lib/data/models/response/xendit_status_response.dart`**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'xendit_status_response.freezed.dart';
part 'xendit_status_response.g.dart';

@freezed
class XenditStatusResponse with _$XenditStatusResponse {
  const factory XenditStatusResponse({
    required bool success,
    required XenditStatusData data,
  }) = _XenditStatusResponse;

  factory XenditStatusResponse.fromJson(Map<String, dynamic> json) =>
      _$XenditStatusResponseFromJson(json);
}

@freezed
class XenditStatusData with _$XenditStatusData {
  const factory XenditStatusData({
    required bool enabled,
    @JsonKey(name: 'payment_methods') required List<XenditPaymentMethod> paymentMethods,
  }) = _XenditStatusData;

  factory XenditStatusData.fromJson(Map<String, dynamic> json) =>
      _$XenditStatusDataFromJson(json);
}

@freezed
class XenditPaymentMethod with _$XenditPaymentMethod {
  const factory XenditPaymentMethod({
    required String code,
    required String name,
    required String icon,
  }) = _XenditPaymentMethod;

  factory XenditPaymentMethod.fromJson(Map<String, dynamic> json) =>
      _$XenditPaymentMethodFromJson(json);
}
```

**File: `lib/data/models/response/xendit_invoice_response.dart`**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'xendit_invoice_response.freezed.dart';
part 'xendit_invoice_response.g.dart';

@freezed
class XenditInvoiceResponse with _$XenditInvoiceResponse {
  const factory XenditInvoiceResponse({
    required bool success,
    required String message,
    required XenditInvoiceData data,
  }) = _XenditInvoiceResponse;

  factory XenditInvoiceResponse.fromJson(Map<String, dynamic> json) =>
      _$XenditInvoiceResponseFromJson(json);
}

@freezed
class XenditInvoiceData with _$XenditInvoiceData {
  const factory XenditInvoiceData({
    @JsonKey(name: 'transaction_id') required int transactionId,
    @JsonKey(name: 'external_id') required String externalId,
    @JsonKey(name: 'invoice_url') required String invoiceUrl,
    required double amount,
    required String status,
    @JsonKey(name: 'expires_at') required String expiresAt,
  }) = _XenditInvoiceData;

  factory XenditInvoiceData.fromJson(Map<String, dynamic> json) =>
      _$XenditInvoiceDataFromJson(json);
}
```

**File: `lib/data/models/response/xendit_sale_response.dart`**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'xendit_sale_response.freezed.dart';
part 'xendit_sale_response.g.dart';

@freezed
class XenditSaleResponse with _$XenditSaleResponse {
  const factory XenditSaleResponse({
    required bool success,
    required String message,
    required XenditSaleData data,
  }) = _XenditSaleResponse;

  factory XenditSaleResponse.fromJson(Map<String, dynamic> json) =>
      _$XenditSaleResponseFromJson(json);
}

@freezed
class XenditSaleData with _$XenditSaleData {
  const factory XenditSaleData({
    @JsonKey(name: 'sale_id') required int saleId,
    @JsonKey(name: 'invoice_number') required String invoiceNumber,
    required double total,
    required XenditInfo xendit,
  }) = _XenditSaleData;

  factory XenditSaleData.fromJson(Map<String, dynamic> json) =>
      _$XenditSaleDataFromJson(json);
}

@freezed
class XenditInfo with _$XenditInfo {
  const factory XenditInfo({
    @JsonKey(name: 'transaction_id') required int transactionId,
    @JsonKey(name: 'external_id') required String externalId,
    @JsonKey(name: 'invoice_url') required String invoiceUrl,
    required String status,
    @JsonKey(name: 'expires_at') required String expiresAt,
  }) = _XenditInfo;

  factory XenditInfo.fromJson(Map<String, dynamic> json) =>
      _$XenditInfoFromJson(json);
}
```

**File: `lib/data/models/response/xendit_check_response.dart`**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'xendit_check_response.freezed.dart';
part 'xendit_check_response.g.dart';

@freezed
class XenditCheckResponse with _$XenditCheckResponse {
  const factory XenditCheckResponse({
    required bool success,
    required XenditCheckData data,
  }) = _XenditCheckResponse;

  factory XenditCheckResponse.fromJson(Map<String, dynamic> json) =>
      _$XenditCheckResponseFromJson(json);
}

@freezed
class XenditCheckData with _$XenditCheckData {
  const factory XenditCheckData({
    required String status,
    @JsonKey(name: 'is_paid') required bool isPaid,
    @JsonKey(name: 'is_expired') bool? isExpired,
    @JsonKey(name: 'paid_at') String? paidAt,
    @JsonKey(name: 'expires_at') String? expiresAt,
    @JsonKey(name: 'payment_method') String? paymentMethod,
    @JsonKey(name: 'payment_channel') String? paymentChannel,
    @JsonKey(name: 'sale_id') int? saleId,
  }) = _XenditCheckData;

  factory XenditCheckData.fromJson(Map<String, dynamic> json) =>
      _$XenditCheckDataFromJson(json);
}
```

**File: `lib/data/models/request/xendit_sale_request.dart`**
```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'xendit_sale_request.freezed.dart';
part 'xendit_sale_request.g.dart';

@freezed
class XenditSaleRequest with _$XenditSaleRequest {
  const factory XenditSaleRequest({
    @JsonKey(name: 'customer_id') int? customerId,
    required List<XenditSaleItem> items,
    @Default(0) double discount,
    @Default(0) double tax,
    String? notes,
    @JsonKey(name: 'payment_method_code') required String paymentMethodCode,
  }) = _XenditSaleRequest;

  factory XenditSaleRequest.fromJson(Map<String, dynamic> json) =>
      _$XenditSaleRequestFromJson(json);
}

@freezed
class XenditSaleItem with _$XenditSaleItem {
  const factory XenditSaleItem({
    @JsonKey(name: 'product_id') required int productId,
    @JsonKey(name: 'batch_id') required int batchId,
    @JsonKey(name: 'unit_id') int? unitId,
    required int quantity,
    required double price,
    @Default(0) double discount,
  }) = _XenditSaleItem;

  factory XenditSaleItem.fromJson(Map<String, dynamic> json) =>
      _$XenditSaleItemFromJson(json);
}
```

---

### Step 2: Create Datasource

**File: `lib/data/datasources/xendit_remote_datasource.dart`**
```dart
import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../models/request/xendit_sale_request.dart';
import '../models/response/xendit_check_response.dart';
import '../models/response/xendit_invoice_response.dart';
import '../models/response/xendit_sale_response.dart';
import '../models/response/xendit_status_response.dart';
import '../../core/constants/variables.dart';
import 'auth_local_datasource.dart';

class XenditRemoteDatasource {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthLocalDatasource().getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Check if Xendit is enabled
  Future<Either<String, XenditStatusResponse>> getStatus() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${Variables.baseUrl}/api/v1/xendit/status'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Right(XenditStatusResponse.fromJson(jsonDecode(response.body)));
      } else {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Failed to get Xendit status');
      }
    } catch (e) {
      return Left('Network error: $e');
    }
  }

  /// Create sale with Xendit payment
  Future<Either<String, XenditSaleResponse>> createSaleWithPayment(
    XenditSaleRequest request,
  ) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${Variables.baseUrl}/api/v1/xendit/sale'),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Right(XenditSaleResponse.fromJson(jsonDecode(response.body)));
      } else {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Failed to create Xendit sale');
      }
    } catch (e) {
      return Left('Network error: $e');
    }
  }

  /// Create invoice for existing sale
  Future<Either<String, XenditInvoiceResponse>> createInvoice({
    required int saleId,
    String? paymentMethodCode,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = {
        'sale_id': saleId,
        if (paymentMethodCode != null) 'payment_method_code': paymentMethodCode,
      };

      final response = await http.post(
        Uri.parse('${Variables.baseUrl}/api/v1/xendit/invoice'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Right(XenditInvoiceResponse.fromJson(jsonDecode(response.body)));
      } else {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Failed to create invoice');
      }
    } catch (e) {
      return Left('Network error: $e');
    }
  }

  /// Check payment status
  Future<Either<String, XenditCheckResponse>> checkStatus(int transactionId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${Variables.baseUrl}/api/v1/xendit/check/$transactionId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Right(XenditCheckResponse.fromJson(jsonDecode(response.body)));
      } else {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Failed to check status');
      }
    } catch (e) {
      return Left('Network error: $e');
    }
  }

  /// Cancel payment
  Future<Either<String, String>> cancelPayment(int transactionId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${Variables.baseUrl}/api/v1/xendit/cancel/$transactionId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Right(data['message'] ?? 'Payment cancelled');
      } else {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Failed to cancel payment');
      }
    } catch (e) {
      return Left('Network error: $e');
    }
  }
}
```

---

### Step 3: Create BLoC

**File: `lib/presentation/xendit/bloc/xendit_event.dart`**
```dart
part of 'xendit_bloc.dart';

@freezed
class XenditEvent with _$XenditEvent {
  const factory XenditEvent.checkStatus() = _CheckStatus;
  const factory XenditEvent.createSale(XenditSaleRequest request) = _CreateSale;
  const factory XenditEvent.createInvoice({
    required int saleId,
    String? paymentMethodCode,
  }) = _CreateInvoice;
  const factory XenditEvent.checkPaymentStatus(int transactionId) = _CheckPaymentStatus;
  const factory XenditEvent.cancelPayment(int transactionId) = _CancelPayment;
  const factory XenditEvent.startPolling(int transactionId) = _StartPolling;
  const factory XenditEvent.stopPolling() = _StopPolling;
}
```

**File: `lib/presentation/xendit/bloc/xendit_state.dart`**
```dart
part of 'xendit_bloc.dart';

@freezed
class XenditState with _$XenditState {
  const factory XenditState.initial() = _Initial;
  const factory XenditState.loading() = _Loading;

  // Status
  const factory XenditState.statusLoaded(XenditStatusData status) = _StatusLoaded;
  const factory XenditState.statusError(String message) = _StatusError;

  // Sale Creation
  const factory XenditState.saleCreated(XenditSaleData sale) = _SaleCreated;
  const factory XenditState.saleError(String message) = _SaleError;

  // Invoice Creation
  const factory XenditState.invoiceCreated(XenditInvoiceData invoice) = _InvoiceCreated;
  const factory XenditState.invoiceError(String message) = _InvoiceError;

  // Payment Status
  const factory XenditState.paymentPending(XenditCheckData data) = _PaymentPending;
  const factory XenditState.paymentSuccess(XenditCheckData data) = _PaymentSuccess;
  const factory XenditState.paymentExpired(XenditCheckData data) = _PaymentExpired;
  const factory XenditState.paymentError(String message) = _PaymentError;

  // Cancel
  const factory XenditState.paymentCancelled(String message) = _PaymentCancelled;
}
```

**File: `lib/presentation/xendit/bloc/xendit_bloc.dart`**
```dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data/datasources/xendit_remote_datasource.dart';
import '../../../data/models/request/xendit_sale_request.dart';
import '../../../data/models/response/xendit_check_response.dart';
import '../../../data/models/response/xendit_invoice_response.dart';
import '../../../data/models/response/xendit_sale_response.dart';
import '../../../data/models/response/xendit_status_response.dart';

part 'xendit_event.dart';
part 'xendit_state.dart';
part 'xendit_bloc.freezed.dart';

class XenditBloc extends Bloc<XenditEvent, XenditState> {
  final XenditRemoteDatasource _datasource;
  Timer? _pollingTimer;

  XenditBloc(this._datasource) : super(const XenditState.initial()) {
    on<_CheckStatus>(_onCheckStatus);
    on<_CreateSale>(_onCreateSale);
    on<_CreateInvoice>(_onCreateInvoice);
    on<_CheckPaymentStatus>(_onCheckPaymentStatus);
    on<_CancelPayment>(_onCancelPayment);
    on<_StartPolling>(_onStartPolling);
    on<_StopPolling>(_onStopPolling);
  }

  Future<void> _onCheckStatus(_CheckStatus event, Emitter<XenditState> emit) async {
    emit(const XenditState.loading());
    final result = await _datasource.getStatus();
    result.fold(
      (error) => emit(XenditState.statusError(error)),
      (response) => emit(XenditState.statusLoaded(response.data)),
    );
  }

  Future<void> _onCreateSale(_CreateSale event, Emitter<XenditState> emit) async {
    emit(const XenditState.loading());
    final result = await _datasource.createSaleWithPayment(event.request);
    result.fold(
      (error) => emit(XenditState.saleError(error)),
      (response) => emit(XenditState.saleCreated(response.data)),
    );
  }

  Future<void> _onCreateInvoice(_CreateInvoice event, Emitter<XenditState> emit) async {
    emit(const XenditState.loading());
    final result = await _datasource.createInvoice(
      saleId: event.saleId,
      paymentMethodCode: event.paymentMethodCode,
    );
    result.fold(
      (error) => emit(XenditState.invoiceError(error)),
      (response) => emit(XenditState.invoiceCreated(response.data)),
    );
  }

  Future<void> _onCheckPaymentStatus(_CheckPaymentStatus event, Emitter<XenditState> emit) async {
    final result = await _datasource.checkStatus(event.transactionId);
    result.fold(
      (error) => emit(XenditState.paymentError(error)),
      (response) {
        final data = response.data;
        if (data.isPaid) {
          _stopPollingTimer();
          emit(XenditState.paymentSuccess(data));
        } else if (data.isExpired == true) {
          _stopPollingTimer();
          emit(XenditState.paymentExpired(data));
        } else {
          emit(XenditState.paymentPending(data));
        }
      },
    );
  }

  Future<void> _onCancelPayment(_CancelPayment event, Emitter<XenditState> emit) async {
    emit(const XenditState.loading());
    final result = await _datasource.cancelPayment(event.transactionId);
    result.fold(
      (error) => emit(XenditState.paymentError(error)),
      (message) {
        _stopPollingTimer();
        emit(XenditState.paymentCancelled(message));
      },
    );
  }

  void _onStartPolling(_StartPolling event, Emitter<XenditState> emit) {
    _stopPollingTimer();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      add(XenditEvent.checkPaymentStatus(event.transactionId));
    });
  }

  void _onStopPolling(_StopPolling event, Emitter<XenditState> emit) {
    _stopPollingTimer();
  }

  void _stopPollingTimer() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  @override
  Future<void> close() {
    _stopPollingTimer();
    return super.close();
  }
}
```

---

### Step 4: Create Payment Page UI

**File: `lib/presentation/xendit/pages/xendit_payment_page.dart`**
```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/datasources/xendit_remote_datasource.dart';
import '../../../data/models/request/xendit_sale_request.dart';
import '../bloc/xendit_bloc.dart';

class XenditPaymentPage extends StatefulWidget {
  final XenditSaleRequest saleRequest;

  const XenditPaymentPage({
    super.key,
    required this.saleRequest,
  });

  @override
  State<XenditPaymentPage> createState() => _XenditPaymentPageState();
}

class _XenditPaymentPageState extends State<XenditPaymentPage> {
  late XenditBloc _xenditBloc;
  int? _transactionId;
  String? _invoiceUrl;

  @override
  void initState() {
    super.initState();
    _xenditBloc = XenditBloc(XenditRemoteDatasource());
    // Create sale with Xendit payment
    _xenditBloc.add(XenditEvent.createSale(widget.saleRequest));
  }

  @override
  void dispose() {
    _xenditBloc.add(const XenditEvent.stopPolling());
    _xenditBloc.close();
    super.dispose();
  }

  void _openPaymentUrl() async {
    if (_invoiceUrl != null) {
      final uri = Uri.parse(_invoiceUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _xenditBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pembayaran Xendit'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _showCancelDialog(),
          ),
        ),
        body: BlocConsumer<XenditBloc, XenditState>(
          listener: (context, state) {
            state.maybeWhen(
              saleCreated: (sale) {
                _transactionId = sale.xendit.transactionId;
                _invoiceUrl = sale.xendit.invoiceUrl;
                // Start polling for payment status
                _xenditBloc.add(XenditEvent.startPolling(_transactionId!));
                // Open payment URL
                _openPaymentUrl();
              },
              paymentSuccess: (data) {
                _showSuccessDialog(data.saleId);
              },
              paymentExpired: (data) {
                _showExpiredDialog();
              },
              paymentCancelled: (message) {
                Navigator.of(context).pop({'cancelled': true});
              },
              saleError: (message) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message), backgroundColor: Colors.red),
                );
              },
              orElse: () {},
            );
          },
          builder: (context, state) {
            return state.maybeWhen(
              loading: () => const Center(child: CircularProgressIndicator()),
              saleCreated: (sale) => _buildWaitingPayment(sale),
              paymentPending: (data) => _buildWaitingPayment(null),
              paymentSuccess: (data) => _buildSuccess(),
              paymentExpired: (data) => _buildExpired(),
              saleError: (message) => _buildError(message),
              orElse: () => const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWaitingPayment(XenditSaleData? sale) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            const Text(
              'Menunggu Pembayaran',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              sale != null
                ? 'Total: Rp ${sale.total.toStringAsFixed(0)}'
                : 'Silakan selesaikan pembayaran',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _openPaymentUrl,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Buka Halaman Pembayaran'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                if (_transactionId != null) {
                  _xenditBloc.add(XenditEvent.checkPaymentStatus(_transactionId!));
                }
              },
              child: const Text('Cek Status Pembayaran'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _showCancelDialog,
              child: const Text('Batalkan', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 80, color: Colors.green),
          const SizedBox(height: 24),
          const Text(
            'Pembayaran Berhasil!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop({'success': true}),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  Widget _buildExpired() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer_off, size: 80, color: Colors.orange),
          const SizedBox(height: 24),
          const Text(
            'Pembayaran Kedaluwarsa',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop({'expired': true}),
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 80, color: Colors.red),
          const SizedBox(height: 24),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kembali'),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pembayaran?'),
        content: const Text('Apakah Anda yakin ingin membatalkan pembayaran ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (_transactionId != null) {
                _xenditBloc.add(XenditEvent.cancelPayment(_transactionId!));
              } else {
                Navigator.of(this.context).pop({'cancelled': true});
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
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Pembayaran Berhasil'),
          ],
        ),
        content: const Text('Pembayaran telah diterima.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(this.context).pop({'success': true, 'sale_id': saleId});
            },
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
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.timer_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('Pembayaran Kedaluwarsa'),
          ],
        ),
        content: const Text('Waktu pembayaran telah habis. Silakan buat transaksi baru.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(this.context).pop({'expired': true});
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

---

### Step 5: Payment Method Selection Widget

**File: `lib/presentation/xendit/widgets/xendit_payment_method_selector.dart`**
```dart
import 'package:flutter/material.dart';

class XenditPaymentMethodSelector extends StatelessWidget {
  final String? selectedMethod;
  final ValueChanged<String> onSelected;

  const XenditPaymentMethodSelector({
    super.key,
    this.selectedMethod,
    required this.onSelected,
  });

  static const List<Map<String, dynamic>> methods = [
    {'code': 'QRIS', 'name': 'QRIS', 'icon': Icons.qr_code_2, 'color': Color(0xFF00D4AA)},
    {'code': 'GOPAY', 'name': 'GoPay', 'icon': Icons.account_balance_wallet, 'color': Color(0xFF00AED6)},
    {'code': 'OVO', 'name': 'OVO', 'icon': Icons.account_balance_wallet, 'color': Color(0xFF4C3494)},
    {'code': 'DANA', 'name': 'DANA', 'icon': Icons.account_balance_wallet, 'color': Color(0xFF118EEA)},
    {'code': 'SHOPEEPAY', 'name': 'ShopeePay', 'icon': Icons.account_balance_wallet, 'color': Color(0xFFEE4D2D)},
    {'code': 'LINKAJA', 'name': 'LinkAja', 'icon': Icons.account_balance_wallet, 'color': Color(0xFFE82127)},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Pilih Metode Pembayaran Digital',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: methods.length,
          itemBuilder: (context, index) {
            final method = methods[index];
            final isSelected = selectedMethod == method['code'];
            return InkWell(
              onTap: () => onSelected(method['code']),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? method['color'].withOpacity(0.1) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? method['color'] : Colors.grey[300]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      method['icon'],
                      size: 32,
                      color: isSelected ? method['color'] : Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      method['name'],
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? method['color'] : Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
```

---

### Step 6: Integration di Checkout Page

Di checkout page yang sudah ada, tambahkan opsi untuk pembayaran Xendit:

```dart
// Di checkout_page.dart atau payment_page.dart

// Import
import '../xendit/pages/xendit_payment_page.dart';
import '../../../data/models/request/xendit_sale_request.dart';

// Method untuk navigate ke Xendit payment
void _processXenditPayment(String paymentMethodCode) {
  // Convert cart items ke XenditSaleItem
  final items = cartItems.map((item) => XenditSaleItem(
    productId: item.product.id,
    batchId: item.batchId,
    unitId: item.unitId,
    quantity: item.quantity,
    price: item.price,
    discount: item.discount,
  )).toList();

  final request = XenditSaleRequest(
    customerId: selectedCustomer?.id,
    items: items,
    discount: totalDiscount,
    tax: totalTax,
    notes: notes,
    paymentMethodCode: paymentMethodCode,
  );

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => XenditPaymentPage(saleRequest: request),
    ),
  ).then((result) {
    if (result != null && result['success'] == true) {
      // Payment successful, show receipt or go back to POS
      _showSuccessAndPrintReceipt(result['sale_id']);
    }
  });
}
```

---

### Step 7: Dependencies

Tambahkan di `pubspec.yaml`:

```yaml
dependencies:
  url_launcher: ^6.2.5
```

---

### Step 8: Run Build Runner

Setelah membuat semua model files, jalankan:

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Flow Diagram

```
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Checkout      │     │  Xendit Payment │     │    Xendit       │
│     Page        │────▶│      Page       │────▶│   Checkout      │
└─────────────────┘     └─────────────────┘     └─────────────────┘
                               │                        │
                               │  Polling Status        │
                               │◀───────────────────────│
                               │                        │
                               ▼                        │
                        ┌─────────────────┐            │
                        │  Payment Status │◀───────────┘
                        │   (Webhook)     │
                        └─────────────────┘
                               │
                               ▼
                        ┌─────────────────┐
                        │    Success /    │
                        │    Receipt      │
                        └─────────────────┘
```

---

## Testing

### Test dengan Xendit Sandbox
1. Gunakan API key development (sudah dikonfigurasi di backend)
2. Untuk QRIS, scan QR code dan pilih "Simulate Payment" di halaman Xendit
3. Pembayaran akan otomatis terdeteksi via polling

### Test Scenarios
1. **Happy Path**: Create sale → Open payment URL → Complete payment → Auto redirect
2. **Cancel**: Create sale → Cancel before payment → Sale cancelled
3. **Expired**: Create sale → Wait until expired → Show expired message
4. **Network Error**: Simulate offline → Show error message

---

## Notes

- Backend sudah handle stock reduction HANYA setelah payment success
- Polling interval: 3 detik (bisa disesuaikan)
- Invoice expires: 1 jam (dikonfigurasi di backend)
- Webhook juga akan update status jika polling miss

---

## Support

Jika ada pertanyaan atau issue, hubungi:
- Backend API: `https://apotek.jagofullstack.com`
- API Documentation: `https://apotek.jagofullstack.com/docs/api`
