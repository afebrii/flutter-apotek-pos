import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/variables.dart';
import '../../core/utils/app_logger.dart';
import '../models/responses/payment_method_model.dart';
import 'auth_local_datasource.dart';

class PaymentMethodRemoteDatasource {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthLocalDatasource().getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Either<String, List<PaymentMethodModel>>> getPaymentMethods() async {
    try {
      final headers = await _getHeaders();

      AppLogger.apiRequest('GET', Variables.paymentMethods);

      final response = await http.get(
        Uri.parse(Variables.paymentMethods),
        headers: headers,
      );

      AppLogger.apiResponse(
        Variables.paymentMethods,
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final methods = (data['data'] as List)
              .map((e) => PaymentMethodModel.fromJson(e))
              .toList();
          return Right(methods);
        }
        return const Left('Format response tidak valid');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengambil metode pembayaran');
    } catch (e) {
      AppLogger.error('GetPaymentMethods error', error: e);
      // Return default methods as fallback
      return Right(PaymentMethodModel.getDefaultMethods());
    }
  }
}
