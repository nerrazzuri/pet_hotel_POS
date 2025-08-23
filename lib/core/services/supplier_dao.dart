// Functional Supplier DAO for Android compatibility
// Provides in-memory storage with sample data

import 'package:cat_hotel_pos/features/inventory/domain/entities/supplier.dart';

class SupplierDao {
  static final Map<String, Supplier> _suppliers = {};
  static bool _initialized = false;

  static void _initialize() {
    if (_initialized) return;
    
    // Create sample suppliers
    _suppliers['supp_001'] = Supplier(
      id: 'supp_001',
      name: 'Pet Food Plus Co.',
      companyName: 'Pet Food Plus Co.',
      status: SupplierStatus.active,
      category: SupplierCategory.food,
      contactPerson: 'Ahmad Rahman',
      email: 'orders@petfoodplus.com',
      phone: '+60-3-1234-5678',
      address: '123 Pet Street, Kuala Lumpur, Malaysia',
      city: 'Kuala Lumpur',
      state: 'Selangor',
      country: 'Malaysia',
      paymentTerms: 'Net 30',
      creditLimit: '50000.0',
      notes: 'Primary food supplier',
      categories: ['Pet Food', 'Grooming'],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _suppliers['supp_002'] = Supplier(
      id: 'supp_002',
      name: 'Cat Care Supplies Ltd.',
      companyName: 'Cat Care Supplies Ltd.',
      status: SupplierStatus.active,
      category: SupplierCategory.supplies,
      contactPerson: 'Sarah Lim',
      email: 'sales@catcaresupplies.com',
      phone: '+60-3-2345-6789',
      address: '456 Cat Avenue, Petaling Jaya, Malaysia',
      city: 'Petaling Jaya',
      state: 'Selangor',
      country: 'Malaysia',
      paymentTerms: 'Net 45',
      creditLimit: '30000.0',
      notes: 'Accessories and toys supplier',
      categories: ['Accessories', 'Toys'],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _suppliers['supp_003'] = Supplier(
      id: 'supp_003',
      name: 'Premium Pet Products',
      companyName: 'Premium Pet Products',
      status: SupplierStatus.active,
      category: SupplierCategory.services,
      contactPerson: 'David Tan',
      email: 'info@premiumpet.com',
      phone: '+60-3-3456-7890',
      address: '789 Premium Road, Subang Jaya, Malaysia',
      city: 'Subang Jaya',
      state: 'Selangor',
      country: 'Malaysia',
      paymentTerms: 'Net 30',
      creditLimit: '40000.0',
      notes: 'Grooming and health products',
      categories: ['Grooming', 'Health'],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _suppliers['supp_004'] = Supplier(
      id: 'supp_004',
      name: 'Wholesale Pet Mart',
      companyName: 'Wholesale Pet Mart',
      status: SupplierStatus.active,
      category: SupplierCategory.supplies,
      contactPerson: 'Lisa Wong',
      email: 'wholesale@petmart.com',
      phone: '+60-3-4567-8901',
      address: '321 Wholesale Street, Shah Alam, Malaysia',
      city: 'Shah Alam',
      state: 'Selangor',
      country: 'Malaysia',
      paymentTerms: 'Net 60',
      creditLimit: '75000.0',
      notes: 'Bulk supplies for peak season',
      categories: ['Bulk Supplies'],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _suppliers['supp_005'] = Supplier(
      id: 'supp_005',
      name: 'Eco Pet Solutions',
      companyName: 'Eco Pet Solutions',
      status: SupplierStatus.active,
      category: SupplierCategory.supplies,
      contactPerson: 'Mohammed Ali',
      email: 'sales@ecopetsolutions.com',
      phone: '+60-3-5678-9012',
      address: '654 Eco Drive, Cyberjaya, Malaysia',
      city: 'Cyberjaya',
      state: 'Selangor',
      country: 'Malaysia',
      paymentTerms: 'Net 30',
      creditLimit: '25000.0',
      notes: 'Eco-friendly products',
      categories: ['Eco-Friendly'],
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    _initialized = true;
  }

  Future<void> insert(Supplier supplier) async {
    _initialize();
    _suppliers[supplier.id] = supplier;
  }

  Future<Supplier?> getById(String id) async {
    _initialize();
    return _suppliers[id];
  }

  Future<Supplier?> getByEmail(String email) async {
    _initialize();
    try {
      return _suppliers.values.firstWhere((supplier) => supplier.email == email);
    } catch (e) {
      return null;
    }
  }

  Future<List<Supplier>> getAll() async {
    _initialize();
    return _suppliers.values.toList();
  }

  Future<List<Supplier>> getActiveSuppliers() async {
    _initialize();
    return _suppliers.values.where((supplier) => supplier.isActive).toList();
  }

  Future<Supplier> update(Supplier supplier) async {
    _initialize();
    _suppliers[supplier.id] = supplier;
    return supplier;
  }

  Future<void> delete(String id) async {
    _initialize();
    _suppliers.remove(id);
  }

  Future<List<Supplier>> search(String query) async {
    _initialize();
    if (query.trim().isEmpty) return _suppliers.values.toList();
    
    final lowercaseQuery = query.toLowerCase();
    return _suppliers.values.where((supplier) =>
      supplier.name.toLowerCase().contains(lowercaseQuery) ||
      (supplier.email?.toLowerCase().contains(lowercaseQuery) ?? false) ||
      (supplier.contactPerson?.toLowerCase().contains(lowercaseQuery) ?? false) ||
      (supplier.categories?.any((cat) => cat.toLowerCase().contains(lowercaseQuery)) ?? false)
    ).toList();
  }

  Future<List<Supplier>> getByCategory(String category) async {
    _initialize();
    return _suppliers.values.where((supplier) => 
      supplier.categories?.any((cat) => cat.toLowerCase() == category.toLowerCase()) ?? false
    ).toList();
  }

  Future<List<Supplier>> getByStatus(SupplierStatus status) async {
    _initialize();
    return _suppliers.values.where((supplier) => supplier.status == status).toList();
  }

  Future<int> getTotalSuppliers() async {
    _initialize();
    return _suppliers.length;
  }

  Future<int> getActiveSuppliersCount() async {
    _initialize();
    return _suppliers.values.where((supplier) => supplier.isActive).length;
  }

  Future<Map<String, int>> getSuppliersByStatus() async {
    _initialize();
    final result = <String, int>{};
    for (final supplier in _suppliers.values) {
      final status = supplier.isActive ? 'active' : 'inactive';
      result[status] = (result[status] ?? 0) + 1;
    }
    return result;
  }

  Future<Map<String, int>> getSuppliersByCategory() async {
    _initialize();
    final result = <String, int>{};
    for (final supplier in _suppliers.values) {
      if (supplier.categories != null) {
        for (final category in supplier.categories!) {
          result[category] = (result[category] ?? 0) + 1;
        }
      }
    }
    return result;
  }
}
