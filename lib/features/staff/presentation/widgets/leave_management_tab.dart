import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/leave_request.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/staff_member.dart';
import 'package:cat_hotel_pos/features/staff/domain/services/leave_management_service.dart';
import 'package:cat_hotel_pos/core/services/leave_management_dao.dart';
import 'package:cat_hotel_pos/core/services/staff_dao.dart';

class LeaveManagementTab extends ConsumerStatefulWidget {
  const LeaveManagementTab({super.key});

  @override
  ConsumerState<LeaveManagementTab> createState() => _LeaveManagementTabState();
}

class _LeaveManagementTabState extends ConsumerState<LeaveManagementTab> with TickerProviderStateMixin {
  final LeaveManagementService _leaveService = LeaveManagementService(LeaveManagementDao());
  final StaffDao _staffDao = StaffDao();
  
  late TabController _tabController;
  List<StaffMember> _staffMembers = [];
  List<LeaveRequest> _leaveRequests = [];
  List<LeaveRequest> _pendingRequests = [];
  StaffMember? _selectedStaff;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        await _loadLeaveRequests();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadLeaveRequests() async {
    if (_selectedStaff == null) return;
    
    try {
      _leaveRequests = await _leaveService.getLeaveRequestsByStaffMember(_selectedStaff!.id);
      _pendingRequests = await _leaveService.getPendingLeaveRequests();
    } catch (e) {
      _showErrorSnackBar('Failed to load leave requests: $e');
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildStaffSelector(),
          const SizedBox(height: 20),
          _buildTabBar(),
          const SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLeaveRequestsTab(),
                _buildLeaveBalanceTab(),
                _buildLeaveCalendarTab(),
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
        Icon(Icons.calendar_today, size: 28, color: Colors.blue[700]),
        const SizedBox(width: 12),
        Text(
          'Leave Management',
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
          onPressed: _showCreateLeaveRequestDialog,
          icon: const Icon(Icons.add),
          tooltip: 'Create Leave Request',
        ),
      ],
    );
  }

  Widget _buildStaffSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Staff Member',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<StaffMember>(
              value: _selectedStaff,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              items: _staffMembers.map((staff) {
                return DropdownMenuItem(
                  value: staff,
                  child: Text('${staff.fullName} (${staff.employeeId})'),
                );
              }).toList(),
              onChanged: (StaffMember? newValue) async {
                if (newValue != null) {
                  setState(() => _selectedStaff = newValue);
                  await _loadLeaveRequests();
                }
              },
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
          Tab(icon: Icon(Icons.list), text: 'Leave Requests'),
          Tab(icon: Icon(Icons.account_balance_wallet), text: 'Leave Balance'),
          Tab(icon: Icon(Icons.calendar_month), text: 'Leave Calendar'),
        ],
      ),
    );
  }

  Widget _buildLeaveRequestsTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Leave Requests',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_pendingRequests.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_pendingRequests.length} Pending',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _leaveRequests.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No leave requests found',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _leaveRequests.length,
                      itemBuilder: (context, index) {
                        final request = _leaveRequests[index];
                        return _buildLeaveRequestCard(request);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveRequestCard(LeaveRequest request) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: request.status.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.status.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: request.type.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.type.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${request.totalDays} days',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.date_range, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text('${_formatDate(request.startDate)} - ${_formatDate(request.endDate)}'),
              ],
            ),
            if (request.reason != null) ...[
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(child: Text(request.reason!)),
                ],
              ),
            ],
            if (request.status == LeaveStatus.pending) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveLeaveRequest(request.id),
                      icon: const Icon(Icons.check, color: Colors.white),
                      label: const Text('Approve', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _rejectLeaveRequest(request.id),
                      icon: const Icon(Icons.close, color: Colors.white),
                      label: const Text('Reject', style: TextStyle(color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveBalanceTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _selectedStaff != null 
          ? _leaveService.getLeaveStatistics(
              staffMemberId: _selectedStaff!.id,
              year: DateTime.now().year,
            )
          : null,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('No data available'));
        }

        final data = snapshot.data!;
        final balance = data['balance'] as LeaveBalance;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leave Balance ${DateTime.now().year}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildBalanceCard(
                        'Annual Leave',
                        Icons.beach_access,
                        Colors.blue,
                        balance.annualLeaveRemaining,
                        balance.annualLeaveTotal,
                      ),
                      _buildBalanceCard(
                        'Sick Leave',
                        Icons.sick,
                        Colors.red,
                        balance.sickLeaveRemaining,
                        balance.sickLeaveTotal,
                      ),
                      _buildBalanceCard(
                        'Personal Leave',
                        Icons.person,
                        Colors.green,
                        balance.personalLeaveRemaining,
                        balance.personalLeaveTotal,
                      ),
                      _buildBalanceCard(
                        'Emergency Leave',
                        Icons.emergency,
                        Colors.orange,
                        balance.emergencyLeaveRemaining,
                        balance.emergencyLeaveTotal,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalanceCard(String title, IconData icon, Color color, int remaining, int total) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '$remaining / $total',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              'days remaining',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaveCalendarTab() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leave Calendar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Leave Calendar View',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Calendar implementation coming soon',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateLeaveRequestDialog() async {
    if (_selectedStaff == null) return;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => _CreateLeaveRequestDialog(
        staffMember: _selectedStaff!,
        leaveService: _leaveService,
      ),
    );

    if (result != null) {
      _showSuccessSnackBar('Leave request created successfully');
      await _loadLeaveRequests();
    }
  }

  Future<void> _approveLeaveRequest(String requestId) async {
    try {
      await _leaveService.approveLeaveRequest(
        leaveRequestId: requestId,
        approvedBy: 'Current User', // This should come from auth context
      );
      _showSuccessSnackBar('Leave request approved');
      await _loadLeaveRequests();
    } catch (e) {
      _showErrorSnackBar('Failed to approve leave request: $e');
    }
  }

  Future<void> _rejectLeaveRequest(String requestId) async {
    final reason = await _showRejectionReasonDialog();
    if (reason != null) {
      try {
        await _leaveService.rejectLeaveRequest(
          leaveRequestId: requestId,
          rejectedBy: 'Current User', // This should come from auth context
          rejectionReason: reason,
        );
        _showSuccessSnackBar('Leave request rejected');
        await _loadLeaveRequests();
      } catch (e) {
        _showErrorSnackBar('Failed to reject leave request: $e');
      }
    }
  }

  Future<String?> _showRejectionReasonDialog() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Leave Request'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Rejection Reason',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _CreateLeaveRequestDialog extends StatefulWidget {
  final StaffMember staffMember;
  final LeaveManagementService leaveService;

  const _CreateLeaveRequestDialog({
    required this.staffMember,
    required this.leaveService,
  });

  @override
  State<_CreateLeaveRequestDialog> createState() => _CreateLeaveRequestDialogState();
}

class _CreateLeaveRequestDialogState extends State<_CreateLeaveRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();
  
  LeaveType _selectedType = LeaveType.annual;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Leave Request'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<LeaveType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Leave Type',
                  border: OutlineInputBorder(),
                ),
                items: LeaveType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Row(
                      children: [
                        Icon(type.icon, size: 20, color: type.color),
                        const SizedBox(width: 8),
                        Text(type.displayName),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ListTile(
                      title: const Text('Start Date'),
                      subtitle: Text(_formatDate(_startDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, true),
                    ),
                  ),
                  Expanded(
                    child: ListTile(
                      title: const Text('End Date'),
                      subtitle: Text(_formatDate(_endDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context, false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a reason';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _createLeaveRequest,
          child: const Text('Create Request'),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final date = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        if (isStartDate) {
          _startDate = date;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = date;
        }
      });
    }
  }

  Future<void> _createLeaveRequest() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await widget.leaveService.createLeaveRequest(
        staffMemberId: widget.staffMember.id,
        type: _selectedType,
        startDate: _startDate,
        endDate: _endDate,
        reason: _reasonController.text,
        notes: _notesController.text,
      );
      Navigator.of(context).pop({
        'success': true,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create leave request: $e'), backgroundColor: Colors.red),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
