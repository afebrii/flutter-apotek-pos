import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../models/requests/xendit_sale_request.dart';
import '../models/responses/xendit_check_response.dart';
import '../models/responses/xendit_invoice_response.dart';
import '../models/responses/xendit_sale_response.dart';
import '../models/responses/xendit_status_response.dart';
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

  /// Check if Xendit is enabled and get available payment methods
  Future<Either<String, XenditStatusResponse>> getStatus() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${Variables.apiBaseUrl}/xendit/status'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Right(XenditStatusResponse.fromJson(jsonDecode(response.body)));
      } else {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Gagal mendapatkan status Xendit');
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
        Uri.parse('${Variables.apiBaseUrl}/xendit/sale'),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Right(XenditSaleResponse.fromJson(jsonDecode(response.body)));
      } else {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Gagal membuat transaksi Xendit');
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
        Uri.parse('${Variables.apiBaseUrl}/xendit/invoice'),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return Right(XenditInvoiceResponse.fromJson(jsonDecode(response.body)));
      } else {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Gagal membuat invoice');
      }
    } catch (e) {
      return Left('Network error: $e');
    }
  }

  /// Check payment status
  Future<Either<String, XenditCheckResponse>> checkStatus(
      int transactionId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('${Variables.apiBaseUrl}/xendit/check/$transactionId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return Right(XenditCheckResponse.fromJson(jsonDecode(response.body)));
      } else {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Gagal mengecek status');
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
        Uri.parse('${Variables.apiBaseUrl}/xendit/cancel/$transactionId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Right(data['message'] ?? 'Pembayaran berhasil dibatalkan');
      } else {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Gagal membatalkan pembayaran');
      }
    } catch (e) {
      return Left('Network error: $e');
    }
  }
}
