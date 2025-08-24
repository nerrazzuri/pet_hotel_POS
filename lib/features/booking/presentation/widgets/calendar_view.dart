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
  // Implemented drag and drop functionality
  Booking? _draggedBooking;
  String? _draggedOverRoomId;

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
          // Time slots
          ...List.generate(24, (hour) {
            final timeBookings = dayBookings.where((booking) {
              final checkInHour = booking.checkInTime.hour;
              final checkOutHour = booking.checkOutTime.hour;
              return hour >= checkInHour && hour < checkOutHour;
            }).toList();

            return Container(
              height: 60,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  // Time label
                  SizedBox(
                    width: 80,
                    child: Text(
                      '${hour.toString().padLeft(2, '0')}:00',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  // Room columns
                  Expanded(
                    child: Row(
                      children: rooms.map((room) {
                        final roomBookings = timeBookings.where((b) => b.roomId == room.id).toList();
                        return Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                right: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                            child: _buildTimeSlot(room, roomBookings, hour),
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

  Widget _buildTimeSlot(Room room, List<Booking> bookings, int hour) {
    if (bookings.isEmpty) {
      return DragTarget<Booking>(
        onWillAccept: (data) => data != null,
        onAccept: (booking) => _handleBookingDrop(booking, room.id, hour),
        builder: (context, candidateData, rejectedData) {
          return Container(
            color: candidateData.isNotEmpty ? Colors.blue.withOpacity(0.1) : null,
            child: const Center(
              child: Text('', style: TextStyle(fontSize: 10)),
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
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${booking.petName}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
      childWhenDragging: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: const Center(
          child: Text('', style: TextStyle(fontSize: 10)),
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
              booking.customerName,
              style: const TextStyle(fontSize: 8, color: Colors.white70),
            ),
            Text(
              '${booking.checkInTime.hour}:${booking.checkInTime.minute.toString().padLeft(2, '0')} - ${booking.checkOutTime.hour}:${booking.checkOutTime.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 8, color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyView(List<Booking> bookings, List<Room> rooms) {
    final weekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    final weekDays = List.generate(7, (index) => weekStart.add(Duration(days: index)));

    return Column(
      children: [
        // Week header
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 80), // Time column spacer
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
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
        // Week content
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                ...List.generate(24, (hour) {
                  return Container(
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Row(
                      children: [
                        // Time label
                        SizedBox(
                          width: 80,
                          child: Text(
                            '${hour.toString().padLeft(2, '0')}:00',
                            style: const TextStyle(fontSize: 12),
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
                                border: Border(right: BorderSide(color: Colors.grey.shade300)),
                              ),
                              child: _buildWeeklyTimeSlot(timeBookings, hour, date),
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

  Widget _buildWeeklyTimeSlot(List<Booking> bookings, int hour, DateTime date) {
    if (bookings.isEmpty) {
      return DragTarget<Booking>(
        onWillAccept: (data) => data != null,
        onAccept: (booking) => _handleWeeklyBookingDrop(booking, date, hour),
        builder: (context, candidateData, rejectedData) {
          return Container(
            color: candidateData.isNotEmpty ? Colors.blue.withOpacity(0.1) : null,
            child: const Center(
              child: Text('', style: TextStyle(fontSize: 10)),
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
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '${booking.petName}',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ),
      childWhenDragging: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid),
        ),
        child: const Center(
          child: Text('', style: TextStyle(fontSize: 10)),
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

  Widget _buildMonthlyView(List<Booking> bookings, List<Room> rooms) {
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
          child: Row(
            children: [
              const SizedBox(width: 80), // Time column spacer
              ...['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'].map((day) => Expanded(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              )),
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
                    height: 100,
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
                    ),
                    child: Row(
                      children: [
                        // Time label (showing week number for monthly view)
                        SizedBox(
                          width: 80,
                          child: Text(
                            'Week ${weekIndex + 1}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        // Day columns
                        ...weekDays.map((date) {
                          final dayBookings = _getBookingsForDate(date, bookings);
                          final isCurrentMonth = date.month == _selectedDate.month;
                          
                          return Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border(right: BorderSide(color: Colors.grey.shade300)),
                                color: isCurrentMonth ? null : Colors.grey.shade50,
                              ),
                              child: _buildMonthlyDaySlot(dayBookings, date, isCurrentMonth),
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

  Widget _buildMonthlyDaySlot(List<Booking> bookings, DateTime date, bool isCurrentMonth) {
    return Container(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isCurrentMonth ? Colors.black : Colors.grey,
            ),
          ),
          if (bookings.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...bookings.take(3).map((booking) => Container(
              margin: const EdgeInsets.only(bottom: 2),
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: _getBookingColor(booking.status),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                '${booking.petName}',
                style: const TextStyle(
                  fontSize: 8,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            )),
            if (bookings.length > 3)
              Text(
                '+${bookings.length - 3} more',
                style: const TextStyle(fontSize: 8, color: Colors.grey),
              ),
          ],
        ],
      ),
    );
  }

  // Drag and drop handlers
  void _handleBookingDrop(Booking booking, String roomId, int hour) async {
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
          SnackBar(content: Text('Booking moved to ${updatedBooking.roomNumber}')),
        );
        // Refresh the bookings list
        ref.invalidate(bookingsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error moving booking: $e')),
        );
      }
    }
  }

  void _handleWeeklyBookingDrop(Booking booking, DateTime date, int hour) async {
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
          SnackBar(content: Text('Booking moved to ${date.toString().split(' ')[0]}')),
        );
        // Refresh the bookings list
        ref.invalidate(bookingsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error moving booking: $e')),
        );
      }
    }
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

  Color _getBookingColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.checkedIn:
        return Colors.green;
      case BookingStatus.checkedOut:
        return Colors.grey;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.noShow:
        return Colors.purple;
      case BookingStatus.completed:
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }
}
