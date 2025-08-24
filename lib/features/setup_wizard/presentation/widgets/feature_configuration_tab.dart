import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/setup_wizard/domain/entities/setup_configuration.dart';
import 'package:cat_hotel_pos/features/setup_wizard/presentation/providers/setup_wizard_providers.dart';

class FeatureConfigurationTab extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final Function(FeatureConfiguration) onStepComplete;

  const FeatureConfigurationTab({
    super.key,
    required this.onNext,
    required this.onPrevious,
    required this.onStepComplete,
  });

  @override
  ConsumerState<FeatureConfigurationTab> createState() => _FeatureConfigurationTabState();
}

class _FeatureConfigurationTabState extends ConsumerState<FeatureConfigurationTab> {
  late FeatureConfiguration _currentConfig;
  final Map<String, bool> _moduleStates = {};
  final Map<String, bool> _featureFlags = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentConfiguration();
  }

  void _loadCurrentConfiguration() {
    final config = ref.read(featureConfigProvider);
    if (config != null) {
      _currentConfig = config;
      // Initialize module states
      for (final module in config.modules) {
        _moduleStates[module.id] = module.isEnabled;
      }
      // Initialize feature flags
      _featureFlags.addAll(config.featureFlags);
    } else {
      // Create default configuration
      _currentConfig = FeatureConfiguration(
        modules: [],
        disabledFeatures: [],
        featureFlags: {},
      );
    }
  }

  void _toggleModule(String moduleId, bool value) {
    setState(() {
      _moduleStates[moduleId] = value;
    });
    
    // Update the provider
    ref.read(setupWizardProvider.notifier).toggleModule(moduleId, value);
  }

  void _toggleFeatureFlag(String flag, bool value) {
    setState(() {
      _featureFlags[flag] = value;
    });
    
    // Update the provider
    ref.read(setupWizardProvider.notifier).toggleFeatureFlag(flag, value);
  }

  void _nextStep() {
    // Create updated configuration
    final updatedModules = _currentConfig.modules.map((module) {
      return module.copyWith(isEnabled: _moduleStates[module.id] ?? module.isEnabled);
    }).toList();

    final updatedConfig = FeatureConfiguration(
      modules: updatedModules,
      disabledFeatures: _currentConfig.disabledFeatures,
      featureFlags: Map.from(_featureFlags),
    );

    widget.onStepComplete(updatedConfig);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final modules = ref.watch(availableModulesProvider);
    final disabledModules = ref.watch(disabledModulesProvider);
    final allModules = [...modules, ...disabledModules];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.featured_play_list,
                    color: Colors.green,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Feature Configuration',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enable or disable system features and modules based on your business needs. Core features cannot be disabled.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Module Configuration Section
          _buildSectionHeader('System Modules', Icons.apps),
          const SizedBox(height: 16),
          
          Text(
            'Configure which modules are available to your staff. Core modules are required and cannot be disabled.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Module Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 2.5,
            ),
            itemCount: allModules.length,
            itemBuilder: (context, index) {
              final module = allModules[index];
              final isEnabled = _moduleStates[module.id] ?? module.isEnabled;
              
              return _buildModuleCard(context, module, isEnabled);
            },
          ),
          
          const SizedBox(height: 32),
          
          // System Features Section
          _buildSectionHeader('System Features', Icons.tune),
          const SizedBox(height: 16),
          
          Text(
            'Configure system-level features that affect the overall functionality.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Feature Flags
          _buildFeatureFlagsSection(),
          
          const SizedBox(height: 32),
          
          // Summary Section
          _buildSummarySection(),
          
          const SizedBox(height: 32),
          
          // Navigation Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onPrevious,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Previous'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Continue to Permission Setup'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModuleCard(BuildContext context, ModuleFeature module, bool isEnabled) {
    final isRequired = module.isRequired;
    final categoryColor = _getCategoryColor(module.category ?? 'general');
    
    return Card(
      elevation: isEnabled ? 4 : 1,
      color: isEnabled ? Colors.white : Colors.grey[100],
      child: InkWell(
        onTap: isRequired ? null : () => _toggleModule(module.id, !isEnabled),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: categoryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getModuleIcon(module.icon),
                      color: categoryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          module.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isEnabled ? Colors.grey[800] : Colors.grey[600],
                          ),
                        ),
                        Text(
                          (module.category ?? 'GENERAL').toUpperCase(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: categoryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isRequired)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'REQUIRED',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  else
                    Switch(
                      value: isEnabled,
                      onChanged: (value) => _toggleModule(module.id, value),
                      activeColor: Colors.green,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                module.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isEnabled ? Colors.grey[600] : Colors.grey[500],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: module.roles.map((role) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      role,
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureFlagsSection() {
    final featureFlags = ref.watch(featureConfigProvider)?.featureFlags ?? {};
    
    return Column(
      children: featureFlags.entries.map((entry) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: SwitchListTile(
            title: Text(_getFeatureName(entry.key)),
            subtitle: Text(_getFeatureDescription(entry.key)),
            value: _featureFlags[entry.key] ?? entry.value,
            onChanged: (value) => _toggleFeatureFlag(entry.key, value),
            secondary: Icon(
              _getFeatureIcon(entry.key),
              color: Colors.green,
            ),
            activeColor: Colors.green,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummarySection() {
    final enabledModules = _moduleStates.values.where((enabled) => enabled).length;
    final totalModules = _moduleStates.length;
    final enabledFeatures = _featureFlags.values.where((enabled) => enabled).length;
    final totalFeatures = _featureFlags.length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Text(
                'Configuration Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Modules Enabled',
                  '$enabledModules / $totalModules',
                  Icons.apps,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Features Enabled',
                  '$enabledFeatures / $totalFeatures',
                  Icons.tune,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: Colors.green, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'core':
        return Colors.red;
      case 'business':
        return Colors.blue;
      case 'premium':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getModuleIcon(String? iconName) {
    switch (iconName) {
      case 'point_of_sale':
        return Icons.point_of_sale;
      case 'hotel':
        return Icons.hotel;
      case 'pets':
        return Icons.pets;
      case 'inventory':
        return Icons.inventory;
      case 'account_balance':
        return Icons.account_balance;
      case 'people':
        return Icons.people;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'analytics':
        return Icons.analytics;
      case 'spa':
        return Icons.spa;
      case 'payment':
        return Icons.payment;
      default:
        return Icons.apps;
    }
  }

  String _getFeatureName(String feature) {
    switch (feature) {
      case 'audit_logging':
        return 'Audit Logging';
      case 'backup_restore':
        return 'Backup & Restore';
      case 'notifications':
        return 'Notifications';
      case 'offline_mode':
        return 'Offline Mode';
      case 'multi_language':
        return 'Multi-Language Support';
      default:
        return feature.replaceAll('_', ' ').toUpperCase();
    }
  }

  String _getFeatureDescription(String feature) {
    switch (feature) {
      case 'audit_logging':
        return 'Track all system activities for security and compliance';
      case 'backup_restore':
        return 'Automated data backup and recovery functionality';
      case 'notifications':
        return 'Email, SMS, and push notification system';
      case 'offline_mode':
        return 'Work without internet connection';
      case 'multi_language':
        return 'Support for multiple languages';
      default:
        return 'System feature configuration';
    }
  }

  IconData _getFeatureIcon(String feature) {
    switch (feature) {
      case 'audit_logging':
        return Icons.security;
      case 'backup_restore':
        return Icons.backup;
      case 'notifications':
        return Icons.notifications;
      case 'offline_mode':
        return Icons.cloud_off;
      case 'multi_language':
        return Icons.language;
      default:
        return Icons.tune;
    }
  }
}
