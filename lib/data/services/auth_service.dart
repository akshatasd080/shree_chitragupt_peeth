import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_config.dart';
import '../../core/network/api_client.dart';

class AuthService {
  AuthService({ApiClient? client}) : _client = client ?? ApiClient();

  final ApiClient _client;

  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'auth_user_id';
  static const String _keyUserName = 'auth_user_name';
  static const String _keyUserEmail = 'auth_user_email';
  static const String _keyUserMobile = 'auth_user_mobile';
  static const String _keyIsLoggedIn = 'isLoggedIn';

  static Future<Map<String, String>> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString(_keyUserId) ?? '',
      'name': prefs.getString(_keyUserName) ?? 'Guest User',
      'email': prefs.getString(_keyUserEmail) ?? 'user@example.com',
      'mobile': prefs.getString(_keyUserMobile) ?? '+91 XXXXX XXXXX',
    };
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final user = data['user'] as Map<String, dynamic>? ?? {};

    await prefs.setString(_keyToken, data['token']?.toString() ?? '');
    await prefs.setString(_keyUserId, user['id']?.toString() ?? '');
    await prefs.setString(_keyUserName, user['name']?.toString() ?? '');
    await prefs.setString(_keyUserEmail, user['email']?.toString() ?? '');
    await prefs.setString(
      _keyUserMobile,
      user['mobile_number']?.toString() ?? user['mobile']?.toString() ?? '',
    );
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserMobile);
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  Future<Map<String, dynamic>> registerOnly({
    required String name,
    required String email,
    required String mobileNumber,
    required String password,
    required String confirmPassword,
  }) async {
    final result = await _client.post(
      ApiConfig.authRegister,
      body: {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'mobile_number': mobileNumber.trim(),
        'password': password,
        'confirmPassword': confirmPassword,
      },
    );
    return result;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String mobileNumber,
    required String password,
    required String confirmPassword,
  }) async {
    final result = await registerOnly(
      name: name,
      email: email,
      mobileNumber: mobileNumber,
      password: password,
      confirmPassword: confirmPassword,
    );
    await _saveAuthData(result);
    return result;
  }

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final trimmed = identifier.trim();
    final result = await _client.post(
      ApiConfig.authLogin,
      body: {
        'email': trimmed,
        'password': password,
      },
    );
    await _saveAuthData(result);
    return result;
  }
}
