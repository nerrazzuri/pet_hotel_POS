// Stub User DAO for Android compatibility
// This will be re-enabled when database services are restored

import 'package:cat_hotel_pos/features/auth/domain/entities/user.dart';

class UserDao {
  // TODO: Uncomment when implementing database tables
  // static const String _table = 'users';

  Future<void> insert(User user) async {
    // Stub implementation
  }

  Future<User?> getById(String userId) async {
    return null;
  }

  Future<User?> getByEmail(String email) async {
    return null;
  }

  Future<List<User>> getAll() async {
    return [];
  }

  Future<List<User>> getByRole(String role) async {
    return [];
  }

  Future<List<User>> getActiveUsers() async {
    return [];
  }

  Future<User> update(User user) async {
    return user;
  }

  Future<User> updateStatus(String userId, UserStatus status) async {
    return User(
      id: userId,
      username: 'user_$userId',
      email: 'user$userId@example.com',
      fullName: 'User $userId',
      role: UserRole.staff,
      permissions: {},
      isActive: status == UserStatus.active,
      lastLoginAt: DateTime.now(),
      createdAt: DateTime.now(),
      status: status,
    );
  }
}
