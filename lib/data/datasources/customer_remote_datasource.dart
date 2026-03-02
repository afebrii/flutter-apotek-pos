import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/variables.dart';
import '../../core/utils/app_logger.dart';
import '../models/requests/customer_request_model.dart';
import '../models/responses/customer_model.dart';
import 'auth_local_datasource.dart';

class CustomerRemoteDatasource {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthLocalDatasource().getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Either<String, CustomerListResponse>> getCustomers({
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

      final uri = Uri.parse(Variables.customers).replace(queryParameters: queryParams);

      AppLogger.apiRequest('GET', uri.toString());

      final response = await http.get(uri, headers: headers);

      AppLogger.apiResponse(Variables.customers, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Right(CustomerListResponse.fromJson(data));
        }
        return const Left('Format response tidak valid');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengambil data pelanggan');
    } catch (e) {
      AppLogger.error('GetCustomers error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }

  Future<Either<String, CustomerModel>> getCustomerById(int id) async {
    try {
      final headers = await _getHeaders();
      final url = '${Variables.customers}/$id';

      AppLogger.apiRequest('GET', url);

      final response = await http.get(Uri.parse(url), headers: headers);

      AppLogger.apiResponse(url, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Right(CustomerModel.fromJson(data['data']));
        }
        return const Left('Pelanggan tidak ditemukan');
      } else if (response.statusCode == 404) {
        return const Left('Pelanggan tidak ditemukan');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengambil data pelanggan');
    } catch (e) {
      AppLogger.error('GetCustomerById error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }

  Future<Either<String, CustomerModel>> createCustomer(
    CustomerRequestModel request,
  ) async {
    try {
      final headers = await _getHeaders();

      AppLogger.apiRequest('POST', Variables.customers, body: request.toJson());

      final response = await http.post(
        Uri.parse(Variables.customers),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      AppLogger.apiResponse(
        Variables.customers,
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Right(CustomerModel.fromJson(data['data']));
        }
        return const Left('Gagal membuat pelanggan');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        final message = data['message'] ?? 'Validasi gagal';
        return Left(message);
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal membuat pelanggan');
    } catch (e) {
      AppLogger.error('CreateCustomer error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }
}
