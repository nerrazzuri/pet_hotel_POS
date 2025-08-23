import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/features/booking/domain/services/booking_service.dart';
import 'package:cat_hotel_pos/core/services/booking_dao.dart';
import 'package:cat_hotel_pos/core/services/room_dao.dart';
import 'package:cat_hotel_pos/core/services/customer_dao.dart';
import 'package:cat_hotel_pos/core/services/pet_dao.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/pet.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';


// Service providers
final bookingServiceProvider = Provider<BookingService>((ref) {
  return BookingService(
    bookingDao: ref.read(bookingDaoProvider),
    roomDao: ref.read(roomDaoProvider),
    customerDao: ref.read(customerDaoProvider),
    petDao: ref.read(petDaoProvider),
  );
});

final bookingDaoProvider = Provider<BookingDao>((ref) => BookingDao());
final roomDaoProvider = Provider<RoomDao>((ref) => RoomDao());
final customerDaoProvider = Provider<CustomerDao>((ref) => CustomerDao());
final petDaoProvider = Provider<PetDao>((ref) => PetDao());

// Data providers for other entities
final customersProvider = FutureProvider<List<Customer>>((ref) async {
  final dao = ref.read(customerDaoProvider);
  return await dao.getAll();
});

final petsProvider = FutureProvider<List<Pet>>((ref) async {
  final dao = ref.read(petDaoProvider);
  return await dao.getAll();
});

final roomsProvider = FutureProvider<List<Room>>((ref) async {
  final dao = ref.read(roomDaoProvider);
  return await dao.getAll();
});

// Data providers
final bookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final service = ref.read(bookingServiceProvider);
  return await service.getAllBookings();
});

final activeBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final service = ref.read(bookingServiceProvider);
  return await service.getActiveBookings();
});

final upcomingBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final service = ref.read(bookingServiceProvider);
  return await service.getUpcomingBookings();
});

final pendingBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final service = ref.read(bookingServiceProvider);
  return await service.getBookingsByStatus(BookingStatus.pending);
});

final confirmedBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final service = ref.read(bookingServiceProvider);
  return await service.getBookingsByStatus(BookingStatus.confirmed);
});

final checkedInBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final service = ref.read(bookingServiceProvider);
  return await service.getBookingsByStatus(BookingStatus.checkedIn);
});

final completedBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final service = ref.read(bookingServiceProvider);
  return await service.getBookingsByStatus(BookingStatus.checkedOut);
});

final cancelledBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final service = ref.read(bookingServiceProvider);
  return await service.getBookingsByStatus(BookingStatus.cancelled);
});

// Search and filter providers
final filteredBookingsProvider = FutureProvider<List<Booking>>((ref) async {
  final filterState = ref.watch(bookingFilterNotifierProvider);
  final service = ref.read(bookingServiceProvider);
  
  return await service.searchBookingsWithFilters(
    query: filterState.query,
    status: filterState.status,
    type: filterState.type,
    fromDate: filterState.fromDate,
    toDate: filterState.toDate,
    customerId: filterState.customerId,
    roomId: filterState.roomId,
  );
});

// Statistics provider
final bookingStatisticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(bookingServiceProvider);
  return await service.getBookingStatistics();
});

// Individual booking provider
final bookingByIdProvider = FutureProvider.family<Booking?, String>((ref, bookingId) async {
  final service = ref.read(bookingServiceProvider);
  return await service.getBookingById(bookingId);
});

final bookingByNumberProvider = FutureProvider.family<Booking?, String>((ref, bookingNumber) async {
  final service = ref.read(bookingServiceProvider);
  return await service.getBookingByNumber(bookingNumber);
});

// Filter state notifier
class BookingFilterNotifier extends StateNotifier<BookingFilterState> {
  BookingFilterNotifier() : super(BookingFilterState.initial());

  void updateFilters({
    String? query,
    BookingStatus? status,
    BookingType? type,
    DateTime? fromDate,
    DateTime? toDate,
    String? customerId,
    String? roomId,
  }) {
    state = state.copyWith(
      query: query,
      status: status,
      type: type,
      fromDate: fromDate,
      toDate: toDate,
      customerId: customerId,
      roomId: roomId,
    );
  }

  void clearFilters() {
    state = BookingFilterState.initial();
  }

  void setQuery(String query) {
    state = state.copyWith(query: query);
  }

  void setStatus(BookingStatus? status) {
    state = state.copyWith(status: status);
  }

  void setType(BookingType? type) {
    state = state.copyWith(type: type);
  }

  void setDateRange(DateTime? fromDate, DateTime? toDate) {
    state = state.copyWith(fromDate: fromDate, toDate: toDate);
  }

  void setCustomer(String? customerId) {
    state = state.copyWith(customerId: customerId);
  }

  void setRoom(String? roomId) {
    state = state.copyWith(roomId: roomId);
  }
}

final bookingFilterNotifierProvider = StateNotifierProvider<BookingFilterNotifier, BookingFilterState>((ref) {
  return BookingFilterNotifier();
});

// Filter state class
class BookingFilterState {
  final String? query;
  final BookingStatus? status;
  final BookingType? type;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? customerId;
  final String? roomId;

  const BookingFilterState({
    this.query,
    this.status,
    this.type,
    this.fromDate,
    this.toDate,
    this.customerId,
    this.roomId,
  });

  factory BookingFilterState.initial() => const BookingFilterState();

  BookingFilterState copyWith({
    String? query,
    BookingStatus? status,
    BookingType? type,
    DateTime? fromDate,
    DateTime? toDate,
    String? customerId,
    String? roomId,
  }) {
    return BookingFilterState(
      query: query ?? this.query,
      status: status ?? this.status,
      type: type ?? this.type,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      customerId: customerId ?? this.customerId,
      roomId: roomId ?? this.roomId,
    );
  }

  bool get hasActiveFilters {
    return query != null ||
           status != null ||
           type != null ||
           fromDate != null ||
           toDate != null ||
           customerId != null ||
           roomId != null;
  }
}

// Booking operations notifier
class BookingNotifier extends StateNotifier<AsyncValue<void>> {
  final BookingService _service;

  BookingNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> createBooking({
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
    state = const AsyncValue.loading();
    
    try {
      await _service.createBooking(
        customerId: customerId,
        petId: petId,
        roomId: roomId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
        type: type,
        basePricePerNight: basePricePerNight,
        additionalServices: additionalServices,
        servicePrices: servicePrices,
        specialInstructions: specialInstructions,
        careNotes: careNotes,
        veterinaryNotes: veterinaryNotes,
        depositAmount: depositAmount,
        discountAmount: discountAmount,
        taxAmount: taxAmount,
        assignedStaffId: assignedStaffId,
        assignedStaffName: assignedStaffName,
      );
      
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateBooking({
    required String bookingId,
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
    state = const AsyncValue.loading();
    
    try {
      await _service.updateBooking(
        id: bookingId,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
        type: type,
        basePricePerNight: basePricePerNight,
        additionalServices: additionalServices,
        servicePrices: servicePrices,
        specialInstructions: specialInstructions,
        careNotes: careNotes,
        veterinaryNotes: veterinaryNotes,
        depositAmount: depositAmount,
        discountAmount: discountAmount,
        taxAmount: taxAmount,
        assignedStaffId: assignedStaffId,
        assignedStaffName: assignedStaffName,
      );
      
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus newStatus) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.updateBookingStatus(bookingId, newStatus);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> checkIn(String bookingId, {DateTime? actualCheckInTime}) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.checkIn(bookingId, actualCheckInTime ?? DateTime.now());
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> checkOut(String bookingId, {DateTime? actualCheckOutTime}) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.checkOut(bookingId, actualCheckOutTime ?? DateTime.now());
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> cancelBooking(String bookingId, String reason, double? refundAmount) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.cancelBooking(bookingId, reason, refundAmount);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.deleteBooking(bookingId);
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final bookingNotifierProvider = StateNotifierProvider<BookingNotifier, AsyncValue<void>>((ref) {
  final service = ref.read(bookingServiceProvider);
  return BookingNotifier(service);
});

// Search notifier
class BookingSearchNotifier extends StateNotifier<AsyncValue<List<Booking>>> {
  final BookingService _service;

  BookingSearchNotifier(this._service) : super(const AsyncValue.data([]));

  Future<void> searchBookings({
    String? query,
    BookingStatus? status,
    BookingType? type,
    DateTime? fromDate,
    DateTime? toDate,
    String? customerId,
    String? roomId,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      final results = await _service.searchBookingsWithFilters(
        query: query,
        status: status,
        type: type,
        fromDate: fromDate,
        toDate: toDate,
        customerId: customerId,
        roomId: roomId,
      );
      
      state = AsyncValue.data(results);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearSearch() {
    state = const AsyncValue.data([]);
  }
}

final bookingSearchNotifierProvider = StateNotifierProvider<BookingSearchNotifier, AsyncValue<List<Booking>>>((ref) {
  final service = ref.read(bookingServiceProvider);
  return BookingSearchNotifier(service);
});
