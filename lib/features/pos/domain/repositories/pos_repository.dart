import 'package:cat_hotel_pos/features/pos/domain/entities/cart_item.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/pos_cart.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/pos_transaction.dart';

abstract class POSRepository {
  // Cart operations
  Future<POSCart> createCart();
  Future<POSCart> addItemToCart(String cartId, CartItem item);
  Future<POSCart> updateCartItem(String cartId, String itemId, CartItem item);
  Future<POSCart> removeItemFromCart(String cartId, String itemId);
  Future<POSCart> clearCart(String cartId);
  Future<POSCart> holdCart(String cartId, String reason);
  Future<POSCart> recallCart(String cartId);
  
  // Transaction operations
  Future<POSTransaction> completeTransaction(String cartId, Map<String, dynamic> paymentDetails);
  Future<POSTransaction> refundTransaction(String transactionId, List<String> itemIds, String reason);
  Future<POSTransaction> voidTransaction(String transactionId, String reason);
  
  // Search and retrieval
  Future<List<POSTransaction>> getTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? customerId,
    String? status,
    int? limit,
    int? offset,
  });
  
  Future<POSTransaction?> getTransactionById(String transactionId);
  Future<List<POSCart>> getHeldCarts();
  
  // Receipt and invoice
  Future<String> generateReceipt(String transactionId);
  Future<String> generateInvoice(String transactionId);
  Future<void> sendReceipt(String transactionId, String method); // email, whatsapp, sms
  
  // Offline operations
  Future<void> syncOfflineTransactions();
  Future<List<POSTransaction>> getOfflineTransactions();
}
