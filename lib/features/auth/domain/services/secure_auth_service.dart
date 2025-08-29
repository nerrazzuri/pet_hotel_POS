import 'dart:convert';
import 'package:cat_hotel_pos/features/auth/domain/entities/user.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/password_service.dart';
import 'package:cat_hotel_pos/core/services/web_storage_service.dart';

/// Secure authentication service with proper password hashing and rate limiting
class SecureAuthService {
  static const int _maxFailedAttempts = 5;
  static const int _lockoutDurationMinutes = 30;
  
  /// Authenticate user with secure password verification and rate limiting
  static Future<SecureAuthResult> authenticateUser(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      return SecureAuthResult(success: false, error: 'Username and password cannot be empty');
    }

    try {
      // Simulate network delay for security (prevents timing attacks)
      await Future.delayed(const Duration(milliseconds: 500));
      
      final users = WebStorageService.getAllUsers();
      final userMap = users.firstWhere(
        (u) => u['username'] == username,
        orElse: () => <String, dynamic>{},
      );
      
      if (userMap.isEmpty) {
        // Still check password to prevent username enumeration
        PasswordService.createPasswordHash('dummy_password');
        return SecureAuthResult(success: false, error: 'Invalid credentials');
      }

      // Check if account is locked
      if (_isAccountLocked(userMap)) {
        return SecureAuthResult(success: false, error: 'Account temporarily locked due to multiple failed attempts');
      }

      // Check if account is active
      if (!userMap['isActive']) {
        return SecureAuthResult(success: false, error: 'Account is disabled');
      }

      // Verify password
      final storedPasswordHash = userMap['passwordHash'] as String;
      final isValidPassword = PasswordService.verifyPassword(password, storedPasswordHash);
      
      if (!isValidPassword) {
        await _recordFailedLoginAttempt(userMap);
        return SecureAuthResult(success: false, error: 'Invalid credentials');
      }

      // Password is valid, clear failed attempts and update last login
      await _recordSuccessfulLogin(userMap);
      
      final user = _mapToUser(userMap);
      return SecureAuthResult(success: true, user: user);
      
    } catch (e) {
      return SecureAuthResult(success: false, error: 'Authentication service error');
    }
  }

  /// Check if account is locked due to failed attempts
  static bool _isAccountLocked(Map<String, dynamic> userMap) {
    final failedAttempts = userMap['failedLoginAttempts'] as int? ?? 0;
    final lockoutUntilString = userMap['lockoutUntil'] as String?;
    
    if (failedAttempts < _maxFailedAttempts) {
      return false;
    }
    
    if (lockoutUntilString == null) {
      return false;
    }
    
    final lockoutUntil = DateTime.parse(lockoutUntilString);
    return DateTime.now().isBefore(lockoutUntil);
  }

  /// Record failed login attempt and implement lockout if needed
  static Future<void> _recordFailedLoginAttempt(Map<String, dynamic> userMap) async {
    final currentAttempts = userMap['failedLoginAttempts'] as int? ?? 0;
    final newAttempts = currentAttempts + 1;
    
    userMap['failedLoginAttempts'] = newAttempts;
    
    if (newAttempts >= _maxFailedAttempts) {
      final lockoutUntil = DateTime.now().add(Duration(minutes: _lockoutDurationMinutes));
      userMap['lockoutUntil'] = lockoutUntil.toIso8601String();
    }
    
    WebStorageService.saveUser(userMap);
  }

  /// Record successful login and clear failed attempts
  static Future<void> _recordSuccessfulLogin(Map<String, dynamic> userMap) async {
    userMap['failedLoginAttempts'] = 0;
    userMap['lockoutUntil'] = null;
    userMap['lastLoginAt'] = DateTime.now().toIso8601String();
    
    WebStorageService.saveUser(userMap);
  }

  /// Convert map to User entity
  static User _mapToUser(Map<String, dynamic> userMap) {
    return User(
      id: userMap['id'],
      username: userMap['username'],
      email: userMap['email'],
      fullName: userMap['fullName'],
      role: _parseUserRole(userMap['role']),
      permissions: _parsePermissions(userMap['permissions']),
      isActive: userMap['isActive'],
      lastLoginAt: DateTime.parse(userMap['lastLoginAt']),
      createdAt: DateTime.parse(userMap['createdAt']),
      phoneNumber: userMap['phoneNumber'],
      profileImageUrl: userMap['profileImageUrl'],
      customPermissions: userMap['customPermissions'] != null 
          ? Map<String, bool>.from(userMap['customPermissions'])
          : null,
      status: _parseUserStatus(userMap['status']),
      location: userMap['location'],
      allowedShifts: userMap['allowedShifts'] != null 
          ? List<String>.from(userMap['allowedShifts'])
          : null,
      timeBasedPermissions: userMap['timeBasedPermissions'] != null
          ? Map<String, Map<String, dynamic>>.from(userMap['timeBasedPermissions'])
          : null,
      managerId: userMap['managerId'],
      subordinateIds: userMap['subordinateIds'] != null
          ? List<String>.from(userMap['subordinateIds'])
          : null,
      department: userMap['department'],
      position: userMap['position'],
      hireDate: userMap['hireDate'] != null 
          ? DateTime.parse(userMap['hireDate'])
          : null,
      passwordHash: userMap['passwordHash'],
      lastPasswordChange: userMap['lastPasswordChange'] != null
          ? DateTime.parse(userMap['lastPasswordChange'])
          : null,
      failedLoginAttempts: userMap['failedLoginAttempts'],
      lockoutUntil: userMap['lockoutUntil'] != null
          ? DateTime.parse(userMap['lockoutUntil'])
          : null,
      preferences: userMap['preferences'],
      notes: userMap['notes'],
    );
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

  /// Parse user status from string
  static UserStatus _parseUserStatus(String? statusString) {
    if (statusString == null) return UserStatus.active;
    
    switch (statusString) {
      case 'active':
        return UserStatus.active;
      case 'inactive':
        return UserStatus.inactive;
      case 'suspended':
        return UserStatus.suspended;
      case 'terminated':
        return UserStatus.terminated;
      default:
        return UserStatus.active;
    }
  }

  /// Parse permissions from JSON string
  static Map<String, bool> _parsePermissions(String permissionsJson) {
    try {
      final decoded = jsonDecode(permissionsJson);
      return Map<String, bool>.from(decoded);
    } catch (e) {
      return <String, bool>{};
    }
  }

  /// Get user by username
  static Future<User?> getUserByUsername(String username) async {
    try {
      final users = WebStorageService.getAllUsers();
      final userMap = users.firstWhere(
        (u) => u['username'] == username,
        orElse: () => <String, dynamic>{},
      );
      
      if (userMap.isEmpty) return null;
      
      return _mapToUser(userMap);
    } catch (e) {
      return null;
    }
  }

  /// Get user by ID
  static Future<User?> getUserById(String id) async {
    try {
      final users = WebStorageService.getAllUsers();
      final userMap = users.firstWhere(
        (u) => u['id'] == id,
        orElse: () => <String, dynamic>{},
      );
      
      if (userMap.isEmpty) return null;
      
      return _mapToUser(userMap);
    } catch (e) {
      return null;
    }
  }

  /// Get all users
  static Future<List<User>> getAllUsers() async {
    try {
      final users = WebStorageService.getAllUsers();
      return users.map((userMap) => _mapToUser(userMap)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Create new user with secure password
  static Future<SecureAuthResult> createUser({
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
    try {
      // Validate password strength
      if (!PasswordService.isPasswordSecure(password)) {
        return SecureAuthResult(
          success: false, 
          error: 'Password must be at least 8 characters with uppercase, lowercase, digit, and special character'
        );
      }

      // Check if username already exists
      final existingUser = await getUserByUsername(username);
      if (existingUser != null) {
        return SecureAuthResult(success: false, error: 'Username already exists');
      }

      // Create secure password hash
      final passwordHash = PasswordService.createPasswordHash(password);
      final now = DateTime.now();
      
      final userMap = {
        'id': username, // Use username as ID for simplicity
        'username': username,
        'email': email,
        'fullName': fullName,
        'role': role.toString().split('.').last,
        'permissions': jsonEncode(permissions),
        'isActive': true,
        'status': 'active',
        'department': department,
        'position': position,
        'hireDate': now.toIso8601String(),
        'passwordHash': passwordHash,
        'createdAt': now.toIso8601String(),
        'lastLoginAt': now.toIso8601String(),
        'lastPasswordChange': now.toIso8601String(),
        'failedLoginAttempts': 0,
        'lockoutUntil': null,
        'phoneNumber': phoneNumber,
        'managerId': managerId,
        'subordinateIds': subordinateIds,
      };

      WebStorageService.saveUser(userMap);
      
      final user = _mapToUser(userMap);
      return SecureAuthResult(success: true, user: user);
      
    } catch (e) {
      return SecureAuthResult(success: false, error: 'Failed to create user');
    }
  }

  /// Change user password
  static Future<SecureAuthResult> changePassword({
    required String username,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Validate new password strength
      if (!PasswordService.isPasswordSecure(newPassword)) {
        return SecureAuthResult(
          success: false, 
          error: 'New password must be at least 8 characters with uppercase, lowercase, digit, and special character'
        );
      }

      // Authenticate with current password
      final authResult = await authenticateUser(username, currentPassword);
      if (!authResult.success) {
        return SecureAuthResult(success: false, error: 'Current password is incorrect');
      }

      // Update password
      final users = WebStorageService.getAllUsers();
      final userMap = users.firstWhere(
        (u) => u['username'] == username,
        orElse: () => <String, dynamic>{},
      );
      
      if (userMap.isEmpty) {
        return SecureAuthResult(success: false, error: 'User not found');
      }

      final newPasswordHash = PasswordService.createPasswordHash(newPassword);
      userMap['passwordHash'] = newPasswordHash;
      userMap['lastPasswordChange'] = DateTime.now().toIso8601String();
      
      WebStorageService.saveUser(userMap);
      
      return SecureAuthResult(success: true, message: 'Password changed successfully');
      
    } catch (e) {
      return SecureAuthResult(success: false, error: 'Failed to change password');
    }
  }

  /// Unlock user account (admin function)
  static Future<SecureAuthResult> unlockAccount(String username) async {
    try {
      final users = WebStorageService.getAllUsers();
      final userMap = users.firstWhere(
        (u) => u['username'] == username,
        orElse: () => <String, dynamic>{},
      );
      
      if (userMap.isEmpty) {
        return SecureAuthResult(success: false, error: 'User not found');
      }

      userMap['failedLoginAttempts'] = 0;
      userMap['lockoutUntil'] = null;
      
      WebStorageService.saveUser(userMap);
      
      return SecureAuthResult(success: true, message: 'Account unlocked successfully');
      
    } catch (e) {
      return SecureAuthResult(success: false, error: 'Failed to unlock account');
    }
  }
}

/// Secure authentication result class
class SecureAuthResult {
  final bool success;
  final User? user;
  final String? error;
  final String? message;

  SecureAuthResult({
    required this.success,
    this.user,
    this.error,
    this.message,
  });

  bool get isSuccess => success;
  bool get hasError => error != null;
}