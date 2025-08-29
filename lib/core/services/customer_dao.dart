// Stub Customer DAO for Android compatibility
// This will be re-enabled when database services are restored

import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/pet.dart';
import 'package:cat_hotel_pos/core/services/pet_dao.dart';

class CustomerDao {
  // In-memory storage for desktop
  static final List<Customer> _customers = [];
  static bool _initialized = false;

  // Initialize with some sample data if empty
  static void _initialize() {
    if (_initialized) return;
    
    // Add some sample customers if the list is empty
    if (_customers.isEmpty) {
      _customers.addAll([
        Customer(
          id: 'cust_001',
          customerCode: 'CUST001',
          firstName: 'John',
          lastName: 'Smith',
          email: 'john.smith@email.com',
          phoneNumber: '+1-555-0101',
          status: CustomerStatus.active,
          source: CustomerSource.onlineBooking,
          createdAt: DateTime.now().subtract(const Duration(days: 365)),
          updatedAt: DateTime.now(),
          address: '123 Main St',
          city: 'Anytown',
          state: 'CA',
          zipCode: '12345',
          country: 'USA',
          dateOfBirth: DateTime(1985, 3, 15),
          loyaltyTier: LoyaltyTier.gold,
          lastVisitDate: DateTime.now().subtract(const Duration(days: 7)),
          totalSpent: 1250.00,
          notes: 'Prefers morning appointments',
          emergencyContacts: [
            EmergencyContact(
              id: 'ec_001',
              name: 'Jane Smith',
              relationship: 'Spouse',
              phoneNumber: '+1-555-0102',
              customerId: 'cust_001',
              email: 'jane.smith@email.com',
            ),
          ],
          isActive: true,
        ),
        Customer(
          id: 'cust_002',
          customerCode: 'CUST002',
          firstName: 'Sarah',
          lastName: 'Johnson',
          email: 'sarah.j@email.com',
          phoneNumber: '+1-555-0202',
          status: CustomerStatus.active,
          source: CustomerSource.walkIn,
          createdAt: DateTime.now().subtract(const Duration(days: 180)),
          updatedAt: DateTime.now(),
          address: '456 Oak Ave',
          city: 'Somewhere',
          state: 'NY',
          zipCode: '67890',
          country: 'USA',
          dateOfBirth: DateTime(1990, 7, 22),
          loyaltyTier: LoyaltyTier.silver,
          lastVisitDate: DateTime.now().subtract(const Duration(days: 3)),
          totalSpent: 850.00,
          notes: 'Has multiple pets, very caring owner',
          emergencyContacts: [
            EmergencyContact(
              id: 'ec_002',
              name: 'Mike Johnson',
              relationship: 'Husband',
              phoneNumber: '+1-555-0203',
              customerId: 'cust_002',
            ),
          ],
          isActive: true,
        ),
        Customer(
          id: 'cust_003',
          customerCode: 'CUST003',
          firstName: 'Michael',
          lastName: 'Brown',
          email: 'mike.brown@email.com',
          phoneNumber: '+1-555-0303',
          status: CustomerStatus.active,
          source: CustomerSource.referral,
          createdAt: DateTime.now().subtract(const Duration(days: 90)),
          updatedAt: DateTime.now(),
          address: '789 Pine St',
          city: 'Elsewhere',
          state: 'TX',
          zipCode: '11111',
          country: 'USA',
          dateOfBirth: DateTime(1978, 11, 8),
          loyaltyTier: LoyaltyTier.bronze,
          lastVisitDate: DateTime.now().subtract(const Duration(days: 14)),
          totalSpent: 450.00,
          notes: 'New customer, referred by Sarah Johnson',
          emergencyContacts: [
            EmergencyContact(
              id: 'ec_003',
              name: 'Lisa Brown',
              relationship: 'Wife',
              phoneNumber: '+1-555-0304',
              customerId: 'cust_003',
            ),
          ],
          isActive: true,
        ),
        Customer(
          id: 'cust_004',
          customerCode: 'CUST004',
          firstName: 'Emily',
          lastName: 'Davis',
          email: 'emily.davis@email.com',
          phoneNumber: '+1-555-0404',
          status: CustomerStatus.active,
          source: CustomerSource.onlineBooking,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          updatedAt: DateTime.now(),
          address: '321 Elm St',
          city: 'Newtown',
          state: 'FL',
          zipCode: '22222',
          country: 'USA',
          dateOfBirth: DateTime(1992, 4, 18),
          loyaltyTier: LoyaltyTier.bronze,
          lastVisitDate: DateTime.now().subtract(const Duration(days: 21)),
          totalSpent: 320.00,
          notes: 'Loves her cat, very attentive owner',
          emergencyContacts: [
            EmergencyContact(
              id: 'ec_004',
              name: 'David Davis',
              relationship: 'Brother',
              phoneNumber: '+1-555-0405',
              customerId: 'cust_004',
            ),
          ],
          isActive: true,
        ),
        Customer(
          id: 'cust_005',
          customerCode: 'CUST005',
          firstName: 'Robert',
          lastName: 'Wilson',
          email: 'rob.wilson@email.com',
          phoneNumber: '+1-555-0505',
          status: CustomerStatus.active,
          source: CustomerSource.walkIn,
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
          updatedAt: DateTime.now(),
          address: '654 Maple Dr',
          city: 'Oldtown',
          state: 'OH',
          zipCode: '33333',
          country: 'USA',
          dateOfBirth: DateTime(1988, 12, 3),
          loyaltyTier: LoyaltyTier.bronze,
          lastVisitDate: DateTime.now().subtract(const Duration(days: 28)),
          totalSpent: 180.00,
          notes: 'First-time pet owner, learning quickly',
          emergencyContacts: [
            EmergencyContact(
              id: 'ec_005',
              name: 'Jennifer Wilson',
              relationship: 'Sister',
              phoneNumber: '+1-555-0506',
              customerId: 'cust_005',
            ),
          ],
          isActive: true,
        ),
      ]);
      
      print('CustomerDao: Initialized with ${_customers.length} sample customers');
    }
    
    _initialized = true;
  }

  Future<void> insert(Customer customer) async {
    _initialize();
    
    // Check if customer already exists
    final existingIndex = _customers.indexWhere((c) => c.id == customer.id);
    if (existingIndex != -1) {
      _customers[existingIndex] = customer;
      print('CustomerDao: Updated existing customer: ${customer.firstName} ${customer.lastName}');
    } else {
      _customers.add(customer);
      print('CustomerDao: Added new customer: ${customer.firstName} ${customer.lastName}');
    }
  }

  Future<Customer?> getById(String id) async {
    _initialize();
    return _customers.firstWhere((customer) => customer.id == id);
  }

  Future<Customer?> getByEmail(String email) async {
    _initialize();
    try {
      return _customers.firstWhere((customer) => customer.email == email);
    } catch (e) {
      return null;
    }
  }

  Future<Customer?> getByPhone(String phone) async {
    _initialize();
    try {
      return _customers.firstWhere((customer) => customer.phoneNumber == phone);
    } catch (e) {
      return null;
    }
  }

  Future<List<Customer>> getAll({bool onlyActive = true}) async {
    _initialize();
    
    if (onlyActive) {
      return _customers.where((customer) => customer.isActive ?? false).toList();
    }
    return List.from(_customers);
  }

  Future<List<Customer>> getAllWithPets() async {
    _initialize();
    final petDao = PetDao();
    final allPets = await petDao.getAll();
    
    // Create a map of customer ID to pets
    final petsByCustomerId = <String, List<Pet>>{};
    for (final pet in allPets) {
      petsByCustomerId.putIfAbsent(pet.customerId, () => []).add(pet);
    }
    
    // Return customers with their pets
    return _customers.map((customer) {
      final customerPets = petsByCustomerId[customer.id] ?? [];
      return customer.copyWith(pets: customerPets);
    }).toList();
  }

  Future<List<Customer>> getActiveCustomers() async {
    return getAll(onlyActive: true);
  }

  Future<int> update(Customer customer) async {
    await insert(customer);
    return 1;
  }

  Future<void> delete(String id) async {
    _initialize();
    _customers.removeWhere((customer) => customer.id == id);
  }

  Future<List<Customer>> search(String query) async {
    try {
      _initialize();
      
      if (query.trim().isEmpty) {
        return [];
      }
      
      final trimmedQuery = query.trim().toLowerCase();
      
      return _customers.where((customer) {
        // Search in first name, last name, phone number, and email
        final fullName = '${customer.firstName} ${customer.lastName}'.toLowerCase();
        return customer.firstName.toLowerCase().contains(trimmedQuery) ||
               customer.lastName.toLowerCase().contains(trimmedQuery) ||
               fullName.contains(trimmedQuery) ||
               customer.phoneNumber.toLowerCase().contains(trimmedQuery) ||
               customer.email.toLowerCase().contains(trimmedQuery);
      }).toList();
    } catch (e) {
      print('CustomerDao.search: Error searching for "$query": $e');
      return [];
    }
  }

  Future<List<Customer>> getByStatus(CustomerStatus status) async {
    _initialize();
    return _customers.where((customer) => customer.status == status).toList();
  }

  Future<List<Customer>> getByRegistrationDate(DateTime startDate, DateTime endDate) async {
    _initialize();
    return _customers.where((customer) => 
      customer.createdAt.isAfter(startDate) && customer.createdAt.isBefore(endDate)
    ).toList();
  }

  Future<int> getTotalCustomers() async {
    _initialize();
    return _customers.length;
  }

  Future<int> getActiveCustomersCount() async {
    _initialize();
    return _customers.where((customer) => customer.isActive ?? false).length;
  }
}
