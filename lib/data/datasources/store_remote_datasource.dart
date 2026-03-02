import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/variables.dart';
import '../../core/utils/app_logger.dart';
import '../models/responses/store_model.dart';
import 'auth_local_datasource.dart';

class StoreRemoteDatasource {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthLocalDatasource().getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Get store information
  Future<Either<String, StoreModel>> getStore() async {
    try {
      final headers = await _getHeaders();

      AppLogger.apiRequest('GET', Variables.store);

      final response = await http.get(
        Uri.parse(Variables.store),
        headers: headers,
      );

      AppLogger.apiResponse(Variables.store, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Right(StoreModel.fromJson(data['data']));
        }
        return const Left('Data toko tidak ditemukan');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengambil data toko');
    } catch (e) {
      AppLogger.error('GetStore error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }

  /// Get application settings
  Future<Either<String, SettingsModel>> getSettings() async {
    try {
      final headers = await _getHeaders();

      AppLogger.apiRequest('GET', Variables.settings);

      final response = await http.get(
        Uri.parse(Variables.settings),
        headers: headers,
      );

      AppLogger.apiResponse(Variables.settings, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Right(SettingsModel.fromJson(data['data']));
        }
        return const Left('Settings tidak ditemukan');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengambil settings');
    } catch (e) {
      AppLogger.error('GetSettings error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }
}
