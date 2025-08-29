import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

/// Secure password hashing service using PBKDF2 with SHA-256
/// This provides industry-standard password security
class PasswordService {
  static const int _defaultIterations = 100000; // NIST recommended minimum
  static const int _saltLength = 32; // 256 bits
  static const int _keyLength = 64; // 512 bits

  /// Generates a cryptographically secure random salt
  static String generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(_saltLength, (i) => random.nextInt(256));
    return base64.encode(saltBytes);
  }

  /// Hashes a password with a given salt using PBKDF2-SHA256
  static String hashPassword(String password, String salt, {int iterations = _defaultIterations}) {
    if (password.isEmpty) {
      throw ArgumentError('Password cannot be empty');
    }
    if (salt.isEmpty) {
      throw ArgumentError('Salt cannot be empty');
    }

    final saltBytes = base64.decode(salt);
    final passwordBytes = utf8.encode(password);

    // Implement PBKDF2 manually since dart doesn't have built-in support
    List<int> pbkdf2(List<int> password, List<int> salt, int iterations, int keyLength) {
      final hmac = Hmac(sha256, password);
      final result = <int>[];
      
      for (int block = 1; result.length < keyLength; block++) {
        final blockSalt = List<int>.from(salt)..addAll(_intToBytes(block));
        var u = hmac.convert(blockSalt).bytes;
        var output = List<int>.from(u);
        
        for (int i = 1; i < iterations; i++) {
          u = hmac.convert(u).bytes;
          for (int j = 0; j < output.length; j++) {
            output[j] ^= u[j];
          }
        }
        
        result.addAll(output);
      }
      
      return result.take(keyLength).toList();
    }

    final hash = pbkdf2(passwordBytes, saltBytes, iterations, _keyLength);
    return base64.encode(hash);
  }

  /// Creates a complete hash string with salt and iterations embedded
  static String createPasswordHash(String password, {int iterations = _defaultIterations}) {
    final salt = generateSalt();
    final hash = hashPassword(password, salt, iterations: iterations);
    
    // Format: iterations$salt$hash
    return '$iterations\$${salt}\$${hash}';
  }

  /// Verifies a password against a stored hash
  static bool verifyPassword(String password, String storedHash) {
    try {
      final parts = storedHash.split('\$');
      if (parts.length != 3) {
        return false;
      }

      final iterations = int.parse(parts[0]);
      final salt = parts[1];
      final hash = parts[2];

      final computedHash = hashPassword(password, salt, iterations: iterations);
      return _constantTimeEquals(computedHash, hash);
    } catch (e) {
      // Log error in production
      return false;
    }
  }

  /// Constant-time string comparison to prevent timing attacks
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) {
      return false;
    }

    int result = 0;
    for (int i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Helper method to convert integer to bytes
  static List<int> _intToBytes(int value) {
    return [
      (value >> 24) & 0xff,
      (value >> 16) & 0xff,
      (value >> 8) & 0xff,
      value & 0xff,
    ];
  }

  /// Checks if a password meets security requirements
  static bool isPasswordSecure(String password) {
    if (password.length < 8) return false;
    
    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return hasUppercase && hasLowercase && hasDigit && hasSpecialChar;
  }

  /// Generates a secure random password
  static String generateSecurePassword({int length = 16}) {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#\$%^&*()';
    final Random random = Random.secure();
    
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Check if password needs to be rehashed (e.g., due to increased security requirements)
  static bool needsRehash(String storedHash, {int targetIterations = _defaultIterations}) {
    try {
      final parts = storedHash.split('\$');
      if (parts.length != 3) {
        return true; // Invalid format, needs rehash
      }

      final iterations = int.parse(parts[0]);
      return iterations < targetIterations;
    } catch (e) {
      return true; // Error parsing, needs rehash
    }
  }
}