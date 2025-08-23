// Functional ServicePackage DAO for Android compatibility
// Provides in-memory storage with sample data

import 'package:cat_hotel_pos/features/services/domain/entities/service.dart';
// import 'package:uuid/uuid.dart';

class ServicePackageDao {
  static final Map<String, ServicePackage> _packages = {};
  static bool _initialized = false;
  // TODO: Uncomment when implementing UUID generation
  // static final Uuid _uuid = const Uuid();

  static void _initialize() {
    if (_initialized) return;
    
    // Create sample service packages
    _packages['package_001'] = ServicePackage(
      id: 'package_001',
      name: 'Grooming Essentials Package',
      description: 'Complete grooming package including basic grooming, nail trim, and ear cleaning',
      price: 120.00,
      validityDays: 90,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      serviceIds: ['service_001', 'service_005'],
      discountPercentage: 15.0,
      discountReason: 'Package discount',
      maxUses: 3,
      termsAndConditions: 'Valid for 90 days, non-refundable, must be used by the same pet',
      restrictions: ['Cannot be combined with other offers', 'Valid for one pet only'],
    );

    _packages['package_002'] = ServicePackage(
      id: 'package_002',
      name: 'Wellness & Training Combo',
      description: 'Health check-up combined with basic training session',
      price: 85.00,
      validityDays: 60,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      serviceIds: ['service_003', 'service_004'],
      discountPercentage: 10.0,
      discountReason: 'Combo package discount',
      maxUses: 2,
      termsAndConditions: 'Valid for 60 days, includes consultation and training materials',
      restrictions: ['Training session must be scheduled in advance', 'Health check required before training'],
    );

    _packages['package_003'] = ServicePackage(
      id: 'package_003',
      name: 'Premium Care Package',
      description: 'Premium grooming with extra playtime and special diet preparation',
      price: 180.00,
      validityDays: 120,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      serviceIds: ['service_002', 'service_005', 'service_006'],
      discountPercentage: 20.0,
      discountReason: 'Premium package discount',
      maxUses: 5,
      termsAndConditions: 'Valid for 120 days, includes premium grooming and additional services',
      restrictions: ['Premium grooming only', 'Cannot be split between pets'],
    );

    _packages['package_004'] = ServicePackage(
      id: 'package_004',
      name: 'Daycare Plus Package',
      description: 'Full-day daycare with extra playtime and health monitoring',
      price: 150.00,
      validityDays: 30,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      serviceIds: ['service_008', 'service_005', 'service_004'],
      discountPercentage: 25.0,
      discountReason: 'Daycare package discount',
      maxUses: 10,
      termsAndConditions: 'Valid for 30 days, includes full-day care and additional services',
      restrictions: ['Must be used within 30 days', 'Advance booking required'],
    );

    _packages['package_005'] = ServicePackage(
      id: 'package_005',
      name: 'Medical Care Package',
      description: 'Health check-up with medication administration and monitoring',
      price: 65.00,
      validityDays: 45,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      serviceIds: ['service_004', 'service_007'],
      discountPercentage: 12.0,
      discountReason: 'Medical package discount',
      maxUses: 3,
      termsAndConditions: 'Valid for 45 days, includes health assessment and medication support',
      restrictions: ['Prescription required for medication', 'Health check mandatory'],
    );

    _packages['package_006'] = ServicePackage(
      id: 'package_006',
      name: 'New Pet Welcome Package',
      description: 'Essential services for new pets including health check and basic grooming',
      price: 95.00,
      validityDays: 180,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      serviceIds: ['service_001', 'service_004', 'service_005'],
      discountPercentage: 18.0,
      discountReason: 'New pet welcome discount',
      maxUses: 1,
      termsAndConditions: 'Valid for 180 days, designed for new pet owners',
      restrictions: ['New customers only', 'First-time pet owners'],
    );

    _packages['package_007'] = ServicePackage(
      id: 'package_007',
      name: 'Senior Pet Care Package',
      description: 'Specialized care for senior pets including health monitoring and gentle grooming',
      price: 140.00,
      validityDays: 90,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      serviceIds: ['service_001', 'service_004', 'service_007'],
      discountPercentage: 22.0,
      discountReason: 'Senior pet care discount',
      maxUses: 4,
      termsAndConditions: 'Valid for 90 days, specialized for senior pets',
      restrictions: ['Pets 7+ years old only', 'Health assessment required'],
    );

    _packages['package_008'] = ServicePackage(
      id: 'package_008',
      name: 'Holiday Care Package',
      description: 'Extended care package for holiday periods with multiple services',
      price: 250.00,
      validityDays: 365,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      serviceIds: ['service_002', 'service_003', 'service_004', 'service_005', 'service_006'],
      discountPercentage: 30.0,
      discountReason: 'Holiday package discount',
      maxUses: 8,
      termsAndConditions: 'Valid for 1 year, comprehensive care package',
      restrictions: ['Holiday season only', 'Advance booking required'],
    );

    _initialized = true;
  }

  Future<void> insert(ServicePackage package) async {
    _initialize();
    _packages[package.id] = package;
  }

  Future<ServicePackage?> getById(String id) async {
    _initialize();
    return _packages[id];
  }

  Future<ServicePackage> create(ServicePackage package) async {
    _initialize();
    _packages[package.id] = package;
    return package;
  }

  Future<List<ServicePackage>> getAll() async {
    _initialize();
    return _packages.values.toList();
  }

  Future<ServicePackage> update(ServicePackage package) async {
    _initialize();
    _packages[package.id] = package;
    return package;
  }

  Future<void> delete(String id) async {
    _initialize();
    _packages.remove(id);
  }

  Future<List<ServicePackage>> search(String query) async {
    _initialize();
    if (query.trim().isEmpty) return _packages.values.toList();
    
    final lowercaseQuery = query.toLowerCase();
    return _packages.values.where((package) =>
      package.name.toLowerCase().contains(lowercaseQuery) ||
      (package.description?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }

  Future<List<ServicePackage>> getActivePackages() async {
    _initialize();
    return _packages.values.where((package) => package.isActive).toList();
  }

  Future<List<ServicePackage>> getPackagesByPriceRange(double minPrice, double maxPrice) async {
    _initialize();
    return _packages.values.where((package) => 
      package.price >= minPrice && package.price <= maxPrice
    ).toList();
  }

  Future<List<ServicePackage>> getPackagesByValidityDays(int maxDays) async {
    _initialize();
    return _packages.values.where((package) => 
      package.validityDays <= maxDays
    ).toList();
  }

  Future<List<ServicePackage>> getPackagesByDiscountPercentage(double minDiscount) async {
    _initialize();
    return _packages.values.where((package) => 
      package.discountPercentage != null && package.discountPercentage! >= minDiscount
    ).toList();
  }

  Future<int> getTotalPackages() async {
    _initialize();
    return _packages.length;
  }

  Future<double> getTotalPackageValue() async {
    _initialize();
    double total = 0.0;
    for (final package in _packages.values) {
      total += package.price;
    }
    return total;
  }

  Future<Map<String, int>> getPackagesByValidityPeriod() async {
    _initialize();
    final result = <String, int>{};
    for (final package in _packages.values) {
      String period;
      if (package.validityDays <= 30) {
        period = '1 Month';
      } else if (package.validityDays <= 90) {
        period = '3 Months';
      } else if (package.validityDays <= 180) {
        period = '6 Months';
      } else {
        period = '1 Year';
      }
      result[period] = (result[period] ?? 0) + 1;
    }
    return result;
  }

  Future<Map<String, double>> getAveragePriceByValidityPeriod() async {
    _initialize();
    final result = <String, List<double>>{};
    for (final package in _packages.values) {
      String period;
      if (package.validityDays <= 30) {
        period = '1 Month';
      } else if (package.validityDays <= 90) {
        period = '3 Months';
      } else if (package.validityDays <= 180) {
        period = '6 Months';
      } else {
        period = '1 Year';
      }
      if (result[period] == null) {
        result[period] = [];
      }
      result[period]!.add(package.price);
    }
    
    final averages = <String, double>{};
    for (final entry in result.entries) {
      final total = entry.value.fold(0.0, (sum, price) => sum + price);
      averages[entry.key] = total / entry.value.length;
    }
    return averages;
  }

  Future<List<ServicePackage>> getPackagesByServiceId(String serviceId) async {
    _initialize();
    return _packages.values.where((package) => 
      package.serviceIds?.contains(serviceId) ?? false
    ).toList();
  }

  Future<List<ServicePackage>> getPackagesByMaxUses(int maxUses) async {
    _initialize();
    return _packages.values.where((package) => 
      package.maxUses != null && package.maxUses! <= maxUses
    ).toList();
  }
}
