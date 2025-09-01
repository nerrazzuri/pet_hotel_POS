import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:cat_hotel_pos/features/booking/presentation/providers/room_providers.dart';
import 'package:cat_hotel_pos/features/booking/presentation/widgets/create_room_dialog.dart';
import 'package:cat_hotel_pos/features/booking/presentation/widgets/edit_room_dialog.dart';
import 'package:cat_hotel_pos/features/booking/presentation/widgets/room_details_dialog.dart';
import 'package:uuid/uuid.dart';

class RoomManagementScreen extends ConsumerStatefulWidget {
  const RoomManagementScreen({super.key});

  @override
  ConsumerState<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends ConsumerState<RoomManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  RoomStatus? _selectedStatus;
  RoomType? _selectedType;
  String _searchQuery = '';
  bool _showAdvancedSearch = false;

  @override
  void initState() {
    super.initState();
    // Seed default rooms if none exist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _seedDefaultRoomsIfNeeded();
    });
  }

  Future<void> _seedDefaultRoomsIfNeeded() async {
    final rooms = await ref.read(roomsProvider.future);
    if (rooms.isEmpty) {
      final roomService = ref.read(roomServiceProvider);
      await roomService.seedDefaultRooms();
      ref.invalidate(roomsProvider);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Room Management'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        actions: [
          // Enhanced search toggle
          IconButton(
            icon: Icon(_showAdvancedSearch ? Icons.search_off : Icons.search),
            onPressed: () {
              setState(() {
                _showAdvancedSearch = !_showAdvancedSearch;
              });
            },
            tooltip: _showAdvancedSearch ? 'Hide Advanced Search' : 'Show Advanced Search',
          ),
          // Export button
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportRoomData,
            tooltip: 'Export Room Data',
          ),
          // Create room button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateRoomDialog(context),
            tooltip: 'Add New Room',
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(roomsProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey[50]!,
              Colors.blue[50]!,
            ],
          ),
        ),
        child: Column(
          children: [
            // Statistics Cards
            _buildStatisticsCards(roomsAsync),
            
            // Search and Filter Section
            if (_showAdvancedSearch) _buildAdvancedSearchAndFilters(),
            
            // Rooms List
            Expanded(
              child: _buildRoomsList(roomsAsync),
            ),
          ],
        ),
      ),
    );
  }

  void _exportRoomData() {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon!')),
    );
  }

  Widget _buildStatisticsCards(AsyncValue<List<Room>> roomsAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: roomsAsync.when(
        data: (rooms) {
          final totalRooms = rooms.length;
          final availableRooms = rooms.where((r) => r.status == RoomStatus.available).length;
          final occupiedRooms = rooms.where((r) => r.status == RoomStatus.occupied).length;
          final maintenanceRooms = rooms.where((r) => r.status == RoomStatus.maintenance).length;
          
          return Row(
            children: [
              Expanded(
                child: _buildEnhancedStatCard(
                  'Total Rooms',
                  '$totalRooms',
                  Icons.hotel,
                  Colors.blue[700]!,
                  Colors.blue[50]!,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEnhancedStatCard(
                  'Available',
                  '$availableRooms',
                  Icons.check_circle,
                  Colors.green[700]!,
                  Colors.green[50]!,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEnhancedStatCard(
                  'Occupied',
                  '$occupiedRooms',
                  Icons.person,
                  Colors.red[700]!,
                  Colors.red[50]!,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEnhancedStatCard(
                  'Maintenance',
                  '$maintenanceRooms',
                  Icons.build,
                  Colors.orange[700]!,
                  Colors.orange[50]!,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildEnhancedStatCard(String title, String value, IconData icon, Color color, Color backgroundColor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundColor, backgroundColor.withOpacity(0.7)],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSearchAndFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search rooms...',
              hintText: 'Search by room number, name, or description',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              // TODO: Implement search functionality
            },
          ),
          const SizedBox(height: 16),
          // Filter Row
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<RoomStatus?>(
                  value: _selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Status Filter',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Statuses'),
                    ),
                    ...RoomStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.name.toUpperCase()),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedStatus = value;
                    });
                    // TODO: Implement status filter
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<RoomType?>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Type Filter',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ...RoomType.values.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value;
                    });
                    // TODO: Implement type filter
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsList(AsyncValue<List<Room>> roomsAsync) {
    return roomsAsync.when(
      data: (rooms) {
        if (rooms.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.hotel_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No rooms found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Add your first room to get started',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rooms.length,
          itemBuilder: (context, index) {
            final room = rooms[index];
            return _RoomCard(
              room: room,
              onEdit: () => _showEditRoomDialog(context, room),
              onDelete: () => _showDeleteRoomDialog(context, room),
              onView: () => _showRoomDetailsDialog(context, room),
              onStatusChange: (room) => _showStatusChangeDialog(context, room),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading rooms',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateRoomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateRoomDialog(),
    );
  }

  void _showEditRoomDialog(BuildContext context, Room room) {
    showDialog(
      context: context,
      builder: (context) => EditRoomDialog(room: room),
    );
  }

  void _showDeleteRoomDialog(BuildContext context, Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Room'),
        content: Text('Are you sure you want to delete room ${room.roomNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete room
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete room coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showRoomDetailsDialog(BuildContext context, Room room) {
    showDialog(
      context: context,
      builder: (context) => RoomDetailsDialog(room: room),
    );
  }

  void _showStatusChangeDialog(BuildContext context, Room room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Room Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current status: ${room.status.name.toUpperCase()}'),
            const SizedBox(height: 16),
            DropdownButtonFormField<RoomStatus>(
              value: room.status,
              decoration: const InputDecoration(
                labelText: 'New Status',
                border: OutlineInputBorder(),
              ),
              items: RoomStatus.values.map((status) => DropdownMenuItem(
                value: status,
                child: Text(status.name.toUpperCase()),
              )).toList(),
              onChanged: (value) {
                // TODO: Implement status change
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement status change
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Status change coming soon!')),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onView;
  final Function(Room) onStatusChange;

  const _RoomCard({
    required this.room,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
    required this.onStatusChange,
  });

  Color _getStatusColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.available:
        return Colors.green;
      case RoomStatus.occupied:
        return Colors.red;
      case RoomStatus.reserved:
        return Colors.orange;
      case RoomStatus.maintenance:
        return Colors.red[700]!;
      case RoomStatus.cleaning:
        return Colors.blue;
      case RoomStatus.outOfService:
        return Colors.grey;
    }
  }

  Color _getTypeColor(RoomType type) {
    switch (type) {
      case RoomType.standard:
        return Colors.blue;
      case RoomType.deluxe:
        return Colors.purple;
      case RoomType.vip:
        return Colors.amber;
      case RoomType.isolation:
        return Colors.red;
      case RoomType.medical:
        return Colors.teal;
      case RoomType.family:
        return Colors.green;
      case RoomType.outdoor:
        return Colors.brown;
      case RoomType.playroom:
        return Colors.pink;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              _getStatusColor(room.status).withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: _getStatusColor(room.status).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Room Number Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getTypeColor(room.type),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      room.roomNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(room.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(room.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      room.status.name.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(room.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Room Info
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getTypeColor(room.type).withOpacity(0.1),
                    child: Icon(
                      Icons.room,
                      color: _getTypeColor(room.type),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          room.type.displayName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Room Details Grid
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      'Capacity',
                      '${room.capacity} pets',
                      Icons.pets,
                      colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDetailItem(
                      'Price',
                      'MYR ${room.basePricePerNight.toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.green[700]!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      'Type',
                      room.type.displayName,
                      Icons.category,
                      Colors.blue[700]!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDetailItem(
                      'Status',
                      room.status.name.toUpperCase(),
                      Icons.info,
                      Colors.orange[700]!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    'View',
                    Icons.visibility,
                    Colors.blue,
                    onView,
                  ),
                  _buildActionButton(
                    'Edit',
                    Icons.edit,
                    Colors.orange,
                    onEdit,
                  ),
                  _buildActionButton(
                    'Status',
                    Icons.swap_horiz,
                    Colors.purple,
                    () => onStatusChange(room),
                  ),
                  _buildActionButton(
                    'Delete',
                    Icons.delete,
                    Colors.red,
                    onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
