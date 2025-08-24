import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/setup_wizard/presentation/providers/setup_wizard_providers.dart';
import 'package:cat_hotel_pos/features/setup_wizard/domain/entities/setup_configuration.dart';

class SetupCompletionTab extends ConsumerWidget {
  final VoidCallback onPrevious;
  final VoidCallback onComplete;
  final Function(int) onGoToStep;

  const SetupCompletionTab({
    super.key,
    required this.onPrevious,
    required this.onComplete,
    required this.onGoToStep,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setupConfig = ref.watch(setupWizardProvider);
    
    if (setupConfig == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.purple,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Setup Completion',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Review your configuration and complete the setup. You can go back to any step to make changes.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.purple[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Configuration Summary
          _buildSectionHeader(context, 'Configuration Summary', Icons.summarize),
          const SizedBox(height: 16),
          
          _buildConfigurationSummary(context, setupConfig),
          
          const SizedBox(height: 32),
          
          // Step Review
          _buildSectionHeader(context, 'Step Review', Icons.assignment),
          const SizedBox(height: 16),
          
          _buildStepReview(context),
          
          const SizedBox(height: 32),
          
          // Recommendations
          _buildSectionHeader(context, 'Recommendations', Icons.lightbulb),
          const SizedBox(height: 16),
          
          _buildRecommendations(context, setupConfig),
          
          const SizedBox(height: 32),
          
          // Final Actions
          _buildSectionHeader(context, 'Final Actions', Icons.play_arrow),
          const SizedBox(height: 16),
          
          _buildFinalActions(context),
          
          const SizedBox(height: 32),
          
          // Navigation Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onPrevious,
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
                  onPressed: onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Complete Setup'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfigurationSummary(BuildContext context, SetupConfiguration setupConfig) {
    final businessConfig = setupConfig.businessConfig;
    final featureConfig = setupConfig.featureConfig;
    final permissionConfig = setupConfig.permissionConfig;
    
    final enabledModules = featureConfig.modules.where((m) => m.isEnabled).length;
    final totalModules = featureConfig.modules.length;
    final activeRoles = permissionConfig.roles.where((r) => r.isActive).length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.business, color: Colors.green[600]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessConfig.businessName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    Text(
                      businessConfig.businessType,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  context,
                  'Modules',
                  '$enabledModules / $totalModules',
                  Icons.apps,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  'Active Roles',
                  '$activeRoles',
                  Icons.people,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  'Services',
                  '${businessConfig.services.length}',
                  Icons.spa,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String label, String value, IconData icon, Color color) {
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

  Widget _buildStepReview(BuildContext context) {
    final steps = <Map<String, dynamic>>[
      {'title': 'Business Configuration', 'icon': Icons.business, 'color': Colors.blue},
      {'title': 'Feature Configuration', 'icon': Icons.featured_play_list, 'color': Colors.green},
      {'title': 'Permission Setup', 'icon': Icons.security, 'color': Colors.orange},
      {'title': 'Setup Completion', 'icon': Icons.check_circle, 'color': Colors.purple},
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: step['color']!.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                step['icon'] as IconData,
                color: step['color'] as Color,
                size: 20,
              ),
            ),
            title: Text(
              step['title'] as String,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('Step ${index + 1} of ${steps.length}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (index < steps.length - 1)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => onGoToStep(index),
                    tooltip: 'Edit this step',
                  ),
                Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRecommendations(BuildContext context, SetupConfiguration setupConfig) {
    final recommendations = <Widget>[];
    
    // Check business configuration
    if (setupConfig.businessConfig.website == null || 
        setupConfig.businessConfig.website!.isEmpty) {
      recommendations.add(_buildRecommendation(
        context,
        'Add Business Website',
        'Consider adding a website URL for better customer experience',
        Icons.language,
        Colors.blue,
      ));
    }
    
    if (setupConfig.businessConfig.services.length < 3) {
      recommendations.add(_buildRecommendation(
        context,
        'Expand Services',
        'Adding more services can help attract more customers',
        Icons.spa,
        Colors.green,
      ));
    }
    
    // Check feature configuration
    final disabledModules = setupConfig.featureConfig.modules
        .where((m) => !m.isEnabled && !m.isRequired)
        .toList();
    
    if (disabledModules.isNotEmpty) {
      recommendations.add(_buildRecommendation(
        context,
        'Review Disabled Modules',
        '${disabledModules.length} modules are currently disabled. Consider enabling them if needed.',
        Icons.apps,
        Colors.orange,
      ));
    }
    
    // Check permission configuration
    final activeRoles = setupConfig.permissionConfig.roles
        .where((r) => r.isActive)
        .length;
    
    if (activeRoles < 2) {
      recommendations.add(_buildRecommendation(
        context,
        'Role Diversity',
        'Consider enabling more roles for better staff management',
        Icons.people,
        Colors.purple,
      ));
    }
    
    if (recommendations.isEmpty) {
      recommendations.add(_buildRecommendation(
        context,
        'Great Configuration!',
        'Your setup looks comprehensive and well-configured.',
        Icons.thumb_up,
        Colors.green,
      ));
    }
    
    return Column(children: recommendations);
  }

  Widget _buildRecommendation(BuildContext context, String title, String description, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.amber[600]),
              const SizedBox(width: 12),
              Text(
                'Before You Complete Setup',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.amber[800],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          _buildActionItem(
            'Review all configurations carefully',
            Icons.checklist,
          ),
          _buildActionItem(
            'Ensure business information is accurate',
            Icons.business,
          ),
          _buildActionItem(
            'Verify role permissions are correct',
            Icons.security,
          ),
          _buildActionItem(
            'Test the system with a staff account',
            Icons.person,
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.amber[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You can always access the Setup Wizard later from the Settings menu to make changes.',
                    style: TextStyle(
                      color: Colors.amber[800],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.amber[600], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: Colors.purple, size: 20),
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
}
