import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cat_hotel_pos/features/setup_wizard/domain/entities/setup_configuration.dart';

class SetupWizardService {
  static const String _configKey = 'setup_wizard_configuration';
  static const String _isFirstTimeKey = 'is_first_time_setup';

  // Check if this is the first time setup
  Future<bool> isFirstTimeSetup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isFirstTimeKey) ?? true;
    } catch (e) {
      print('Error checking first time setup: $e');
      return true;
    }
  }

  // Mark setup as completed
  Future<void> markSetupCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isFirstTimeKey, false);
    } catch (e) {
      print('Error marking setup as completed: $e');
    }
  }

  // Load configuration from storage
  Future<SetupConfiguration?> loadConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString(_configKey);
      
      if (configJson != null) {
        final configMap = json.decode(configJson) as Map<String, dynamic>;
        return SetupConfiguration.fromJson(configMap);
      }
      
      return null;
    } catch (e) {
      print('Error loading setup configuration: $e');
      return null;
    }
  }

  // Save configuration to storage
  Future<void> saveConfiguration(SetupConfiguration config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = json.encode(config.toJson());
      await prefs.setString(_configKey, configJson);
      
      // Mark setup as completed when saving
      await markSetupCompleted();
    } catch (e) {
      print('Error saving setup configuration: $e');
      rethrow;
    }
  }

  // Delete configuration
  Future<void> deleteConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_configKey);
      await prefs.setBool(_isFirstTimeKey, true);
    } catch (e) {
      print('Error deleting setup configuration: $e');
    }
  }

  // Reset to first time setup
  Future<void> resetToFirstTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isFirstTimeKey, true);
    } catch (e) {
      print('Error resetting to first time setup: $e');
    }
  }

  // Export configuration
  Future<String> exportConfiguration(SetupConfiguration config) async {
    try {
      final configMap = config.toJson();
      configMap['exportedAt'] = DateTime.now().toIso8601String();
      configMap['version'] = '1.0.0';
      
      return json.encode(configMap);
    } catch (e) {
      print('Error exporting configuration: $e');
      rethrow;
    }
  }

  // Import configuration
  Future<SetupConfiguration> importConfiguration(String configJson) async {
    try {
      final configMap = json.decode(configJson) as Map<String, dynamic>;
      
      // Remove export metadata
      configMap.remove('exportedAt');
      configMap.remove('version');
      
      // Update timestamps
      final now = DateTime.now();
      configMap['createdAt'] = now.toIso8601String();
      configMap['updatedAt'] = now.toIso8601String();
      
      return SetupConfiguration.fromJson(configMap);
    } catch (e) {
      print('Error importing configuration: $e');
      rethrow;
    }
  }

  // Validate configuration
  bool validateConfiguration(SetupConfiguration config) {
    try {
      // Check required fields
      if (config.businessConfig.businessName.isEmpty) return false;
      if (config.businessConfig.businessType.isEmpty) return false;
      if (config.businessConfig.address.isEmpty) return false;
      if (config.businessConfig.phone.isEmpty) return false;
      if (config.businessConfig.email.isEmpty) return false;
      
      // Check if at least core modules are enabled
      final coreModules = config.featureConfig.modules
          .where((module) => module.isRequired)
          .toList();
      
      final enabledCoreModules = coreModules
          .where((module) => module.isEnabled)
          .toList();
      
      if (enabledCoreModules.length != coreModules.length) return false;
      
      // Check if roles have permissions
      if (config.permissionConfig.roles.isEmpty) return false;
      
      return true;
    } catch (e) {
      print('Error validating configuration: $e');
      return false;
    }
  }

  // Get configuration summary
  Map<String, dynamic> getConfigurationSummary(SetupConfiguration config) {
    try {
      final enabledModules = config.featureConfig.modules
          .where((module) => module.isEnabled)
          .length;
      
      final totalModules = config.featureConfig.modules.length;
      
      final enabledFeatures = config.featureConfig.featureFlags
          .entries
          .where((entry) => entry.value)
          .length;
      
      final totalFeatures = config.featureConfig.featureFlags.length;
      
      final activeRoles = config.permissionConfig.roles
          .where((role) => role.isActive)
          .length;
      
      return {
        'businessName': config.businessConfig.businessName,
        'businessType': config.businessConfig.businessType,
        'enabledModules': enabledModules,
        'totalModules': totalModules,
        'enabledFeatures': enabledFeatures,
        'totalFeatures': totalFeatures,
        'activeRoles': activeRoles,
        'lastUpdated': config.updatedAt.toIso8601String(),
        'isValid': validateConfiguration(config),
      };
    } catch (e) {
      print('Error getting configuration summary: $e');
      return {};
    }
  }

  // Check if configuration needs update
  bool needsUpdate(SetupConfiguration config) {
    try {
      final now = DateTime.now();
      final daysSinceUpdate = now.difference(config.updatedAt).inDays;
      
      // Suggest update if more than 30 days old
      return daysSinceUpdate > 30;
    } catch (e) {
      print('Error checking if configuration needs update: $e');
      return false;
    }
  }

  // Get recommended updates
  List<String> getRecommendedUpdates(SetupConfiguration config) {
    final recommendations = <String>[];
    
    try {
      // Check for disabled core features
      final disabledCoreFeatures = config.featureConfig.featureFlags.entries
          .where((entry) => !entry.value && _isCoreFeature(entry.key))
          .map((entry) => entry.key)
          .toList();
      
      if (disabledCoreFeatures.isNotEmpty) {
        recommendations.add('Consider enabling core features: ${disabledCoreFeatures.join(', ')}');
      }
      
      // Check for unused modules
      final unusedModules = config.featureConfig.modules
          .where((module) => !module.isEnabled && !module.isRequired)
          .map((module) => module.name)
          .toList();
      
      if (unusedModules.isNotEmpty) {
        recommendations.add('Review disabled modules: ${unusedModules.join(', ')}');
      }
      
      // Check for missing business information
      if (config.businessConfig.website == null || config.businessConfig.website!.isEmpty) {
        recommendations.add('Add business website for better customer experience');
      }
      
      if (config.businessConfig.services.length < 3) {
        recommendations.add('Consider adding more services to attract customers');
      }
      
    } catch (e) {
      print('Error getting recommended updates: $e');
    }
    
    return recommendations;
  }

  bool _isCoreFeature(String feature) {
    const coreFeatures = [
      'audit_logging',
      'notifications',
      'offline_mode',
    ];
    
    return coreFeatures.contains(feature);
  }
}
