import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for securely storing and retrieving authentication data
class SecureStorageService {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userDataKey = 'user_data';
  static const String _lastLoginKey = 'last_login';
  static const String _rememberMeKey = 'remember_me';
  static const String _biometricEnabledKey = 'biometric_enabled';
  
  // Secure storage for sensitive data (Android/iOS)
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  
  // Shared preferences for non-sensitive data
  static SharedPreferences? _prefs;
  
  /// Initialize the service
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  /// Store access token securely
  static Future<void> storeAccessToken(String token) async {
    if (kIsWeb) {
      // For web, use localStorage with encryption (simplified)
      _prefs?.setString(_accessTokenKey, _encryptForWeb(token));
    } else {
      // For mobile/desktop, use secure storage
      await _secureStorage.write(key: _accessTokenKey, value: token);
    }
  }
  
  /// Retrieve access token
  static Future<String?> getAccessToken() async {
    if (kIsWeb) {
      final encrypted = _prefs?.getString(_accessTokenKey);
      return encrypted != null ? _decryptForWeb(encrypted) : null;
    } else {
      return await _secureStorage.read(key: _accessTokenKey);
    }
  }
  
  /// Store refresh token securely
  static Future<void> storeRefreshToken(String token) async {
    if (kIsWeb) {
      _prefs?.setString(_refreshTokenKey, _encryptForWeb(token));
    } else {
      await _secureStorage.write(key: _refreshTokenKey, value: token);
    }
  }
  
  /// Retrieve refresh token
  static Future<String?> getRefreshToken() async {
    if (kIsWeb) {
      final encrypted = _prefs?.getString(_refreshTokenKey);
      return encrypted != null ? _decryptForWeb(encrypted) : null;
    } else {
      return await _secureStorage.read(key: _refreshTokenKey);
    }
  }
  
  /// Store user data (non-sensitive)
  static Future<void> storeUserData(Map<String, dynamic> userData) async {
    final jsonString = json.encode(userData);
    await _prefs?.setString(_userDataKey, jsonString);
  }
  
  /// Retrieve user data
  static Future<Map<String, dynamic>?> getUserData() async {
    final jsonString = _prefs?.getString(_userDataKey);
    if (jsonString != null) {
      try {
        return json.decode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        print('Error decoding user data: $e');
        return null;
      }
    }
    return null;
  }
  
  /// Store last login timestamp
  static Future<void> storeLastLogin(DateTime timestamp) async {
    await _prefs?.setString(_lastLoginKey, timestamp.toIso8601String());
  }
  
  /// Retrieve last login timestamp
  static Future<DateTime?> getLastLogin() async {
    final timestampString = _prefs?.getString(_lastLoginKey);
    if (timestampString != null) {
      try {
        return DateTime.parse(timestampString);
      } catch (e) {
        print('Error parsing last login timestamp: $e');
        return null;
      }
    }
    return null;
  }
  
  /// Store remember me preference
  static Future<void> setRememberMe(bool enabled) async {
    await _prefs?.setBool(_rememberMeKey, enabled);
  }
  
  /// Get remember me preference
  static bool getRememberMe() {
    return _prefs?.getBool(_rememberMeKey) ?? false;
  }
  
  /// Store biometric authentication preference
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs?.setBool(_biometricEnabledKey, enabled);
  }
  
  /// Get biometric authentication preference
  static bool getBiometricEnabled() {
    return _prefs?.getBool(_biometricEnabledKey) ?? false;
  }
  
  /// Clear all stored authentication data
  static Future<void> clearAll() async {
    if (kIsWeb) {
      _prefs?.remove(_accessTokenKey);
      _prefs?.remove(_refreshTokenKey);
      _prefs?.remove(_userDataKey);
      _prefs?.remove(_lastLoginKey);
      _prefs?.remove(_rememberMeKey);
      _prefs?.remove(_biometricEnabledKey);
    } else {
      await _secureStorage.deleteAll();
      _prefs?.clear();
    }
  }
  
  /// Clear only authentication tokens
  static Future<void> clearTokens() async {
    if (kIsWeb) {
      _prefs?.remove(_accessTokenKey);
      _prefs?.remove(_refreshTokenKey);
    } else {
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
    }
  }
  
  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
  
  /// Get stored credentials for auto-login
  static Future<Map<String, String>?> getStoredCredentials() async {
    if (!getRememberMe()) return null;
    
    final username = _prefs?.getString('username');
    final password = _prefs?.getString('password');
    
    if (username != null && password != null) {
      return {
        'username': username,
        'password': _decryptForWeb(password),
      };
    }
    
    return null;
  }
  
  /// Store credentials for auto-login (only if remember me is enabled)
  static Future<void> storeCredentials(String username, String password) async {
    if (getRememberMe()) {
      await _prefs?.setString('username', username);
      await _prefs?.setString('password', _encryptForWeb(password));
    }
  }
  
  /// Clear stored credentials
  static Future<void> clearCredentials() async {
    _prefs?.remove('username');
    _prefs?.remove('password');
  }
  
  /// Simple encryption for web storage (in production, use proper encryption)
  static String _encryptForWeb(String data) {
    // This is a simple obfuscation for demo purposes
    // In production, use proper encryption libraries
    final bytes = utf8.encode(data);
    final encoded = base64.encode(bytes);
    return encoded.split('').reversed.join();
  }
  
  /// Simple decryption for web storage
  static String _decryptForWeb(String encrypted) {
    try {
      final reversed = encrypted.split('').reversed.join();
      final bytes = base64.decode(reversed);
      return utf8.decode(bytes);
    } catch (e) {
      print('Error decrypting data: $e');
      return '';
    }
  }
  
  /// Check if secure storage is available
  static bool get isSecureStorageAvailable {
    return !kIsWeb;
  }
  
  /// Get storage type being used
  static String get storageType {
    return kIsWeb ? 'Web Storage (LocalStorage)' : 'Secure Storage';
  }
  
  /// Validate stored tokens
  static Future<bool> validateStoredTokens() async {
    try {
      final accessToken = await getAccessToken();
      final refreshToken = await getRefreshToken();
      
      if (accessToken == null || refreshToken == null) {
        return false;
      }
      
      // Basic validation - check if tokens are not empty
      return accessToken.isNotEmpty && refreshToken.isNotEmpty;
    } catch (e) {
      print('Error validating stored tokens: $e');
      return false;
    }
  }
  
  /// Get storage statistics
  static Future<Map<String, dynamic>> getStorageStats() async {
    final loggedInStatus = await isLoggedIn();
    final lastLogin = await getLastLogin();
    final rememberMe = getRememberMe();
    final biometricEnabled = getBiometricEnabled();
    
    return {
      'isLoggedIn': loggedInStatus,
      'lastLogin': lastLogin?.toIso8601String(),
      'rememberMe': rememberMe,
      'biometricEnabled': biometricEnabled,
      'storageType': storageType,
      'secureStorageAvailable': isSecureStorageAvailable,
    };
  }
}
