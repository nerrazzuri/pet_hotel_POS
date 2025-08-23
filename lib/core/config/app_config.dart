// import 'package:hive_flutter/hive_flutter.dart';

class AppConfig {
  // TODO: Uncomment when implementing configuration storage
  // static const String _configBoxName = 'app_config';
  // static const String _apiBaseUrlKey = 'api_base_url';
  // static const String _appVersionKey = 'app_version';
  // static const String _buildNumberKey = 'build_number';
  // static const String _environmentKey = 'environment';
  // static const String _companyNameKey = 'company_name';
  // static const String _taxRateKey = 'tax_rate';
  // static const String _currencyKey = 'currency';
  // static const String _timezoneKey = 'timezone';
  // static const String _languageKey = 'language';
  
  // Default values
  static const String _defaultApiBaseUrl = 'http://localhost:3000/api';
  static const String _defaultCompanyName = 'Cat Hotel';
  static const double _defaultTaxRate = 0.06; // 6% SST for Malaysia
  static const String _defaultCurrency = 'MYR';
  static const String _defaultTimezone = 'Asia/Kuala_Lumpur';
  static const String _defaultLanguage = 'en';
  
  // static late Box _configBox;
  
  // Getters
  static String get apiBaseUrl => _defaultApiBaseUrl;
  static String get appVersion => '1.0.0';
  static int get buildNumber => 1;
  static String get environment => 'development';
  static String get companyName => _defaultCompanyName;
  static double get taxRate => _defaultTaxRate;
  static String get currency => _defaultCurrency;
  static String get timezone => _defaultTimezone;
  static String get language => _defaultLanguage;
  
  // Business logic constants
  static const int maxBookingDays = 365;
  static const int maxPetsPerOwner = 10;
  static const int maxServicesPerBooking = 20;
  static const int maxDiscountPercentage = 50;
  static const int maxRefundDays = 30;
  
  // Time constants
  static const int checkInTime = 14; // 2 PM
  static const int checkOutTime = 11; // 11 AM
  static const int lateCheckOutFee = 50; // MYR
  static const int noShowFee = 100; // MYR
  
  // Room types
  static const List<String> roomTypes = [
    'Single',
    'Deluxe',
    'Suite',
    'VIP Suite',
  ];
  
  // Service categories
  static const List<String> serviceCategories = [
    'Boarding',
    'Daycare',
    'Grooming',
    'Add-ons',
    'Retail',
  ];
  
  // Payment methods
  static const List<String> paymentMethods = [
    'Cash',
    'Credit Card',
    'Debit Card',
    'E-Wallet',
    'Bank Transfer',
    'FPX',
    'DuitNow',
    'Touch n Go',
  ];
  
  // User roles
  static const List<String> userRoles = [
    'Admin',
    'Manager',
    'Cashier',
    'Groomer',
    'Housekeeper',
    'Receptionist',
  ];
  
  // Permissions
  static const Map<String, List<String>> rolePermissions = {
    'Admin': ['*'], // All permissions
    'Manager': [
      'pos:read', 'pos:write',
      'booking:read', 'booking:write',
      'customers:read', 'customers:write',
      'reports:read',
      'staff:read', 'staff:write',
    ],
    'Cashier': [
      'pos:read', 'pos:write',
      'booking:read',
      'customers:read', 'customers:write',
      'payments:read', 'payments:write',
    ],
    'Groomer': [
      'services:read', 'services:write',
      'customers:read',
      'booking:read',
    ],
    'Housekeeper': [
      'rooms:read', 'rooms:write',
      'booking:read',
    ],
    'Receptionist': [
      'booking:read', 'booking:write',
      'customers:read', 'customers:write',
      'rooms:read',
    ],
  };
  
  static Future<void> load() async {
    // _configBox = await Hive.openBox(_configBoxName);
    
    // Set default values if not exists
    // if (!_configBox.containsKey(_apiBaseUrlKey)) {
    //   await _configBox.put(_apiBaseUrlKey, _defaultApiBaseUrl);
    // }
    // if (!_configBox.containsKey(_companyNameKey)) {
    //   await _configBox.put(_companyNameKey, _defaultCompanyName);
    // }
    // if (!_configBox.containsKey(_taxRateKey)) {
    //   await _configBox.put(_taxRateKey, _defaultTaxRate);
    // }
    // if (!_configBox.containsKey(_currencyKey)) {
    //   await _configBox.put(_currencyKey, _defaultCurrency);
    // }
    // if (!_configBox.containsKey(_timezoneKey)) {
    //   await _configBox.put(_timezoneKey, _defaultTimezone);
    // }
    // if (!_configBox.containsKey(_languageKey)) {
    //   await _configBox.put(_languageKey, _defaultLanguage);
    // }
  }
  
  static Future<void> updateConfig({
    String? apiBaseUrl,
    String? companyName,
    double? taxRate,
    String? currency,
    String? timezone,
    String? language,
  }) async {
    // if (apiBaseUrl != null) {
    //   await _configBox.put(_apiBaseUrlKey, apiBaseUrl);
    // }
    // if (companyName != null) {
    //   await _configBox.put(_companyNameKey, companyName);
    // }
    // if (taxRate != null) {
    //   await _configBox.put(_taxRateKey, taxRate);
    // }
    // if (currency != null) {
    //   await _configBox.put(_currencyKey, currency);
    // }
    // if (timezone != null) {
    //   await _configBox.put(_timezoneKey, timezone);
    // }
    // if (language != null) {
    //   await _configBox.put(_languageKey, language);
    // }
  }
  
  static Future<void> resetToDefaults() async {
    // await _configBox.clear();
    await load();
  }
  
  static void dispose() {
    // _configBox.close();
  }
}
