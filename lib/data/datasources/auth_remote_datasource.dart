import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/variables.dart';
import '../../core/utils/app_logger.dart';
import '../models/responses/auth_response_model.dart';
import '../models/responses/user_model.dart';
import 'auth_local_datasource.dart';

class AuthRemoteDatasource {
  Future<Either<String, AuthResponseModel>> login(
    String email,
    String password,
  ) async {
    try {
      AppLogger.apiRequest('POST', Variables.login, body: {'email': email});

      final response = await http.post(
        Uri.parse(Variables.login),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'device_name': 'Flutter Apotek App',
        }),
      );

      AppLogger.apiResponse(Variables.login, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final authResponse = AuthResponseModel.fromJson(jsonDecode(response.body));
        return Right(authResponse);
      } else if (response.statusCode == 422) {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Email atau password salah');
      } else if (response.statusCode == 401) {
        return const Left('Email atau password salah');
      } else {
        return const Left('Login gagal. Silakan coba lagi.');
      }
    } catch (e) {
      AppLogger.error('Login error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }

  Future<Either<String, bool>> logout() async {
    try {
      final token = await AuthLocalDatasource().getToken();

      final response = await http.post(
        Uri.parse(Variables.logout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      AppLogger.apiResponse(Variables.logout, response.statusCode, response.body);

      if (response.statusCode == 200) {
        await AuthLocalDatasource().clearAll();
        return const Right(true);
      }
      // Even if logout fails on server, clear local data
      await AuthLocalDatasource().clearAll();
      return const Right(true);
    } catch (e) {
      AppLogger.error('Logout error', error: e);
      // Clear local data even on error
      await AuthLocalDatasource().clearAll();
      return const Right(true);
    }
  }

  Future<Either<String, UserModel>> getMe() async {
    try {
      final token = await AuthLocalDatasource().getToken();

      if (token == null) {
        return const Left('Token tidak ditemukan');
      }

      final response = await http.get(
        Uri.parse(Variables.me),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      AppLogger.apiResponse(Variables.me, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Right(UserModel.fromJson(data['data']));
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengambil data user');
    } catch (e) {
      AppLogger.error('GetMe error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }

  Future<Either<String, UserModel>> updateProfile({
    required String name,
    String? phone,
  }) async {
    try {
      final token = await AuthLocalDatasource().getToken();

      if (token == null) {
        return const Left('Token tidak ditemukan');
      }

      final body = {
        'name': name,
        if (phone != null) 'phone': phone,
      };

      AppLogger.apiRequest('PUT', Variables.updateProfile, body: body);

      final response = await http.put(
        Uri.parse(Variables.updateProfile),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      AppLogger.apiResponse(Variables.updateProfile, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Right(UserModel.fromJson(data['data']));
      } else if (response.statusCode == 422) {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Validasi gagal');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal memperbarui profil');
    } catch (e) {
      AppLogger.error('UpdateProfile error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }

  Future<Either<String, String>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await AuthLocalDatasource().getToken();

      if (token == null) {
        return const Left('Token tidak ditemukan');
      }

      final body = {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPassword,
      };

      AppLogger.apiRequest('PUT', Variables.changePassword, body: {'current_password': '***', 'password': '***'});

      final response = await http.put(
        Uri.parse(Variables.changePassword),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      AppLogger.apiResponse(Variables.changePassword, response.statusCode, response.body);

      if (response.statusCode == 200) {
        return const Right('Password berhasil diubah');
      } else if (response.statusCode == 422) {
        final error = jsonDecode(response.body);
        return Left(error['message'] ?? 'Password saat ini tidak sesuai');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengubah password');
    } catch (e) {
      AppLogger.error('ChangePassword error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }
}
