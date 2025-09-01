import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/time_tracking.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/staff_member.dart';
import 'package:cat_hotel_pos/features/staff/domain/services/time_tracking_service.dart';
import 'package:cat_hotel_pos/core/services/time_tracking_dao.dart';
import 'package:cat_hotel_pos/core/services/staff_dao.dart';

class TimeTrackingTab extends ConsumerStatefulWidget {
  const TimeTrackingTab({super.key});

  @override
  ConsumerState<TimeTrackingTab> createState() => _TimeTrackingTabState();
}

class _TimeTrackingTabState extends ConsumerState<TimeTrackingTab> {
  final TimeTrackingService _timeTrackingService = TimeTrackingService(TimeTrackingDao());
  final StaffDao _staffDao = StaffDao();
  
  List<StaffMember> _staffMembers = [];
  List<TimeTracking> _timeTrackingRecords = [];
  StaffMember? _selectedStaff;
  TimeTracking? _activeTracking;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      _staffMembers = await _staffDao.getAll();
      if (_staffMembers.isNotEmpty) {
        _selectedStaff = _staffMembers.first;
        await _loadTimeTrackingRecords();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to load data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTimeTrackingRecords() async {
    if (_selectedStaff == null) return;
    
    try {
      _timeTrackingRecords = await _timeTrackingService.getTimeTrackingByStaffMember(_selectedStaff!.id);
      _activeTracking = await _timeTrackingService.getActiveTracking(_selectedStaff!.id);
    } catch (e) {
      _showErrorSnackBar('Failed to load time tracking records: $e');
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
          _buildActiveTrackingCard(),
          const SizedBox(height: 20),
          _buildTimeTrackingActions(),
          const SizedBox(height: 20),
          _buildTimeTrackingHistory(),
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
          'Time Tracking',
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
                  await _loadTimeTrackingRecords();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTrackingCard() {
    if (_activeTracking == null) {
      return Card(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey[600]),
              const SizedBox(width: 12),
              Text(
                'No active time tracking',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    final tracking = _activeTracking!;
    final duration = DateTime.now().difference(tracking.clockInTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;

    return Card(
      color: tracking.status.color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_circle_filled,
                  color: tracking.status.color,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Active Session',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: tracking.status.color,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: tracking.status.color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tracking.status.displayName,
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
                Text(
                  'Clock In: ${_formatTime(tracking.clockInTime)}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Spacer(),
                Text(
                  'Duration: ${hours}h ${minutes}m',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            if (tracking.location != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Location: ${tracking.location}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeTrackingActions() {
    if (_selectedStaff == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time Tracking Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.login,
                    label: 'Clock In',
                    color: Colors.green,
                    onPressed: _activeTracking == null ? _clockIn : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.logout,
                    label: 'Clock Out',
                    color: Colors.red,
                    onPressed: _activeTracking != null ? _clockOut : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.pause_circle,
                    label: 'Start Break',
                    color: Colors.orange,
                    onPressed: _activeTracking?.status == TimeTrackingStatus.clockedIn ? _startBreak : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.play_circle,
                    label: 'End Break',
                    color: Colors.blue,
                    onPressed: _activeTracking?.status == TimeTrackingStatus.onBreak ? _endBreak : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildTimeTrackingHistory() {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Time Tracking History',
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
                            Icon(Icons.history, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'No time tracking records found',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _timeTrackingRecords.length,
                        itemBuilder: (context, index) {
                          final record = _timeTrackingRecords[index];
                          return _buildTimeTrackingRecordCard(record);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeTrackingRecordCard(TimeTracking record) {
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
                const Spacer(),
                Text(
                  _formatDate(record.clockInTime),
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
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
          ],
        ),
      ),
    );
  }

  Future<void> _clockIn() async {
    if (_selectedStaff == null) return;

    try {
      await _timeTrackingService.clockIn(
        staffMemberId: _selectedStaff!.id,
        location: 'Main Office', // This could be made configurable
      );
      _showSuccessSnackBar('Clocked in successfully');
      await _loadTimeTrackingRecords();
    } catch (e) {
      _showErrorSnackBar('Failed to clock in: $e');
    }
  }

  Future<void> _clockOut() async {
    if (_selectedStaff == null) return;

    try {
      await _timeTrackingService.clockOut(staffMemberId: _selectedStaff!.id);
      _showSuccessSnackBar('Clocked out successfully');
      await _loadTimeTrackingRecords();
    } catch (e) {
      _showErrorSnackBar('Failed to clock out: $e');
    }
  }

  Future<void> _startBreak() async {
    if (_selectedStaff == null) return;

    // Show break type selection dialog
    final breakType = await _showBreakTypeDialog();
    if (breakType != null) {
      try {
        await _timeTrackingService.startBreak(
          staffMemberId: _selectedStaff!.id,
          breakType: breakType,
        );
        _showSuccessSnackBar('Break started');
        await _loadTimeTrackingRecords();
      } catch (e) {
        _showErrorSnackBar('Failed to start break: $e');
      }
    }
  }

  Future<void> _endBreak() async {
    if (_selectedStaff == null) return;

    try {
      await _timeTrackingService.endBreak(staffMemberId: _selectedStaff!.id);
      _showSuccessSnackBar('Break ended');
      await _loadTimeTrackingRecords();
    } catch (e) {
      _showErrorSnackBar('Failed to end break: $e');
    }
  }

  Future<BreakType?> _showBreakTypeDialog() async {
    return showDialog<BreakType>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Break Type'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: BreakType.values.map((type) {
            return ListTile(
              leading: Icon(type.icon),
              title: Text(type.displayName),
              onTap: () => Navigator.of(context).pop(type),
            );
          }).toList(),
        ),
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

extension BreakTypeIcon on BreakType {
  IconData get icon {
    switch (this) {
      case BreakType.lunch:
        return Icons.lunch_dining;
      case BreakType.shortBreak:
        return Icons.coffee;
      case BreakType.personal:
        return Icons.person;
      case BreakType.emergency:
        return Icons.emergency;
    }
  }
}
