import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/core/services/pos_dao.dart';
import 'package:cat_hotel_pos/core/services/product_dao.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/cart_item.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/pos_cart.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/pos_transaction.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/voucher.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/deposit.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/partial_payment.dart';
import 'package:cat_hotel_pos/features/pos/domain/services/partial_payment_service.dart';
import 'package:cat_hotel_pos/features/pos/domain/services/deposit_service.dart';
import 'package:cat_hotel_pos/features/services/domain/entities/product.dart';
import 'package:uuid/uuid.dart';

// Functional providers for POS system

// POS DAO provider
final posDAOProvider = Provider<PosDao>((ref) => PosDao());

// Product DAO provider (for POS integration)
final productDAOProvider = Provider<ProductDao>((ref) => ProductDao());

// Available products for POS provider
final availableProductsProvider = FutureProvider<List<Product>>((ref) async {
  final productDao = ref.read(productDAOProvider);
  return await productDao.getAll();
});

// Current cart provider
final currentCartProvider = StateNotifierProvider<POSCartNotifier, POSCart?>((ref) {
  final posDao = ref.read(posDAOProvider);
  return POSCartNotifier(posDao);
});

// Cart items provider
final cartItemsProvider = Provider<List<CartItem>>((ref) {
  final cart = ref.watch(currentCartProvider);
  return cart?.items ?? [];
});

// Cart subtotal provider
final cartSubtotalProvider = Provider<double>((ref) {
  final items = ref.watch(cartItemsProvider);
  return ref.read(posDAOProvider).calculateSubtotal(items);
});

// Cart tax amount provider
final cartTaxAmountProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  return ref.read(posDAOProvider).calculateTax(subtotal);
});

// Cart discount amount provider
final cartDiscountAmountProvider = Provider<double>((ref) {
  final cart = ref.watch(currentCartProvider);
  return cart?.discountAmount ?? 0.0;
});

// Cart total provider
final cartTotalProvider = Provider<double>((ref) {
  final subtotal = ref.watch(cartSubtotalProvider);
  final taxAmount = ref.watch(cartTaxAmountProvider);
  final discountAmount = ref.watch(cartDiscountAmountProvider);
  return ref.read(posDAOProvider).calculateTotal(subtotal, taxAmount, discountAmount);
});

// Held carts provider
final heldCartsProvider = FutureProvider<List<POSCart>>((ref) async {
  final posDao = ref.read(posDAOProvider);
  return await posDao.getHeldCarts();
});

// Recent transactions provider
final recentTransactionsProvider = FutureProvider<List<POSTransaction>>((ref) async {
  final posDao = ref.read(posDAOProvider);
  return await posDao.getRecentTransactions(limit: 10);
});

// POS Cart Notifier
class POSCartNotifier extends StateNotifier<POSCart?> {
  final PosDao _posDao;
  final Uuid _uuid = const Uuid();

  POSCartNotifier(this._posDao) : super(null);

  Future<void> createNewCart() async {
    final cart = POSCart(
      id: _uuid.v4(),
      items: [],
      createdAt: DateTime.now(),
      status: 'active',
    );
    final createdCart = await _posDao.createCart(cart);
    state = createdCart;
  }

  Future<void> addItemToCart(CartItem item) async {
    if (state == null) await createNewCart();
    
    final currentCart = state!;
    final updatedItems = List<CartItem>.from(currentCart.items);
    
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

    final subtotal = _posDao.calculateSubtotal(updatedItems);
    final taxAmount = _posDao.calculateTax(subtotal);
    final totalAmount = _posDao.calculateTotal(subtotal, taxAmount, currentCart.discountAmount ?? 0.0);

    final updatedCart = currentCart.copyWith(
      items: updatedItems,
      subtotal: subtotal,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
    );

    await _posDao.updateCart(updatedCart);
    state = updatedCart;
  }

  Future<void> updateCartItem(String itemId, CartItem item) async {
    if (state == null) return;
    
    final currentCart = state!;
    final updatedItems = currentCart.items.map((i) => i.id == itemId ? item : i).toList();

    final subtotal = _posDao.calculateSubtotal(updatedItems);
    final taxAmount = _posDao.calculateTax(subtotal);
    final totalAmount = _posDao.calculateTotal(subtotal, taxAmount, currentCart.discountAmount ?? 0.0);

    final updatedCart = currentCart.copyWith(
      items: updatedItems,
      subtotal: subtotal,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
    );

    await _posDao.updateCart(updatedCart);
    state = updatedCart;
  }

  Future<void> removeItemFromCart(String itemId) async {
    if (state == null) return;
    
    final currentCart = state!;
    final updatedItems = currentCart.items.where((i) => i.id != itemId).toList();

    final subtotal = _posDao.calculateSubtotal(updatedItems);
    final taxAmount = _posDao.calculateTax(subtotal);
    final totalAmount = _posDao.calculateTotal(subtotal, taxAmount, currentCart.discountAmount ?? 0.0);

    final updatedCart = currentCart.copyWith(
      items: updatedItems,
      subtotal: subtotal,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
    );

    await _posDao.updateCart(updatedCart);
    state = updatedCart;
  }

  Future<void> removeCartItem(String itemId) async {
    await removeItemFromCart(itemId);
  }

  Future<void> clearCart() async {
    if (state == null) return;
    
    final updatedCart = state!.copyWith(
      items: [],
      subtotal: 0.0,
      taxAmount: 0.0,
      totalAmount: 0.0,
      discountAmount: 0.0,
    );

    await _posDao.updateCart(updatedCart);
    state = updatedCart;
  }

  Future<void> holdCart([String? reason]) async {
    if (state == null) return;
    
    final updatedCart = state!.copyWith(
      status: 'held',
      holdReason: reason ?? 'Customer requested hold',
      heldAt: DateTime.now(),
    );

    await _posDao.updateCart(updatedCart);
    // Create new cart after holding current one
    await createNewCart();
  }

  Future<void> retrieveHeldCart(String cartId) async {
    final cart = await _posDao.getCartById(cartId);
    if (cart != null) {
      final updatedCart = cart.copyWith(
        status: 'active',
        holdReason: null,
        heldAt: null,
      );
      
      await _posDao.updateCart(updatedCart);
      state = updatedCart;
    }
  }

  Future<POSTransaction?> completeTransaction([Map<String, dynamic>? transactionData]) async {
    if (state == null) return null;
    
    final currentCart = state!;
    final transactionId = _uuid.v4();
    final receiptNumber = _posDao.generateReceiptNumber();

    final transaction = POSTransaction(
      id: transactionId,
      items: currentCart.items,
      createdAt: currentCart.createdAt,
      completedAt: DateTime.now(),
      totalAmount: currentCart.totalAmount ?? 0.0,
      paymentMethod: transactionData?['paymentMethod'] ?? 'cash',
      status: 'completed',
      customerId: currentCart.customerId,
      customerName: currentCart.customerName,
      customerPhone: currentCart.customerPhone,
      subtotal: currentCart.subtotal,
      taxAmount: currentCart.taxAmount,
      discountAmount: currentCart.discountAmount,
      amountPaid: transactionData?['amountPaid'] ?? currentCart.totalAmount ?? 0.0,
      changeAmount: (transactionData?['amountPaid'] ?? currentCart.totalAmount ?? 0.0) - (currentCart.totalAmount ?? 0.0),
      cashierId: transactionData?['cashierId'] ?? 'staff_001',
      cashierName: transactionData?['cashierName'] ?? 'Staff Member',
      receiptNumber: receiptNumber,
      notes: currentCart.notes,
    );

    await _posDao.createTransaction(transaction);
    
    // Mark cart as completed
    final completedCart = currentCart.copyWith(
      status: 'completed',
      transactionId: transactionId,
    );
    await _posDao.updateCart(completedCart);
    
    // Create new cart
    await createNewCart();
    
    return transaction;
  }

  Future<void> recallHeldCart(String cartId) async {
    await retrieveHeldCart(cartId);
  }

  void setCustomerInfo(String? customerId, String? customerName, String? customerPhone) {
    if (state == null) return;
    
    final updatedCart = state!.copyWith(
      customerId: customerId,
      customerName: customerName,
      customerPhone: customerPhone,
    );
    
    _posDao.updateCart(updatedCart);
    state = updatedCart;
  }

  void addNotes(String notes) {
    if (state == null) return;
    
    final updatedCart = state!.copyWith(notes: notes);
    _posDao.updateCart(updatedCart);
    state = updatedCart;
  }

  void applyDiscount(double discountAmount, String reason) {
    if (state == null) return;
    
    final currentCart = state!;
    final subtotal = currentCart.subtotal ?? 0.0;
    final taxAmount = currentCart.taxAmount ?? 0.0;
    final totalAmount = _posDao.calculateTotal(subtotal, taxAmount, discountAmount);

    final updatedCart = currentCart.copyWith(
      discountAmount: discountAmount,
      totalAmount: totalAmount,
      notes: '${currentCart.notes ?? ''}\nDiscount applied: $reason',
    );
    
    _posDao.updateCart(updatedCart);
    state = updatedCart;
  }

  // Apply voucher to cart
  void applyVoucher(Voucher voucher, Map<String, dynamic> voucherResult) {
    if (state == null) return;
    
    final currentCart = state!;
    final appliedVouchers = [...(currentCart.appliedVouchers ?? []), voucher];
    final voucherDiscountTotal = (currentCart.voucherDiscountTotal ?? 0.0) + (voucherResult['voucherDiscount'] ?? 0.0);
    
    final updatedCart = currentCart.copyWith(
      appliedVouchers: appliedVouchers.cast<Voucher>(),
      voucherDiscountTotal: voucherDiscountTotal,
      discountAmount: voucherDiscountTotal,
      sstRate: voucherResult['sstRate'],
      sstAmount: voucherResult['sstAmount'],
      totalAmount: voucherResult['finalTotal'],
    );
    
    _posDao.updateCart(updatedCart);
    state = updatedCart;
  }

  // Remove voucher from cart
  void removeVoucher(Voucher voucher) {
    if (state == null) return;
    
    final currentCart = state!;
    final appliedVouchers = currentCart.appliedVouchers?.where((v) => v.id != voucher.id).toList() ?? [];
    final voucherDiscountTotal = appliedVouchers.fold(0.0, (sum, v) => sum + (v.value));
    
    // Recalculate totals without this voucher
    final subtotal = currentCart.subtotal ?? 0.0;
    final newTotal = subtotal - voucherDiscountTotal;
    final sstAmount = newTotal * 0.1; // 10% SST
    final finalTotal = newTotal + sstAmount;
    
    final updatedCart = currentCart.copyWith(
      appliedVouchers: appliedVouchers.cast<Voucher>(),
      voucherDiscountTotal: voucherDiscountTotal,
      discountAmount: voucherDiscountTotal,
      sstAmount: sstAmount,
      totalAmount: finalTotal,
    );
    
    _posDao.updateCart(updatedCart);
    state = updatedCart;
  }

  // Add deposit to cart
  void addDeposit(DepositApplicationResult result) {
    if (state == null) return;
    
    final currentCart = state!;
    final appliedDeposits = [...(currentCart.appliedDeposits ?? []), result.updatedDeposit!];
    
    final updatedCart = currentCart.copyWith(
      appliedDeposits: appliedDeposits.cast<Deposit>(),
      depositAmountTotal: result.newCartData!['depositAmountTotal'],
      amountPaid: result.newCartData!['amountPaid'],
      remainingBalance: result.newCartData!['remainingBalance'],
      changeAmount: result.newCartData!['changeAmount'],
      status: result.newCartData!['status'],
    );
    
    _posDao.updateCart(updatedCart);
    state = updatedCart;
  }

  // Remove deposit from cart
  void removeDeposit(Deposit deposit) {
    if (state == null) return;
    
    final currentCart = state!;
    final appliedDeposits = currentCart.appliedDeposits?.where((d) => d.id != deposit.id).toList() ?? [];
    final depositAmountTotal = appliedDeposits.fold(0.0, (sum, d) => sum + d.amount);
    
    // Recalculate totals
    final totalAmount = currentCart.totalAmount ?? 0.0;
    final newAmountPaid = (currentCart.amountPaid ?? 0.0) - deposit.amount;
    final newRemainingBalance = totalAmount - newAmountPaid;
    final newChangeAmount = newAmountPaid > totalAmount ? newAmountPaid - totalAmount : 0.0;
    
    String newStatus = 'active';
    if (newRemainingBalance <= 0) {
      newStatus = 'completed';
    } else if (newAmountPaid > 0) {
      newStatus = 'partial';
    }
    
    final updatedCart = currentCart.copyWith(
      appliedDeposits: appliedDeposits.cast<Deposit>(),
      depositAmountTotal: depositAmountTotal,
      amountPaid: newAmountPaid,
      remainingBalance: newRemainingBalance > 0 ? newRemainingBalance : 0.0,
      changeAmount: newChangeAmount,
      status: newStatus,
    );
    
    _posDao.updateCart(updatedCart);
    state = updatedCart;
  }

  // Add partial payment to cart
  void addPartialPayment(PartialPaymentResult result) {
    if (state == null || result.partialPayment == null || result.updatedCartData == null) return;
    
    final currentCart = state!;
    final partialPayments = [...(currentCart.partialPayments ?? []), result.partialPayment!];
    
    final updatedCart = currentCart.copyWith(
      partialPayments: partialPayments.cast<PartialPayment>(),
      amountPaid: result.updatedCartData!['amountPaid'],
      remainingBalance: result.updatedCartData!['remainingBalance'],
      changeAmount: result.updatedCartData!['changeAmount'],
      status: result.updatedCartData!['status'],
    );
    
    _posDao.updateCart(updatedCart);
    state = updatedCart;
  }

  // Remove partial payment from cart
  void removePartialPayment(PartialPayment payment) {
    if (state == null) return;
    
    final currentCart = state!;
    final partialPayments = currentCart.partialPayments?.where((p) => p.id != payment.id).toList() ?? [];
    
    // Recalculate totals
    final totalAmount = currentCart.totalAmount ?? 0.0;
    final newAmountPaid = partialPayments.fold(0.0, (sum, p) => sum + p.amount);
    final newRemainingBalance = totalAmount - newAmountPaid;
    final newChangeAmount = newAmountPaid > totalAmount ? newAmountPaid - totalAmount : 0.0;
    
    String newStatus = 'active';
    if (newRemainingBalance <= 0) {
      newStatus = 'completed';
    } else if (newAmountPaid > 0) {
      newStatus = 'partial';
    }
    
    final updatedCart = currentCart.copyWith(
      partialPayments: partialPayments.cast<PartialPayment>(),
      amountPaid: newAmountPaid,
      remainingBalance: newRemainingBalance > 0 ? newRemainingBalance : 0.0,
      changeAmount: newChangeAmount,
      status: newStatus,
    );
    
    _posDao.updateCart(updatedCart);
    state = updatedCart;
  }

  // Split bill
  void splitBill(BillSplitResult result) {
    if (state == null || result.partialPayments == null || result.updatedCartData == null) return;
    
    final currentCart = state!;
    
    final updatedCart = currentCart.copyWith(
      partialPayments: result.partialPayments!.cast<PartialPayment>(),
      amountPaid: result.updatedCartData!['amountPaid'],
      remainingBalance: result.updatedCartData!['remainingBalance'],
      changeAmount: result.updatedCartData!['changeAmount'],
      status: result.updatedCartData!['status'],
    );
    
    _posDao.updateCart(updatedCart);
    state = updatedCart;
  }

  void removeDiscount() {
    if (state == null) return;
    
    final currentCart = state!;
    final subtotal = currentCart.subtotal ?? 0.0;
    final taxAmount = currentCart.taxAmount ?? 0.0;
    final totalAmount = _posDao.calculateTotal(subtotal, taxAmount, 0.0);

    final updatedCart = currentCart.copyWith(
      discountAmount: 0.0,
      totalAmount: totalAmount,
    );
    
    _posDao.updateCart(updatedCart);
    state = updatedCart;
  }
}

// Helper function to convert Product to CartItem
CartItem productToCartItem(Product product, {int quantity = 1}) {
  return CartItem(
    id: product.id,
    name: product.name,
    type: 'product',
    price: product.price,
    quantity: quantity,
    description: product.description,
    category: product.category.name,
    sku: product.productCode,
    barcode: product.barcode,
    createdAt: DateTime.now(),
  );
}
