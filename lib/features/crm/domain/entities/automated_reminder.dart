import 'package:freezed_annotation/freezed_annotation.dart';

part 'automated_reminder.freezed.dart';
part 'automated_reminder.g.dart';

enum ReminderType {
  vaccinationExpiry,
  upcomingBooking,
  checkInPrep,
  checkOut,
  loyaltyPointsExpiry,
  birthday,
  followUp,
  custom,
}

enum ReminderStatus {
  pending,
  sent,
  failed,
  cancelled,
}

enum ReminderChannel {
  email,
  sms,
  whatsapp,
  push,
}

@freezed
class AutomatedReminder with _$AutomatedReminder {
  const factory AutomatedReminder({
    required String id,
    required String customerId,
    required String? petId,
    required ReminderType type,
    required ReminderStatus status,
    required ReminderChannel channel,
    required String subject,
    required String message,
    required DateTime scheduledAt,
    required DateTime? sentAt,
    required int retryCount,
    required String? errorMessage,
    required Map<String, dynamic>? metadata,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _AutomatedReminder;

  factory AutomatedReminder.fromJson(Map<String, dynamic> json) =>
      _$AutomatedReminderFromJson(json);
}
