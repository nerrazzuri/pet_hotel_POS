import 'package:uuid/uuid.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/waitlist.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/core/services/waitlist_dao.dart';
import 'package:cat_hotel_pos/core/services/room_dao.dart';
import 'package:cat_hotel_pos/core/services/booking_dao.dart';

class WaitlistService {
  final WaitlistDao _waitlistDao;
  final RoomDao _roomDao;
  final BookingDao _bookingDao;

  WaitlistService({
    required WaitlistDao waitlistDao,
    required RoomDao roomDao,
    required BookingDao bookingDao,
  })  : _waitlistDao = waitlistDao,
        _roomDao = roomDao,
        _bookingDao = bookingDao;

  // Add customer to waitlist
  Future<WaitlistEntry> addToWaitlist({
    required String customerId,
    required String customerName,
    required String petId,
    required String petName,
    required String phoneNumber,
    required String email,
    required DateTime requestedCheckInDate,
    required DateTime requestedCheckOutDate,
    required RoomType preferredRoomType,
    required int numberOfPets,
    WaitlistPriority priority = WaitlistPriority.medium,
    String? notes,
    String? specialRequirements,
  }) async {
    // Validate dates
    if (requestedCheckInDate.isAfter(requestedCheckOutDate)) {
      throw ArgumentError('Check-in date cannot be after check-out date');
    }

    if (requestedCheckInDate.isBefore(DateTime.now())) {
      throw ArgumentError('Check-in date cannot be in the past');
    }

    final entry = WaitlistEntry(
      id: const Uuid().v4(),
      customerId: customerId,
      customerName: customerName,
      petId: petId,
      petName: petName,
      phoneNumber: phoneNumber,
      email: email,
      requestedCheckInDate: requestedCheckInDate,
      requestedCheckOutDate: requestedCheckOutDate,
      preferredRoomType: preferredRoomType,
      numberOfPets: numberOfPets,
      status: WaitlistStatus.pending,
      priority: priority,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      notes: notes,
      specialRequirements: specialRequirements,
    );

    await _waitlistDao.insert(entry);
    return entry;
  }

  // Update waitlist entry status
  Future<WaitlistEntry> updateStatus(String id, WaitlistStatus newStatus) async {
    final entry = await _waitlistDao.getById(id);
    if (entry == null) {
      throw ArgumentError('Waitlist entry not found');
    }

    final updatedEntry = entry.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
      notificationSentAt: newStatus == WaitlistStatus.notified ? DateTime.now() : entry.notificationSentAt,
      confirmedAt: newStatus == WaitlistStatus.confirmed ? DateTime.now() : entry.confirmedAt,
    );

    await _waitlistDao.update(updatedEntry);
    return updatedEntry;
  }

  // Cancel waitlist entry
  Future<WaitlistEntry> cancelEntry(String id, String cancelledBy, String? reason) async {
    final entry = await _waitlistDao.getById(id);
    if (entry == null) {
      throw ArgumentError('Waitlist entry not found');
    }

    final updatedEntry = entry.copyWith(
      status: WaitlistStatus.cancelled,
      updatedAt: DateTime.now(),
      cancelledAt: DateTime.now(),
      cancelledBy: cancelledBy,
      cancellationReason: reason,
    );

    await _waitlistDao.update(updatedEntry);
    return updatedEntry;
  }

  // Get available rooms for waitlist entry
  Future<List<Room>> getAvailableRoomsForEntry(String entryId) async {
    final entry = await _waitlistDao.getById(entryId);
    if (entry == null) {
      throw ArgumentError('Waitlist entry not found');
    }

    final allRooms = await _roomDao.getAll();
    final availableRooms = <Room>[];

    for (final room in allRooms) {
      if (room.type == entry.preferredRoomType && room.isActive) {
        final isAvailable = await _isRoomAvailableForDateRange(
          room.id,
          entry.requestedCheckInDate,
          entry.requestedCheckOutDate,
        );
        if (isAvailable) {
          availableRooms.add(room);
        }
      }
    }

    return availableRooms;
  }

  // Convert waitlist entry to booking
  Future<Booking> convertToBooking(String entryId, String roomId) async {
    final entry = await _waitlistDao.getById(entryId);
    if (entry == null) {
      throw ArgumentError('Waitlist entry not found');
    }

    final room = await _roomDao.getById(roomId);
    if (room == null) {
      throw ArgumentError('Room not found');
    }

    // Check if room is still available
    final isAvailable = await _isRoomAvailableForDateRange(
      roomId,
      entry.requestedCheckInDate,
      entry.requestedCheckOutDate,
    );

    if (!isAvailable) {
      throw ArgumentError('Room is no longer available for the requested dates');
    }

    // Create booking (this would typically call the booking service)
    // For now, we'll just update the waitlist status
    final updatedEntry = await updateStatus(entryId, WaitlistStatus.confirmed);
    
    // TODO: Create actual booking using BookingService
    throw UnimplementedError('Booking creation from waitlist not yet implemented');
  }

  // Get waitlist entries by priority
  Future<List<WaitlistEntry>> getByPriority(WaitlistPriority priority) async {
    return await _waitlistDao.getByPriority(priority);
  }

  // Get waitlist entries by status
  Future<List<WaitlistEntry>> getByStatus(WaitlistStatus status) async {
    return await _waitlistDao.getByStatus(status);
  }

  // Get expired entries
  Future<List<WaitlistEntry>> getExpiredEntries() async {
    return await _waitlistDao.getExpiredEntries();
  }

  // Auto-expire old entries
  Future<void> expireOldEntries() async {
    final expiredEntries = await getExpiredEntries();
    for (final entry in expiredEntries) {
      await updateStatus(entry.id, WaitlistStatus.expired);
    }
  }

  // Get waitlist statistics
  Future<Map<String, dynamic>> getWaitlistStatistics() async {
    final allEntries = await _waitlistDao.getAll();
    final now = DateTime.now();

    final pendingCount = allEntries.where((e) => e.status == WaitlistStatus.pending).length;
    final notifiedCount = allEntries.where((e) => e.status == WaitlistStatus.notified).length;
    final confirmedCount = allEntries.where((e) => e.status == WaitlistStatus.confirmed).length;
    final cancelledCount = allEntries.where((e) => e.status == WaitlistStatus.cancelled).length;
    final expiredCount = allEntries.where((e) => e.status == WaitlistStatus.expired).length;

    final urgentCount = allEntries.where((e) => e.priority == WaitlistPriority.urgent).length;
    final highCount = allEntries.where((e) => e.priority == WaitlistPriority.high).length;

    final todayEntries = allEntries.where((e) => 
      e.createdAt.year == now.year &&
      e.createdAt.month == now.month &&
      e.createdAt.day == now.day
    ).length;

    return {
      'total': allEntries.length,
      'pending': pendingCount,
      'notified': notifiedCount,
      'confirmed': confirmedCount,
      'cancelled': cancelledCount,
      'expired': expiredCount,
      'urgent': urgentCount,
      'high': highCount,
      'today': todayEntries,
    };
  }

  // Helper method to check room availability
  Future<bool> _isRoomAvailableForDateRange(String roomId, DateTime checkIn, DateTime checkOut) async {
    final bookings = await _bookingDao.getAll();
    final conflictingBookings = bookings.where((booking) {
      if (booking.roomId != roomId) return false;
      if (booking.status == BookingStatus.cancelled || booking.status == BookingStatus.noShow) return false;
      
      return (booking.checkInDate.isBefore(checkOut) && booking.checkOutDate.isAfter(checkIn));
    }).toList();

    return conflictingBookings.isEmpty;
  }
}
