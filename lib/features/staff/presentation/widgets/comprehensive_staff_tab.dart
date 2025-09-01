import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/staff_member.dart';
import 'package:cat_hotel_pos/core/services/staff_dao.dart';

class ComprehensiveStaffTab extends ConsumerStatefulWidget {
  const ComprehensiveStaffTab({super.key});

  @override
  ConsumerState<ComprehensiveStaffTab> createState() => _ComprehensiveStaffTabState();
}

class _ComprehensiveStaffTabState extends ConsumerState<ComprehensiveStaffTab> with TickerProviderStateMixin {
  final StaffDao _staffDao = StaffDao();
  
  late TabController _tabController;
  List<StaffMember> _staffMembers = [];
  StaffMember? _selectedStaff;
  bool _isLoading = false;
  String _searchQuery = '';
  StaffRole? _selectedRole;
  StaffStatus? _selectedStatus;
  bool _showGridView = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _staffMembers = await _staffDao.getAll();
      if (_staffMembers.isNotEmpty) {
        _selectedStaff = _staffMembers.first;
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  List<StaffMember> get _filteredStaffMembers {
    return _staffMembers.where((staff) {
      final matchesSearch = _searchQuery.isEmpty ||
          staff.fullName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          staff.employeeId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (staff.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      
      final matchesRole = _selectedRole == null || staff.role == _selectedRole;
      final matchesStatus = _selectedStatus == null || staff.status == _selectedStatus;
      
      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  int _calculateLengthOfService(DateTime hireDate) {
    final now = DateTime.now();
    final difference = now.difference(hireDate);
    return (difference.inDays / 365).floor();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildSearchAndFilters(),
          const SizedBox(height: 20),
          _buildTabBar(),
          const SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildStaffDirectoryTab(),
                _buildStaffDetailsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.people, size: 28, color: Colors.blue[700]),
        const SizedBox(width: 12),
        Text(
          'Staff Management',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: _loadData,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
        IconButton(
          onPressed: _showCreateStaffDialog,
          icon: const Icon(Icons.person_add),
          tooltip: 'Add Staff Member',
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search Staff',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => setState(() => _showGridView = !_showGridView),
                  icon: Icon(_showGridView ? Icons.list : Icons.grid_view),
                  tooltip: _showGridView ? 'List View' : 'Grid View',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<StaffRole?>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Role',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<StaffRole?>(
                        value: null,
                        child: Text('All Roles'),
                      ),
                      ...StaffRole.values.map((role) {
                        return DropdownMenuItem<StaffRole?>(
                          value: role,
                          child: Text(role.displayName),
                        );
                      }),
                    ],
                    onChanged: (value) => setState(() => _selectedRole = value),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<StaffStatus?>(
                    value: _selectedStatus,
                    decoration: const InputDecoration(
                      labelText: 'Filter by Status',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<StaffStatus?>(
                        value: null,
                        child: Text('All Status'),
                      ),
                      ...StaffStatus.values.map((status) {
                        return DropdownMenuItem<StaffStatus?>(
                          value: status,
                          child: Text(status.displayName),
                        );
                      }),
                    ],
                    onChanged: (value) => setState(() => _selectedStatus = value),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Card(
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(icon: Icon(Icons.grid_view), text: 'Staff Directory'),
          Tab(icon: Icon(Icons.person), text: 'Staff Details'),
        ],
      ),
    );
  }

  Widget _buildStaffDirectoryTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Staff Directory (${_filteredStaffMembers.length} members)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredStaffMembers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No staff members found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : _showGridView
                      ? GridView.builder(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _filteredStaffMembers.length,
                          itemBuilder: (context, index) {
                            final staff = _filteredStaffMembers[index];
                            return _buildStaffCard(staff);
                          },
                        )
                      : ListView.builder(
                          itemCount: _filteredStaffMembers.length,
                          itemBuilder: (context, index) {
                            final staff = _filteredStaffMembers[index];
                            return _buildStaffListTile(staff);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffCard(StaffMember staff) {
    final lengthOfService = _calculateLengthOfService(staff.hireDate);
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () {
          setState(() => _selectedStaff = staff);
          _tabController.animateTo(1);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: staff.role.color.withOpacity(0.2),
                child: staff.profilePhoto != null
                    ? ClipOval(
                        child: Image.network(
                          staff.profilePhoto!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.person,
                              size: 30,
                              color: staff.role.color,
                            );
                          },
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 30,
                        color: staff.role.color,
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                staff.fullName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: staff.role.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  staff.role.shortName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: staff.status.color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  staff.status.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$lengthOfService years service',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStaffListTile(StaffMember staff) {
    final lengthOfService = _calculateLengthOfService(staff.hireDate);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: staff.role.color.withOpacity(0.2),
          child: staff.profilePhoto != null
              ? ClipOval(
                  child: Image.network(
                    staff.profilePhoto!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        color: staff.role.color,
                      );
                    },
                  ),
                )
              : Icon(
                  Icons.person,
                  color: staff.role.color,
                ),
        ),
        title: Text(
          staff.fullName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${staff.employeeId} • ${staff.role.displayName}'),
            Text('$lengthOfService years service • ${staff.department ?? 'No Department'}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: staff.status.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                staff.status.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                setState(() => _selectedStaff = staff);
                _tabController.animateTo(1);
              },
              icon: const Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
        onTap: () {
          setState(() => _selectedStaff = staff);
          _tabController.animateTo(1);
        },
      ),
    );
  }

  Widget _buildStaffDetailsTab() {
    if (_selectedStaff == null) {
      return Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Select a staff member to view details',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final staff = _selectedStaff!;
    final lengthOfService = _calculateLengthOfService(staff.hireDate);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Staff Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _showEditStaffDialog(staff),
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit Staff',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildStaffHeader(staff, lengthOfService),
                    const SizedBox(height: 20),
                    _buildDetailSection('Personal Information', [
                      _buildDetailRow('Full Name', staff.fullName),
                      _buildDetailRow('Employee ID', staff.employeeId),
                      _buildDetailRow('Email', staff.email),
                      _buildDetailRow('Phone', staff.phone),
                      _buildDetailRow('Date of Birth', staff.dateOfBirth ?? 'Not specified'),
                      _buildDetailRow('Gender', staff.gender ?? 'Not specified'),
                      _buildDetailRow('Nationality', staff.nationality ?? 'Not specified'),
                      _buildDetailRow('Marital Status', staff.maritalStatus ?? 'Not specified'),
                      _buildDetailRow('Address', staff.address ?? 'Not specified'),
                    ]),
                    const SizedBox(height: 20),
                    _buildDetailSection('Employment Information', [
                      _buildDetailRow('Role', staff.role.displayName),
                      _buildDetailRow('Status', staff.status.displayName),
                      _buildDetailRow('Department', staff.department ?? 'Not specified'),
                      _buildDetailRow('Position', staff.position ?? 'Not specified'),
                      _buildDetailRow('Hire Date', _formatDate(staff.hireDate)),
                      _buildDetailRow('Length of Service', '$lengthOfService years'),
                      _buildDetailRow('Contract Type', staff.contractType ?? 'Not specified'),
                      _buildDetailRow('Work Location', staff.workLocation ?? 'Not specified'),
                      _buildDetailRow('Work Schedule', staff.workSchedule ?? 'Not specified'),
                      _buildDetailRow('Reporting Manager', staff.reportingManager ?? 'Not specified'),
                    ]),
                    const SizedBox(height: 20),
                    _buildDetailSection('Salary & Compensation', [
                      _buildDetailRow('Hourly Rate', staff.hourlyRate != null ? 'RM ${staff.hourlyRate!.toStringAsFixed(2)}' : 'Not specified'),
                      _buildDetailRow('Monthly Salary', staff.monthlySalary != null ? 'RM ${staff.monthlySalary!.toStringAsFixed(2)}' : 'Not specified'),
                      _buildDetailRow('Annual Salary', _calculateAnnualSalary(staff)),
                      _buildDetailRow('Bank Account', staff.bankAccount ?? 'Not specified'),
                      _buildDetailRow('Bank Name', staff.bankName ?? 'Not specified'),
                      _buildDetailRow('Tax ID', staff.taxId ?? 'Not specified'),
                    ]),
                    const SizedBox(height: 20),
                    _buildDetailSection('Emergency Contact', [
                      _buildDetailRow('Emergency Contact', staff.emergencyContact ?? 'Not specified'),
                      _buildDetailRow('Emergency Phone', staff.emergencyPhone ?? 'Not specified'),
                    ]),
                    const SizedBox(height: 20),
                    _buildDetailSection('Professional Information', [
                      _buildDetailRow('Education', staff.education ?? 'Not specified'),
                      _buildDetailRow('Skills', staff.skills ?? 'Not specified'),
                      _buildDetailRow('Certifications', staff.certifications ?? 'Not specified'),
                    ]),
                    if (staff.notes != null) ...[
                      const SizedBox(height: 20),
                      _buildDetailSection('Notes', [
                        _buildDetailRow('Notes', staff.notes!),
                      ]),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffHeader(StaffMember staff, int lengthOfService) {
    return Card(
      color: staff.role.color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: staff.role.color.withOpacity(0.2),
              child: staff.profilePhoto != null
                  ? ClipOval(
                      child: Image.network(
                        staff.profilePhoto!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.person,
                            size: 40,
                            color: staff.role.color,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.person,
                      size: 40,
                      color: staff.role.color,
                    ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    staff.fullName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: staff.role.color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          staff.role.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: staff.status.color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          staff.status.displayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${staff.employeeId} • $lengthOfService years service',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                  ),
                  if (staff.monthlySalary != null || staff.hourlyRate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _calculateAnnualSalary(staff),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  String _calculateAnnualSalary(StaffMember staff) {
    if (staff.monthlySalary != null) {
      return 'RM ${(staff.monthlySalary! * 12).toStringAsFixed(2)} annually';
    } else if (staff.hourlyRate != null) {
      // Assuming 40 hours per week, 52 weeks per year
      final annualSalary = staff.hourlyRate! * 40 * 52;
      return 'RM ${annualSalary.toStringAsFixed(2)} annually (estimated)';
    }
    return 'Not specified';
  }

  Future<void> _showCreateStaffDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _CreateStaffDialog(staffDao: _staffDao),
    );

    if (result != null) {
      _showSuccessSnackBar('Staff member created successfully');
      await _loadData();
    }
  }

  Future<void> _showEditStaffDialog(StaffMember staff) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _EditStaffDialog(staff: staff, staffDao: _staffDao),
    );

    if (result != null) {
      _showSuccessSnackBar('Staff member updated successfully');
      await _loadData();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _CreateStaffDialog extends StatefulWidget {
  final StaffDao staffDao;

  const _CreateStaffDialog({required this.staffDao});

  @override
  State<_CreateStaffDialog> createState() => _CreateStaffDialogState();
}

class _CreateStaffDialogState extends State<_CreateStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  final _employeeIdController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  StaffRole _selectedRole = StaffRole.assistant;
  String? _department;
  String? _position;
  double? _hourlyRate;
  double? _monthlySalary;

  @override
  void dispose() {
    _employeeIdController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Staff Member'),
      content: SizedBox(
        width: 500,
        height: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _employeeIdController,
                  decoration: const InputDecoration(
                    labelText: 'Employee ID',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter employee ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<StaffRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: StaffRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.displayName),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedRole = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createStaff,
          child: const Text('Create Staff'),
        ),
      ],
    );
  }

  Future<void> _createStaff() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final staff = StaffMember.create(
        employeeId: _employeeIdController.text,
        fullName: _fullNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        role: _selectedRole,
        department: _department,
        position: _position,
        hourlyRate: _hourlyRate,
        monthlySalary: _monthlySalary,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      await widget.staffDao.create(staff);
      Navigator.of(context).pop({'success': true});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create staff: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

class _EditStaffDialog extends StatefulWidget {
  final StaffMember staff;
  final StaffDao staffDao;

  const _EditStaffDialog({required this.staff, required this.staffDao});

  @override
  State<_EditStaffDialog> createState() => _EditStaffDialogState();
}

class _EditStaffDialogState extends State<_EditStaffDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _notesController;

  late StaffRole _selectedRole;
  late StaffStatus _selectedStatus;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.staff.fullName);
    _emailController = TextEditingController(text: widget.staff.email);
    _phoneController = TextEditingController(text: widget.staff.phone);
    _addressController = TextEditingController(text: widget.staff.address ?? '');
    _notesController = TextEditingController(text: widget.staff.notes ?? '');
    _selectedRole = widget.staff.role;
    _selectedStatus = widget.staff.status;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Staff Member'),
      content: SizedBox(
        width: 500,
        height: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter full name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<StaffRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    labelText: 'Role',
                    border: OutlineInputBorder(),
                  ),
                  items: StaffRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.displayName),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedRole = value!),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<StaffStatus>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: StaffStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.displayName),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedStatus = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateStaff,
          child: const Text('Update Staff'),
        ),
      ],
    );
  }

  Future<void> _updateStaff() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final updatedStaff = widget.staff.copyWith(
        fullName: _fullNameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        role: _selectedRole,
        status: _selectedStatus,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        updatedAt: DateTime.now(),
      );

      await widget.staffDao.update(updatedStaff);
      Navigator.of(context).pop({'success': true});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update staff: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
