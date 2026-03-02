import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/variables.dart';
import '../../core/utils/app_logger.dart';
import '../models/responses/shift_model.dart';
import '../models/responses/shift_summary_model.dart';
import 'auth_local_datasource.dart';

class ShiftRemoteDatasource {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthLocalDatasource().getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Get current active shift
  Future<Either<String, ShiftModel?>> getCurrentShift() async {
    try {
      final headers = await _getHeaders();

      AppLogger.apiRequest('GET', Variables.shiftCurrent);

      final response = await http.get(
        Uri.parse(Variables.shiftCurrent),
        headers: headers,
      );

      AppLogger.apiResponse(
        Variables.shiftCurrent,
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Right(ShiftModel.fromJson(data['data']));
        }
        return const Right(null); // No active shift
      } else if (response.statusCode == 404) {
        return const Right(null); // No active shift
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengambil data shift');
    } catch (e) {
      AppLogger.error('GetCurrentShift error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }

  /// Open new shift
  Future<Either<String, ShiftModel>> openShift(OpenShiftRequest request) async {
    try {
      final headers = await _getHeaders();

      AppLogger.apiRequest('POST', Variables.shiftOpen, body: request.toJson());

      final response = await http.post(
        Uri.parse(Variables.shiftOpen),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      AppLogger.apiResponse(
        Variables.shiftOpen,
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Right(ShiftModel.fromJson(data['data']));
        }
        return Left(data['message'] ?? 'Gagal membuka shift');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        return Left(data['message'] ?? 'Anda sudah memiliki shift aktif');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal membuka shift');
    } catch (e) {
      AppLogger.error('OpenShift error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }

  /// Close current shift
  Future<Either<String, ShiftModel>> closeShift(CloseShiftRequest request) async {
    try {
      final headers = await _getHeaders();

      AppLogger.apiRequest('POST', Variables.shiftClose, body: request.toJson());

      final response = await http.post(
        Uri.parse(Variables.shiftClose),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      AppLogger.apiResponse(
        Variables.shiftClose,
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Right(ShiftModel.fromJson(data['data']));
        }
        return Left(data['message'] ?? 'Gagal menutup shift');
      } else if (response.statusCode == 404) {
        return const Left('Tidak ada shift aktif');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal menutup shift');
    } catch (e) {
      AppLogger.error('CloseShift error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }

  /// Get shift summary (for closing shift)
  Future<Either<String, ShiftSummaryModel>> getShiftSummary() async {
    try {
      final headers = await _getHeaders();

      AppLogger.apiRequest('GET', Variables.shiftSummary);

      final response = await http.get(
        Uri.parse(Variables.shiftSummary),
        headers: headers,
      );

      AppLogger.apiResponse(
        Variables.shiftSummary,
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Right(ShiftSummaryModel.fromJson(data['data']));
        }
        return const Left('Data summary tidak ditemukan');
      } else if (response.statusCode == 404) {
        return const Left('Tidak ada shift aktif');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengambil summary shift');
    } catch (e) {
      AppLogger.error('GetShiftSummary error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }

  /// Get shift sales list
  Future<Either<String, ShiftSalesResponse>> getShiftSales({int perPage = 20}) async {
    try {
      final headers = await _getHeaders();

      final queryParams = <String, String>{
        'per_page': perPage.toString(),
      };

      final uri = Uri.parse(Variables.shiftSales).replace(queryParameters: queryParams);

      AppLogger.apiRequest('GET', uri.toString());

      final response = await http.get(uri, headers: headers);

      AppLogger.apiResponse(
        Variables.shiftSales,
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Right(ShiftSalesResponse.fromJson(data));
        }
        return const Left('Format response tidak valid');
      } else if (response.statusCode == 404) {
        return const Left('Tidak ada shift aktif');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengambil data transaksi shift');
    } catch (e) {
      AppLogger.error('GetShiftSales error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }
}
