import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/setup_wizard/domain/entities/setup_configuration.dart';
import 'package:cat_hotel_pos/features/setup_wizard/domain/services/setup_wizard_service.dart';

// Setup wizard service provider
final setupWizardServiceProvider = Provider<SetupWizardService>((ref) {
  return SetupWizardService();
});

// Setup wizard state provider
final setupWizardProvider = StateNotifierProvider<SetupWizardNotifier, SetupConfiguration?>((ref) {
  final service = ref.read(setupWizardServiceProvider);
  return SetupWizardNotifier(service);
});

// Business configuration provider
final businessConfigProvider = Provider<BusinessConfiguration?>((ref) {
  final setup = ref.watch(setupWizardProvider);
  return setup?.businessConfig;
});

// Feature configuration provider
final featureConfigProvider = Provider<FeatureConfiguration?>((ref) {
  final setup = ref.watch(setupWizardProvider);
  return setup?.featureConfig;
});

// Permission configuration provider
final permissionConfigProvider = Provider<PermissionConfiguration?>((ref) {
  final setup = ref.watch(setupWizardProvider);
  return setup?.permissionConfig;
});

// Available modules provider
final availableModulesProvider = Provider<List<ModuleFeature>>((ref) {
  final featureConfig = ref.watch(featureConfigProvider);
  return featureConfig?.modules.where((module) => module.isEnabled).toList() ?? [];
});

// Disabled modules provider
final disabledModulesProvider = Provider<List<ModuleFeature>>((ref) {
  final featureConfig = ref.watch(featureConfigProvider);
  return featureConfig?.modules.where((module) => !module.isEnabled).toList() ?? [];
});

// Role permissions provider
final rolePermissionsProvider = Provider<Map<String, List<String>>>((ref) {
  final permissionConfig = ref.watch(permissionConfigProvider);
  return permissionConfig?.rolePermissions ?? {};
});

class SetupWizardNotifier extends StateNotifier<SetupConfiguration?> {
  final SetupWizardService _service;

  SetupWizardNotifier(this._service) : super(null) {
    _loadConfiguration();
  }

  Future<void> _loadConfiguration() async {
    try {
      final config = await _service.loadConfiguration();
      if (config != null) {
        state = config;
      } else {
        // Create default configuration if none exists
        state = _createDefaultConfiguration();
      }
    } catch (e) {
      print('Error loading setup configuration: $e');
      state = _createDefaultConfiguration();
    }
  }

  SetupConfiguration _createDefaultConfiguration() {
    return SetupConfiguration(
      businessConfig: BusinessConfiguration(
        businessName: 'Cat Hotel & Spa',
        businessType: 'Pet Hotel',
        address: '123 Pet Street, Cat City, CC 12345',
        phone: '+1-555-123-4567',
        email: 'info@cathotel.com',
        website: 'https://cathotel.com',
        currency: 'USD',
        timezone: 'America/New_York',
        language: 'en',
        services: ['Boarding', 'Daycare', 'Grooming', 'Veterinary Care'],
      ),
      featureConfig: FeatureConfiguration(
        modules: _getDefaultModules(),
        disabledFeatures: [],
        featureFlags: {
          'audit_logging': true,
          'backup_restore': true,
          'notifications': true,
          'offline_mode': true,
          'multi_language': false,
        },
      ),
      permissionConfig: PermissionConfiguration(
        roles: _getDefaultRoles(),
        rolePermissions: _getDefaultRolePermissions(),
      ),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: 'system',
      notes: 'Default configuration created by system',
    );
  }

  List<ModuleFeature> _getDefaultModules() {
    return [
      ModuleFeature(
        id: 'pos',
        name: 'POS System',
        description: 'Point of Sale system for transactions',
        isEnabled: true,
        isRequired: true,
        roles: ['admin', 'owner', 'manager', 'staff'],
        icon: 'point_of_sale',
        category: 'core',
      ),
      ModuleFeature(
        id: 'booking',
        name: 'Booking & Room Management',
        description: 'Manage reservations and room availability',
        isEnabled: true,
        isRequired: true,
        roles: ['admin', 'owner', 'manager', 'staff'],
        icon: 'hotel',
        category: 'core',
      ),
      ModuleFeature(
        id: 'customers',
        name: 'Customer & Pet Management',
        description: 'Manage customer and pet profiles',
        isEnabled: true,
        isRequired: true,
        roles: ['admin', 'owner', 'manager', 'staff'],
        icon: 'pets',
        category: 'core',
      ),
      ModuleFeature(
        id: 'inventory',
        name: 'Inventory & Purchasing',
        description: 'Manage stock, supplies, and purchases',
        isEnabled: true,
        isRequired: false,
        roles: ['admin', 'owner', 'manager'],
        icon: 'inventory',
        category: 'business',
      ),
      ModuleFeature(
        id: 'financials',
        name: 'Financial Operations',
        description: 'Track accounts, transactions, and budgets',
        isEnabled: true,
        isRequired: false,
        roles: ['admin', 'owner', 'manager'],
        icon: 'account_balance',
        category: 'business',
      ),
      ModuleFeature(
        id: 'staff',
        name: 'Staff Management',
        description: 'Manage staff, schedules, and roles',
        isEnabled: true,
        isRequired: false,
        roles: ['admin', 'owner', 'manager'],
        icon: 'people',
        category: 'business',
      ),
      ModuleFeature(
        id: 'loyalty',
        name: 'Loyalty & CRM',
        description: 'Manage loyalty programs and customer relationships',
        isEnabled: true,
        isRequired: false,
        roles: ['admin', 'owner'],
        icon: 'card_giftcard',
        category: 'premium',
      ),
      ModuleFeature(
        id: 'reports',
        name: 'Reports & Analytics',
        description: 'Business insights and performance reports',
        isEnabled: true,
        isRequired: false,
        roles: ['admin', 'owner', 'manager'],
        icon: 'analytics',
        category: 'business',
      ),
      ModuleFeature(
        id: 'services',
        name: 'Services Management',
        description: 'Manage pet care services and packages',
        isEnabled: true,
        isRequired: false,
        roles: ['admin', 'owner'],
        icon: 'spa',
        category: 'premium',
      ),
      ModuleFeature(
        id: 'payments',
        name: 'Payment Processing',
        description: 'Handle payments and invoicing',
        isEnabled: true,
        isRequired: false,
        roles: ['admin', 'owner', 'manager'],
        icon: 'payment',
        category: 'business',
      ),
    ];
  }

  List<RolePermission> _getDefaultRoles() {
    return [
      RolePermission(
        id: 'admin',
        name: 'Administrator',
        description: 'Full system access and control',
        permissions: ['*'],
        isActive: true,
        priority: 1,
      ),
      RolePermission(
        id: 'owner',
        name: 'Business Owner',
        description: 'Full business access and control',
        permissions: ['*'],
        isActive: true,
        priority: 2,
      ),
      RolePermission(
        id: 'manager',
        name: 'Manager',
        description: 'Business operations and staff management',
        permissions: [
          'pos:read', 'pos:write',
          'booking:read', 'booking:write',
          'customers:read', 'customers:write',
          'inventory:read', 'inventory:write',
          'financials:read', 'financials:write',
          'staff:read', 'staff:write',
          'reports:read',
        ],
        isActive: true,
        priority: 3,
      ),
      RolePermission(
        id: 'staff',
        name: 'Staff',
        description: 'Basic operations and customer service',
        permissions: [
          'pos:read', 'pos:write',
          'booking:read',
          'customers:read', 'customers:write',
          'reports:read',
        ],
        isActive: true,
        priority: 4,
      ),
    ];
  }

  Map<String, List<String>> _getDefaultRolePermissions() {
    return {
      'admin': ['*'],
      'owner': ['*'],
      'manager': [
        'pos:read', 'pos:write',
        'booking:read', 'booking:write',
        'customers:read', 'customers:write',
        'inventory:read', 'inventory:write',
        'financials:read', 'financials:write',
        'staff:read', 'staff:write',
        'reports:read',
      ],
      'staff': [
        'pos:read', 'pos:write',
        'booking:read',
        'customers:read', 'customers:write',
        'reports:read',
      ],
    };
  }

  void updateBusinessConfig(BusinessConfiguration config) {
    if (state != null) {
      state = state!.copyWith(
        businessConfig: config,
        updatedAt: DateTime.now(),
      );
    }
  }

  void updateFeatureConfig(FeatureConfiguration config) {
    if (state != null) {
      state = state!.copyWith(
        featureConfig: config,
        updatedAt: DateTime.now(),
      );
    }
  }

  void updatePermissionConfig(PermissionConfiguration config) {
    if (state != null) {
      state = state!.copyWith(
        permissionConfig: config,
        updatedAt: DateTime.now(),
      );
    }
  }

  void toggleModule(String moduleId, bool isEnabled) {
    if (state != null) {
      final updatedModules = state!.featureConfig.modules.map((module) {
        if (module.id == moduleId) {
          return module.copyWith(isEnabled: isEnabled);
        }
        return module;
      }).toList();

      final updatedFeatureConfig = state!.featureConfig.copyWith(
        modules: updatedModules,
      );

      state = state!.copyWith(
        featureConfig: updatedFeatureConfig,
        updatedAt: DateTime.now(),
      );
    }
  }

  void toggleFeatureFlag(String flag, bool value) {
    if (state != null) {
      final updatedFlags = Map<String, bool>.from(state!.featureConfig.featureFlags);
      updatedFlags[flag] = value;

      final updatedFeatureConfig = state!.featureConfig.copyWith(
        featureFlags: updatedFlags,
      );

      state = state!.copyWith(
        featureConfig: updatedFeatureConfig,
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<void> saveConfiguration() async {
    if (state != null) {
      try {
        await _service.saveConfiguration(state!);
        print('Setup configuration saved successfully');
      } catch (e) {
        print('Error saving setup configuration: $e');
        rethrow;
      }
    }
  }

  Future<void> resetToDefaults() async {
    state = _createDefaultConfiguration();
    await saveConfiguration();
  }
}
