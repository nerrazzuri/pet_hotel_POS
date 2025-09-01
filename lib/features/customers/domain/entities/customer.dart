import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/pet.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

@JsonEnum()
enum CustomerStatus {
  @JsonValue('active')
  active,
  @JsonValue('inactive')
  inactive,
  @JsonValue('blacklisted')
  blacklisted,
  @JsonValue('pending_verification')
  pendingVerification,
  @JsonValue('suspended')
  suspended,
}

extension CustomerStatusExtension on CustomerStatus {
  String get displayName {
    switch (this) {
      case CustomerStatus.active:
        return 'Active';
      case CustomerStatus.inactive:
        return 'Inactive';
      case CustomerStatus.blacklisted:
        return 'Blacklisted';
      case CustomerStatus.pendingVerification:
        return 'Pending Verification';
      case CustomerStatus.suspended:
        return 'Suspended';
    }
  }
}

@JsonEnum()
enum LoyaltyTier {
  @JsonValue('bronze')
  bronze,
  @JsonValue('silver')
  silver,
  @JsonValue('gold')
  gold,
  @JsonValue('platinum')
  platinum,
  @JsonValue('diamond')
  diamond,
}

extension LoyaltyTierExtension on LoyaltyTier {
  String get displayName {
    switch (this) {
      case LoyaltyTier.bronze:
        return 'Bronze';
      case LoyaltyTier.silver:
        return 'Silver';
      case LoyaltyTier.gold:
        return 'Gold';
      case LoyaltyTier.platinum:
        return 'Platinum';
      case LoyaltyTier.diamond:
        return 'Diamond';
    }
  }
}

@JsonEnum()
enum CustomerSource {
  @JsonValue('walk_in')
  walkIn,
  @JsonValue('online_booking')
  onlineBooking,
  @JsonValue('referral')
  referral,
  @JsonValue('social_media')
  socialMedia,
  @JsonValue('advertisement')
  advertisement,
  @JsonValue('other')
  other,
}

extension CustomerSourceExtension on CustomerSource {
  String get displayName {
    switch (this) {
      case CustomerSource.walkIn:
        return 'Walk In';
      case CustomerSource.onlineBooking:
        return 'Online Booking';
      case CustomerSource.referral:
        return 'Referral';
      case CustomerSource.socialMedia:
        return 'Social Media';
      case CustomerSource.advertisement:
        return 'Advertisement';
      case CustomerSource.other:
        return 'Other';
    }
  }
}



@freezed
class EmergencyContact with _$EmergencyContact {
  const factory EmergencyContact({
    required String id,
    required String name,
    required String relationship,
    required String phoneNumber,
    required String customerId,
    String? email,
    String? address,
    bool? isPrimary,
    String? alternatePhone,
    String? notes,
    bool? isActive,
  }) = _EmergencyContact;

  factory EmergencyContact.fromJson(Map<String, dynamic> json) => _$EmergencyContactFromJson(json);
}

@freezed
class CustomerPreferences with _$CustomerPreferences {
  const factory CustomerPreferences({
    required String id,
    required String customerId,
    String? preferredContactMethod,
    String? preferredContactTime,
    bool? marketingConsent,
    bool? smsConsent,
    bool? emailConsent,
    bool? whatsappConsent,
    String? preferredLanguage,
    String? specialInstructions,
    Map<String, dynamic>? servicePreferences,
    Map<String, dynamic>? roomPreferences,
    Map<String, dynamic>? dietaryPreferences,
    bool? isActive,
  }) = _CustomerPreferences;

  factory CustomerPreferences.fromJson(Map<String, dynamic> json) => _$CustomerPreferencesFromJson(json);
}

@freezed
class Customer with _$Customer {
  const factory Customer({
    required String id,
    required String customerCode,
    required String firstName,
    required String lastName,
    required String email,
    required String phoneNumber,
    required CustomerStatus status,
    required CustomerSource source,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? companyName,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? notes,
    List<Pet>? pets,
    List<EmergencyContact>? emergencyContacts,
    CustomerPreferences? preferences,
    String? loyaltyCardNumber,
    int? loyaltyPoints,
    LoyaltyTier? loyaltyTier,
    DateTime? lastVisitDate,
    double? totalSpent,
    String? referredBy,
    String? referredByCode,
    String? identificationNumber,
    String? identificationType,
    DateTime? dateOfBirth,
    String? occupation,
    String? maritalStatus,
    int? numberOfChildren,
    String? householdSize,
    String? petExperience,
    String? veterinarianName,
    String? veterinarianPhone,
    String? veterinarianClinic,
    bool? isActive,
    Map<String, dynamic>? metadata,
  }) = _Customer;

  factory Customer.fromJson(Map<String, dynamic> json) => _$CustomerFromJson(json);
}



extension CustomerExtension on Customer {
  String get fullName => '$firstName $lastName';
  String get displayName => companyName != null ? '$fullName ($companyName)' : fullName;
  
  bool get hasPets => pets != null && pets!.isNotEmpty;
  int get petCount => pets?.length ?? 0;
  
  bool get hasEmergencyContacts => emergencyContacts != null && emergencyContacts!.isNotEmpty;
  EmergencyContact? get primaryEmergencyContact {
    if (emergencyContacts == null) return null;
    return emergencyContacts!.firstWhere(
      (contact) => contact.isPrimary == true,
      orElse: () => emergencyContacts!.first,
    );
  }
  
  bool get isLoyaltyMember => loyaltyCardNumber != null && loyaltyCardNumber!.isNotEmpty;
  bool get canEarnPoints => status == CustomerStatus.active && isLoyaltyMember;
  
  int get daysSinceLastVisit {
    if (lastVisitDate == null) return -1;
    final now = DateTime.now();
    return now.difference(lastVisitDate!).inDays;
  }
  
  bool get isNewCustomer {
    final now = DateTime.now();
    return now.difference(createdAt).inDays <= 30;
  }
  
  bool get needsFollowUp {
    if (lastVisitDate == null) return false;
    return daysSinceLastVisit > 90;
  }
  
  String get statusDisplay {
    switch (status) {
      case CustomerStatus.active:
        return 'Active';
      case CustomerStatus.inactive:
        return 'Inactive';
      case CustomerStatus.blacklisted:
        return 'Blacklisted';
      case CustomerStatus.pendingVerification:
        return 'Pending Verification';
      case CustomerStatus.suspended:
        return 'Suspended';
    }
  }
  
  String get loyaltyTierDisplay {
    switch (loyaltyTier) {
      case LoyaltyTier.bronze:
        return 'Bronze';
      case LoyaltyTier.silver:
        return 'Silver';
      case LoyaltyTier.gold:
        return 'Gold';
      case LoyaltyTier.platinum:
        return 'Platinum';
      case LoyaltyTier.diamond:
        return 'Diamond';
      default:
        return 'No Tier';
    }
  }
}
