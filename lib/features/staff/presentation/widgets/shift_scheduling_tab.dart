import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/staff_member.dart';
import 'package:cat_hotel_pos/features/staff/domain/entities/shift.dart';
import 'package:cat_hotel_pos/features/staff/domain/services/staff_service.dart';
import 'package:cat_hotel_pos/core/services/staff_dao.dart';
import 'package:intl/intl.dart';

class ShiftSchedulingTab extends ConsumerStatefulWidget {
  const ShiftSchedulingTab({super.key});

  @override
  ConsumerState<ShiftSchedulingTab> createState() => _ShiftSchedulingTabState();
}

class _ShiftSchedulingTabState extends ConsumerState<ShiftSchedulingTab> {
  DateTime _selectedDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('EEEE, MMMM d, y');
  final DateFormat _timeFormat = DateFormat('HH:mm');
  final DateFormat _shortDateFormat = DateFormat('MMM d');

  @override
  Widget build(BuildContext context) {
    final staffService = StaffService(StaffDao());
    
    return Column(
      children: [
        // Date Selector and Actions
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Date Navigation
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.subtract(const Duration(days: 1));
                  });
                },
                icon: const Icon(Icons.chevron_left),
              ),
              
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _dateFormat.format(_selectedDate),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDate = _selectedDate.add(const Duration(days: 1));
                  });
                },
                icon: const Icon(Icons.chevron_right),
              ),
              
              const SizedBox(width: 16),
              
              // Quick Date Buttons
              _buildQuickDateButton('Today', DateTime.now()),
              _buildQuickDateButton('Tomorrow', DateTime.now().add(const Duration(days: 1))),
            ],
          ),
        ),
        
        // Shifts for Selected Date
        Expanded(
          child: FutureBuilder<List<Shift>>(
            future: staffService.getShiftsByDateRange(_selectedDate, _selectedDate),
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
                        'Error loading shifts',
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
              
              final shifts = snapshot.data ?? [];
              
              if (shifts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.schedule_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No shifts scheduled',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'for ${_shortDateFormat.format(_selectedDate)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showCreateShiftDialog(context, staffService),
                        icon: const Icon(Icons.add),
                        label: const Text('Create Shift'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              return Column(
                children: [
                  // Shifts Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Text(
                          '${shifts.length} shift${shifts.length == 1 ? '' : 's'} scheduled',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          onPressed: () => _showCreateShiftDialog(context, staffService),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Shift'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Shifts List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: shifts.length,
                      itemBuilder: (context, index) {
                        final shift = shifts[index];
                        return _buildShiftCard(context, shift, staffService);
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickDateButton(String label, DateTime date) {
    final isSelected = _selectedDate.year == date.year &&
        _selectedDate.month == date.month &&
        _selectedDate.day == date.day;
    
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _selectedDate = date;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.indigo : Colors.grey.shade200,
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Text(label),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildShiftCard(BuildContext context, Shift shift, StaffService staffService) {
    return FutureBuilder<StaffMember?>(
      future: staffService.getStaffMemberById(shift.staffMemberId),
      builder: (context, staffSnapshot) {
        final staff = staffSnapshot.data;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: staff?.role.color ?? Colors.grey,
              child: staff != null
                  ? Text(
                      staff.fullName.split(' ').map((n) => n[0]).join(''),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.person, color: Colors.white),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    staff?.fullName ?? 'Unknown Staff',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: shift.status.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: shift.status.color),
                  ),
                  child: Text(
                    shift.status.displayName,
                    style: TextStyle(
                      color: shift.status.color,
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
                    Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${_timeFormat.format(shift.startTime)}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    if (shift.endTime != null) ...[
                      const Text(' - '),
                      Text(
                        _timeFormat.format(shift.endTime!),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                    if (shift.actualHours != null) ...[
                      const SizedBox(width: 16),
                      Icon(Icons.timer, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        '${shift.actualHours!.toStringAsFixed(1)}h',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ],
                ),
                if (shift.notes != null && shift.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.note, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          shift.notes!,
                          style: TextStyle(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (staff != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.work, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        staff.role.displayName,
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
                ],
              ],
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) => _handleShiftAction(context, value, shift, staffService),
              itemBuilder: (context) => [
                if (shift.status == ShiftStatus.scheduled) ...[
                  const PopupMenuItem(
                    value: 'start',
                    child: Row(
                      children: [
                        Icon(Icons.play_arrow, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Start Shift'),
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
                  const PopupMenuItem(
                    value: 'cancel',
                    child: Row(
                      children: [
                        Icon(Icons.cancel, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Cancel'),
                      ],
                    ),
                  ),
                ],
                if (shift.status == ShiftStatus.active) ...[
                  const PopupMenuItem(
                    value: 'end',
                    child: Row(
                      children: [
                        Icon(Icons.stop, color: Colors.red),
                        SizedBox(width: 8),
                        Text('End Shift'),
                      ],
                    ),
                  ),
                ],
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
            onTap: () => _showShiftDetails(context, shift, staff),
          ),
        );
      },
    );
  }

  void _handleShiftAction(BuildContext context, String action, Shift shift, StaffService staffService) {
    switch (action) {
      case 'start':
        _startShift(context, shift, staffService);
        break;
      case 'end':
        _endShift(context, shift, staffService);
        break;
      case 'edit':
        // TODO: Show edit shift dialog
        break;
      case 'cancel':
        _cancelShift(context, shift, staffService);
        break;
      case 'delete':
        _showDeleteShiftDialog(context, shift, staffService);
        break;
    }
  }

  void _startShift(BuildContext context, Shift shift, StaffService staffService) async {
    try {
      await staffService.startShift(shift.id);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shift started successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting shift: $e')),
      );
    }
  }

  void _endShift(BuildContext context, Shift shift, StaffService staffService) async {
    final actualHoursController = TextEditingController();
    final overtimeHoursController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Shift'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please enter the actual hours worked:'),
            const SizedBox(height: 16),
            TextField(
              controller: actualHoursController,
              decoration: const InputDecoration(
                labelText: 'Actual Hours',
                border: OutlineInputBorder(),
                suffixText: 'hours',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: overtimeHoursController,
              decoration: const InputDecoration(
                labelText: 'Overtime Hours (optional)',
                border: OutlineInputBorder(),
                suffixText: 'hours',
              ),
              keyboardType: TextInputType.number,
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
              final actualHours = double.tryParse(actualHoursController.text) ?? 8.0;
              final overtimeHours = double.tryParse(overtimeHoursController.text) ?? 0.0;
              
              try {
                await staffService.endShift(
                  shift.id,
                  actualHours: actualHours,
                  overtimeHours: overtimeHours,
                );
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Shift ended successfully')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error ending shift: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('End Shift'),
          ),
        ],
      ),
    );
  }

  void _cancelShift(BuildContext context, Shift shift, StaffService staffService) async {
    final updatedShift = shift.copyWith(
      status: ShiftStatus.cancelled,
      updatedAt: DateTime.now(),
    );
    
    try {
      await staffService.updateShift(updatedShift);
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Shift cancelled successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cancelling shift: $e')),
      );
    }
  }

  void _showDeleteShiftDialog(BuildContext context, Shift shift, StaffService staffService) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shift'),
        content: const Text(
          'Are you sure you want to delete this shift? '
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
                final success = await staffService.deleteShift(shift.id);
                Navigator.pop(context);
                if (success) {
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Shift deleted successfully')),
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

  void _showShiftDetails(BuildContext context, Shift shift, StaffMember? staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Shift Details${staff != null ? ' - ${staff.fullName}' : ''}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Staff Member', staff?.fullName ?? 'Unknown'),
              _buildDetailRow('Employee ID', staff?.employeeId ?? 'N/A'),
              _buildDetailRow('Role', staff?.role.displayName ?? 'N/A'),
              _buildDetailRow('Start Time', _timeFormat.format(shift.startTime)),
              if (shift.endTime != null) _buildDetailRow('End Time', _timeFormat.format(shift.endTime!)),
              _buildDetailRow('Status', shift.status.displayName),
              if (shift.actualHours != null) _buildDetailRow('Actual Hours', '${shift.actualHours!.toStringAsFixed(1)}h'),
              if (shift.overtimeHours != null && shift.overtimeHours! > 0) 
                _buildDetailRow('Overtime Hours', '${shift.overtimeHours!.toStringAsFixed(1)}h'),
              if (shift.notes != null && shift.notes!.isNotEmpty) _buildDetailRow('Notes', shift.notes!),
              _buildDetailRow('Created', _dateFormat.format(shift.createdAt)),
              _buildDetailRow('Last Updated', _dateFormat.format(shift.updatedAt)),
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

  void _showCreateShiftDialog(BuildContext context, StaffService staffService) {
    // TODO: Implement create shift dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Create shift dialog - Coming Soon')),
    );
  }
}
