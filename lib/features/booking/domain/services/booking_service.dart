import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/core/services/booking_dao.dart';
import 'package:cat_hotel_pos/core/services/room_dao.dart';
import 'package:cat_hotel_pos/core/services/customer_dao.dart';
import 'package:cat_hotel_pos/core/services/pet_dao.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:uuid/uuid.dart';

class BookingService {
  final BookingDao _bookingDao;
  final RoomDao _roomDao;
  final CustomerDao _customerDao;
  final PetDao _petDao;

  BookingService({
    required BookingDao bookingDao,
    required RoomDao roomDao,
    required CustomerDao customerDao,
    required PetDao petDao,
  }) : _bookingDao = bookingDao,
       _roomDao = roomDao,
       _customerDao = customerDao,
       _petDao = petDao;

  // Create a new booking
  Future<Booking> createBooking({
    required String customerId,
    required String petId,
    required String roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required BookingTimeOfDay checkInTime,
    required BookingTimeOfDay checkOutTime,
    required BookingType type,
    required double basePricePerNight,
    List<String>? additionalServices,
    Map<String, double>? servicePrices,
    String? specialInstructions,
    String? careNotes,
    String? veterinaryNotes,
    double? depositAmount,
    double? discountAmount,
    double? taxAmount,
    String? assignedStaffId,
    String? assignedStaffName,
  }) async {
    // Validate dates
    if (checkInDate.isAfter(checkOutDate)) {
      throw ArgumentError('Check-in date cannot be after check-out date');
    }

    if (checkInDate.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      throw ArgumentError('Check-in date cannot be in the past');
    }

    // Get customer and pet information
    final customer = await _customerDao.getById(customerId);
    if (customer == null) {
      throw ArgumentError('Customer not found');
    }

    final pet = await _petDao.getById(petId);
    if (pet == null) {
      throw ArgumentError('Pet not found');
    }

    // Get room information
    final room = await _roomDao.getById(roomId);
    if (room == null) {
      throw ArgumentError('Room not found');
    }

    // Calculate total amount
    final numberOfNights = checkOutDate.difference(checkInDate).inDays;
    final baseAmount = basePricePerNight * numberOfNights;
    
    double servicesAmount = 0.0;
    if (servicePrices != null) {
      for (final price in servicePrices.values) {
        servicesAmount += price;
      }
    }
    
    final subtotal = baseAmount + servicesAmount;
    final tax = taxAmount ?? 0.0;
    final discount = discountAmount ?? 0.0;
    final totalAmount = subtotal + tax - discount;

    // Generate unique booking number
    final bookingNumber = await _generateUniqueBookingNumber();

    final booking = Booking(
      id: const Uuid().v4(),
      bookingNumber: bookingNumber,
      customerId: customerId,
      customerName: '${customer.firstName} ${customer.lastName}',
      petId: petId,
      petName: pet.name,
      roomId: roomId,
      roomNumber: room.roomNumber,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      checkInTime: checkInTime,
      checkOutTime: checkOutTime,
      status: BookingStatus.pending,
      type: type,
      basePricePerNight: basePricePerNight,
      totalAmount: totalAmount,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      depositAmount: depositAmount,
      discountAmount: discountAmount,
      taxAmount: taxAmount,
      specialInstructions: specialInstructions,
      careNotes: careNotes,
      veterinaryNotes: veterinaryNotes,
      additionalServices: additionalServices,
      servicePrices: servicePrices,
      assignedStaffId: assignedStaffId,
      assignedStaffName: assignedStaffName,
    );

    await _bookingDao.insert(booking);

    // Update room status to reserved
    await _roomDao.updateRoomStatus(roomId, RoomStatus.reserved);

    return booking;
  }

  // Generate unique booking number
  Future<String> _generateUniqueBookingNumber() async {
    const prefix = 'BK';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (1000 + (timestamp % 9000)).toString();
    final bookingNumber = '$prefix$timestamp$random';

    // Check if it's unique
    final existing = await _bookingDao.getByBookingNumber(bookingNumber);
    if (existing == null) {
      return bookingNumber;
    }

    // If not unique, try again with a different random number
    return _generateUniqueBookingNumber();
  }

  // Get all bookings
  Future<List<Booking>> getAllBookings() async {
    return await _bookingDao.getAll();
  }

  // Get active bookings
  Future<List<Booking>> getActiveBookings() async {
    return await _bookingDao.getActiveBookings();
  }

  // Get upcoming bookings
  Future<List<Booking>> getUpcomingBookings() async {
    return await _bookingDao.getUpcomingBookings();
  }

  // Get bookings by status
  Future<List<Booking>> getBookingsByStatus(BookingStatus status) async {
    return await _bookingDao.getByStatus(status);
  }

  // Search bookings
  Future<List<Booking>> searchBookings(String query) async {
    return await _bookingDao.searchBookings(query: query);
  }

  // Search bookings with filters
  Future<List<Booking>> searchBookingsWithFilters({
    String? query,
    BookingStatus? status,
    BookingType? type,
    DateTime? fromDate,
    DateTime? toDate,
    String? customerId,
    String? roomId,
  }) async {
    return await _bookingDao.searchBookings(
      query: query,
      status: status,
      type: type,
      fromDate: fromDate,
      toDate: toDate,
      customerId: customerId,
      roomId: roomId,
    );
  }

  // Get booking statistics
  Future<Map<String, dynamic>> getBookingStatistics() async {
    final allBookings = await _bookingDao.getAll();
    
    int totalBookings = allBookings.length;
    int pendingBookings = allBookings.where((b) => b.status == BookingStatus.pending).length;
    int confirmedBookings = allBookings.where((b) => b.status == BookingStatus.confirmed).length;
    int checkedInBookings = allBookings.where((b) => b.status == BookingStatus.checkedIn).length;
    int checkedOutBookings = allBookings.where((b) => b.status == BookingStatus.checkedOut).length;
    int cancelledBookings = allBookings.where((b) => b.status == BookingStatus.cancelled).length;
    
    double totalRevenue = 0.0;
    for (final booking in allBookings) {
      totalRevenue += booking.totalAmount;
    }
    
    return {
      'totalBookings': totalBookings,
      'pendingBookings': pendingBookings,
      'confirmedBookings': confirmedBookings,
      'checkedInBookings': checkedInBookings,
      'checkedOutBookings': checkedOutBookings,
      'cancelledBookings': cancelledBookings,
      'totalRevenue': totalRevenue,
    };
  }

  // Get booking by ID
  Future<Booking?> getBookingById(String id) async {
    return await _bookingDao.getById(id);
  }

  // Get booking by number
  Future<Booking?> getBookingByNumber(String bookingNumber) async {
    return await _bookingDao.getByBookingNumber(bookingNumber);
  }

  // Update booking
  Future<Booking> updateBooking({
    required String id,
    DateTime? checkInDate,
    DateTime? checkOutDate,
    BookingTimeOfDay? checkInTime,
    BookingTimeOfDay? checkOutTime,
    BookingType? type,
    double? basePricePerNight,
    List<String>? additionalServices,
    Map<String, double>? servicePrices,
    String? specialInstructions,
    String? careNotes,
    String? veterinaryNotes,
    double? depositAmount,
    double? discountAmount,
    double? taxAmount,
    String? assignedStaffId,
    String? assignedStaffName,
  }) async {
    final existingBooking = await _bookingDao.getById(id);
    if (existingBooking == null) {
      throw ArgumentError('Booking not found');
    }

    // Validate dates if provided
    if (checkInDate != null && checkOutDate != null) {
      if (checkInDate.isAfter(checkOutDate)) {
        throw ArgumentError('Check-in date cannot be after check-out date');
      }
    }

    // Calculate total amount if pricing changed
    double? totalAmount;
    if (checkInDate != null || checkOutDate != null || basePricePerNight != null) {
      final startDate = checkInDate ?? existingBooking.checkInDate;
      final endDate = checkOutDate ?? existingBooking.checkOutDate;
      final pricePerNight = basePricePerNight ?? existingBooking.basePricePerNight;
      
      final numberOfNights = endDate.difference(startDate).inDays;
      final baseAmount = pricePerNight * numberOfNights;
      
      double servicesAmount = 0.0;
      final services = servicePrices ?? existingBooking.servicePrices;
      if (services != null) {
        for (final price in services.values) {
          servicesAmount += price;
        }
      }
      
      final subtotal = baseAmount + servicesAmount;
      final tax = taxAmount ?? existingBooking.taxAmount ?? 0.0;
      final discount = discountAmount ?? existingBooking.discountAmount ?? 0.0;
      totalAmount = subtotal + tax - discount;
    }

    final updatedBooking = existingBooking.copyWith(
      checkInDate: checkInDate ?? existingBooking.checkInDate,
      checkOutDate: checkOutDate ?? existingBooking.checkOutDate,
      checkInTime: checkInTime ?? existingBooking.checkInTime,
      checkOutTime: checkOutTime ?? existingBooking.checkOutTime,
      type: type ?? existingBooking.type,
      basePricePerNight: basePricePerNight ?? existingBooking.basePricePerNight,
      totalAmount: totalAmount ?? existingBooking.totalAmount,
      additionalServices: additionalServices ?? existingBooking.additionalServices,
      servicePrices: servicePrices ?? existingBooking.servicePrices,
      specialInstructions: specialInstructions ?? existingBooking.specialInstructions,
      careNotes: careNotes ?? existingBooking.careNotes,
      veterinaryNotes: veterinaryNotes ?? existingBooking.veterinaryNotes,
      depositAmount: depositAmount ?? existingBooking.depositAmount,
      discountAmount: discountAmount ?? existingBooking.discountAmount,
      taxAmount: taxAmount ?? existingBooking.taxAmount,
      assignedStaffId: assignedStaffId ?? existingBooking.assignedStaffId,
      assignedStaffName: assignedStaffName ?? existingBooking.assignedStaffName,
      updatedAt: DateTime.now(),
    );

    await _bookingDao.update(updatedBooking);
    return updatedBooking;
  }

  // Update booking status
  Future<Booking> updateBookingStatus(String id, BookingStatus newStatus) async {
    final existingBooking = await _bookingDao.getById(id);
    if (existingBooking == null) {
      throw ArgumentError('Booking not found');
    }

    if (!_isValidStatusTransition(existingBooking.status, newStatus)) {
      throw ArgumentError('Invalid status transition from ${existingBooking.status} to $newStatus');
    }

    final updatedBooking = existingBooking.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    await _bookingDao.update(updatedBooking);

    // Update room status based on booking status
    if (newStatus == BookingStatus.checkedIn) {
      await _roomDao.updateRoomStatus(existingBooking.roomId, RoomStatus.occupied);
    } else if (newStatus == BookingStatus.checkedOut) {
      await _roomDao.updateRoomStatus(existingBooking.roomId, RoomStatus.available);
    } else if (newStatus == BookingStatus.cancelled) {
      await _roomDao.updateRoomStatus(existingBooking.roomId, RoomStatus.available);
    }

    return updatedBooking;
  }

  // Check in
  Future<Booking> checkIn(String id, DateTime actualCheckInTime) async {
    final existingBooking = await _bookingDao.getById(id);
    if (existingBooking == null) {
      throw ArgumentError('Booking not found');
    }

    if (existingBooking.status != BookingStatus.confirmed) {
      throw ArgumentError('Only confirmed bookings can be checked in');
    }

    final updatedBooking = existingBooking.copyWith(
      status: BookingStatus.checkedIn,
      actualCheckInTime: actualCheckInTime,
      updatedAt: DateTime.now(),
    );

    await _bookingDao.update(updatedBooking);
    await _roomDao.updateRoomStatus(existingBooking.roomId, RoomStatus.occupied);

    return updatedBooking;
  }

  // Check out
  Future<Booking> checkOut(String id, DateTime actualCheckOutTime) async {
    final existingBooking = await _bookingDao.getById(id);
    if (existingBooking == null) {
      throw ArgumentError('Booking not found');
    }

    if (existingBooking.status != BookingStatus.checkedIn) {
      throw ArgumentError('Only checked-in bookings can be checked out');
    }

    final updatedBooking = existingBooking.copyWith(
      status: BookingStatus.checkedOut,
      actualCheckOutTime: actualCheckOutTime,
      updatedAt: DateTime.now(),
    );

    await _bookingDao.update(updatedBooking);
    await _roomDao.updateRoomStatus(existingBooking.roomId, RoomStatus.available);

    return updatedBooking;
  }

  // Cancel booking
  Future<Booking> cancelBooking(String id, String reason, double? refundAmount) async {
    final existingBooking = await _bookingDao.getById(id);
    if (existingBooking == null) {
      throw ArgumentError('Booking not found');
    }

    if (existingBooking.status == BookingStatus.checkedOut) {
      throw ArgumentError('Cannot cancel a completed booking');
    }

    final updatedBooking = existingBooking.copyWith(
      status: BookingStatus.cancelled,
      cancellationReason: reason,
      refundAmount: refundAmount,
      cancelledAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _bookingDao.update(updatedBooking);
    await _roomDao.updateRoomStatus(existingBooking.roomId, RoomStatus.available);

    return updatedBooking;
  }

  // Delete booking
  Future<void> deleteBooking(String id) async {
    final existingBooking = await _bookingDao.getById(id);
    if (existingBooking == null) {
      throw ArgumentError('Booking not found');
    }

    if (existingBooking.status == BookingStatus.checkedIn) {
      throw ArgumentError('Cannot delete a checked-in booking');
    }

    await _bookingDao.softDelete(id);
  }

  // Check if status transition is valid
  bool _isValidStatusTransition(BookingStatus from, BookingStatus to) {
    switch (from) {
      case BookingStatus.pending:
        return to == BookingStatus.confirmed || to == BookingStatus.cancelled;
      case BookingStatus.confirmed:
        return to == BookingStatus.checkedIn || to == BookingStatus.cancelled;
      case BookingStatus.checkedIn:
        return to == BookingStatus.checkedOut;
      case BookingStatus.checkedOut:
        return false; // Final state
      case BookingStatus.cancelled:
        return false; // Final state
      case BookingStatus.noShow:
        return false; // Final state
      case BookingStatus.completed:
        return false; // Final state
    }
  }
}
