import 'package:cat_hotel_pos/features/settings/domain/entities/settings.dart';

class SettingsDao {
  static Settings _settings = Settings.create(
    businessName: 'Cat Hotel & Pet Services',
    businessAddress: '123 Pet Street, Kuala Lumpur, Malaysia',
    businessPhone: '+60123456789',
    businessEmail: 'info@cathotel.com',
  );

  // Get current settings
  Future<Settings> getSettings() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _settings;
  }

  // Update settings
  Future<Settings> updateSettings(Settings settings) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _settings = settings.copyWith(
      updatedAt: DateTime.now(),
    );
    return _settings;
  }

  // Reset to default settings
  Future<Settings> resetToDefaults() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _settings = Settings.create(
      businessName: 'Cat Hotel & Pet Services',
      businessAddress: '123 Pet Street, Kuala Lumpur, Malaysia',
      businessPhone: '+60123456789',
      businessEmail: 'info@cathotel.com',
    );
    return _settings;
  }

  // Get specific setting value
  Future<T?> getSettingValue<T>(String key) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    switch (key) {
      case 'businessName':
        return _settings.businessName as T;
      case 'businessAddress':
        return _settings.businessAddress as T;
      case 'businessPhone':
        return _settings.businessPhone as T;
      case 'businessEmail':
        return _settings.businessEmail as T;
      case 'currency':
        return _settings.currency as T;
      case 'timezone':
        return _settings.timezone as T;
      case 'language':
        return _settings.language as T;
      case 'enableNotifications':
        return _settings.enableNotifications as T;
      case 'enableBiometricAuth':
        return _settings.enableBiometricAuth as T;
      case 'enableAutoBackup':
        return _settings.enableAutoBackup as T;
      case 'backupFrequency':
        return _settings.backupFrequency as T;
      case 'enableTaxCalculation':
        return _settings.enableTaxCalculation as T;
      case 'defaultTaxRate':
        return _settings.defaultTaxRate as T;
      case 'enableReceiptPrinting':
        return _settings.enableReceiptPrinting as T;
      case 'receiptHeader':
        return _settings.receiptHeader as T;
      case 'receiptFooter':
        return _settings.receiptFooter as T;
      case 'enableEmailReceipts':
        return _settings.enableEmailReceipts as T;
      case 'enableWhatsAppReceipts':
        return _settings.enableWhatsAppReceipts as T;
      case 'smtpServer':
        return _settings.smtpServer as T;
      case 'smtpPort':
        return _settings.smtpPort as T;
      case 'smtpUsername':
        return _settings.smtpUsername as T;
      case 'smtpPassword':
        return _settings.smtpPassword as T;
      case 'enableSsl':
        return _settings.enableSsl as T;
      default:
        return null;
    }
  }

  // Update specific setting value
  Future<bool> updateSettingValue<T>(String key, T value) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    try {
      switch (key) {
        case 'businessName':
          _settings = _settings.copyWith(businessName: value as String);
          break;
        case 'businessAddress':
          _settings = _settings.copyWith(businessAddress: value as String);
          break;
        case 'businessPhone':
          _settings = _settings.copyWith(businessPhone: value as String);
          break;
        case 'businessEmail':
          _settings = _settings.copyWith(businessEmail: value as String);
          break;
        case 'currency':
          _settings = _settings.copyWith(currency: value as String);
          break;
        case 'timezone':
          _settings = _settings.copyWith(timezone: value as String);
          break;
        case 'language':
          _settings = _settings.copyWith(language: value as String);
          break;
        case 'enableNotifications':
          _settings = _settings.copyWith(enableNotifications: value as bool);
          break;
        case 'enableBiometricAuth':
          _settings = _settings.copyWith(enableBiometricAuth: value as bool);
          break;
        case 'enableAutoBackup':
          _settings = _settings.copyWith(enableAutoBackup: value as bool);
          break;
        case 'backupFrequency':
          _settings = _settings.copyWith(backupFrequency: value as String);
          break;
        case 'enableTaxCalculation':
          _settings = _settings.copyWith(enableTaxCalculation: value as bool);
          break;
        case 'defaultTaxRate':
          _settings = _settings.copyWith(defaultTaxRate: value as double);
          break;
        case 'enableReceiptPrinting':
          _settings = _settings.copyWith(enableReceiptPrinting: value as bool);
          break;
        case 'receiptHeader':
          _settings = _settings.copyWith(receiptHeader: value as String);
          break;
        case 'receiptFooter':
          _settings = _settings.copyWith(receiptFooter: value as String);
          break;
        case 'enableEmailReceipts':
          _settings = _settings.copyWith(enableEmailReceipts: value as bool);
          break;
        case 'enableWhatsAppReceipts':
          _settings = _settings.copyWith(enableWhatsAppReceipts: value as bool);
          break;
        case 'smtpServer':
          _settings = _settings.copyWith(smtpServer: value as String);
          break;
        case 'smtpPort':
          _settings = _settings.copyWith(smtpPort: value as int);
          break;
        case 'smtpUsername':
          _settings = _settings.copyWith(smtpUsername: value as String);
          break;
        case 'smtpPassword':
          _settings = _settings.copyWith(smtpPassword: value as String);
          break;
        case 'enableSsl':
          _settings = _settings.copyWith(enableSsl: value as bool);
          break;
        default:
          return false;
      }
      
      _settings = _settings.copyWith(updatedAt: DateTime.now());
      return true;
    } catch (e) {
      return false;
    }
  }

  // Export settings
  Future<Map<String, dynamic>> exportSettings() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _settings.toJson();
  }

  // Import settings
  Future<Settings> importSettings(Map<String, dynamic> json) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      _settings = Settings.fromJson(json).copyWith(
        updatedAt: DateTime.now(),
      );
      return _settings;
    } catch (e) {
      throw Exception('Invalid settings format');
    }
  }
}
