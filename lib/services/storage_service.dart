import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  // Keys
  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserName = 'user_name';
  static const String _keyUserEmail = 'user_email';
  static const String _keyUserPhone = 'user_phone';
  static const String _keyUserCreatedAt = 'user_created_at';

  // Save authentication token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  // Get authentication token
  static Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  // Save user data
  static Future<void> saveUserData({
    required int id,
    required String name,
    required String email,
    String? phone,
    required DateTime createdAt,
  }) async {
    await _storage.write(key: _keyUserId, value: id.toString());
    await _storage.write(key: _keyUserName, value: name);
    await _storage.write(key: _keyUserEmail, value: email);
    if (phone != null) {
      await _storage.write(key: _keyUserPhone, value: phone);
    }
    await _storage.write(
      key: _keyUserCreatedAt,
      value: createdAt.toIso8601String(),
    );
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final id = await _storage.read(key: _keyUserId);
    if (id == null) return null;

    final name = await _storage.read(key: _keyUserName);
    final email = await _storage.read(key: _keyUserEmail);
    final phone = await _storage.read(key: _keyUserPhone);
    final createdAt = await _storage.read(key: _keyUserCreatedAt);

    if (name == null || email == null) return null;

    return {
      'id': int.parse(id),
      'name': name,
      'email': email,
      'phone': phone,
      'created_at': createdAt,
    };
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all stored data (logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // Clear specific key
  static Future<void> clearKey(String key) async {
    await _storage.delete(key: key);
  }
}
