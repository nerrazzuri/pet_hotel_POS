import 'package:cat_hotel_pos/features/pos/domain/entities/voucher.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/cart_item.dart';

class VoucherService {
  static const double defaultSstRate = 10.0; // Malaysia SST rate

  /// Validate if a voucher can be applied to the current cart
  static VoucherValidationResult validateVoucher(
    Voucher voucher,
    List<CartItem> cartItems,
    double cartSubtotal,
    String? customerId,
  ) {
    // Check if voucher is active
    if (voucher.status != VoucherStatus.active) {
      return VoucherValidationResult(
        isValid: false,
        errorMessage: 'Voucher is not active',
      );
    }

    // Check validity period
    final now = DateTime.now();
    if (now.isBefore(voucher.validFrom) || now.isAfter(voucher.validUntil)) {
      return VoucherValidationResult(
        isValid: false,
        errorMessage: 'Voucher is expired or not yet valid',
      );
    }

    // Check usage limit
    if (voucher.currentUsage >= voucher.maxUsage) {
      return VoucherValidationResult(
        isValid: false,
        errorMessage: 'Voucher usage limit exceeded',
      );
    }

    // Check if voucher is customer-specific
    if (voucher.customerId != null && voucher.customerId != customerId) {
      return VoucherValidationResult(
        isValid: false,
        errorMessage: 'Voucher is not valid for this customer',
      );
    }

    // Check minimum purchase amount
    if (voucher.minimumPurchaseAmount != null && 
        cartSubtotal < voucher.minimumPurchaseAmount!) {
      return VoucherValidationResult(
        isValid: false,
        errorMessage: 'Minimum purchase amount not met',
      );
    }

    // Check if voucher applies to cart items
    if (voucher.applicableServices != null || voucher.applicableProducts != null) {
      bool hasApplicableItems = false;
      for (final item in cartItems) {
        if (voucher.applicableServices?.contains(item.id) == true ||
            voucher.applicableProducts?.contains(item.id) == true) {
          hasApplicableItems = true;
          break;
        }
      }
      if (!hasApplicableItems) {
        return VoucherValidationResult(
          isValid: false,
          errorMessage: 'Voucher does not apply to any items in cart',
        );
      }
    }

    return VoucherValidationResult(
      isValid: true,
      voucher: voucher,
    );
  }

  /// Calculate discount amount for a voucher
  static double calculateVoucherDiscount(Voucher voucher, double applicableAmount) {
    double discountAmount = 0.0;

    switch (voucher.type) {
      case VoucherType.discount:
        // For percentage discounts, assume value is percentage (e.g., 10.0 = 10%)
        if (voucher.value <= 100) {
          discountAmount = applicableAmount * (voucher.value / 100);
        } else {
          // For fixed amount discounts
          discountAmount = voucher.value;
        }
        break;

      case VoucherType.giftCard:
        // Gift card value is the maximum discount
        discountAmount = voucher.value;
        break;

      case VoucherType.promotional:
        // Promotional codes can have various discount types
        if (voucher.value <= 100) {
          discountAmount = applicableAmount * (voucher.value / 100);
        } else {
          discountAmount = voucher.value;
        }
        break;

      case VoucherType.loyalty:
        // Loyalty points redemption (convert points to currency)
        discountAmount = voucher.value;
        break;
    }

    // Apply maximum discount limit if specified
    if (voucher.maximumDiscountAmount != null && 
        discountAmount > voucher.maximumDiscountAmount!) {
      discountAmount = voucher.maximumDiscountAmount!;
    }

    // Ensure discount doesn't exceed applicable amount
    if (discountAmount > applicableAmount) {
      discountAmount = applicableAmount;
    }

    return discountAmount;
  }

  /// Apply voucher to cart and return updated cart data
  static Map<String, dynamic> applyVoucherToCart(
    Voucher voucher,
    List<CartItem> cartItems,
    double cartSubtotal,
    double existingDiscount,
  ) {
    // Calculate applicable amount (exclude already discounted items)
    double applicableAmount = cartSubtotal - existingDiscount;
    
    // Calculate voucher discount
    double voucherDiscount = calculateVoucherDiscount(voucher, applicableAmount);
    
    // Calculate new totals
    double newDiscountTotal = existingDiscount + voucherDiscount;
    double newSubtotal = cartSubtotal;
    double newTotal = newSubtotal - newDiscountTotal;
    
    // Calculate SST (Malaysia tax)
    double sstAmount = newTotal * (defaultSstRate / 100);
    double finalTotal = newTotal + sstAmount;

    return {
      'voucherDiscount': voucherDiscount,
      'totalDiscount': newDiscountTotal,
      'subtotal': newSubtotal,
      'totalBeforeTax': newTotal,
      'sstRate': defaultSstRate,
      'sstAmount': sstAmount,
      'finalTotal': finalTotal,
    };
  }

  /// Create voucher usage record
  static VoucherUsage createVoucherUsage(
    Voucher voucher,
    String transactionId,
    double discountAmount,
    String usedBy, {
    String? customerId,
    String? customerName,
  }) {
    return VoucherUsage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      voucherId: voucher.id,
      voucherCode: voucher.code,
      transactionId: transactionId,
      discountAmount: discountAmount,
      usedAt: DateTime.now(),
      usedBy: usedBy,
      customerId: customerId,
      customerName: customerName,
    );
  }
}

class VoucherValidationResult {
  final bool isValid;
  final Voucher? voucher;
  final String? errorMessage;

  VoucherValidationResult({
    required this.isValid,
    this.voucher,
    this.errorMessage,
  });
}
