import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cat_hotel_pos/features/auth/domain/entities/user.dart';
import 'package:cat_hotel_pos/core/services/web_storage_service.dart';

/// Web-compatible User DAO that works with both database and web storage
class WebUserDao {
  static bool get isWeb => kIsWeb;

  /// Get all users
  Future<List<User>> getAll() async {
    if (isWeb) {
      return _getAllFromWebStorage();
    } else {
      // This should not be called on non-web platforms
      throw UnsupportedError('WebUserDao.getAll() called on non-web platform');
    }
  }

  /// Get user by ID
  Future<User?> getById(String id) async {
    if (isWeb) {
      return _getByIdFromWebStorage(id);
    } else {
      throw UnsupportedError('WebUserDao.getById() called on non-web platform');
    }
  }

  /// Get user by username
  Future<User?> getByUsername(String username) async {
    if (isWeb) {
      return _getByUsernameFromWebStorage(username);
    } else {
      throw UnsupportedError('WebUserDao.getByUsername() called on non-web platform');
    }
  }

  /// Insert a new user
  Future<void> insert(User user) async {
    if (isWeb) {
      _insertToWebStorage(user);
    } else {
      throw UnsupportedError('WebUserDao.insert() called on non-web platform');
    }
  }

  /// Update an existing user
  Future<void> update(User user) async {
    if (isWeb) {
      _updateInWebStorage(user);
    } else {
      throw UnsupportedError('WebUserDao.update() called on non-web platform');
    }
  }

  /// Delete a user
  Future<void> delete(String id) async {
    if (isWeb) {
      _deleteFromWebStorage(id);
    } else {
      throw UnsupportedError('WebUserDao.delete() called on non-web platform');
    }
  }

  // Web storage implementation methods
  List<User> _getAllFromWebStorage() {
    final userData = WebStorageService.getAllUsers();
    return userData.map((data) => _mapFromStorage(data)).toList();
  }

  User? _getByIdFromWebStorage(String id) {
    final userData = WebStorageService.getAllUsers();
    final userMap = userData.firstWhere(
      (data) => data['id'] == id,
      orElse: () => <String, dynamic>{},
    );
    
    if (userMap.isEmpty) return null;
    return _mapFromStorage(userMap);
  }

  User? _getByUsernameFromWebStorage(String username) {
    final userData = WebStorageService.getAllUsers();
    final userMap = userData.firstWhere(
      (data) => data['username'] == username,
      orElse: () => <String, dynamic>{},
    );
    
    if (userMap.isEmpty) return null;
    return _mapFromStorage(userMap);
  }

  void _insertToWebStorage(User user) {
    final userData = WebStorageService.getAllUsers();
    userData.add(_mapToStorage(user));
    WebStorageService.saveUser(_mapToStorage(user));
  }

  void _updateInWebStorage(User user) {
    final userData = WebStorageService.getAllUsers();
    final index = userData.indexWhere((data) => data['id'] == user.id);
    if (index >= 0) {
      userData[index] = _mapToStorage(user);
      WebStorageService.saveUser(_mapToStorage(user));
    }
  }

  void _deleteFromWebStorage(String id) {
    final userData = WebStorageService.getAllUsers();
    userData.removeWhere((data) => data['id'] == id);
    // Re-save the updated list
    if (userData.isNotEmpty) {
      WebStorageService.saveUser(_mapToStorage(_mapFromStorage(userData.first)));
    }
  }

  // Mapping methods
  User _mapFromStorage(Map<String, dynamic> data) {
    return User(
      id: data['id'] ?? '',
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      role: _parseUserRole(data['role'] ?? 'staff'),
      permissions: _parsePermissions(data['permissions'] ?? '{}'),
      isActive: data['isActive'] ?? true,
      lastLoginAt: DateTime.parse(data['lastLoginAt'] ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(data['createdAt'] ?? DateTime.now().toIso8601String()),
      status: _parseUserStatus(data['status'] ?? 'active'),
      department: data['department'] ?? '',
      position: data['position'] ?? '',
      hireDate: data['hireDate'] != null 
          ? DateTime.parse(data['hireDate']) 
          : null,
      passwordHash: data['passwordHash'] ?? '',
      salt: data['salt'] ?? '',
    );
  }

  Map<String, dynamic> _mapToStorage(User user) {
    return {
      'id': user.id,
      'username': user.username,
      'email': user.email,
      'fullName': user.fullName,
      'role': user.role.name,
      'permissions': jsonEncode(user.permissions),
      'createdAt': user.createdAt.toIso8601String(),
      'lastLoginAt': user.lastLoginAt.toIso8601String(),
      'isActive': user.isActive,
      'status': user.status?.name ?? 'active',
      'department': user.department ?? '',
      'position': user.position ?? '',
      'hireDate': user.hireDate?.toIso8601String(),
      'passwordHash': user.passwordHash ?? '',
      'salt': user.salt ?? '',
    };
  }

  UserRole _parseUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'administrator':
        return UserRole.administrator;
      case 'owner':
        return UserRole.owner;
      case 'manager':
        return UserRole.manager;
      case 'staff':
      default:
        return UserRole.staff;
    }
  }

  UserStatus _parseUserStatus(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return UserStatus.active;
      case 'inactive':
        return UserStatus.inactive;
      case 'suspended':
        return UserStatus.suspended;
      default:
        return UserStatus.active;
    }
  }

  Map<String, bool> _parsePermissions(String permissionsJson) {
    try {
      final Map<String, dynamic> permissions = jsonDecode(permissionsJson);
      return permissions.map((key, value) => MapEntry(key, value as bool));
    } catch (e) {
      // Return default permissions if parsing fails
      return {
        'dashboard': true,
        'users': false,
        'customers': true,
        'bookings': true,
        'rooms': true,
        'pos': true,
        'reports': false,
      };
    }
  }
}
