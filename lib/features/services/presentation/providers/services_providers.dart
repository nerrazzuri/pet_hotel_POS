import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/services/domain/entities/service.dart';
import 'package:cat_hotel_pos/features/services/domain/entities/product.dart';
import 'package:cat_hotel_pos/features/services/domain/services/service_service.dart';
import 'package:cat_hotel_pos/features/services/domain/services/product_service.dart';

// Service instances
final serviceServiceProvider = Provider<ServiceService>((ref) => ServiceService());
final productServiceProvider = Provider<ProductService>((ref) => ProductService());

// Services providers
final allServicesProvider = FutureProvider<List<Service>>((ref) async {
  final serviceService = ref.read(serviceServiceProvider);
  return await serviceService.getAllServices();
});

final activeServicesProvider = FutureProvider<List<Service>>((ref) async {
  final serviceService = ref.read(serviceServiceProvider);
  return await serviceService.getActiveServices();
});

final servicesByCategoryProvider = FutureProvider.family<List<Service>, ServiceCategory>((ref, category) async {
  final serviceService = ref.read(serviceServiceProvider);
  return await serviceService.getServicesByCategory(category);
});

final serviceByIdProvider = FutureProvider.family<Service?, String>((ref, id) async {
  final serviceService = ref.read(serviceServiceProvider);
  return await serviceService.getServiceById(id);
});

final serviceByCodeProvider = FutureProvider.family<Service?, String>((ref, serviceCode) async {
  final serviceService = ref.read(serviceServiceProvider);
  return await serviceService.getServiceByCode(serviceCode);
});

// Service packages providers
final allPackagesProvider = FutureProvider<List<ServicePackage>>((ref) async {
  final serviceService = ref.read(serviceServiceProvider);
  return await serviceService.getAllPackages();
});

final packageByIdProvider = FutureProvider.family<ServicePackage?, String>((ref, id) async {
  final serviceService = ref.read(serviceServiceProvider);
  return await serviceService.getPackageById(id);
});

// Products providers
final allProductsProvider = FutureProvider<List<Product>>((ref) async {
  final productService = ref.read(productServiceProvider);
  return await productService.getAllProducts();
});

final activeProductsProvider = FutureProvider<List<Product>>((ref) async {
  final productService = ref.read(productServiceProvider);
  return await productService.getActiveProducts();
});

final productsByCategoryProvider = FutureProvider.family<List<Product>, ProductCategory>((ref, category) async {
  final productService = ref.read(productServiceProvider);
  return await productService.getProductsByCategory(category);
});

final productByIdProvider = FutureProvider.family<Product?, String>((ref, id) async {
  final productService = ref.read(productServiceProvider);
  return await productService.getProductById(id);
});

final productByCodeProvider = FutureProvider.family<Product?, String>((ref, productCode) async {
  final productService = ref.read(productServiceProvider);
  return await productService.getProductByCode(productCode);
});

final productByBarcodeProvider = FutureProvider.family<Product?, String>((ref, barcode) async {
  final productService = ref.read(productServiceProvider);
  return await productService.getProductByBarcode(barcode);
});

// Product bundles providers
final allBundlesProvider = FutureProvider<List<ProductBundle>>((ref) async {
  final productService = ref.read(productServiceProvider);
  return await productService.getAllBundles();
});

final bundleByIdProvider = FutureProvider.family<ProductBundle?, String>((ref, id) async {
  final productService = ref.read(productServiceProvider);
  return await productService.getBundleById(id);
});

// Inventory management providers
final lowStockProductsProvider = FutureProvider<List<Product>>((ref) async {
  final productService = ref.read(productServiceProvider);
  return await productService.getLowStockProducts();
});

final outOfStockProductsProvider = FutureProvider<List<Product>>((ref) async {
  final productService = ref.read(productServiceProvider);
  return await productService.getOutOfStockProducts();
});

// Search providers
final servicesSearchProvider = FutureProvider.family<List<Service>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final serviceService = ref.read(serviceServiceProvider);
  return await serviceService.searchServices(query);
});

final productsSearchProvider = FutureProvider.family<List<Product>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final productService = ref.read(productServiceProvider);
  return await productService.searchProducts(query);
});

// Price range providers
final servicesByPriceRangeProvider = FutureProvider.family<List<Service>, Map<String, double>>((ref, range) async {
  final serviceService = ref.read(serviceServiceProvider);
  return await serviceService.getServicesByPriceRange(range['min']!, range['max']!);
});

final productsByPriceRangeProvider = FutureProvider.family<List<Product>, Map<String, double>>((ref, range) async {
  final productService = ref.read(productServiceProvider);
  return await productService.getProductsByPriceRange(range['min']!, range['max']!);
});

// Popular items providers
final popularServicesProvider = FutureProvider<List<Service>>((ref) async {
  final serviceService = ref.read(serviceServiceProvider);
  return await serviceService.getPopularServices(limit: 10);
});

final popularProductsProvider = FutureProvider<List<Product>>((ref) async {
  final productService = ref.read(productServiceProvider);
  return await productService.getPopularProducts(limit: 10);
});

// Analytics providers
final serviceAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final serviceService = ref.read(serviceServiceProvider);
  return await serviceService.getServiceAnalytics();
});

final productAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final productService = ref.read(productServiceProvider);
  return await productService.getProductAnalytics();
});

// Combined analytics provider
final servicesProductsAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final serviceAnalytics = await ref.read(serviceAnalyticsProvider.future);
  final productAnalytics = await ref.read(productAnalyticsProvider.future);
  
  return {
    'services': serviceAnalytics,
    'products': productAnalytics,
    'summary': {
      'totalServices': serviceAnalytics['totalServices'] ?? 0,
      'totalProducts': productAnalytics['totalProducts'] ?? 0,
      'totalItems': (serviceAnalytics['totalServices'] ?? 0) + (productAnalytics['totalProducts'] ?? 0),
      'activeServices': serviceAnalytics['activeServices'] ?? 0,
      'activeProducts': productAnalytics['activeProducts'] ?? 0,
      'totalActiveItems': (serviceAnalytics['activeServices'] ?? 0) + (productAnalytics['activeProducts'] ?? 0),
    }
  };
});

// State notifiers for CRUD operations
class ServicesNotifier extends StateNotifier<AsyncValue<List<Service>>> {
  final ServiceService _serviceService;
  
  ServicesNotifier(this._serviceService) : super(const AsyncValue.loading()) {
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      state = const AsyncValue.loading();
      final services = await _serviceService.getAllServices();
      state = AsyncValue.data(services);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadServices();
  }

  Future<void> addService(Service service) async {
    try {
      await _serviceService.createService(
        serviceCode: service.serviceCode,
        name: service.name,
        category: service.category,
        price: service.price,
        description: service.description,
        duration: service.duration,
        imageUrl: service.imageUrl,
        tags: service.tags,
        specifications: service.specifications,
        staffNotes: service.staffNotes,
        customerNotes: service.customerNotes,
        requirements: service.requirements,
        requiresAppointment: service.requiresAppointment,
        maxPetsPerSession: service.maxPetsPerSession,
        cancellationPolicy: service.cancellationPolicy,
        depositRequired: service.depositRequired,
      );
      await _loadServices();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateService(String id, Map<String, dynamic> updates) async {
    try {
      await _serviceService.updateService(id, updates);
      await _loadServices();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteService(String id) async {
    try {
      await _serviceService.deleteService(id);
      await _loadServices();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

class ProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final ProductService _productService;
  
  ProductsNotifier(this._productService) : super(const AsyncValue.loading()) {
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      state = const AsyncValue.loading();
      final products = await _productService.getAllProducts();
      state = AsyncValue.data(products);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    await _loadProducts();
  }

  Future<void> addProduct(Product product) async {
    try {
      await _productService.createProduct(
        productCode: product.productCode,
        name: product.name,
        category: product.category,
        price: product.price,
        cost: product.cost,
        stockQuantity: product.stockQuantity,
        reorderPoint: product.reorderPoint,
        description: product.description,
        barcode: product.barcode,
        supplier: product.supplier,
        brand: product.brand,
        size: product.size,
        color: product.color,
        weight: product.weight,
        unit: product.unit,
        imageUrl: product.imageUrl,
        images: product.images,
        tags: product.tags,
        specifications: product.specifications,
        notes: product.notes,
        expiryDate: product.expiryDate,
        batchNumber: product.batchNumber,
        location: product.location,
      );
      await _loadProducts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateProduct(String id, Map<String, dynamic> updates) async {
    try {
      await _productService.updateProduct(id, updates);
      await _loadProducts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _productService.deleteProduct(id);
      await _loadProducts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateStock(String id, int newQuantity) async {
    try {
      await _productService.updateStock(id, newQuantity);
      await _loadProducts();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// State notifier providers
final servicesNotifierProvider = StateNotifierProvider<ServicesNotifier, AsyncValue<List<Service>>>((ref) {
  final serviceService = ref.read(serviceServiceProvider);
  return ServicesNotifier(serviceService);
});

final productsNotifierProvider = StateNotifierProvider<ProductsNotifier, AsyncValue<List<Product>>>((ref) {
  final productService = ref.read(productServiceProvider);
  return ProductsNotifier(productService);
});

// Filtered providers
final filteredServicesProvider = Provider<AsyncValue<List<Service>>>((ref) {
  final servicesAsync = ref.watch(servicesNotifierProvider);
  return servicesAsync.when(
    data: (services) => AsyncValue.data(services.where((s) => s.isActive).toList()),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsNotifierProvider);
  return productsAsync.when(
    data: (products) => AsyncValue.data(products.where((p) => p.isActive).toList()),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});
