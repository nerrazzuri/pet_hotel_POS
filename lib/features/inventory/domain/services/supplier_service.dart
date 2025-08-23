import 'package:flutter/foundation.dart';
import '../entities/supplier.dart';
import '../../../../core/services/supplier_dao.dart';
import '../../../../core/services/web_supplier_dao.dart';

class SupplierService {
  late final dynamic _supplierDao;

  SupplierService() {
    print('SupplierService: Constructor called, kIsWeb: $kIsWeb');
    if (kIsWeb) {
      print('SupplierService: Creating WebSupplierDao...');
      _supplierDao = WebSupplierDao();
    } else {
      print('SupplierService: Creating SupplierDao...');
      _supplierDao = SupplierDao();
    }
    print('SupplierService: Constructor completed successfully');
  }

  /// Get all suppliers
  Future<List<Supplier>> getAllSuppliers({bool onlyActive = true}) async {
    print('SupplierService.getAllSuppliers: Called with onlyActive: $onlyActive');
    print('SupplierService.getAllSuppliers: _supplierDao type: ${_supplierDao.runtimeType}');
    
    try {
      final suppliers = await _supplierDao.getAll(onlyActive: onlyActive);
      print('SupplierService.getAllSuppliers: Successfully retrieved ${suppliers.length} suppliers');
      return suppliers;
    } catch (e) {
      print('SupplierService.getAllSuppliers: Error: $e');
      rethrow;
    }
  }

  /// Get supplier by ID
  Future<Supplier?> getSupplierById(String id) async {
    print('SupplierService.getSupplierById: Called with id: $id');
    
    try {
      final supplier = await _supplierDao.getById(id);
      print('SupplierService.getSupplierById: ${supplier != null ? "Found" : "Not found"} supplier');
      return supplier;
    } catch (e) {
      print('SupplierService.getSupplierById: Error: $e');
      rethrow;
    }
  }

  /// Search suppliers
  Future<List<Supplier>> searchSuppliers(String query) async {
    print('SupplierService.searchSuppliers: Called with query: "$query"');
    
    try {
      final suppliers = await _supplierDao.search(query);
      print('SupplierService.searchSuppliers: Found ${suppliers.length} suppliers');
      return suppliers;
    } catch (e) {
      print('SupplierService.searchSuppliers: Error: $e');
      rethrow;
    }
  }

  /// Create new supplier
  Future<Supplier> createSupplier({
    required String name,
    String? companyName,
    String? contactPerson,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? website,
    String? taxId,
    String? paymentTerms,
    double? creditLimit,
    String? notes,
    List<String>? categories,
    Map<String, dynamic>? metadata,
  }) async {
    print('SupplierService.createSupplier: Called with name: $name');
    
    try {
      final supplier = Supplier(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        companyName: companyName ?? 'Unknown Company',
        status: SupplierStatus.active,
        category: SupplierCategory.supplies,
        contactPerson: contactPerson,
        email: email,
        phone: phone,
        address: address,
        city: city,
        state: state,
        postalCode: zipCode,
        country: country,
        website: website,
        taxId: taxId,
        paymentTerms: paymentTerms,
        creditLimit: creditLimit?.toString(),
        notes: notes,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        categories: categories,
        metadata: metadata,
      );

      await _supplierDao.create(supplier);
      print('SupplierService.createSupplier: Successfully created supplier');
      return supplier;
    } catch (e) {
      print('SupplierService.createSupplier: Error: $e');
      rethrow;
    }
  }

  /// Update supplier
  Future<Supplier> updateSupplier({
    required String supplierId,
    String? name,
    String? companyName,
    String? contactPerson,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? country,
    String? website,
    String? taxId,
    String? paymentTerms,
    double? creditLimit,
    String? notes,
    bool? isActive,
    List<String>? categories,
    Map<String, dynamic>? metadata,
  }) async {
    print('SupplierService.updateSupplier: Called with supplierId: $supplierId');
    
    try {
      final existingSupplier = await _supplierDao.getById(supplierId);
      if (existingSupplier == null) {
        throw Exception('Supplier not found');
      }

      final updatedSupplier = existingSupplier.copyWith(
        name: name ?? existingSupplier.name,
        companyName: companyName ?? existingSupplier.companyName,
        contactPerson: contactPerson ?? existingSupplier.contactPerson,
        email: email ?? existingSupplier.email,
        phone: phone ?? existingSupplier.phone,
        address: address ?? existingSupplier.address,
        city: city ?? existingSupplier.city,
        state: state ?? existingSupplier.state,
        postalCode: zipCode ?? existingSupplier.postalCode,
        country: country ?? existingSupplier.country,
        website: website ?? existingSupplier.website,
        taxId: taxId ?? existingSupplier.taxId,
        paymentTerms: paymentTerms ?? existingSupplier.paymentTerms,
        creditLimit: creditLimit?.toString() ?? existingSupplier.creditLimit,
        notes: notes ?? existingSupplier.notes,
        isActive: isActive ?? existingSupplier.isActive,
        categories: categories ?? existingSupplier.categories,
        metadata: metadata ?? existingSupplier.metadata,
        updatedAt: DateTime.now(),
      );

      await _supplierDao.update(updatedSupplier);
      print('SupplierService.updateSupplier: Successfully updated supplier');
      return updatedSupplier;
    } catch (e) {
      print('SupplierService.updateSupplier: Error: $e');
      rethrow;
    }
  }

  /// Deactivate supplier (soft delete)
  Future<void> deactivateSupplier(String supplierId) async {
    print('SupplierService.deactivateSupplier: Called with supplierId: $supplierId');
    
    try {
      await updateSupplier(supplierId: supplierId, isActive: false);
      print('SupplierService.deactivateSupplier: Successfully deactivated supplier');
    } catch (e) {
      print('SupplierService.deactivateSupplier: Error: $e');
      rethrow;
    }
  }
}

