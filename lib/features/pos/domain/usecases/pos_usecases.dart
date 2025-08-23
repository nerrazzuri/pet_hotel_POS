import 'package:cat_hotel_pos/features/pos/domain/entities/cart_item.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/pos_cart.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/pos_transaction.dart';
import 'package:cat_hotel_pos/features/pos/domain/repositories/pos_repository.dart';

class POSUseCases {
  final POSRepository _repository;

  POSUseCases(this._repository);

  // Cart management
  Future<POSCart> createNewCart() async {
    return await _repository.createCart();
  }

  Future<POSCart> addItemToCart(String cartId, CartItem item) async {
    return await _repository.addItemToCart(cartId, item);
  }

  Future<POSCart> updateCartItem(String cartId, String itemId, CartItem item) async {
    return await _repository.updateCartItem(cartId, itemId, item);
  }

  Future<POSCart> removeCartItem(String cartId, String itemId) async {
    return await _repository.removeItemFromCart(cartId, itemId);
  }

  Future<POSCart> clearCart(String cartId) async {
    return await _repository.clearCart(cartId);
  }

  Future<POSCart> holdCart(String cartId, String reason) async {
    return await _repository.holdCart(cartId, reason);
  }

  Future<POSCart> recallHeldCart(String cartId) async {
    return await _repository.recallCart(cartId);
  }

  // Transaction processing
  Future<POSTransaction> processTransaction(String cartId, Map<String, dynamic> paymentDetails) async {
    return await _repository.completeTransaction(cartId, paymentDetails);
  }

  Future<POSTransaction> refundItems(String transactionId, List<String> itemIds, String reason) async {
    return await _repository.refundTransaction(transactionId, itemIds, reason);
  }

  Future<POSTransaction> voidTransaction(String transactionId, String reason) async {
    return await _repository.voidTransaction(transactionId, reason);
  }

  // Cart calculations
  double calculateSubtotal(List<CartItem> items) {
    return items.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double calculateTax(double subtotal, double taxRate) {
    return subtotal * (taxRate / 100);
  }

  double calculateTotal(double subtotal, double taxAmount, double discountAmount) {
    return subtotal + taxAmount - discountAmount;
  }

  double calculateChange(double totalAmount, double amountPaid) {
    return amountPaid - totalAmount;
  }

  // Validation
  bool validatePayment(double totalAmount, double amountPaid) {
    return amountPaid >= totalAmount;
  }

  bool validateCart(List<CartItem> items) {
    return items.isNotEmpty;
  }

  // Search and retrieval
  Future<List<POSTransaction>> searchTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? customerId,
    String? status,
    int? limit,
    int? offset,
  }) async {
    return await _repository.getTransactions(
      startDate: startDate,
      endDate: endDate,
      customerId: customerId,
      status: status,
      limit: limit,
      offset: offset,
    );
  }

  Future<List<POSCart>> getHeldCarts() async {
    return await _repository.getHeldCarts();
  }

  // Receipt and invoice
  Future<String> generateReceipt(String transactionId) async {
    return await _repository.generateReceipt(transactionId);
  }

  Future<String> generateInvoice(String transactionId) async {
    return await _repository.generateInvoice(transactionId);
  }

  Future<void> sendReceipt(String transactionId, String method) async {
    await _repository.sendReceipt(transactionId, method);
  }
}
