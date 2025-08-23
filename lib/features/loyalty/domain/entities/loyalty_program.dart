import 'package:freezed_annotation/freezed_annotation.dart';

part 'loyalty_program.freezed.dart';
part 'loyalty_program.g.dart';

@freezed
class LoyaltyProgram with _$LoyaltyProgram {
  const factory LoyaltyProgram({
    required String id,
    required String name,
    required String description,
    required List<LoyaltyTier> tiers,
    required LoyaltyRules rules,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _LoyaltyProgram;

  factory LoyaltyProgram.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyProgramFromJson(json);
}

@freezed
class LoyaltyTier with _$LoyaltyTier {
  const factory LoyaltyTier({
    required String id,
    required String name,
    required String description,
    required int minPoints,
    required double discountPercentage,
    required List<String> benefits,
    required String color,
    required String icon,
  }) = _LoyaltyTier;

  factory LoyaltyTier.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyTierFromJson(json);
}

@freezed
class LoyaltyRules with _$LoyaltyRules {
  const factory LoyaltyRules({
    required double pointsPerRinggit,
    required double pointsPerNight,
    required double pointsPerService,
    required int pointsExpiryMonths,
    required double minimumRedemptionAmount,
    required List<String> excludedServices,
    required List<String> excludedProducts,
  }) = _LoyaltyRules;

  factory LoyaltyRules.fromJson(Map<String, dynamic> json) =>
      _$LoyaltyRulesFromJson(json);
}
