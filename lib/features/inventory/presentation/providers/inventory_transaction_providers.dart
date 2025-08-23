import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/inventory/domain/services/inventory_transaction_service.dart';
import 'package:cat_hotel_pos/features/inventory/domain/entities/inventory_transaction.dart';

// Service provider
final inventoryTransactionServiceProvider = Provider<InventoryTransactionService>((ref) {
  return InventoryTransactionService();
});

// Main inventory transactions provider
final inventoryTransactionsProvider = FutureProvider<List<InventoryTransaction>>((ref) async {
  final service = ref.read(inventoryTransactionServiceProvider);
  return await service.getAllTransactions();
});

// Search query provider
final transactionSearchQueryProvider = StateProvider<String>((ref) => '');

// Type filter provider
final transactionTypeFilterProvider = StateProvider<TransactionType?>((ref) => null);

// Date range filter providers
final transactionFromDateProvider = StateProvider<DateTime?>((ref) => null);
final transactionToDateProvider = StateProvider<DateTime?>((ref) => null);

// Filtered inventory transactions provider
final filteredInventoryTransactionsProvider = FutureProvider<List<InventoryTransaction>>((ref) async {
  final service = ref.read(inventoryTransactionServiceProvider);
  final searchQuery = ref.watch(transactionSearchQueryProvider);
  final typeFilter = ref.watch(transactionTypeFilterProvider);
  final fromDate = ref.watch(transactionFromDateProvider);
  final toDate = ref.watch(transactionToDateProvider);

  if (searchQuery.isNotEmpty) {
    return await service.searchTransactions(searchQuery);
  }

  return await service.getAllTransactions(
    type: typeFilter,
    fromDate: fromDate,
    toDate: toDate,
  );
});

// Selected inventory transaction provider
final selectedInventoryTransactionProvider = StateProvider<InventoryTransaction?>((ref) => null);

// Inventory transaction form state
class InventoryTransactionFormState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final String productId;
  final String productName;
  final TransactionType type;
  final int quantity;
  final double unitCost;
  final String? notes;
  final String? reason;
  final String? location;
  final String? reference;
  final String? referenceType;

  const InventoryTransactionFormState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.productId = '',
    this.productName = '',
    this.type = TransactionType.adjustment,
    this.quantity = 0,
    this.unitCost = 0.0,
    this.notes,
    this.reason,
    this.location,
    this.reference,
    this.referenceType,
  });

  InventoryTransactionFormState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    String? productId,
    String? productName,
    TransactionType? type,
    int? quantity,
    double? unitCost,
    String? notes,
    String? reason,
    String? location,
    String? reference,
    String? referenceType,
  }) {
    return InventoryTransactionFormState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      notes: notes ?? this.notes,
      reason: reason ?? this.reason,
      location: location ?? this.location,
      reference: reference ?? this.reference,
      referenceType: referenceType ?? this.referenceType,
    );
  }
}

// Inventory transaction form notifier
class InventoryTransactionFormNotifier extends StateNotifier<InventoryTransactionFormState> {
  final InventoryTransactionService _service;

  InventoryTransactionFormNotifier(this._service) : super(const InventoryTransactionFormState());

  void setProduct(String productId, String productName) {
    state = state.copyWith(
      productId: productId,
      productName: productName,
    );
  }

  void setType(TransactionType type) {
    state = state.copyWith(type: type);
  }

  void setQuantity(int quantity) {
    state = state.copyWith(quantity: quantity);
  }

  void setUnitCost(double unitCost) {
    state = state.copyWith(unitCost: unitCost);
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void setReason(String reason) {
    state = state.copyWith(reason: reason);
  }

  void setLocation(String location) {
    state = state.copyWith(location: location);
  }

  void setReference(String reference, String referenceType) {
    state = state.copyWith(
      reference: reference,
      referenceType: referenceType,
    );
  }

  void reset() {
    state = const InventoryTransactionFormState();
  }

  Future<bool> createTransaction() async {
    if (state.productId.isEmpty || state.quantity == 0) {
      state = state.copyWith(
        error: 'Please fill in all required fields',
        isLoading: false,
      );
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final transaction = await _service.createTransaction(
        productId: state.productId,
        type: state.type,
        quantity: state.quantity,
        unitCost: state.unitCost,
        notes: state.notes,
        reason: state.reason,
        location: state.location,
        reference: state.reference,
        referenceType: state.referenceType,
      );

      if (transaction != null) {
        state = state.copyWith(
          isLoading: false,
          isSuccess: true,
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to create transaction',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Error: $e',
      );
      return false;
    }
  }
}

// Inventory transaction form provider
final inventoryTransactionFormProvider = StateNotifierProvider<InventoryTransactionFormNotifier, InventoryTransactionFormState>((ref) {
  final service = ref.read(inventoryTransactionServiceProvider);
  return InventoryTransactionFormNotifier(service);
});
