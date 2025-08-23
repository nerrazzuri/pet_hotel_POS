import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';
import 'package:cat_hotel_pos/features/customers/domain/services/customer_service.dart';

// Customer service provider
final customerServiceProvider = Provider<CustomerService>((ref) {
  return CustomerService();
});

// All customers provider
final customersProvider = FutureProvider<List<Customer>>((ref) async {
  try {
    print('customersProvider: Called');
    
    final customerService = ref.read(customerServiceProvider);
    print('customersProvider: CustomerService retrieved: ${customerService.runtimeType}');
    
    final result = await customerService.getAllCustomers();
    print('customersProvider: Successfully retrieved ${result.length} customers');
    return result;
  } catch (e) {
    print('customersProvider: Error occurred: $e');
    print('customersProvider: Stack trace: ${StackTrace.current}');
    rethrow;
  }
});

// Active customers provider
final activeCustomersProvider = FutureProvider<List<Customer>>((ref) async {
  final customerService = ref.read(customerServiceProvider);
  return await customerService.getAllCustomers(onlyActive: true);
});

// Customer search provider
final customerSearchProvider = StateProvider<String>((ref) => '');

// Filtered customers provider
final filteredCustomersProvider = FutureProvider.family<List<Customer>, String>((ref, query) async {
  try {
    print('filteredCustomersProvider: Called with query: "$query"');
    
    final customerService = ref.read(customerServiceProvider);
    print('filteredCustomersProvider: CustomerService retrieved: ${customerService.runtimeType}');
    
    if (query.trim().isEmpty) {
      print('filteredCustomersProvider: Empty query, calling getAllCustomers()');
      final result = await customerService.getAllCustomers();
      print('filteredCustomersProvider: getAllCustomers returned ${result.length} customers');
      return result;
    }
    
    print('filteredCustomersProvider: Calling searchCustomers with: "${query.trim()}"');
    final result = await customerService.searchCustomers(query);
    print('filteredCustomersProvider: searchCustomers returned ${result.length} customers');
    return result;
  } catch (e) {
    print('filteredCustomersProvider: Error occurred: $e');
    print('filteredCustomersProvider: Stack trace: ${StackTrace.current}');
    rethrow;
  }
});

// Customer by ID provider
final customerByIdProvider = FutureProvider.family<Customer?, String>((ref, customerId) async {
  final customerService = ref.read(customerServiceProvider);
  return await customerService.getCustomerById(customerId);
});

// Customer status filter provider
final customerStatusFilterProvider = StateProvider<CustomerStatus?>((ref) => null);

// Filtered customers by status provider
final customersByStatusProvider = FutureProvider.family<List<Customer>, CustomerStatus?>((ref, status) async {
  final customerService = ref.read(customerServiceProvider);
  if (status == null) {
    return await customerService.getAllCustomers();
  }
  return await customerService.getCustomersByStatus(status);
});
