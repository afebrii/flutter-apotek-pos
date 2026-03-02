import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/variables.dart';
import '../../core/utils/app_logger.dart';
import '../models/requests/sale_request_model.dart';
import '../models/responses/sale_model.dart';
import '../models/responses/receipt_model.dart';
import 'auth_local_datasource.dart';

class SaleRemoteDatasource {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthLocalDatasource().getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Either<String, CreateSaleResponse>> createSale(
    SaleRequestModel request,
  ) async {
    try {
      final headers = await _getHeaders();

      AppLogger.apiRequest('POST', Variables.sales, body: request.toJson());

      final response = await http.post(
        Uri.parse(Variables.sales),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      AppLogger.apiResponse(
        Variables.sales,
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Right(CreateSaleResponse.fromJson(data));
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'Validasi gagal';
        return Left(message);
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal membuat transaksi');
    } catch (e) {
      AppLogger.error('CreateSale error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }

  Future<Either<String, SaleListResponse>> getSales({
    String? date,
    String? status,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final headers = await _getHeaders();

      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (date != null) {
        queryParams['date'] = date;
      }
      if (status != null) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse(Variables.sales).replace(queryParameters: queryParams);

      AppLogger.apiRequest('GET', uri.toString());

      final response = await http.get(uri, headers: headers);

      AppLogger.apiResponse(Variables.sales, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Right(SaleListResponse.fromJson(data));
        }
        return const Left('Format response tidak valid');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengambil data transaksi');
    } catch (e) {
      AppLogger.error('GetSales error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }

  Future<Either<String, SaleModel>> getSaleById(int id) async {
    try {
      final headers = await _getHeaders();
      final url = '${Variables.sales}/$id';

      AppLogger.apiRequest('GET', url);

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      AppLogger.apiResponse(url, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Right(SaleModel.fromJson(data['data']));
        }
        return const Left('Transaksi tidak ditemukan');
      } else if (response.statusCode == 404) {
        return const Left('Transaksi tidak ditemukan');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengambil detail transaksi');
    } catch (e) {
      AppLogger.error('GetSaleById error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }

  /// Void a sale (cancel transaction)
  Future<Either<String, VoidSaleResponse>> voidSale(int saleId, String reason) async {
    try {
      final headers = await _getHeaders();
      final url = '${Variables.sales}/$saleId/void';

      AppLogger.apiRequest('POST', url, body: {'reason': reason});

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({'reason': reason}),
      );

      AppLogger.apiResponse(url, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Right(VoidSaleResponse.fromJson(data));
        }
        return Left(data['message'] ?? 'Gagal membatalkan transaksi');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        return Left(data['message'] ?? 'Tidak dapat membatalkan transaksi');
      } else if (response.statusCode == 404) {
        return const Left('Transaksi tidak ditemukan');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal membatalkan transaksi');
    } catch (e) {
      AppLogger.error('VoidSale error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }

  /// Get receipt data for printing
  Future<Either<String, ReceiptModel>> getReceipt(int saleId) async {
    try {
      final headers = await _getHeaders();
      final url = '${Variables.sales}/$saleId/receipt';

      AppLogger.apiRequest('GET', url);

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      AppLogger.apiResponse(url, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Right(ReceiptModel.fromJson(data['data']));
        }
        return const Left('Data receipt tidak ditemukan');
      } else if (response.statusCode == 404) {
        return const Left('Transaksi tidak ditemukan');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengambil data receipt');
    } catch (e) {
      AppLogger.error('GetReceipt error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }
}

class VoidSaleResponse {
  final bool success;
  final String? message;
  final int? saleId;
  final String? invoiceNumber;
  final String? status;

  VoidSaleResponse({
    required this.success,
    this.message,
    this.saleId,
    this.invoiceNumber,
    this.status,
  });

  factory VoidSaleResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return VoidSaleResponse(
      success: json['success'] ?? false,
      message: json['message'],
      saleId: data?['id'],
      invoiceNumber: data?['invoice_number'],
      status: data?['status'],
    );
  }
}

class SaleListResponse {
  final List<SaleModel> sales;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  SaleListResponse({
    required this.sales,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory SaleListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'] ?? data;

    List<SaleModel> sales = [];
    if (data != null) {
      final saleList = data['data'] ?? data;
      if (saleList is List) {
        sales = saleList.map((e) => SaleModel.fromJson(e)).toList();
      }
    }

    return SaleListResponse(
      sales: sales,
      currentPage: meta?['current_page'] ?? 1,
      lastPage: meta?['last_page'] ?? 1,
      perPage: meta?['per_page'] ?? 15,
      total: meta?['total'] ?? sales.length,
    );
  }

  bool get hasNextPage => currentPage < lastPage;
}
