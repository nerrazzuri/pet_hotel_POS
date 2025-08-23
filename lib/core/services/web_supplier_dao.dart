
import 'package:cat_hotel_pos/features/inventory/domain/entities/supplier.dart';
import 'web_storage_service.dart';

class WebSupplierDao {
  // TODO: Uncomment when implementing storage key
  // static const String _storageKey = 'suppliers';

  /// Create a new supplier
  Future<void> create(Supplier supplier) async {
    print('WebSupplierDao.create: Called with supplier: ${supplier.name}');
    
    try {
      WebStorageService.saveSupplier(supplier.toJson());
      print('WebSupplierDao.create: Successfully saved supplier');
    } catch (e) {
      print('WebSupplierDao.create: Error: $e');
      rethrow;
    }
  }

  /// Update an existing supplier
  Future<void> update(Supplier supplier) async {
    print('WebSupplierDao.update: Called with supplier: ${supplier.name}');
    
    try {
      WebStorageService.saveSupplier(supplier.toJson());
      print('WebSupplierDao.update: Successfully updated supplier');
    } catch (e) {
      print('WebSupplierDao.update: Error: $e');
      rethrow;
    }
  }

  /// Get all suppliers
  Future<List<Supplier>> getAll({bool onlyActive = true}) async {
    print('WebSupplierDao.getAll: Called with onlyActive: $onlyActive');
    
    try {
      final supplierData = WebStorageService.getAllSuppliers();
      print('WebSupplierDao.getAll: Raw data count: ${supplierData.length}');
      
      final suppliers = supplierData.map((data) => Supplier.fromJson(data)).toList();
      
      final filteredSuppliers = onlyActive 
          ? suppliers.where((supplier) => supplier.isActive).toList()
          : suppliers;
      
      print('WebSupplierDao.getAll: Retrieved ${filteredSuppliers.length} suppliers');
      return filteredSuppliers;
    } catch (e) {
      print('WebSupplierDao.getAll: Error: $e');
      return [];
    }
  }

  /// Get supplier by ID
  Future<Supplier?> getById(String id) async {
    print('WebSupplierDao.getById: Called with id: $id');
    
    try {
      final suppliers = await getAll(onlyActive: false);
      final supplier = suppliers.cast<Supplier?>().firstWhere(
        (supplier) => supplier?.id == id,
        orElse: () => null,
      );
      
      print('WebSupplierDao.getById: ${supplier != null ? "Found" : "Not found"} supplier');
      return supplier;
    } catch (e) {
      print('WebSupplierDao.getById: Error: $e');
      return null;
    }
  }

  /// Search suppliers by name or company
  Future<List<Supplier>> search(String query) async {
    print('WebSupplierDao.search: Called with query: "$query"');
    
    try {
      final suppliers = await getAll(onlyActive: true);
      final filteredSuppliers = suppliers.where((supplier) =>
        supplier.name.toLowerCase().contains(query.toLowerCase()) ||
        (supplier.companyName?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
      
      print('WebSupplierDao.search: Found ${filteredSuppliers.length} suppliers');
      return filteredSuppliers;
    } catch (e) {
      print('WebSupplierDao.search: Error: $e');
      return [];
    }
  }

}
