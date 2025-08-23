// Functional Booking DAO for Android compatibility
// Provides in-memory storage with sample data

import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';

// import 'package:uuid/uuid.dart';

class BookingDao {
  static final Map<String, Booking> _bookings = {};
  static bool _initialized = false;
  // TODO: Uncomment when implementing UUID generation
  // static final Uuid _uuid = const Uuid();

  static void _initialize() {
    if (_initialized) return;
    
    // Create sample bookings
    _bookings['booking_001'] = Booking(
      id: 'booking_001',
      bookingNumber: 'BK-2024-001',
      customerId: 'cust_001',
      customerName: 'Sarah Johnson',
      petId: 'pet_001',
      petName: 'Whiskers',
      roomId: 'room_003',
      roomNumber: '201',
      checkInDate: DateTime.now().subtract(const Duration(days: 2)),
      checkOutDate: DateTime.now().add(const Duration(days: 3)),
      checkInTime: BookingTimeOfDay(hour: 14, minute: 0),
      checkOutTime: BookingTimeOfDay(hour: 11, minute: 0),
      status: BookingStatus.checkedIn,
      type: BookingType.standard,
      basePricePerNight: 95.00,
      totalAmount: 475.00,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
      depositAmount: 100.00,
      specialInstructions: 'Please provide extra grooming attention',
      careNotes: 'Loves window views, feed twice daily',
      assignedStaffId: 'staff_001',
      assignedStaffName: 'John Doe',
      actualCheckInTime: DateTime.now().subtract(const Duration(days: 2, hours: 2)),
      paymentMethod: 'card',
      paymentStatus: 'paid',
      receiptNumber: 'R240820001',
    );

    _bookings['booking_002'] = Booking(
      id: 'booking_002',
      bookingNumber: 'BK-2024-002',
      customerId: 'cust_002',
      customerName: 'Mike Chen',
      petId: 'pet_002',
      petName: 'Shadow',
      roomId: 'room_002',
      roomNumber: '102',
      checkInDate: DateTime.now().add(const Duration(days: 1)),
      checkOutDate: DateTime.now().add(const Duration(days: 4)),
      checkInTime: BookingTimeOfDay(hour: 15, minute: 0),
      checkOutTime: BookingTimeOfDay(hour: 10, minute: 0),
      status: BookingStatus.confirmed,
      type: BookingType.standard,
      basePricePerNight: 65.00,
      totalAmount: 195.00,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      updatedAt: DateTime.now(),
      depositAmount: 50.00,
      specialInstructions: 'Quiet room preferred',
      careNotes: 'Independent cat, minimal interaction needed',
      assignedStaffId: 'staff_002',
      assignedStaffName: 'Jane Smith',
      paymentMethod: 'cash',
      paymentStatus: 'partial',
    );

    _bookings['booking_003'] = Booking(
      id: 'booking_003',
      bookingNumber: 'BK-2024-003',
      customerId: 'cust_003',
      customerName: 'Emma Wilson',
      petId: 'pet_003',
      petName: 'Luna',
      roomId: 'room_001',
      roomNumber: '101',
      checkInDate: DateTime.now().add(const Duration(days: 2)),
      checkOutDate: DateTime.now().add(const Duration(days: 5)),
      checkInTime: BookingTimeOfDay(hour: 16, minute: 0),
      checkOutTime: BookingTimeOfDay(hour: 12, minute: 0),
      status: BookingStatus.pending,
      type: BookingType.grooming,
      basePricePerNight: 45.00,
      totalAmount: 135.00,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
      depositAmount: 0.00,
      specialInstructions: 'Include grooming service',
      careNotes: 'Sensitive to loud noises, gentle handling required',
      paymentMethod: 'card',
      paymentStatus: 'pending',
    );

    _bookings['booking_004'] = Booking(
      id: 'booking_004',
      bookingNumber: 'BK-2024-004',
      customerId: 'cust_004',
      customerName: 'David Kim',
      petId: 'pet_004',
      petName: 'Tiger',
      roomId: 'room_004',
      roomNumber: '202',
      checkInDate: DateTime.now().subtract(const Duration(days: 10)),
      checkOutDate: DateTime.now().subtract(const Duration(days: 3)),
      checkInTime: BookingTimeOfDay(hour: 13, minute: 0),
      checkOutTime: BookingTimeOfDay(hour: 10, minute: 0),
      status: BookingStatus.completed,
      type: BookingType.medical,
      basePricePerNight: 75.00,
      totalAmount: 525.00,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
      depositAmount: 150.00,
      specialInstructions: 'Medical monitoring required',
      careNotes: 'Arthritis management, gentle exercise only',
      veterinaryNotes: 'Monitor joint mobility, administer supplements',
      assignedStaffId: 'staff_003',
      assignedStaffName: 'Dr. Lisa Wong',
      actualCheckInTime: DateTime.now().subtract(const Duration(days: 10, hours: 1)),
      actualCheckOutTime: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
      paymentMethod: 'card',
      paymentStatus: 'paid',
      receiptNumber: 'R240810001',
    );

    _bookings['booking_005'] = Booking(
      id: 'booking_005',
      bookingNumber: 'BK-2024-005',
      customerId: 'cust_005',
      customerName: 'Lisa Brown',
      petId: 'pet_005',
      petName: 'Mittens',
      roomId: 'room_005',
      roomNumber: '301',
      checkInDate: DateTime.now().add(const Duration(days: 3)),
      checkOutDate: DateTime.now().add(const Duration(days: 7)),
      checkInTime: BookingTimeOfDay(hour: 14, minute: 0),
      checkOutTime: BookingTimeOfDay(hour: 11, minute: 0),
      status: BookingStatus.confirmed,
      type: BookingType.extended,
      basePricePerNight: 85.00,
      totalAmount: 340.00,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now(),
      depositAmount: 100.00,
      specialInstructions: 'Family suite for multiple cats',
      careNotes: 'Very relaxed cat, loves being held',
      assignedStaffId: 'staff_001',
      assignedStaffName: 'John Doe',
      paymentMethod: 'e_wallet',
      paymentStatus: 'paid',
    );

    _initialized = true;
  }

  Future<void> insert(Booking booking) async {
    _initialize();
    _bookings[booking.id] = booking;
  }

  Future<Booking?> getById(String id) async {
    _initialize();
    return _bookings[id];
  }

  Future<List<Booking>> getAll() async {
    _initialize();
    return _bookings.values.toList();
  }

  Future<List<Booking>> getByCustomerId(String customerId) async {
    _initialize();
    return _bookings.values.where((booking) => booking.customerId == customerId).toList();
  }

  Future<List<Booking>> getByRoomId(String roomId) async {
    _initialize();
    return _bookings.values.where((booking) => booking.roomId == roomId).toList();
  }

  Future<List<Booking>> getByDateRange(DateTime startDate, DateTime endDate) async {
    _initialize();
    return _bookings.values.where((booking) => 
      (booking.checkInDate.isAfter(startDate) || booking.checkInDate.isAtSameMomentAs(startDate)) &&
      (booking.checkInDate.isBefore(endDate) || booking.checkInDate.isAtSameMomentAs(endDate))
    ).toList();
  }

  Future<List<Booking>> getByStatus(BookingStatus status) async {
    _initialize();
    return _bookings.values.where((booking) => booking.status == status).toList();
  }

  Future<Booking> update(Booking booking) async {
    _initialize();
    _bookings[booking.id] = booking;
    return booking;
  }

  Future<void> delete(String id) async {
    _initialize();
    _bookings.remove(id);
  }

  Future<List<Booking>> search(String query) async {
    _initialize();
    if (query.trim().isEmpty) return _bookings.values.toList();
    
    final lowercaseQuery = query.toLowerCase();
    return _bookings.values.where((booking) =>
      booking.bookingNumber.toLowerCase().contains(lowercaseQuery) ||
      booking.customerName.toLowerCase().contains(lowercaseQuery) ||
      booking.petName.toLowerCase().contains(lowercaseQuery) ||
      (booking.specialInstructions?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }

  Future<List<Booking>> getUpcomingBookings() async {
    _initialize();
    final now = DateTime.now();
    return _bookings.values.where((booking) => 
      booking.checkInDate.isAfter(now) && 
      (booking.status == BookingStatus.confirmed || booking.status == BookingStatus.pending)
    ).toList();
  }

  Future<List<Booking>> getOverdueBookings() async {
    _initialize();
    final now = DateTime.now();
    return _bookings.values.where((booking) => 
      booking.checkOutDate.isBefore(now) && 
      booking.status == BookingStatus.checkedIn
    ).toList();
  }

  Future<List<Booking>> getBookingsForToday() async {
    _initialize();
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return _bookings.values.where((booking) => 
      (booking.checkInDate.isAfter(startOfDay) || booking.checkInDate.isAtSameMomentAs(startOfDay)) &&
      booking.checkInDate.isBefore(endOfDay)
    ).toList();
  }

  Future<List<Booking>> getBookingsForWeek() async {
    _initialize();
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 7));
    
    return _bookings.values.where((booking) => 
      (booking.checkInDate.isAfter(startOfWeek) || booking.checkInDate.isAtSameMomentAs(startOfWeek)) &&
      booking.checkInDate.isBefore(endOfWeek)
    ).toList();
  }

  Future<List<Booking>> getBookingsForMonth() async {
    _initialize();
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 1);
    
    return _bookings.values.where((booking) => 
      (booking.checkInDate.isAfter(startOfMonth) || booking.checkInDate.isAtSameMomentAs(startOfMonth)) &&
      booking.checkInDate.isBefore(endOfMonth)
    ).toList();
  }

  Future<int> getTotalBookings() async {
    _initialize();
    return _bookings.length;
  }

  Future<double> getTotalRevenue() async {
    _initialize();
    double total = 0.0;
    for (final booking in _bookings.values) {
      total += booking.totalAmount;
    }
    return total;
  }

  Future<Map<String, int>> getBookingsByStatus() async {
    _initialize();
    final result = <String, int>{};
    for (final booking in _bookings.values) {
      final status = booking.status.name;
      result[status] = (result[status] ?? 0) + 1;
    }
    return result;
  }

  Future<Map<String, int>> getBookingsByMonth() async {
    _initialize();
    final result = <String, int>{};
    for (final booking in _bookings.values) {
      final month = '${booking.checkInDate.year}-${booking.checkInDate.month.toString().padLeft(2, '0')}';
      result[month] = (result[month] ?? 0) + 1;
    }
    return result;
  }

  // Additional methods that BookingService expects
  Future<Booking?> getByBookingNumber(String bookingNumber) async {
    _initialize();
    try {
      return _bookings.values.firstWhere((booking) => booking.bookingNumber == bookingNumber);
    } catch (e) {
      return null;
    }
  }

  Future<List<Booking>> getActiveBookings() async {
    _initialize();
    return _bookings.values.where((booking) => 
      booking.status == BookingStatus.checkedIn || 
      booking.status == BookingStatus.confirmed
    ).toList();
  }

  Future<List<Booking>> searchBookings({
    String? query,
    BookingStatus? status,
    BookingType? type,
    DateTime? fromDate,
    DateTime? toDate,
    String? customerId,
    String? roomId,
  }) async {
    _initialize();
    return _bookings.values.where((booking) {
      bool matches = true;
      
      if (query != null && query.isNotEmpty) {
        final searchLower = query.toLowerCase();
        matches = matches && (
          booking.bookingNumber.toLowerCase().contains(searchLower) ||
          booking.customerName.toLowerCase().contains(searchLower) ||
          booking.petName.toLowerCase().contains(searchLower) ||
          (booking.specialInstructions?.toLowerCase().contains(searchLower) ?? false)
        );
      }
      
      if (status != null) {
        matches = matches && booking.status == status;
      }
      
      if (type != null) {
        matches = matches && booking.type == type;
      }
      
      if (fromDate != null) {
        matches = matches && (booking.checkInDate.isAfter(fromDate) || booking.checkInDate.isAtSameMomentAs(fromDate));
      }
      
      if (toDate != null) {
        matches = matches && (booking.checkInDate.isBefore(toDate) || booking.checkInDate.isAtSameMomentAs(toDate));
      }
      
      if (customerId != null) {
        matches = matches && booking.customerId == customerId;
      }
      
      if (roomId != null) {
        matches = matches && booking.roomId == roomId;
      }
      
      return matches;
    }).toList();
  }

  Future<void> softDelete(String bookingId) async {
    _initialize();
    // For now, just remove the booking since there's no isActive field
    // In a real implementation, you might want to add this field to the entity
    _bookings.remove(bookingId);
  }

  // Get bookings by date range
  Future<List<Booking>> getBookingsByDateRange(DateTime startDate, DateTime endDate) async {
    _initialize();
    return _bookings.values.where((booking) {
      return (booking.checkInDate.isAfter(startDate) || booking.checkInDate.isAtSameMomentAs(startDate)) &&
             (booking.checkInDate.isBefore(endDate) || booking.checkInDate.isAtSameMomentAs(endDate));
    }).toList();
  }
}
