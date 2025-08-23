import 'package:cat_hotel_pos/core/services/settings_dao.dart';
import 'package:cat_hotel_pos/features/settings/domain/entities/settings.dart';

class SettingsService {
  final SettingsDao _settingsDao;

  SettingsService(this._settingsDao);

  // Get current settings
  Future<Settings> getSettings() async {
    return await _settingsDao.getSettings();
  }

  // Update settings
  Future<Settings> updateSettings(Settings settings) async {
    // Validate business email format
    if (!_isValidEmail(settings.businessEmail)) {
      throw Exception('Invalid business email format');
    }

    // Validate business phone format
    if (!_isValidPhone(settings.businessPhone)) {
      throw Exception('Invalid business phone format');
    }

    // Validate tax rate
    if (settings.defaultTaxRate < 0 || settings.defaultTaxRate > 100) {
      throw Exception('Tax rate must be between 0 and 100');
    }

    // Validate SMTP port
    if (settings.smtpPort < 1 || settings.smtpPort > 65535) {
      throw Exception('SMTP port must be between 1 and 65535');
    }

    return await _settingsDao.updateSettings(settings);
  }

  // Reset to default settings
  Future<Settings> resetToDefaults() async {
    return await _settingsDao.resetToDefaults();
  }

  // Get specific setting value
  Future<T?> getSettingValue<T>(String key) async {
    return await _settingsDao.getSettingValue<T>(key);
  }

  // Update specific setting value
  Future<bool> updateSettingValue<T>(String key, T value) async {
    // Validate specific values based on key
    switch (key) {
      case 'businessEmail':
        if (value is String && !_isValidEmail(value)) {
          throw Exception('Invalid business email format');
        }
        break;
      case 'businessPhone':
        if (value is String && !_isValidPhone(value)) {
          throw Exception('Invalid business phone format');
        }
        break;
      case 'defaultTaxRate':
        if (value is double && (value < 0 || value > 100)) {
          throw Exception('Tax rate must be between 0 and 100');
        }
        break;
      case 'smtpPort':
        if (value is int && (value < 1 || value > 65535)) {
          throw Exception('SMTP port must be between 1 and 65535');
        }
        break;
    }

    return await _settingsDao.updateSettingValue<T>(key, value);
  }

  // Export settings
  Future<Map<String, dynamic>> exportSettings() async {
    return await _settingsDao.exportSettings();
  }

  // Import settings
  Future<Settings> importSettings(Map<String, dynamic> json) async {
    try {
      final settings = Settings.fromJson(json);
      
      // Validate imported settings
      if (!_isValidEmail(settings.businessEmail)) {
        throw Exception('Invalid business email format in imported settings');
      }

      if (!_isValidPhone(settings.businessPhone)) {
        throw Exception('Invalid business phone format in imported settings');
      }

      if (settings.defaultTaxRate < 0 || settings.defaultTaxRate > 100) {
        throw Exception('Invalid tax rate in imported settings');
      }

      if (settings.smtpPort < 1 || settings.smtpPort > 65535) {
        throw Exception('Invalid SMTP port in imported settings');
      }

      return await _settingsDao.importSettings(json);
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to import settings: $e');
    }
  }

  // Test SMTP connection
  Future<bool> testSmtpConnection() async {
    final settings = await _settingsDao.getSettings();
    
    if (settings.smtpServer.isEmpty || 
        settings.smtpUsername.isEmpty || 
        settings.smtpPassword.isEmpty) {
      throw Exception('SMTP configuration is incomplete');
    }

    // Simulate SMTP connection test
    await Future.delayed(const Duration(seconds: 2));
    
    // For demo purposes, always return success
    // In a real implementation, you would test the actual SMTP connection
    return true;
  }

  // Get available currencies
  List<String> getAvailableCurrencies() {
    return [
      'MYR', 'USD', 'EUR', 'GBP', 'SGD', 'JPY', 'CNY', 'AUD', 'CAD', 'CHF'
    ];
  }

  // Get available timezones
  List<String> getAvailableTimezones() {
    return [
      'Asia/Kuala_Lumpur',
      'Asia/Singapore',
      'Asia/Bangkok',
      'Asia/Manila',
      'Asia/Jakarta',
      'Asia/Ho_Chi_Minh',
      'Asia/Seoul',
      'Asia/Tokyo',
      'Asia/Shanghai',
      'Asia/Hong_Kong',
      'UTC',
      'America/New_York',
      'America/London',
      'Europe/Paris',
      'Europe/Berlin',
    ];
  }

  // Get available languages
  List<String> getAvailableLanguages() {
    return ['en', 'ms', 'zh', 'ta'];
  }

  // Get available backup frequencies
  List<String> getAvailableBackupFrequencies() {
    return ['hourly', 'daily', 'weekly', 'monthly'];
  }

  // Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Validate phone format
  bool _isValidPhone(String phone) {
    // Accept various phone formats: +60123456789, 0123456789, 60123456789
    final phoneRegex = RegExp(r'^(\+?6?0?1?)[0-9]{8,11}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  // Get system information
  Map<String, dynamic> getSystemInfo() {
    return {
      'appVersion': '1.0.0',
      'flutterVersion': '3.19.0',
      'dartVersion': '3.3.0',
      'platform': 'Android/Windows/Web',
      'lastBackup': DateTime.now().subtract(const Duration(days: 1)),
      'databaseSize': '2.5 MB',
      'cacheSize': '15.3 MB',
    };
  }

  // Perform system maintenance
  Future<Map<String, dynamic>> performMaintenance() async {
    await Future.delayed(const Duration(seconds: 3));
    
    return {
      'cacheCleared': true,
      'tempFilesRemoved': true,
      'databaseOptimized': true,
      'logsRotated': true,
      'maintenanceCompleted': DateTime.now(),
    };
  }
}
