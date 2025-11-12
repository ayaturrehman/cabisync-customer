import '../models/user.dart';
import 'api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class AuthService {
  final ApiService _apiService;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  AuthService(this._apiService);

  Future<void> sendOTP(String phone) async {
    try {
      await _apiService.post(
        '/auth/send-otp',
        data: {
          'phone': phone,
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<User> verifyOTP(String phone, String otp) async {
    try {
      final response = await _apiService.post(
        '/auth/verify-otp',
        data: {
          'phone': phone,
          'otp': otp,
        },
      );

      final data = response.data as Map<String, dynamic>;
      
      final token = data['token'] as String;
      await _apiService.saveToken(token);
      
      final userData = data['user'] as Map<String, dynamic>;
      await _storage.write(key: 'user_data', value: jsonEncode(userData));
      
      return User.fromJson(userData);
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final userDataStr = await _storage.read(key: 'user_data');
      if (userDataStr == null) return null;
      
      final userData = jsonDecode(userDataStr) as Map<String, dynamic>;
      return User.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  Future<User> getProfile() async {
    try {
      final response = await _apiService.get('/profile');
      final data = response.data as Map<String, dynamic>;
      
      await _storage.write(key: 'user_data', value: jsonEncode(data));
      
      return User.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateProfile({
    String? name,
    String? email,
  }) async {
    try {
      final response = await _apiService.put(
        '/profile',
        data: {
          if (name != null) 'name': name,
          if (email != null) 'email': email,
        },
      );

      final data = response.data as Map<String, dynamic>;
      await _storage.write(key: 'user_data', value: jsonEncode(data));
      
      return User.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post('/auth/logout');
    } catch (e) {
      print('Logout API error: $e');
    } finally {
      await _apiService.deleteToken();
      await _storage.delete(key: 'user_data');
    }
  }

  Future<bool> isAuthenticated() async {
    final token = await _apiService.getToken();
    return token != null;
  }
}
