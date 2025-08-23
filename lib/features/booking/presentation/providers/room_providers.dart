import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:cat_hotel_pos/features/booking/domain/services/room_service.dart';

part 'room_providers.g.dart';

@riverpod
RoomService roomService(RoomServiceRef ref) {
  // Temporarily create without audit service to fix compilation
  return RoomService(null as dynamic);
}

@riverpod
Future<List<Room>> rooms(RoomsRef ref) async {
  final roomService = ref.watch(roomServiceProvider);
  return await roomService.getAllRooms();
}

@riverpod
Future<List<Room>> availableRooms(AvailableRoomsRef ref) async {
  final roomService = ref.watch(roomServiceProvider);
  return await roomService.getAvailableRooms();
}

@riverpod
Future<List<Room>> roomsByStatus(RoomsByStatusRef ref, RoomStatus status) async {
  final roomService = ref.watch(roomServiceProvider);
  return await roomService.getRoomsByStatus(status);
}

@riverpod
Future<List<Room>> roomsByType(RoomsByTypeRef ref, RoomType type) async {
  final roomService = ref.watch(roomServiceProvider);
  return await roomService.getRoomsByType(type);
}

@riverpod
Future<Map<String, dynamic>> roomStatistics(RoomStatisticsRef ref) async {
  final roomService = ref.watch(roomServiceProvider);
  return await roomService.getRoomStatistics();
}

@riverpod
class RoomSearchNotifier extends _$RoomSearchNotifier {
  @override
  Future<List<Room>> build() async {
    final roomService = ref.watch(roomServiceProvider);
    return await roomService.getAllRooms();
  }

  Future<void> searchRooms({
    String? query,
    RoomType? type,
    RoomStatus? status,
    double? minPrice,
    double? maxPrice,
    int? minCapacity,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final roomService = ref.read(roomServiceProvider);
      final results = await roomService.searchRooms(
        query: query,
        type: type,
        status: status,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minCapacity: minCapacity,
      );
      state = AsyncValue.data(results);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    ref.invalidate(roomsProvider);
    final roomService = ref.read(roomServiceProvider);
    final results = await roomService.getAllRooms();
    state = AsyncValue.data(results);
  }
}

@riverpod
class RoomFilterNotifier extends _$RoomFilterNotifier {
  @override
  RoomFilterState build() {
    return const RoomFilterState();
  }

  void updateFilters({
    String? query,
    RoomType? type,
    RoomStatus? status,
    double? minPrice,
    double? maxPrice,
    int? minCapacity,
  }) {
    state = state.copyWith(
      query: query,
      type: type,
      status: status,
      minPrice: minPrice,
      maxPrice: maxPrice,
      minCapacity: minCapacity,
    );
  }

  void clearFilters() {
    state = const RoomFilterState();
  }
}

@riverpod
Future<List<Room>> filteredRooms(FilteredRoomsRef ref) async {
  final filterState = ref.watch(roomFilterNotifierProvider);
  final roomService = ref.watch(roomServiceProvider);
  
  return await roomService.searchRooms(
    query: filterState.query,
    type: filterState.type,
    status: filterState.status,
    minPrice: filterState.minPrice,
    maxPrice: filterState.maxPrice,
    minCapacity: filterState.minCapacity,
  );
}

@riverpod
class RoomNotifier extends _$RoomNotifier {
  @override
  Future<Room?> build(String roomId) async {
    final roomService = ref.watch(roomServiceProvider);
    return await roomService.getRoomById(roomId);
  }

  Future<void> updateRoom({
    String? roomNumber,
    String? name,
    RoomType? type,
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
    final roomService = ref.read(roomServiceProvider);
    final currentRoom = state.value;
    
    if (currentRoom == null) return;

    try {
      final updatedRoom = await roomService.updateRoom(
        roomId: currentRoom.id,
        roomNumber: roomNumber,
        name: name,
        type: type,
        capacity: capacity,
        basePricePerNight: basePricePerNight,
        peakSeasonPrice: peakSeasonPrice,
        description: description,
        amenities: amenities,
        specifications: specifications,
        notes: notes,
        maintenanceNotes: maintenanceNotes,
        images: images,
        metadata: metadata,
      );
      
      state = AsyncValue.data(updatedRoom);
      
      // Invalidate related providers
      ref.invalidate(roomsProvider);
      ref.invalidate(availableRoomsProvider);
      ref.invalidate(roomStatisticsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateStatus(RoomStatus status) async {
    final roomService = ref.read(roomServiceProvider);
    final currentRoom = state.value;
    
    if (currentRoom == null) return;

    try {
      await roomService.updateRoomStatus(currentRoom.id, status);
      
      // Refresh the room data
      final updatedRoom = await roomService.getRoomById(currentRoom.id);
      state = AsyncValue.data(updatedRoom);
      
      // Invalidate related providers
      ref.invalidate(roomsProvider);
      ref.invalidate(availableRoomsProvider);
      ref.invalidate(roomStatisticsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> assignOccupant(String? occupantId, String? occupantName) async {
    final roomService = ref.read(roomServiceProvider);
    final currentRoom = state.value;
    
    if (currentRoom == null) return;

    try {
      await roomService.assignOccupant(currentRoom.id, occupantId, occupantName);
      
      // Refresh the room data
      final updatedRoom = await roomService.getRoomById(currentRoom.id);
      state = AsyncValue.data(updatedRoom);
      
      // Invalidate related providers
      ref.invalidate(roomsProvider);
      ref.invalidate(availableRoomsProvider);
      ref.invalidate(roomStatisticsProvider);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateCleaningSchedule(DateTime? lastCleaned, DateTime? nextCleaning) async {
    final roomService = ref.read(roomServiceProvider);
    final currentRoom = state.value;
    
    if (currentRoom == null) return;

    try {
      await roomService.updateCleaningSchedule(currentRoom.id, lastCleaned, nextCleaning);
      
      // Refresh the room data
      final updatedRoom = await roomService.getRoomById(currentRoom.id);
      state = AsyncValue.data(updatedRoom);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class RoomFilterState {
  final String? query;
  final RoomType? type;
  final RoomStatus? status;
  final double? minPrice;
  final double? maxPrice;
  final int? minCapacity;

  const RoomFilterState({
    this.query,
    this.type,
    this.status,
    this.minPrice,
    this.maxPrice,
    this.minCapacity,
  });

  RoomFilterState copyWith({
    String? query,
    RoomType? type,
    RoomStatus? status,
    double? minPrice,
    double? maxPrice,
    int? minCapacity,
  }) {
    return RoomFilterState(
      query: query ?? this.query,
      type: type ?? this.type,
      status: status ?? this.status,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minCapacity: minCapacity ?? this.minCapacity,
    );
  }

  bool get hasActiveFilters {
    return query != null ||
        type != null ||
        status != null ||
        minPrice != null ||
        maxPrice != null ||
        minCapacity != null;
  }
}
