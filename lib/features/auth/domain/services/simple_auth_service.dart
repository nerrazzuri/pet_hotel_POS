import 'package:cat_hotel_pos/features/auth/domain/entities/user.dart';


class SimpleAuthService {
  static final Map<String, User> _demoUsers = {
    'admin': User(
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
    ),
    'owner': User(
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
    ),
    'manager': User(
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
    ),
    'staff': User(
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
    ),
  };

  static final Map<String, String> _passwords = {
    'admin': 'admin123',
    'owner': 'owner123',
    'manager': 'manager123',
    'staff': 'staff123',
  };

  static Future<User?> authenticateUser(String username, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final user = _demoUsers[username];
    if (user == null) return null;
    
    if (!user.isActive) return null;
    
    final expectedPassword = _passwords[username];
    if (expectedPassword == password) {
      // Update last login time
      final updatedUser = user.copyWith(lastLoginAt: DateTime.now());
      _demoUsers[username] = updatedUser;
      return updatedUser;
    }
    
    return null;
  }

  static Future<List<User>> getAllUsers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _demoUsers.values.toList();
  }

  static Future<User?> getUserById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _demoUsers.values.firstWhere((user) => user.id == id);
  }

  static Future<User?> getUserByUsername(String username) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _demoUsers[username];
  }
}
