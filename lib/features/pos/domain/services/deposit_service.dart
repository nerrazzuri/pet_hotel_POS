import 'package:cat_hotel_pos/features/pos/domain/entities/deposit.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/pos_cart.dart';

class DepositService {
  /// Validate if a deposit can be created
  static DepositValidationResult validateDeposit(
    DepositType type,
    double amount,
    String paymentMethod,
    String customerId,
    String customerName,
    String customerPhone,
  ) {
    // Basic validation
    if (amount <= 0) {
      return DepositValidationResult(
        isValid: false,
        errorMessage: 'Deposit amount must be greater than zero',
      );
    }

    if (customerId.isEmpty || customerName.isEmpty || customerPhone.isEmpty) {
      return DepositValidationResult(
        isValid: false,
        errorMessage: 'Customer information is required',
      );
    }

    if (paymentMethod.isEmpty) {
      return DepositValidationResult(
        isValid: false,
        errorMessage: 'Payment method is required',
      );
    }

    // Type-specific validation
    switch (type) {
      case DepositType.advance:
        if (amount < 10.0) {
          return DepositValidationResult(
            isValid: false,
            errorMessage: 'Advance payment must be at least RM 10.00',
          );
        }
        break;

      case DepositType.security:
        if (amount < 50.0) {
          return DepositValidationResult(
            isValid: false,
            errorMessage: 'Security deposit must be at least RM 50.00',
          );
        }
        break;

      case DepositType.preAuth:
        // Pre-authorization amounts can vary
        break;

      case DepositType.giftCard:
        if (amount < 5.0) {
          return DepositValidationResult(
            isValid: false,
            errorMessage: 'Gift card minimum amount is RM 5.00',
          );
        }
        break;

      case DepositType.storeCredit:
        // Store credit is typically created from refunds or adjustments
        break;
    }

    return DepositValidationResult(
      isValid: true,
    );
  }

  /// Create a new deposit
  static Deposit createDeposit({
    required String customerId,
    required String customerName,
    required String customerPhone,
    required DepositType type,
    required double amount,
    required String paymentMethod,
    required String processedBy,
    String? description,
    String? reference,
  }) {
    return Deposit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
      type: type,
      status: DepositStatus.pending,
      amount: amount,
      paymentMethod: paymentMethod,
      createdAt: DateTime.now(),
      description: description,
      reference: reference,
      processedBy: processedBy,
    );
  }

  /// Confirm a deposit (mark as confirmed)
  static Deposit confirmDeposit(Deposit deposit) {
    return deposit.copyWith(
      status: DepositStatus.confirmed,
      confirmedAt: DateTime.now(),
    );
  }

  /// Apply deposit to cart
  static DepositApplicationResult applyDepositToCart(
    Deposit deposit,
    POSCart cart,
    double amountToApply,
  ) {
    // Validate deposit can be applied
    if (deposit.status != DepositStatus.confirmed) {
      return DepositApplicationResult(
        success: false,
        errorMessage: 'Deposit must be confirmed before applying',
      );
    }

    if (amountToApply <= 0) {
      return DepositApplicationResult(
        success: false,
        errorMessage: 'Amount to apply must be greater than zero',
      );
    }

    if (amountToApply > deposit.amount) {
      return DepositApplicationResult(
        success: false,
        errorMessage: 'Cannot apply more than available deposit amount',
      );
    }

    // Calculate new cart totals
    double currentTotal = cart.totalAmount ?? 0.0;
    double newAmountPaid = (cart.amountPaid ?? 0.0) + amountToApply;
    double newRemainingBalance = currentTotal - newAmountPaid;
    double newChangeAmount = newAmountPaid > currentTotal ? newAmountPaid - currentTotal : 0.0;

    // Determine new cart status
    String newStatus = 'active';
    if (newRemainingBalance <= 0) {
      newStatus = 'completed';
    } else if (newAmountPaid > 0) {
      newStatus = 'partial';
    }

    // Create deposit application record
    final depositApplication = DepositApplication(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      depositId: deposit.id,
      transactionId: cart.id,
      amountApplied: amountToApply,
      appliedAt: DateTime.now(),
      appliedBy: cart.cashierId ?? 'system',
    );

    // Update deposit status
    final updatedDeposit = deposit.copyWith(
      status: newRemainingBalance <= 0 ? DepositStatus.applied : DepositStatus.applied,
      appliedAt: DateTime.now(),
      appliedToTransactionId: cart.id,
    );

    return DepositApplicationResult(
      success: true,
      depositApplication: depositApplication,
      updatedDeposit: updatedDeposit,
      newCartData: {
        'amountPaid': newAmountPaid,
        'remainingBalance': newRemainingBalance > 0 ? newRemainingBalance : 0.0,
        'changeAmount': newChangeAmount,
        'status': newStatus,
        'appliedDeposits': [...(cart.appliedDeposits ?? []), updatedDeposit],
        'depositAmountTotal': (cart.depositAmountTotal ?? 0.0) + amountToApply,
      },
    );
  }

  /// Refund a deposit
  static Deposit refundDeposit(
    Deposit deposit,
    String refundReason,
    String refundedBy,
  ) {
    return deposit.copyWith(
      status: DepositStatus.refunded,
      refundedAt: DateTime.now(),
      refundReason: refundReason,
    );
  }

  /// Cancel a deposit
  static Deposit cancelDeposit(
    Deposit deposit,
    String cancelledReason,
    String cancelledBy,
  ) {
    return deposit.copyWith(
      status: DepositStatus.cancelled,
      cancelledAt: DateTime.now(),
      cancelledReason: cancelledReason,
    );
  }

  /// Get available deposits for a customer
  static List<Deposit> getAvailableDeposits(List<Deposit> deposits) {
    return deposits.where((deposit) => 
      deposit.status == DepositStatus.confirmed && 
      deposit.amount > 0
    ).toList();
  }

  /// Calculate total available deposit amount for a customer
  static double calculateTotalAvailableDeposits(List<Deposit> deposits) {
    return getAvailableDeposits(deposits)
        .fold(0.0, (sum, deposit) => sum + deposit.amount);
  }
}

class DepositValidationResult {
  final bool isValid;
  final String? errorMessage;

  DepositValidationResult({
    required this.isValid,
    this.errorMessage,
  });
}

class DepositApplicationResult {
  final bool success;
  final DepositApplication? depositApplication;
  final Deposit? updatedDeposit;
  final Map<String, dynamic>? newCartData;
  final String? errorMessage;

  DepositApplicationResult({
    required this.success,
    this.depositApplication,
    this.updatedDeposit,
    this.newCartData,
    this.errorMessage,
  });
}
