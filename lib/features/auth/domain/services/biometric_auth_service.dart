import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/secure_storage_service.dart';

/// Service for handling biometric authentication
class BiometricAuthService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  
  /// Check if biometric authentication is available
  static Future<bool> isBiometricAvailable() async {
    try {
      if (kIsWeb) return false;
      
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      return isAvailable && isDeviceSupported;
    } catch (e) {
      print('Error checking biometric availability: $e');
      return false;
    }
  }
  
  /// Get available biometric types
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      if (kIsWeb) return [];
      
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }
  
  /// Check if specific biometric type is available
  static Future<bool> isBiometricTypeAvailable(BiometricType type) async {
    try {
      if (kIsWeb) return false;
      
      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.contains(type);
    } catch (e) {
      print('Error checking biometric type availability: $e');
      return false;
    }
  }
  
  /// Get biometric type name for display
  static String getBiometricTypeName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Strong Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
      default:
        return 'Biometric';
    }
  }
  
  /// Get primary biometric type for the device
  static Future<BiometricType?> getPrimaryBiometricType() async {
    try {
      if (kIsWeb) return null;
      
      final availableBiometrics = await getAvailableBiometrics();
      
      // Priority order: Face ID > Fingerprint > Iris > Strong > Weak
      if (availableBiometrics.contains(BiometricType.face)) {
        return BiometricType.face;
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return BiometricType.fingerprint;
      } else if (availableBiometrics.contains(BiometricType.iris)) {
        return BiometricType.iris;
      } else if (availableBiometrics.contains(BiometricType.strong)) {
        return BiometricType.strong;
      } else if (availableBiometrics.contains(BiometricType.weak)) {
        return BiometricType.weak;
      }
      
      return null;
    } catch (e) {
      print('Error getting primary biometric type: $e');
      return null;
    }
  }
  
  /// Authenticate using biometrics
  static Future<bool> authenticate({
    String reason = 'Please authenticate to continue',
  }) async {
    try {
      if (kIsWeb) return false;
      
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        print('Biometric authentication not available');
        return false;
      }
      
      final result = await _localAuth.authenticate(
        localizedReason: reason,
        authMessages: _getAuthMessages(),
        options: _getAuthOptions(),
      );
      
      return result;
    } catch (e) {
      print('Error during biometric authentication: $e');
      return false;
    }
  }
  
  /// Authenticate with specific biometric type
  static Future<bool> authenticateWithType(
    BiometricType type, {
    String reason = 'Please authenticate to continue',
  }) async {
    try {
      if (kIsWeb) return false;
      
      final isAvailable = await isBiometricTypeAvailable(type);
      if (!isAvailable) {
        print('Biometric type $type not available');
        return false;
      }
      
      final result = await _localAuth.authenticate(
        localizedReason: reason,
        options: _getAuthOptions(),
      );
      
      return result;
    } catch (e) {
      print('Error during biometric authentication with type $type: $e');
      return false;
    }
  }
  
  /// Check if biometric authentication is enabled in app settings
  static Future<bool> isBiometricEnabled() async {
    return SecureStorageService.getBiometricEnabled();
  }
  
  /// Enable or disable biometric authentication
  static Future<void> setBiometricEnabled(bool enabled) async {
    await SecureStorageService.setBiometricEnabled(enabled);
  }
  
  /// Get biometric authentication status
  static Future<BiometricAuthStatus> getBiometricStatus() async {
    try {
      final isAvailable = await isBiometricAvailable();
      final isEnabled = await isBiometricEnabled();
      final primaryType = await getPrimaryBiometricType();
      final availableTypes = await getAvailableBiometrics();
      
      return BiometricAuthStatus(
        isAvailable: isAvailable,
        isEnabled: isEnabled,
        primaryType: primaryType,
        availableTypes: availableTypes,
        canUseBiometrics: isAvailable && isEnabled,
      );
    } catch (e) {
      print('Error getting biometric status: $e');
      return BiometricAuthStatus(
        isAvailable: false,
        isEnabled: false,
        primaryType: null,
        availableTypes: [],
        canUseBiometrics: false,
      );
    }
  }
  
  /// Authenticate for login
  static Future<bool> authenticateForLogin() async {
    final status = await getBiometricStatus();
    if (!status.canUseBiometrics) {
      return false;
    }
    
    final reason = 'Authenticate to login to Cat Hotel POS';
    return await authenticate(reason: reason);
  }
  
  /// Authenticate for sensitive operations
  static Future<bool> authenticateForSensitiveOperation(String operation) async {
    final status = await getBiometricStatus();
    if (!status.canUseBiometrics) {
      return false;
    }
    
    final reason = 'Authenticate to $operation';
    return await authenticate(reason: reason);
  }
  
  /// Authenticate for settings changes
  static Future<bool> authenticateForSettings() async {
    final status = await getBiometricStatus();
    if (!status.canUseBiometrics) {
      return false;
    }
    
    final reason = 'Authenticate to change security settings';
    return await authenticate(reason: reason);
  }
  
  /// Get authentication messages for different platforms
  static List<AuthMessages> _getAuthMessages() {
    if (kIsWeb) return [];
    
    if (defaultTargetPlatform == TargetPlatform.android) {
      return <AuthMessages>[
                                const AndroidAuthMessages(
                          signInTitle: 'Biometric Authentication',
                          goToSettingsButton: 'Settings',
                          goToSettingsDescription: 'Please set up your biometric authentication.',
                          biometricHint: 'Touch the fingerprint sensor',
                          biometricNotRecognized: 'Fingerprint not recognized',
                          biometricRequiredTitle: 'Biometric authentication required',
                          biometricSuccess: 'Authentication successful',
                        ),
      ];
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return <AuthMessages>[
        const IOSAuthMessages(
          goToSettingsButton: 'Settings',
          goToSettingsDescription: 'Please set up your biometric authentication.',
          lockOut: 'Biometric authentication is locked out.',
        ),
      ];
    }
    
    return [];
  }
  
  /// Get authentication options
  static AuthenticationOptions _getAuthOptions() {
    if (kIsWeb) {
      return const AuthenticationOptions();
    }
    
    return const AuthenticationOptions();
  }
  
  /// Check if device supports strong biometrics
  static Future<bool> supportsStrongBiometrics() async {
    try {
      if (kIsWeb) return false;
      
      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.contains(BiometricType.strong);
    } catch (e) {
      print('Error checking strong biometrics support: $e');
      return false;
    }
  }
  
  /// Check if device supports weak biometrics
  static Future<bool> supportsWeakBiometrics() async {
    try {
      if (kIsWeb) return false;
      
      final availableBiometrics = await getAvailableBiometrics();
      return availableBiometrics.contains(BiometricType.weak);
    } catch (e) {
      print('Error checking weak biometrics support: $e');
      return false;
    }
  }
  
  /// Get biometric strength level
  static Future<BiometricStrength> getBiometricStrength() async {
    try {
      if (kIsWeb) return BiometricStrength.none;
      
      if (await supportsStrongBiometrics()) {
        return BiometricStrength.strong;
      } else if (await supportsWeakBiometrics()) {
        return BiometricStrength.weak;
      } else {
        return BiometricStrength.none;
      }
    } catch (e) {
      print('Error getting biometric strength: $e');
      return BiometricStrength.none;
    }
  }
  
  /// Check if biometric authentication is recommended
  static Future<bool> isBiometricRecommended() async {
    try {
      if (kIsWeb) return false;
      
      final strength = await getBiometricStrength();
      return strength == BiometricStrength.strong;
    } catch (e) {
      print('Error checking biometric recommendation: $e');
      return false;
    }
  }


}

/// Biometric authentication status
class BiometricAuthStatus {
  final bool isAvailable;
  final bool isEnabled;
  final BiometricType? primaryType;
  final List<BiometricType> availableTypes;
  final bool canUseBiometrics;
  
  const BiometricAuthStatus({
    required this.isAvailable,
    required this.isEnabled,
    required this.primaryType,
    required this.availableTypes,
    required this.canUseBiometrics,
  });
  
  /// Get status description
  String get statusDescription {
    if (!isAvailable) {
      return 'Biometric authentication not available on this device';
    }
    
    if (!isEnabled) {
      return 'Biometric authentication is disabled in app settings';
    }
    
    if (primaryType != null) {
      return 'Biometric authentication available using ${BiometricAuthService.getBiometricTypeName(primaryType!)}';
    }
    
    return 'Biometric authentication available';
  }
  
  /// Get primary biometric type name
  String? get primaryBiometricTypeName {
    return primaryType != null 
        ? BiometricAuthService.getBiometricTypeName(primaryType!)
        : null;
  }
  
  /// Get available biometric types names
  List<String> get availableBiometricTypeNames {
    return availableTypes
        .map((type) => BiometricAuthService.getBiometricTypeName(type))
        .toList();
  }
}

/// Biometric strength levels
enum BiometricStrength {
  none,
  weak,
  strong,
}
