// Functional POS DAO for Android compatibility
// Provides in-memory storage with sample data


import 'package:cat_hotel_pos/features/pos/domain/entities/cart_item.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/pos_cart.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/pos_transaction.dart';
// import 'package:uuid/uuid.dart';

class PosDao {
  final Map<String, POSCart> _carts = {};
  final Map<String, POSTransaction> _transactions = {};
  // TODO: Uncomment when implementing UUID generation
  // final Uuid _uuid = const Uuid();
  bool _initialized = false;

  void _initialize() {
    if (_initialized) return;
    
    // Create sample held carts
    _carts['cart_001'] = POSCart(
      id: 'cart_001',
      items: [
        CartItem(
          id: 'item_001',
          name: 'Premium Cat Food',
          type: 'product',
          price: 45.99,
          quantity: 2,
          description: 'High-quality dry cat food',
          category: 'Pet Food',
          sku: 'CAT-FOOD-001',
          barcode: '1234567890123',
          createdAt: DateTime.now(),
        ),
        CartItem(
          id: 'item_002',
          name: 'Basic Cat Check-up',
          type: 'service',
          price: 80.00,
          quantity: 1,
          description: 'Complete health examination for cats',
          category: 'Health Services',
          createdAt: DateTime.now(),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      customerName: 'Sarah Johnson',
      customerPhone: '+60-12-345-6789',
      holdReason: 'Customer went to get cash',
      heldAt: DateTime.now().subtract(const Duration(hours: 1)),
      heldBy: 'staff_001',
      subtotal: 171.98,
      taxAmount: 10.32,
      totalAmount: 182.30,
      status: 'held',
      cashierId: 'staff_001',
      cashierName: 'John Doe',
    );

    _carts['cart_002'] = POSCart(
      id: 'cart_002',
      items: [
        CartItem(
          id: 'item_003',
          name: 'Cat Grooming Service',
          type: 'service',
          price: 60.00,
          quantity: 1,
          description: 'Full grooming service including bath and nail trimming',
          category: 'Grooming Services',
          createdAt: DateTime.now(),
        ),
        CartItem(
          id: 'item_004',
          name: 'Cat Toy Set',
          type: 'product',
          price: 24.99,
          quantity: 1,
          description: 'Interactive toys for mental stimulation',
          category: 'Toys',
          sku: 'CAT-TOYS-001',
          barcode: '1234567890125',
          createdAt: DateTime.now(),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
      customerName: 'Mike Chen',
      customerPhone: '+60-12-456-7890',
      holdReason: 'Waiting for cat to be brought in',
      heldAt: DateTime.now().subtract(const Duration(minutes: 30)),
      heldBy: 'staff_002',
      subtotal: 84.99,
      taxAmount: 5.10,
      totalAmount: 90.09,
      status: 'held',
      cashierId: 'staff_002',
      cashierName: 'Jane Smith',
    );

    // Create sample completed transactions
    _transactions['trans_001'] = POSTransaction(
      id: 'trans_001',
      items: [
        CartItem(
          id: 'item_005',
          name: 'Cat Boarding (1 night)',
          type: 'service',
          price: 120.00,
          quantity: 1,
          description: 'Overnight cat boarding with basic care',
          category: 'Boarding Services',
          createdAt: DateTime.now(),
        ),
        CartItem(
          id: 'item_006',
          name: 'Cat Litter Premium',
          type: 'product',
          price: 32.99,
          quantity: 1,
          description: 'Clumping cat litter with odor control',
          category: 'Litter',
          sku: 'CAT-LITTER-001',
          barcode: '1234567890124',
          createdAt: DateTime.now(),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      completedAt: DateTime.now().subtract(const Duration(hours: 3)),
      totalAmount: 162.18,
      paymentMethod: 'cash',
      status: 'completed',
      customerName: 'Emma Wilson',
      customerPhone: '+60-12-567-8901',
      customerEmail: 'emma.wilson@email.com',
      subtotal: 152.99,
      taxAmount: 9.19,
      discountAmount: 0.0,
      amountPaid: 162.18,
      changeAmount: 0.0,
      cashierId: 'staff_001',
      cashierName: 'John Doe',
      receiptNumber: 'R240820001',
      notes: 'Customer paid in cash',
    );

    _transactions['trans_002'] = POSTransaction(
      id: 'trans_002',
      items: [
        CartItem(
          id: 'item_007',
          name: 'Premium Cat Food',
          type: 'product',
          price: 45.99,
          quantity: 3,
          description: 'High-quality dry cat food',
          category: 'Pet Food',
          sku: 'CAT-FOOD-001',
          barcode: '1234567890123',
          createdAt: DateTime.now(),
        ),
        CartItem(
          id: 'item_008',
          name: 'Cat Health Checkup',
          type: 'service',
          price: 80.00,
          quantity: 1,
          description: 'Complete health examination for cats',
          category: 'Health Services',
          createdAt: DateTime.now(),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      completedAt: DateTime.now().subtract(const Duration(hours: 5)),
      totalAmount: 233.18,
      paymentMethod: 'card',
      status: 'completed',
      customerName: 'David Kim',
      customerPhone: '+60-12-678-9012',
      customerEmail: 'david.kim@email.com',
      subtotal: 217.97,
      taxAmount: 13.08,
      discountAmount: 0.0,
      amountPaid: 233.18,
      changeAmount: 0.0,
      cashierId: 'staff_002',
      cashierName: 'Jane Smith',
      receiptNumber: 'R240820002',
      notes: 'Paid by credit card',
    );

    _transactions['trans_003'] = POSTransaction(
      id: 'trans_003',
      items: [
        CartItem(
          id: 'item_009',
          name: 'Cat Grooming Deluxe',
          type: 'service',
          price: 95.00,
          quantity: 1,
          description: 'Premium grooming service with spa treatment',
          category: 'Grooming Services',
          createdAt: DateTime.now(),
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(hours: 7)),
      completedAt: DateTime.now().subtract(const Duration(hours: 7)),
      totalAmount: 100.70,
      paymentMethod: 'card',
      status: 'completed',
      customerName: 'Lisa Brown',
      customerPhone: '+60-12-789-0123',
      customerEmail: 'lisa.brown@email.com',
      subtotal: 95.00,
      taxAmount: 5.70,
      discountAmount: 0.0,
      amountPaid: 100.70,
      changeAmount: 0.0,
      cashierId: 'staff_001',
      cashierName: 'John Doe',
      receiptNumber: 'R240820003',
      notes: 'Customer very satisfied with service',
    );

    _initialized = true;
  }

  // Cart operations
  Future<List<POSCart>> getHeldCarts() async {
    _initialize();
    return _carts.values.where((cart) => cart.status == 'held').toList();
  }

  Future<List<POSCart>> getActiveCarts() async {
    _initialize();
    return _carts.values.where((cart) => cart.status == 'active').toList();
  }

  // Transaction operations

  Future<List<POSTransaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? customerId,
    String? status,
    int? limit,
    int? offset,
  }) async {
    _initialize();
    var transactions = _transactions.values.toList();

    // Apply filters
    if (startDate != null) {
      transactions = transactions.where((t) => t.completedAt.isAfter(startDate)).toList();
    }
    
    if (endDate != null) {
      transactions = transactions.where((t) => t.completedAt.isBefore(endDate)).toList();
    }
    
    if (customerId != null) {
      transactions = transactions.where((t) => t.customerId == customerId).toList();
    }
    
    if (status != null) {
      transactions = transactions.where((t) => t.status == status).toList();
    }

    // Sort by completion date (newest first)
    transactions.sort((a, b) => b.completedAt.compareTo(a.completedAt));

    // Apply pagination
    if (offset != null) {
      transactions = transactions.skip(offset).toList();
    }
    
    if (limit != null) {
      transactions = transactions.take(limit).toList();
    }

    return transactions;
  }

  Future<List<POSTransaction>> getRecentTransactions({int limit = 10}) async {
    _initialize();
    final transactions = _transactions.values.toList();
    transactions.sort((a, b) => b.completedAt.compareTo(a.completedAt));
    return transactions.take(limit).toList();
  }

  Future<int> getTotalTransactionsCount() async {
    _initialize();
    return _transactions.length;
  }

  Future<double> getTotalRevenue() async {
    _initialize();
    double total = 0.0;
    for (final transaction in _transactions.values) {
      total += transaction.totalAmount;
    }
    return total;
  }

  Future<Map<String, int>> getTransactionsByPaymentMethod() async {
    _initialize();
    final result = <String, int>{};
    for (final transaction in _transactions.values) {
      final method = transaction.paymentMethod;
      result[method] = (result[method] ?? 0) + 1;
    }
    return result;
  }

  Future<Map<String, double>> getRevenueByPaymentMethod() async {
    _initialize();
    final result = <String, double>{};
    for (final transaction in _transactions.values) {
      final method = transaction.paymentMethod;
      result[method] = (result[method] ?? 0.0) + transaction.totalAmount;
    }
    return result;
  }

  // Helper methods
  String generateReceiptNumber() {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final random = (1000 + DateTime.now().millisecondsSinceEpoch % 9000).toString();
    return 'R$year$month$day$random';
  }

  double calculateSubtotal(List<CartItem> items) {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double calculateTax(double subtotal, {double taxRate = 0.06}) {
    return subtotal * taxRate;
  }

  double calculateTotal(double subtotal, double taxAmount, double discountAmount) {
    return subtotal + taxAmount - discountAmount;
  }

  // Get transactions by date range
  Future<List<POSTransaction>> getTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    _initialize();
    return _transactions.values.where((transaction) {
      return transaction.completedAt.isAfter(startDate) && transaction.completedAt.isBefore(endDate);
    }).toList();
  }

  // Cart management methods
  Future<POSCart> createCart(POSCart cart) async {
    _initialize();
    _carts[cart.id] = cart;
    return cart;
  }

  Future<POSCart?> getCartById(String cartId) async {
    _initialize();
    return _carts[cartId];
  }

  Future<List<POSCart>> getAllCarts() async {
    _initialize();
    return _carts.values.toList();
  }

  Future<POSCart> updateCart(POSCart cart) async {
    _initialize();
    _carts[cart.id] = cart;
    return cart;
  }

  Future<void> deleteCart(String cartId) async {
    _initialize();
    _carts.remove(cartId);
  }

  // Transaction management methods
  Future<POSTransaction> createTransaction(POSTransaction transaction) async {
    _initialize();
    _transactions[transaction.id] = transaction;
    return transaction;
  }

  Future<POSTransaction?> getTransactionById(String transactionId) async {
    _initialize();
    return _transactions[transactionId];
  }

  Future<List<POSTransaction>> getAllTransactions() async {
    _initialize();
    return _transactions.values.toList();
  }

  Future<List<POSTransaction>> getTransactionsByCustomerId(String customerId) async {
    _initialize();
    return _transactions.values
        .where((transaction) => transaction.customerId == customerId)
        .toList();
  }

  Future<POSTransaction> updateTransaction(POSTransaction transaction) async {
    _initialize();
    _transactions[transaction.id] = transaction;
    return transaction;
  }

  Future<void> deleteTransaction(String transactionId) async {
    _initialize();
    _transactions.remove(transactionId);
  }
}
