import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/variables.dart';
import '../../core/utils/app_logger.dart';
import '../models/responses/transaction_model.dart';
import 'auth_local_datasource.dart';

class TransactionRemoteDatasource {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthLocalDatasource().getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Either<String, TransactionListResponse>> getTransactions({
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

      if (date != null && date.isNotEmpty) {
        queryParams['date'] = date;
      }

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final uri = Uri.parse(Variables.sales).replace(queryParameters: queryParams);

      AppLogger.apiRequest('GET', uri.toString());

      final response = await http.get(uri, headers: headers);

      AppLogger.apiResponse(
        uri.toString(),
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final transactions = (data['data']['data'] as List? ?? [])
              .map((e) => TransactionModel.fromJson(e))
              .toList();

          final meta = data['meta'] ?? {};

          return Right(TransactionListResponse(
            transactions: transactions,
            currentPage: meta['current_page'] ?? 1,
            lastPage: meta['last_page'] ?? 1,
            total: meta['total'] ?? transactions.length,
          ));
        }
        return const Left('Format response tidak valid');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengambil data transaksi');
    } catch (e) {
      AppLogger.error('GetTransactions error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }

  Future<Either<String, TransactionDetailModel>> getTransactionDetail(int id) async {
    try {
      final headers = await _getHeaders();

      final url = '${Variables.sales}/$id';
      AppLogger.apiRequest('GET', url);

      final response = await http.get(Uri.parse(url), headers: headers);

      AppLogger.apiResponse(
        url,
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Right(TransactionDetailModel.fromJson(data['data']));
        }
        return const Left('Format response tidak valid');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      } else if (response.statusCode == 404) {
        return const Left('Transaksi tidak ditemukan');
      }
      return const Left('Gagal mengambil detail transaksi');
    } catch (e) {
      AppLogger.error('GetTransactionDetail error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }
}

class TransactionListResponse {
  final List<TransactionModel> transactions;
  final int currentPage;
  final int lastPage;
  final int total;

  TransactionListResponse({
    required this.transactions,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });

  bool get hasMore => currentPage < lastPage;
}
