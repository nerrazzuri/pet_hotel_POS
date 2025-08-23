import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/services/supplier_service.dart';

// Supplier Service Provider
final supplierServiceProvider = Provider<SupplierService>((ref) {
  return SupplierService();
});

// All Suppliers Provider
final suppliersProvider = FutureProvider<List<Supplier>>((ref) async {
  final supplierService = ref.read(supplierServiceProvider);
  return supplierService.getAllSuppliers();
});

// Search Query Provider
final supplierSearchQueryProvider = StateProvider<String>((ref) => '');

// Supplier Status Filter Provider
final supplierStatusFilterProvider = StateProvider<bool>((ref) => true); // true = active only

// Filtered Suppliers Provider
final filteredSuppliersProvider = FutureProvider<List<Supplier>>((ref) async {
  print('filteredSuppliersProvider: Called');
  
  try {
    final supplierService = ref.read(supplierServiceProvider);
    print('filteredSuppliersProvider: SupplierService retrieved: ${supplierService.runtimeType}');
    
    final query = ref.watch(supplierSearchQueryProvider);
    final onlyActive = ref.watch(supplierStatusFilterProvider);
    
    print('filteredSuppliersProvider: Query: "$query", OnlyActive: $onlyActive');
    
    if (query.isEmpty) {
      print('filteredSuppliersProvider: Empty query, calling getAllSuppliers()');
      final suppliers = await supplierService.getAllSuppliers(onlyActive: onlyActive);
      print('filteredSuppliersProvider: getAllSuppliers returned ${suppliers.length} suppliers');
      return suppliers;
    } else {
      print('filteredSuppliersProvider: Non-empty query, calling searchSuppliers()');
      final suppliers = await supplierService.searchSuppliers(query);
      
      // Apply status filter to search results
      final filteredSuppliers = onlyActive 
          ? suppliers.where((supplier) => supplier.isActive).toList()
          : suppliers;
      
      print('filteredSuppliersProvider: searchSuppliers returned ${filteredSuppliers.length} suppliers');
      return filteredSuppliers;
    }
  } catch (e) {
    print('filteredSuppliersProvider: Error: $e');
    rethrow;
  }
});

// Selected Supplier Provider
final selectedSupplierProvider = StateProvider<Supplier?>((ref) => null);

// Supplier Form State Provider
final supplierFormProvider = StateNotifierProvider<SupplierFormNotifier, SupplierFormState>((ref) {
  return SupplierFormNotifier(ref.read(supplierServiceProvider));
});

class SupplierFormState {
  final bool isLoading;
  final String? error;
  final bool isSuccess;

  const SupplierFormState({
    this.isLoading = false,
    this.error,
    this.isSuccess = false,
  });

  SupplierFormState copyWith({
    bool? isLoading,
    String? error,
    bool? isSuccess,
  }) {
    return SupplierFormState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class SupplierFormNotifier extends StateNotifier<SupplierFormState> {
  final SupplierService _supplierService;

  SupplierFormNotifier(this._supplierService) : super(const SupplierFormState());

  Future<void> createSupplier({
    required String name,
    String? companyName,
    String? contactPerson,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? stateValue,
    String? zipCode,
    String? country,
    String? website,
    String? taxId,
    String? paymentTerms,
    double? creditLimit,
    String? notes,
    List<String>? categories,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      await _supplierService.createSupplier(
        name: name,
        companyName: companyName,
        contactPerson: contactPerson,
        email: email,
        phone: phone,
        address: address,
        city: city,
        state: stateValue,
        zipCode: zipCode,
        country: country,
        website: website,
        taxId: taxId,
        paymentTerms: paymentTerms,
        creditLimit: creditLimit,
        notes: notes,
        categories: categories,
      );

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> updateSupplier({
    required String supplierId,
    String? name,
    String? companyName,
    String? contactPerson,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? stateValue,
    String? zipCode,
    String? country,
    String? website,
    String? taxId,
    String? paymentTerms,
    double? creditLimit,
    String? notes,
    bool? isActive,
    List<String>? categories,
  }) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      await _supplierService.updateSupplier(
        supplierId: supplierId,
        name: name,
        companyName: companyName,
        contactPerson: contactPerson,
        email: email,
        phone: phone,
        address: address,
        city: city,
        state: stateValue,
        zipCode: zipCode,
        country: country,
        website: website,
        taxId: taxId,
        paymentTerms: paymentTerms,
        creditLimit: creditLimit,
        notes: notes,
        isActive: isActive,
        categories: categories,
      );

      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> deactivateSupplier(String supplierId) async {
    state = state.copyWith(isLoading: true, error: null, isSuccess: false);

    try {
      await _supplierService.deactivateSupplier(supplierId);
      state = state.copyWith(isLoading: false, isSuccess: true);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void resetState() {
    state = const SupplierFormState();
  }
}
