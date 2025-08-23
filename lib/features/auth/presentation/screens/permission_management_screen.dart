import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/auth/domain/entities/user.dart';
import 'package:cat_hotel_pos/features/auth/domain/entities/permission.dart';
import 'package:cat_hotel_pos/features/auth/domain/entities/audit_log.dart';
import 'package:cat_hotel_pos/features/auth/presentation/providers/auth_providers.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/permission_service.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/audit_service.dart';

class PermissionManagementScreen extends ConsumerStatefulWidget {
  const PermissionManagementScreen({super.key});

  @override
  ConsumerState<PermissionManagementScreen> createState() => _PermissionManagementScreenState();
}

class _PermissionManagementScreenState extends ConsumerState<PermissionManagementScreen> {
  final PermissionService _permissionService = PermissionService();
  final AuditService _auditService = AuditService();
  
  // Mock users for demonstration
  late List<User> _users;
  late Map<String, Map<String, bool>> _userPermissions;
  
  @override
  void initState() {
    super.initState();
    _initializeUsers();
  }
  
  void _initializeUsers() {
    _users = [
      User(
        id: 'staff_001',
        username: 'john_staff',
        email: 'john@cathotel.com',
        fullName: 'John Staff',
        role: UserRole.staff,
        permissions: {},
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isActive: true,
      ),
      User(
        id: 'manager_001',
        username: 'sarah_manager',
        email: 'sarah@cathotel.com',
        fullName: 'Sarah Manager',
        role: UserRole.manager,
        permissions: {},
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isActive: true,
      ),
      User(
        id: 'owner_001',
        username: 'mike_owner',
        email: 'mike@cathotel.com',
        fullName: 'Mike Owner',
        role: UserRole.owner,
        permissions: {},
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        isActive: true,
      ),
    ];
    
    _userPermissions = {};
    for (final user in _users) {
      _userPermissions[user.id] = _permissionService.getAllUserPermissions(user);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    
    if (currentUser == null || !_permissionService.canManagePermissions(currentUser)) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 64,
                color: Colors.red,
              ),
              SizedBox(height: 16),
              Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'You do not have permission to access this screen.',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Permission Management'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePermissions,
            tooltip: 'Save Changes',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showAuditLogs,
            tooltip: 'View Audit Logs',
          ),
        ],
      ),
      body: Row(
        children: [
          // Left side - User list
          Expanded(
            flex: 1,
            child: _buildUserList(),
          ),
          
          // Right side - Permission management
          Expanded(
            flex: 2,
            child: _buildPermissionManagement(),
          ),
        ],
      ),
    );
  }

  Widget _buildUserList() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: const Text(
              'Users',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return _buildUserListItem(user);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListItem(User user) {
    final isSelected = _selectedUser?.id == user.id;
    
    return ListTile(
      selected: isSelected,
      selectedTileColor: Colors.teal.shade50,
      leading: CircleAvatar(
        backgroundColor: _getRoleColor(user.role),
        child: Text(
          user.fullName.split(' ').map((n) => n[0]).join(''),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        user.fullName,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${user.role.name.toUpperCase()} • ${user.username}',
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
      onTap: () => _selectUser(user),
    );
  }

  Widget _buildPermissionManagement() {
    if (_selectedUser == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Select a user to manage permissions',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _getRoleColor(_selectedUser!.role),
                child: Text(
                  _selectedUser!.fullName.split(' ').map((n) => n[0]).join(''),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedUser!.fullName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_selectedUser!.role.name.toUpperCase()} • ${_selectedUser!.username}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Text(
                  _selectedUser!.role.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: _getRoleColor(_selectedUser!.role),
              ),
            ],
          ),
        ),
        
        // Permission categories
        Expanded(
          child: _buildPermissionCategories(),
        ),
      ],
    );
  }

  Widget _buildPermissionCategories() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.5, // Make cards rectangular (wider than tall)
      ),
      itemCount: _getPermissionCategories().length,
      itemBuilder: (context, index) {
        final category = _getPermissionCategories()[index];
        return _buildPermissionCategoryCard(category['title']!, category['permissions']!);
      },
    );
  }

  List<Map<String, dynamic>> _getPermissionCategories() {
    return [
      {
        'title': 'Sales & POS',
        'permissions': [
          SystemPermissions.salesRegister,
          SystemPermissions.applyDiscount,
          SystemPermissions.voidTransaction,
          SystemPermissions.refundTransaction,
          SystemPermissions.splitBill,
          SystemPermissions.holdCart,
        ],
      },
      {
        'title': 'Customer Management',
        'permissions': [
          SystemPermissions.viewCustomer,
          SystemPermissions.addCustomer,
          SystemPermissions.editCustomer,
          SystemPermissions.deleteCustomer,
          SystemPermissions.viewPetProfile,
          SystemPermissions.editPetProfile,
        ],
      },
      {
        'title': 'Booking & Rooms',
        'permissions': [
          SystemPermissions.viewBookings,
          SystemPermissions.createBooking,
          SystemPermissions.editBooking,
          SystemPermissions.cancelBooking,
          SystemPermissions.viewRooms,
          SystemPermissions.manageRooms,
        ],
      },
      {
        'title': 'Inventory & Services',
        'permissions': [
          SystemPermissions.viewInventory,
          SystemPermissions.editInventory,
          SystemPermissions.manageServices,
          SystemPermissions.manageProducts,
          SystemPermissions.viewSuppliers,
          SystemPermissions.manageSuppliers,
        ],
      },
      {
        'title': 'Reports & Analytics',
        'permissions': [
          SystemPermissions.viewBasicReports,
          SystemPermissions.viewFinancialReports,
          SystemPermissions.viewAnalytics,
          SystemPermissions.exportReports,
        ],
      },
      {
        'title': 'Staff Management',
        'permissions': [
          SystemPermissions.viewStaff,
          SystemPermissions.manageStaff,
          SystemPermissions.viewSchedules,
          SystemPermissions.manageSchedules,
        ],
      },
      {
        'title': 'System Settings',
        'permissions': [
          SystemPermissions.viewSettings,
          SystemPermissions.manageSettings,
          SystemPermissions.managePermissions,
          SystemPermissions.viewAuditLogs,
        ],
      },
      {
        'title': 'Financial Operations',
        'permissions': [
          SystemPermissions.viewFinancials,
          SystemPermissions.managePricing,
          SystemPermissions.viewTaxReports,
          SystemPermissions.manageLoyalty,
        ],
      },
    ];
  }

  Widget _buildPermissionCategoryCard(String title, List<String> permissions) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showPermissionDetails(title, permissions),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(title),
                    color: Colors.teal,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${permissions.length} permissions',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: _getEnabledPermissionCount(permissions) / permissions.length,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_getEnabledPermissionCount(permissions)}/${permissions.length}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getEnabledPermissionCount(List<String> permissions) {
    if (_selectedUser == null) return 0;
    return permissions.where((permission) => 
      _userPermissions[_selectedUser!.id]?[permission] ?? false
    ).length;
  }

  IconData _getCategoryIcon(String title) {
    switch (title) {
      case 'Sales & POS':
        return Icons.point_of_sale;
      case 'Customer Management':
        return Icons.people;
      case 'Booking & Rooms':
        return Icons.hotel;
      case 'Inventory & Services':
        return Icons.inventory;
      case 'Reports & Analytics':
        return Icons.analytics;
      case 'Staff Management':
        return Icons.manage_accounts;
      case 'System Settings':
        return Icons.settings;
      case 'Financial Operations':
        return Icons.account_balance_wallet;
      default:
        return Icons.category;
    }
  }

  void _showPermissionDetails(String title, List<String> permissions) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 600,
          height: 500,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(title),
                        color: Colors.teal,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: permissions.length,
                  itemBuilder: (context, index) {
                    final permissionKey = permissions[index];
                    return _buildPermissionItem(permissionKey);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem(String permissionKey) {
    final isEnabled = _userPermissions[_selectedUser!.id]?[permissionKey] ?? false;
    final permissionName = _getPermissionDisplayName(permissionKey);
    
    return ListTile(
      title: Text(permissionName),
      subtitle: Text(
        permissionKey,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: isEnabled,
        onChanged: (value) {
          _updatePermission(permissionKey, value);
        },
        activeColor: Colors.teal,
      ),
    );
  }

  void _updatePermission(String permissionKey, bool value) {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    setState(() {
      _userPermissions[_selectedUser!.id]![permissionKey] = value;
    });

    // Log the permission change
    _auditService.logPermissionChange(
      userId: currentUser.id,
      userEmail: currentUser.email,
      userRole: currentUser.role.name,
      targetUserId: _selectedUser!.id,
      targetUserRole: _selectedUser!.role.name,
      permission: permissionKey,
      granted: value,
      reason: 'Permission updated by ${currentUser.fullName}',
    );
  }

  String _getPermissionDisplayName(String permissionKey) {
    switch (permissionKey) {
      case SystemPermissions.salesRegister:
        return 'Sales Register Access';
      case SystemPermissions.applyDiscount:
        return 'Apply Discounts';
      case SystemPermissions.voidTransaction:
        return 'Void Transactions';
      case SystemPermissions.refundTransaction:
        return 'Refund Transactions';
      case SystemPermissions.splitBill:
        return 'Split Bills';
      case SystemPermissions.holdCart:
        return 'Hold Carts';
      case SystemPermissions.viewCustomer:
        return 'View Customers';
      case SystemPermissions.addCustomer:
        return 'Add Customers';
      case SystemPermissions.editCustomer:
        return 'Edit Customers';
      case SystemPermissions.deleteCustomer:
        return 'Delete Customers';
      case SystemPermissions.viewPetProfile:
        return 'View Pet Profiles';
      case SystemPermissions.editPetProfile:
        return 'Edit Pet Profiles';
      case SystemPermissions.viewBookings:
        return 'View Bookings';
      case SystemPermissions.createBooking:
        return 'Create Bookings';
      case SystemPermissions.editBooking:
        return 'Edit Bookings';
      case SystemPermissions.cancelBooking:
        return 'Cancel Bookings';
      case SystemPermissions.viewRooms:
        return 'View Rooms';
      case SystemPermissions.manageRooms:
        return 'Manage Rooms';
      case SystemPermissions.viewInventory:
        return 'View Inventory';
      case SystemPermissions.editInventory:
        return 'Edit Inventory';
      case SystemPermissions.manageServices:
        return 'Manage Services';
      case SystemPermissions.manageProducts:
        return 'Manage Products';
      case SystemPermissions.viewSuppliers:
        return 'View Suppliers';
      case SystemPermissions.manageSuppliers:
        return 'Manage Suppliers';
      case SystemPermissions.viewBasicReports:
        return 'View Basic Reports';
      case SystemPermissions.viewFinancialReports:
        return 'View Financial Reports';
      case SystemPermissions.viewAnalytics:
        return 'View Analytics';
      case SystemPermissions.exportReports:
        return 'Export Reports';
      case SystemPermissions.viewStaff:
        return 'View Staff';
      case SystemPermissions.manageStaff:
        return 'Manage Staff';
      case SystemPermissions.viewSchedules:
        return 'View Schedules';
      case SystemPermissions.manageSchedules:
        return 'Manage Schedules';
      case SystemPermissions.viewSettings:
        return 'View Settings';
      case SystemPermissions.manageSettings:
        return 'Manage Settings';
      case SystemPermissions.managePermissions:
        return 'Manage Permissions';
      case SystemPermissions.viewAuditLogs:
        return 'View Audit Logs';
      case SystemPermissions.viewFinancials:
        return 'View Financial Data';
      case SystemPermissions.managePricing:
        return 'Manage Pricing';
      case SystemPermissions.viewTaxReports:
        return 'View Tax Reports';
      case SystemPermissions.manageLoyalty:
        return 'Manage Loyalty Programs';
      default:
        return permissionKey.replaceAll('_', ' ').toTitleCase();
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.staff:
        return Colors.blue;
      case UserRole.manager:
        return Colors.green;
      case UserRole.owner:
        return Colors.orange;
      case UserRole.administrator:
        return Colors.purple;
    }
  }

  User? _selectedUser;

  void _selectUser(User user) {
    setState(() {
      _selectedUser = user;
    });
  }

  void _savePermissions() {
    // In a real app, this would save to the database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Permissions saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showAuditLogs() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: 800,
          height: 600,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Audit Logs',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _exportAuditLogs(),
                        icon: const Icon(Icons.download),
                        label: const Text('Export CSV'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<AuditLog>>(
                  future: _auditService.getAllLogs(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error loading audit logs: ${snapshot.error}'),
                      );
                    }
                    
                    final auditLogs = snapshot.data ?? [];
                    
                    if (auditLogs.isEmpty) {
                      return const Center(
                        child: Text('No audit logs found'),
                      );
                    }
                    
                    return ListView.builder(
                      itemCount: auditLogs.length,
                      itemBuilder: (context, index) {
                        final log = auditLogs[index];
                        return _buildAuditLogItem(log);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuditLogItem(AuditLog log) {
    final severityColor = _getSeverityColor(log.severity);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: severityColor,
          child: Icon(
            _getActionIcon(log.action),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          log.details,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${log.userEmail} (${log.userRole}) → ${log.resource}'),
            Text(
              log.timestamp.toIso8601String().substring(0, 19),
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Chip(
          label: Text(
            log.severity.name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: severityColor,
        ),
      ),
    );
  }

  Color _getSeverityColor(AuditSeverity severity) {
    switch (severity) {
      case AuditSeverity.low:
        return Colors.green;
      case AuditSeverity.medium:
        return Colors.orange;
      case AuditSeverity.high:
        return Colors.red;
      case AuditSeverity.critical:
        return Colors.purple;
    }
  }

  IconData _getActionIcon(AuditAction action) {
    switch (action) {
      case AuditAction.permissionGranted:
        return Icons.security;
      case AuditAction.permissionRevoked:
        return Icons.block;
      case AuditAction.roleChanged:
        return Icons.swap_horiz;
      case AuditAction.userCreated:
        return Icons.person_add;
      case AuditAction.userDeleted:
        return Icons.person_remove;
      case AuditAction.login:
        return Icons.login;
      case AuditAction.logout:
        return Icons.logout;
      case AuditAction.dataAccessed:
        return Icons.visibility;
      case AuditAction.dataModified:
        return Icons.edit;
      case AuditAction.systemSettingChanged:
        return Icons.settings;
    }
  }

  void _exportAuditLogs() async {
    try {
      final auditLogs = await _auditService.getAllLogs();
      final csv = await _auditService.exportToCSV(auditLogs);
      // In a real app, this would trigger a file download
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Audit logs exported to CSV!'),
          backgroundColor: Colors.green,
        ),
      );
      print('CSV Export:\n$csv');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting audit logs: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

extension StringExtension on String {
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
}
