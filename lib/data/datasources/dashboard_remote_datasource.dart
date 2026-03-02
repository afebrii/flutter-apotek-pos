import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/variables.dart';
import '../../core/utils/app_logger.dart';
import '../models/responses/dashboard_model.dart';
import 'auth_local_datasource.dart';

class DashboardRemoteDatasource {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthLocalDatasource().getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Either<String, DashboardSummaryModel>> getSummary() async {
    try {
      final headers = await _getHeaders();

      AppLogger.apiRequest('GET', Variables.dashboardSummary);

      final response = await http.get(
        Uri.parse(Variables.dashboardSummary),
        headers: headers,
      );

      AppLogger.apiResponse(
        Variables.dashboardSummary,
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Right(DashboardSummaryModel.fromJson(data['data']));
        }
        return const Left('Format response tidak valid');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengambil data dashboard');
    } catch (e) {
      AppLogger.error('GetSummary error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }

  Future<Either<String, List<LowStockProductModel>>> getLowStockProducts() async {
    try {
      final headers = await _getHeaders();

      AppLogger.apiRequest('GET', Variables.dashboardLowStock);

      final response = await http.get(
        Uri.parse(Variables.dashboardLowStock),
        headers: headers,
      );

      AppLogger.apiResponse(
        Variables.dashboardLowStock,
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final list = (data['data'] as List)
              .map((e) => LowStockProductModel.fromJson(e))
              .toList();
          return Right(list);
        }
        return const Left('Format response tidak valid');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengambil data stok rendah');
    } catch (e) {
      AppLogger.error('GetLowStockProducts error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }

  Future<Either<String, List<ExpiringBatchModel>>> getExpiringBatches() async {
    try {
      final headers = await _getHeaders();

      AppLogger.apiRequest('GET', Variables.dashboardExpiring);

      final response = await http.get(
        Uri.parse(Variables.dashboardExpiring),
        headers: headers,
      );

      AppLogger.apiResponse(
        Variables.dashboardExpiring,
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final list = (data['data'] as List)
              .map((e) => ExpiringBatchModel.fromJson(e))
              .toList();
          return Right(list);
        }
        return const Left('Format response tidak valid');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengambil data kadaluarsa');
    } catch (e) {
      AppLogger.error('GetExpiringBatches error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }
}
