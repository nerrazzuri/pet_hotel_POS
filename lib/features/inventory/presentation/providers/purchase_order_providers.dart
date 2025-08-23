import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/inventory/domain/services/purchase_order_service.dart';
import 'package:cat_hotel_pos/features/inventory/domain/entities/purchase_order.dart';
import 'package:cat_hotel_pos/features/inventory/domain/entities/purchase_order_item.dart';

// Service provider
final purchaseOrderServiceProvider = Provider<PurchaseOrderService>((ref) {
  return PurchaseOrderService();
});

// Main purchase orders provider
final purchaseOrdersProvider = FutureProvider<List<PurchaseOrder>>((ref) async {
  final service = ref.read(purchaseOrderServiceProvider);
  return await service.getAllPurchaseOrders();
});

// Search query provider
final purchaseOrderSearchQueryProvider = StateProvider<String>((ref) => '');

// Status filter provider
final purchaseOrderStatusFilterProvider = StateProvider<PurchaseOrderStatus?>((ref) => null);

// Supplier filter provider
final purchaseOrderSupplierFilterProvider = StateProvider<String?>((ref) => null);

// Date range filter providers
final purchaseOrderFromDateProvider = StateProvider<DateTime?>((ref) => null);
final purchaseOrderToDateProvider = StateProvider<DateTime?>((ref) => null);

// Filtered purchase orders provider
final filteredPurchaseOrdersProvider = FutureProvider<List<PurchaseOrder>>((ref) async {
  final service = ref.read(purchaseOrderServiceProvider);
  final searchQuery = ref.watch(purchaseOrderSearchQueryProvider);
  final statusFilter = ref.watch(purchaseOrderStatusFilterProvider);
  final supplierFilter = ref.watch(purchaseOrderSupplierFilterProvider);
  final fromDate = ref.watch(purchaseOrderFromDateProvider);
  final toDate = ref.watch(purchaseOrderToDateProvider);

  if (searchQuery.isNotEmpty) {
    return await service.searchPurchaseOrders(searchQuery);
  }

  return await service.getAllPurchaseOrders(
    status: statusFilter,
    supplierId: supplierFilter,
    fromDate: fromDate,
    toDate: toDate,
  );
});

// Selected purchase order provider
final selectedPurchaseOrderProvider = StateProvider<PurchaseOrder?>((ref) => null);

// Purchase order form state (simplified without freezed)
class PurchaseOrderFormState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final List<PurchaseOrderItem> items;
  final String supplierId;
  final String supplierName;
  final PurchaseOrderType type;
  final DateTime? expectedDeliveryDate;
  final String notes;
  final String specialInstructions;

  const PurchaseOrderFormState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.items = const [],
    this.supplierId = '',
    this.supplierName = '',
    this.type = PurchaseOrderType.regular,
    this.expectedDeliveryDate,
    this.notes = '',
    this.specialInstructions = '',
  });

  PurchaseOrderFormState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    List<PurchaseOrderItem>? items,
    String? supplierId,
    String? supplierName,
    PurchaseOrderType? type,
    DateTime? expectedDeliveryDate,
    String? notes,
    String? specialInstructions,
  }) {
    return PurchaseOrderFormState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
      items: items ?? this.items,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      type: type ?? this.type,
      expectedDeliveryDate: expectedDeliveryDate ?? this.expectedDeliveryDate,
      notes: notes ?? this.notes,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }
}

// Purchase order form notifier
class PurchaseOrderFormNotifier extends StateNotifier<PurchaseOrderFormState> {
  final PurchaseOrderService _purchaseOrderService;

  PurchaseOrderFormNotifier(this._purchaseOrderService) : super(const PurchaseOrderFormState());

  void addItem(PurchaseOrderItem item) {
    state = state.copyWith(items: [...state.items, item]);
  }

  void removeItem(String itemId) {
    state = state.copyWith(
      items: state.items.where((item) => item.id != itemId).toList(),
    );
  }

  void updateItem(PurchaseOrderItem updatedItem) {
    state = state.copyWith(
      items: state.items.map((item) => 
        item.id == updatedItem.id ? updatedItem : item
      ).toList(),
    );
  }

  void setSupplier(String supplierId, String supplierName) {
    state = state.copyWith(
      supplierId: supplierId,
      supplierName: supplierName,
    );
  }

  void setType(PurchaseOrderType type) {
    state = state.copyWith(type: type);
  }

  void setExpectedDeliveryDate(DateTime date) {
    state = state.copyWith(expectedDeliveryDate: date);
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void setSpecialInstructions(String instructions) {
    state = state.copyWith(specialInstructions: instructions);
  }

  Future<void> createPurchaseOrder() async {
    if (state.items.isEmpty) {
      state = state.copyWith(error: 'Please add at least one item to the purchase order');
      return;
    }

    if (state.supplierId.isEmpty) {
      state = state.copyWith(error: 'Please select a supplier');
      return;
    }

    if (state.expectedDeliveryDate == null) {
      state = state.copyWith(error: 'Please set an expected delivery date');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _purchaseOrderService.createPurchaseOrder(
        supplierId: state.supplierId,
        supplierName: state.supplierName,
        type: state.type,
        expectedDeliveryDate: state.expectedDeliveryDate!,
        items: state.items,
        notes: state.notes,
        specialInstructions: state.specialInstructions,
      );

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void reset() {
    state = const PurchaseOrderFormState();
  }
}

// Purchase order form provider
final purchaseOrderFormProvider = StateNotifierProvider<PurchaseOrderFormNotifier, PurchaseOrderFormState>((ref) {
  final service = ref.read(purchaseOrderServiceProvider);
  return PurchaseOrderFormNotifier(service);
});
