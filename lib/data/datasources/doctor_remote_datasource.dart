import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/variables.dart';
import '../../core/utils/app_logger.dart';
import '../models/responses/doctor_model.dart';
import 'auth_local_datasource.dart';

class DoctorRemoteDatasource {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthLocalDatasource().getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Get list of doctors with pagination and search
  Future<Either<String, DoctorListResponse>> getDoctors({
    String? search,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final headers = await _getHeaders();

      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse(Variables.doctors).replace(queryParameters: queryParams);

      AppLogger.apiRequest('GET', uri.toString());

      final response = await http.get(uri, headers: headers);

      AppLogger.apiResponse(Variables.doctors, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Right(DoctorListResponse.fromJson(data));
        }
        return const Left('Format response tidak valid');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengambil data dokter');
    } catch (e) {
      AppLogger.error('GetDoctors error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }

  /// Get doctor detail by ID
  Future<Either<String, DoctorModel>> getDoctorById(int id) async {
    try {
      final headers = await _getHeaders();
      final url = '${Variables.doctors}/$id';

      AppLogger.apiRequest('GET', url);

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      AppLogger.apiResponse(url, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Right(DoctorModel.fromJson(data['data']));
        }
        return const Left('Dokter tidak ditemukan');
      } else if (response.statusCode == 404) {
        return const Left('Dokter tidak ditemukan');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengambil detail dokter');
    } catch (e) {
      AppLogger.error('GetDoctorById error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }

  /// Create new doctor
  Future<Either<String, DoctorModel>> createDoctor(CreateDoctorRequest request) async {
    try {
      final headers = await _getHeaders();

      AppLogger.apiRequest('POST', Variables.doctors, body: request.toJson());

      final response = await http.post(
        Uri.parse(Variables.doctors),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      AppLogger.apiResponse(Variables.doctors, response.statusCode, response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Right(DoctorModel.fromJson(data['data']));
        }
        return Left(data['message'] ?? 'Gagal menambahkan dokter');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'Validasi gagal';
        return Left(message);
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal menambahkan dokter');
    } catch (e) {
      AppLogger.error('CreateDoctor error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }
}
