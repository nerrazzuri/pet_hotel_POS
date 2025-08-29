import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:cat_hotel_pos/core/services/room_dao.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/audit_service.dart';
import 'package:cat_hotel_pos/features/auth/domain/entities/audit_log.dart';

class RoomService {
  final RoomDao _roomDao = RoomDao.instance;
  final AuditService? _auditService;

  RoomService(this._auditService);

  // Helper method to safely log audit events
  Future<void> _logAuditEvent({
    required String userId,
    required String userEmail,
    required String userRole,
    required String resource,
    required String details,
    required AuditSeverity severity,
  }) async {
    if (_auditService != null) {
      await _auditService!.logDataModification(
        userId: userId,
        userEmail: userEmail,
        userRole: userRole,
        resource: resource,
        details: details,
        severity: severity,
      );
    }
  }

  // Create a new room
  Future<Room> createRoom({
    required String roomNumber,
    required String name,
    required RoomType type,
    required RoomStatus status,
    required int capacity,
    required double basePricePerNight,
    required double peakSeasonPrice,
    required String description,
    required List<String> amenities,
    required Map<String, dynamic> specifications,
    String? notes,
    String? maintenanceNotes,
    List<String>? images,
    Map<String, dynamic>? metadata,
  }) async {
    // Check if room number already exists
    final existingRooms = await _roomDao.getAll();
    if (existingRooms.any((room) => room.roomNumber == roomNumber)) {
      throw Exception('Room number $roomNumber already exists');
    }

    final room = Room(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      roomNumber: roomNumber,
      name: name,
      type: type,
      status: status,
      capacity: capacity,
      basePricePerNight: basePricePerNight,
      peakSeasonPrice: peakSeasonPrice,
      description: description,
      amenities: amenities,
      specifications: specifications,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      notes: notes,
      maintenanceNotes: maintenanceNotes,
      images: images,
      metadata: metadata,
    );

    await _roomDao.insert(room);

    await _logAuditEvent(
      userId: 'system',
      userEmail: 'system@cathotel.com',
      userRole: 'system',
      resource: 'room',
      details: 'Room created: $roomNumber - $name',
      severity: AuditSeverity.medium,
    );

    return room;
  }

  // Update an existing room
  Future<Room> updateRoom({
    required String roomId,
    String? roomNumber,
    String? name,
    RoomType? type,
    RoomStatus? status,
    int? capacity,
    double? basePricePerNight,
    double? peakSeasonPrice,
    String? description,
    List<String>? amenities,
    Map<String, dynamic>? specifications,
    String? notes,
    String? maintenanceNotes,
    List<String>? images,
    Map<String, dynamic>? metadata,
  }) async {
    final existingRoom = await _roomDao.getById(roomId);
    if (existingRoom == null) {
      throw Exception('Room not found');
    }

    // Check if new room number conflicts with existing rooms
    if (roomNumber != null && roomNumber != existingRoom.roomNumber) {
      final allRooms = await _roomDao.getAll();
      if (allRooms.any((room) => room.roomNumber == roomNumber && room.id != roomId)) {
        throw Exception('Room number $roomNumber already exists');
      }
    }

    final updatedRoom = existingRoom.copyWith(
      roomNumber: roomNumber ?? existingRoom.roomNumber,
      name: name ?? existingRoom.name,
      type: type ?? existingRoom.type,
      status: status ?? existingRoom.status,
      capacity: capacity ?? existingRoom.capacity,
      basePricePerNight: basePricePerNight ?? existingRoom.basePricePerNight,
      peakSeasonPrice: peakSeasonPrice ?? existingRoom.peakSeasonPrice,
      description: description ?? existingRoom.description,
      amenities: amenities ?? existingRoom.amenities,
      specifications: specifications ?? existingRoom.specifications,
      notes: notes ?? existingRoom.notes,
      maintenanceNotes: maintenanceNotes ?? existingRoom.maintenanceNotes,
      images: images ?? existingRoom.images,
      metadata: metadata ?? existingRoom.metadata,
      updatedAt: DateTime.now(),
    );

    await _roomDao.update(updatedRoom);

    await _logAuditEvent(
      userId: 'system',
      userEmail: 'system@cathotel.com',
      userRole: 'system',
      resource: 'room',
      details: 'Room updated: ${updatedRoom.roomNumber} - ${updatedRoom.name}',
      severity: AuditSeverity.medium,
    );

    return updatedRoom;
  }

  // Delete a room (soft delete)
  Future<void> deleteRoom(String roomId) async {
    final room = await _roomDao.getById(roomId);
    if (room == null) {
      throw Exception('Room not found');
    }

    if (room.status != RoomStatus.available) {
      throw Exception('Cannot delete room that is not available');
    }

    await _roomDao.softDelete(roomId);

    await _logAuditEvent(
      userId: 'system',
      userEmail: 'system@cathotel.com',
      userRole: 'system',
      resource: 'room',
      details: 'Room deleted: ${room.roomNumber} - ${room.name}',
      severity: AuditSeverity.medium,
    );
  }

  // Get room by ID
  Future<Room?> getRoomById(String roomId) async {
    return await _roomDao.getById(roomId);
  }

  // Get all rooms
  Future<List<Room>> getAllRooms() async {
    return await _roomDao.getAll();
  }

  // Get rooms by status
  Future<List<Room>> getRoomsByStatus(RoomStatus status) async {
    return await _roomDao.getByStatus(status);
  }

  // Get rooms by type
  Future<List<Room>> getRoomsByType(RoomType type) async {
    return await _roomDao.getByType(type);
  }

  // Get available rooms
  Future<List<Room>> getAvailableRooms() async {
    return await _roomDao.getAvailableRooms();
  }

  // Search rooms with filters
  Future<List<Room>> searchRooms({
    String? query,
    RoomType? type,
    RoomStatus? status,
    double? minPrice,
    double? maxPrice,
    int? minCapacity,
  }) async {
    return await _roomDao.searchRooms(
      query: query,
      type: type,
      status: status,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minCapacity: minCapacity,
    );
  }

  // Update room status (legacy method - use the one below)
  Future<void> updateRoomStatusLegacy(String roomId, RoomStatus status) async {
    final room = await _roomDao.getById(roomId);
    if (room == null) {
      throw Exception('Room not found');
    }

    final updatedRoom = room.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    await _roomDao.update(updatedRoom);

    await _logAuditEvent(
      userId: 'system',
      userEmail: 'system@cathotel.com',
      userRole: 'system',
      resource: 'room_status',
      details: 'Room ${room.roomNumber} status changed from ${room.status.name} to ${status.name}',
      severity: AuditSeverity.medium,
    );
  }

  // Assign occupant to room
  Future<void> assignOccupant(String roomId, String? occupantId, String? occupantName) async {
    final room = await _roomDao.getById(roomId);
    if (room == null) {
      throw Exception('Room not found');
    }

    await _roomDao.assignOccupant(roomId, occupantId, occupantName);

    if (occupantId != null) {
      await _logAuditEvent(
        userId: 'system',
        userEmail: 'system@cathotel.com',
        userRole: 'system',
        resource: 'room_occupant',
        details: 'Pet $occupantName assigned to room ${room.roomNumber}',
        severity: AuditSeverity.medium,
      );
    } else {
      await _logAuditEvent(
        userId: 'system',
        userEmail: 'system@cathotel.com',
        userRole: 'system',
        resource: 'room_occupant',
        details: 'Room ${room.roomNumber} occupant removed',
        severity: AuditSeverity.medium,
      );
    }
  }

  // Update cleaning schedule
  Future<void> updateCleaningSchedule(
    String roomId,
    DateTime? lastCleaned,
    DateTime? nextCleaning,
  ) async {
    final room = await _roomDao.getById(roomId);
    if (room == null) {
      throw Exception('Room not found');
    }

    await _roomDao.updateCleaningSchedule(roomId, lastCleaned, nextCleaning);

    await _logAuditEvent(
      userId: 'system',
      userEmail: 'system@cathotel.com',
      userRole: 'system',
      resource: 'room_cleaning',
      details: 'Cleaning schedule updated for room ${room.roomNumber}',
      severity: AuditSeverity.low,
    );
  }

  // Check room availability for a date range
  Future<bool> isRoomAvailable(String roomId, DateTime checkIn, DateTime checkOut) async {
    final room = await _roomDao.getById(roomId);
    if (room == null || !room.isActive) {
      return false;
    }

    if (room.status != RoomStatus.available) {
      return false;
    }

    // Additional availability logic can be added here
    // For example, checking if the room is already booked for the given dates
    return true;
  }

  // Get room statistics
  Future<Map<String, dynamic>> getRoomStatistics() async {
    final allRooms = await _roomDao.getAll();
    
    final totalRooms = allRooms.length;
    final availableRooms = allRooms.where((r) => r.status == RoomStatus.available).length;
    final occupiedRooms = allRooms.where((r) => r.status == RoomStatus.occupied).length;
    final maintenanceRooms = allRooms.where((r) => r.status == RoomStatus.maintenance).length;
    final cleaningRooms = allRooms.where((r) => r.status == RoomStatus.cleaning).length;

    final roomTypes = <String, int>{};
    for (final room in allRooms) {
      roomTypes[room.type.name] = (roomTypes[room.type.name] ?? 0) + 1;
    }

    return {
      'totalRooms': totalRooms,
      'availableRooms': availableRooms,
      'occupiedRooms': occupiedRooms,
      'maintenanceRooms': maintenanceRooms,
      'cleaningRooms': cleaningRooms,
      'roomTypes': roomTypes,
      'occupancyRate': totalRooms > 0 ? (occupiedRooms / totalRooms) * 100 : 0.0,
    };
  }

  // Update room status
  Future<Room> updateRoomStatus(String roomId, RoomStatus newStatus) async {
    final existingRoom = await _roomDao.getById(roomId);
    if (existingRoom == null) {
      throw Exception('Room not found');
    }

    final updatedRoom = existingRoom.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    await _roomDao.update(updatedRoom);

    await _logAuditEvent(
      userId: 'system',
      userEmail: 'system@cathotel.com',
      userRole: 'system',
      resource: 'room_status',
      details: 'Room status updated: ${existingRoom.roomNumber} - ${existingRoom.status.name} → ${newStatus.name}',
      severity: AuditSeverity.low,
    );

    return updatedRoom;
  }

  // Seed default rooms for testing
  Future<void> seedDefaultRooms() async {
    final existingRooms = await _roomDao.getAll();
    if (existingRooms.isNotEmpty) return;

    final defaultRooms = [
      Room(
        id: 'room_1',
        roomNumber: '101',
        name: 'Standard Single',
        type: RoomType.standard,
        status: RoomStatus.available,
        capacity: 1,
        basePricePerNight: 25.0,
        peakSeasonPrice: 35.0,
        description: 'Comfortable single pet room with basic amenities',
        amenities: ['Heating', 'AC', 'Play area', 'Security camera'],
        specifications: {
          'width': 2.5,
          'length': 3.0,
          'height': 2.2,
          'hasWindow': true,
          'hasHeating': true,
          'hasAC': true,
          'hasPlayArea': true,
          'isSoundproofed': false,
          'hasSecurityCamera': true,
          'maxPetWeight': 10,
          'allowedPetTypes': ['Cat', 'Small Dog'],
          'isWheelchairAccessible': true,
          'hasEmergencyExit': true,
        },
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Room(
        id: 'room_2',
        roomNumber: '102',
        name: 'Deluxe Suite',
        type: RoomType.deluxe,
        status: RoomStatus.available,
        capacity: 2,
        basePricePerNight: 40.0,
        peakSeasonPrice: 55.0,
        description: 'Spacious deluxe room for multiple pets or larger animals',
        amenities: ['Heating', 'AC', 'Large play area', 'Window view', 'Premium bedding'],
        specifications: {
          'width': 3.5,
          'length': 4.0,
          'height': 2.5,
          'hasWindow': true,
          'hasHeating': true,
          'hasAC': true,
          'hasPlayArea': true,
          'isSoundproofed': true,
          'hasSecurityCamera': true,
          'maxPetWeight': 25,
          'allowedPetTypes': ['Cat', 'Dog', 'Small Animal'],
          'isWheelchairAccessible': true,
          'hasEmergencyExit': true,
        },
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Room(
        id: 'room_3',
        roomNumber: '201',
        name: 'VIP Luxury',
        type: RoomType.vip,
        status: RoomStatus.available,
        capacity: 3,
        basePricePerNight: 75.0,
        peakSeasonPrice: 95.0,
        description: 'Premium luxury room with all amenities and extra space',
        amenities: ['Heating', 'AC', 'Large play area', 'Premium view', 'Luxury bedding', 'Music system'],
        specifications: {
          'width': 4.0,
          'length': 5.0,
          'height': 3.0,
          'hasWindow': true,
          'hasHeating': true,
          'hasAC': true,
          'hasPlayArea': true,
          'isSoundproofed': true,
          'hasSecurityCamera': true,
          'maxPetWeight': 50,
          'allowedPetTypes': ['Cat', 'Dog', 'Large Animal'],
          'isWheelchairAccessible': true,
          'hasEmergencyExit': true,
        },
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    for (final room in defaultRooms) {
      await _roomDao.insert(room);
    }

    await _logAuditEvent(
      userId: 'system',
      userEmail: 'system@cathotel.com',
      userRole: 'system',
      resource: 'room_seeding',
      details: 'Default rooms seeded: ${defaultRooms.length} rooms created',
      severity: AuditSeverity.low,
    );
  }
}
