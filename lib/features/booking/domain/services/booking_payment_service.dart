import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/payment.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/transaction.dart';
import 'package:cat_hotel_pos/core/services/booking_dao.dart';
import 'package:cat_hotel_pos/core/services/payment_dao.dart';
import 'package:cat_hotel_pos/core/services/transaction_dao.dart';

class BookingPaymentService {
  final BookingDao _bookingDao;
  final PaymentDao _paymentDao;
  final TransactionDao _transactionDao;

  BookingPaymentService({
    required BookingDao bookingDao,
    required PaymentDao paymentDao,
    required TransactionDao transactionDao,
  }) : _bookingDao = bookingDao,
       _paymentDao = paymentDao,
       _transactionDao = transactionDao;

  /// Process payment for a booking
  Future<Payment> processBookingPayment({
    required String bookingId,
    required double amount,
    required PaymentMethod paymentMethod,
    required String customerName,
    String? notes,
    String? processedBy,
  }) async {
    final booking = await _bookingDao.getById(bookingId);
    if (booking == null) {
      throw ArgumentError('Booking not found');
    }

    // Check if payment is already processed
    final existingPayments = await _paymentDao.getPaymentsByBookingId(bookingId);
    if (existingPayments.isNotEmpty) {
      throw ArgumentError('Payment already processed for this booking');
    }

    // Create payment record
    final payment = Payment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookingId: bookingId,
      amount: amount,
      paymentMethod: paymentMethod,
      status: PaymentStatus.completed,
      customerName: customerName,
      notes: notes ?? 'Booking payment for ${booking.bookingNumber}',
      processedBy: processedBy,
      processedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _paymentDao.create(payment);

    // Create POS transaction
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.sale,
      amount: amount,
      paymentMethod: paymentMethod,
      status: TransactionStatus.completed,
      customerName: customerName,
      items: [
        TransactionItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Booking - ${booking.bookingNumber}',
          quantity: 1,
          unitPrice: amount,
          totalPrice: amount,
          category: 'Booking',
        ),
      ],
      subtotal: amount,
      tax: 0.0,
      discount: 0.0,
      total: amount,
      notes: 'Booking payment: ${booking.bookingNumber}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _transactionDao.create(transaction);

    // Update booking payment status
    final updatedBooking = booking.copyWith(
      paymentStatus: BookingPaymentStatus.paid.name,
      updatedAt: DateTime.now(),
    );

    await _bookingDao.update(updatedBooking);

    return payment;
  }

  /// Process deposit payment for a booking
  Future<Payment> processBookingDeposit({
    required String bookingId,
    required double depositAmount,
    required PaymentMethod paymentMethod,
    required String customerName,
    String? notes,
    String? processedBy,
  }) async {
    final booking = await _bookingDao.getById(bookingId);
    if (booking == null) {
      throw ArgumentError('Booking not found');
    }

    // Check if deposit is already paid
    if (booking.depositAmount != null && booking.depositAmount! > 0) {
      final existingDeposits = await _paymentDao.getDepositsByBookingId(bookingId);
      if (existingDeposits.isNotEmpty) {
        throw ArgumentError('Deposit already processed for this booking');
      }
    }

    // Create deposit payment record
    final payment = Payment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookingId: bookingId,
      amount: depositAmount,
      paymentMethod: paymentMethod,
      status: PaymentStatus.completed,
      paymentType: PaymentType.deposit,
      customerName: customerName,
      notes: notes ?? 'Deposit payment for ${booking.bookingNumber}',
      processedBy: processedBy,
      processedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _paymentDao.create(payment);

    // Create POS transaction for deposit
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.sale,
      amount: depositAmount,
      paymentMethod: paymentMethod,
      status: TransactionStatus.completed,
      customerName: customerName,
      items: [
        TransactionItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Deposit - ${booking.bookingNumber}',
          quantity: 1,
          unitPrice: depositAmount,
          totalPrice: depositAmount,
          category: 'Booking Deposit',
        ),
      ],
      subtotal: depositAmount,
      tax: 0.0,
      discount: 0.0,
      total: depositAmount,
      notes: 'Booking deposit: ${booking.bookingNumber}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _transactionDao.create(transaction);

    // Update booking with deposit amount
    final updatedBooking = booking.copyWith(
      depositAmount: depositAmount,
      paymentStatus: BookingPaymentStatus.depositPaid.name,
      updatedAt: DateTime.now(),
    );

    await _bookingDao.update(updatedBooking);

    return payment;
  }

  /// Process remaining balance payment
  Future<Payment> processRemainingBalance({
    required String bookingId,
    required PaymentMethod paymentMethod,
    required String customerName,
    String? notes,
    String? processedBy,
  }) async {
    final booking = await _bookingDao.getById(bookingId);
    if (booking == null) {
      throw ArgumentError('Booking not found');
    }

    // Calculate remaining balance
    final totalAmount = booking.totalAmount;
    final depositAmount = booking.depositAmount ?? 0.0;
    final remainingBalance = totalAmount - depositAmount;

    if (remainingBalance <= 0) {
      throw ArgumentError('No remaining balance to pay');
    }

    // Check if remaining balance is already paid
    final existingPayments = await _paymentDao.getPaymentsByBookingId(bookingId);
    final totalPaid = existingPayments.fold(0.0, (sum, payment) => sum + payment.amount);
    
    if (totalPaid >= totalAmount) {
      throw ArgumentError('Booking is already fully paid');
    }

    // Create remaining balance payment
    final payment = Payment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookingId: bookingId,
      amount: remainingBalance,
      paymentMethod: paymentMethod,
      status: PaymentStatus.completed,
      paymentType: PaymentType.balance,
      customerName: customerName,
      notes: notes ?? 'Remaining balance payment for ${booking.bookingNumber}',
      processedBy: processedBy,
      processedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _paymentDao.create(payment);

    // Create POS transaction for remaining balance
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.sale,
      amount: remainingBalance,
      paymentMethod: paymentMethod,
      status: TransactionStatus.completed,
      customerName: customerName,
      items: [
        TransactionItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Remaining Balance - ${booking.bookingNumber}',
          quantity: 1,
          unitPrice: remainingBalance,
          totalPrice: remainingBalance,
          category: 'Booking Balance',
        ),
      ],
      subtotal: remainingBalance,
      tax: 0.0,
      discount: 0.0,
      total: remainingBalance,
      notes: 'Remaining balance payment: ${booking.bookingNumber}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _transactionDao.create(transaction);

    // Update booking payment status
    final updatedBooking = booking.copyWith(
      paymentStatus: BookingPaymentStatus.paid.name,
      updatedAt: DateTime.now(),
    );

    await _bookingDao.update(updatedBooking);

    return payment;
  }

  /// Process refund for a booking
  Future<Payment> processBookingRefund({
    required String bookingId,
    required double refundAmount,
    required String reason,
    required String customerName,
    String? notes,
    String? processedBy,
  }) async {
    final booking = await _bookingDao.getById(bookingId);
    if (booking == null) {
      throw ArgumentError('Booking not found');
    }

    // Check if refund amount is valid
    final totalPaid = await getTotalPaidAmount(bookingId);
    if (refundAmount > totalPaid) {
      throw ArgumentError('Refund amount cannot exceed total paid amount');
    }

    // Create refund payment record
    final payment = Payment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookingId: bookingId,
      amount: -refundAmount, // Negative amount for refund
      paymentMethod: PaymentMethod.refund,
      status: PaymentStatus.completed,
      paymentType: PaymentType.refund,
      customerName: customerName,
      notes: notes ?? 'Refund for ${booking.bookingNumber}: $reason',
      processedBy: processedBy,
      processedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _paymentDao.create(payment);

    // Create POS transaction for refund
    final transaction = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: TransactionType.refund,
      amount: refundAmount,
      paymentMethod: PaymentMethod.refund,
      status: TransactionStatus.completed,
      customerName: customerName,
      items: [
        TransactionItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Refund - ${booking.bookingNumber}',
          quantity: 1,
          unitPrice: refundAmount,
          totalPrice: refundAmount,
          category: 'Booking Refund',
        ),
      ],
      subtotal: refundAmount,
      tax: 0.0,
      discount: 0.0,
      total: refundAmount,
      notes: 'Refund for booking: ${booking.bookingNumber} - $reason',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _transactionDao.create(transaction);

    // Update booking payment status
    final remainingBalance = totalPaid - refundAmount;
    final paymentStatus = remainingBalance > 0 
        ? BookingPaymentStatus.partiallyPaid.name
        : BookingPaymentStatus.refunded.name;

    final updatedBooking = booking.copyWith(
      paymentStatus: paymentStatus,
      updatedAt: DateTime.now(),
    );

    await _bookingDao.update(updatedBooking);

    return payment;
  }

  /// Get payment history for a booking
  Future<List<Payment>> getBookingPaymentHistory(String bookingId) async {
    return await _paymentDao.getPaymentsByBookingId(bookingId);
  }

  /// Get total paid amount for a booking
  Future<double> getTotalPaidAmount(String bookingId) async {
    final payments = await _paymentDao.getPaymentsByBookingId(bookingId);
    return payments.fold<double>(0.0, (sum, payment) => sum + payment.amount);
  }

  /// Get remaining balance for a booking
  Future<double> getRemainingBalance(String bookingId) async {
    final booking = await _bookingDao.getById(bookingId);
    if (booking == null) {
      throw ArgumentError('Booking not found');
    }

    final totalPaid = await getTotalPaidAmount(bookingId);
    return booking.totalAmount - totalPaid;
  }

  /// Get payment summary for a booking
  Future<BookingPaymentSummary> getBookingPaymentSummary(String bookingId) async {
    final booking = await _bookingDao.getById(bookingId);
    if (booking == null) {
      throw ArgumentError('Booking not found');
    }

    final payments = await getBookingPaymentHistory(bookingId);
    final totalPaid = await getTotalPaidAmount(bookingId);
    final remainingBalance = booking.totalAmount - totalPaid;

    return BookingPaymentSummary(
      bookingId: bookingId,
      totalAmount: booking.totalAmount,
      depositAmount: booking.depositAmount ?? 0.0,
      totalPaid: totalPaid,
      remainingBalance: remainingBalance,
      paymentStatus: _parsePaymentStatus(booking.paymentStatus),
      payments: payments,
    );
  }

  /// Parse payment status from string
  BookingPaymentStatus _parsePaymentStatus(String? status) {
    if (status == null) return BookingPaymentStatus.pending;
    
    switch (status.toLowerCase()) {
      case 'pending':
        return BookingPaymentStatus.pending;
      case 'depositpaid':
        return BookingPaymentStatus.depositPaid;
      case 'partiallypaid':
        return BookingPaymentStatus.partiallyPaid;
      case 'paid':
        return BookingPaymentStatus.paid;
      case 'refunded':
        return BookingPaymentStatus.refunded;
      case 'cancelled':
        return BookingPaymentStatus.cancelled;
      default:
        return BookingPaymentStatus.pending;
    }
  }

  /// Generate payment receipt
  Future<String> generatePaymentReceipt(String paymentId) async {
    final payment = await _paymentDao.getById(paymentId);
    if (payment == null) {
      throw ArgumentError('Payment not found');
    }

    final booking = await _bookingDao.getById(payment.bookingId);
    if (booking == null) {
      throw ArgumentError('Booking not found');
    }

    // Generate receipt content
    final receipt = '''
=== PAYMENT RECEIPT ===
Receipt No: ${payment.id}
Date: ${payment.processedAt.toString().split(' ')[0]}
Time: ${payment.processedAt.toString().split(' ')[1].substring(0, 5)}

Booking Details:
- Booking No: ${booking.bookingNumber}
- Customer: ${booking.customerName}
- Pet: ${booking.petName}
- Room: ${booking.roomNumber}
- Check-in: ${booking.checkInDate.toString().split(' ')[0]}
- Check-out: ${booking.checkOutDate.toString().split(' ')[0]}

Payment Details:
- Amount: MYR ${payment.amount.abs().toStringAsFixed(2)}
- Payment Method: ${payment.paymentMethod.name.toUpperCase()}
- Payment Type: ${payment.paymentType?.name.toUpperCase() ?? 'FULL PAYMENT'}
- Status: ${payment.status.name.toUpperCase()}

Processed by: ${payment.processedBy ?? 'System'}
Notes: ${payment.notes}

Thank you for your business!
''';

    return receipt;
  }
}

/// Payment summary for a booking
class BookingPaymentSummary {
  final String bookingId;
  final double totalAmount;
  final double depositAmount;
  final double totalPaid;
  final double remainingBalance;
  final BookingPaymentStatus paymentStatus;
  final List<Payment> payments;

  BookingPaymentSummary({
    required this.bookingId,
    required this.totalAmount,
    required this.depositAmount,
    required this.totalPaid,
    required this.remainingBalance,
    required this.paymentStatus,
    required this.payments,
  });
}

/// Booking payment status
enum BookingPaymentStatus {
  pending,
  depositPaid,
  partiallyPaid,
  paid,
  refunded,
  cancelled,
}
