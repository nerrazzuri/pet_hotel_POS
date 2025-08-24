import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/setup_wizard/domain/entities/setup_configuration.dart';
import 'package:cat_hotel_pos/features/setup_wizard/presentation/providers/setup_wizard_providers.dart';

class PermissionSetupTab extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final Function(PermissionConfiguration) onStepComplete;

  const PermissionSetupTab({
    super.key,
    required this.onNext,
    required this.onPrevious,
    required this.onStepComplete,
  });

  @override
  ConsumerState<PermissionSetupTab> createState() => _PermissionSetupTabState();
}

class _PermissionSetupTabState extends ConsumerState<PermissionSetupTab> {
  late PermissionConfiguration _currentConfig;
  final Map<String, List<String>> _rolePermissions = {};
  final Map<String, bool> _roleStates = {};

  @override
  void initState() {
    super.initState();
    _loadCurrentConfiguration();
  }

  void _loadCurrentConfiguration() {
    final config = ref.read(permissionConfigProvider);
    if (config != null) {
      _currentConfig = config;
      _rolePermissions.addAll(config.rolePermissions);
      // Initialize role states
      for (final role in config.roles) {
        _roleStates[role.id] = role.isActive;
      }
    } else {
      _currentConfig = PermissionConfiguration(
        roles: [],
        rolePermissions: {},
      );
    }
  }

  void _togglePermission(String roleId, String permission) {
    setState(() {
      if (_rolePermissions[roleId]?.contains(permission) == true) {
        _rolePermissions[roleId]!.remove(permission);
      } else {
        _rolePermissions[roleId] ??= [];
        _rolePermissions[roleId]!.add(permission);
      }
    });
  }

  void _toggleRole(String roleId, bool isActive) {
    setState(() {
      _roleStates[roleId] = isActive;
    });
  }

  void _nextStep() {
    // Create updated configuration
    final updatedRoles = _currentConfig.roles.map((role) {
      return role.copyWith(isActive: _roleStates[role.id] ?? role.isActive);
    }).toList();

    final updatedConfig = PermissionConfiguration(
      roles: updatedRoles,
      rolePermissions: Map.from(_rolePermissions),
    );

    widget.onStepComplete(updatedConfig);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    final roles = ref.watch(permissionConfigProvider)?.roles ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.security,
                    color: Colors.orange,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Permission Setup',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[800],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Configure role-based access control and permissions for your staff. Define what each role can access and modify.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Role Management Section
          _buildSectionHeader('Role Management', Icons.people),
          const SizedBox(height: 16),
          
          Text(
            'Manage user roles and their active status. Disabled roles will not be available for assignment.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Role Cards
          ...roles.map((role) => _buildRoleCard(role)),
          
          const SizedBox(height: 32),
          
          // Permission Matrix Section
          _buildSectionHeader('Permission Matrix', Icons.security),
          const SizedBox(height: 16),
          
          Text(
            'Configure permissions for each role. Use the matrix below to grant or revoke access to specific features.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Permission Matrix
          _buildPermissionMatrix(),
          
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
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Continue to Setup Completion'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(RolePermission role) {
    final isActive = _roleStates[role.id] ?? role.isActive;
    final roleColor = _getRoleColor(role.id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isActive ? 4 : 1,
      color: isActive ? Colors.white : Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: roleColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getRoleIcon(role.id),
                color: roleColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.grey[800] : Colors.grey[600],
                    ),
                  ),
                  Text(
                    role.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isActive ? Colors.grey[600] : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Priority: ${role.priority}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: roleColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isActive,
              onChanged: (value) => _toggleRole(role.id, value),
              activeColor: roleColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionMatrix() {
    final roles = ref.watch(permissionConfigProvider)?.roles ?? [];
    final allPermissions = _getAllPermissions();
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          const DataColumn(label: Text('Permission')),
          ...roles.map((role) => DataColumn(
            label: Text(role.name),
            tooltip: role.description,
          )),
        ],
        rows: allPermissions.map((permission) {
          return DataRow(
            cells: [
              DataCell(
                Text(
                  _getPermissionDisplayName(permission),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              ...roles.map((role) {
                final hasPermission = _rolePermissions[role.id]?.contains(permission) ?? false;
                final isRoleActive = _roleStates[role.id] ?? role.isActive;
                
                return DataCell(
                  Checkbox(
                    value: hasPermission && isRoleActive,
                    onChanged: isRoleActive ? (value) {
                      _togglePermission(role.id, permission);
                    } : null,
                    activeColor: _getRoleColor(role.id),
                  ),
                );
              }),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummarySection() {
    final activeRoles = _roleStates.values.where((active) => active).length;
    final totalRoles = _roleStates.length;
    final totalPermissions = _getAllPermissions().length;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.summarize, color: Colors.orange[600]),
              const SizedBox(width: 8),
              Text(
                'Permission Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Active Roles',
                  '$activeRoles / $totalRoles',
                  Icons.people,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Total Permissions',
                  '$totalPermissions',
                  Icons.security,
                  Colors.red,
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
            color: Colors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: Colors.orange, size: 20),
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

  Color _getRoleColor(String roleId) {
    switch (roleId.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'owner':
        return Colors.purple;
      case 'manager':
        return Colors.blue;
      case 'staff':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String roleId) {
    switch (roleId.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'owner':
        return Icons.business;
      case 'manager':
        return Icons.manage_accounts;
      case 'staff':
        return Icons.person;
      default:
        return Icons.people;
    }
  }

  List<String> _getAllPermissions() {
    final permissions = <String>{};
    for (final rolePermissions in _rolePermissions.values) {
      permissions.addAll(rolePermissions);
    }
    
    // Add common permissions
    permissions.addAll([
      'pos:read',
      'pos:write',
      'booking:read',
      'booking:write',
      'customers:read',
      'customers:write',
      'inventory:read',
      'inventory:write',
      'financials:read',
      'financials:write',
      'staff:read',
      'staff:write',
      'reports:read',
      'reports:write',
      'settings:read',
      'settings:write',
    ]);
    
    return permissions.toList()..sort();
  }

  String _getPermissionDisplayName(String permission) {
    final parts = permission.split(':');
    if (parts.length == 2) {
      final module = parts[0].toUpperCase();
      final action = parts[1] == 'read' ? 'View' : 'Manage';
      return '$action $module';
    }
    return permission.replaceAll(':', ' ').toUpperCase();
  }
}
