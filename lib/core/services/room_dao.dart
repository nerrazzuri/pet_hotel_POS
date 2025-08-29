// Functional Room DAO for Android compatibility
// Provides in-memory storage with sample data

import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
// import 'package:uuid/uuid.dart';

class RoomDao {
  static final Map<String, Room> _rooms = {};
  static bool _initialized = false;
  static RoomDao? _instance;
  
  // Private constructor for singleton pattern
  RoomDao._() {
    _initialize();
  }
  
  // Singleton instance getter
  static RoomDao get instance {
    _instance ??= RoomDao._();
    return _instance!;
  }
  // TODO: Uncomment when implementing UUID generation
  // static final Uuid _uuid = const Uuid();

  static void _initialize() {
    if (_initialized) return;
    
    // Create sample rooms
    _rooms['room_001'] = Room(
      id: 'room_001',
      roomNumber: '101',
      name: 'Standard Cat Suite',
      type: RoomType.standard,
      status: RoomStatus.available,
      capacity: 2,
      basePricePerNight: 45.00,
      peakSeasonPrice: 55.00,
      description: 'Comfortable standard room with basic amenities',
      amenities: ['Cat bed', 'Food bowls', 'Litter box', 'Window view'],
      specifications: {
        'width': 3.0,
        'length': 4.0,
        'height': 2.5,
        'hasWindow': true,
        'hasHeating': true,
        'hasAC': true,
        'hasPlayArea': false,
        'isSoundproofed': false,
        'hasSecurityCamera': true,
        'maxPetWeight': 8.0,
        'allowedPetTypes': ['Cat'],
        'isWheelchairAccessible': true,
        'hasEmergencyExit': true,
      },
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      currentPrice: 45.00,
    );

    _rooms['room_002'] = Room(
      id: 'room_002',
      roomNumber: '102',
      name: 'Deluxe Cat Villa',
      type: RoomType.deluxe,
      status: RoomStatus.available,
      capacity: 3,
      basePricePerNight: 65.00,
      peakSeasonPrice: 75.00,
      description: 'Spacious deluxe room with premium amenities',
      amenities: ['Luxury cat bed', 'Premium food bowls', 'Auto-cleaning litter box', 'Large window', 'Cat tree', 'Interactive toys'],
      specifications: {
        'width': 4.0,
        'length': 5.0,
        'height': 2.8,
        'hasWindow': true,
        'hasHeating': true,
        'hasAC': true,
        'hasPlayArea': true,
        'isSoundproofed': true,
        'hasSecurityCamera': true,
        'maxPetWeight': 12.0,
        'allowedPetTypes': ['Cat'],
        'isWheelchairAccessible': true,
        'hasEmergencyExit': true,
      },
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      currentPrice: 65.00,
    );

    _rooms['room_003'] = Room(
      id: 'room_003',
      roomNumber: '201',
      name: 'VIP Cat Penthouse',
      type: RoomType.vip,
      status: RoomStatus.occupied,
      capacity: 4,
      basePricePerNight: 95.00,
      peakSeasonPrice: 110.00,
      description: 'Ultra-luxury VIP suite with all premium features',
      amenities: ['Designer cat furniture', 'Gourmet food service', 'Smart litter system', 'Panoramic windows', 'Private play area', 'Cat TV', 'Massage chair'],
      specifications: {
        'width': 5.0,
        'length': 6.0,
        'height': 3.0,
        'hasWindow': true,
        'hasHeating': true,
        'hasAC': true,
        'hasPlayArea': true,
        'isSoundproofed': true,
        'hasSecurityCamera': true,
        'maxPetWeight': 15.0,
        'allowedPetTypes': ['Cat'],
        'isWheelchairAccessible': true,
        'hasEmergencyExit': true,
      },
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      currentPrice: 95.00,
      currentOccupantId: 'pet_001',
      currentOccupantName: 'Whiskers',
    );

    _rooms['room_004'] = Room(
      id: 'room_004',
      roomNumber: '202',
      name: 'Medical Isolation Suite',
      type: RoomType.isolation,
      status: RoomStatus.available,
      capacity: 1,
      basePricePerNight: 75.00,
      peakSeasonPrice: 85.00,
      description: 'Specialized medical isolation room with monitoring equipment',
      amenities: ['Medical monitoring', 'Sterile environment', 'Easy-clean surfaces', 'Emergency equipment'],
      specifications: {
        'width': 3.5,
        'length': 4.5,
        'height': 2.5,
        'hasWindow': false,
        'hasHeating': true,
        'hasAC': true,
        'hasPlayArea': false,
        'isSoundproofed': true,
        'hasSecurityCamera': true,
        'maxPetWeight': 10.0,
        'allowedPetTypes': ['Cat'],
        'isWheelchairAccessible': true,
        'hasEmergencyExit': true,
        'specialEquipment': 'Medical monitoring system',
      },
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      currentPrice: 75.00,
    );

    _rooms['room_005'] = Room(
      id: 'room_005',
      roomNumber: '301',
      name: 'Family Cat Suite',
      type: RoomType.family,
      status: RoomStatus.reserved,
      capacity: 6,
      basePricePerNight: 85.00,
      peakSeasonPrice: 95.00,
      description: 'Large family suite for multiple cats from the same family',
      amenities: ['Multiple cat beds', 'Family play area', 'Separate feeding stations', 'Large windows', 'Cat tunnels', 'Climbing structures'],
      specifications: {
        'width': 6.0,
        'length': 7.0,
        'height': 3.0,
        'hasWindow': true,
        'hasHeating': true,
        'hasAC': true,
        'hasPlayArea': true,
        'isSoundproofed': true,
        'hasSecurityCamera': true,
        'maxPetWeight': 20.0,
        'allowedPetTypes': ['Cat'],
        'isWheelchairAccessible': true,
        'hasEmergencyExit': true,
      },
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      currentPrice: 85.00,
    );

    _initialized = true;
  }

  Future<void> insert(Room room) async {
    _initialize();
    _rooms[room.id] = room;
  }

  Future<Room?> getById(String id) async {
    _initialize();
    return _rooms[id];
  }

  Future<List<Room>> getAll() async {
    _initialize();
    return _rooms.values.toList();
  }

  Future<List<Room>> getByType(RoomType type) async {
    _initialize();
    return _rooms.values.where((room) => room.type == type).toList();
  }

  Future<List<Room>> getByStatus(RoomStatus status) async {
    _initialize();
    return _rooms.values.where((room) => room.status == status).toList();
  }

  Future<List<Room>> getAvailableRoomsByDate(DateTime checkInDate, DateTime checkOutDate) async {
    _initialize();
    return _rooms.values.where((room) => 
      room.status == RoomStatus.available || room.status == RoomStatus.cleaning
    ).toList();
  }

  Future<List<Room>> getRoomsByCapacity(int minCapacity) async {
    _initialize();
    return _rooms.values.where((room) => room.capacity >= minCapacity).toList();
  }

  Future<Room> update(Room room) async {
    _initialize();
    _rooms[room.id] = room;
    return room;
  }

  Future<void> delete(String id) async {
    _initialize();
    _rooms.remove(id);
  }

  Future<List<Room>> search(String query) async {
    _initialize();
    if (query.trim().isEmpty) return _rooms.values.toList();
    
    final lowercaseQuery = query.toLowerCase();
    return _rooms.values.where((room) =>
      room.name.toLowerCase().contains(lowercaseQuery) ||
      room.roomNumber.toLowerCase().contains(lowercaseQuery) ||
      (room.description?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }

  Future<List<Room>> getRoomsByFloor(String floor) async {
    _initialize();
    return _rooms.values.where((room) => 
      room.roomNumber.startsWith(floor)
    ).toList();
  }

  Future<List<Room>> getRoomsByAmenities(List<String> amenities) async {
    _initialize();
    return _rooms.values.where((room) => 
      amenities.every((amenity) => room.amenities.contains(amenity))
    ).toList();
  }

  Future<Map<String, int>> getRoomCountByType() async {
    _initialize();
    final result = <String, int>{};
    for (final room in _rooms.values) {
      final type = room.type.name;
      result[type] = (result[type] ?? 0) + 1;
    }
    return result;
  }

  Future<Map<String, int>> getRoomCountByStatus() async {
    _initialize();
    final result = <String, int>{};
    for (final room in _rooms.values) {
      final status = room.status.name;
      result[status] = (result[status] ?? 0) + 1;
    }
    return result;
  }

  Future<double> getAverageRoomPrice() async {
    _initialize();
    if (_rooms.isEmpty) return 0.0;
    
    double totalPrice = 0.0;
    for (final room in _rooms.values) {
      totalPrice += room.basePricePerNight;
    }
    return totalPrice / _rooms.length;
  }

  Future<int> getTotalRooms() async {
    _initialize();
    return _rooms.length;
  }

  Future<int> getAvailableRoomsCount() async {
    _initialize();
    return _rooms.values.where((room) => room.status == RoomStatus.available).length;
  }

  Future<int> getOccupiedRoomsCount() async {
    _initialize();
    return _rooms.values.where((room) => room.status == RoomStatus.occupied).length;
  }

  Future<int> getMaintenanceRoomsCount() async {
    _initialize();
    return _rooms.values.where((room) => room.status == RoomStatus.maintenance).length;
  }

  // Additional methods that RoomService expects
  Future<void> softDelete(String roomId) async {
    _initialize();
    final room = _rooms[roomId];
    if (room != null) {
      _rooms[roomId] = room.copyWith(isActive: false);
    }
  }

  Future<List<Room>> getAvailableRooms() async {
    _initialize();
    return _rooms.values.where((room) => 
      room.status == RoomStatus.available && room.isActive
    ).toList();
  }

  Future<List<Room>> searchRooms({
    String? query,
    RoomType? type,
    RoomStatus? status,
    double? minPrice,
    double? maxPrice,
    int? minCapacity,
  }) async {
    _initialize();
    return _rooms.values.where((room) {
      bool matches = true;
      
      if (query != null && query.isNotEmpty) {
        final searchLower = query.toLowerCase();
        matches = matches && (
          room.name.toLowerCase().contains(searchLower) ||
          room.roomNumber.toLowerCase().contains(searchLower) ||
          (room.description?.toLowerCase().contains(searchLower) ?? false)
        );
      }
      
      if (type != null) {
        matches = matches && room.type == type;
      }
      
      if (status != null) {
        matches = matches && room.status == status;
      }
      
      if (minPrice != null) {
        matches = matches && room.basePricePerNight >= minPrice;
      }
      
      if (maxPrice != null) {
        matches = matches && room.basePricePerNight <= maxPrice;
      }
      
      if (minCapacity != null) {
        matches = matches && room.capacity >= minCapacity;
      }
      
      return matches;
    }).toList();
  }

  Future<void> updateRoomStatus(String roomId, RoomStatus status) async {
    _initialize();
    final room = _rooms[roomId];
    if (room != null) {
      _rooms[roomId] = room.copyWith(status: status);
    }
  }

  Future<void> assignOccupant(String roomId, String? occupantId, String? occupantName) async {
    _initialize();
    final room = _rooms[roomId];
    if (room != null) {
      _rooms[roomId] = room.copyWith(
        currentOccupantId: occupantId,
        currentOccupantName: occupantName,
        status: occupantId != null ? RoomStatus.occupied : RoomStatus.available,
      );
    }
  }

  Future<void> updateCleaningSchedule(String roomId, DateTime? lastCleaned, DateTime? nextCleaning) async {
    _initialize();
    final room = _rooms[roomId];
    if (room != null) {
      _rooms[roomId] = room.copyWith(
        lastCleanedAt: lastCleaned,
        nextCleaningDue: nextCleaning,
      );
    }
  }

  Future<void> updateCurrentOccupant(String roomId, String? occupantId, String? occupantName) async {
    _initialize();
    final room = _rooms[roomId];
    if (room != null) {
      _rooms[roomId] = room.copyWith(
        currentOccupantId: occupantId,
        currentOccupantName: occupantName,
        status: occupantId != null ? RoomStatus.occupied : RoomStatus.available,
      );
    }
  }
}
