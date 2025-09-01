import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:cat_hotel_pos/core/services/booking_dao.dart';
import 'package:cat_hotel_pos/core/services/room_dao.dart';

class StatusManagementService {
  final BookingDao _bookingDao;
  final RoomDao _roomDao;

  StatusManagementService({
    required BookingDao bookingDao,
    required RoomDao roomDao,
  }) : _bookingDao = bookingDao,
       _roomDao = roomDao;

  /// Update booking status with validation
  Future<Booking> updateBookingStatus({
    required String bookingId,
    required BookingStatus newStatus,
    String? reason,
    String? updatedBy,
  }) async {
    final booking = await _bookingDao.getById(bookingId);
    if (booking == null) {
      throw ArgumentError('Booking not found');
    }

    // Validate status transition
    if (!_isValidBookingStatusTransition(booking.status, newStatus)) {
      throw ArgumentError(
        'Invalid status transition from ${booking.status.name} to ${newStatus.name}'
      );
    }

    // Update room status if needed
    await _updateRoomStatusForBooking(booking, newStatus);

    // Update booking status
    final updatedBooking = booking.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    await _bookingDao.update(updatedBooking);
    return updatedBooking;
  }

  /// Update room status with validation
  Future<Room> updateRoomStatus({
    required String roomId,
    required RoomStatus newStatus,
    String? reason,
    String? updatedBy,
  }) async {
    final room = await _roomDao.getById(roomId);
    if (room == null) {
      throw ArgumentError('Room not found');
    }

    // Validate status transition
    if (!_isValidRoomStatusTransition(room.status, newStatus)) {
      throw ArgumentError(
        'Invalid status transition from ${room.status.name} to ${newStatus.name}'
      );
    }

    // Check for active bookings if setting room to unavailable
    if (newStatus == RoomStatus.outOfService || newStatus == RoomStatus.maintenance) {
      final hasActiveBookings = await _hasActiveBookings(roomId);
      if (hasActiveBookings) {
        throw ArgumentError(
          'Cannot set room to ${newStatus.name} while it has active bookings'
        );
      }
    }

    // Update room status
    final updatedRoom = room.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    await _roomDao.update(updatedRoom);
    return updatedRoom;
  }

  /// Check-in a booking
  Future<Booking> checkInBooking({
    required String bookingId,
    String? notes,
    String? checkedInBy,
  }) async {
    final booking = await _bookingDao.getById(bookingId);
    if (booking == null) {
      throw ArgumentError('Booking not found');
    }

    if (booking.status != BookingStatus.confirmed) {
      throw ArgumentError('Only confirmed bookings can be checked in');
    }

    // Update booking status to checked in
    final updatedBooking = booking.copyWith(
      status: BookingStatus.checkedIn,
      updatedAt: DateTime.now(),
    );

    await _bookingDao.update(updatedBooking);

    // Update room status to occupied
    await updateRoomStatus(
      roomId: booking.roomId,
      newStatus: RoomStatus.occupied,
      reason: 'Booking checked in: ${booking.bookingNumber}',
      updatedBy: checkedInBy,
    );

    return updatedBooking;
  }

  /// Check-out a booking
  Future<Booking> checkOutBooking({
    required String bookingId,
    String? notes,
    String? checkedOutBy,
  }) async {
    final booking = await _bookingDao.getById(bookingId);
    if (booking == null) {
      throw ArgumentError('Booking not found');
    }

    if (booking.status != BookingStatus.checkedIn) {
      throw ArgumentError('Only checked-in bookings can be checked out');
    }

    // Update booking status to checked out
    final updatedBooking = booking.copyWith(
      status: BookingStatus.checkedOut,
      updatedAt: DateTime.now(),
    );

    await _bookingDao.update(updatedBooking);

    // Update room status to cleaning
    await updateRoomStatus(
      roomId: booking.roomId,
      newStatus: RoomStatus.cleaning,
      reason: 'Booking checked out: ${booking.bookingNumber}',
      updatedBy: checkedOutBy,
    );

    return updatedBooking;
  }

  /// Cancel a booking
  Future<Booking> cancelBooking({
    required String bookingId,
    required String reason,
    String? cancelledBy,
  }) async {
    final booking = await _bookingDao.getById(bookingId);
    if (booking == null) {
      throw ArgumentError('Booking not found');
    }

    if (booking.status == BookingStatus.checkedIn || 
        booking.status == BookingStatus.checkedOut ||
        booking.status == BookingStatus.completed) {
      throw ArgumentError('Cannot cancel a booking that has been checked in or completed');
    }

    // Update booking status to cancelled
    final updatedBooking = booking.copyWith(
      status: BookingStatus.cancelled,
      updatedAt: DateTime.now(),
    );

    await _bookingDao.update(updatedBooking);

    // Update room status if it was reserved
    if (booking.status == BookingStatus.confirmed) {
      await updateRoomStatus(
        roomId: booking.roomId,
        newStatus: RoomStatus.available,
        reason: 'Booking cancelled: ${booking.bookingNumber}',
        updatedBy: cancelledBy,
      );
    }

    return updatedBooking;
  }

  /// Complete room cleaning
  Future<Room> completeRoomCleaning({
    required String roomId,
    String? cleanedBy,
  }) async {
    final room = await _roomDao.getById(roomId);
    if (room == null) {
      throw ArgumentError('Room not found');
    }

    if (room.status != RoomStatus.cleaning) {
      throw ArgumentError('Room is not in cleaning status');
    }

    // Update room status to available
    final updatedRoom = room.copyWith(
      status: RoomStatus.available,
      updatedAt: DateTime.now(),
    );

    await _roomDao.update(updatedRoom);
    return updatedRoom;
  }

  /// Validate booking status transition
  bool _isValidBookingStatusTransition(BookingStatus currentStatus, BookingStatus newStatus) {
    switch (currentStatus) {
      case BookingStatus.pending:
        return newStatus == BookingStatus.confirmed || 
               newStatus == BookingStatus.cancelled;
      
      case BookingStatus.confirmed:
        return newStatus == BookingStatus.checkedIn || 
               newStatus == BookingStatus.cancelled ||
               newStatus == BookingStatus.noShow;
      
      case BookingStatus.checkedIn:
        return newStatus == BookingStatus.checkedOut;
      
      case BookingStatus.checkedOut:
        return newStatus == BookingStatus.completed;
      
      case BookingStatus.cancelled:
      case BookingStatus.completed:
      case BookingStatus.noShow:
        return false; // Terminal states
    }
  }

  /// Validate room status transition
  bool _isValidRoomStatusTransition(RoomStatus currentStatus, RoomStatus newStatus) {
    switch (currentStatus) {
      case RoomStatus.available:
        return newStatus == RoomStatus.reserved || 
               newStatus == RoomStatus.occupied ||
               newStatus == RoomStatus.maintenance ||
               newStatus == RoomStatus.outOfService;
      
      case RoomStatus.reserved:
        return newStatus == RoomStatus.occupied ||
               newStatus == RoomStatus.available ||
               newStatus == RoomStatus.maintenance ||
               newStatus == RoomStatus.outOfService;
      
      case RoomStatus.occupied:
        return newStatus == RoomStatus.cleaning;
      
      case RoomStatus.cleaning:
        return newStatus == RoomStatus.available ||
               newStatus == RoomStatus.maintenance ||
               newStatus == RoomStatus.outOfService;
      
      case RoomStatus.maintenance:
        return newStatus == RoomStatus.available ||
               newStatus == RoomStatus.outOfService;
      
      case RoomStatus.outOfService:
        return newStatus == RoomStatus.available ||
               newStatus == RoomStatus.maintenance;
    }
  }

  /// Check if room has active bookings
  Future<bool> _hasActiveBookings(String roomId) async {
    final allBookings = await _bookingDao.getAll();
    return allBookings.any((booking) => 
      booking.roomId == roomId && 
      (booking.status == BookingStatus.confirmed || 
       booking.status == BookingStatus.checkedIn)
    );
  }

  /// Update room status based on booking status
  Future<void> _updateRoomStatusForBooking(Booking booking, BookingStatus newStatus) async {
    switch (newStatus) {
      case BookingStatus.confirmed:
        await updateRoomStatus(
          roomId: booking.roomId,
          newStatus: RoomStatus.reserved,
          reason: 'Booking confirmed: ${booking.bookingNumber}',
        );
        break;
      
      case BookingStatus.checkedIn:
        await updateRoomStatus(
          roomId: booking.roomId,
          newStatus: RoomStatus.occupied,
          reason: 'Booking checked in: ${booking.bookingNumber}',
        );
        break;
      
      case BookingStatus.checkedOut:
        await updateRoomStatus(
          roomId: booking.roomId,
          newStatus: RoomStatus.cleaning,
          reason: 'Booking checked out: ${booking.bookingNumber}',
        );
        break;
      
      case BookingStatus.cancelled:
        if (booking.status == BookingStatus.confirmed) {
          await updateRoomStatus(
            roomId: booking.roomId,
            newStatus: RoomStatus.available,
            reason: 'Booking cancelled: ${booking.bookingNumber}',
          );
        }
        break;
      
      default:
        // No room status change needed
        break;
    }
  }

  /// Get status transition history for a booking
  Future<List<StatusTransition>> getBookingStatusHistory(String bookingId) async {
    // This would typically be implemented with a separate status history table
    // For now, we'll return a simple list
    return [];
  }

  /// Get status transition history for a room
  Future<List<StatusTransition>> getRoomStatusHistory(String roomId) async {
    // This would typically be implemented with a separate status history table
    // For now, we'll return a simple list
    return [];
  }
}

/// Represents a status transition
class StatusTransition {
  final String entityId;
  final String fromStatus;
  final String toStatus;
  final DateTime timestamp;
  final String? reason;
  final String? updatedBy;

  StatusTransition({
    required this.entityId,
    required this.fromStatus,
    required this.toStatus,
    required this.timestamp,
    this.reason,
    this.updatedBy,
  });
}
