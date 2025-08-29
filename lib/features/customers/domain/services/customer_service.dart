import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';
import 'package:cat_hotel_pos/core/services/customer_dao.dart';
import 'package:cat_hotel_pos/core/services/web_customer_dao.dart';
import 'package:flutter/foundation.dart';

class CustomerService {
  late final dynamic _customerDao;

  CustomerService() {
    try {
      print('CustomerService: Constructor called, kIsWeb: $kIsWeb');
      if (kIsWeb) {
        print('CustomerService: Creating WebCustomerDao...');
        _customerDao = WebCustomerDao();
        print('CustomerService: WebCustomerDao created successfully');
      } else {
        print('CustomerService: Creating CustomerDao...');
        _customerDao = CustomerDao();
        print('CustomerService: CustomerDao created successfully');
      }
      print('CustomerService: Constructor completed successfully');
    } catch (e) {
      print('CustomerService: Error in constructor: $e');
      print('CustomerService: Stack trace: ${StackTrace.current}');
      rethrow;
    }
  }

  // Create a new customer
  Future<Customer> createCustomer({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    String? email,
    String? address,
    List<String>? emergencyContacts,
    int? loyaltyPoints,
  }) async {
    // Convert emergency contact strings to EmergencyContact objects
    List<EmergencyContact>? emergencyContactObjects;
    if (emergencyContacts != null && emergencyContacts.isNotEmpty) {
      emergencyContactObjects = emergencyContacts.map((contact) => EmergencyContact(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: contact,
        relationship: 'Emergency Contact',
        phoneNumber: '',
        customerId: DateTime.now().millisecondsSinceEpoch.toString(),
        isActive: true,
      )).toList();
    }

    final customer = Customer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerCode: 'CUST${DateTime.now().millisecondsSinceEpoch}',
      firstName: firstName,
      lastName: lastName,
      email: email ?? '',
      phoneNumber: phoneNumber,
      source: CustomerSource.walkIn, // Default to walk-in for new customers
      status: CustomerStatus.active,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      address: address,
      loyaltyPoints: loyaltyPoints ?? 0,
      emergencyContacts: emergencyContactObjects,
      pets: [],
    );

    await _customerDao.insert(customer);
    return customer;
  }

  // Update an existing customer
  Future<Customer> updateCustomer({
    required String customerId,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? address,
    CustomerStatus? status,
    List<String>? emergencyContacts,
    int? loyaltyPoints,
  }) async {
    final existingCustomer = await _customerDao.getById(customerId);
    if (existingCustomer == null) {
      throw Exception('Customer not found');
    }

    final updatedCustomer = existingCustomer.copyWith(
      firstName: firstName ?? existingCustomer.firstName,
      lastName: lastName ?? existingCustomer.lastName,
      email: email ?? existingCustomer.email,
      phoneNumber: phoneNumber ?? existingCustomer.phoneNumber,
      status: status ?? existingCustomer.status,
      address: address ?? existingCustomer.address,
      emergencyContacts: emergencyContacts ?? existingCustomer.emergencyContacts,
      loyaltyPoints: loyaltyPoints ?? existingCustomer.loyaltyPoints,
      updatedAt: DateTime.now(),
    );

    await _customerDao.update(updatedCustomer);
    return updatedCustomer;
  }

  // Soft delete a customer
  Future<void> deleteCustomer(String customerId) async {
    await _customerDao.softDelete(customerId);
  }

  // Get customer by ID
  Future<Customer?> getCustomerById(String customerId) async {
    return await _customerDao.getById(customerId);
  }

  // Get all customers
  Future<List<Customer>> getAllCustomers({bool onlyActive = true}) async {
    try {
      print('CustomerService.getAllCustomers: Called with onlyActive: $onlyActive');
      print('CustomerService.getAllCustomers: _customerDao type: ${_customerDao.runtimeType}');
      
      final customers = await _customerDao.getAll(onlyActive: onlyActive);
      print('CustomerService.getAllCustomers: Successfully retrieved ${customers.length} customers');
      
      // Debug: Print customer names if any found
      if (customers.isNotEmpty) {
        print('CustomerService.getAllCustomers: Customers found: ${customers.map((c) => c.fullName).join(', ')}');
      }
      
      return customers;
    } catch (e) {
      print('CustomerService.getAllCustomers: Error: $e');
      print('CustomerService.getAllCustomers: Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Search customers
  Future<List<Customer>> searchCustomers(String query) async {
    try {
      print('CustomerService.searchCustomers: Called with query: "$query"');
      
      if (query.trim().isEmpty) {
        print('CustomerService.searchCustomers: Empty query, calling getAll()');
        final result = await _customerDao.getAll(onlyActive: true);
        print('CustomerService.searchCustomers: getAll() returned ${result.length} customers');
        return result;
      }
      
      print('CustomerService.searchCustomers: Calling search with trimmed query: "${query.trim()}"');
      final result = await _customerDao.search(query.trim());
      print('CustomerService.searchCustomers: Successfully retrieved ${result.length} customers');
      
      // Debug: Print customer names found
      if (result.isNotEmpty) {
        print('CustomerService.searchCustomers: Found customers: ${result.map((c) => c.fullName).join(', ')}');
      }
      
      return result;
    } catch (e) {
      print('CustomerService.searchCustomers: Error: $e');
      print('CustomerService.searchCustomers: Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Get customers by status
  Future<List<Customer>> getCustomersByStatus(CustomerStatus status) async {
    final allCustomers = await _customerDao.getAll(onlyActive: false);
    return allCustomers.where((c) => c.status == status).toList();
  }

  // Add loyalty points
  Future<void> addLoyaltyPoints(String customerId, int points) async {
    final customer = await _customerDao.getById(customerId);
    if (customer == null) {
      throw Exception('Customer not found');
    }

    final newPoints = (customer.loyaltyPoints ?? 0) + points;
    final updatedCustomer = customer.copyWith(
      loyaltyPoints: newPoints,
      updatedAt: DateTime.now(),
    );

    await _customerDao.update(updatedCustomer);
  }

  // Update customer status
  Future<void> updateCustomerStatus(String customerId, CustomerStatus status) async {
    final customer = await _customerDao.getById(customerId);
    if (customer == null) {
      throw Exception('Customer not found');
    }

    final updatedCustomer = customer.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );

    await _customerDao.update(updatedCustomer);
  }
}
