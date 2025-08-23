import 'package:cat_hotel_pos/features/payments/domain/entities/payment_transaction.dart';
import 'package:cat_hotel_pos/features/payments/domain/entities/payment_method.dart';

class PaymentTransactionDao {
  static final Map<String, PaymentTransaction> _transactions = {};
  static bool _initialized = false;

  static void _initialize() {
    if (_initialized) return;

    // Create sample payment transactions
    _transactions['pt_001'] = PaymentTransaction(
      id: 'pt_001',
      transactionId: 'TXN001',
      type: TransactionType.sale,
      amount: 150.00,
      paymentMethod: PaymentMethod(
        id: 'pm_001',
        name: 'Cash',
        type: PaymentType.cash,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      status: PaymentStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      customerId: 'cust_001',
      customerName: 'John Doe',
      orderId: 'ORD001',
      invoiceId: 'INV001',
      receiptId: 'RCP001',
      referenceNumber: 'REF001',
      processedAt: DateTime.now().subtract(const Duration(hours: 2)),
      completedAt: DateTime.now().subtract(const Duration(hours: 2)),
      processedBy: 'cashier_001',
      taxAmount: 9.00,
      currency: 'MYR',
      notes: 'Grooming service for Whiskers',
    );

    _transactions['pt_002'] = PaymentTransaction(
      id: 'pt_002',
      transactionId: 'TXN002',
      type: TransactionType.sale,
      amount: 89.50,
      paymentMethod: PaymentMethod(
        id: 'pm_002',
        name: 'Credit Card',
        type: PaymentType.creditCard,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      status: PaymentStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 1)),
      customerId: 'cust_002',
      customerName: 'Jane Smith',
      orderId: 'ORD002',
      invoiceId: 'INV002',
      receiptId: 'RCP002',
      referenceNumber: 'REF002',
      authorizationCode: 'AUTH123',
      transactionReference: 'TXN_REF_002',
      processedAt: DateTime.now().subtract(const Duration(hours: 1)),
      completedAt: DateTime.now().subtract(const Duration(hours: 1)),
      processedBy: 'cashier_001',
      processingFee: 2.24,
      taxAmount: 5.37,
      currency: 'MYR',
      cardType: 'Visa',
      cardLast4: '1234',
      notes: 'Pet food and toys purchase',
    );

    _transactions['pt_003'] = PaymentTransaction(
      id: 'pt_003',
      transactionId: 'TXN003',
      type: TransactionType.deposit,
      amount: 200.00,
      paymentMethod: PaymentMethod(
        id: 'pm_007',
        name: 'Deposit',
        type: PaymentType.deposit,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      status: PaymentStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      customerId: 'cust_003',
      customerName: 'Mike Johnson',
      orderId: 'ORD003',
      invoiceId: 'INV003',
      receiptId: 'RCP003',
      referenceNumber: 'REF003',
      processedAt: DateTime.now().subtract(const Duration(days: 1)),
      completedAt: DateTime.now().subtract(const Duration(days: 1)),
      processedBy: 'cashier_002',
      currency: 'MYR',
      notes: 'Deposit for boarding services',
    );

    _transactions['pt_004'] = PaymentTransaction(
      id: 'pt_004',
      transactionId: 'TXN004',
      type: TransactionType.refund,
      amount: 45.00,
      paymentMethod: PaymentMethod(
        id: 'pm_002',
        name: 'Credit Card',
        type: PaymentType.creditCard,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      status: PaymentStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      updatedAt: DateTime.now().subtract(const Duration(days: 2)),
      customerId: 'cust_001',
      customerName: 'John Doe',
      orderId: 'ORD004',
      invoiceId: 'INV004',
      receiptId: 'RCP004',
      referenceNumber: 'REF004',
      processedAt: DateTime.now().subtract(const Duration(days: 2)),
      completedAt: DateTime.now().subtract(const Duration(days: 2)),
      processedBy: 'cashier_001',
      currency: 'MYR',
      notes: 'Refund for cancelled appointment',
    );

    _transactions['pt_005'] = PaymentTransaction(
      id: 'pt_005',
      transactionId: 'TXN005',
      type: TransactionType.sale,
      amount: 75.25,
      paymentMethod: PaymentMethod(
        id: 'pm_004',
        name: 'Digital Wallet',
        type: PaymentType.digitalWallet,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      status: PaymentStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(hours: 30)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 30)),
      customerId: 'cust_004',
      customerName: 'Sarah Wilson',
      orderId: 'ORD005',
      invoiceId: 'INV005',
      receiptId: 'RCP005',
      referenceNumber: 'REF005',
      transactionReference: 'TXN_REF_005',
      processedAt: DateTime.now().subtract(const Duration(hours: 30)),
      completedAt: DateTime.now().subtract(const Duration(hours: 30)),
      processedBy: 'cashier_002',
      processingFee: 0.75,
      taxAmount: 4.52,
      currency: 'MYR',
      notes: 'Vaccination service for Shadow',
    );

    _initialized = true;
  }

  Future<List<PaymentTransaction>> getAll() async {
    _initialize();
    return _transactions.values.toList();
  }

  Future<PaymentTransaction?> getById(String id) async {
    _initialize();
    return _transactions[id];
  }

  Future<List<PaymentTransaction>> getByCustomerId(String customerId) async {
    _initialize();
    return _transactions.values
        .where((transaction) => transaction.customerId == customerId)
        .toList();
  }

  Future<List<PaymentTransaction>> getByStatus(PaymentStatus status) async {
    _initialize();
    return _transactions.values
        .where((transaction) => transaction.status == status)
        .toList();
  }

  Future<List<PaymentTransaction>> getByType(TransactionType type) async {
    _initialize();
    return _transactions.values
        .where((transaction) => transaction.type == type)
        .toList();
  }

  Future<List<PaymentTransaction>> getByDateRange(DateTime startDate, DateTime endDate) async {
    _initialize();
    return _transactions.values
        .where((transaction) => 
            transaction.createdAt.isAfter(startDate) && 
            transaction.createdAt.isBefore(endDate))
        .toList();
  }

  Future<PaymentTransaction> create(PaymentTransaction transaction) async {
    _initialize();
    _transactions[transaction.id] = transaction;
    return transaction;
  }

  Future<PaymentTransaction> update(PaymentTransaction transaction) async {
    _initialize();
    _transactions[transaction.id] = transaction;
    return transaction;
  }

  Future<void> delete(String id) async {
    _initialize();
    _transactions.remove(id);
  }

  Future<void> updateStatus(String id, PaymentStatus status) async {
    _initialize();
    final transaction = _transactions[id];
    if (transaction != null) {
      _transactions[id] = transaction.copyWith(
        status: status,
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<List<PaymentTransaction>> getTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    _initialize();
    return _transactions.values
        .where((transaction) => 
            transaction.createdAt.isAfter(startDate) && 
            transaction.createdAt.isBefore(endDate))
        .toList();
  }
}
