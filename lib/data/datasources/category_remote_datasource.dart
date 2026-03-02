import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/variables.dart';
import '../../core/utils/app_logger.dart';
import '../models/responses/category_model.dart';
import '../models/responses/category_type_model.dart';
import 'auth_local_datasource.dart';

class CategoryRemoteDatasource {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthLocalDatasource().getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Either<String, List<CategoryModel>>> getCategories() async {
    try {
      final headers = await _getHeaders();

      AppLogger.apiRequest('GET', Variables.categories);

      final response = await http.get(
        Uri.parse(Variables.categories),
        headers: headers,
      );

      AppLogger.apiResponse(
        Variables.categories,
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<CategoryModel> categories = (data['data'] as List)
              .map((e) => CategoryModel.fromJson(e))
              .toList();
          return Right(categories);
        }
        return const Right([]);
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengambil data kategori');
    } catch (e) {
      AppLogger.error('GetCategories error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }

  Future<Either<String, List<CategoryTypeModel>>> getCategoryTypes() async {
    try {
      final headers = await _getHeaders();

      AppLogger.apiRequest('GET', Variables.categoryTypes);

      final response = await http.get(
        Uri.parse(Variables.categoryTypes),
        headers: headers,
      );

      AppLogger.apiResponse(
        Variables.categoryTypes,
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final List<CategoryTypeModel> types = (data['data'] as List)
              .map((e) => CategoryTypeModel.fromJson(e))
              .toList();
          return Right(types);
        }
        return const Right([]);
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengambil data tipe kategori');
    } catch (e) {
      AppLogger.error('GetCategoryTypes error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }
}
