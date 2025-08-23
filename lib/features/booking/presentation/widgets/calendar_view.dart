import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:cat_hotel_pos/features/booking/presentation/providers/booking_providers.dart';

enum CalendarViewType { daily, weekly, monthly }

class CalendarView extends ConsumerStatefulWidget {
  const CalendarView({super.key});

  @override
  ConsumerState<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends ConsumerState<CalendarView> {
  CalendarViewType _viewType = CalendarViewType.weekly;
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  // TODO: Implement drag and drop functionality
  // Booking? _draggedBooking;

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(filteredBookingsProvider);
    final roomsAsync = ref.watch(roomsProvider);

    return Column(
      children: [
        // Calendar Controls
        _buildCalendarControls(),
        
        // Calendar View
        Expanded(
          child: bookingsAsync.when(
            data: (bookings) => roomsAsync.when(
              data: (rooms) => _buildCalendarContent(bookings, rooms),
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

  Widget _buildCalendarControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // View Type Selector
          DropdownButton<CalendarViewType>(
            value: _viewType,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _viewType = value;
                });
              }
            },
            items: CalendarViewType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(type.name.toUpperCase()),
              );
            }).toList(),
          ),
          
          const SizedBox(width: 16),
          
          // Navigation Buttons
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _navigateDate(-1),
          ),
          TextButton(
            onPressed: () => _goToToday(),
            child: const Text('TODAY'),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _navigateDate(1),
          ),
          
          const Spacer(),
          
          // Date Display
          Text(
            _getDateRangeText(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarContent(List<Booking> bookings, List<Room> rooms) {
    switch (_viewType) {
      case CalendarViewType.daily:
        return _buildDailyView(bookings, rooms);
      case CalendarViewType.weekly:
        return _buildWeeklyView(bookings, rooms);
      case CalendarViewType.monthly:
        return _buildMonthlyView(bookings, rooms);
    }
  }

  Widget _buildDailyView(List<Booking> bookings, List<Room> rooms) {
    final dayBookings = _getBookingsForDate(_selectedDate, bookings);
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Time slots header
          _buildTimeHeader(),
          
          // Room columns with time slots
          ...rooms.map((room) => _buildRoomTimeColumn(room, dayBookings)),
        ],
      ),
    );
  }

  Widget _buildWeeklyView(List<Booking> bookings, List<Room> rooms) {
    final weekDates = _getWeekDates(_focusedDate);
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Week header
            _buildWeekHeader(weekDates),
            
            // Room rows with week columns
            ...rooms.map((room) => _buildRoomWeekRow(room, weekDates, bookings)),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyView(List<Booking> bookings, List<Room> rooms) {
    final monthDates = _getMonthDates(_focusedDate);
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Month grid
          _buildMonthGrid(monthDates, bookings, rooms),
        ],
      ),
    );
  }

  Widget _buildTimeHeader() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Center(
              child: Text(
                'Time',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 24,
              itemBuilder: (context, index) {
                return Container(
                  width: 80,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.grey.shade200)),
                  ),
                  child: Text('${index.toString().padLeft(2, '0')}:00'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomTimeColumn(Room room, List<Booking> dayBookings) {
    final roomBookings = dayBookings.where((b) => b.roomId == room.id).toList();
    
    return Container(
      height: 600,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          // Room info
          SizedBox(
            width: 120,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getRoomStatusColor(room.status),
                border: Border(right: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.roomNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    room.name,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    room.status.name,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          
          // Time slots
          Expanded(
            child: Stack(
              children: [
                // Time grid
                _buildTimeGrid(),
                
                // Bookings
                ...roomBookings.map((booking) => _buildBookingSlot(booking)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeGrid() {
    return Column(
      children: List.generate(24, (index) {
        return Container(
          height: 25,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade100),
              right: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBookingSlot(Booking booking) {
    final startHour = booking.checkInTime.hour;
    final duration = _calculateDuration(booking.checkInTime, booking.checkOutTime);
    
    return Positioned(
      left: startHour * 80.0,
      top: startHour * 25.0,
      child: Container(
        width: duration * 80.0,
        height: duration * 25.0,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: _getBookingStatusColor(booking.status),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Center(
          child: Text(
            '${booking.customerName}\n${booking.petName}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekHeader(List<DateTime> weekDates) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Center(
              child: Text(
                'Room',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
          ),
          ...weekDates.map((date) => Expanded(
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _getDayName(date.weekday),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '${date.day}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRoomWeekRow(Room room, List<DateTime> weekDates, List<Booking> bookings) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          // Room info
          SizedBox(
            width: 120,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getRoomStatusColor(room.status),
                border: Border(right: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.roomNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    room.name,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          
          // Week columns
          ...weekDates.map((date) => Expanded(
            child: _buildWeekDayCell(room, date, bookings),
          )),
        ],
      ),
    );
  }

  Widget _buildWeekDayCell(Room room, DateTime date, List<Booking> bookings) {
    final dayBookings = _getBookingsForDate(date, bookings)
        .where((b) => b.roomId == room.id)
        .toList();
    
    return Container(
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Stack(
        children: [
          // Background
          Container(
            color: dayBookings.isEmpty ? Colors.green.shade50 : Colors.orange.shade100,
          ),
          
          // Bookings
          ...dayBookings.map((booking) => _buildWeekDayBooking(booking)),
        ],
      ),
    );
  }

  Widget _buildWeekDayBooking(Booking booking) {
    return Container(
      margin: const EdgeInsets.all(2),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _getBookingStatusColor(booking.status),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '${booking.customerName}\n${booking.petName}',
        style: const TextStyle(
          fontSize: 8,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildMonthGrid(List<DateTime> monthDates, List<Booking> bookings, List<Room> rooms) {
    return Column(
      children: [
        // Month header
        Container(
          padding: const EdgeInsets.all(16),
          child: Text(
            '${_focusedDate.month}/${_focusedDate.year}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        
        // Calendar grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 1.2,
          ),
          itemCount: monthDates.length,
          itemBuilder: (context, index) {
            final date = monthDates[index];
            final dayBookings = _getBookingsForDate(date, bookings);
            
            return _buildMonthDayCell(date, dayBookings, rooms);
          },
        ),
      ],
    );
  }

  Widget _buildMonthDayCell(DateTime date, List<Booking> dayBookings, List<Room> rooms) {
    final isToday = _isSameDay(date, DateTime.now());
    
    return Container(
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: isToday ? Colors.blue.shade100 : Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // Date header
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isToday ? Colors.blue : Colors.grey.shade200,
            ),
            child: Text(
              '${date.day}',
              style: TextStyle(
                color: isToday ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          // Booking count
          if (dayBookings.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(4),
              child: Text(
                '${dayBookings.length} bookings',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          
          // Room status summary
          Expanded(
            child: _buildMonthDayRoomStatus(date, rooms, dayBookings),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthDayRoomStatus(DateTime date, List<Room> rooms, List<Booking> dayBookings) {
    final occupiedRooms = dayBookings.map((b) => b.roomId).toSet();
    final availableRooms = rooms.where((r) => !occupiedRooms.contains(r.id)).length;
    
    return Container(
      padding: const EdgeInsets.all(4),
      child: Column(
        children: [
          Text(
            'Available: $availableRooms',
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 10,
            ),
          ),
          Text(
            'Occupied: ${occupiedRooms.length}',
            style: TextStyle(
              color: Colors.orange.shade700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  List<DateTime> _getWeekDates(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

  List<DateTime> _getMonthDates(DateTime date) {
    final startOfMonth = DateTime(date.year, date.month, 1);
    final endOfMonth = DateTime(date.year, date.month + 1, 0);
    
    final startOfWeek = startOfMonth.subtract(Duration(days: startOfMonth.weekday - 1));
    final endOfWeek = endOfMonth.add(Duration(days: 7 - endOfMonth.weekday));
    
    final days = endOfWeek.difference(startOfWeek).inDays + 1;
    return List.generate(days, (index) => startOfWeek.add(Duration(days: index)));
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

  int _calculateDuration(BookingTimeOfDay start, BookingTimeOfDay end) {
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    final durationMinutes = endMinutes - startMinutes;
    return (durationMinutes / 60).ceil(); // Round up to nearest hour
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getDateRangeText() {
    switch (_viewType) {
      case CalendarViewType.daily:
        return '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}';
      case CalendarViewType.weekly:
        final weekDates = _getWeekDates(_focusedDate);
        return '${weekDates.first.day}/${weekDates.first.month} - ${weekDates.last.day}/${weekDates.last.month}';
      case CalendarViewType.monthly:
        return '${_focusedDate.month}/${_focusedDate.year}';
    }
  }

  void _navigateDate(int days) {
    setState(() {
      switch (_viewType) {
        case CalendarViewType.daily:
          _selectedDate = _selectedDate.add(Duration(days: days));
          _focusedDate = _selectedDate;
          break;
        case CalendarViewType.weekly:
          _focusedDate = _focusedDate.add(Duration(days: days * 7));
          break;
        case CalendarViewType.monthly:
          _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + days, 1);
          break;
      }
    });
  }

  void _goToToday() {
    setState(() {
      _selectedDate = DateTime.now();
      _focusedDate = DateTime.now();
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Color _getRoomStatusColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.available:
        return Colors.green.shade100;
      case RoomStatus.occupied:
        return Colors.orange.shade100;
      case RoomStatus.maintenance:
        return Colors.red.shade100;
      case RoomStatus.cleaning:
        return Colors.yellow.shade100;
      case RoomStatus.reserved:
        return Colors.blue.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getBookingStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.checkedIn:
        return Colors.green;
      case BookingStatus.checkedOut:
        return Colors.grey;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.noShow:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
