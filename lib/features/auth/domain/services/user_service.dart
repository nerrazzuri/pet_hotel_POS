import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:cat_hotel_pos/features/auth/domain/entities/user.dart';
import 'package:cat_hotel_pos/features/auth/domain/entities/role.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/permission_service.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/audit_service.dart';
import 'package:cat_hotel_pos/features/auth/domain/entities/audit_log.dart';

import 'package:cat_hotel_pos/core/services/web_user_dao.dart';
import 'package:cat_hotel_pos/core/services/simple_user_dao.dart';
import 'package:cat_hotel_pos/core/services/web_storage_service.dart';
import 'package:flutter/foundation.dart';

class UserService {
  final PermissionService _permissionService;
  final AuditService _auditService;
  late final dynamic _userDao; // Can be UserDao or WebUserDao
  
  // In-memory cache synchronized with DB
  final Map<String, User> _users = {};
  final Map<String, Role> _roles = {};
  
  // Create a system user for audit logging
  late final User _systemUser;
  
  UserService(this._permissionService, this._auditService) {
    _initializeUserDao();
    _initializeSystemUser();
    _initializeDefaultData();
  }

  void _initializeUserDao() {
    if (kIsWeb) {
      _userDao = WebUserDao();
      // Initialize web storage and seed default data
      WebStorageService.initialize();
      WebStorageService.seedDefaultData();
    } else {
      // For Android, use a simple in-memory approach for now
      // This avoids the database issues while maintaining functionality
      _userDao = SimpleUserDao();
    }
  }
  
  void _initializeSystemUser() {
    _systemUser = User(
      id: 'system',
      username: 'system',
      email: 'system@cathotel.com',
      fullName: 'System',
      role: UserRole.administrator,
      permissions: _permissionService.getDefaultPermissions(UserRole.administrator),
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isActive: true,
      status: UserStatus.active,
    );
  }
  
  Future<void> _seedDefaultsIfEmpty() async {
    final existingUsers = await _userDao.getAll();
    if (existingUsers.isNotEmpty) return;

    final defaults = [
      User(
        id: 'admin',
        username: 'admin',
        email: 'admin@cathotel.com',
        fullName: 'System Administrator',
        role: UserRole.administrator,
        permissions: _permissionService.getDefaultPermissions(UserRole.administrator),
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isActive: true,
        status: UserStatus.active,
        department: 'IT',
        position: 'System Administrator',
        hireDate: DateTime.now(),
        // Default password: admin123
        passwordHash: _hashPassword('admin123', 'admin_salt_123'),
        salt: 'admin_salt_123',
      ),
      User(
        id: 'owner',
        username: 'owner',
        email: 'owner@cathotel.com',
        fullName: 'Business Owner',
        role: UserRole.owner,
        permissions: _permissionService.getDefaultPermissions(UserRole.owner),
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isActive: true,
        status: UserStatus.active,
        department: 'Management',
        position: 'Owner',
        hireDate: DateTime.now(),
        // Default password: owner123
        passwordHash: _hashPassword('owner123', 'owner_salt_123'),
        salt: 'owner_salt_123',
      ),
      User(
        id: 'manager',
        username: 'manager',
        email: 'manager@cathotel.com',
        fullName: 'General Manager',
        role: UserRole.manager,
        permissions: _permissionService.getDefaultPermissions(UserRole.manager),
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isActive: true,
        status: UserStatus.active,
        department: 'Operations',
        position: 'General Manager',
        hireDate: DateTime.now(),
        // Default password: manager123
        passwordHash: _hashPassword('manager123', 'manager_salt_123'),
        salt: 'manager_salt_123',
      ),
      User(
        id: 'staff',
        username: 'staff',
        email: 'staff@cathotel.com',
        fullName: 'Front Desk Staff',
        role: UserRole.staff,
        permissions: _permissionService.getDefaultPermissions(UserRole.staff),
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isActive: true,
        status: UserStatus.active,
        department: 'Front Desk',
        position: 'Customer Service Representative',
        hireDate: DateTime.now(),
        // Default password: staff123
        passwordHash: _hashPassword('staff123', 'staff_salt_123'),
        salt: 'staff_salt_123',
      ),
    ];
    for (final u in defaults) {
      await _userDao.insert(u);
    }
  }
  
  Future<void> _hydrateCacheFromDb() async {
    final users = await _userDao.getAll();
    _users.clear();
    for (final user in users) {
      _users[user.id] = user;
    }
  }
  
  Future<void> _initializeDefaultData() async {
    // Roles (static in-memory for now)
    _roles['staff'] = Role(
      id: 'staff',
      name: 'Staff',
      description: 'Basic staff member with limited access',
      baseRole: UserRole.staff,
      permissions: _permissionService.getDefaultPermissions(UserRole.staff),
      isCustom: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );
    _roles['manager'] = Role(
      id: 'manager',
      name: 'Manager',
      description: 'Department manager with enhanced access',
      baseRole: UserRole.manager,
      permissions: _permissionService.getDefaultPermissions(UserRole.manager),
      isCustom: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );
    _roles['owner'] = Role(
      id: 'owner',
      name: 'Owner',
      description: 'Business owner with full access',
      baseRole: UserRole.owner,
      permissions: _permissionService.getDefaultPermissions(UserRole.owner),
      isCustom: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );
    _roles['administrator'] = Role(
      id: 'administrator',
      name: 'Administrator',
      description: 'System administrator with full control',
      baseRole: UserRole.administrator,
      permissions: _permissionService.getDefaultPermissions(UserRole.administrator),
      isCustom: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
    );
    
    // await _seedDefaultsIfEmpty(); // Disabled to avoid conflicts with SimpleUserDao
    await _hydrateCacheFromDb();
  }
  
  // Password hashing methods
  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Url.encode(bytes);
  }
  
  String _hashPassword(String password, [String? salt]) {
    final saltToUse = salt ?? _generateSalt();
    final saltedPassword = password + saltToUse;
    final bytes = utf8.encode(saltedPassword);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  bool _verifyPassword(String password, String storedHash, String storedSalt) {
    if (kIsWeb) {
      // For web demo, use simple password comparison
      return password == storedHash;
    } else {
      // For desktop, use proper hashing
      final hashedPassword = _hashPassword(password, storedSalt);
      return hashedPassword == storedHash;
    }
  }
  
  // Authentication method
  Future<User?> authenticateUser(String username, String password) async {
    final user = await _userDao.getByUsername(username);
    if (user == null) return null;
    
    // Check if user is active
    if (!user.isActive) return null;
    
    // Check if user is locked out
    if (user.lockoutUntil != null && DateTime.now().isBefore(user.lockoutUntil!)) {
      return null;
    }
    
    // Verify password - handle both hashed and simplified passwords
    if (user.passwordHash != null) {
      bool passwordValid = false;
      
      // Check if this is a simplified password (for demo purposes)
      if (user.passwordHash!.endsWith('_hash')) {
        // Simple password check for demo users
        final expectedPassword = user.passwordHash!.replaceAll('_hash', '');
        passwordValid = password == expectedPassword;
      } else if (user.salt != null) {
        // Full password verification for production users
        passwordValid = _verifyPassword(password, user.passwordHash!, user.salt!);
      }
      
      if (passwordValid) {
        // Reset failed login attempts on successful login
        if (user.failedLoginAttempts != null && user.failedLoginAttempts! > 0) {
          final updatedUser = user.copyWith(
            failedLoginAttempts: 0,
            lockoutUntil: null,
            lastLoginAt: DateTime.now(),
          );
          await _userDao.update(updatedUser);
          _users[user.id] = updatedUser;
        } else {
          // Update last login time
          final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
          await _userDao.update(updatedUser);
          _users[user.id] = updatedUser;
        }
        return user;
      } else {
        // Increment failed login attempts
        final failedAttempts = (user.failedLoginAttempts ?? 0) + 1;
        final lockoutUntil = failedAttempts >= 5 
            ? DateTime.now().add(const Duration(minutes: 15))
            : null;
        
        final updatedUser = user.copyWith(
          failedLoginAttempts: failedAttempts,
          lockoutUntil: lockoutUntil,
        );
        await _userDao.update(updatedUser);
        _users[user.id] = updatedUser;
        
        return null;
      }
    }
    
    return null;
  }
  
  // User CRUD operations
  Future<User> createUser({
    required String username,
    required String email,
    required String fullName,
    required UserRole role,
    required String password,
    String? phoneNumber,
    String? department,
    String? position,
    String? location,
    List<String>? allowedShifts,
    String? managerId,
    String? notes,
  }) async {
    // Check if username or email already exists (cache)
    if (_users.values.any((user) => user.username == username)) {
      throw Exception('Username already exists');
    }
    if (_users.values.any((user) => user.email == email)) {
      throw Exception('Email already exists');
    }
    
    final salt = _generateSalt();
    final passwordHash = _hashPassword(password, salt);
    
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username,
      email: email,
      fullName: fullName,
      role: role,
      permissions: _permissionService.getDefaultPermissions(role),
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isActive: true,
      status: UserStatus.active,
      phoneNumber: phoneNumber,
      department: department,
      position: position,
      location: location,
      allowedShifts: allowedShifts,
      managerId: managerId,
      hireDate: DateTime.now(),
      notes: notes,
      passwordHash: passwordHash,
      salt: salt,
      lastPasswordChange: DateTime.now(),
    );
    
    await _userDao.insert(user);
    _users[user.id] = user;
    
    _auditService.logDataModification(
      userId: _systemUser.id,
      userEmail: _systemUser.email,
      userRole: _systemUser.role.name,
      resource: 'user',
      details: 'User created: ${user.fullName}',
      severity: AuditSeverity.medium,
    );
    
    return user;
  }
  
  Future<User> updateUser({
    required String userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    UserRole? role,
    UserStatus? status,
    String? department,
    String? position,
    String? location,
    List<String>? allowedShifts,
    String? managerId,
    String? notes,
  }) async {
    final existingUser = _users[userId];
    if (existingUser == null) {
      throw Exception('User not found');
    }
    
    final updatedUser = existingUser.copyWith(
      fullName: fullName ?? existingUser.fullName,
      email: email ?? existingUser.email,
      phoneNumber: phoneNumber ?? existingUser.phoneNumber,
      role: role ?? existingUser.role,
      status: status ?? existingUser.status,
      department: department ?? existingUser.department,
      position: position ?? existingUser.position,
      location: location ?? existingUser.location,
      allowedShifts: allowedShifts ?? existingUser.allowedShifts,
      managerId: managerId ?? existingUser.managerId,
      notes: notes ?? existingUser.notes,
    );
    
    await _userDao.update(updatedUser);
    _users[userId] = updatedUser;
    
    _auditService.logDataModification(
      userId: _systemUser.id,
      userEmail: _systemUser.email,
      userRole: _systemUser.role.name,
      resource: 'user',
      details: 'User updated: ${updatedUser.fullName}',
      severity: AuditSeverity.medium,
    );
    
    return updatedUser;
  }
  
  Future<void> deleteUser(String userId) async {
    final user = _users[userId];
    if (user == null) {
      throw Exception('User not found');
    }
    
    await _userDao.softDelete(userId);
    _users[userId] = user.copyWith(isActive: false, status: UserStatus.inactive);
    
    _auditService.logDataModification(
      userId: _systemUser.id,
      userEmail: _systemUser.email,
      userRole: _systemUser.role.name,
      resource: 'user',
      details: 'User deactivated: ${user.fullName}',
      severity: AuditSeverity.medium,
    );
  }
  
  Future<User?> getUserById(String userId) async {
    return await _userDao.getById(userId);
  }
  
  Future<User?> getUserByUsername(String username) async {
    return await _userDao.getByUsername(username);
  }
  
  Future<User?> getUserByEmail(String email) async {
    final allUsers = await _userDao.getAll();
    return allUsers.firstWhere(
      (user) => user.email == email,
      orElse: () => throw Exception('User not found'),
    );
  }
  
  Future<List<User>> getAllUsers() async {
    return await _userDao.getAll();
  }
  
  Future<List<User>> getActiveUsers() async {
    return await _userDao.getActive();
  }
  
  Future<List<User>> getUsersByRole(UserRole role) async {
    return await _userDao.getByRole(role);
  }
  
  Future<List<User>> getUsersByDepartment(String department) async {
    final all = await _userDao.getAll();
    return all.where((u) => u.department == department).toList();
  }
  
  // Password management
  Future<void> changePassword(String userId, String currentPassword, String newPassword) async {
    final user = _users[userId];
    if (user == null) {
      throw Exception('User not found');
    }
    
    // Verify current password
    if (user.passwordHash != null && user.salt != null) {
      if (!_verifyPassword(currentPassword, user.passwordHash!, user.salt!)) {
        throw Exception('Current password is incorrect');
      }
    }
    
    // Hash new password
    final newSalt = _generateSalt();
    final newPasswordHash = _hashPassword(newPassword, newSalt);
    
    // Update user
    final updatedUser = user.copyWith(
      passwordHash: newPasswordHash,
      salt: newSalt,
      lastPasswordChange: DateTime.now(),
      failedLoginAttempts: 0,
      lockoutUntil: null,
    );
    
    await _userDao.update(updatedUser);
    _users[userId] = updatedUser;
    
    _auditService.logDataModification(
      userId: _systemUser.id,
      userEmail: _systemUser.email,
      userRole: _systemUser.role.name,
      resource: 'user_password',
      details: 'Password changed for user: ${user.fullName}',
      severity: AuditSeverity.medium,
    );
  }
  
  Future<void> resetPassword(String userId, String newPassword) async {
    final user = _users[userId];
    if (user == null) {
      throw Exception('User not found');
    }
    
    // Hash new password
    final newSalt = _generateSalt();
    final newPasswordHash = _hashPassword(newPassword, newSalt);
    
    // Update user
    final updatedUser = user.copyWith(
      passwordHash: newPasswordHash,
      salt: newSalt,
      lastPasswordChange: DateTime.now(),
      failedLoginAttempts: 0,
      lockoutUntil: null,
    );
    
    await _userDao.update(updatedUser);
    _users[userId] = updatedUser;
    
    _auditService.logDataModification(
      userId: _systemUser.id,
      userEmail: _systemUser.email,
      userRole: _systemUser.role.name,
      resource: 'user_password',
      details: 'Password reset for user: ${user.fullName}',
      severity: AuditSeverity.medium,
    );
  }
  
  // Role management remains in-memory (no table yet)
  Future<Role> createCustomRole({
    required String name,
    required String description,
    required UserRole baseRole,
    required Map<String, bool> permissions,
    String? createdBy,
  }) async {
    final role = Role(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      baseRole: baseRole,
      permissions: permissions,
      isCustom: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
      createdBy: createdBy,
    );
    _roles[role.id] = role;
    
    _auditService.logDataModification(
      userId: _systemUser.id,
      userEmail: _systemUser.email,
      userRole: _systemUser.role.name,
      resource: 'role',
      details: 'Custom role created: ${role.name}',
      severity: AuditSeverity.medium,
    );
    return role;
  }
  
  Future<Role> updateRole({
    required String roleId,
    String? name,
    String? description,
    Map<String, bool>? permissions,
  }) async {
    final existingRole = _roles[roleId];
    if (existingRole == null) {
      throw Exception('Role not found');
    }
    final updatedRole = existingRole.copyWith(
      name: name ?? existingRole.name,
      description: description ?? existingRole.description,
      permissions: permissions ?? existingRole.permissions,
      updatedAt: DateTime.now(),
    );
    _roles[roleId] = updatedRole;
    
    _auditService.logDataModification(
      userId: _systemUser.id,
      userEmail: _systemUser.email,
      userRole: _systemUser.role.name,
      resource: 'role',
      details: 'Role updated: ${updatedRole.name}',
      severity: AuditSeverity.medium,
    );
    return updatedRole;
  }
  
  Future<List<Role>> getAllRoles() async {
    return _roles.values.toList();
  }
  
  Future<Role?> getRoleById(String roleId) async {
    return _roles[roleId];
  }
  
  Future<void> updateUserPermissions({
    required String userId,
    required Map<String, bool> permissions,
    String? updatedBy,
  }) async {
    final user = _users[userId];
    if (user == null) {
      throw Exception('User not found');
    }
    final updated = user.copyWith(permissions: permissions);
    await _userDao.update(updated);
    _users[userId] = updated;
    
    _auditService.logPermissionChange(
      userId: _systemUser.id,
      userEmail: _systemUser.email,
      userRole: _systemUser.role.name,
      targetUserId: userId,
      targetUserRole: user.role.name,
      permission: 'multiple',
      granted: true,
      reason: 'Bulk permission update',
    );
  }
  
  Future<void> assignRoleToUser({
    required String userId,
    required String roleId,
    String? assignedBy,
  }) async {
    final user = _users[userId];
    final role = _roles[roleId];
    if (user == null) {
      throw Exception('User not found');
    }
    if (role == null) {
      throw Exception('Role not found');
    }
    final oldRole = user.role.name;
    final updated = user.copyWith(role: role.baseRole, permissions: role.permissions);
    await _userDao.update(updated);
    _users[userId] = updated;
    
    _auditService.logRoleChange(
      userId: _systemUser.id,
      userEmail: _systemUser.email,
      userRole: _systemUser.role.name,
      targetUserId: userId,
      oldRole: oldRole,
      newRole: role.baseRole.name,
      reason: 'Role assignment',
    );
  }
  
  Future<void> applyPermissionPreset({
    required String presetName,
    required List<String> userIds,
    required Map<String, bool> permissions,
    String? appliedBy,
  }) async {
    for (final userId in userIds) {
      final user = _users[userId];
      if (user != null) {
        final updatedPermissions = Map<String, bool>.from(user.permissions)
          ..addAll(permissions);
        final updated = user.copyWith(permissions: updatedPermissions);
        await _userDao.update(updated);
        _users[userId] = updated;
      }
    }
    _auditService.logDataModification(
      userId: _systemUser.id,
      userEmail: _systemUser.email,
      userRole: _systemUser.role.name,
      resource: 'permissions',
      details: 'Permission preset applied: $presetName to ${userIds.length} users',
      severity: AuditSeverity.high,
    );
  }
  
  Future<void> createRoleTemplate({
    required String templateName,
    required String description,
    required UserRole baseRole,
    required Map<String, bool> permissions,
    String? createdBy,
  }) async {
    final templateId = 'template_${DateTime.now().millisecondsSinceEpoch}';
    _roles[templateId] = Role(
      id: templateId,
      name: templateName,
      description: description,
      baseRole: baseRole,
      permissions: permissions,
      isCustom: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isActive: true,
      createdBy: createdBy,
      metadata: {'isTemplate': true},
    );
  }
  
  bool hasTimeBasedPermission({
    required User user,
    required String permissionKey,
    required DateTime currentTime,
  }) {
    if (user.timeBasedPermissions == null) {
      return _permissionService.hasPermission(user, permissionKey);
    }
    final timePermissions = user.timeBasedPermissions![permissionKey];
    if (timePermissions == null) {
      return _permissionService.hasPermission(user, permissionKey);
    }
    return timePermissions['enabled'] ?? false;
  }
  
  bool hasLocationPermission({
    required User user,
    required String permissionKey,
    required String currentLocation,
  }) {
    if (user.location == null || user.location == currentLocation) {
      return _permissionService.hasPermission(user, permissionKey);
    }
    return false;
  }
}
