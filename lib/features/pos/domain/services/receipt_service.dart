
import 'package:cat_hotel_pos/features/pos/domain/entities/pos_transaction.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/receipt_reprint.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/invoice_resend.dart';

class ReceiptService {
  static const String companyName = 'Cat Hotel & Pet Services';
  static const String companyAddress = '123 Pet Street, Kuala Lumpur, Malaysia';
  static const String companyPhone = '+60 3-1234 5678';
  static const String companyEmail = 'info@cathotel.com';
  static const String taxRegistrationNumber = 'MY123456789';

  /// Generate receipt content for printing
  static String generateReceiptContent(POSTransaction transaction) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('${'=' * 40}');
    buffer.writeln('${companyName.toUpperCase()}');
    buffer.writeln(companyAddress);
    buffer.writeln('Phone: $companyPhone');
    buffer.writeln('Email: $companyEmail');
    buffer.writeln('${'=' * 40}');
    
    // Receipt details
    buffer.writeln('Receipt #: ${transaction.receiptNumber ?? 'N/A'}');
    buffer.writeln('Date: ${_formatDateTime(transaction.completedAt)}');
    buffer.writeln('Cashier: ${transaction.cashierName ?? 'N/A'}');
    buffer.writeln('Customer: ${transaction.customerName ?? 'Walk-in Customer'}');
    if (transaction.customerPhone != null) {
      buffer.writeln('Phone: ${transaction.customerPhone}');
    }
    buffer.writeln('${'=' * 40}');
    
    // Items
    buffer.writeln('ITEMS:');
    buffer.writeln('${'=' * 40}');
    for (final item in transaction.items) {
      buffer.writeln('${item.name}');
      buffer.writeln('  ${item.quantity} x RM${item.price.toStringAsFixed(2)} = RM${(item.quantity * item.price).toStringAsFixed(2)}');
      if (item.notes != null && item.notes!.isNotEmpty) {
        buffer.writeln('  Note: ${item.notes}');
      }
    }
    buffer.writeln('${'=' * 40}');
    
    // Totals
    buffer.writeln('Subtotal: RM${transaction.subtotal?.toStringAsFixed(2) ?? '0.00'}');
    if (transaction.discountAmount != null && transaction.discountAmount! > 0) {
      buffer.writeln('Discount: -RM${transaction.discountAmount!.toStringAsFixed(2)}');
    }
    if (transaction.sstAmount != null && transaction.sstAmount! > 0) {
      buffer.writeln('SST (${transaction.sstRate?.toStringAsFixed(1) ?? '10.0'}%): RM${transaction.sstAmount!.toStringAsFixed(2)}');
    }
    buffer.writeln('TOTAL: RM${transaction.totalAmount.toStringAsFixed(2)}');
    buffer.writeln('${'=' * 40}');
    
    // Payment details
    buffer.writeln('PAYMENT:');
    buffer.writeln('Method: ${_formatPaymentMethod(transaction.paymentMethod)}');
    buffer.writeln('Amount Paid: RM${transaction.amountPaid?.toStringAsFixed(2) ?? '0.00'}');
    if (transaction.changeAmount != null && transaction.changeAmount! > 0) {
      buffer.writeln('Change: RM${transaction.changeAmount!.toStringAsFixed(2)}');
    }
    
    // Partial payments if any
    if (transaction.partialPayments != null && transaction.partialPayments!.isNotEmpty) {
      buffer.writeln('${'=' * 40}');
      buffer.writeln('PARTIAL PAYMENTS:');
      for (final payment in transaction.partialPayments!) {
        buffer.writeln('${_formatPaymentMethod(payment.paymentMethod)}: RM${payment.amount.toStringAsFixed(2)}');
      }
    }
    
    // Vouchers if any
    if (transaction.appliedVouchers != null && transaction.appliedVouchers!.isNotEmpty) {
      buffer.writeln('${'=' * 40}');
      buffer.writeln('VOUCHERS APPLIED:');
      for (final voucher in transaction.appliedVouchers!) {
        buffer.writeln('${voucher.code}: -RM${voucher.value.toStringAsFixed(2)}');
      }
    }
    
    // Footer
    buffer.writeln('${'=' * 40}');
    buffer.writeln('Thank you for choosing $companyName!');
    buffer.writeln('Please keep this receipt for your records.');
    buffer.writeln('${'=' * 40}');
    
    return buffer.toString();
  }

  /// Generate invoice content for email/WhatsApp
  static String generateInvoiceContent(POSTransaction transaction) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('INVOICE');
    buffer.writeln('${'=' * 50}');
    buffer.writeln('${companyName.toUpperCase()}');
    buffer.writeln(companyAddress);
    buffer.writeln('Phone: $companyPhone');
    buffer.writeln('Email: $companyEmail');
    buffer.writeln('Tax Reg No: $taxRegistrationNumber');
    buffer.writeln('${'=' * 50}');
    
    // Invoice details
    buffer.writeln('Invoice #: ${transaction.invoiceNumber ?? 'N/A'}');
    buffer.writeln('Date: ${_formatDateTime(transaction.completedAt)}');
    buffer.writeln('Due Date: ${_formatDateTime(transaction.completedAt)}');
    buffer.writeln('${'=' * 50}');
    
    // Customer details
    buffer.writeln('BILL TO:');
    buffer.writeln('${transaction.customerName ?? 'Walk-in Customer'}');
    if (transaction.customerPhone != null) {
      buffer.writeln('Phone: ${transaction.customerPhone}');
    }
    if (transaction.customerEmail != null) {
      buffer.writeln('Email: ${transaction.customerEmail}');
    }
    buffer.writeln('${'=' * 50}');
    
    // Items table
    buffer.writeln('DESCRIPTION\t\tQTY\tRATE\t\tAMOUNT');
    buffer.writeln('${'=' * 50}');
    for (final item in transaction.items) {
      final itemTotal = item.quantity * item.price;
      buffer.writeln('${item.name}\t\t${item.quantity}\tRM${item.price.toStringAsFixed(2)}\t\tRM${itemTotal.toStringAsFixed(2)}');
      if (item.notes != null && item.notes!.isNotEmpty) {
        buffer.writeln('  Note: ${item.notes}');
      }
    }
    buffer.writeln('${'=' * 50}');
    
    // Totals
    buffer.writeln('Subtotal:\t\t\t\t\tRM${transaction.subtotal?.toStringAsFixed(2) ?? '0.00'}');
    if (transaction.discountAmount != null && transaction.discountAmount! > 0) {
      buffer.writeln('Discount:\t\t\t\t\t-RM${transaction.discountAmount!.toStringAsFixed(2)}');
    }
    if (transaction.sstAmount != null && transaction.sstAmount! > 0) {
      buffer.writeln('SST (${transaction.sstRate?.toStringAsFixed(1) ?? '10.0'}%):\t\t\t\t\tRM${transaction.sstAmount!.toStringAsFixed(2)}');
    }
    buffer.writeln('TOTAL:\t\t\t\t\t\tRM${transaction.totalAmount.toStringAsFixed(2)}');
    buffer.writeln('${'=' * 50}');
    
    // Payment details
    buffer.writeln('PAYMENT STATUS: PAID');
    buffer.writeln('Payment Method: ${_formatPaymentMethod(transaction.paymentMethod)}');
    buffer.writeln('Amount Paid: RM${transaction.amountPaid?.toStringAsFixed(2) ?? '0.00'}');
    
    // Terms and conditions
    buffer.writeln('${'=' * 50}');
    buffer.writeln('TERMS & CONDITIONS:');
    buffer.writeln('• Payment is due upon receipt');
    buffer.writeln('• Late payments may incur additional charges');
    buffer.writeln('• All prices include applicable taxes');
    buffer.writeln('• Please contact us for any questions');
    
    return buffer.toString();
  }

  /// Create receipt reprint record
  static ReceiptReprint createReceiptReprint(
    String reprintedBy, {
    String? reason,
    String? notes,
  }) {
    return ReceiptReprint(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      reprintedAt: DateTime.now(),
      reprintedBy: reprintedBy,
      reason: reason,
      notes: notes,
    );
  }

  /// Create invoice resend record
  static InvoiceResend createInvoiceResend(
    String resentBy,
    String method, {
    String? reason,
    String? notes,
  }) {
    return InvoiceResend(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      resentAt: DateTime.now(),
      resentBy: resentBy,
      method: method,
      reason: reason,
      notes: notes,
    );
  }

  /// Generate receipt number
  static String generateReceiptNumber() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final timestamp = now.millisecondsSinceEpoch.toString().substring(8);
    return 'R$year$month$day$timestamp';
  }

  /// Generate invoice number
  static String generateInvoiceNumber() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final timestamp = now.millisecondsSinceEpoch.toString().substring(8);
    return 'INV$year$month$day$timestamp';
  }

  /// Format date and time for receipt/invoice
  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Format payment method for display
  static String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'Cash';
      case 'card':
        return 'Credit/Debit Card';
      case 'e_wallet':
        return 'E-Wallet';
      case 'bank_transfer':
        return 'Bank Transfer';
      case 'duitnow':
        return 'DuitNow';
      case 'tng':
        return 'Touch n Go';
      case 'fpx':
        return 'FPX';
      default:
        return method.replaceAll('_', ' ').toUpperCase();
    }
  }

  /// Send receipt via email (placeholder for actual email service)
  static Future<bool> sendReceiptByEmail(
    POSTransaction transaction,
    String emailAddress,
  ) async {
    // This would integrate with an actual email service
    // For now, just return success
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  /// Send receipt via WhatsApp (placeholder for actual WhatsApp service)
  static Future<bool> sendReceiptByWhatsApp(
    POSTransaction transaction,
    String phoneNumber,
  ) async {
    // This would integrate with WhatsApp Business API
    // For now, just return success
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  /// Print receipt (placeholder for actual printer service)
  static Future<bool> printReceipt(String receiptContent) async {
    // This would integrate with actual receipt printer
    // For now, just return success
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }
}
