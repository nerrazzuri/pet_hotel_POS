import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/auth/domain/entities/user.dart';
import 'package:cat_hotel_pos/features/auth/domain/entities/role.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/permission_service.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/audit_service.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/user_service.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/auth_service.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/secure_storage_service.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/biometric_auth_service.dart';

// Service providers
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService();
});

final auditServiceProvider = Provider<AuditService>((ref) {
  return AuditService();
});

final userServiceProvider = Provider<UserService>((ref) {
  return UserService(
    ref.read(permissionServiceProvider),
    ref.read(auditServiceProvider),
  );
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(
    ref.read(userServiceProvider),
    ref.read(auditServiceProvider),
  );
});

// Authentication state providers
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  return AuthStateNotifier(
    ref.read(authServiceProvider),
    ref.read(auditServiceProvider),
  );
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).isAuthenticated;
});

final authTokenProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).accessToken;
});

// Biometric authentication providers
final biometricStatusProvider = FutureProvider<BiometricAuthStatus>((ref) async {
  return await BiometricAuthService.getBiometricStatus();
});

final biometricEnabledProvider = FutureProvider<bool>((ref) async {
  return await BiometricAuthService.isBiometricEnabled();
});

// Secure storage providers
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final storageStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  return await SecureStorageService.getStorageStats();
});

// Permission check providers
final hasPermissionProvider = Provider.family<bool, String>((ref, permissionKey) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  
  final permissionService = ref.read(permissionServiceProvider);
  return permissionService.hasPermission(user, permissionKey);
});

final hasAnyPermissionProvider = Provider.family<bool, List<String>>((ref, permissionKeys) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  
  final permissionService = ref.read(permissionServiceProvider);
  return permissionService.hasAnyPermission(user, permissionKeys);
});

final hasAllPermissionsProvider = Provider.family<bool, List<String>>((ref, permissionKeys) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  
  final permissionService = ref.read(permissionServiceProvider);
  return permissionService.hasAllPermissions(user, permissionKeys);
});

// User management providers
final canManageUsersProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  
  final permissionService = ref.read(permissionServiceProvider);
  return permissionService.canManageStaff(user);
});

final canManagePermissionsProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return false;
  
  final permissionService = ref.read(permissionServiceProvider);
  return permissionService.canManagePermissions(user);
});

// Users list providers
final usersListProvider = FutureProvider<List<User>>((ref) async {
  final userService = ref.read(userServiceProvider);
  return await userService.getAllUsers();
});

final activeUsersProvider = FutureProvider<List<User>>((ref) async {
  final userService = ref.read(userServiceProvider);
  return await userService.getActiveUsers();
});

// Roles list provider
final rolesListProvider = FutureProvider<List<Role>>((ref) async {
  final userService = ref.read(userServiceProvider);
  return await userService.getAllRoles();
});

// Authentication state notifier
class AuthStateNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final AuditService _auditService;
  
  AuthStateNotifier(this._authService, this._auditService) : super(AuthState.initial()) {
    _initializeAuth();
  }
  
  /// Initialize authentication state
  Future<void> _initializeAuth() async {
    try {
      // Check if user is already logged in
      final isLoggedIn = await SecureStorageService.isLoggedIn();
      if (isLoggedIn) {
        final accessToken = await SecureStorageService.getAccessToken();
        if (accessToken != null) {
          final user = await _authService.getUserFromToken(accessToken);
          if (user != null) {
            state = state.copyWith(
              user: user,
              isAuthenticated: true,
              accessToken: accessToken,
              isLoading: false,
            );
            return;
          }
        }
      }
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to initialize authentication: $e',
        isLoading: false,
      );
    }
  }
  
  /// Login user
  Future<AuthResult> login(String username, String password, {bool rememberMe = false}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final result = await _authService.authenticateUser(username, password);
      
      if (result.isSuccess && result.user != null && result.accessToken != null) {
        // Store tokens securely
        await SecureStorageService.storeAccessToken(result.accessToken!);
        await SecureStorageService.storeRefreshToken(result.refreshToken!);
        await SecureStorageService.storeUserData(result.user!.toJson());
        await SecureStorageService.storeLastLogin(DateTime.now());
        await SecureStorageService.setRememberMe(rememberMe);
        
        if (rememberMe) {
          await SecureStorageService.storeCredentials(username, password);
        }
        
        // Update state
        state = state.copyWith(
          user: result.user,
          isAuthenticated: true,
          accessToken: result.accessToken,
          refreshToken: result.refreshToken,
          isLoading: false,
          error: null,
        );
        
        return result;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.errorMessage ?? 'Authentication failed',
        );
        return result;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login error: $e',
      );
      return AuthResult.failure('Login error: $e');
    }
  }
  
  /// Login with biometrics
  Future<AuthResult> loginWithBiometrics() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final isAuthenticated = await BiometricAuthService.authenticateForLogin();
      if (!isAuthenticated) {
        state = state.copyWith(
          isLoading: false,
          error: 'Biometric authentication failed',
        );
        return AuthResult.failure('Biometric authentication failed');
      }
      
      // Get stored credentials
      final credentials = await SecureStorageService.getStoredCredentials();
      if (credentials == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'No stored credentials found',
        );
        return AuthResult.failure('No stored credentials found');
      }
      
      // Login with stored credentials
      return await login(credentials['username']!, credentials['password']!);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Biometric login error: $e',
      );
      return AuthResult.failure('Biometric login error: $e');
    }
  }
  
  /// Refresh access token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await SecureStorageService.getRefreshToken();
      if (refreshToken == null) {
        await logout();
        return false;
      }
      
      final result = await _authService.refreshToken(refreshToken);
      if (result.isSuccess && result.accessToken != null) {
        await SecureStorageService.storeAccessToken(result.accessToken!);
        await SecureStorageService.storeRefreshToken(result.refreshToken!);
        
        state = state.copyWith(
          accessToken: result.accessToken,
          refreshToken: result.refreshToken,
        );
        
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      await logout();
      return false;
    }
  }
  
  /// Logout user
  Future<void> logout() async {
    try {
      if (state.user != null && state.accessToken != null) {
        await _authService.logout(state.user!.id, state.accessToken!);
      }
      
      // Clear stored data
      await SecureStorageService.clearAll();
      
      // Update state
      state = AuthState.initial();
    } catch (e) {
      print('Logout error: $e');
      // Force logout even if there's an error
      await SecureStorageService.clearAll();
      state = AuthState.initial();
    }
  }
  
  /// Change password
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      if (state.user == null) return false;
      
      final success = await _authService.changePassword(
        state.user!.id,
        currentPassword,
        newPassword,
      );
      
      if (success) {
        // Update stored credentials if remember me is enabled
        if (SecureStorageService.getRememberMe()) {
          final credentials = await SecureStorageService.getStoredCredentials();
          if (credentials != null) {
            await SecureStorageService.storeCredentials(
              credentials['username']!,
              newPassword,
            );
          }
        }
      }
      
      return success;
    } catch (e) {
      print('Change password error: $e');
      return false;
    }
  }
  
  /// Reset password
  Future<bool> resetPassword(String email, String newPassword) async {
    try {
      return await _authService.resetPassword(email, newPassword);
    } catch (e) {
      print('Reset password error: $e');
      return false;
    }
  }
  
  /// Update user profile
  void updateUserProfile(User updatedUser) {
    if (state.user?.id == updatedUser.id) {
      state = state.copyWith(user: updatedUser);
      // Update stored user data
      SecureStorageService.storeUserData(updatedUser.toJson());
    }
  }
  
  /// Check if token is expired and refresh if needed
  Future<bool> checkAndRefreshToken() async {
    try {
      if (state.accessToken == null) return false;
      
      final isValid = _authService.validateAccessToken(state.accessToken!);
      if (!isValid) {
        return await refreshToken();
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Get authentication status
  AuthStatus get authStatus {
    if (state.isLoading) return AuthStatus.loading;
    if (state.isAuthenticated) return AuthStatus.authenticated;
    if (state.error != null) return AuthStatus.error;
    return AuthStatus.unauthenticated;
  }
}

/// Authentication state
class AuthState {
  final User? user;
  final bool isAuthenticated;
  final String? accessToken;
  final String? refreshToken;
  final bool isLoading;
  final String? error;
  final DateTime? lastActivity;
  
  const AuthState({
    this.user,
    required this.isAuthenticated,
    this.accessToken,
    this.refreshToken,
    required this.isLoading,
    this.error,
    this.lastActivity,
  });
  
  factory AuthState.initial() {
    return const AuthState(
      isAuthenticated: false,
      isLoading: true,
    );
  }
  
  AuthState copyWith({
    User? user,
    bool? isAuthenticated,
    String? accessToken,
    String? refreshToken,
    bool? isLoading,
    String? error,
    DateTime? lastActivity,
  }) {
    return AuthState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastActivity: lastActivity ?? DateTime.now(),
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.user == user &&
        other.isAuthenticated == isAuthenticated &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken &&
        other.isLoading == isLoading &&
        other.error == error;
  }
  
  @override
  int get hashCode {
    return Object.hash(
      user,
      isAuthenticated,
      accessToken,
      refreshToken,
      isLoading,
      error,
    );
  }
}

/// Authentication status
enum AuthStatus {
  loading,
  authenticated,
  unauthenticated,
  error,
}
