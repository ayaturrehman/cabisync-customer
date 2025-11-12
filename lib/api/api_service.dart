// lib/api/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiService {
  static const String baseUrl = AppConfig.apiBaseUrl;

  // Email-based authentication
  static Future<Map<String, dynamic>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(
              'https://app.cabisync.com/api/login/eyJpdiI6IlY2RDRNZ1gwclNlM3V2cmtWZGcyZVE9PSIsInZhbHVlIjoiOEJCZlRhWTFJZnEybjJrcUQzM1ZrZz09IiwibWFjIjoiN2M1MGE3ZDkzMjFjYjcxM2RmNWU2ZmM3N2YxZGNlOTY5YjVhYjhkZjJmZGMzZGIxNmNjYTY3MDdkNmE1MTAzYyIsInRhZyI6IiJ9',
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Connection timeout. Please check your internet connection.',
              );
            },
          );

      print('Login Response Status: ${response.statusCode}');
      print('Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      print('Login Exception: $e');
      throw Exception('Login error: $e');
    }
  }

  // Register with email
  static Future<Map<String, dynamic>> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  // Verify email (if needed for email verification flow)
  static Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String token,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/verify-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'token': token}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Email verification failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Email verification error: $e');
    }
  }

  // Request password reset
  static Future<Map<String, dynamic>> requestPasswordReset({
    required String email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/forgot-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Password reset request failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Password reset error: $e');
    }
  }

  // Reset password with token
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'token': token,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Password reset failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Password reset error: $e');
    }
  }
}
