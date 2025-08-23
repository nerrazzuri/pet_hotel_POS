import 'package:cat_hotel_pos/features/payments/domain/entities/payment_method.dart';
import 'package:cat_hotel_pos/features/payments/domain/entities/payment_transaction.dart';
import 'package:cat_hotel_pos/core/services/payment_method_dao.dart';
import 'package:cat_hotel_pos/core/services/payment_transaction_dao.dart';

class PaymentService {
  final PaymentMethodDao _paymentMethodDao = PaymentMethodDao();
  final PaymentTransactionDao _transactionDao = PaymentTransactionDao();

  // Payment Method Management
  Future<List<PaymentMethod>> getAllPaymentMethods() async {
    return await _paymentMethodDao.getAll();
  }

  Future<List<PaymentMethod>> getActivePaymentMethods() async {
    return await _paymentMethodDao.getActiveMethods();
  }

  Future<PaymentMethod?> getPaymentMethodById(String id) async {
    return await _paymentMethodDao.getById(id);
  }

  Future<List<PaymentMethod>> getPaymentMethodsByType(PaymentType type) async {
    return await _paymentMethodDao.getByType(type);
  }

  Future<PaymentMethod> createPaymentMethod({
    required String name,
    required PaymentType type,
    String? description,
    String? iconPath,
    Map<String, dynamic>? configuration,
    double? processingFee,
    double? minimumAmount,
    double? maximumAmount,
    List<String>? supportedCurrencies,
    bool? requiresSignature,
    bool? requiresReceipt,
    String? notes,
  }) async {
    final method = PaymentMethod(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: description,
      iconPath: iconPath,
      configuration: configuration,
      processingFee: processingFee,
      minimumAmount: minimumAmount,
      maximumAmount: maximumAmount,
      supportedCurrencies: supportedCurrencies,
      requiresSignature: requiresSignature,
      requiresReceipt: requiresReceipt,
      notes: notes,
    );

    await _paymentMethodDao.create(method);
    return method;
  }

  Future<PaymentMethod> updatePaymentMethod(String id, Map<String, dynamic> updates) async {
    final method = await _paymentMethodDao.getById(id);
    if (method == null) {
      throw Exception('Payment method not found');
    }

    // Manually update fields since copyWith doesn't support spread operator
    var updatedMethod = method;
    
    if (updates.containsKey('name') && updates['name'] != null) {
      updatedMethod = updatedMethod.copyWith(name: updates['name'] as String);
    }
    if (updates.containsKey('description')) {
      updatedMethod = updatedMethod.copyWith(description: updates['description'] as String?);
    }
    if (updates.containsKey('iconPath')) {
      updatedMethod = updatedMethod.copyWith(iconPath: updates['iconPath'] as String?);
    }
    if (updates.containsKey('configuration')) {
      updatedMethod = updatedMethod.copyWith(configuration: updates['configuration'] as Map<String, dynamic>?);
    }
    if (updates.containsKey('processingFee')) {
      updatedMethod = updatedMethod.copyWith(processingFee: updates['processingFee'] as double?);
    }
    if (updates.containsKey('minimumAmount')) {
      updatedMethod = updatedMethod.copyWith(minimumAmount: updates['minimumAmount'] as double?);
    }
    if (updates.containsKey('maximumAmount')) {
      updatedMethod = updatedMethod.copyWith(maximumAmount: updates['maximumAmount'] as double?);
    }
    if (updates.containsKey('supportedCurrencies')) {
      updatedMethod = updatedMethod.copyWith(supportedCurrencies: updates['supportedCurrencies'] as List<String>?);
    }
    if (updates.containsKey('requiresSignature')) {
      updatedMethod = updatedMethod.copyWith(requiresSignature: updates['requiresSignature'] as bool);
    }
    if (updates.containsKey('requiresReceipt')) {
      updatedMethod = updatedMethod.copyWith(requiresReceipt: updates['requiresReceipt'] as bool);
    }
    if (updates.containsKey('notes')) {
      updatedMethod = updatedMethod.copyWith(notes: updates['notes'] as String?);
    }
    if (updates.containsKey('isActive')) {
      updatedMethod = updatedMethod.copyWith(isActive: updates['isActive'] as bool);
    }
    
    updatedMethod = updatedMethod.copyWith(updatedAt: DateTime.now());

    await _paymentMethodDao.update(updatedMethod);
    return updatedMethod;
  }

  Future<void> deactivatePaymentMethod(String id) async {
    await _paymentMethodDao.deactivate(id);
  }

  Future<void> activatePaymentMethod(String id) async {
    await _paymentMethodDao.activate(id);
  }

  Future<void> deletePaymentMethod(String id) async {
    await _paymentMethodDao.delete(id);
  }

  // Payment Processing
  Future<PaymentTransaction> processPayment({
    required String transactionId,
    required TransactionType type,
    required double amount,
    required PaymentMethod paymentMethod,
    String? customerId,
    String? customerName,
    String? orderId,
    String? invoiceId,
    String? receiptId,
    String? referenceNumber,
    String? notes,
    double? taxAmount,
    double? tipAmount,
    double? serviceChargeAmount,
    String? currency,
    String? processedBy,
  }) async {
    // Validate payment method
    if (!paymentMethod.isActive) {
      throw Exception('Payment method is not active');
    }

    // Validate amount limits
    if (paymentMethod.minimumAmount != null && amount < paymentMethod.minimumAmount!) {
      throw Exception('Amount is below minimum for this payment method');
    }
    if (paymentMethod.maximumAmount != null && amount > paymentMethod.maximumAmount!) {
      throw Exception('Amount exceeds maximum for this payment method');
    }

    // Calculate processing fee
    double processingFee = 0.0;
    if (paymentMethod.processingFee != null) {
      processingFee = (amount * paymentMethod.processingFee! / 100);
    }

    // Create payment transaction
    final transaction = PaymentTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      transactionId: transactionId,
      type: type,
      amount: amount,
      paymentMethod: paymentMethod,
      status: PaymentStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      customerId: customerId,
      customerName: customerName,
      orderId: orderId,
      invoiceId: invoiceId,
      receiptId: receiptId,
      referenceNumber: referenceNumber,
      notes: notes,
      processingFee: processingFee,
      taxAmount: taxAmount,
      tipAmount: tipAmount,
      serviceChargeAmount: serviceChargeAmount,
      currency: currency ?? 'MYR',
      processedBy: processedBy,
    );

    await _transactionDao.create(transaction);
    return transaction;
  }

  Future<PaymentTransaction> completePayment(String transactionId) async {
    final transaction = await _transactionDao.getById(transactionId);
    if (transaction == null) {
      throw Exception('Transaction not found');
    }

    final updatedTransaction = transaction.copyWith(
      status: PaymentStatus.completed,
      updatedAt: DateTime.now(),
      completedAt: DateTime.now(),
    );

    await _transactionDao.update(updatedTransaction);
    return updatedTransaction;
  }

  Future<PaymentTransaction> failPayment(String transactionId, String errorMessage) async {
    final transaction = await _transactionDao.getById(transactionId);
    if (transaction == null) {
      throw Exception('Transaction not found');
    }

    final updatedTransaction = transaction.copyWith(
      status: PaymentStatus.failed,
      updatedAt: DateTime.now(),
      errorMessage: errorMessage,
    );

    await _transactionDao.update(updatedTransaction);
    return updatedTransaction;
  }

  Future<PaymentTransaction> cancelPayment(String transactionId, String reason) async {
    final transaction = await _transactionDao.getById(transactionId);
    if (transaction == null) {
      throw Exception('Transaction not found');
    }

    final updatedTransaction = transaction.copyWith(
      status: PaymentStatus.cancelled,
      updatedAt: DateTime.now(),
      notes: reason,
    );

    await _transactionDao.update(updatedTransaction);
    return updatedTransaction;
  }

  // Refund Processing
  Future<PaymentTransaction> processRefund({
    required String originalTransactionId,
    required double refundAmount,
    required String reason,
    String? processedBy,
    String? notes,
  }) async {
    final originalTransaction = await _transactionDao.getById(originalTransactionId);
    if (originalTransaction == null) {
      throw Exception('Original transaction not found');
    }

    if (originalTransaction.status != PaymentStatus.completed) {
      throw Exception('Original transaction is not completed');
    }

    if (refundAmount > originalTransaction.amount) {
      throw Exception('Refund amount cannot exceed original transaction amount');
    }

    final refundTransaction = PaymentTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      transactionId: 'REF${DateTime.now().millisecondsSinceEpoch}',
      type: refundAmount == originalTransaction.amount 
          ? TransactionType.refund 
          : TransactionType.partialRefund,
      amount: refundAmount,
      paymentMethod: originalTransaction.paymentMethod,
      status: PaymentStatus.completed,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      customerId: originalTransaction.customerId,
      customerName: originalTransaction.customerName,
      orderId: originalTransaction.orderId,
      invoiceId: originalTransaction.invoiceId,
      receiptId: originalTransaction.receiptId,
      referenceNumber: 'REF${DateTime.now().millisecondsSinceEpoch}',
      notes: 'Refund: $reason',
      processedBy: processedBy,
      currency: originalTransaction.currency,
      processedAt: DateTime.now(),
      completedAt: DateTime.now(),
    );

    await _transactionDao.create(refundTransaction);
    return refundTransaction;
  }

  // Transaction Management
  Future<List<PaymentTransaction>> getAllTransactions() async {
    return await _transactionDao.getAll();
  }

  Future<PaymentTransaction?> getTransactionById(String id) async {
    return await _transactionDao.getById(id);
  }

  Future<List<PaymentTransaction>> getTransactionsByCustomer(String customerId) async {
    return await _transactionDao.getByCustomerId(customerId);
  }

  Future<List<PaymentTransaction>> getTransactionsByStatus(PaymentStatus status) async {
    return await _transactionDao.getByStatus(status);
  }

  Future<List<PaymentTransaction>> getTransactionsByType(TransactionType type) async {
    return await _transactionDao.getByType(type);
  }

  Future<List<PaymentTransaction>> getTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    return await _transactionDao.getByDateRange(startDate, endDate);
  }

  // Analytics and Reporting
  Future<Map<String, dynamic>> getPaymentSummary(DateTime startDate, DateTime endDate) async {
    final transactions = await _transactionDao.getByDateRange(startDate, endDate);
    
    double totalAmount = 0.0;
    double totalProcessingFees = 0.0;
    double totalTaxAmount = 0.0;
    Map<PaymentType, double> amountByPaymentType = {};
    Map<PaymentStatus, int> countByStatus = {};

    for (final transaction in transactions) {
      if (transaction.status == PaymentStatus.completed) {
        totalAmount += transaction.amount;
        totalProcessingFees += transaction.processingFee ?? 0.0;
        totalTaxAmount += transaction.taxAmount ?? 0.0;
        
        amountByPaymentType[transaction.paymentMethod.type] = 
            (amountByPaymentType[transaction.paymentMethod.type] ?? 0.0) + transaction.amount;
      }
      
      countByStatus[transaction.status] = (countByStatus[transaction.status] ?? 0) + 1;
    }

    return {
      'totalTransactions': transactions.length,
      'totalAmount': totalAmount,
      'totalProcessingFees': totalProcessingFees,
      'totalTaxAmount': totalTaxAmount,
      'amountByPaymentType': amountByPaymentType,
      'countByStatus': countByStatus,
      'averageTransactionAmount': transactions.isNotEmpty ? totalAmount / transactions.length : 0.0,
    };
  }

  Future<List<PaymentTransaction>> getRecentTransactions({int limit = 10}) async {
    final allTransactions = await _transactionDao.getAll();
    allTransactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return allTransactions.take(limit).toList();
  }
}
