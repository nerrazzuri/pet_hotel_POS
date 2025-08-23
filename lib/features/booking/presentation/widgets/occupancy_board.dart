import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/features/booking/presentation/providers/booking_providers.dart';

class OccupancyBoard extends ConsumerStatefulWidget {
  const OccupancyBoard({super.key});

  @override
  ConsumerState<OccupancyBoard> createState() => _OccupancyBoardState();
}

class _OccupancyBoardState extends ConsumerState<OccupancyBoard> {
  DateTime _selectedDate = DateTime.now();
  bool _showOnlyAvailable = false;
  bool _showOnlyOccupied = false;

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsProvider);
    final bookingsAsync = ref.watch(filteredBookingsProvider);

    return Column(
      children: [
        // Controls
        _buildControls(),
        
        // Statistics
        _buildStatistics(roomsAsync, bookingsAsync),
        
        // Room Grid
        Expanded(
          child: roomsAsync.when(
            data: (rooms) => bookingsAsync.when(
              data: (bookings) => _buildRoomGrid(rooms, bookings),
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
          
          // Filter Toggles
          FilterChip(
            label: const Text('Available'),
            selected: _showOnlyAvailable,
            onSelected: (selected) {
              setState(() {
                _showOnlyAvailable = selected;
                if (selected) _showOnlyOccupied = false;
              });
            },
          ),
          
          const SizedBox(width: 8),
          
          FilterChip(
            label: const Text('Occupied'),
            selected: _showOnlyOccupied,
            onSelected: (selected) {
              setState(() {
                _showOnlyOccupied = selected;
                if (selected) _showOnlyAvailable = false;
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

  Widget _buildStatistics(AsyncValue<List<Room>> roomsAsync, AsyncValue<List<Booking>> bookingsAsync) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: roomsAsync.when(
        data: (rooms) => bookingsAsync.when(
          data: (bookings) {
            final totalRooms = rooms.length;
            final availableRooms = rooms.where((r) => r.status == RoomStatus.available).length;
            final occupiedRooms = rooms.where((r) => r.status == RoomStatus.occupied).length;
            final maintenanceRooms = rooms.where((r) => r.status == RoomStatus.maintenance).length;
            final cleaningRooms = rooms.where((r) => r.status == RoomStatus.cleaning).length;
            final reservedRooms = rooms.where((r) => r.status == RoomStatus.reserved).length;
            
            final occupancyRate = totalRooms > 0 ? (occupiedRooms / totalRooms * 100).toStringAsFixed(1) : '0.0';
            
            return Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Rooms',
                    '$totalRooms',
                    Icons.home,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Available',
                    '$availableRooms',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Occupied',
                    '$occupiedRooms',
                    Icons.person,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Maintenance',
                    '$maintenanceRooms',
                    Icons.build,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Cleaning',
                    '$cleaningRooms',
                    Icons.cleaning_services,
                    Colors.yellow,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Reserved',
                    '$reservedRooms',
                    Icons.bookmark,
                    Colors.purple,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Occupancy Rate',
                    '$occupancyRate%',
                    Icons.trending_up,
                    Colors.indigo,
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

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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

  Widget _buildRoomGrid(List<Room> rooms, List<Booking> bookings) {
    // Filter rooms based on selection
    List<Room> filteredRooms = rooms;
    if (_showOnlyAvailable) {
      filteredRooms = rooms.where((r) => r.status == RoomStatus.available).toList();
    } else if (_showOnlyOccupied) {
      filteredRooms = rooms.where((r) => r.status == RoomStatus.occupied).toList();
    }

    // Get bookings for selected date
    final dayBookings = _getBookingsForDate(_selectedDate, bookings);

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredRooms.length,
      itemBuilder: (context, index) {
        final room = filteredRooms[index];
        final roomBookings = dayBookings.where((b) => b.roomId == room.id).toList();
        
        return _buildRoomCard(room, roomBookings);
      },
    );
  }

  Widget _buildRoomCard(Room room, List<Booking> bookings) {
    final isOccupied = bookings.isNotEmpty;
    final currentBooking = isOccupied ? bookings.first : null;
    
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _showRoomDetails(room, currentBooking),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _getRoomStatusColor(room.status),
            border: Border.all(
              color: isOccupied ? Colors.orange : Colors.grey.shade300,
              width: isOccupied ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              // Room Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      room.roomNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      room.name,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              // Room Status
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getRoomStatusIcon(room.status),
                        size: 32,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        room.status.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (room.capacity > 1)
                        Text(
                          'Capacity: ${room.capacity}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              
              // Booking Info
              if (isOccupied && currentBooking != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.9),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        currentBooking.customerName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        currentBooking.petName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '${currentBooking.checkInTime.hour}:${currentBooking.checkInTime.minute.toString().padLeft(2, '0')} - ${currentBooking.checkOutTime.hour}:${currentBooking.checkOutTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRoomDetails(Room room, Booking? currentBooking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Room ${room.roomNumber} - ${room.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${room.type.name}'),
            Text('Status: ${room.status.name}'),
            Text('Capacity: ${room.capacity}'),
            Text('Base Price: \$${room.basePricePerNight}'),
            Text('Peak Price: \$${room.peakSeasonPrice}'),
            if (room.description.isNotEmpty)
              Text('Description: ${room.description}'),
            if (room.amenities.isNotEmpty)
              Text('Amenities: ${room.amenities.join(', ')}'),
            if (room.notes?.isNotEmpty == true)
              Text('Notes: ${room.notes}'),
            if (room.maintenanceNotes?.isNotEmpty == true)
              Text('Maintenance: ${room.maintenanceNotes}'),
            if (currentBooking != null) ...[
              const Divider(),
              Text('Current Booking:', style: Theme.of(context).textTheme.titleSmall),
              Text('Customer: ${currentBooking.customerName}'),
              Text('Pet: ${currentBooking.petName}'),
              Text('Check-in: ${currentBooking.checkInTime}'),
              Text('Check-out: ${currentBooking.checkOutTime}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (room.status == RoomStatus.available)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _createBookingForRoom(room);
              },
              child: const Text('Book Now'),
            ),
        ],
      ),
    );
  }

  void _createBookingForRoom(Room room) {
    // Navigate to booking creation with pre-selected room
    // This would typically open a booking form
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Creating booking for Room ${room.roomNumber}'),
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

  Color _getRoomStatusColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.available:
        return Colors.green.shade400;
      case RoomStatus.occupied:
        return Colors.orange.shade400;
      case RoomStatus.maintenance:
        return Colors.red.shade400;
      case RoomStatus.cleaning:
        return Colors.yellow.shade400;
      case RoomStatus.reserved:
        return Colors.blue.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  IconData _getRoomStatusIcon(RoomStatus status) {
    switch (status) {
      case RoomStatus.available:
        return Icons.check_circle;
      case RoomStatus.occupied:
        return Icons.person;
      case RoomStatus.maintenance:
        return Icons.build;
      case RoomStatus.cleaning:
        return Icons.cleaning_services;
      case RoomStatus.reserved:
        return Icons.bookmark;
      default:
        return Icons.help;
    }
  }
}
