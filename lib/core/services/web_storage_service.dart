
import 'package:flutter/foundation.dart';
import 'package:cat_hotel_pos/features/auth/domain/services/password_service.dart';

// Conditional imports for web vs non-web platforms
import 'web_storage_service_stub.dart' if (dart.library.html) 'web_storage_service_web.dart';

/// Web-compatible storage service using localStorage
/// This provides the same interface as DatabaseService for web platforms
class WebStorageService {
  static const String _prefix = 'cat_hotel_pos_';
  static const String _usersKey = '${_prefix}users';
  static const String _customersKey = '${_prefix}customers';
  static const String _petsKey = '${_prefix}pets';
  static const String _roomsKey = '${_prefix}rooms';
  static const String _bookingsKey = '${_prefix}bookings';
  // TODO: Uncomment when implementing these storage keys
  // static const String _auditLogsKey = '${_prefix}audit_logs';
  // static const String _posCartsKey = '${_prefix}pos_carts';
  // static const String _posTransactionsKey = '${_prefix}pos_transactions';
  // static const String _inventoryKey = '${_prefix}inventory';
	static const String _suppliersKey = '${_prefix}suppliers';
	static const String _purchaseOrdersKey = '${_prefix}purchase_orders';
	static const String _purchaseOrderItemsKey = '${_prefix}purchase_order_items';
	static const String _productsKey = '${_prefix}products';
	static const String _inventoryTransactionsKey = '${_prefix}inventory_transactions';

  static bool get isAvailable => true; // Make available on all platforms

  /// Initialize web storage (no-op for web, but provides consistent interface)
  static Future<void> initialize() async {
    print('WebStorageService.initialize() called');
    print('kIsWeb: $kIsWeb');
    print('isAvailable: $isAvailable');
    
    if (!isAvailable) {
      print('WebStorageService is not available, throwing error');
      throw UnsupportedError('WebStorageService is only available on web platforms');
    }
    // Web storage is automatically available
    print('Web storage initialized');
  }

  /// Get data from localStorage
  static List<Map<String, dynamic>> getData(String key) {
    print('_getData called with key: $key');
    print('kIsWeb: $kIsWeb');
    print('isAvailable: $isAvailable');
    
    if (!isAvailable) {
      print('_getData: Not available, returning empty list');
      return [];
    }
    
    try {
      print('_getData: Creating WebStorageImplementation...');
      final implementation = WebStorageImplementation();
      print('_getData: WebStorageImplementation created successfully');
      final result = implementation.getData(key);
      print('_getData: Retrieved ${result.length} items for key: $key');
      return result;
    } catch (e) {
      print('Error reading from web storage: $e');
      print('Error stack trace: ${StackTrace.current}');
      return [];
    }
  }

  /// Save data to localStorage
  static void saveData(String key, List<Map<String, dynamic>> data) {
    print('_saveData called with key: $key, data count: ${data.length}');
    print('kIsWeb: $kIsWeb');
    print('isAvailable: $isAvailable');
    
    if (!isAvailable) {
      print('_saveData: Not available, returning early');
      return;
    }
    
    try {
      print('_saveData: Creating WebStorageImplementation...');
      final implementation = WebStorageImplementation();
      print('_saveData: WebStorageImplementation created successfully');
      implementation.saveData(key, data);
      print('_saveData: Successfully saved ${data.length} items for key: $key');
    } catch (e) {
      print('Error saving to web storage: $e');
      print('Error stack trace: ${StackTrace.current}');
    }
  }

  /// Remove data for a specific key
  static void removeData(String key) {
    print('_removeData called with key: $key');
    print('kIsWeb: $kIsWeb');
    print('isAvailable: $isAvailable');
    
    if (!isAvailable) {
      print('_removeData: Not available, returning early');
      return;
    }
    
    try {
      print('_removeData: Creating WebStorageImplementation...');
      final implementation = WebStorageImplementation();
      print('_removeData: WebStorageImplementation created successfully');
      implementation.removeData(key);
      print('_removeData: Successfully removed data for key: $key');
    } catch (e) {
      print('Error removing from web storage: $e');
      print('Error stack trace: ${StackTrace.current}');
    }
  }

  /// Get all users
  static List<Map<String, dynamic>> getAllUsers() {
    return getData(_usersKey);
  }

  /// Insert or update a user
  static void saveUser(Map<String, dynamic> user) {
    final users = getData(_usersKey);
    final existingIndex = users.indexWhere((u) => u['id'] == user['id']);
    
    if (existingIndex >= 0) {
      users[existingIndex] = user;
    } else {
      users.add(user);
    }
    
    saveData(_usersKey, users);
  }

  /// Get all customers
  static List<Map<String, dynamic>> getAllCustomers() {
    return getData(_customersKey);
  }

  /// Insert or update a customer
  static void saveCustomer(Map<String, dynamic> customer) {
    final customers = getData(_customersKey);
    final existingIndex = customers.indexWhere((c) => c['id'] == customer['id']);
    
    if (existingIndex >= 0) {
      customers[existingIndex] = customer;
    } else {
      customers.add(customer);
    }
    
    saveData(_customersKey, customers);
  }

  /// Get all pets
  static List<Map<String, dynamic>> getAllPets() {
    return getData(_petsKey);
  }

  /// Insert or update a pet
  static void savePet(Map<String, dynamic> pet) {
    final pets = getData(_petsKey);
    final existingIndex = pets.indexWhere((p) => p['id'] == pet['id']);
    
    if (existingIndex >= 0) {
      pets[existingIndex] = pet;
    } else {
      pets.add(pet);
    }
    
    saveData(_petsKey, pets);
  }

  /// Get all rooms
  static List<Map<String, dynamic>> getAllRooms() {
    return getData(_roomsKey);
  }

  /// Insert or update a room
  static void saveRoom(Map<String, dynamic> room) {
    final rooms = getData(_roomsKey);
    final existingIndex = rooms.indexWhere((r) => r['id'] == room['id']);
    
    if (existingIndex >= 0) {
      rooms[existingIndex] = room;
    } else {
      rooms.add(room);
    }
    
    saveData(_roomsKey, rooms);
  }

  /// Get all bookings
  static List<Map<String, dynamic>> getAllBookings() {
    return getData(_bookingsKey);
  }

  /// Insert or update a booking
  static void saveBooking(Map<String, dynamic> booking) {
    final bookings = getData(_bookingsKey);
    final existingIndex = bookings.indexWhere((b) => b['id'] == booking['id']);
    
    if (existingIndex >= 0) {
      bookings[existingIndex] = booking;
    } else {
      bookings.add(booking);
    }
    
    saveData(_bookingsKey, bookings);
  }

  	/// Get all suppliers
	static List<Map<String, dynamic>> getAllSuppliers() {
		    return getData(_suppliersKey);
	}

	/// Insert or update a supplier
	static void saveSupplier(Map<String, dynamic> supplier) {
		    final suppliers = getData(_suppliersKey);
		final existingIndex = suppliers.indexWhere((s) => s['id'] == supplier['id']);
		
		if (existingIndex >= 0) {
			suppliers[existingIndex] = supplier;
		} else {
			suppliers.add(supplier);
		}
		
		    saveData(_suppliersKey, suppliers);
	}

	/// Get all purchase orders
	static List<Map<String, dynamic>> getAllPurchaseOrders() {
		    return getData(_purchaseOrdersKey);
	}

	/// Save purchase orders
	static void savePurchaseOrders(List<Map<String, dynamic>> purchaseOrders) {
		    saveData(_purchaseOrdersKey, purchaseOrders);
	}

	/// Get all purchase order items
	static List<Map<String, dynamic>> getAllPurchaseOrderItems() {
		    return getData(_purchaseOrderItemsKey);
	}

	/// Save purchase order items
	static void savePurchaseOrderItems(List<Map<String, dynamic>> purchaseOrderItems) {
		    saveData(_purchaseOrderItemsKey, purchaseOrderItems);
	}

	/// Get all products
	static List<Map<String, dynamic>> getAllProducts() {
		    return getData(_productsKey);
	}

	/// Save products
	static void saveProducts(List<Map<String, dynamic>> products) {
		    saveData(_productsKey, products);
	}

	/// Get all inventory transactions
	static List<Map<String, dynamic>> getAllInventoryTransactions() {
		    return getData(_inventoryTransactionsKey);
	}

	/// Save inventory transactions
	static void saveInventoryTransactions(List<Map<String, dynamic>> transactions) {
		    saveData(_inventoryTransactionsKey, transactions);
	}

  /// Clear all data (useful for testing)
  static void clearAll() {
    if (!isAvailable) return;
    
    try {
      final implementation = WebStorageImplementation();
      implementation.clearAll();
    } catch (e) {
      print('Error clearing web storage: $e');
    }
  }

  /// Seed default data for web platform
  static void seedDefaultData() {
    print('WebStorageService.seedDefaultData() called');
    print('isAvailable: $isAvailable');
    
    if (!isAvailable) {
      print('WebStorageService is not available, returning early');
      return;
    }

    // Check if data already exists
    final users = getData(_usersKey);
    print('Existing users count: ${users.length}');
    
    if (users.isNotEmpty) {
      print('Data already exists, returning early');
      return;
    }

    print('Creating default users with secure password hashing...');
    // Create default users with properly hashed passwords
    final defaultUsers = [
      {
        'id': 'admin',
        'username': 'admin',
        'email': 'admin@cathotel.com',
        'fullName': 'System Administrator',
        'role': 'administrator',
        'permissions': '{"dashboard": true, "users": true, "customers": true, "bookings": true, "rooms": true, "pos": true, "reports": true}',
        'isActive': true,
        'status': 'active',
        'department': 'IT',
        'position': 'System Administrator',
        'hireDate': DateTime.now().toIso8601String(),
        'passwordHash': PasswordService.createPasswordHash('admin123'), // Properly hashed password
        'createdAt': DateTime.now().toIso8601String(),
        'lastLoginAt': DateTime.now().toIso8601String(),
        'failedLoginAttempts': 0,
        'lockoutUntil': null,
        'lastPasswordChange': DateTime.now().toIso8601String(),
      },
      {
        'id': 'owner',
        'username': 'owner',
        'email': 'owner@cathotel.com',
        'fullName': 'Business Owner',
        'role': 'owner',
        'permissions': '{"dashboard": true, "users": true, "customers": true, "bookings": true, "rooms": true, "pos": true, "reports": true}',
        'isActive': true,
        'status': 'active',
        'department': 'Management',
        'position': 'Owner',
        'hireDate': DateTime.now().toIso8601String(),
        'passwordHash': PasswordService.createPasswordHash('owner123'), // Properly hashed password
        'createdAt': DateTime.now().toIso8601String(),
        'lastLoginAt': DateTime.now().toIso8601String(),
        'failedLoginAttempts': 0,
        'lockoutUntil': null,
        'lastPasswordChange': DateTime.now().toIso8601String(),
      },
      {
        'id': 'manager',
        'username': 'manager',
        'email': 'manager@cathotel.com',
        'fullName': 'General Manager',
        'role': 'manager',
        'permissions': '{"dashboard": true, "users": false, "customers": true, "bookings": true, "rooms": true, "pos": true, "reports": false}',
        'isActive': true,
        'status': 'active',
        'department': 'Operations',
        'position': 'General Manager',
        'hireDate': DateTime.now().toIso8601String(),
        'passwordHash': PasswordService.createPasswordHash('manager123'), // Properly hashed password
        'createdAt': DateTime.now().toIso8601String(),
        'lastLoginAt': DateTime.now().toIso8601String(),
        'failedLoginAttempts': 0,
        'lockoutUntil': null,
        'lastPasswordChange': DateTime.now().toIso8601String(),
      },
      {
        'id': 'staff',
        'username': 'staff',
        'email': 'staff@cathotel.com',
        'fullName': 'Front Desk Staff',
        'role': 'staff',
        'permissions': '{"dashboard": true, "users": false, "customers": true, "bookings": true, "rooms": true, "pos": false, "reports": false}',
        'isActive': true,
        'status': 'active',
        'department': 'Front Desk',
        'position': 'Customer Service Representative',
        'hireDate': DateTime.now().toIso8601String(),
        'passwordHash': PasswordService.createPasswordHash('staff123'), // Properly hashed password
        'createdAt': DateTime.now().toIso8601String(),
        'lastLoginAt': DateTime.now().toIso8601String(),
        'failedLoginAttempts': 0,
        'lockoutUntil': null,
        'lastPasswordChange': DateTime.now().toIso8601String(),
      },
    ];

    saveData(_usersKey, defaultUsers);
    print('Default users saved, count: ${defaultUsers.length}');

    print('Creating default customers...');
    // Create default customers
    final defaultCustomers = [
      {
        'id': 'cust001',
        'customerCode': 'CUST001',
        'firstName': 'John',
        'lastName': 'Doe',
        'email': 'john.doe@email.com',
        'phone': '+1-555-0101',
        'address': '123 Main St, Anytown, USA',
        'emergencyContact': 'Jane Doe',
        'emergencyPhone': '+1-555-0102',
        'loyaltyPoints': 150,
        'loyaltyTier': 'Silver',
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'cust002',
        'customerCode': 'CUST002',
        'firstName': 'Sarah',
        'lastName': 'Smith',
        'email': 'sarah.smith@email.com',
        'phone': '+1-555-0202',
        'address': '456 Oak Ave, Somewhere, USA',
        'emergencyContact': 'Mike Smith',
        'emergencyPhone': '+1-555-0203',
        'loyaltyPoints': 75,
        'loyaltyTier': 'Bronze',
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'id': 'cust003',
        'customerCode': 'CUST003',
        'firstName': 'Michael',
        'lastName': 'Johnson',
        'email': 'michael.johnson@email.com',
        'phone': '+1-555-0303',
        'address': '789 Pine Rd, Elsewhere, USA',
        'emergencyContact': 'Lisa Johnson',
        'emergencyPhone': '+1-555-0304',
        'loyaltyPoints': 300,
        'loyaltyTier': 'Gold',
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];

    saveData(_customersKey, defaultCustomers);
    print('Default customers saved, count: ${defaultCustomers.length}');
    
    print('Creating default suppliers...');
    // Create default suppliers
    final defaultSuppliers = [
      {
        'id': 'sup001',
        'name': 'Pet Food Distributors Inc',
        'companyName': 'Pet Food Distributors Inc',
        'contactPerson': 'Sarah Johnson',
        'email': 'sarah@petfooddist.com',
        'phone': '+1-555-1001',
        'address': '123 Pet Supply Blvd',
        'city': 'Pet City',
        'state': 'CA',
        'zipCode': '90210',
        'country': 'USA',
        'website': 'https://petfooddist.com',
        'taxId': null,
        'paymentTerms': 'Net 30',
        'creditLimit': 10000.0,
        'notes': 'Primary pet food supplier',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'categories': ['Pet Food', 'Treats'],
        'metadata': null,
      },
      {
        'id': 'sup002',
        'name': 'Quality Pet Supplies',
        'companyName': 'Quality Pet Supplies LLC',
        'contactPerson': 'Mike Chen',
        'email': 'mike@qualitypet.com',
        'phone': '+1-555-2002',
        'address': '456 Supply Lane',
        'city': 'Supplier Town',
        'state': 'TX',
        'zipCode': '75001',
        'country': 'USA',
        'website': 'https://qualitypet.com',
        'taxId': null,
        'paymentTerms': 'Net 15',
        'creditLimit': 5000.0,
        'notes': 'Toys and accessories supplier',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'categories': ['Toys', 'Accessories', 'Grooming'],
        'metadata': null,
      },
      {
        'id': 'sup003',
        'name': 'Veterinary Supplies Co',
        'companyName': 'Veterinary Supplies Co',
        'contactPerson': 'Dr. Emily Rodriguez',
        'email': 'emily@vetsupp.com',
        'phone': '+1-555-3003',
        'address': '789 Medical Drive',
        'city': 'Health Valley',
        'state': 'FL',
        'zipCode': '33101',
        'country': 'USA',
        'website': 'https://vetsupp.com',
        'taxId': null,
        'paymentTerms': 'Net 45',
        'creditLimit': 15000.0,
        'notes': 'Medical and health supplies',
        'isActive': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'categories': ['Health', 'Medical', 'Cleaning'],
        'metadata': null,
      },
    ];

    saveData(_suppliersKey, defaultSuppliers);
    print('Default suppliers saved, count: ${defaultSuppliers.length}');
    
    // Verify the data was saved
    final savedUsers = getData(_usersKey);
    final savedCustomers = getData(_customersKey);
    final savedSuppliers = getData(_suppliersKey);
    print('Verification - Saved users: ${savedUsers.length}, Saved customers: ${savedCustomers.length}, Saved suppliers: ${savedSuppliers.length}');
    
    print('Default users, customers, and suppliers seeded in web storage');
  }

  /// Test method to verify web storage is working
  static void testWebStorage() {
    print('=== WebStorageService.testWebStorage() ===');
    print('kIsWeb: $kIsWeb');
    print('isAvailable: $isAvailable');
    
    if (!isAvailable) {
      print('Web storage is not available');
      return;
    }
    
    try {
      print('Testing WebStorageImplementation creation...');
      final implementation = WebStorageImplementation();
      print('WebStorageImplementation created successfully');
      
      print('Testing data operations...');
      final testData = [{'test': 'value', 'timestamp': DateTime.now().toIso8601String()}];
      
      print('Saving test data...');
      implementation.saveData('test_key', testData);
      print('Test data saved');
      
      print('Retrieving test data...');
      final retrievedData = implementation.getData('test_key');
      print('Retrieved ${retrievedData.length} test items');
      
      print('Test data content: $retrievedData');
      
      print('Testing customer data operations...');
      final customers = getAllCustomers();
      print('Found ${customers.length} customers in storage');
      
      print('Testing manual customer data save...');
      final testCustomer = {
        'id': 'test123',
        'customerCode': 'TEST123',
        'firstName': 'Test',
        'lastName': 'Customer',
        'email': 'test@example.com',
        'phone': '+1-555-0999',
        'isActive': 1,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };
      saveCustomer(testCustomer);
      print('Test customer saved');
      
      final customersAfter = getAllCustomers();
      print('Found ${customersAfter.length} customers after adding test customer');
      
      print('Cleaning up test data...');
      implementation.clearAll();
      print('Test data cleaned up');
      
      print('=== WebStorageService test completed successfully ===');
    } catch (e) {
      print('Error during web storage test: $e');
      print('Error stack trace: ${StackTrace.current}');
    }
  }
}
