import 'package:cat_hotel_pos/core/services/pos_dao.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/cart_item.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/pos_cart.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/pos_transaction.dart';
import 'package:cat_hotel_pos/features/pos/domain/repositories/pos_repository.dart';
import 'package:uuid/uuid.dart';

class POSRepositoryImpl implements POSRepository {
  final PosDao _posDao;
  final Uuid _uuid = const Uuid();

  POSRepositoryImpl(this._posDao);

  @override
  Future<POSCart> createCart() async {
    final cartId = _uuid.v4();
    final cart = POSCart(
      id: cartId,
      items: [],
      createdAt: DateTime.now(),
      status: 'active',
    );

    // Save to DAO
    await _posDao.createCart(cart);
    return cart;
  }

  @override
  Future<POSCart> addItemToCart(String cartId, CartItem item) async {
    // Get current cart
    final cart = await _posDao.getCartById(cartId);
    if (cart == null) {
      throw Exception('Cart not found');
    }

    final updatedItems = List<CartItem>.from(cart.items);
    
    // Check if item already exists
    final existingIndex = updatedItems.indexWhere((i) => i.id == item.id);
    if (existingIndex != -1) {
      // Update quantity
      updatedItems[existingIndex] = updatedItems[existingIndex].copyWith(
        quantity: updatedItems[existingIndex].quantity + item.quantity,
      );
    } else {
      updatedItems.add(item);
    }

    final updatedCart = cart.copyWith(
      items: updatedItems,
      subtotal: _calculateSubtotal(updatedItems),
    );

    // Update DAO
    await _posDao.updateCart(updatedCart);
    return updatedCart;
  }

  @override
  Future<POSCart> updateCartItem(String cartId, String itemId, CartItem item) async {
    final cart = await _posDao.getCartById(cartId);
    if (cart == null) {
      throw Exception('Cart not found');
    }

    final updatedItems = List<CartItem>.from(cart.items);
    final itemIndex = updatedItems.indexWhere((i) => i.id == itemId);
    if (itemIndex == -1) {
      throw Exception('Item not found in cart');
    }

    updatedItems[itemIndex] = item;
    final updatedCart = cart.copyWith(
      items: updatedItems,
      subtotal: _calculateSubtotal(updatedItems),
    );

    await _posDao.updateCart(updatedCart);
    return updatedCart;
  }

  @override
  Future<POSCart> removeItemFromCart(String cartId, String itemId) async {
    final cart = await _posDao.getCartById(cartId);
    if (cart == null) {
      throw Exception('Cart not found');
    }

    final updatedItems = List<CartItem>.from(cart.items);
    updatedItems.removeWhere((i) => i.id == itemId);
    
    final updatedCart = cart.copyWith(
      items: updatedItems,
      subtotal: _calculateSubtotal(updatedItems),
    );

    await _posDao.updateCart(updatedCart);
    return updatedCart;
  }

  @override
  Future<POSCart> clearCart(String cartId) async {
    final cart = await _posDao.getCartById(cartId);
    if (cart == null) {
      throw Exception('Cart not found');
    }

    final updatedCart = cart.copyWith(
      items: [],
      subtotal: 0.0,
      totalAmount: 0.0,
    );

    await _posDao.updateCart(updatedCart);
    return updatedCart;
  }

  @override
  Future<POSCart> holdCart(String cartId, String reason) async {
    final cart = await _posDao.getCartById(cartId);
    if (cart == null) {
      throw Exception('Cart not found');
    }

    final updatedCart = cart.copyWith(
      status: 'held',
      holdReason: reason,
      heldAt: DateTime.now(),
    );

    await _posDao.updateCart(updatedCart);
    return updatedCart;
  }

  @override
  Future<POSCart> recallCart(String cartId) async {
    final cart = await _posDao.getCartById(cartId);
    if (cart == null) {
      throw Exception('Cart not found');
    }

    final updatedCart = cart.copyWith(
      status: 'active',
      holdReason: null,
      heldAt: null,
    );

    await _posDao.updateCart(updatedCart);
    return updatedCart;
  }

  @override
  Future<POSTransaction> completeTransaction(String cartId, Map<String, dynamic> paymentDetails) async {
    final cart = await _posDao.getCartById(cartId);
    if (cart == null) {
      throw Exception('Cart not found');
    }

    final transaction = POSTransaction(
      id: _uuid.v4(),
      items: cart.items,
      createdAt: cart.createdAt,
      completedAt: DateTime.now(),
      totalAmount: cart.totalAmount ?? 0.0,
      paymentMethod: paymentDetails['paymentMethod'] ?? 'cash',
      status: 'completed',
      customerId: cart.customerId,
      customerName: cart.customerName,
      customerPhone: cart.customerPhone,
      subtotal: cart.subtotal,
      taxAmount: cart.taxAmount,
      discountAmount: cart.discountAmount,
      amountPaid: paymentDetails['amountPaid'],
      changeAmount: (paymentDetails['amountPaid'] ?? 0.0) - (cart.totalAmount ?? 0.0),
      cashierId: paymentDetails['cashierId'],
      cashierName: paymentDetails['cashierName'],
      receiptNumber: _generateReceiptNumber(),
      invoiceNumber: _generateInvoiceNumber(),
      notes: cart.notes,
    );

    // Save transaction
    await _posDao.createTransaction(transaction);
    
    // Update cart status
    final updatedCart = cart.copyWith(
      status: 'completed',
      transactionId: transaction.id,
    );
    await _posDao.updateCart(updatedCart);

    return transaction;
  }

  @override
  Future<POSTransaction> refundTransaction(String transactionId, List<String> itemIds, String reason) async {
    final transaction = await _posDao.getTransactionById(transactionId);
    if (transaction == null) {
      throw Exception('Transaction not found');
    }

    final refundedTransaction = transaction.copyWith(
      status: 'refunded',
      refundReason: reason,
      refundedAt: DateTime.now(),
    );

    await _posDao.updateTransaction(refundedTransaction);
    return refundedTransaction;
  }

  @override
  Future<POSTransaction> voidTransaction(String transactionId, String reason) async {
    final transaction = await _posDao.getTransactionById(transactionId);
    if (transaction == null) {
      throw Exception('Transaction not found');
    }

    final voidedTransaction = transaction.copyWith(
      status: 'voided',
      voidReason: reason,
      voidedAt: DateTime.now(),
    );

    await _posDao.updateTransaction(voidedTransaction);
    return voidedTransaction;
  }

  @override
  Future<List<POSTransaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? customerId,
    String? status,
    int? limit,
    int? offset,
  }) async {
    var transactions = await _posDao.getAllTransactions();
    
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
    
    // Apply pagination
    if (offset != null && limit != null) {
      final start = offset;
      final end = start + limit;
      transactions = transactions.sublist(
        start,
        end > transactions.length ? transactions.length : end,
      );
    }

    return transactions;
  }

  @override
  Future<POSTransaction?> getTransactionById(String transactionId) async {
    return await _posDao.getTransactionById(transactionId);
  }

  @override
  Future<List<POSCart>> getHeldCarts() async {
    final allCarts = await _posDao.getAllCarts();
    return allCarts.where((cart) => cart.status == 'held').toList();
  }

  @override
  Future<String> generateReceipt(String transactionId) async {
    final transaction = await _posDao.getTransactionById(transactionId);
    if (transaction == null) {
      throw Exception('Transaction not found');
    }

    // Simple receipt generation
    final receipt = '''
RECEIPT #${transaction.receiptNumber}
Date: ${transaction.completedAt.toString()}
Items:
${transaction.items.map((item) => '${item.name} x${item.quantity} @${item.price}').join('\n')}
Subtotal: ${transaction.subtotal}
Tax: ${transaction.taxAmount ?? 0.0}
Total: ${transaction.totalAmount}
Payment Method: ${transaction.paymentMethod}
''';
    
    return receipt;
  }

  @override
  Future<String> generateInvoice(String transactionId) async {
    final transaction = await _posDao.getTransactionById(transactionId);
    if (transaction == null) {
      throw Exception('Transaction not found');
    }

    // Simple invoice generation
    final invoice = '''
INVOICE #${transaction.invoiceNumber}
Date: ${transaction.completedAt.toString()}
Customer: ${transaction.customerName ?? 'Walk-in Customer'}
Items:
${transaction.items.map((item) => '${item.name} x${item.quantity} @${item.price}').join('\n')}
Subtotal: ${transaction.subtotal}
Tax: ${transaction.taxAmount ?? 0.0}
Total: ${transaction.totalAmount}
Payment Method: ${transaction.paymentMethod}
''';
    
    return invoice;
  }

  @override
  Future<void> sendReceipt(String transactionId, String method) async {
    // Placeholder implementation
    // In a real app, this would integrate with email/SMS services
    print('Sending receipt via $method for transaction $transactionId');
  }

  @override
  Future<void> syncOfflineTransactions() async {
    // Placeholder implementation
    // In a real app, this would sync with a remote server
    print('Syncing offline transactions...');
  }

  @override
  Future<List<POSTransaction>> getOfflineTransactions() async {
    // Placeholder implementation
    // In a real app, this would return transactions marked as offline
    return [];
  }

  double _calculateSubtotal(List<CartItem> items) {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  String _generateReceiptNumber() {
    return 'R${DateTime.now().millisecondsSinceEpoch}';
  }

  String _generateInvoiceNumber() {
    return 'I${DateTime.now().millisecondsSinceEpoch}';
  }
}
