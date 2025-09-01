import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/time_tracking.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/staff_member.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/leave_request.dart';
import 'package:cat_hotel_pos/features/staff/domain/services/time_tracking_service.dart';
import 'package:cat_hotel_pos/features/staff/domain/services/leave_management_service.dart';
import 'package:cat_hotel_pos/core/services/time_tracking_dao.dart';
import 'package:cat_hotel_pos/core/services/leave_management_dao.dart';
import 'package:cat_hotel_pos/core/services/staff_dao.dart';

class StaffHRModule extends ConsumerStatefulWidget {
  const StaffHRModule({super.key});

  @override
  ConsumerState<StaffHRModule> createState() => _StaffHRModuleState();
}

class _StaffHRModuleState extends ConsumerState<StaffHRModule> with TickerProviderStateMixin {
  final TimeTrackingService _timeTrackingService = TimeTrackingService(TimeTrackingDao());
  final LeaveManagementService _leaveService = LeaveManagementService(LeaveManagementDao());
  final StaffDao _staffDao = StaffDao();
  
  late TabController _tabController;
  StaffMember? _currentStaff;
  List<TimeTracking> _timeTrackingRecords = [];
  List<LeaveRequest> _leaveRequests = [];
  LeaveBalance? _leaveBalance;
  bool _isLoading = false;
  bool _isExpanded = false; // Default to collapsed

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCurrentStaff();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentStaff() async {
    setState(() => _isLoading = true);
    try {
      final staffMembers = await _staffDao.getAll();
      // For demo purposes, select the first staff member
      // In a real app, this would be the logged-in user
      if (staffMembers.isNotEmpty) {
        _currentStaff = staffMembers.first;
        await _loadData();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadData() async {
    if (_currentStaff == null) return;
    
    try {
      _timeTrackingRecords = await _timeTrackingService.getTimeTrackingByStaffMember(_currentStaff!.id);
      _leaveRequests = await _leaveService.getLeaveRequestsByStaffMember(_currentStaff!.id);
      _leaveBalance = await _leaveService.getLeaveBalance(_currentStaff!.id, DateTime.now().year);
    } catch (e) {
      _showErrorSnackBar('Failed to load HR data: $e');
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
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (_currentStaff == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with expand/collapse button
            InkWell(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Row(
                children: [
                  Icon(Icons.work, color: Colors.blue[700], size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'HR Portal',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _currentStaff!.status.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _currentStaff!.status.displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blue[700],
                    size: 20,
                  ),
                ],
              ),
            ),
            
            // Expandable content
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: _isExpanded ? 250 : 0,
              child: _isExpanded ? Column(
                children: [
                  const SizedBox(height: 12),
                  // Tab bar
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelStyle: const TextStyle(fontSize: 12),
                    tabs: const [
                      Tab(icon: Icon(Icons.access_time, size: 16), text: 'Time History'),
                      Tab(icon: Icon(Icons.calendar_today, size: 16), text: 'Leave'),
                      Tab(icon: Icon(Icons.analytics, size: 16), text: 'Balance'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTimeHistoryTab(),
                        _buildLeaveTab(),
                        _buildBalanceTab(),
                      ],
                    ),
                  ),
                ],
              ) : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeHistoryTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Time Tracking',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _timeTrackingRecords.isEmpty
              ? Center(
                  child: Text(
                    'No time tracking records',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                )
              : ListView.builder(
                  itemCount: _timeTrackingRecords.take(5).length,
                  itemBuilder: (context, index) {
                    final record = _timeTrackingRecords[index];
                    return _buildTimeRecordItem(record);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTimeRecordItem(TimeTracking record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(
            record.status.icon,
            size: 12,
            color: record.status.color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${_formatDate(record.clockInTime)} - ${_formatTime(record.clockInTime)}',
              style: const TextStyle(fontSize: 11),
            ),
          ),
          if (record.clockOutTime != null)
            Text(
              'Out: ${_formatTime(record.clockOutTime!)}',
              style: const TextStyle(fontSize: 11),
            ),
        ],
      ),
    );
  }

  Widget _buildLeaveTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Leave Requests',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _showLeaveRequestDialog,
              icon: const Icon(Icons.add, size: 14),
              label: const Text('Apply', style: TextStyle(fontSize: 12)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(0, 28),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _leaveRequests.isEmpty
              ? Center(
                  child: Text(
                    'No leave requests',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                )
              : ListView.builder(
                  itemCount: _leaveRequests.take(3).length,
                  itemBuilder: (context, index) {
                    final request = _leaveRequests[index];
                    return _buildLeaveRequestItem(request);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildLeaveRequestItem(LeaveRequest request) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: request.status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: request.status.color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            request.type.icon,
            size: 12,
            color: request.type.color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.type.displayName,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_formatDate(request.startDate)} - ${_formatDate(request.endDate)}',
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: request.status.color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              request.status.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceTab() {
    if (_leaveBalance == null) {
      return Center(
        child: Text(
          'No leave balance data',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Leave Balance ${_leaveBalance!.year}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView(
            children: [
              _buildBalanceItem('Annual', _leaveBalance!.annualLeaveRemaining, _leaveBalance!.annualLeaveTotal, Colors.blue),
              _buildBalanceItem('Sick', _leaveBalance!.sickLeaveRemaining, _leaveBalance!.sickLeaveTotal, Colors.red),
              _buildBalanceItem('Medical', _leaveBalance!.medicalLeaveRemaining, _leaveBalance!.medicalLeaveTotal, Colors.red[300]!),
              _buildBalanceItem('Personal', _leaveBalance!.personalLeaveRemaining, _leaveBalance!.personalLeaveTotal, Colors.green),
              _buildBalanceItem('Emergency', _leaveBalance!.emergencyLeaveRemaining, _leaveBalance!.emergencyLeaveTotal, Colors.orange),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceItem(String type, int remaining, int total, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              type,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            '$remaining/$total',
            style: const TextStyle(fontSize: 11),
          ),
        ],
      ),
    );
  }

  void _showLeaveRequestDialog() {
    showDialog(
      context: context,
      builder: (context) => _LeaveRequestDialog(
        staffMemberId: _currentStaff!.id,
        onLeaveRequested: (newRequest) {
          // Immediately add the new request to the list
          setState(() {
            _leaveRequests.insert(0, newRequest);
          });
          _showSuccessSnackBar('Leave request submitted successfully');
        },
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}

class _LeaveRequestDialog extends StatefulWidget {
  final String staffMemberId;
  final Function(LeaveRequest) onLeaveRequested;

  const _LeaveRequestDialog({
    required this.staffMemberId,
    required this.onLeaveRequested,
  });

  @override
  State<_LeaveRequestDialog> createState() => _LeaveRequestDialogState();
}

class _LeaveRequestDialogState extends State<_LeaveRequestDialog> {
  final LeaveManagementService _leaveService = LeaveManagementService(LeaveManagementDao());
  
  LeaveType _selectedType = LeaveType.annual;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Apply for Leave'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Leave Type
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
                      Icon(type.icon, size: 16, color: type.color),
                      const SizedBox(width: 8),
                      Text(type.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedType = value);
                }
              },
            ),
            const SizedBox(height: 16),
            
            // Date Range
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_formatDate(_startDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'End Date',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(_formatDate(_endDate)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Reason
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            
            // Notes
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Additional Notes (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submitLeaveRequest,
          child: _isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
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
            _endDate = _startDate;
          }
        } else {
          _endDate = date;
          if (_startDate.isAfter(_endDate)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  Future<void> _submitLeaveRequest() async {
    if (_reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a reason for leave')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      final newRequest = await _leaveService.createLeaveRequest(
        staffMemberId: widget.staffMemberId,
        type: _selectedType,
        startDate: _startDate,
        endDate: _endDate,
        reason: _reasonController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );
      
      Navigator.of(context).pop();
      widget.onLeaveRequested(newRequest);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit leave request: $e')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
