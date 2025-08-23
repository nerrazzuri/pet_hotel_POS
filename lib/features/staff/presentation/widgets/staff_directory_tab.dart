import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/staff_member.dart';
import 'package:cat_hotel_pos/features/staff/domain/services/staff_service.dart';
import 'package:cat_hotel_pos/core/services/staff_dao.dart';

class StaffDirectoryTab extends ConsumerStatefulWidget {
  const StaffDirectoryTab({super.key});

  @override
  ConsumerState<StaffDirectoryTab> createState() => _StaffDirectoryTabState();
}

class _StaffDirectoryTabState extends ConsumerState<StaffDirectoryTab> {
  final TextEditingController _searchController = TextEditingController();
  StaffRole? _selectedRole;
  StaffStatus? _selectedStatus;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staffService = StaffService(StaffDao());
    
    return Column(
      children: [
        // Search and Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search staff members...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
              
              const SizedBox(height: 16),
              
              // Filter Row
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<StaffRole>(
                      value: _selectedRole,
                      decoration: const InputDecoration(
                        labelText: 'Role',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<StaffRole>(
                          value: null,
                          child: Text('All Roles'),
                        ),
                        ...StaffRole.values.map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role.displayName),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value;
                        });
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  Expanded(
                    child: DropdownButtonFormField<StaffStatus>(
                      value: _selectedStatus,
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<StaffStatus>(
                          value: null,
                          child: Text('All Statuses'),
                        ),
                        ...StaffStatus.values.map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.displayName),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStatus = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // Staff List
        Expanded(
          child: FutureBuilder<List<StaffMember>>(
            future: staffService.getAllStaffMembers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading staff members',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              final allStaff = snapshot.data ?? [];
              final filteredStaff = _filterStaff(allStaff);
              
              if (filteredStaff.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No staff members found',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your search or filters',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: filteredStaff.length,
                itemBuilder: (context, index) {
                  final staff = filteredStaff[index];
                  return _buildStaffCard(context, staff, staffService);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  List<StaffMember> _filterStaff(List<StaffMember> staff) {
    return staff.where((member) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!member.fullName.toLowerCase().contains(query) &&
            !member.employeeId.toLowerCase().contains(query) &&
            !member.email.toLowerCase().contains(query)) {
          return false;
        }
      }
      
      // Role filter
      if (_selectedRole != null && member.role != _selectedRole) {
        return false;
      }
      
      // Status filter
      if (_selectedStatus != null && member.status != _selectedStatus) {
        return false;
      }
      
      return true;
    }).toList();
  }

  Widget _buildStaffCard(BuildContext context, StaffMember staff, StaffService staffService) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 30,
          backgroundColor: staff.role.color,
          child: Text(
            staff.fullName.split(' ').map((n) => n[0]).join(''),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                staff.fullName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: staff.status.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: staff.status.color),
              ),
              child: Text(
                staff.status.displayName,
                style: TextStyle(
                  color: staff.status.color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.badge, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  staff.employeeId,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.work, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  staff.role.displayName,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.email, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    staff.email,
                    style: TextStyle(color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  staff.phone,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                if (staff.hourlyRate != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'RM ${staff.hourlyRate!.toStringAsFixed(2)}/hr',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
            if (staff.department != null || staff.position != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.business, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${staff.department ?? ''}${staff.department != null && staff.position != null ? ' - ' : ''}${staff.position ?? ''}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) => _handleStaffAction(context, value, staff, staffService),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            if (staff.status == StaffStatus.active)
              const PopupMenuItem(
                value: 'deactivate',
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Deactivate'),
                  ],
                ),
              ),
            if (staff.status == StaffStatus.inactive)
              const PopupMenuItem(
                value: 'reactivate',
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Reactivate'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 'shifts',
              child: Row(
                children: [
                  Icon(Icons.schedule),
                  SizedBox(width: 8),
                  Text('View Shifts'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _showStaffDetails(context, staff),
      ),
    );
  }

  void _handleStaffAction(BuildContext context, String action, StaffMember staff, StaffService staffService) {
    switch (action) {
      case 'view':
        _showStaffDetails(context, staff);
        break;
      case 'edit':
        // TODO: Show edit staff dialog
        break;
      case 'deactivate':
        _showDeactivateDialog(context, staff, staffService);
        break;
      case 'reactivate':
        _reactivateStaff(context, staff, staffService);
        break;
      case 'shifts':
        // TODO: Navigate to shifts view
        break;
      case 'delete':
        _showDeleteDialog(context, staff, staffService);
        break;
    }
  }

  void _showStaffDetails(BuildContext context, StaffMember staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Staff Details - ${staff.fullName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Employee ID', staff.employeeId),
              _buildDetailRow('Full Name', staff.fullName),
              _buildDetailRow('Email', staff.email),
              _buildDetailRow('Phone', staff.phone),
              _buildDetailRow('Role', staff.role.displayName),
              _buildDetailRow('Status', staff.status.displayName),
              _buildDetailRow('Hire Date', _formatDate(staff.hireDate)),
              if (staff.department != null) _buildDetailRow('Department', staff.department!),
              if (staff.position != null) _buildDetailRow('Position', staff.position!),
              if (staff.hourlyRate != null) _buildDetailRow('Hourly Rate', 'RM ${staff.hourlyRate!.toStringAsFixed(2)}'),
              if (staff.emergencyContact != null) _buildDetailRow('Emergency Contact', staff.emergencyContact!),
              if (staff.emergencyPhone != null) _buildDetailRow('Emergency Phone', staff.emergencyPhone!),
              if (staff.address != null) _buildDetailRow('Address', staff.address!),
              if (staff.notes != null) _buildDetailRow('Notes', staff.notes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showDeactivateDialog(BuildContext context, StaffMember staff, StaffService staffService) {
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Deactivate ${staff.fullName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to deactivate this staff member?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for deactivation',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isNotEmpty) {
                try {
                  await staffService.deactivateStaffMember(staff.id, reasonController.text.trim());
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${staff.fullName} has been deactivated')),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _reactivateStaff(BuildContext context, StaffMember staff, StaffService staffService) async {
    try {
      await staffService.reactivateStaffMember(staff.id);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${staff.fullName} has been reactivated')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showDeleteDialog(BuildContext context, StaffMember staff, StaffService staffService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${staff.fullName}'),
        content: Text(
          'Are you sure you want to permanently delete ${staff.fullName}? '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final success = await staffService.deleteStaffMember(staff.id);
                Navigator.pop(context);
                if (success) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${staff.fullName} has been deleted')),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
