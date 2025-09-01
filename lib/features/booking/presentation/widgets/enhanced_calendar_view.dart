import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/blackout_date.dart';
import 'package:cat_hotel_pos/features/booking/presentation/providers/booking_providers.dart';

enum CalendarViewType { daily, weekly, monthly }

class EnhancedCalendarView extends ConsumerStatefulWidget {
  const EnhancedCalendarView({super.key});

  @override
  ConsumerState<EnhancedCalendarView> createState() => _EnhancedCalendarViewState();
}

class _EnhancedCalendarViewState extends ConsumerState<EnhancedCalendarView> {
  CalendarViewType _viewType = CalendarViewType.weekly;
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  Booking? _draggedBooking;
  String? _draggedOverRoomId;
  bool _showBlackoutDates = true;
  bool _showOccupancyBoard = true;

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(filteredBookingsProvider);
    final roomsAsync = ref.watch(roomsProvider);

    return Column(
      children: [
        // Enhanced Calendar Controls
        _buildEnhancedCalendarControls(),
        
        // Live Occupancy Board (if enabled)
        if (_showOccupancyBoard) _buildLiveOccupancyBoard(),
        
        // Calendar View
        Expanded(
          child: bookingsAsync.when(
            data: (bookings) => roomsAsync.when(
              data: (rooms) => _buildEnhancedCalendarContent(bookings, rooms),
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

  Widget _buildEnhancedCalendarControls() {
    return Container(
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
          // View Type Selector
          Row(
            children: [
              Expanded(
                child: SegmentedButton<CalendarViewType>(
                  segments: const [
                    ButtonSegment(
                      value: CalendarViewType.daily,
                      label: Text('Daily'),
                      icon: Icon(Icons.view_day),
                    ),
                    ButtonSegment(
                      value: CalendarViewType.weekly,
                      label: Text('Weekly'),
                      icon: Icon(Icons.view_week),
                    ),
                                         ButtonSegment(
                       value: CalendarViewType.monthly,
                       label: Text('Monthly'),
                       icon: Icon(Icons.calendar_view_month),
                     ),
                  ],
                  selected: {_viewType},
                  onSelectionChanged: (Set<CalendarViewType> selection) {
                    setState(() {
                      _viewType = selection.first;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Toggle switches
              Row(
                children: [
                  Row(
                    children: [
                      Switch(
                        value: _showBlackoutDates,
                        onChanged: (value) {
                          setState(() {
                            _showBlackoutDates = value;
                          });
                        },
                      ),
                      const Text('Blackout Dates'),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      Switch(
                        value: _showOccupancyBoard,
                        onChanged: (value) {
                          setState(() {
                            _showOccupancyBoard = value;
                          });
                        },
                      ),
                      const Text('Occupancy Board'),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Navigation Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => _navigateDate(-1),
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Previous',
                  ),
                  Text(
                    _getDateRangeText(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _navigateDate(1),
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Next',
                  ),
                ],
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _goToToday,
                    icon: const Icon(Icons.today),
                    label: const Text('Today'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showCreateBookingDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('New Booking'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveOccupancyBoard() {
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
              const Icon(Icons.dashboard, color: Colors.indigo),
              const SizedBox(width: 8),
              const Text(
                'Live Occupancy Board',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'Last updated: ${DateTime.now().toString().substring(11, 16)}',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Consumer(
            builder: (context, ref, child) {
              final roomsAsync = ref.watch(roomsProvider);
              return roomsAsync.when(
                data: (rooms) {
                  final totalRooms = rooms.length;
                  final occupiedRooms = rooms.where((r) => r.status == RoomStatus.occupied).length;
                  final availableRooms = rooms.where((r) => r.status == RoomStatus.available).length;
                  final cleaningRooms = rooms.where((r) => r.status == RoomStatus.cleaning).length;
                  final maintenanceRooms = rooms.where((r) => r.status == RoomStatus.maintenance).length;
                  final reservedRooms = rooms.where((r) => r.status == RoomStatus.reserved).length;

                  return Row(
                    children: [
                      _buildOccupancyCard('Total', totalRooms, Colors.grey),
                      _buildOccupancyCard('Occupied', occupiedRooms, Colors.orange),
                      _buildOccupancyCard('Available', availableRooms, Colors.green),
                      _buildOccupancyCard('Cleaning', cleaningRooms, Colors.yellow),
                      _buildOccupancyCard('Maintenance', maintenanceRooms, Colors.red),
                      _buildOccupancyCard('Reserved', reservedRooms, Colors.blue),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyCard(String label, int count, Color color) {
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

  Widget _buildEnhancedCalendarContent(List<Booking> bookings, List<Room> rooms) {
    switch (_viewType) {
      case CalendarViewType.daily:
        return _buildEnhancedDailyView(bookings, rooms);
      case CalendarViewType.weekly:
        return _buildEnhancedWeeklyView(bookings, rooms);
      case CalendarViewType.monthly:
        return _buildEnhancedMonthlyView(bookings, rooms);
    }
  }

  Widget _buildEnhancedDailyView(List<Booking> bookings, List<Room> rooms) {
    final dayBookings = _getBookingsForDate(_selectedDate, bookings);
    
    return SingleChildScrollView(
      child: Column(
        children: [
          // Room headers
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 80), // Time column space
                ...rooms.map((room) => Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border(right: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          room.roomNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          room.type.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getRoomStatusColor(room.status),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            room.status.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )).toList(),
              ],
            ),
          ),
          // Time slots with enhanced drag and drop
          ...List.generate(24, (hour) {
            final timeBookings = dayBookings.where((booking) {
              final checkInHour = booking.checkInTime.hour;
              final checkOutHour = booking.checkOutTime.hour;
              return hour >= checkInHour && hour < checkOutHour;
            }).toList();

            return Container(
              height: 80,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                color: hour % 2 == 0 ? Colors.white : Colors.grey.shade50,
              ),
              child: Row(
                children: [
                  // Time label
                  SizedBox(
                    width: 80,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Text(
                            '${hour.toString().padLeft(2, '0')}:00',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (hour == 11) // Standard checkout time
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Checkout',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Room columns with enhanced drag and drop
                  Expanded(
                    child: Row(
                      children: rooms.map((room) {
                        final roomBookings = timeBookings.where((b) => b.roomId == room.id).toList();
                        return Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(right: BorderSide(color: Colors.grey.shade200)),
                            ),
                            child: _buildEnhancedTimeSlot(room, roomBookings, hour),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEnhancedTimeSlot(Room room, List<Booking> bookings, int hour) {
    if (bookings.isEmpty) {
      return DragTarget<Booking>(
        onWillAccept: (data) => data != null,
        onAccept: (booking) => _handleEnhancedBookingDrop(booking, room.id, hour),
        builder: (context, candidateData, rejectedData) {
          return Container(
            color: candidateData.isNotEmpty ? Colors.blue.withOpacity(0.1) : null,
            child: Center(
              child: candidateData.isNotEmpty
                  ? const Icon(Icons.add, color: Colors.blue, size: 20)
                  : null,
            ),
          );
        },
      );
    }

    final booking = bookings.first;
    return Draggable<Booking>(
      data: booking,
      feedback: Material(
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                booking.petName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                booking.customerName,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
      childWhenDragging: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: Icon(Icons.drag_handle, color: Colors.grey),
        ),
      ),
      onDragStarted: () {
        setState(() {
          _draggedBooking = booking;
        });
      },
      onDragEnd: (details) {
        setState(() {
          _draggedBooking = null;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _getBookingColor(booking.status),
          borderRadius: BorderRadius.circular(6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.petName,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              booking.customerName,
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
            Text(
              '${booking.checkInTime.hour}:${booking.checkInTime.minute.toString().padLeft(2, '0')} - ${booking.checkOutTime.hour}:${booking.checkOutTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                booking.status.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedWeeklyView(List<Booking> bookings, List<Room> rooms) {
    final weekDays = _getWeekDates(_focusedDate);
    
    return Column(
      children: [
        // Week header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 80), // Time column space
              ...weekDays.map((date) => Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _getDayName(date.weekday),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${date.day}/${date.month}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      if (_isSameDay(date, DateTime.now()))
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'TODAY',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )).toList(),
            ],
          ),
        ),
        // Week content with enhanced features
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...List.generate(24, (hour) {
                  return Container(
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                      color: hour % 2 == 0 ? Colors.white : Colors.grey.shade50,
                    ),
                    child: Row(
                      children: [
                        // Time label
                        SizedBox(
                          width: 80,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              '${hour.toString().padLeft(2, '0')}:00',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // Day columns
                        ...weekDays.map((date) {
                          final dayBookings = _getBookingsForDate(date, bookings);
                          final timeBookings = dayBookings.where((booking) {
                            final checkInHour = booking.checkInTime.hour;
                            final checkOutHour = booking.checkOutTime.hour;
                            return hour >= checkInHour && hour < checkOutHour;
                          }).toList();

                          return Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(right: BorderSide(color: Colors.grey.shade200)),
                              ),
                              child: _buildEnhancedWeeklyTimeSlot(timeBookings, hour, date),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedWeeklyTimeSlot(List<Booking> bookings, int hour, DateTime date) {
    if (bookings.isEmpty) {
      return DragTarget<Booking>(
        onWillAccept: (data) => data != null,
        onAccept: (booking) => _handleEnhancedWeeklyBookingDrop(booking, date, hour),
        builder: (context, candidateData, rejectedData) {
          return Container(
            color: candidateData.isNotEmpty ? Colors.blue.withOpacity(0.1) : null,
            child: Center(
              child: candidateData.isNotEmpty
                  ? const Icon(Icons.add, color: Colors.blue, size: 16)
                  : null,
            ),
          );
        },
      );
    }

    final booking = bookings.first;
    return Draggable<Booking>(
      data: booking,
      feedback: Material(
        elevation: 8,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            booking.petName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      childWhenDragging: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: Icon(Icons.drag_handle, color: Colors.grey, size: 16),
        ),
      ),
      onDragStarted: () {
        setState(() {
          _draggedBooking = booking;
        });
      },
      onDragEnd: (details) {
        setState(() {
          _draggedBooking = null;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(1),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _getBookingColor(booking.status),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              booking.petName,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              booking.roomNumber,
              style: const TextStyle(fontSize: 8, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedMonthlyView(List<Booking> bookings, List<Room> rooms) {
    final monthStart = DateTime(_selectedDate.year, _selectedDate.month, 1);
    final monthEnd = DateTime(_selectedDate.year, _selectedDate.month + 1, 0);
    final firstWeekday = monthStart.weekday;
    final daysInMonth = monthEnd.day;

    final calendarDays = <DateTime>[];
    
    // Add previous month's days to fill first week
    for (int i = firstWeekday - 1; i > 0; i--) {
      calendarDays.add(monthStart.subtract(Duration(days: i)));
    }
    
    // Add current month's days
    for (int i = 1; i <= daysInMonth; i++) {
      calendarDays.add(DateTime(_selectedDate.year, _selectedDate.month, i));
    }
    
    // Add next month's days to fill last week
    final remainingDays = 42 - calendarDays.length; // 6 weeks * 7 days
    for (int i = 1; i <= remainingDays; i++) {
      calendarDays.add(monthEnd.add(Duration(days: i)));
    }

    return Column(
      children: [
        // Month header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 80), // Week column space
              ...['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) => Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.grey.shade300)),
                  ),
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )).toList(),
            ],
          ),
        ),
        // Month content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...List.generate(6, (weekIndex) {
                  final weekDays = calendarDays.skip(weekIndex * 7).take(7).toList();
                  return Container(
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: Row(
                      children: [
                        // Week label
                        SizedBox(
                          width: 80,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Text(
                              'Week ${weekIndex + 1}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // Day columns
                        ...weekDays.map((date) {
                          final dayBookings = _getBookingsForDate(date, bookings);
                          final isCurrentMonth = date.month == _selectedDate.month;
                          
                          return Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(right: BorderSide(color: Colors.grey.shade200)),
                                color: isCurrentMonth ? null : Colors.grey.shade50,
                              ),
                              child: _buildEnhancedMonthlyDaySlot(dayBookings, date, isCurrentMonth),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedMonthlyDaySlot(List<Booking> bookings, DateTime date, bool isCurrentMonth) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date number
          Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isCurrentMonth ? Colors.black : Colors.grey,
            ),
          ),
          // Booking indicators
          if (bookings.isNotEmpty) ...[
            const SizedBox(height: 2),
            ...bookings.take(3).map((booking) => Container(
              margin: const EdgeInsets.only(bottom: 1),
              height: 4,
              decoration: BoxDecoration(
                color: _getBookingColor(booking.status),
                borderRadius: BorderRadius.circular(2),
              ),
            )),
            if (bookings.length > 3)
              Text(
                '+${bookings.length - 3}',
                style: const TextStyle(
                  fontSize: 8,
                  color: Colors.grey,
                ),
              ),
          ],
          // Today indicator
          if (_isSameDay(date, DateTime.now()))
            Container(
              margin: const EdgeInsets.only(top: 2),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'TODAY',
                style: TextStyle(
                  fontSize: 8,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Enhanced drag and drop handlers
  void _handleEnhancedBookingDrop(Booking booking, String roomId, int hour) async {
    try {
      final bookingService = ref.read(bookingServiceProvider);
      
      // Update the booking with new time
      final updatedBooking = await bookingService.updateBooking(
        id: booking.id,
        checkInTime: BookingTimeOfDay(hour: hour, minute: 0),
        checkOutTime: BookingTimeOfDay(hour: hour + 1, minute: 0),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking moved to ${updatedBooking.roomNumber}'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the bookings list
        ref.invalidate(bookingsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error moving booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleEnhancedWeeklyBookingDrop(Booking booking, DateTime date, int hour) async {
    try {
      final bookingService = ref.read(bookingServiceProvider);
      
      // Update the booking with new date and time
      final updatedBooking = await bookingService.updateBooking(
        id: booking.id,
        checkInDate: date,
        checkOutDate: date.add(const Duration(days: 1)),
        checkInTime: BookingTimeOfDay(hour: hour, minute: 0),
        checkOutTime: BookingTimeOfDay(hour: hour + 1, minute: 0),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking moved to ${date.toString().split(' ')[0]}'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the bookings list
        ref.invalidate(bookingsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error moving booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCreateBookingDialog() {
    // TODO: Implement create booking dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create booking dialog coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Helper methods
  List<DateTime> _getWeekDates(DateTime date) {
    final startOfWeek = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
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

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
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
        return Colors.green;
      case RoomStatus.occupied:
        return Colors.orange;
      case RoomStatus.maintenance:
        return Colors.red;
      case RoomStatus.cleaning:
        return Colors.yellow;
      case RoomStatus.reserved:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getBookingColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.checkedIn:
        return Colors.green;
      case BookingStatus.checkedOut:
        return Colors.grey;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.noShow:
        return Colors.purple;
      case BookingStatus.completed:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
}
