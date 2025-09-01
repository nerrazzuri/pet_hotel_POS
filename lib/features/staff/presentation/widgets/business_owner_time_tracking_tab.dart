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

class BusinessOwnerTimeTrackingTab extends ConsumerStatefulWidget {
  const BusinessOwnerTimeTrackingTab({super.key});

  @override
  ConsumerState<BusinessOwnerTimeTrackingTab> createState() => _BusinessOwnerTimeTrackingTabState();
}

class _BusinessOwnerTimeTrackingTabState extends ConsumerState<BusinessOwnerTimeTrackingTab> with TickerProviderStateMixin {
  final TimeTrackingService _timeTrackingService = TimeTrackingService(TimeTrackingDao());
  final LeaveManagementService _leaveService = LeaveManagementService(LeaveManagementDao());
  final StaffDao _staffDao = StaffDao();
  
  late TabController _tabController;
  List<StaffMember> _staffMembers = [];
  List<TimeTracking> _timeTrackingRecords = [];
  List<LeaveRequest> _leaveRequests = [];
  StaffMember? _selectedStaff;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

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
      await _loadTimeTrackingRecords();
      await _loadLeaveRequests();
    } catch (e) {
      _showErrorSnackBar('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTimeTrackingRecords() async {
    try {
      _timeTrackingRecords = await _timeTrackingService.getTimeTrackingByDateRange(
        startDate: DateTime(_selectedDate.year, _selectedDate.month, 1),
        endDate: DateTime(_selectedDate.year, _selectedDate.month + 1, 0),
      );
    } catch (e) {
      _showErrorSnackBar('Failed to load time tracking records: $e');
    }
  }

  Future<void> _loadLeaveRequests() async {
    try {
      _leaveRequests = await _leaveService.getAllLeaveRequests();
    } catch (e) {
      _showErrorSnackBar('Failed to load leave requests: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
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
          _buildDateSelector(),
          const SizedBox(height: 20),
          _buildTabBar(),
          const SizedBox(height: 20),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCalendarView(),
                _buildDetailedView(),
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
        Icon(Icons.access_time, size: 28, color: Colors.blue[700]),
        const SizedBox(width: 12),
        Text(
          'Time Tracking Management',
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
      ],
    );
  }

  Widget _buildDateSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.blue[700]),
            const SizedBox(width: 12),
            Text(
              'Viewing: ${_formatMonthYear(_selectedDate)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
                });
                _loadTimeTrackingRecords();
              },
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Previous Month',
            ),
            IconButton(
              onPressed: () {
                setState(() {
                  _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
                });
                _loadTimeTrackingRecords();
              },
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next Month',
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedDate = DateTime.now();
                });
                _loadTimeTrackingRecords();
              },
              icon: const Icon(Icons.today),
              label: const Text('Today'),
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
          Tab(icon: Icon(Icons.calendar_month), text: 'Calendar View'),
          Tab(icon: Icon(Icons.list), text: 'Detailed View'),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Attendance Calendar - ${_formatMonthYear(_selectedDate)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildCalendar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final firstDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final lastDayOfMonth = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final firstDayOfWeek = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    
    return Column(
      children: [
        // Day headers row (fixed height)
        Row(
          children: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) {
            return Expanded(
              child: Container(
                height: 24, // Fixed minimal height
                padding: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Center(
                  child: Text(
                    day,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // Calendar days grid
        Expanded(
          child: GridView.count(
            crossAxisCount: 7,
            childAspectRatio: 0.8,
            children: [
              // Add empty cells for days before the first day of the month
              ...List.generate(firstDayOfWeek - 1, (index) => Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                ),
              )),
              // Add days of the month with staff cards
              ...List.generate(daysInMonth, (index) {
                final day = index + 1;
                final currentDate = DateTime(_selectedDate.year, _selectedDate.month, day);
                final dayRecords = _getTimeTrackingForDate(currentDate);
                final dayLeaveRequests = _getLeaveRequestsForDate(currentDate);
                
                return Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    color: _getDateColor(dayRecords, dayLeaveRequests),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Day number
                      Text(
                        day.toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: currentDate.day == DateTime.now().day && 
                                 currentDate.month == DateTime.now().month ? 
                                 Colors.blue : Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Staff cards (time tracking and leave)
                      Expanded(
                        child: _buildDayContent(dayRecords, dayLeaveRequests),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedView() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Time Tracking Records',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _timeTrackingRecords.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.access_time, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'No time tracking records found for ${_formatMonthYear(_selectedDate)}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _timeTrackingRecords.length,
                      itemBuilder: (context, index) {
                        final record = _timeTrackingRecords[index];
                        final staff = _staffMembers.firstWhere(
                          (s) => s.id == record.staffMemberId,
                          orElse: () => StaffMember.create(
                            employeeId: 'Unknown',
                            fullName: 'Unknown Staff',
                            email: 'unknown@example.com',
                            phone: '000-000-0000',
                            role: StaffRole.assistant,
                          ),
                        );
                        return _buildTimeTrackingRecordCard(record, staff);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffCard(TimeTracking record, StaffMember staff) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            staff.fullName,
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Row(
            children: [
              Text(
                'In ${_formatTime(record.clockInTime)}',
                style: const TextStyle(fontSize: 7),
              ),
              const SizedBox(width: 2),
              Text(
                record.clockOutTime != null 
                    ? 'Out ${_formatTime(record.clockOutTime!)}'
                    : 'Out -',
                style: TextStyle(
                  fontSize: 7,
                  color: record.clockOutTime != null ? Colors.black : Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTrackingRecordCard(TimeTracking record, StaffMember staff) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: staff.role.color.withOpacity(0.2),
                  child: Icon(
                    Icons.person,
                    color: staff.role.color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        staff.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${staff.employeeId} • ${staff.role.displayName}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: record.status.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record.status.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text('In: ${_formatTime(record.clockInTime)}'),
                if (record.clockOutTime != null) ...[
                  const SizedBox(width: 16),
                  Text('Out: ${_formatTime(record.clockOutTime!)}'),
                ],
              ],
            ),
            if (record.totalHours != null && record.totalHours! > 0) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text('Total: ${record.totalHours!.toStringAsFixed(1)}h'),
                ],
              ),
            ],
            if (record.location != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text('Location: ${record.location}'),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text('Date: ${_formatDate(record.clockInTime)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<TimeTracking> _getTimeTrackingForDate(DateTime date) {
    return _timeTrackingRecords.where((record) {
      final recordDate = DateTime(
        record.clockInTime.year,
        record.clockInTime.month,
        record.clockInTime.day,
      );
      return recordDate.isAtSameMomentAs(date);
    }).toList();
  }

  List<LeaveRequest> _getLeaveRequestsForDate(DateTime date) {
    return _leaveRequests.where((request) {
      return (date.isAtSameMomentAs(request.startDate) || 
              date.isAtSameMomentAs(request.endDate) ||
              (date.isAfter(request.startDate) && date.isBefore(request.endDate))) &&
             request.status == LeaveStatus.approved;
    }).toList();
  }

  Color _getDateColor(List<TimeTracking> records, List<LeaveRequest> leaveRequests) {
    if (leaveRequests.isNotEmpty) return Colors.blue[100]!; // Leave days
    if (records.isEmpty) return Colors.grey[100]!;
    
    final hasIncompleteRecords = records.any((record) => 
      record.clockOutTime == null && record.status != TimeTrackingStatus.clockedOut);
    
    if (hasIncompleteRecords) return Colors.orange[100]!;
    
    return Colors.green[100]!;
  }

  Widget _buildDayContent(List<TimeTracking> dayRecords, List<LeaveRequest> dayLeaveRequests) {
    final allItems = <Widget>[];
    
    // Add leave requests first
    for (final request in dayLeaveRequests) {
      final staff = _staffMembers.firstWhere(
        (s) => s.id == request.staffMemberId,
        orElse: () => StaffMember.create(
          employeeId: 'Unknown',
          fullName: 'Unknown Staff',
          email: 'unknown@example.com',
          phone: '000-000-0000',
          role: StaffRole.assistant,
        ),
      );
      allItems.add(_buildLeaveCard(request, staff));
    }
    
    // Add time tracking records
    for (final record in dayRecords) {
      final staff = _staffMembers.firstWhere(
        (s) => s.id == record.staffMemberId,
        orElse: () => StaffMember.create(
          employeeId: 'Unknown',
          fullName: 'Unknown Staff',
          email: 'unknown@example.com',
          phone: '000-000-0000',
          role: StaffRole.assistant,
        ),
      );
      allItems.add(_buildStaffCard(record, staff));
    }
    
    if (allItems.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return ListView.builder(
      itemCount: allItems.length,
      itemBuilder: (context, index) => allItems[index],
    );
  }

  Widget _buildLeaveCard(LeaveRequest request, StaffMember staff) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: request.type.color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: request.type.color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(
            request.type.icon,
            size: 10,
            color: request.type.color,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              '${staff.fullName}: On ${request.type.displayName.toLowerCase()}',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: request.type.color,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  // Public method to refresh leave data when approvals/rejections happen
  Future<void> refreshLeaveData() async {
    await _loadLeaveRequests();
    setState(() {});
  }
}
