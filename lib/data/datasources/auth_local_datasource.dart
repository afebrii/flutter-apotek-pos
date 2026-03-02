import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/responses/user_model.dart';
import '../models/responses/auth_response_model.dart';

class AuthLocalDatasource {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  Future<void> saveAuthData(AuthResponseModel authData) async {
    final prefs = await SharedPreferences.getInstance();
    if (authData.token != null) {
      await prefs.setString(_tokenKey, authData.token!);
    }
    if (authData.user != null) {
      await prefs.setString(_userKey, jsonEncode(authData.user!.toJson()));
    }
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
