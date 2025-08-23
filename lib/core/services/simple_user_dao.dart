import 'package:cat_hotel_pos/features/auth/domain/entities/user.dart';


class SimpleUserDao {
  static final Map<String, User> _users = {};
  static bool _initialized = false;

  static void _initialize() {
    if (_initialized) return;
    print('SimpleUserDao: Initializing users...');
    
    // Create default users
    _users['admin'] = User(
      id: 'admin',
      username: 'admin',
      email: 'admin@cathotel.com',
      fullName: 'System Administrator',
      role: UserRole.administrator,
      permissions: {'*': true}, // All permissions
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isActive: true,
      status: UserStatus.active,
      department: 'IT',
      position: 'System Administrator',
      hireDate: DateTime.now(),
      passwordHash: 'e7f4f14186001d92a9f6695c5a787c087fc9226b41abf7169c93373f242efbf3', // admin123 + admin_salt_123
      salt: 'admin_salt_123',
    );

    _users['owner'] = User(
      id: 'owner',
      username: 'owner',
      email: 'owner@cathotel.com',
      fullName: 'Business Owner',
      role: UserRole.owner,
      permissions: {'*': true}, // All permissions
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isActive: true,
      status: UserStatus.active,
      department: 'Management',
      position: 'Owner',
      hireDate: DateTime.now(),
      passwordHash: '02981f217e5603af56604ee94f089d656c33af4a91fcb14e1514a0be6cc22374', // owner123 + owner_salt_123
      salt: 'owner_salt_123',
    );

    _users['manager'] = User(
      id: 'manager',
      username: 'manager',
      email: 'manager@cathotel.com',
      fullName: 'General Manager',
      role: UserRole.manager,
      permissions: {
        'dashboard': true,
        'customers': true,
        'bookings': true,
        'pos': true,
        'inventory': true,
        'reports': true,
      },
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isActive: true,
      status: UserStatus.active,
      department: 'Operations',
      position: 'General Manager',
      hireDate: DateTime.now(),
      passwordHash: '465504fd5e8b57f7f6b01c9010af3b6239afd9d09bdce399e0cef4a6a2e509e5', // manager123 + manager_salt_123
      salt: 'manager_salt_123',
    );

    _users['staff'] = User(
      id: 'staff',
      username: 'staff',
      email: 'staff@cathotel.com',
      fullName: 'Front Desk Staff',
      role: UserRole.staff,
      permissions: {
        'dashboard': true,
        'customers': true,
        'bookings': true,
        'pos': true,
      },
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      isActive: true,
      status: UserStatus.active,
      department: 'Front Desk',
      position: 'Customer Service Representative',
      hireDate: DateTime.now(),
      passwordHash: 'aade6a28a5e308698e5385730f65657dcab27bd8969eb25bcd5cbeb5d45ccd93', // staff123 + staff_salt_123
      salt: 'staff_salt_123',
    );

    _initialized = true;
    print('SimpleUserDao: Users initialized. Available users: ${_users.keys.join(', ')}');
  }

  Future<List<User>> getAll() async {
    _initialize();
    return _users.values.toList();
  }

  Future<User?> getById(String id) async {
    _initialize();
    return _users[id];
  }

  Future<User?> getByUsername(String username) async {
    _initialize();
    final user = _users[username];
    print('SimpleUserDao: getByUsername($username) returned: ${user?.username ?? 'null'}');
    return user;
  }

  Future<User?> getByEmail(String email) async {
    _initialize();
    try {
      return _users.values.firstWhere((user) => user.email == email);
    } catch (e) {
      return null;
    }
  }

  Future<void> insert(User user) async {
    _initialize();
    _users[user.id] = user;
  }

  Future<void> update(User user) async {
    _initialize();
    _users[user.id] = user;
  }

  Future<void> delete(String id) async {
    _initialize();
    _users.remove(id);
  }

  Future<List<User>> getActiveUsers() async {
    _initialize();
    return _users.values.where((user) => user.isActive).toList();
  }

  Future<List<User>> getUsersByRole(UserRole role) async {
    _initialize();
    return _users.values.where((user) => user.role == role).toList();
  }

  Future<void> updateLastLogin(String userId, DateTime lastLogin) async {
    _initialize();
    final user = _users[userId];
    if (user != null) {
      _users[userId] = user.copyWith(lastLoginAt: lastLogin);
    }
  }

  Future<void> updateStatus(String userId, UserStatus status) async {
    _initialize();
    final user = _users[userId];
    if (user != null) {
      _users[userId] = user.copyWith(status: status);
    }
  }

  Future<void> updateFailedLoginAttempts(String userId, int attempts, DateTime? lockoutUntil) async {
    _initialize();
    final user = _users[userId];
    if (user != null) {
      _users[userId] = user.copyWith(
        failedLoginAttempts: attempts,
        lockoutUntil: lockoutUntil,
      );
    }
  }

  Future<List<User>> getActive() async {
    _initialize();
    return _users.values.where((user) => user.isActive).toList();
  }

  Future<List<User>> getByRole(UserRole role) async {
    _initialize();
    return _users.values.where((user) => user.role == role).toList();
  }

  Future<void> softDelete(String userId) async {
    _initialize();
    final user = _users[userId];
    if (user != null) {
      _users[userId] = user.copyWith(isActive: false, status: UserStatus.inactive);
    }
  }
}
