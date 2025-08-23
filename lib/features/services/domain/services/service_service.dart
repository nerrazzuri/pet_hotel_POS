import 'package:cat_hotel_pos/features/services/domain/entities/service.dart';
import 'package:cat_hotel_pos/core/services/service_dao.dart';
import 'package:cat_hotel_pos/core/services/service_package_dao.dart';

class ServiceService {
  final ServiceDao _serviceDao = ServiceDao();
  final ServicePackageDao _packageDao = ServicePackageDao();

  // Service Management
  Future<List<Service>> getAllServices() async {
    return await _serviceDao.getAll();
  }

  Future<List<Service>> getActiveServices() async {
    final allServices = await _serviceDao.getAll();
    return allServices.where((service) => service.isActive).toList();
  }

  Future<List<Service>> getServicesByCategory(ServiceCategory category) async {
    final allServices = await _serviceDao.getAll();
    return allServices.where((service) => 
      service.category == category && service.isActive
    ).toList();
  }

  Future<Service?> getServiceById(String id) async {
    return await _serviceDao.getById(id);
  }

  Future<Service?> getServiceByCode(String serviceCode) async {
    final allServices = await _serviceDao.getAll();
    try {
      return allServices.firstWhere((service) => service.serviceCode == serviceCode);
    } catch (e) {
      return null;
    }
  }

  Future<Service> createService({
    required String serviceCode,
    required String name,
    required ServiceCategory category,
    required double price,
    String? description,
    int? duration,
    String? imageUrl,
    List<String>? tags,
    Map<String, dynamic>? specifications,
    String? staffNotes,
    String? customerNotes,
    List<String>? requirements,
    bool? requiresAppointment,
    int? maxPetsPerSession,
    String? cancellationPolicy,
    double? depositRequired,
  }) async {
    final service = Service(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      serviceCode: serviceCode,
      name: name,
      category: category,
      price: price,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: description,
      duration: duration,
      imageUrl: imageUrl,
      tags: tags,
      specifications: specifications,
      staffNotes: staffNotes,
      customerNotes: customerNotes,
      requirements: requirements,
      requiresAppointment: requiresAppointment ?? false,
      maxPetsPerSession: maxPetsPerSession,
      cancellationPolicy: cancellationPolicy,
      depositRequired: depositRequired,
    );

    await _serviceDao.create(service);
    return service;
  }

  Future<Service> updateService(String id, Map<String, dynamic> updates) async {
    final service = await _serviceDao.getById(id);
    if (service == null) {
      throw Exception('Service not found');
    }

    // Manually update fields since copyWith doesn't support spread operator
    var updatedService = service;
    
    if (updates.containsKey('name') && updates['name'] != null) updatedService = updatedService.copyWith(name: updates['name'] as String);
    if (updates.containsKey('serviceCode') && updates['serviceCode'] != null) updatedService = updatedService.copyWith(serviceCode: updates['serviceCode'] as String);
    if (updates.containsKey('category') && updates['category'] != null) updatedService = updatedService.copyWith(category: updates['category'] as ServiceCategory);
    if (updates.containsKey('price') && updates['price'] != null) updatedService = updatedService.copyWith(price: updates['price'] as double);
    if (updates.containsKey('description')) updatedService = updatedService.copyWith(description: updates['description'] as String?);
    if (updates.containsKey('duration')) updatedService = updatedService.copyWith(duration: updates['duration'] as int?);
    if (updates.containsKey('imageUrl')) updatedService = updatedService.copyWith(imageUrl: updates['imageUrl'] as String?);
    if (updates.containsKey('tags')) updatedService = updatedService.copyWith(tags: updates['tags'] as List<String>?);
    if (updates.containsKey('specifications')) updatedService = updatedService.copyWith(specifications: updates['specifications'] as Map<String, dynamic>?);
    if (updates.containsKey('staffNotes')) updatedService = updatedService.copyWith(staffNotes: updates['staffNotes'] as String?);
    if (updates.containsKey('customerNotes')) updatedService = updatedService.copyWith(customerNotes: updates['customerNotes'] as String?);
    if (updates.containsKey('requirements')) updatedService = updatedService.copyWith(requirements: updates['requirements'] as List<String>?);
    if (updates.containsKey('requiresAppointment')) updatedService = updatedService.copyWith(requiresAppointment: updates['requiresAppointment'] as bool);
    if (updates.containsKey('maxPetsPerSession')) updatedService = updatedService.copyWith(maxPetsPerSession: updates['maxPetsPerSession'] as int?);
    if (updates.containsKey('cancellationPolicy')) updatedService = updatedService.copyWith(cancellationPolicy: updates['cancellationPolicy'] as String?);
    if (updates.containsKey('depositRequired')) updatedService = updatedService.copyWith(depositRequired: updates['depositRequired'] as double?);
    if (updates.containsKey('isActive')) updatedService = updatedService.copyWith(isActive: updates['isActive'] as bool);
    if (updates.containsKey('discountPrice')) updatedService = updatedService.copyWith(discountPrice: updates['discountPrice'] as double?);
    if (updates.containsKey('discountReason')) updatedService = updatedService.copyWith(discountReason: updates['discountReason'] as String?);
    if (updates.containsKey('discountValidUntil')) updatedService = updatedService.copyWith(discountValidUntil: updates['discountValidUntil'] as DateTime?);
    
    updatedService = updatedService.copyWith(updatedAt: DateTime.now());

    await _serviceDao.update(updatedService);
    return updatedService;
  }

  Future<void> deactivateService(String id) async {
    final service = await _serviceDao.getById(id);
    if (service == null) {
      throw Exception('Service not found');
    }

    final updatedService = service.copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );

    await _serviceDao.update(updatedService);
  }

  Future<void> deleteService(String id) async {
    await _serviceDao.delete(id);
  }

  // Pricing & Discounts
  Future<Service> applyDiscount(String serviceId, {
    required double discountPrice,
    required String reason,
    required DateTime validUntil,
  }) async {
    final service = await _serviceDao.getById(serviceId);
    if (service == null) {
      throw Exception('Service not found');
    }

    if (discountPrice >= service.price) {
      throw Exception('Discount price must be less than original price');
    }

    final updatedService = service.copyWith(
      discountPrice: discountPrice,
      discountReason: reason,
      discountValidUntil: validUntil,
      updatedAt: DateTime.now(),
    );

    await _serviceDao.update(updatedService);
    return updatedService;
  }

  Future<Service> removeDiscount(String serviceId) async {
    final service = await _serviceDao.getById(serviceId);
    if (service == null) {
      throw Exception('Service not found');
    }

    final updatedService = service.copyWith(
      discountPrice: null,
      discountReason: null,
      discountValidUntil: null,
      updatedAt: DateTime.now(),
    );

    await _serviceDao.update(updatedService);
    return updatedService;
  }

  // Service Packages
  Future<List<ServicePackage>> getAllPackages() async {
    return await _packageDao.getAll();
  }

  Future<ServicePackage?> getPackageById(String id) async {
    return await _packageDao.getById(id);
  }

  Future<ServicePackage> createPackage({
    required String name,
    required String description,
    required double price,
    required int validityDays,
    List<String>? serviceIds,
    double? discountPercentage,
    String? discountReason,
    DateTime? discountValidUntil,
    int? maxUses,
    String? termsAndConditions,
    List<String>? restrictions,
  }) async {
    final package = ServicePackage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      price: price,
      validityDays: validityDays,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      serviceIds: serviceIds,
      discountPercentage: discountPercentage,
      discountReason: discountReason,
      discountValidUntil: discountValidUntil,
      maxUses: maxUses,
      termsAndConditions: termsAndConditions,
      restrictions: restrictions,
    );

    await _packageDao.create(package);
    return package;
  }

  Future<ServicePackage> updatePackage(String id, Map<String, dynamic> updates) async {
    final package = await _packageDao.getById(id);
    if (package == null) {
      throw Exception('Package not found');
    }

    // Manually update fields since copyWith doesn't support spread operator
    var updatedPackage = package;
    
    if (updates.containsKey('name') && updates['name'] != null) updatedPackage = updatedPackage.copyWith(name: updates['name'] as String);
    if (updates.containsKey('description') && updates['description'] != null) updatedPackage = updatedPackage.copyWith(description: updates['description'] as String);
    if (updates.containsKey('price') && updates['price'] != null) updatedPackage = updatedPackage.copyWith(price: updates['price'] as double);
    if (updates.containsKey('validityDays') && updates['validityDays'] != null) updatedPackage = updatedPackage.copyWith(validityDays: updates['validityDays'] as int);
    if (updates.containsKey('serviceIds')) updatedPackage = updatedPackage.copyWith(serviceIds: updates['serviceIds'] as List<String>?);
    if (updates.containsKey('discountPercentage')) updatedPackage = updatedPackage.copyWith(discountPercentage: updates['discountPercentage'] as double?);
    if (updates.containsKey('discountReason')) updatedPackage = updatedPackage.copyWith(discountReason: updates['discountReason'] as String?);
    if (updates.containsKey('discountValidUntil')) updatedPackage = updatedPackage.copyWith(discountValidUntil: updates['discountValidUntil'] as DateTime?);
    if (updates.containsKey('maxUses')) updatedPackage = updatedPackage.copyWith(maxUses: updates['maxUses'] as int?);
    if (updates.containsKey('termsAndConditions')) updatedPackage = updatedPackage.copyWith(termsAndConditions: updates['termsAndConditions'] as String? ?? null);
    if (updates.containsKey('restrictions')) updatedPackage = updatedPackage.copyWith(restrictions: updates['restrictions'] as List<String>?);
    if (updates.containsKey('isActive')) updatedPackage = updatedPackage.copyWith(isActive: updates['isActive'] as bool);
    
    updatedPackage = updatedPackage.copyWith(updatedAt: DateTime.now());

    await _packageDao.update(updatedPackage);
    return updatedPackage;
  }

  Future<void> deactivatePackage(String id) async {
    final package = await _packageDao.getById(id);
    if (package == null) {
      throw Exception('Package not found');
    }

    final updatedPackage = package.copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );

    await _packageDao.update(updatedPackage);
  }

  // Business Logic
  Future<List<Service>> getPopularServices({int limit = 10}) async {
    final allServices = await _serviceDao.getAll();
    // TODO: Implement popularity logic based on usage/ratings
    return allServices.take(limit).toList();
  }

  Future<List<Service>> searchServices(String query) async {
    final allServices = await _serviceDao.getAll();
    final lowercaseQuery = query.toLowerCase();
    
    return allServices.where((service) =>
      service.name.toLowerCase().contains(lowercaseQuery) ||
      service.description?.toLowerCase().contains(lowercaseQuery) == true ||
      service.tags?.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) == true
    ).toList();
  }

  Future<List<Service>> getServicesByPriceRange(double minPrice, double maxPrice) async {
    final allServices = await _serviceDao.getAll();
    return allServices.where((service) =>
      service.price >= minPrice && service.price <= maxPrice
    ).toList();
  }

  Future<double> calculateServicePrice(String serviceId, {
    int? quantity = 1,
    double? customDiscount = 0.0,
  }) async {
    final service = await _serviceDao.getById(serviceId);
    if (service == null) {
      throw Exception('Service not found');
    }

    double basePrice = service.discountPrice ?? service.price;
    double totalPrice = basePrice * (quantity ?? 1);
    
    if (customDiscount != null && customDiscount > 0) {
      totalPrice = totalPrice * (1 - customDiscount);
    }

    return totalPrice;
  }

  // Validation
  bool isValidServiceCode(String serviceCode) {
    // Service code should be alphanumeric and 3-10 characters
    return RegExp(r'^[A-Za-z0-9]{3,10}$').hasMatch(serviceCode);
  }

  bool isValidPrice(double price) {
    return price > 0;
  }

  bool isValidDuration(int? duration) {
    return duration == null || duration > 0;
  }

  // Analytics
  Future<Map<String, dynamic>> getServiceAnalytics() async {
    final allServices = await _serviceDao.getAll();
    final activeServices = allServices.where((s) => s.isActive).toList();
    
    return {
      'totalServices': allServices.length,
      'activeServices': activeServices.length,
      'inactiveServices': allServices.length - activeServices.length,
      'averagePrice': allServices.isNotEmpty 
          ? allServices.map((s) => s.price).reduce((a, b) => a + b) / allServices.length 
          : 0.0,
      'servicesByCategory': ServiceCategory.values.map((category) {
        final count = allServices.where((s) => s.category == category).length;
        return {'category': category.name, 'count': count};
      }).toList(),
      'discountedServices': allServices.where((s) => s.discountPrice != null).length,
    };
  }
}
