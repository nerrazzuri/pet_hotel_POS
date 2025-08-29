import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:cat_hotel_pos/features/auth/domain/entities/user.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/secure_storage_service.dart';

/// Secure session management service
class SessionService {
  static const String _sessionTokenKey = 'session_token';
  static const String _sessionUserKey = 'session_user';
  static const String _sessionExpiryKey = 'session_expiry';
  static const String _sessionCreatedKey = 'session_created';
  static const String _refreshTokenKey = 'refresh_token';
  
  // Session configuration
  static const int _sessionDurationMinutes = 60; // 1 hour
  static const int _refreshTokenDurationDays = 30; // 30 days
  static const int _maxSessions = 5; // Max concurrent sessions per user
  static const int _sessionWarningMinutes = 10; // Warning before expiry
  
  /// Generate secure session token
  static String _generateSecureToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64.encode(bytes);
  }

  /// Generate session hash for server-side validation
  static String _generateSessionHash(String token, String userId, DateTime created) {
    final data = '$token$userId${created.millisecondsSinceEpoch}';
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Create new session for authenticated user
  static Future<SessionResult> createSession(User user) async {
    try {
      final now = DateTime.now();
      final expiryTime = now.add(Duration(minutes: _sessionDurationMinutes));
      final refreshExpiryTime = now.add(Duration(days: _refreshTokenDurationDays));
      
      // Generate tokens
      final sessionToken = _generateSecureToken();
      final refreshToken = _generateSecureToken();
      
      // Create session hash for validation
      final sessionHash = _generateSessionHash(sessionToken, user.id, now);
      
      // Prepare session data
      final sessionData = {
        'token': sessionToken,
        'userId': user.id,
        'username': user.username,
        'fullName': user.fullName,
        'role': user.role.toString().split('.').last,
        'permissions': user.permissions,
        'createdAt': now.toIso8601String(),
        'expiresAt': expiryTime.toIso8601String(),
        'refreshToken': refreshToken,
        'refreshExpiresAt': refreshExpiryTime.toIso8601String(),
        'sessionHash': sessionHash,
        'isActive': true,
      };

      // Store session securely
      await SecureStorageService.write(_sessionTokenKey, sessionToken);
      await SecureStorageService.write(_sessionUserKey, jsonEncode(sessionData));
      await SecureStorageService.write(_sessionExpiryKey, expiryTime.toIso8601String());
      await SecureStorageService.write(_sessionCreatedKey, now.toIso8601String());
      await SecureStorageService.write(_refreshTokenKey, refreshToken);

      return SessionResult(
        success: true,
        sessionToken: sessionToken,
        refreshToken: refreshToken,
        expiresAt: expiryTime,
        user: user,
      );
      
    } catch (e) {
      return SessionResult(
        success: false,
        error: 'Failed to create session: ${e.toString()}',
      );
    }
  }

  /// Validate current session
  static Future<SessionValidationResult> validateSession() async {
    try {
      final sessionToken = await SecureStorageService.read(_sessionTokenKey);
      final sessionDataJson = await SecureStorageService.read(_sessionUserKey);
      final expiryString = await SecureStorageService.read(_sessionExpiryKey);
      
      if (sessionToken == null || sessionDataJson == null || expiryString == null) {
        return SessionValidationResult(
          isValid: false,
          reason: 'No active session found',
        );
      }

      final sessionData = jsonDecode(sessionDataJson);
      final expiryTime = DateTime.parse(expiryString);
      final now = DateTime.now();

      // Check if session is expired
      if (now.isAfter(expiryTime)) {
        await clearSession();
        return SessionValidationResult(
          isValid: false,
          reason: 'Session expired',
          needsRefresh: true,
        );
      }

      // Check if session is about to expire (show warning)
      final warningTime = expiryTime.subtract(Duration(minutes: _sessionWarningMinutes));
      final showWarning = now.isAfter(warningTime);

      // Validate session hash
      final storedHash = sessionData['sessionHash'];
      final createdAt = DateTime.parse(sessionData['createdAt']);
      final expectedHash = _generateSessionHash(sessionToken, sessionData['userId'], createdAt);
      
      if (storedHash != expectedHash) {
        await clearSession();
        return SessionValidationResult(
          isValid: false,
          reason: 'Session integrity check failed',
        );
      }

      // Check if session is marked as active
      if (!sessionData['isActive']) {
        await clearSession();
        return SessionValidationResult(
          isValid: false,
          reason: 'Session has been deactivated',
        );
      }

      return SessionValidationResult(
        isValid: true,
        sessionData: sessionData,
        expiresAt: expiryTime,
        showExpiryWarning: showWarning,
      );
      
    } catch (e) {
      await clearSession();
      return SessionValidationResult(
        isValid: false,
        reason: 'Session validation error: ${e.toString()}',
      );
    }
  }

  /// Refresh session using refresh token
  static Future<SessionResult> refreshSession() async {
    try {
      final refreshToken = await SecureStorageService.read(_refreshTokenKey);
      final sessionDataJson = await SecureStorageService.read(_sessionUserKey);
      
      if (refreshToken == null || sessionDataJson == null) {
        return SessionResult(
          success: false,
          error: 'No refresh token available',
        );
      }

      final sessionData = jsonDecode(sessionDataJson);
      final refreshExpiryTime = DateTime.parse(sessionData['refreshExpiresAt']);
      final now = DateTime.now();

      // Check if refresh token is expired
      if (now.isAfter(refreshExpiryTime)) {
        await clearSession();
        return SessionResult(
          success: false,
          error: 'Refresh token expired',
          requiresLogin: true,
        );
      }

      // Validate stored refresh token
      if (sessionData['refreshToken'] != refreshToken) {
        await clearSession();
        return SessionResult(
          success: false,
          error: 'Invalid refresh token',
          requiresLogin: true,
        );
      }

      // Create new session with extended expiry
      final newExpiryTime = now.add(Duration(minutes: _sessionDurationMinutes));
      final newSessionToken = _generateSecureToken();
      final newSessionHash = _generateSessionHash(newSessionToken, sessionData['userId'], now);

      // Update session data
      sessionData['token'] = newSessionToken;
      sessionData['expiresAt'] = newExpiryTime.toIso8601String();
      sessionData['sessionHash'] = newSessionHash;
      sessionData['refreshedAt'] = now.toIso8601String();

      // Store updated session
      await SecureStorageService.write(_sessionTokenKey, newSessionToken);
      await SecureStorageService.write(_sessionUserKey, jsonEncode(sessionData));
      await SecureStorageService.write(_sessionExpiryKey, newExpiryTime.toIso8601String());

      // Reconstruct user from session data
      final user = User(
        id: sessionData['userId'],
        username: sessionData['username'],
        email: '', // Not stored in session for security
        fullName: sessionData['fullName'],
        role: _parseUserRole(sessionData['role']),
        permissions: Map<String, bool>.from(sessionData['permissions']),
        isActive: true,
        lastLoginAt: DateTime.parse(sessionData['createdAt']),
        createdAt: DateTime.parse(sessionData['createdAt']),
      );

      return SessionResult(
        success: true,
        sessionToken: newSessionToken,
        refreshToken: refreshToken,
        expiresAt: newExpiryTime,
        user: user,
      );
      
    } catch (e) {
      await clearSession();
      return SessionResult(
        success: false,
        error: 'Failed to refresh session: ${e.toString()}',
        requiresLogin: true,
      );
    }
  }

  /// Clear current session (logout)
  static Future<void> clearSession() async {
    try {
      await SecureStorageService.delete(_sessionTokenKey);
      await SecureStorageService.delete(_sessionUserKey);
      await SecureStorageService.delete(_sessionExpiryKey);
      await SecureStorageService.delete(_sessionCreatedKey);
      await SecureStorageService.delete(_refreshTokenKey);
    } catch (e) {
      // Log error but don't throw - clearing session should always succeed
      print('Error clearing session: $e');
    }
  }

  /// Get current user from session
  static Future<User?> getCurrentUser() async {
    try {
      final validation = await validateSession();
      if (!validation.isValid || validation.sessionData == null) {
        return null;
      }

      final sessionData = validation.sessionData!;
      return User(
        id: sessionData['userId'],
        username: sessionData['username'],
        email: '', // Not stored in session
        fullName: sessionData['fullName'],
        role: _parseUserRole(sessionData['role']),
        permissions: Map<String, bool>.from(sessionData['permissions']),
        isActive: true,
        lastLoginAt: DateTime.parse(sessionData['createdAt']),
        createdAt: DateTime.parse(sessionData['createdAt']),
      );
      
    } catch (e) {
      return null;
    }
  }

  /// Extend current session (activity-based extension)
  static Future<void> extendSession() async {
    try {
      final validation = await validateSession();
      if (!validation.isValid) return;

      final now = DateTime.now();
      final newExpiryTime = now.add(Duration(minutes: _sessionDurationMinutes));
      
      await SecureStorageService.write(_sessionExpiryKey, newExpiryTime.toIso8601String());
      
      // Update session data
      if (validation.sessionData != null) {
        final sessionData = Map<String, dynamic>.from(validation.sessionData!);
        sessionData['expiresAt'] = newExpiryTime.toIso8601String();
        sessionData['lastActivity'] = now.toIso8601String();
        
        await SecureStorageService.write(_sessionUserKey, jsonEncode(sessionData));
      }
      
    } catch (e) {
      // Log error but don't throw
      print('Error extending session: $e');
    }
  }

  /// Get session info for UI display
  static Future<SessionInfo?> getSessionInfo() async {
    try {
      final validation = await validateSession();
      if (!validation.isValid) return null;

      return SessionInfo(
        isValid: true,
        expiresAt: validation.expiresAt!,
        showExpiryWarning: validation.showExpiryWarning,
        userName: validation.sessionData!['fullName'],
        userRole: validation.sessionData!['role'],
      );
      
    } catch (e) {
      return null;
    }
  }

  /// Check if user has specific permission
  static Future<bool> hasPermission(String permission) async {
    try {
      final user = await getCurrentUser();
      if (user == null) return false;
      
      return user.permissions[permission] == true || user.permissions['*'] == true;
    } catch (e) {
      return false;
    }
  }

  /// Parse user role from string
  static UserRole _parseUserRole(String roleString) {
    switch (roleString) {
      case 'staff':
        return UserRole.staff;
      case 'manager':
        return UserRole.manager;
      case 'owner':
        return UserRole.owner;
      case 'administrator':
        return UserRole.administrator;
      default:
        return UserRole.staff;
    }
  }
}

/// Session creation result
class SessionResult {
  final bool success;
  final String? sessionToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final User? user;
  final String? error;
  final bool requiresLogin;

  SessionResult({
    required this.success,
    this.sessionToken,
    this.refreshToken,
    this.expiresAt,
    this.user,
    this.error,
    this.requiresLogin = false,
  });
}

/// Session validation result
class SessionValidationResult {
  final bool isValid;
  final String? reason;
  final Map<String, dynamic>? sessionData;
  final DateTime? expiresAt;
  final bool showExpiryWarning;
  final bool needsRefresh;

  SessionValidationResult({
    required this.isValid,
    this.reason,
    this.sessionData,
    this.expiresAt,
    this.showExpiryWarning = false,
    this.needsRefresh = false,
  });
}

/// Session information for UI
class SessionInfo {
  final bool isValid;
  final DateTime expiresAt;
  final bool showExpiryWarning;
  final String userName;
  final String userRole;

  SessionInfo({
    required this.isValid,
    required this.expiresAt,
    required this.showExpiryWarning,
    required this.userName,
    required this.userRole,
  });

  /// Time until session expires
  Duration get timeUntilExpiry => expiresAt.difference(DateTime.now());
  
  /// Minutes until session expires
  int get minutesUntilExpiry => timeUntilExpiry.inMinutes;
  
  /// Whether session expires within warning period
  bool get isNearExpiry => minutesUntilExpiry <= 10;
}