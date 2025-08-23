import 'package:flutter/foundation.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';
import 'package:cat_hotel_pos/core/services/web_storage_service.dart';

class WebCustomerDao {
  static bool get isWeb => kIsWeb;

  Future<Customer> insert(Customer customer) async {
    if (isWeb) {
      return _insertToWebStorage(customer);
    } else {
      throw UnsupportedError('WebCustomerDao.insert() called on non-web platform');
    }
  }

  Future<int> update(Customer customer) async {
    if (isWeb) {
      return _updateInWebStorage(customer);
    } else {
      throw UnsupportedError('WebCustomerDao.update() called on non-web platform');
    }
  }

  Future<int> softDelete(String id) async {
    if (isWeb) {
      return _softDeleteFromWebStorage(id);
    } else {
      throw UnsupportedError('WebCustomerDao.softDelete() called on non-web platform');
    }
  }

  Future<Customer?> getById(String id) async {
    if (isWeb) {
      return _getByIdFromWebStorage(id);
    } else {
      throw UnsupportedError('WebCustomerDao.getById() called on non-web platform');
    }
  }

  /// Get all customers
  Future<List<Customer>> getAll({bool onlyActive = true}) async {
    print('WebCustomerDao.getAll() called with onlyActive: $onlyActive');
    if (isWeb) {
      final result = _getAllFromWebStorage(onlyActive: onlyActive);
      print('WebCustomerDao.getAll() returning ${result.length} customers');
      return result;
    } else {
      throw UnsupportedError('WebCustomerDao.getAll() called on non-web platform');
    }
  }

  /// Search customers
  Future<List<Customer>> search(String query) async {
    print('WebCustomerDao.search() called with query: "$query"');
    if (isWeb) {
      final result = _searchInWebStorage(query);
      print('WebCustomerDao.search() returning ${result.length} customers');
      return result;
    } else {
      throw UnsupportedError('WebCustomerDao.search() called on non-web platform');
    }
  }

  // Web storage implementation
  Customer _insertToWebStorage(Customer customer) {
    final customers = WebStorageService.getAllCustomers();
    customers.add(_mapToStorage(customer));
    WebStorageService.saveCustomer(_mapToStorage(customer));
    return customer;
  }

  int _updateInWebStorage(Customer customer) {
    final customers = WebStorageService.getAllCustomers();
    final index = customers.indexWhere((c) => c['id'] == customer.id);
    if (index >= 0) {
      customers[index] = _mapToStorage(customer);
      WebStorageService.saveCustomer(_mapToStorage(customer));
      return 1;
    }
    return 0;
  }

  int _softDeleteFromWebStorage(String id) {
    final customers = WebStorageService.getAllCustomers();
    final index = customers.indexWhere((c) => c['id'] == id);
    if (index >= 0) {
      customers[index]['isActive'] = 0;
      customers[index]['updatedAt'] = DateTime.now().toIso8601String();
      WebStorageService.saveCustomer(customers[index]);
      return 1;
    }
    return 0;
  }

  Customer? _getByIdFromWebStorage(String id) {
    final customers = WebStorageService.getAllCustomers();
    final customerData = customers.firstWhere(
      (c) => c['id'] == id,
      orElse: () => <String, dynamic>{},
    );
    if (customerData.isEmpty) return null;
    return _mapFromStorage(customerData);
  }

  List<Customer> _getAllFromWebStorage({bool onlyActive = true}) {
    final customers = WebStorageService.getAllCustomers();
    if (onlyActive) {
      return customers
          .where((c) => c['isActive'] == 1)
          .map(_mapFromStorage)
          .toList();
    }
    return customers.map(_mapFromStorage).toList();
  }

  List<Customer> _searchInWebStorage(String query) {
    if (query.trim().isEmpty) {
      return _getAllFromWebStorage();
    }
    
    final customers = WebStorageService.getAllCustomers();
    final lowercaseQuery = query.toLowerCase();
    
    return customers
        .where((c) =>
            (c['firstName'] as String?)?.toLowerCase().contains(lowercaseQuery) == true ||
            (c['lastName'] as String?)?.toLowerCase().contains(lowercaseQuery) == true ||
            (c['email'] as String?)?.toLowerCase().contains(lowercaseQuery) == true ||
            (c['phone'] as String?)?.toLowerCase().contains(lowercaseQuery) == true)
        .map(_mapFromStorage)
        .toList();
  }

  Customer _mapFromStorage(Map<String, dynamic> data) {
    return Customer(
      id: data['id'] ?? '',
      customerCode: data['customerCode'] ?? data['id'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phone'] ?? '',
      source: CustomerSource.walkIn, // Default to walk-in for existing data
      status: data['isActive'] == 1 ? CustomerStatus.active : CustomerStatus.inactive,
      createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(data['updatedAt'] ?? '') ?? DateTime.now(),
      address: data['address'],
      loyaltyPoints: data['loyaltyPoints'] ?? 0,
      emergencyContacts: data['emergencyContact'] != null ? [data['emergencyContact']] : [],
      pets: const [],
    );
  }

  Map<String, dynamic> _mapToStorage(Customer customer) {
    return {
      'id': customer.id,
      'customerCode': customer.id,
      'firstName': customer.firstName,
      'lastName': customer.lastName,
      'email': customer.email,
      'phone': customer.phoneNumber,
      'address': customer.address,
      'emergencyContact': customer.emergencyContacts?.isNotEmpty == true ? customer.emergencyContacts!.first : null,
      'emergencyPhone': null,
      'loyaltyPoints': customer.loyaltyPoints ?? 0,
      'loyaltyTier': 'Bronze',
      'isActive': customer.status == CustomerStatus.active ? 1 : 0,
      'createdAt': customer.createdAt.toIso8601String(),
      'updatedAt': customer.updatedAt.toIso8601String(),
    };
  }
}
