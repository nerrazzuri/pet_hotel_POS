import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/auth/presentation/providers/auth_providers.dart';
import 'package:cat_hotel_pos/features/auth/domain/entities/user.dart';
import 'package:cat_hotel_pos/features/auth/domain/entities/role.dart';


class UserManagementScreen extends ConsumerStatefulWidget {
  const UserManagementScreen({super.key});

  @override
  ConsumerState<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends ConsumerState<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canManageUsers = ref.watch(canManageUsersProvider);
    final canManagePermissions = ref.watch(canManagePermissionsProvider);

    if (!canManageUsers) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Management'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Access denied. You need permission to manage users.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Users', icon: Icon(Icons.people)),
            Tab(text: 'Roles', icon: Icon(Icons.security)),
            Tab(text: 'Permissions', icon: Icon(Icons.admin_panel_settings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _UsersTab(canManagePermissions: canManagePermissions),
          _RolesTab(canManagePermissions: canManagePermissions),
          _PermissionsTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildFloatingActionButton() {
    switch (_selectedTabIndex) {
      case 0:
        return FloatingActionButton(
          onPressed: () => _showCreateUserDialog(),
          backgroundColor: Colors.teal,
          child: const Icon(Icons.person_add, color: Colors.white),
        );
      case 1:
        return FloatingActionButton(
          onPressed: () => _showCreateRoleDialog(),
          backgroundColor: Colors.teal,
          child: const Icon(Icons.add_business, color: Colors.white),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  void _showCreateUserDialog() {
    showDialog(
      context: context,
      builder: (context) => const _CreateUserDialog(),
    );
  }

  void _showCreateRoleDialog() {
    showDialog(
      context: context,
      builder: (context) => const _CreateRoleDialog(),
    );
  }
}

class _UsersTab extends ConsumerStatefulWidget {
  final bool canManagePermissions;

  const _UsersTab({required this.canManagePermissions});

  @override
  ConsumerState<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends ConsumerState<_UsersTab> {
  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersListProvider);

    return usersAsync.when(
      data: (users) => _buildUsersList(users),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildUsersList(List<User> users) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _UserCard(
          user: user,
          canManagePermissions: widget.canManagePermissions,
          onEdit: () => _showEditUserDialog(user),
          onDelete: () => _showDeleteUserDialog(user),
          onPermissions: () => _showUserPermissionsDialog(user),
        );
      },
    );
  }

  void _showEditUserDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => _EditUserDialog(user: user),
    );
  }

  void _showDeleteUserDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => _DeleteUserDialog(user: user),
    );
  }

  void _showUserPermissionsDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => _UserPermissionsDialog(user: user),
    );
  }
}

class _UserCard extends StatelessWidget {
  final User user;
  final bool canManagePermissions;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPermissions;

  const _UserCard({
    required this.user,
    required this.canManagePermissions,
    required this.onEdit,
    required this.onDelete,
    required this.onPermissions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getRoleColor(user.role),
                  child: Text(
                    user.fullName.substring(0, 1).toUpperCase(),
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
                        user.fullName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user.email,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(user.role).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getRoleColor(user.role),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              user.role.name.toUpperCase(),
                              style: TextStyle(
                                color: _getRoleColor(user.role),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(user.status).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getStatusColor(user.status),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              user.status?.name.toUpperCase() ?? 'ACTIVE',
                              style: TextStyle(
                                color: _getStatusColor(user.status),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (user.department != null || user.position != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (user.department != null) ...[
                    Icon(
                      Icons.business,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.department!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                  if (user.department != null && user.position != null)
                    const SizedBox(width: 16),
                  if (user.position != null) ...[
                    Icon(
                      Icons.work,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.position!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (canManagePermissions)
                  TextButton.icon(
                    onPressed: onPermissions,
                    icon: const Icon(Icons.security),
                    label: const Text('Permissions'),
                  ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

  Color _getStatusColor(UserStatus? status) {
    switch (status) {
      case UserStatus.active:
        return Colors.green;
      case UserStatus.inactive:
        return Colors.grey;
      case UserStatus.suspended:
        return Colors.red;
      case UserStatus.terminated:
        return Colors.red;
      default:
        return Colors.green;
    }
  }
}

class _RolesTab extends ConsumerStatefulWidget {
  final bool canManagePermissions;

  const _RolesTab({required this.canManagePermissions});

  @override
  ConsumerState<_RolesTab> createState() => _RolesTabState();
}

class _RolesTabState extends ConsumerState<_RolesTab> {
  @override
  Widget build(BuildContext context) {
    final rolesAsync = ref.watch(rolesListProvider);

    return rolesAsync.when(
      data: (roles) => _buildRolesList(roles),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildRolesList(List<Role> roles) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: roles.length,
      itemBuilder: (context, index) {
        final role = roles[index];
        return _RoleCard(
          role: role,
          canManagePermissions: widget.canManagePermissions,
          onEdit: () => _showEditRoleDialog(role),
          onDelete: () => _showDeleteRoleDialog(role),
        );
      },
    );
  }

  void _showEditRoleDialog(Role role) {
    showDialog(
      context: context,
      builder: (context) => _EditRoleDialog(role: role),
    );
  }

  void _showDeleteRoleDialog(Role role) {
    showDialog(
      context: context,
      builder: (context) => _DeleteRoleDialog(role: role),
      );
  }
}

class _RoleCard extends StatelessWidget {
  final Role role;
  final bool canManagePermissions;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RoleCard({
    required this.role,
    required this.canManagePermissions,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final enabledPermissions = role.permissions.values.where((p) => p).length;
    final totalPermissions = role.permissions.length;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getRoleColor(role.baseRole),
                  child: Text(
                    role.name.substring(0, 1).toUpperCase(),
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
                        role.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        role.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(role.baseRole).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getRoleColor(role.baseRole),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              role.baseRole.name.toUpperCase(),
                              style: TextStyle(
                                color: _getRoleColor(role.baseRole),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (role.isCustom) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.orange,
                                  width: 1,
                                ),
                              ),
                              child: const Text(
                                'CUSTOM',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Permissions: $enabledPermissions/$totalPermissions',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: totalPermissions > 0 ? enabledPermissions / totalPermissions : 0,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                _getRoleColor(role.baseRole),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                if (role.isCustom)
                  TextButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
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
}

class _PermissionsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Text('Permissions management will be implemented here'),
    );
  }
}

// Dialog classes will be implemented next...
class _CreateUserDialog extends StatelessWidget {
  const _CreateUserDialog();

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      title: Text('Create User'),
      content: Text('User creation dialog will be implemented here'),
      actions: [
        TextButton(
          onPressed: null,
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: null,
          child: Text('Create'),
        ),
      ],
    );
  }
}

class _EditUserDialog extends StatelessWidget {
  final User user;

  const _EditUserDialog({required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${user.fullName}'),
      content: Text('Edit user dialog will be implemented here'),
      actions: [
        TextButton(
          onPressed: null,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _DeleteUserDialog extends StatelessWidget {
  final User user;

  const _DeleteUserDialog({required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete ${user.fullName}'),
      content: Text('Are you sure you want to delete ${user.fullName}?'),
      actions: [
        TextButton(
          onPressed: null,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: null,
          child: const Text('Delete'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
        ),
      ],
    );
  }
}

class _CreateRoleDialog extends StatelessWidget {
  const _CreateRoleDialog();

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      title: Text('Create Role'),
      content: Text('Role creation dialog will be implemented here'),
      actions: [
        TextButton(
          onPressed: null,
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: null,
          child: Text('Create'),
        ),
      ],
    );
  }
}

class _EditRoleDialog extends StatelessWidget {
  final Role role;

  const _EditRoleDialog({required this.role});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${role.name}'),
      content: Text('Edit role dialog will be implemented here'),
      actions: [
        TextButton(
          onPressed: null,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: null,
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class _DeleteRoleDialog extends StatelessWidget {
  final Role role;

  const _DeleteRoleDialog({required this.role});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete ${role.name}'),
      content: Text('Are you sure you want to delete ${role.name}?'),
      actions: [
        TextButton(
          onPressed: null,
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: null,
          child: const Text('Delete'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.red,
          ),
        ),
      ],
    );
  }
}

class _UserPermissionsDialog extends StatelessWidget {
  final User user;

  const _UserPermissionsDialog({required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${user.fullName} Permissions'),
      content: const Text('User permissions dialog will be implemented here'),
      actions: [
        TextButton(
          onPressed: null,
          child: const Text('Close'),
        ),
      ],
    );
  }
}
