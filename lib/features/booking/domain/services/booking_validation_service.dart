import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:cat_hotel_pos/core/services/booking_dao.dart';
import 'package:cat_hotel_pos/core/services/room_dao.dart';

class BookingValidationService {
  final BookingDao _bookingDao;
  final RoomDao _roomDao;

  BookingValidationService({
    required BookingDao bookingDao,
    required RoomDao roomDao,
  }) : _bookingDao = bookingDao,
       _roomDao = roomDao;

  /// Check if there are any booking conflicts for a room in the given date range
  Future<List<BookingConflict>> checkBookingConflicts({
    required String roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    String? excludeBookingId, // For updates, exclude the current booking
  }) async {
    final conflicts = <BookingConflict>[];
    
    // Get all bookings for the room
    final allBookings = await _bookingDao.getAll();
    final roomBookings = allBookings.where((booking) => 
      booking.roomId == roomId && 
      booking.status != BookingStatus.cancelled &&
      booking.status != BookingStatus.completed
    ).toList();

    // Check for overlapping bookings
    for (final existingBooking in roomBookings) {
      // Skip the booking being updated
      if (excludeBookingId != null && existingBooking.id == excludeBookingId) {
        continue;
      }

      // Check for date overlap
      if (_hasDateOverlap(
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        existingCheckIn: existingBooking.checkInDate,
        existingCheckOut: existingBooking.checkOutDate,
      )) {
        conflicts.add(BookingConflict(
          type: ConflictType.dateOverlap,
          conflictingBooking: existingBooking,
          message: 'Date range overlaps with existing booking ${existingBooking.bookingNumber}',
        ));
      }
    }

    return conflicts;
  }

  /// Check if a room is available for the given date range
  Future<bool> isRoomAvailable({
    required String roomId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    String? excludeBookingId,
  }) async {
    final conflicts = await checkBookingConflicts(
      roomId: roomId,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      excludeBookingId: excludeBookingId,
    );
    
    return conflicts.isEmpty;
  }

  /// Get all available rooms for a given date range
  Future<List<Room>> getAvailableRooms({
    required DateTime checkInDate,
    required DateTime checkOutDate,
    int? requiredCapacity,
    RoomType? preferredType,
  }) async {
    final allRooms = await _roomDao.getAll();
    final availableRooms = <Room>[];

    for (final room in allRooms) {
      // Check if room is in service
      if (room.status == RoomStatus.outOfService || 
          room.status == RoomStatus.maintenance) {
        continue;
      }

      // Check capacity requirement
      if (requiredCapacity != null && room.capacity < requiredCapacity) {
        continue;
      }

      // Check type preference
      if (preferredType != null && room.type != preferredType) {
        continue;
      }

      // Check availability
      final isAvailable = await isRoomAvailable(
        roomId: room.id,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
      );

      if (isAvailable) {
        availableRooms.add(room);
      }
    }

    return availableRooms;
  }

  /// Validate booking dates
  List<String> validateBookingDates({
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required BookingTimeOfDay checkInTime,
    required BookingTimeOfDay checkOutTime,
  }) {
    final errors = <String>[];

    // Check if check-in date is in the past
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final checkInDay = DateTime(checkInDate.year, checkInDate.month, checkInDate.day);
    
    if (checkInDay.isBefore(today)) {
      errors.add('Check-in date cannot be in the past');
    }

    // Check if check-out date is before check-in date
    if (checkOutDate.isBefore(checkInDate)) {
      errors.add('Check-out date cannot be before check-in date');
    }

    // Check if check-out date is the same as check-in date
    if (checkOutDate.isAtSameMomentAs(checkInDate)) {
      errors.add('Check-out date must be after check-in date');
    }

    // Check if booking duration is reasonable (e.g., not more than 30 days)
    final duration = checkOutDate.difference(checkInDate).inDays;
    if (duration > 30) {
      errors.add('Booking duration cannot exceed 30 days');
    }

    // Check if check-in time is before check-out time for same-day bookings
    if (checkInDate.isAtSameMomentAs(checkOutDate)) {
      final checkInMinutes = checkInTime.hour * 60 + checkInTime.minute;
      final checkOutMinutes = checkOutTime.hour * 60 + checkOutTime.minute;
      
      if (checkInMinutes >= checkOutMinutes) {
        errors.add('Check-in time must be before check-out time for same-day bookings');
      }
    }

    return errors;
  }

  /// Calculate dynamic pricing based on room type, season, and duration
  double calculateDynamicPricing({
    required Room room,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required bool isPeakSeason,
  }) {
    final basePrice = room.basePricePerNight;
    final peakPrice = room.peakSeasonPrice;
    final duration = checkOutDate.difference(checkInDate).inDays;

    // Use peak season price if applicable
    double pricePerNight = isPeakSeason ? peakPrice : basePrice;

    // Apply duration discounts
    double discount = 0.0;
    if (duration >= 7) {
      discount = 0.10; // 10% discount for 7+ days
    } else if (duration >= 3) {
      discount = 0.05; // 5% discount for 3+ days
    }

    // Apply room type multipliers
    double typeMultiplier = 1.0;
    switch (room.type) {
      case RoomType.standard:
        typeMultiplier = 1.0;
        break;
      case RoomType.deluxe:
        typeMultiplier = 1.25;
        break;
      case RoomType.vip:
        typeMultiplier = 1.5;
        break;
      case RoomType.isolation:
        typeMultiplier = 1.3;
        break;
      case RoomType.medical:
        typeMultiplier = 1.4;
        break;
      case RoomType.family:
        typeMultiplier = 1.2;
        break;
      case RoomType.outdoor:
        typeMultiplier = 0.9;
        break;
      case RoomType.playroom:
        typeMultiplier = 0.8;
        break;
    }

    final totalPrice = pricePerNight * duration * typeMultiplier * (1 - discount);
    return totalPrice;
  }

  /// Check if dates overlap
  bool _hasDateOverlap({
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required DateTime existingCheckIn,
    required DateTime existingCheckOut,
  }) {
    // Convert to date-only comparison (ignore time)
    final newCheckIn = DateTime(checkInDate.year, checkInDate.month, checkInDate.day);
    final newCheckOut = DateTime(checkOutDate.year, checkOutDate.month, checkOutDate.day);
    final existingCheckInDate = DateTime(existingCheckIn.year, existingCheckIn.month, existingCheckIn.day);
    final existingCheckOutDate = DateTime(existingCheckOut.year, existingCheckOut.month, existingCheckOut.day);

    // Check for overlap
    return (newCheckIn.isBefore(existingCheckOutDate) && newCheckOut.isAfter(existingCheckInDate));
  }

  /// Determine if a date range is in peak season
  bool isPeakSeason(DateTime checkInDate, DateTime checkOutDate) {
    // Simple peak season logic - can be enhanced with more sophisticated rules
    final month = checkInDate.month;
    
    // Peak season: December, January, February (holiday season)
    // Also consider school holidays and local events
    return month == 12 || month == 1 || month == 2;
  }
}

/// Represents a booking conflict
class BookingConflict {
  final ConflictType type;
  final Booking conflictingBooking;
  final String message;

  BookingConflict({
    required this.type,
    required this.conflictingBooking,
    required this.message,
  });
}

/// Types of booking conflicts
enum ConflictType {
  dateOverlap,
  roomUnavailable,
  capacityExceeded,
  maintenance,
}
