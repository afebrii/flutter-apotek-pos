import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/variables.dart';
import '../../core/utils/app_logger.dart';
import '../models/responses/report_model.dart';
import 'auth_local_datasource.dart';

class ReportRemoteDatasource {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthLocalDatasource().getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Either<String, SalesReportModel>> getSalesReport({
    required String startDate,
    required String endDate,
  }) async {
    try {
      final headers = await _getHeaders();

      final queryParams = {
        'start_date': startDate,
        'end_date': endDate,
      };

      final uri = Uri.parse(Variables.reportSales).replace(queryParameters: queryParams);

      AppLogger.apiRequest('GET', uri.toString());

      final response = await http.get(uri, headers: headers);

      AppLogger.apiResponse(
        uri.toString(),
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Right(SalesReportModel.fromJson(data['data']));
        }
        return const Left('Format response tidak valid');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        return Left(data['message'] ?? 'Validasi gagal');
      }
      return const Left('Gagal mengambil laporan');
    } catch (e) {
      AppLogger.error('GetSalesReport error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }
}
