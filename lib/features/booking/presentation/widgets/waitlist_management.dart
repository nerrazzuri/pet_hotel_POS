import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/waitlist.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:cat_hotel_pos/features/booking/presentation/providers/booking_providers.dart';

class WaitlistManagement extends ConsumerStatefulWidget {
  const WaitlistManagement({super.key});

  @override
  ConsumerState<WaitlistManagement> createState() => _WaitlistManagementState();
}

class _WaitlistManagementState extends ConsumerState<WaitlistManagement> {
  WaitlistStatus? _selectedStatus;
  WaitlistPriority? _selectedPriority;
  RoomType? _selectedRoomType;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final waitlistAsync = ref.watch(waitlistEntriesProvider);
    final statisticsAsync = ref.watch(waitlistStatisticsProvider);
    final roomsAsync = ref.watch(roomsProvider);

    return Column(
      children: [
        // Header with statistics
        _buildHeader(statisticsAsync),
        
        // Controls
        _buildControls(),
        
        // Waitlist entries
        Expanded(
          child: waitlistAsync.when(
            data: (entries) => _buildWaitlistEntries(entries, roomsAsync),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(AsyncValue<Map<String, dynamic>> statisticsAsync) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.queue, color: Colors.indigo),
              const SizedBox(width: 8),
              const Text(
                'Waitlist Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: () => _showAddToWaitlistDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Add to Waitlist'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          statisticsAsync.when(
            data: (stats) => Row(
              children: [
                _buildStatCard('Total', stats['total'] ?? 0, Colors.grey),
                _buildStatCard('Pending', stats['pending'] ?? 0, Colors.orange),
                _buildStatCard('Urgent', stats['urgent'] ?? 0, Colors.red),
                _buildStatCard('High', stats['high'] ?? 0, Colors.purple),
                _buildStatCard('Today', stats['today'] ?? 0, Colors.blue),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search by customer name, pet name, or phone...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          const SizedBox(height: 16),
          // Filter chips
          Wrap(
            spacing: 8,
            children: [
              // Status filters
              ...WaitlistStatus.values.map((status) => FilterChip(
                label: Text(status.name.toUpperCase()),
                selected: _selectedStatus == status,
                onSelected: (selected) {
                  setState(() {
                    _selectedStatus = selected ? status : null;
                  });
                },
                backgroundColor: Colors.grey.shade100,
                selectedColor: Colors.blue.shade100,
              )),
              const SizedBox(width: 16),
              // Priority filters
              ...WaitlistPriority.values.map((priority) => FilterChip(
                label: Text(priority.name.toUpperCase()),
                selected: _selectedPriority == priority,
                onSelected: (selected) {
                  setState(() {
                    _selectedPriority = selected ? priority : null;
                  });
                },
                backgroundColor: Colors.grey.shade100,
                selectedColor: _getPriorityColor(priority).withOpacity(0.2),
              )),
              const SizedBox(width: 16),
              // Room type filters
              ...RoomType.values.map((roomType) => FilterChip(
                label: Text(roomType.displayName),
                selected: _selectedRoomType == roomType,
                onSelected: (selected) {
                  setState(() {
                    _selectedRoomType = selected ? roomType : null;
                  });
                },
                backgroundColor: Colors.grey.shade100,
                selectedColor: Colors.green.shade100,
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaitlistEntries(List<WaitlistEntry> entries, AsyncValue<List<Room>> roomsAsync) {
    return roomsAsync.when(
      data: (rooms) {
        final filteredEntries = _filterEntries(entries);
          
        if (filteredEntries.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.queue_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No waitlist entries found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Add customers to the waitlist when rooms are unavailable',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filteredEntries.length,
          itemBuilder: (context, index) {
            final entry = filteredEntries[index];
            return _buildWaitlistCard(entry, rooms);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  List<WaitlistEntry> _filterEntries(List<WaitlistEntry> entries) {
    return entries.where((entry) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!entry.customerName.toLowerCase().contains(query) &&
            !entry.petName.toLowerCase().contains(query) &&
            !entry.phoneNumber.contains(query) &&
            !entry.email.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Status filter
      if (_selectedStatus != null && entry.status != _selectedStatus) {
        return false;
      }

      // Priority filter
      if (_selectedPriority != null && entry.priority != _selectedPriority) {
        return false;
      }

      // Room type filter
      if (_selectedRoomType != null && entry.preferredRoomType != _selectedRoomType) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _buildWaitlistCard(WaitlistEntry entry, List<Room> rooms) {
    final priorityColor = _getPriorityColor(entry.priority);
    final statusColor = _getStatusColor(entry.status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: priorityColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.customerName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          entry.petName,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: priorityColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          entry.priority.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: priorityColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          entry.status.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Phone', entry.phoneNumber),
                        _buildDetailRow('Email', entry.email),
                        _buildDetailRow('Room Type', entry.preferredRoomType.displayName),
                        _buildDetailRow('Number of Pets', entry.numberOfPets.toString()),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow('Check-in', _formatDate(entry.requestedCheckInDate)),
                        _buildDetailRow('Check-out', _formatDate(entry.requestedCheckOutDate)),
                        _buildDetailRow('Created', _formatDate(entry.createdAt)),
                        if (entry.notes != null)
                          _buildDetailRow('Notes', entry.notes!),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showAvailableRooms(entry, rooms),
                      icon: const Icon(Icons.room),
                      label: const Text('Check Availability'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(entry),
                      icon: const Icon(Icons.update),
                      label: const Text('Update Status'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showEntryDetails(entry),
                    icon: const Icon(Icons.info),
                    tooltip: 'View Details',
                  ),
                  IconButton(
                    onPressed: () => _cancelEntry(entry),
                    icon: const Icon(Icons.cancel),
                    tooltip: 'Cancel Entry',
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(WaitlistPriority priority) {
    switch (priority) {
      case WaitlistPriority.low:
        return Colors.green;
      case WaitlistPriority.medium:
        return Colors.orange;
      case WaitlistPriority.high:
        return Colors.red;
      case WaitlistPriority.urgent:
        return Colors.purple;
    }
  }

  Color _getStatusColor(WaitlistStatus status) {
    switch (status) {
      case WaitlistStatus.pending:
        return Colors.orange;
      case WaitlistStatus.notified:
        return Colors.blue;
      case WaitlistStatus.confirmed:
        return Colors.green;
      case WaitlistStatus.cancelled:
        return Colors.red;
      case WaitlistStatus.expired:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddToWaitlistDialog() {
    // TODO: Implement add to waitlist dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Add to waitlist dialog coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showAvailableRooms(WaitlistEntry entry, List<Room> rooms) {
    // TODO: Implement available rooms dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Available rooms dialog coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _updateStatus(WaitlistEntry entry) {
    // TODO: Implement status update dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Status update dialog coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showEntryDetails(WaitlistEntry entry) {
    // TODO: Implement entry details dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Entry details dialog coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _cancelEntry(WaitlistEntry entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Waitlist Entry'),
        content: Text('Are you sure you want to cancel the waitlist entry for ${entry.customerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement cancel entry
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cancel entry functionality coming soon!'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
