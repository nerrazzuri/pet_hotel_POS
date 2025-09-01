import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_policy.freezed.dart';
part 'booking_policy.g.dart';

enum PolicyType {
  overbooking,
  lateCheckout,
  noShow,
  cancellation,
  deposit,
  refund
}

@freezed
class BookingPolicy with _$BookingPolicy {
  const factory BookingPolicy({
    required String id,
    required String name,
    required PolicyType type,
    required String description,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
    // Overbooking policy
    int? maxOverbookingPercentage,
    List<String>? overbookingAllowedRoomTypes,
    // Late checkout policy
    double? lateCheckoutFeePerHour,
    int? gracePeriodMinutes,
    TimeOfDay? standardCheckoutTime,
    // No-show policy
    double? noShowFeePercentage,
    int? noShowGracePeriodHours,
    // Cancellation policy
    double? cancellationFeePercentage,
    int? freeCancellationHours,
    // Deposit policy
    double? depositPercentage,
    double? minimumDepositAmount,
    // Refund policy
    double? refundPercentage,
    int? refundProcessingDays,
    Map<String, dynamic>? conditions,
    Map<String, dynamic>? metadata,
  }) = _BookingPolicy;

  factory BookingPolicy.fromJson(Map<String, dynamic> json) => _$BookingPolicyFromJson(json);
}

@freezed
class TimeOfDay with _$TimeOfDay {
  const factory TimeOfDay({
    required int hour,
    required int minute,
  }) = _TimeOfDay;

  factory TimeOfDay.fromJson(Map<String, dynamic> json) => _$TimeOfDayFromJson(json);
}
