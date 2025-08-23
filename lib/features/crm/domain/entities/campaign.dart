import 'package:freezed_annotation/freezed_annotation.dart';

part 'campaign.freezed.dart';
part 'campaign.g.dart';

enum CampaignType {
  email,
  sms,
  whatsapp,
  push,
}

enum CampaignStatus {
  draft,
  scheduled,
  active,
  paused,
  completed,
  cancelled,
}

enum CampaignTarget {
  allCustomers,
  specificTier,
  specificSegment,
  recentBookings,
  expiringVaccinations,
  loyaltyMembers,
}

@freezed
class Campaign with _$Campaign {
  const factory Campaign({
    required String id,
    required String name,
    required String description,
    required CampaignType type,
    required CampaignStatus status,
    required CampaignTarget target,
    required String subject,
    required String content,
    required String? templateId,
    required List<String> targetCustomerIds,
    required Map<String, dynamic>? targetCriteria,
    required DateTime? scheduledAt,
    required DateTime? sentAt,
    required int totalRecipients,
    required int sentCount,
    required int openedCount,
    required int clickedCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    required String createdBy,
  }) = _Campaign;

  factory Campaign.fromJson(Map<String, dynamic> json) =>
      _$CampaignFromJson(json);
}
