import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/features/booking/presentation/providers/booking_providers.dart';

enum HousekeepingTaskType {
  cleaning,
  maintenance,
  inspection,
  restocking,
  deepCleaning,
}

enum TaskPriority { low, medium, high, urgent }

class HousekeepingStatus extends ConsumerStatefulWidget {
  const HousekeepingStatus({super.key});

  @override
  ConsumerState<HousekeepingStatus> createState() => _HousekeepingStatusState();
}

class _HousekeepingStatusState extends ConsumerState<HousekeepingStatus> {
  DateTime _selectedDate = DateTime.now();
  HousekeepingTaskType? _selectedTaskType;
  bool _showCompleted = false;

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsProvider);
    final bookingsAsync = ref.watch(filteredBookingsProvider);

    return Column(
      children: [
        // Controls
        _buildControls(),
        
        // Housekeeping Summary
        _buildHousekeepingSummary(roomsAsync, bookingsAsync),
        
        // Task List
        Expanded(
          child: roomsAsync.when(
            data: (rooms) => bookingsAsync.when(
              data: (bookings) => _buildTaskList(rooms, bookings),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Date Selector
          ElevatedButton.icon(
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.calendar_today),
            label: Text(
              '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Task Type Filter
          DropdownButton<HousekeepingTaskType?>(
            value: _selectedTaskType,
            hint: const Text('All Tasks'),
            onChanged: (value) {
              setState(() {
                _selectedTaskType = value;
              });
            },
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('All Tasks'),
              ),
              ...HousekeepingTaskType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Show Completed Toggle
          FilterChip(
            label: const Text('Show Completed'),
            selected: _showCompleted,
            onSelected: (selected) {
              setState(() {
                _showCompleted = selected;
              });
            },
          ),
          
          const Spacer(),
          
          // Refresh Button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(roomsProvider);
              ref.invalidate(filteredBookingsProvider);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildHousekeepingSummary(AsyncValue<List<Room>> roomsAsync, AsyncValue<List<Booking>> bookingsAsync) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: roomsAsync.when(
        data: (rooms) => bookingsAsync.when(
          data: (bookings) {
            final totalRooms = rooms.length;
            final cleaningRooms = rooms.where((r) => r.status == RoomStatus.cleaning).length;
            final maintenanceRooms = rooms.where((r) => r.status == RoomStatus.maintenance).length;
            final availableRooms = rooms.where((r) => r.status == RoomStatus.available).length;
            final occupiedRooms = rooms.where((r) => r.status == RoomStatus.occupied).length;
            
            final pendingTasks = cleaningRooms + maintenanceRooms;
            final completedTasks = totalRooms - pendingTasks - occupiedRooms;
            
            return Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    'Total Rooms',
                    '$totalRooms',
                    Icons.home,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard(
                    'Pending Tasks',
                    '$pendingTasks',
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard(
                    'Completed',
                    '$completedTasks',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard(
                    'Cleaning',
                    '$cleaningRooms',
                    Icons.cleaning_services,
                    Colors.yellow,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard(
                    'Maintenance',
                    '$maintenanceRooms',
                    Icons.build,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSummaryCard(
                    'Available',
                    '$availableRooms',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Room> rooms, List<Booking> bookings) {
    // Filter rooms based on task type
    List<Room> filteredRooms = rooms;
    if (_selectedTaskType != null) {
      switch (_selectedTaskType!) {
        case HousekeepingTaskType.cleaning:
          filteredRooms = rooms.where((r) => r.status == RoomStatus.cleaning).toList();
          break;
        case HousekeepingTaskType.maintenance:
          filteredRooms = rooms.where((r) => r.status == RoomStatus.maintenance).toList();
          break;
        case HousekeepingTaskType.inspection:
          filteredRooms = rooms.where((r) => r.status == RoomStatus.available).toList();
          break;
        case HousekeepingTaskType.restocking:
          filteredRooms = rooms.where((r) => r.status == RoomStatus.available).toList();
          break;
        case HousekeepingTaskType.deepCleaning:
          filteredRooms = rooms.where((r) => r.status == RoomStatus.cleaning).toList();
          break;
      }
    }

    // Filter based on completion status
    if (!_showCompleted) {
      filteredRooms = filteredRooms.where((r) => 
        r.status == RoomStatus.cleaning || 
        r.status == RoomStatus.maintenance
      ).toList();
    }

    if (filteredRooms.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'No pending housekeeping tasks!',
              style: TextStyle(fontSize: 18, color: Colors.green),
            ),
            Text(
              'All rooms are ready for guests.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRooms.length,
      itemBuilder: (context, index) {
        final room = filteredRooms[index];
        final roomBookings = _getBookingsForDate(_selectedDate, bookings)
            .where((b) => b.roomId == room.id)
            .toList();
        
        return _buildTaskCard(room, roomBookings);
      },
    );
  }

  Widget _buildTaskCard(Room room, List<Booking> bookings) {
    final isCompleted = room.status == RoomStatus.available;
    final taskType = _getTaskTypeForRoom(room);
    final priority = _getTaskPriority(room, bookings);
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getPriorityColor(priority),
            width: 2,
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getTaskTypeColor(taskType),
            child: Icon(
              _getTaskTypeIcon(taskType),
              color: Colors.white,
            ),
          ),
          title: Row(
            children: [
              Text(
                'Room ${room.roomNumber}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getPriorityColor(priority),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  priority.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(room.name),
              Text('Status: ${room.status.name}'),
              if (room.maintenanceNotes?.isNotEmpty == true)
                Text('Notes: ${room.maintenanceNotes}'),
              if (bookings.isNotEmpty)
                Text('Last Guest: ${bookings.first.customerName}'),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isCompleted) ...[
                IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: () => _completeTask(room),
                  tooltip: 'Mark as Complete',
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  onPressed: () => _editTask(room),
                  tooltip: 'Edit Task',
                ),
              ] else ...[
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Completed',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          onTap: () => _showTaskDetails(room, bookings),
        ),
      ),
    );
  }

  void _showTaskDetails(Room room, List<Booking> bookings) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Housekeeping Task - Room ${room.roomNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Room: ${room.name}'),
            Text('Type: ${room.type.name}'),
            Text('Status: ${room.status.name}'),
            Text('Capacity: ${room.capacity}'),
            if (room.description.isNotEmpty)
              Text('Description: ${room.description}'),
            if (room.amenities.isNotEmpty)
              Text('Amenities: ${room.amenities.join(', ')}'),
            if (room.notes?.isNotEmpty == true)
              Text('Notes: ${room.notes}'),
            if (room.maintenanceNotes?.isNotEmpty == true)
              Text('Maintenance: ${room.maintenanceNotes}'),
            if (bookings.isNotEmpty) ...[
              const Divider(),
              Text('Last Booking:', style: Theme.of(context).textTheme.titleSmall),
              Text('Customer: ${bookings.first.customerName}'),
              Text('Pet: ${bookings.first.petName}'),
              Text('Check-out: ${bookings.first.checkOutTime}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (room.status != RoomStatus.available)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _completeTask(room);
              },
              child: const Text('Mark Complete'),
            ),
        ],
      ),
    );
  }

  void _completeTask(Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Complete Task - Room ${room.roomNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to mark this task as complete?'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Completion Notes',
                hintText: 'Enter any notes about the completed task...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _markTaskComplete(room);
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _markTaskComplete(Room room) {
    // In a real implementation, this would update the room status
    // For now, just show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task completed for Room ${room.roomNumber}'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  void _editTask(Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Task - Room ${room.roomNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Task Notes',
                hintText: 'Enter task details...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              controller: TextEditingController(text: room.maintenanceNotes ?? ''),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _updateTask(room);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _updateTask(Room room) {
    // In a real implementation, this would update the room
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Task updated for Room ${room.roomNumber}'),
        backgroundColor: Colors.blue,
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  List<Booking> _getBookingsForDate(DateTime date, List<Booking> bookings) {
    return bookings.where((booking) {
      final checkIn = DateTime(booking.checkInDate.year, booking.checkInDate.month, booking.checkInDate.day);
      final checkOut = DateTime(booking.checkOutDate.year, booking.checkOutDate.month, booking.checkOutDate.day);
      final targetDate = DateTime(date.year, date.month, date.day);
      
      return targetDate.isAfter(checkIn.subtract(const Duration(days: 1))) &&
             targetDate.isBefore(checkOut.add(const Duration(days: 1)));
    }).toList();
  }

  HousekeepingTaskType _getTaskTypeForRoom(Room room) {
    switch (room.status) {
      case RoomStatus.cleaning:
        return HousekeepingTaskType.cleaning;
      case RoomStatus.maintenance:
        return HousekeepingTaskType.maintenance;
      case RoomStatus.available:
        return HousekeepingTaskType.inspection;
      default:
        return HousekeepingTaskType.cleaning;
    }
  }

  TaskPriority _getTaskPriority(Room room, List<Booking> bookings) {
    // Simple priority logic - in real implementation, this would be more sophisticated
    if (room.status == RoomStatus.maintenance) {
      return TaskPriority.high;
    } else if (room.status == RoomStatus.cleaning && bookings.isNotEmpty) {
      return TaskPriority.medium;
    } else {
      return TaskPriority.low;
    }
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.green;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.urgent:
        return Colors.purple;
    }
  }

  Color _getTaskTypeColor(HousekeepingTaskType taskType) {
    switch (taskType) {
      case HousekeepingTaskType.cleaning:
        return Colors.yellow;
      case HousekeepingTaskType.maintenance:
        return Colors.red;
      case HousekeepingTaskType.inspection:
        return Colors.blue;
      case HousekeepingTaskType.restocking:
        return Colors.green;
      case HousekeepingTaskType.deepCleaning:
        return Colors.orange;
    }
  }

  IconData _getTaskTypeIcon(HousekeepingTaskType taskType) {
    switch (taskType) {
      case HousekeepingTaskType.cleaning:
        return Icons.cleaning_services;
      case HousekeepingTaskType.maintenance:
        return Icons.build;
      case HousekeepingTaskType.inspection:
        return Icons.search;
      case HousekeepingTaskType.restocking:
        return Icons.inventory;
      case HousekeepingTaskType.deepCleaning:
        return Icons.cleaning_services;
    }
  }
}
