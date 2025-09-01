class AppConfig {
  static bool _isInitialized = false;
  
  // MVP Module Configuration
  static const Map<String, bool> _mvpModules = {
    // MVP Required Modules
    'pos': true,                    // 1. Sales Register (POS Front Desk)
    'booking': true,                // 2. Booking & Room/Cage Management
    'customers': true,              // 3. Customer & Pet Profiles
    'services': true,               // 4. Services & Products
    'payments': true,               // 5. Payments & Invoicing
    'reports': true,                // 6. Reports (Basic)
    'staff': true,                  // 7. Staff & Roles (Basic)
    
    // Non-MVP Modules (disabled for MVP, kept for future enhancement)
    'financials': false,            // Advanced financial operations
    'loyalty': false,               // Loyalty programs
    'crm': false,                   // CRM management
    'inventory': false,             // Inventory management
    'settings': false,              // Advanced settings
    'setup_wizard': false,          // Setup wizard
  };

  static void initialize() {
    if (!_isInitialized) {
      _isInitialized = true;
      print('AppConfig initialized with MVP module configuration');
      print('MVP Modules: ${_mvpModules.entries.where((e) => e.value).map((e) => e.key).join(', ')}');
      print('Disabled Modules: ${_mvpModules.entries.where((e) => !e.value).map((e) => e.key).join(', ')}');
    }
  }

  /// Check if a module is enabled for MVP
  static bool isModuleEnabled(String moduleName) {
    return _mvpModules[moduleName] ?? false;
  }

  /// Get all enabled modules
  static List<String> getEnabledModules() {
    return _mvpModules.entries.where((e) => e.value).map((e) => e.key).toList();
  }

  /// Get all disabled modules
  static List<String> getDisabledModules() {
    return _mvpModules.entries.where((e) => !e.value).map((e) => e.key).toList();
  }

  /// Get MVP module configuration
  static Map<String, bool> getMvpConfiguration() {
    return Map.unmodifiable(_mvpModules);
  }

  /// Enable a module (for future use)
  static void enableModule(String moduleName) {
    if (_mvpModules.containsKey(moduleName)) {
      print('Module $moduleName enabled');
    }
  }

  /// Disable a module (for future use)
  static void disableModule(String moduleName) {
    if (_mvpModules.containsKey(moduleName)) {
      print('Module $moduleName disabled');
    }
  }
}
