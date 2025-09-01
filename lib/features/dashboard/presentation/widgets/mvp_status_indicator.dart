import 'package:flutter/material.dart';
import 'package:cat_hotel_pos/core/app_config.dart';

class MvpStatusIndicator extends StatelessWidget {
  const MvpStatusIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final enabledModules = AppConfig.getEnabledModules();
    final disabledModules = AppConfig.getDisabledModules();

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.rocket_launch, color: Colors.green[700]),
                const SizedBox(width: 8),
                const Text(
                  'MVP Mode Active',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${enabledModules.length} Active',
                    style: TextStyle(
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Enabled Modules:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: enabledModules.map((module) => _buildModuleChip(module, true)).toList(),
            ),
            if (disabledModules.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Disabled for MVP (Available in Future):',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: disabledModules.map((module) => _buildModuleChip(module, false)).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModuleChip(String moduleName, bool isEnabled) {
    final displayName = _getModuleDisplayName(moduleName);
    final color = isEnabled ? Colors.green : Colors.grey;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        displayName,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getModuleDisplayName(String moduleName) {
    switch (moduleName) {
      case 'pos':
        return 'POS System';
      case 'booking':
        return 'Booking & Rooms';
      case 'customers':
        return 'Customer & Pet Profiles';
      case 'services':
        return 'Services & Products';
      case 'payments':
        return 'Payments & Invoicing';
      case 'reports':
        return 'Reports & Analytics';
      case 'staff':
        return 'Staff & Roles';
      case 'financials':
        return 'Financial Operations';
      case 'loyalty':
        return 'Loyalty Programs';
      case 'crm':
        return 'CRM Management';
      case 'inventory':
        return 'Inventory & Purchasing';
      case 'settings':
        return 'Settings';
      case 'setup_wizard':
        return 'Setup Wizard';
      default:
        return moduleName;
    }
  }
}
