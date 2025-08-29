import 'package:flutter/foundation.dart';
import 'package:cat_hotel_pos/features/auth/domain/entities/user.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/secure_auth_service.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/simple_auth_service.dart';

/// Platform-aware authentication service that uses the appropriate service based on platform
class PlatformAuthService {
  /// Authenticate user with platform-appropriate service
  static Future<PlatformAuthResult> authenticateUser(String username, String password) async {
    if (kIsWeb) {
      // Use secure auth service for web
      final result = await SecureAuthService.authenticateUser(username, password);
      return PlatformAuthResult(
        success: result.success,
        user: result.user,
        error: result.error,
        message: result.message,
      );
    } else {
      // Use simple auth service for desktop
      try {
        final user = await SimpleAuthService.authenticateUser(username, password);
        if (user != null) {
          return PlatformAuthResult(
            success: true,
            user: user,
          );
        } else {
          return PlatformAuthResult(
            success: false,
            error: 'Invalid credentials',
          );
        }
      } catch (e) {
        return PlatformAuthResult(
          success: false,
          error: 'Authentication error: ${e.toString()}',
        );
      }
    }
  }

  /// Get user by username
  static Future<User?> getUserByUsername(String username) async {
    if (kIsWeb) {
      return await SecureAuthService.getUserByUsername(username);
    } else {
      return await SimpleAuthService.getUserByUsername(username);
    }
  }

  /// Get user by ID
  static Future<User?> getUserById(String id) async {
    if (kIsWeb) {
      return await SecureAuthService.getUserById(id);
    } else {
      return await SimpleAuthService.getUserById(id);
    }
  }

  /// Get all users
  static Future<List<User>> getAllUsers() async {
    if (kIsWeb) {
      return await SecureAuthService.getAllUsers();
    } else {
      return await SimpleAuthService.getAllUsers();
    }
  }

  /// Create new user (web only, desktop uses predefined users)
  static Future<PlatformAuthResult> createUser({
    required String username,
    required String email,
    required String fullName,
    required String password,
    required UserRole role,
    required Map<String, bool> permissions,
    String? phoneNumber,
    String? department,
    String? position,
    String? managerId,
    List<String>? subordinateIds,
  }) async {
    if (kIsWeb) {
      final result = await SecureAuthService.createUser(
        username: username,
        email: email,
        fullName: fullName,
        password: password,
        role: role,
        permissions: permissions,
        phoneNumber: phoneNumber,
        department: department,
        position: position,
        managerId: managerId,
        subordinateIds: subordinateIds,
      );
      return PlatformAuthResult(
        success: result.success,
        user: result.user,
        error: result.error,
        message: result.message,
      );
    } else {
      return PlatformAuthResult(
        success: false,
        error: 'User creation not supported on desktop platform',
      );
    }
  }

  /// Change password (web only)
  static Future<PlatformAuthResult> changePassword({
    required String username,
    required String currentPassword,
    required String newPassword,
  }) async {
    if (kIsWeb) {
      final result = await SecureAuthService.changePassword(
        username: username,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return PlatformAuthResult(
        success: result.success,
        user: result.user,
        error: result.error,
        message: result.message,
      );
    } else {
      return PlatformAuthResult(
        success: false,
        error: 'Password change not supported on desktop platform',
      );
    }
  }

  /// Unlock account (web only)
  static Future<PlatformAuthResult> unlockAccount(String username) async {
    if (kIsWeb) {
      final result = await SecureAuthService.unlockAccount(username);
      return PlatformAuthResult(
        success: result.success,
        user: result.user,
        error: result.error,
        message: result.message,
      );
    } else {
      return PlatformAuthResult(
        success: false,
        error: 'Account unlock not supported on desktop platform',
      );
    }
  }

  /// Check if platform supports advanced security features
  static bool get supportsAdvancedSecurity => kIsWeb;

  /// Get platform name for debugging
  static String get platformName => kIsWeb ? 'Web' : 'Desktop';
}

/// Platform authentication result
class PlatformAuthResult {
  final bool success;
  final User? user;
  final String? error;
  final String? message;

  PlatformAuthResult({
    required this.success,
    this.user,
    this.error,
    this.message,
  });

  bool get isSuccess => success;
  bool get hasError => error != null;
}