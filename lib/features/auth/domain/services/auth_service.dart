import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:cat_hotel_pos/features/auth/domain/entities/user.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/user_service.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/audit_service.dart';

class AuthService {
  final UserService _userService;
  final AuditService _auditService;
  
  // In-memory session storage (in production, use Redis or database)
  static final Map<String, Map<String, dynamic>> _sessions = {};
  static final Map<String, DateTime> _refreshTokens = {};
  
  // JWT configuration
  static const String _jwtSecret = 'your-super-secret-jwt-key-here-change-in-production';
  static const Duration _accessTokenExpiry = Duration(minutes: 15);
  static const Duration _refreshTokenExpiry = Duration(days: 7);
  
  AuthService(this._userService, this._auditService);

  /// Verify password for a user (for setup wizard)
  Future<bool> verifyPassword(String username, String password) async {
    try {
      final user = await _userService.getUserByUsername(username);
      if (user == null) return false;
      
      return _verifyPassword(password, user.passwordHash ?? '', user.salt ?? '');
    } catch (e) {
      return false;
    }
  }

  /// Authenticate user with username and password
  Future<AuthResult> authenticateUser(String username, String password) async {
    try {
      // Get user by username
      print('AuthService: Attempting to get user: $username');
      final user = await _userService.getUserByUsername(username);
      print('AuthService: User found: ${user?.username ?? 'null'}');
      if (user == null) {
        return AuthResult.failure('Invalid username or password');
      }

      // Check if user is active
      if (!user.isActive) {
        return AuthResult.failure('Account is deactivated');
      }

      // Check if user is locked out
      if (user.lockoutUntil != null && DateTime.now().isBefore(user.lockoutUntil!)) {
        return AuthResult.failure('Account is temporarily locked. Try again later.');
      }

      // Verify password
      print('AuthService: Verifying password for user: ${user.username}');
      print('AuthService: Stored hash: ${user.passwordHash}');
      print('AuthService: Stored salt: ${user.salt}');
      if (!_verifyPassword(password, user.passwordHash ?? '', user.salt ?? '')) {
        // Increment failed login attempts
          final updatedUser = user.copyWith(
            failedLoginAttempts: (user.failedLoginAttempts ?? 0) + 1,
            lockoutUntil: _shouldLockAccount(user.failedLoginAttempts ?? 0) 
                ? DateTime.now().add(const Duration(minutes: 30))
                : null,
          );
          await _userService.updateUser(
            userId: user.id,
            notes: 'Failed login attempt. Lockout until: ${updatedUser.lockoutUntil}',
          );

          if (updatedUser.lockoutUntil != null) {
            return AuthResult.failure('Too many failed attempts. Account locked for 30 minutes.');
          }

          return AuthResult.failure('Invalid username or password');
      }

      // Reset failed login attempts on successful login
      if (user.failedLoginAttempts != null && user.failedLoginAttempts! > 0) {
        final updatedUser = user.copyWith(
          failedLoginAttempts: 0,
          lockoutUntil: null,
          lastLoginAt: DateTime.now(),
        );
        await _userService.updateUser(
          userId: user.id,
          notes: 'Login successful. Reset failed attempts.',
        );
      } else {
        // Update last login time
        final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
        await _userService.updateUser(
          userId: user.id,
          notes: 'Login successful.',
        );
      }

      // Generate tokens
      final accessToken = _generateAccessToken(user);
      final refreshToken = _generateRefreshToken(user.id);

      // Create session
      _createSession(user.id, accessToken, refreshToken);

      // Log successful login
      await _auditService.logLogin(
        userId: user.id,
        userEmail: user.email,
        userRole: user.role.name,
      );

      return AuthResult.success(
        user: user,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    } catch (e) {
      return AuthResult.failure('Authentication error: $e');
    }
  }

  /// Refresh access token using refresh token
  Future<AuthResult> refreshToken(String refreshToken) async {
    try {
      final userId = _validateRefreshToken(refreshToken);
      if (userId == null) {
        return AuthResult.failure('Invalid refresh token');
      }

      final user = await _userService.getUserById(userId);
      if (user == null || !user.isActive) {
        return AuthResult.failure('User not found or inactive');
      }

      // Generate new tokens
      final newAccessToken = _generateAccessToken(user);
      final newRefreshToken = _generateRefreshToken(user.id);

      // Update session
      _updateSession(userId, newAccessToken, newRefreshToken);

      return AuthResult.success(
        user: user,
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );
    } catch (e) {
      return AuthResult.failure('Token refresh error: $e');
    }
  }

  /// Logout user and invalidate tokens
  Future<void> logout(String userId, String accessToken) async {
    try {
      // Remove session
      _removeSession(userId);
      
      // Log logout
      final user = await _userService.getUserById(userId);
      if (user != null) {
        await _auditService.logLogout(
          userId: user.id,
          userEmail: user.email,
          userRole: user.role.name,
        );
      }
    } catch (e) {
      // Log error but don't throw
      print('Logout error: $e');
    }
  }

  /// Validate access token
  bool validateAccessToken(String accessToken) {
    try {
      final payload = _decodeJWT(accessToken);
      if (payload == null) return false;

      final expiry = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
      if (DateTime.now().isAfter(expiry)) return false;

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get user from access token
  Future<User?> getUserFromToken(String accessToken) async {
    try {
      final payload = _decodeJWT(accessToken);
      if (payload == null) return null;

      final userId = payload['sub'];
      if (userId == null) return null;

      return await _userService.getUserById(userId);
    } catch (e) {
      return null;
    }
  }

  /// Change user password
  Future<bool> changePassword(String userId, String currentPassword, String newPassword) async {
    try {
      final user = await _userService.getUserById(userId);
      if (user == null) return false;

      // Verify current password
      if (!_verifyPassword(currentPassword, user.passwordHash ?? '', user.salt ?? '')) {
        return false;
      }

      // Hash new password
      final salt = _generateSalt();
      final hashedPassword = _hashPassword(newPassword, salt);

      // Update user
      final updatedUser = user.copyWith(
        passwordHash: hashedPassword,
        salt: salt,
        lastPasswordChange: DateTime.now(),
      );

      await _userService.updateUser(
        userId: user.id,
        notes: 'Password changed successfully.',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reset password (forgot password)
  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      // In a real application, you would:
      // 1. Verify the reset token
      // 2. Check if the reset token is expired
      // 3. Update the password
      
      // For now, we'll just update the password if the user exists
      final user = await _userService.getUserByEmail(email);
      if (user == null) return false;

      final salt = _generateSalt();
      final hashedPassword = _hashPassword(newPassword, salt);

      final updatedUser = user.copyWith(
        passwordHash: hashedPassword,
        salt: salt,
        lastPasswordChange: DateTime.now(),
        failedLoginAttempts: 0,
        lockoutUntil: null,
      );

      await _userService.updateUser(
        userId: user.id,
        notes: 'Password reset successfully.',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Generate password hash
  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verify password
  bool _verifyPassword(String password, String storedHash, String storedSalt) {
    final hash = _hashPassword(password, storedSalt);
    print('AuthService: Password: $password, Salt: $storedSalt');
    print('AuthService: Generated hash: $hash');
    print('AuthService: Stored hash: $storedHash');
    print('AuthService: Hash match: ${hash == storedHash}');
    return hash == storedHash;
  }

  /// Generate random salt
  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Check if account should be locked
  bool _shouldLockAccount(int failedAttempts) {
    return failedAttempts >= 5; // Lock after 5 failed attempts
  }

  /// Generate JWT access token
  String _generateAccessToken(User user) {
    final now = DateTime.now();
    final expiry = now.add(_accessTokenExpiry);
    
    final payload = {
      'sub': user.id,
      'username': user.username,
      'email': user.email,
      'role': user.role.name,
      'iat': now.millisecondsSinceEpoch ~/ 1000,
      'exp': expiry.millisecondsSinceEpoch ~/ 1000,
    };

    return _encodeJWT(payload);
  }

  /// Generate refresh token
  String _generateRefreshToken(String userId) {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    final token = base64Url.encode(bytes);
    
    _refreshTokens[token] = DateTime.now().add(_refreshTokenExpiry);
    
    return token;
  }

  /// Validate refresh token
  String? _validateRefreshToken(String refreshToken) {
    final expiry = _refreshTokens[refreshToken];
    if (expiry == null || DateTime.now().isAfter(expiry)) {
      _refreshTokens.remove(refreshToken);
      return null;
    }
    return _getUserIdFromRefreshToken(refreshToken);
  }

  /// Get user ID from refresh token (simplified implementation)
  String? _getUserIdFromRefreshToken(String refreshToken) {
    // In a real implementation, you would decode the refresh token
    // For now, we'll use a simple mapping (in production, use proper JWT)
    return _sessions.entries
        .firstWhere((entry) => entry.value['refreshToken'] == refreshToken)
        .key;
  }

  /// Create user session
  void _createSession(String userId, String accessToken, String refreshToken) {
    _sessions[userId] = {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'createdAt': DateTime.now(),
    };
  }

  /// Update user session
  void _updateSession(String userId, String accessToken, String refreshToken) {
    if (_sessions.containsKey(userId)) {
      _sessions[userId]!.updateAll((key, value) {
        switch (key) {
          case 'accessToken':
            return accessToken;
          case 'refreshToken':
            return refreshToken;
          case 'createdAt':
            return DateTime.now();
          default:
            return value;
        }
      });
    }
  }

  /// Remove user session
  void _removeSession(String userId) {
    _sessions.remove(userId);
  }

  /// Encode JWT (simplified implementation)
  String _encodeJWT(Map<String, dynamic> payload) {
    final header = base64Url.encode(utf8.encode(json.encode({'alg': 'HS256', 'typ': 'JWT'})));
    final payloadEncoded = base64Url.encode(utf8.encode(json.encode(payload)));
    
    // In production, use proper JWT library with HMAC signing
    return '$header.$payloadEncoded.signature';
  }

  /// Decode JWT (simplified implementation)
  Map<String, dynamic>? _decodeJWT(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = parts[1];
      final decoded = utf8.decode(base64Url.decode(payload));
      return json.decode(decoded) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Get active sessions count
  int get activeSessionsCount => _sessions.length;

  /// Get all active sessions
  Map<String, Map<String, dynamic>> get activeSessions => Map.unmodifiable(_sessions);

  /// Clear expired sessions
  void clearExpiredSessions() {
    final now = DateTime.now();
    _sessions.removeWhere((userId, session) {
      final createdAt = session['createdAt'] as DateTime;
      return now.difference(createdAt) > _accessTokenExpiry;
    });

    _refreshTokens.removeWhere((token, expiry) => now.isAfter(expiry));
  }
}

/// Result of authentication operations
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? accessToken;
  final String? refreshToken;
  final String? errorMessage;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.accessToken,
    this.refreshToken,
    this.errorMessage,
  });

  factory AuthResult.success({
    required User user,
    required String accessToken,
    required String refreshToken,
  }) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  factory AuthResult.failure(String errorMessage) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}
