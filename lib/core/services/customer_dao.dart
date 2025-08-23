// Stub Customer DAO for Android compatibility
// This will be re-enabled when database services are restored

import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';

class CustomerDao {
  Future<void> insert(Customer customer) async {
    // Stub implementation
  }

  Future<Customer?> getById(String id) async {
    return null;
  }

  Future<Customer?> getByEmail(String email) async {
    return null;
  }

  Future<Customer?> getByPhone(String phone) async {
    return null;
  }

  Future<List<Customer>> getAll({bool onlyActive = true}) async {
    return [];
  }

  Future<List<Customer>> getActiveCustomers() async {
    return [];
  }

  Future<int> update(Customer customer) async {
    return 1; // Stub implementation returns 1 to indicate success
  }

  Future<void> delete(String id) async {
    // Stub implementation
  }

  Future<int> softDelete(String id) async {
    return 1; // Stub implementation returns 1 to indicate success
  }

  Future<List<Customer>> search(String query) async {
    return [];
  }

  Future<List<Customer>> getByStatus(CustomerStatus status) async {
    return [];
  }

  Future<List<Customer>> getByRegistrationDate(DateTime startDate, DateTime endDate) async {
    return [];
  }

  Future<int> getTotalCustomers() async {
    return 0;
  }

  Future<int> getActiveCustomersCount() async {
    return 0;
  }

  Future<Map<String, int>> getCustomersByStatus() async {
    return {};
  }

  Future<Map<String, int>> getCustomersByMonth() async {
    return {};
  }
}
