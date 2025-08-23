import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking.freezed.dart';
part 'booking.g.dart';

enum BookingStatus {
  confirmed,
  pending,
  checkedIn,
  checkedOut,
  cancelled,
  noShow,
  completed
}

enum BookingType {
  standard,
  extended,
  emergency,
  medical,
  grooming,
  training
}

@freezed
class Booking with _$Booking {
  const factory Booking({
    required String id,
    required String bookingNumber,
    required String customerId,
    required String customerName,
    required String petId,
    required String petName,
    required String roomId,
    required String roomNumber,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required BookingTimeOfDay checkInTime,
    required BookingTimeOfDay checkOutTime,
    required BookingStatus status,
    required BookingType type,
    required double basePricePerNight,
    required double totalAmount,
    required DateTime createdAt,
    required DateTime updatedAt,
    double? depositAmount,
    double? discountAmount,
    double? taxAmount,
    String? specialInstructions,
    String? careNotes,
    String? veterinaryNotes,
    List<String>? additionalServices,
    Map<String, double>? servicePrices,
    String? assignedStaffId,
    String? assignedStaffName,
    DateTime? actualCheckInTime,
    DateTime? actualCheckOutTime,
    String? cancellationReason,
    DateTime? cancelledAt,
    String? cancelledBy,
    double? refundAmount,
    String? paymentMethod,
    String? paymentStatus,
    String? invoiceNumber,
    String? receiptNumber,
    Map<String, dynamic>? metadata,
  }) = _Booking;

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
}

@freezed
class BookingTimeOfDay with _$BookingTimeOfDay {
  const factory BookingTimeOfDay({
    required int hour,
    required int minute,
  }) = _BookingTimeOfDay;

  factory BookingTimeOfDay.fromJson(Map<String, dynamic> json) => _$BookingTimeOfDayFromJson(json);
}

@freezed
class AdditionalService with _$AdditionalService {
  const factory AdditionalService({
    required String id,
    required String name,
    required String description,
    required double price,
    required String category,
    required bool isActive,
    String? notes,
    Map<String, dynamic>? metadata,
  }) = _AdditionalService;

  factory AdditionalService.fromJson(Map<String, dynamic> json) =>
      _$AdditionalServiceFromJson(json);
}
