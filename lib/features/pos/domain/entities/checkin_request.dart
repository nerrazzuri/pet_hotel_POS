import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';

part 'checkin_request.freezed.dart';
part 'checkin_request.g.dart';

/// Type of check-in being performed
enum CheckInType {
  /// Checking in an existing reservation
  existingBooking,
  /// Walk-in customer without reservation
  walkIn,
  /// Emergency check-in (after hours, urgent care)
  emergency,
  /// Express check-in (minimal information required)
  express
}

/// Current step in the check-in workflow
enum CheckInStep {
  bookingLookup,
  customerVerification,
  petInspection,
  roomAssignment,
  serviceConfirmation,
  paymentProcessing,
  completion
}

/// Check-in request containing all necessary information
@freezed
class CheckInRequest with _$CheckInRequest {
  const factory CheckInRequest({
    required String id,
    required CheckInType type,
    required CheckInStep currentStep,
    required DateTime createdAt,
    
    // Booking Information (if existing reservation)
    String? existingBookingId,
    String? bookingNumber,
    
    // Customer Information
    required String customerId,
    required String customerName,
    String? customerPhone,
    String? customerEmail,
    
    // Pet Information
    required String petId,
    required String petName,
    String? petBreed,
    double? petWeight,
    String? petAge,
    List<String>? petMedications,
    List<String>? dietaryRestrictions,
    String? behaviorNotes,
    String? emergencyContact,
    
    // Room Assignment
    String? requestedRoomId,
    String? assignedRoomId,
    String? roomNumber,
    List<String>? roomPreferences,
    
    // Services
    List<String>? confirmedServices,
    List<String>? additionalServices,
    Map<String, double>? servicePrices,
    
    // Check-in Details
    DateTime? plannedCheckInTime,
    DateTime? actualCheckInTime,
    DateTime? plannedCheckOutTime,
    
    // Belongings & Inspection
    List<String>? petBelongings,
    String? arrivalConditionNotes,
    List<String>? arrivalPhotos,
    
    // Special Instructions
    String? specialInstructions,
    String? careNotes,
    String? feedingInstructions,
    String? medicationInstructions,
    
    // Staff Assignment
    String? assignedStaffId,
    String? assignedStaffName,
    
    // Payment Information
    double? totalAmount,
    double? amountPaid,
    double? remainingBalance,
    String? paymentMethod,
    
    // Status Tracking
    bool? isCompleted,
    String? completedBy,
    DateTime? completedAt,
    List<String>? validationErrors,
    Map<String, dynamic>? metadata,
  }) = _CheckInRequest;

  factory CheckInRequest.fromJson(Map<String, dynamic> json) => 
      _$CheckInRequestFromJson(json);
}

/// Result of check-in processing
@freezed
class CheckInResult with _$CheckInResult {
  const factory CheckInResult({
    required bool success,
    required String checkInId,
    String? bookingId,
    String? transactionId,
    String? receiptNumber,
    String? roomNumber,
    DateTime? actualCheckInTime,
    double? totalAmount,
    double? amountPaid,
    String? message,
    List<String>? warnings,
    String? error,
    CheckInConfirmation? confirmation,
    Map<String, dynamic>? additionalData,
  }) = _CheckInResult;

  factory CheckInResult.fromJson(Map<String, dynamic> json) => 
      _$CheckInResultFromJson(json);
}

/// Check-in confirmation details for receipt/documentation
@freezed
class CheckInConfirmation with _$CheckInConfirmation {
  const factory CheckInConfirmation({
    required String confirmationNumber,
    required String customerName,
    required String petName,
    required String roomNumber,
    required DateTime checkInTime,
    required DateTime checkOutTime,
    required List<String> services,
    required double totalAmount,
    required double amountPaid,
    required String paymentMethod,
    String? specialInstructions,
    String? assignedStaff,
    List<String>? emergencyContacts,
    DateTime? generatedAt,
  }) = _CheckInConfirmation;

  factory CheckInConfirmation.fromJson(Map<String, dynamic> json) => 
      _$CheckInConfirmationFromJson(json);
}

/// Pet inspection results during check-in
@freezed
class PetInspection with _$PetInspection {
  const factory PetInspection({
    required String petId,
    required DateTime inspectionTime,
    required String inspectedBy,
    
    // Physical Condition
    required String overallCondition, // 'excellent', 'good', 'fair', 'poor'
    String? weightNotes,
    String? coatCondition,
    String? eyeCondition,
    String? earCondition,
    String? behaviorObservations,
    
    // Health Checks
    bool? vaccinationsVerified,
    List<String>? healthConcerns,
    bool? requiresVetAttention,
    String? temperatureCheck,
    
    // Belongings
    List<String>? belongings,
    String? foodBrought,
    String? medicationBrought,
    List<String>? toysAndComforts,
    
    // Photos
    List<String>? arrivalPhotos,
    
    // Notes
    String? inspectionNotes,
    String? ownerConcerns,
    bool? approved,
    String? rejectionReason,
  }) = _PetInspection;

  factory PetInspection.fromJson(Map<String, dynamic> json) => 
      _$PetInspectionFromJson(json);
}

/// Room assignment details
@freezed
class RoomAssignment with _$RoomAssignment {
  const factory RoomAssignment({
    required String assignmentId,
    required String roomId,
    required String roomNumber,
    required String petId,
    required String petName,
    required DateTime assignedAt,
    required String assignedBy,
    
    // Assignment Details
    DateTime? checkInTime,
    DateTime? plannedCheckOutTime,
    String? assignmentReason,
    List<String>? roomFeatures,
    
    // Special Arrangements
    String? specialArrangements,
    bool? requiresSpecialCare,
    List<String>? careInstructions,
    
    // Status
    String? status, // 'assigned', 'occupied', 'ready_for_checkout'
    bool? isActive,
    DateTime? updatedAt,
  }) = _RoomAssignment;

  factory RoomAssignment.fromJson(Map<String, dynamic> json) => 
      _$RoomAssignmentFromJson(json);
}