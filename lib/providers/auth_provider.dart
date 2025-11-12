// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../api/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null && _token != null;

  // Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.loginWithEmail(
        email: email,
        password: password,
      );

      // Parse response based on actual API structure
      // Response: {"user": {...}, "token": "..."}
      _token = response['token'];
      final userData = response['user'];

      if (_token == null || userData == null) {
        throw Exception('Invalid response from server');
      }

      _user = User(
        id: userData['id'] ?? 0,
        name: userData['name'] ?? '',
        email: userData['email'] ?? email,
        phone: null, // Phone not provided in response
        createdAt:
            userData['created_at'] != null
                ? DateTime.parse(userData['created_at'])
                : DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Register with email
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiService.registerWithEmail(
        name: name,
        email: email,
        password: password,
      );

      // Parse response based on actual API structure
      _token = response['token'];
      final userData = response['user'];

      if (_token == null || userData == null) {
        throw Exception('Invalid response from server');
      }

      _user = User(
        id: userData['id'] ?? 0,
        name: userData['name'] ?? name,
        email: userData['email'] ?? email,
        phone: null, // Phone not provided in response
        createdAt:
            userData['created_at'] != null
                ? DateTime.parse(userData['created_at'])
                : DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Request password reset
  Future<bool> requestPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.requestPasswordReset(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Reset password with token
  Future<bool> resetPassword(
    String email,
    String token,
    String newPassword,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await ApiService.resetPassword(
        email: email,
        token: token,
        newPassword: newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _user = null;
    _token = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
