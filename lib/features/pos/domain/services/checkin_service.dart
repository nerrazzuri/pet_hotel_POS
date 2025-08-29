import 'package:uuid/uuid.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/checkin_request.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:cat_hotel_pos/features/booking/domain/services/booking_service.dart';
import 'package:cat_hotel_pos/features/booking/domain/services/room_service.dart';
import 'package:cat_hotel_pos/features/customers/domain/services/customer_service.dart';
import 'package:cat_hotel_pos/features/customers/domain/services/customer_pet_service.dart';
import 'package:cat_hotel_pos/features/pos/presentation/providers/pos_providers.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/cart_item.dart';
import 'package:cat_hotel_pos/features/pos/domain/services/pet_inspection_service.dart';
import 'package:cat_hotel_pos/features/pos/domain/services/checkin_payment_service.dart';
import 'package:cat_hotel_pos/features/payments/domain/entities/payment_transaction.dart';
import 'package:cat_hotel_pos/core/services/booking_dao.dart';
import 'package:cat_hotel_pos/core/services/room_dao.dart';

/// Comprehensive check-in service that orchestrates booking, room, and POS integration
class CheckInService {
  final BookingService _bookingService;
  final RoomService _roomService;
  final CustomerService _customerService;
  final CustomerPetService _petService;
  final PetInspectionService _inspectionService;
  final CheckInPaymentService _paymentService;
  final BookingDao _bookingDao = BookingDao();
  final Uuid _uuid = const Uuid();

  CheckInService({
    required BookingService bookingService,
    required RoomService roomService,
    required CustomerService customerService,
    required CustomerPetService petService,
    required PetInspectionService inspectionService,
    required CheckInPaymentService paymentService,
  }) : _bookingService = bookingService,
       _roomService = roomService,
       _customerService = customerService,
       _petService = petService,
       _inspectionService = inspectionService,
       _paymentService = paymentService;

  /// Search for existing bookings for check-in
  Future<List<Booking>> searchBookingsForCheckIn({
    String? customerName,
    String? phoneNumber,
    String? bookingNumber,
    String? petName,
  }) async {
    try {
      List<Booking> results = [];

      // Search by booking number (most precise)
      if (bookingNumber != null && bookingNumber.isNotEmpty) {
        final booking = await _bookingDao.getByBookingNumber(bookingNumber);
        if (booking != null) {
          results.add(booking);
        }
      }

      // Search by customer name
      if (customerName != null && customerName.isNotEmpty) {
        final allBookings = await _bookingDao.getAll();
        final nameMatches = allBookings.where((booking) => 
          booking.customerName.toLowerCase().contains(customerName.toLowerCase()) &&
          (booking.status == BookingStatus.confirmed || booking.status == BookingStatus.pending)
        ).toList();
        results.addAll(nameMatches);
      }

      // Search by phone number (requires customer service integration)
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        final customers = await _customerService.searchCustomers(phoneNumber);
        for (final customer in customers) {
          final customerBookings = await _bookingDao.getByCustomerId(customer.id);
          final activeBookings = customerBookings.where((booking) =>
            booking.status == BookingStatus.confirmed || booking.status == BookingStatus.pending
          ).toList();
          results.addAll(activeBookings);
        }
      }

      // Search by pet name
      if (petName != null && petName.isNotEmpty) {
        final allBookings = await _bookingDao.getAll();
        final petMatches = allBookings.where((booking) => 
          booking.petName.toLowerCase().contains(petName.toLowerCase()) &&
          (booking.status == BookingStatus.confirmed || booking.status == BookingStatus.pending)
        ).toList();
        results.addAll(petMatches);
      }

      // Remove duplicates and sort by check-in date
      final uniqueResults = results.toSet().toList();
      uniqueResults.sort((a, b) => a.checkInDate.compareTo(b.checkInDate));

      return uniqueResults;
    } catch (e) {
      throw Exception('Error searching bookings: $e');
    }
  }

  /// Validate booking eligibility for check-in
  Future<List<String>> validateBookingForCheckIn(Booking booking) async {
    final List<String> errors = [];
    final now = DateTime.now();

    // Check booking status
    if (booking.status == BookingStatus.checkedIn) {
      errors.add('This booking is already checked in');
    } else if (booking.status == BookingStatus.cancelled) {
      errors.add('This booking has been cancelled');
    } else if (booking.status == BookingStatus.completed) {
      errors.add('This booking has been completed');
    } else if (booking.status == BookingStatus.noShow) {
      errors.add('This booking was marked as no-show');
    }

    // Check dates
    final checkInDate = booking.checkInDate;
    final daysDifference = now.difference(checkInDate).inDays;
    
    if (daysDifference < -1) {
      errors.add('Check-in is more than 1 day early (scheduled for ${checkInDate.day}/${checkInDate.month})');
    } else if (daysDifference > 1) {
      errors.add('Check-in is more than 1 day late (was scheduled for ${checkInDate.day}/${checkInDate.month})');
    }

    // Check room availability - only if the booking has a valid room ID
    if (booking.roomId.isNotEmpty) {
      try {
        final room = await _roomService.getRoomById(booking.roomId);
        if (room == null) {
          // Don't add error for missing original room - user can select a different room during check-in
        } else if (room.status == RoomStatus.occupied) {
          errors.add('Room ${room.roomNumber} is currently occupied');
        } else if (room.status == RoomStatus.maintenance) {
          errors.add('Room ${room.roomNumber} is under maintenance');
        } else if (room.status == RoomStatus.outOfService) {
          errors.add('Room ${room.roomNumber} is out of service');
        } else if (!room.isActive) {
          errors.add('Room ${room.roomNumber} is not active');
        }
      } catch (e) {
        errors.add('Error checking room availability: $e');
      }
    }

    // Check payment status - temporarily disabled for testing
    // TODO: Re-enable payment validation when payment system is implemented
    /*
    if (booking.paymentStatus != null && booking.paymentStatus != 'paid' && booking.paymentStatus != 'partial') {
      if (booking.depositAmount == null || booking.depositAmount! <= 0) {
        errors.add('No deposit or payment on file');
      }
    }
    */

    return errors;
  }

  /// Find available rooms for walk-in check-in
  Future<List<Room>> findAvailableRooms({
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? minCapacity,
    RoomType? preferredType,
    List<String>? requiredAmenities,
  }) async {
    try {
      checkInDate ??= DateTime.now();
      checkOutDate ??= checkInDate.add(const Duration(days: 1));

            // Get available rooms (for now, we'll get all available rooms and filter by date later)
      List<Room> availableRooms = await _roomService.getAvailableRooms();

      // Filter by capacity if specified
      if (minCapacity != null) {
        availableRooms = availableRooms.where((room) => room.capacity >= minCapacity).toList();
      }

      // Filter by room type if specified
      if (preferredType != null) {
        availableRooms = availableRooms.where((room) => room.type == preferredType).toList();
      }

      // Filter by amenities if specified
      if (requiredAmenities != null && requiredAmenities.isNotEmpty) {
        availableRooms = availableRooms.where((room) {
          return requiredAmenities.every((amenity) => room.amenities.contains(amenity));
        }).toList();
      }

      // Sort by price (ascending) and then by room number
      availableRooms.sort((a, b) {
        final priceComparison = (a.currentPrice ?? a.basePricePerNight)
            .compareTo(b.currentPrice ?? b.basePricePerNight);
        if (priceComparison != 0) return priceComparison;
        return a.roomNumber.compareTo(b.roomNumber);
      });

      return availableRooms;
    } catch (e) {
      throw Exception('Error finding available rooms: $e');
    }
  }

  /// Conduct pet inspection as part of check-in process
  Future<PetInspection> conductPetInspection({
    required String petId,
    required String inspectorName,
    String? behaviorNotes,
    List<String>? belongings,
    bool isQuickInspection = false,
  }) async {
    try {
      if (isQuickInspection) {
        return await _inspectionService.quickInspection(
          petId: petId,
          inspectorName: inspectorName,
          behaviorNotes: behaviorNotes,
          belongings: belongings,
        );
      } else {
        return await _inspectionService.conductPetInspection(
          petId: petId,
          inspectorId: 'current_user', // TODO: Get from auth context
          inspectorName: inspectorName,
          overallCondition: 'good',
          behaviorObservations: behaviorNotes,
          belongings: belongings,
          vaccinationsVerified: true,
        );
      }
    } catch (e) {
      throw Exception('Error conducting pet inspection: $e');
    }
  }

  /// Validate pet eligibility for check-in
  Future<List<String>> validatePetForCheckIn(String petId) async {
    try {
      return await _inspectionService.validatePetForCheckIn(petId);
    } catch (e) {
      return ['Error validating pet: $e'];
    }
  }

  /// Get pet information for check-in display
  Future<Map<String, dynamic>> getPetCheckInInfo(String petId) async {
    try {
      return await _inspectionService.getPetInspectionData(petId);
    } catch (e) {
      return {
        'error': 'Error retrieving pet information: $e',
        'petExists': false,
      };
    }
  }

  /// Get payment summary for check-in
  Future<CheckInPaymentSummary> getCheckInPaymentSummary({
    required Booking? booking,
    required List<String> selectedServices,
    Map<String, double>? servicePrices,
    double? additionalAmount,
  }) async {
    try {
      return await _paymentService.calculateCheckInPayments(
        booking: booking,
        selectedServices: selectedServices,
        servicePrices: servicePrices,
        additionalAmount: additionalAmount,
      );
    } catch (e) {
      throw Exception('Error calculating payment summary: $e');
    }
  }

  /// Process payment during check-in
  Future<CheckInPaymentResult> processCheckInPayment(CheckInPaymentRequest request) async {
    try {
      return await _paymentService.processCheckInPayment(request);
    } catch (e) {
      throw Exception('Error processing payment: $e');
    }
  }

  /// Get payment history for a booking
  Future<List<PaymentTransaction>> getBookingPaymentHistory(String bookingId) async {
    try {
      return await _paymentService.getBookingPaymentHistory(bookingId);
    } catch (e) {
      throw Exception('Error retrieving payment history: $e');
    }
  }

  /// Perform complete check-in process with pet inspection and payment
  Future<CheckInResult> performCompleteCheckIn(
    CheckInRequest request, {
    PetInspection? petInspection,
    PaymentTransaction? paymentTransaction,
  }) async {
    try {
      // Step 1: Validate pet inspection if provided
      if (petInspection != null && petInspection.approved != true) {
        return CheckInResult(
          success: false,
          checkInId: _uuid.v4(),
          error: 'Pet inspection not approved: ${petInspection.rejectionReason ?? 'Unknown reason'}',
        );
      }

      // Step 2: Process the check-in
      final result = await performCheckIn(request);
      
      // Step 3: Add inspection and payment information to result
      if (result.success) {
        final additionalData = result.additionalData ?? {};
        
        if (petInspection != null) {
          additionalData['petInspection'] = petInspection;
        }
        
        if (paymentTransaction != null) {
          additionalData['paymentTransaction'] = paymentTransaction;
        }
        
        return result.copyWith(additionalData: additionalData);
      }
      
      return result;
    } catch (e) {
      return CheckInResult(
        success: false,
        checkInId: _uuid.v4(),
        error: 'Complete check-in failed: $e',
      );
    }
  }

  /// Perform complete check-in process with pet inspection
  Future<CheckInResult> performCheckInWithInspection(
    CheckInRequest request, {
    PetInspection? petInspection,
  }) async {
    try {
      // Step 1: Validate pet if inspection not provided
      if (petInspection == null) {
        final petWarnings = await validatePetForCheckIn(request.petId);
        if (petWarnings.isNotEmpty) {
          return CheckInResult(
            success: false,
            checkInId: _uuid.v4(),
            error: 'Pet validation failed',
            warnings: petWarnings,
          );
        }
      } else {
        // Validate pet inspection
        if (petInspection.approved != true) {
          return CheckInResult(
            success: false,
            checkInId: _uuid.v4(),
            error: 'Pet inspection not approved: ${petInspection.rejectionReason ?? 'Unknown reason'}',
          );
        }
      }

      // Continue with regular check-in process
      final result = await performCheckIn(request);
      
      // Add inspection information to result if available
      if (petInspection != null && result.success) {
        final additionalData = result.additionalData ?? {};
        additionalData['petInspection'] = petInspection;
        
        return result.copyWith(additionalData: additionalData);
      }
      
      return result;
    } catch (e) {
      return CheckInResult(
        success: false,
        checkInId: _uuid.v4(),
        error: 'Check-in with inspection failed: $e',
      );
    }
  }

  /// Perform complete check-in process
  Future<CheckInResult> performCheckIn(CheckInRequest request) async {
    try {
      final checkInId = _uuid.v4();
      final now = DateTime.now();

      // Step 1: Validate the request
      final validationErrors = await _validateCheckInRequest(request);
      if (validationErrors.isNotEmpty) {
        return CheckInResult(
          success: false,
          checkInId: checkInId,
          error: 'Validation failed',
          warnings: validationErrors,
        );
      }

      // Step 2: Handle room assignment
      String? finalRoomId;
      String? finalRoomNumber;

      if (request.assignedRoomId != null) {
        // Use pre-assigned room
        finalRoomId = request.assignedRoomId;
        final room = await _roomService.getRoomById(finalRoomId!);
        finalRoomNumber = room?.roomNumber;
      } else {
        // Auto-assign available room
        final availableRooms = await findAvailableRooms(
          checkInDate: request.actualCheckInTime ?? now,
          checkOutDate: request.plannedCheckOutTime,
        );
        
        if (availableRooms.isEmpty) {
          return CheckInResult(
            success: false,
            checkInId: checkInId,
            error: 'No rooms available for check-in',
          );
        }
        
        final assignedRoom = availableRooms.first;
        finalRoomId = assignedRoom.id;
        finalRoomNumber = assignedRoom.roomNumber;
      }

      // Step 3: Update room status to occupied
      await _roomService.updateRoomStatus(finalRoomId!, RoomStatus.occupied);
      await _roomService.assignOccupant(finalRoomId!, request.petId, request.petName);

      // Step 4: Update or create booking
      String? bookingId;
      double totalAmount = request.totalAmount ?? 0.0;

      if (request.existingBookingId != null) {
        // Update existing booking
        final existingBooking = await _bookingDao.getById(request.existingBookingId!);
        if (existingBooking != null) {
          final updatedBooking = existingBooking.copyWith(
            status: BookingStatus.checkedIn,
            actualCheckInTime: request.actualCheckInTime ?? now,
            roomId: finalRoomId,
            roomNumber: finalRoomNumber!,
            specialInstructions: request.specialInstructions,
            careNotes: request.careNotes,
            assignedStaffId: request.assignedStaffId,
            assignedStaffName: request.assignedStaffName,
            updatedAt: now,
          );
          await _bookingDao.update(updatedBooking);
          bookingId = existingBooking.id;
          totalAmount = existingBooking.totalAmount;
        }
      } else {
        // Create new booking for walk-in
        final room = await _roomService.getRoomById(finalRoomId!);
        final customer = await _customerService.getCustomerById(request.customerId);
        final pet = await _petService.getPetById(request.petId);
        
        if (room == null || customer == null || pet == null) {
          return CheckInResult(
            success: false,
            checkInId: checkInId,
            error: 'Required data not found (room, customer, or pet)',
          );
        }

        final newBooking = await _bookingService.createBooking(
          customerId: request.customerId,
          petId: request.petId,
          roomId: finalRoomId,
          checkInDate: request.actualCheckInTime ?? now,
          checkOutDate: request.plannedCheckOutTime ?? now.add(const Duration(days: 1)),
          checkInTime: BookingTimeOfDay(
            hour: (request.actualCheckInTime ?? now).hour,
            minute: (request.actualCheckInTime ?? now).minute,
          ),
          checkOutTime: const BookingTimeOfDay(hour: 11, minute: 0),
          type: BookingType.standard,
          basePricePerNight: room.currentPrice ?? room.basePricePerNight,
          specialInstructions: request.specialInstructions,
          careNotes: request.careNotes,
          assignedStaffId: request.assignedStaffId,
          assignedStaffName: request.assignedStaffName,
          additionalServices: request.confirmedServices,
          servicePrices: request.servicePrices,
        );

        // Update booking to checked-in status
        final checkedInBooking = newBooking.copyWith(
          status: BookingStatus.checkedIn,
          actualCheckInTime: request.actualCheckInTime ?? now,
        );
        await _bookingDao.update(checkedInBooking);
        
        bookingId = newBooking.id;
        totalAmount = newBooking.totalAmount;
      }

      // Step 5: Generate confirmation
      final confirmation = CheckInConfirmation(
        confirmationNumber: 'CHK-${now.millisecondsSinceEpoch}',
        customerName: request.customerName,
        petName: request.petName,
        roomNumber: finalRoomNumber!,
        checkInTime: request.actualCheckInTime ?? now,
        checkOutTime: request.plannedCheckOutTime ?? now.add(const Duration(days: 1)),
        services: request.confirmedServices ?? [],
        totalAmount: totalAmount,
        amountPaid: request.amountPaid ?? 0.0,
        paymentMethod: request.paymentMethod ?? 'pending',
        specialInstructions: request.specialInstructions,
        assignedStaff: request.assignedStaffName,
        generatedAt: now,
      );

      return CheckInResult(
        success: true,
        checkInId: checkInId,
        bookingId: bookingId,
        roomNumber: finalRoomNumber,
        actualCheckInTime: request.actualCheckInTime ?? now,
        totalAmount: totalAmount,
        amountPaid: request.amountPaid ?? 0.0,
        message: 'Check-in completed successfully',
        confirmation: confirmation,
      );

    } catch (e) {
      return CheckInResult(
        success: false,
        checkInId: _uuid.v4(),
        error: 'Check-in failed: $e',
      );
    }
  }

  /// Create cart items for POS integration
  Future<List<CartItem>> createCartItemsFromBooking(Booking booking) async {
    final List<CartItem> items = [];

    // Add accommodation service
    items.add(CartItem(
      id: '${booking.id}_accommodation',
      name: 'Room ${booking.roomNumber} - ${_getRoomTypeDisplayName(booking.roomId)}',
      type: 'accommodation',
      price: booking.basePricePerNight,
      quantity: booking.checkOutDate.difference(booking.checkInDate).inDays,
      category: 'Accommodation',
      notes: 'Pet: ${booking.petName}, Check-in: ${booking.checkInDate.day}/${booking.checkInDate.month}',
    ));

    // Add additional services
    if (booking.additionalServices != null) {
      for (final service in booking.additionalServices!) {
        final price = booking.servicePrices?[service] ?? 0.0;
        items.add(CartItem(
          id: '${booking.id}_$service',
          name: _getServiceDisplayName(service),
          type: 'service',
          price: price,
          quantity: 1,
          category: _getServiceCategory(service),
          notes: 'Pet: ${booking.petName}',
        ));
      }
    }

    return items;
  }

  /// Validate check-in request
  Future<List<String>> _validateCheckInRequest(CheckInRequest request) async {
    final List<String> errors = [];

    // Basic validation
    if (request.customerName.isEmpty) {
      errors.add('Customer name is required');
    }

    if (request.petName.isEmpty) {
      errors.add('Pet name is required');
    }

    // Validate existing booking if provided
    if (request.existingBookingId != null) {
      try {
        final booking = await _bookingDao.getById(request.existingBookingId!);
        if (booking == null) {
          errors.add('Booking not found');
        } else {
          final bookingErrors = await validateBookingForCheckIn(booking);
          errors.addAll(bookingErrors);
        }
      } catch (e) {
        errors.add('Error validating booking: $e');
      }
    }

    // Validate room assignment if provided
    if (request.assignedRoomId != null) {
      try {
        final room = await _roomService.getRoomById(request.assignedRoomId!);
        if (room == null) {
          errors.add('Assigned room not found');
        } else if (room.status != RoomStatus.available && room.status != RoomStatus.reserved) {
          errors.add('Room ${room.roomNumber} is not available');
        }
      } catch (e) {
        errors.add('Error validating room: $e');
      }
    }

    return errors;
  }

  // Helper methods for display names
  String _getRoomTypeDisplayName(String roomId) {
    // This would typically come from the room service
    return 'Standard Room';
  }

  String _getServiceDisplayName(String serviceCode) {
    switch (serviceCode) {
      case 'grooming_basic': return 'Basic Grooming';
      case 'grooming_premium': return 'Premium Grooming';
      case 'walking': return 'Daily Walking';
      case 'feeding_premium': return 'Premium Food Service';
      case 'medication': return 'Medication Administration';
      default: return serviceCode;
    }
  }

  String _getServiceCategory(String serviceCode) {
    if (serviceCode.startsWith('grooming')) return 'Grooming';
    if (serviceCode.startsWith('walking')) return 'Exercise';
    if (serviceCode.startsWith('feeding')) return 'Nutrition';
    if (serviceCode.startsWith('medication')) return 'Medical';
    return 'Other';
  }
}