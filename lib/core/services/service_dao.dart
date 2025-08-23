// Functional Service DAO for Android compatibility
// Provides in-memory storage with sample data

import 'package:cat_hotel_pos/features/services/domain/entities/service.dart';
// import 'package:uuid/uuid.dart';

class ServiceDao {
  static final Map<String, Service> _services = {};
  static bool _initialized = false;
  // TODO: Uncomment when implementing UUID generation
  // static final Uuid _uuid = const Uuid();

  static void _initialize() {
    if (_initialized) return;
    
    // Create sample services
    _services['service_001'] = Service(
      id: 'service_001',
      serviceCode: 'GROOM-001',
      name: 'Basic Grooming',
      category: ServiceCategory.grooming,
      price: 45.00,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Basic grooming service including bath, brush, and nail trim',
      duration: 60,
      tags: ['grooming', 'basic', 'bath', 'brush'],
      specifications: {
        'includesBath': true,
        'includesBrush': true,
        'includesNailTrim': true,
        'includesEarCleaning': false,
        'includesHaircut': false,
      },
      requirements: ['Pet must be healthy', 'No aggressive behavior'],
      requiresAppointment: true,
      maxPetsPerSession: 1,
      cancellationPolicy: '24 hours notice required',
    );

    _services['service_002'] = Service(
      id: 'service_002',
      serviceCode: 'GROOM-002',
      name: 'Premium Grooming',
      category: ServiceCategory.grooming,
      price: 75.00,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Premium grooming service with full styling and spa treatment',
      duration: 90,
      tags: ['grooming', 'premium', 'styling', 'spa'],
      specifications: {
        'includesBath': true,
        'includesBrush': true,
        'includesNailTrim': true,
        'includesEarCleaning': true,
        'includesHaircut': true,
        'includesSpaTreatment': true,
      },
      requirements: ['Pet must be healthy', 'No aggressive behavior'],
      requiresAppointment: true,
      maxPetsPerSession: 1,
      cancellationPolicy: '24 hours notice required',
    );

    _services['service_003'] = Service(
      id: 'service_003',
      serviceCode: 'TRAIN-001',
      name: 'Basic Training',
      category: ServiceCategory.training,
      price: 60.00,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Basic obedience training for cats',
      duration: 45,
      tags: ['training', 'basic', 'obedience'],
      specifications: {
        'sessionType': 'individual',
        'maxPetsPerSession': 1,
        'includesMaterials': true,
      },
      requirements: ['Pet must be healthy', 'Owner participation required'],
      requiresAppointment: true,
      maxPetsPerSession: 1,
      cancellationPolicy: '48 hours notice required',
    );

    _services['service_004'] = Service(
      id: 'service_004',
      serviceCode: 'WELL-001',
      name: 'Health Check-up',
      category: ServiceCategory.wellness,
      price: 35.00,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Basic health check-up and consultation',
      duration: 30,
      tags: ['wellness', 'health', 'checkup'],
      specifications: {
        'includesPhysicalExam': true,
        'includesConsultation': true,
        'includesBasicAdvice': true,
      },
      requirements: ['Pet must be healthy'],
      requiresAppointment: true,
      maxPetsPerSession: 1,
      cancellationPolicy: '24 hours notice required',
    );

    _services['service_005'] = Service(
      id: 'service_005',
      serviceCode: 'ADD-001',
      name: 'Extra Playtime',
      category: ServiceCategory.addOns,
      price: 15.00,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Additional 30 minutes of supervised playtime',
      duration: 30,
      tags: ['addon', 'playtime', 'supervised'],
      specifications: {
        'playtimeType': 'supervised',
        'includesToys': true,
        'includesInteraction': true,
      },
      requirements: ['Must be added to existing service'],
      requiresAppointment: false,
      maxPetsPerSession: 1,
    );

    _services['service_006'] = Service(
      id: 'service_006',
      serviceCode: 'ADD-002',
      name: 'Special Diet Preparation',
      category: ServiceCategory.addOns,
      price: 10.00,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Special diet preparation and feeding service',
      duration: 15,
      tags: ['addon', 'diet', 'feeding'],
      specifications: {
        'dietType': 'custom',
        'includesFeeding': true,
        'includesMonitoring': true,
      },
      requirements: ['Owner must provide special food'],
      requiresAppointment: false,
      maxPetsPerSession: 1,
    );

    _services['service_007'] = Service(
      id: 'service_007',
      serviceCode: 'MED-001',
      name: 'Medication Administration',
      category: ServiceCategory.medical,
      price: 20.00,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Medication administration and monitoring',
      duration: 20,
      tags: ['medical', 'medication', 'monitoring'],
      specifications: {
        'medicationType': 'oral',
        'includesMonitoring': true,
        'includesDocumentation': true,
      },
      requirements: ['Prescription required', 'Owner must provide medication'],
      requiresAppointment: false,
      maxPetsPerSession: 1,
    );

    _services['service_008'] = Service(
      id: 'service_008',
      serviceCode: 'DAY-001',
      name: 'Daycare Service',
      category: ServiceCategory.daycare,
      price: 25.00,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Full-day daycare with playtime and supervision',
      duration: 480, // 8 hours
      tags: ['daycare', 'supervision', 'playtime'],
      specifications: {
        'includesPlaytime': true,
        'includesSupervision': true,
        'includesBasicCare': true,
      },
      requirements: ['Pet must be healthy', 'Vaccination records required'],
      requiresAppointment: true,
      maxPetsPerSession: 10,
      cancellationPolicy: '24 hours notice required',
    );

    _initialized = true;
  }

  Future<void> insert(Service service) async {
    _initialize();
    _services[service.id] = service;
  }

  Future<Service?> getById(String id) async {
    _initialize();
    return _services[id];
  }

  Future<Service> create(Service service) async {
    _initialize();
    _services[service.id] = service;
    return service;
  }

  Future<List<Service>> getAll() async {
    _initialize();
    return _services.values.toList();
  }

  Future<Service> update(Service service) async {
    _initialize();
    _services[service.id] = service;
    return service;
  }

  Future<void> delete(String id) async {
    _initialize();
    _services.remove(id);
  }

  Future<List<Service>> search(String query) async {
    _initialize();
    if (query.trim().isEmpty) return _services.values.toList();
    
    final lowercaseQuery = query.toLowerCase();
    return _services.values.where((service) =>
      service.name.toLowerCase().contains(lowercaseQuery) ||
      service.serviceCode.toLowerCase().contains(lowercaseQuery) ||
      (service.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
      service.category.name.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  Future<List<Service>> getByCategory(ServiceCategory category) async {
    _initialize();
    return _services.values.where((service) => service.category == category).toList();
  }

  Future<List<Service>> getActiveServices() async {
    _initialize();
    return _services.values.where((service) => service.isActive).toList();
  }

  Future<List<Service>> getServicesByPriceRange(double minPrice, double maxPrice) async {
    _initialize();
    return _services.values.where((service) => 
      service.price >= minPrice && service.price <= maxPrice
    ).toList();
  }

  Future<List<Service>> getServicesByDuration(int maxDuration) async {
    _initialize();
    return _services.values.where((service) => 
      service.duration != null && service.duration! <= maxDuration
    ).toList();
  }

  Future<int> getTotalServices() async {
    _initialize();
    return _services.length;
  }

  Future<double> getTotalRevenue() async {
    _initialize();
    double total = 0.0;
    for (final service in _services.values) {
      total += service.price;
    }
    return total;
  }

  Future<Map<String, int>> getServicesByCategory() async {
    _initialize();
    final result = <String, int>{};
    for (final service in _services.values) {
      final category = service.category.name;
      result[category] = (result[category] ?? 0) + 1;
    }
    return result;
  }

  Future<Map<String, double>> getAveragePriceByCategory() async {
    _initialize();
    final result = <String, List<double>>{};
    for (final service in _services.values) {
      final category = service.category.name;
      if (result[category] == null) {
        result[category] = [];
      }
      result[category]!.add(service.price);
    }
    
    final averages = <String, double>{};
    for (final entry in result.entries) {
      final total = entry.value.fold(0.0, (sum, price) => sum + price);
      averages[entry.key] = total / entry.value.length;
    }
    return averages;
  }
}
