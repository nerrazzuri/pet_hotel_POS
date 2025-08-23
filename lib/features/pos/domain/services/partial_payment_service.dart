import 'package:cat_hotel_pos/features/pos/domain/entities/pos_cart.dart';

import 'package:cat_hotel_pos/features/pos/domain/entities/partial_payment.dart';

class PartialPaymentService {
  /// Add a partial payment to the cart
  static PartialPaymentResult addPartialPayment(
    POSCart cart,
    String paymentMethod,
    double amount,
    String paidBy, {
    String? reference,
    String? notes,
  }) {
    // Validate payment amount
    if (amount <= 0) {
      return PartialPaymentResult(
        success: false,
        errorMessage: 'Payment amount must be greater than zero',
      );
    }

    // Check if payment exceeds remaining balance
    double currentTotal = cart.totalAmount ?? 0.0;
    double currentAmountPaid = cart.amountPaid ?? 0.0;
    double remainingBalance = currentTotal - currentAmountPaid;

    if (amount > remainingBalance) {
      return PartialPaymentResult(
        success: false,
        errorMessage: 'Payment amount exceeds remaining balance',
      );
    }

    // Create partial payment record
    final partialPayment = PartialPayment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      paymentMethod: paymentMethod,
      amount: amount,
      paidAt: DateTime.now(),
      paidBy: paidBy,
      reference: reference,
      notes: notes,
    );

    // Calculate new totals
    double newAmountPaid = currentAmountPaid + amount;
    double newRemainingBalance = remainingBalance - amount;
    double newChangeAmount = newAmountPaid > currentTotal ? newAmountPaid - currentTotal : 0.0;

    // Determine new cart status
    String newStatus = 'active';
    if (newRemainingBalance <= 0) {
      newStatus = 'completed';
    } else if (newAmountPaid > 0) {
      newStatus = 'partial';
    }

    // Update cart data
    final updatedCartData = {
      'amountPaid': newAmountPaid,
      'remainingBalance': newRemainingBalance > 0 ? newRemainingBalance : 0.0,
      'changeAmount': newChangeAmount,
      'status': newStatus,
      'partialPayments': [...(cart.partialPayments ?? []), partialPayment],
    };

    return PartialPaymentResult(
      success: true,
      partialPayment: partialPayment,
      updatedCartData: updatedCartData,
    );
  }

  /// Split bill into multiple payments
  static BillSplitResult splitBill(
    POSCart cart,
    List<BillSplitItem> splitItems,
  ) {
    // Validate split items
    double totalSplitAmount = splitItems.fold(0.0, (sum, item) => sum + item.amount);
    double cartTotal = cart.totalAmount ?? 0.0;

    if ((totalSplitAmount - cartTotal).abs() > 0.01) {
      return BillSplitResult(
        success: false,
        errorMessage: 'Split amounts must equal cart total',
      );
    }

    // Create partial payments for each split
    List<PartialPayment> partialPayments = [];
    for (final splitItem in splitItems) {
      final partialPayment = PartialPayment(
        id: DateTime.now().millisecondsSinceEpoch.toString() + '_${splitItem.id}',
        paymentMethod: splitItem.paymentMethod,
        amount: splitItem.amount,
        paidAt: DateTime.now(),
        paidBy: splitItem.paidBy,
        reference: splitItem.reference,
        notes: splitItem.notes,
      );
      partialPayments.add(partialPayment);
    }

    // Update cart data
    final updatedCartData = {
      'amountPaid': cartTotal,
      'remainingBalance': 0.0,
      'changeAmount': 0.0,
      'status': 'completed',
      'partialPayments': partialPayments,
    };

    return BillSplitResult(
      success: true,
      partialPayments: partialPayments,
      updatedCartData: updatedCartData,
    );
  }

  /// Calculate payment summary for cart
  static PaymentSummary calculatePaymentSummary(POSCart cart) {
    double totalAmount = cart.totalAmount ?? 0.0;
    double amountPaid = cart.amountPaid ?? 0.0;
    double remainingBalance = totalAmount - amountPaid;
    double changeAmount = cart.changeAmount ?? 0.0;

    // Group payments by method
    Map<String, double> paymentsByMethod = {};
    if (cart.partialPayments != null) {
      for (final payment in cart.partialPayments!) {
        paymentsByMethod[payment.paymentMethod] = 
            (paymentsByMethod[payment.paymentMethod] ?? 0.0) + payment.amount;
      }
    }

    // Add any single payment method amount
    if (cart.paymentMethod != null && cart.amountPaid != null) {
      paymentsByMethod[cart.paymentMethod!] = 
          (paymentsByMethod[cart.paymentMethod!] ?? 0.0) + cart.amountPaid!;
    }

    return PaymentSummary(
      totalAmount: totalAmount,
      amountPaid: amountPaid,
      remainingBalance: remainingBalance,
      changeAmount: changeAmount,
      paymentsByMethod: paymentsByMethod,
      isFullyPaid: remainingBalance <= 0,
      isPartiallyPaid: amountPaid > 0 && remainingBalance > 0,
    );
  }

  /// Validate if cart can be completed
  static bool canCompleteCart(POSCart cart) {
    double totalAmount = cart.totalAmount ?? 0.0;
    double amountPaid = cart.amountPaid ?? 0.0;
    return amountPaid >= totalAmount;
  }

  /// Get payment methods used in cart
  static List<String> getPaymentMethodsUsed(POSCart cart) {
    Set<String> methods = {};
    
    if (cart.paymentMethod != null) {
      methods.add(cart.paymentMethod!);
    }
    
    if (cart.partialPayments != null) {
      for (final payment in cart.partialPayments!) {
        methods.add(payment.paymentMethod);
      }
    }
    
    return methods.toList();
  }

  /// Calculate total paid by specific payment method
  static double getTotalPaidByMethod(POSCart cart, String paymentMethod) {
    double total = 0.0;
    
    if (cart.paymentMethod == paymentMethod && cart.amountPaid != null) {
      total += cart.amountPaid!;
    }
    
    if (cart.partialPayments != null) {
      for (final payment in cart.partialPayments!) {
        if (payment.paymentMethod == paymentMethod) {
          total += payment.amount;
        }
      }
    }
    
    return total;
  }
}

class PartialPaymentResult {
  final bool success;
  final PartialPayment? partialPayment;
  final Map<String, dynamic>? updatedCartData;
  final String? errorMessage;

  PartialPaymentResult({
    required this.success,
    this.partialPayment,
    this.updatedCartData,
    this.errorMessage,
  });
}

class BillSplitItem {
  final String id;
  final String paymentMethod;
  final double amount;
  final String paidBy;
  final String? reference;
  final String? notes;

  BillSplitItem({
    required this.id,
    required this.paymentMethod,
    required this.amount,
    required this.paidBy,
    this.reference,
    this.notes,
  });
}

class BillSplitResult {
  final bool success;
  final List<PartialPayment>? partialPayments;
  final Map<String, dynamic>? updatedCartData;
  final String? errorMessage;

  BillSplitResult({
    required this.success,
    this.partialPayments,
    this.updatedCartData,
    this.errorMessage,
  });
}

class PaymentSummary {
  final double totalAmount;
  final double amountPaid;
  final double remainingBalance;
  final double changeAmount;
  final Map<String, double> paymentsByMethod;
  final bool isFullyPaid;
  final bool isPartiallyPaid;

  PaymentSummary({
    required this.totalAmount,
    required this.amountPaid,
    required this.remainingBalance,
    required this.changeAmount,
    required this.paymentsByMethod,
    required this.isFullyPaid,
    required this.isPartiallyPaid,
  });
}
