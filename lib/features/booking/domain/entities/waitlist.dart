import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';

part 'waitlist.freezed.dart';
part 'waitlist.g.dart';

enum WaitlistStatus {
  pending,
  notified,
  confirmed,
  cancelled,
  expired
}

enum WaitlistPriority {
  low,
  medium,
  high,
  urgent
}

@freezed
class WaitlistEntry with _$WaitlistEntry {
  const factory WaitlistEntry({
    required String id,
    required String customerId,
    required String customerName,
    required String petId,
    required String petName,
    required String phoneNumber,
    required String email,
    required DateTime requestedCheckInDate,
    required DateTime requestedCheckOutDate,
    @JsonKey(fromJson: _roomTypeFromJson, toJson: _roomTypeToJson)
    required RoomType preferredRoomType,
    required int numberOfPets,
    required WaitlistStatus status,
    required WaitlistPriority priority,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? notes,
    String? specialRequirements,
    DateTime? notificationSentAt,
    DateTime? confirmedAt,
    DateTime? cancelledAt,
    String? cancelledBy,
    String? cancellationReason,
    Map<String, dynamic>? metadata,
  }) = _WaitlistEntry;

  factory WaitlistEntry.fromJson(Map<String, dynamic> json) => _$WaitlistEntryFromJson(json);
}

// Helper functions for RoomType serialization
RoomType _roomTypeFromJson(String json) => RoomType.values.firstWhere(
  (e) => e.name == json,
  orElse: () => RoomType.standard,
);

String _roomTypeToJson(RoomType roomType) => roomType.name;
