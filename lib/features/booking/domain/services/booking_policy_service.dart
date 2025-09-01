import 'package:uuid/uuid.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking_policy.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:cat_hotel_pos/core/services/booking_policy_dao.dart';
import 'package:cat_hotel_pos/core/services/booking_dao.dart';

class BookingPolicyService {
  final BookingPolicyDao _policyDao;
  final BookingDao _bookingDao;

  BookingPolicyService({
    required BookingPolicyDao policyDao,
    required BookingDao bookingDao,
  })  : _policyDao = policyDao,
        _bookingDao = bookingDao;

  // Create a new booking policy
  Future<BookingPolicy> createPolicy({
    required String name,
    required PolicyType type,
    required String description,
    int? maxOverbookingPercentage,
    List<String>? overbookingAllowedRoomTypes,
    double? lateCheckoutFeePerHour,
    int? gracePeriodMinutes,
    TimeOfDay? standardCheckoutTime,
    double? noShowFeePercentage,
    int? noShowGracePeriodHours,
    double? cancellationFeePercentage,
    int? freeCancellationHours,
    double? depositPercentage,
    double? minimumDepositAmount,
    double? refundPercentage,
    int? refundProcessingDays,
    Map<String, dynamic>? conditions,
  }) async {
    final policy = BookingPolicy(
      id: const Uuid().v4(),
      name: name,
      type: type,
      description: description,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      maxOverbookingPercentage: maxOverbookingPercentage,
      overbookingAllowedRoomTypes: overbookingAllowedRoomTypes,
      lateCheckoutFeePerHour: lateCheckoutFeePerHour,
      gracePeriodMinutes: gracePeriodMinutes,
      standardCheckoutTime: standardCheckoutTime,
      noShowFeePercentage: noShowFeePercentage,
      noShowGracePeriodHours: noShowGracePeriodHours,
      cancellationFeePercentage: cancellationFeePercentage,
      freeCancellationHours: freeCancellationHours,
      depositPercentage: depositPercentage,
      minimumDepositAmount: minimumDepositAmount,
      refundPercentage: refundPercentage,
      refundProcessingDays: refundProcessingDays,
      conditions: conditions,
    );

    await _policyDao.insert(policy);
    return policy;
  }

  // Calculate late checkout fee
  Future<double> calculateLateCheckoutFee(Booking booking, DateTime actualCheckoutTime) async {
    final policy = await _policyDao.getByType(PolicyType.lateCheckout);
    if (policy == null) return 0.0;

    final standardCheckout = policy.standardCheckoutTime ?? const TimeOfDay(hour: 11, minute: 0);
    final gracePeriod = policy.gracePeriodMinutes ?? 15;
    final feePerHour = policy.lateCheckoutFeePerHour ?? 25.0;

    final standardCheckoutDateTime = DateTime(
      actualCheckoutTime.year,
      actualCheckoutTime.month,
      actualCheckoutTime.day,
      standardCheckout.hour,
      standardCheckout.minute,
    );

    final gracePeriodEnd = standardCheckoutDateTime.add(Duration(minutes: gracePeriod));

    if (actualCheckoutTime.isBefore(gracePeriodEnd)) {
      return 0.0;
    }

    final lateMinutes = actualCheckoutTime.difference(gracePeriodEnd).inMinutes;
    final lateHours = (lateMinutes / 60.0).ceil();
    
    return lateHours * feePerHour;
  }

  // Calculate no-show fee
  Future<double> calculateNoShowFee(Booking booking) async {
    final policy = await _policyDao.getByType(PolicyType.noShow);
    if (policy == null) return 0.0;

    final feePercentage = policy.noShowFeePercentage ?? 50.0;
    return (booking.totalAmount * feePercentage) / 100.0;
  }

  // Calculate cancellation fee
  Future<double> calculateCancellationFee(Booking booking, DateTime cancellationTime) async {
    final policy = await _policyDao.getByType(PolicyType.cancellation);
    if (policy == null) return 0.0;

    final freeCancellationHours = policy.freeCancellationHours ?? 24;
    final feePercentage = policy.cancellationFeePercentage ?? 25.0;

    final checkInTime = DateTime(
      booking.checkInDate.year,
      booking.checkInDate.month,
      booking.checkInDate.day,
      booking.checkInTime.hour,
      booking.checkInTime.minute,
    );

    final hoursUntilCheckIn = checkInTime.difference(cancellationTime).inHours;

    if (hoursUntilCheckIn >= freeCancellationHours) {
      return 0.0;
    }

    return (booking.totalAmount * feePercentage) / 100.0;
  }

  // Calculate required deposit
  Future<double> calculateRequiredDeposit(double totalAmount) async {
    final policy = await _policyDao.getByType(PolicyType.deposit);
    if (policy == null) return 0.0;

    final depositPercentage = policy.depositPercentage ?? 20.0;
    final minimumDeposit = policy.minimumDepositAmount ?? 50.0;

    final calculatedDeposit = (totalAmount * depositPercentage) / 100.0;
    return calculatedDeposit < minimumDeposit ? minimumDeposit : calculatedDeposit;
  }

  // Check if overbooking is allowed
  Future<bool> isOverbookingAllowed(RoomType roomType, int currentOccupancy, int totalCapacity) async {
    final policy = await _policyDao.getByType(PolicyType.overbooking);
    if (policy == null) return false;

    final allowedRoomTypes = policy.overbookingAllowedRoomTypes ?? [];
    if (!allowedRoomTypes.contains(roomType.name)) return false;

    final maxOverbookingPercentage = policy.maxOverbookingPercentage ?? 10;
    final currentPercentage = (currentOccupancy / totalCapacity) * 100;

    return currentPercentage <= (100 + maxOverbookingPercentage);
  }

  // Get overbooking statistics
  Future<Map<String, dynamic>> getOverbookingStatistics() async {
    final policy = await _policyDao.getByType(PolicyType.overbooking);
    if (policy == null) {
      return {
        'enabled': false,
        'maxPercentage': 0,
        'allowedRoomTypes': [],
      };
    }

    return {
      'enabled': true,
      'maxPercentage': policy.maxOverbookingPercentage ?? 0,
      'allowedRoomTypes': policy.overbookingAllowedRoomTypes ?? [],
    };
  }

  // Process no-show bookings
  Future<List<Booking>> processNoShows() async {
    final policy = await _policyDao.getByType(PolicyType.noShow);
    if (policy == null) return [];

    final gracePeriodHours = policy.noShowGracePeriodHours ?? 2;
    final now = DateTime.now();
    final gracePeriodEnd = now.subtract(Duration(hours: gracePeriodHours));

    final allBookings = await _bookingDao.getAll();
    final noShowBookings = allBookings.where((booking) {
      if (booking.status != BookingStatus.confirmed) return false;
      
      final checkInTime = DateTime(
        booking.checkInDate.year,
        booking.checkInDate.month,
        booking.checkInDate.day,
        booking.checkInTime.hour,
        booking.checkInTime.minute,
      );

      return checkInTime.isBefore(gracePeriodEnd);
    }).toList();

    // Update status to no-show
    for (final booking in noShowBookings) {
      final updatedBooking = booking.copyWith(
        status: BookingStatus.noShow,
        updatedAt: DateTime.now(),
      );
      await _bookingDao.update(updatedBooking);
    }

    return noShowBookings;
  }

  // Get policy summary
  Future<Map<String, dynamic>> getPolicySummary() async {
    final policies = await _policyDao.getActivePolicies();
    final summary = <String, dynamic>{};

    for (final policy in policies) {
      switch (policy.type) {
        case PolicyType.lateCheckout:
          summary['lateCheckout'] = {
            'feePerHour': policy.lateCheckoutFeePerHour ?? 0.0,
            'gracePeriodMinutes': policy.gracePeriodMinutes ?? 0,
            'standardCheckoutTime': policy.standardCheckoutTime?.toString() ?? '11:00',
          };
          break;
        case PolicyType.noShow:
          summary['noShow'] = {
            'feePercentage': policy.noShowFeePercentage ?? 0.0,
            'gracePeriodHours': policy.noShowGracePeriodHours ?? 0,
          };
          break;
        case PolicyType.cancellation:
          summary['cancellation'] = {
            'feePercentage': policy.cancellationFeePercentage ?? 0.0,
            'freeCancellationHours': policy.freeCancellationHours ?? 0,
          };
          break;
        case PolicyType.deposit:
          summary['deposit'] = {
            'percentage': policy.depositPercentage ?? 0.0,
            'minimumAmount': policy.minimumDepositAmount ?? 0.0,
          };
          break;
        case PolicyType.overbooking:
          summary['overbooking'] = {
            'maxPercentage': policy.maxOverbookingPercentage ?? 0,
            'allowedRoomTypes': policy.overbookingAllowedRoomTypes ?? [],
          };
          break;
        case PolicyType.refund:
          summary['refund'] = {
            'percentage': policy.refundPercentage ?? 0.0,
            'processingDays': policy.refundProcessingDays ?? 0,
          };
          break;
      }
    }

    return summary;
  }
}
