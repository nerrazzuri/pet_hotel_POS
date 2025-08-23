// Functional ProductBundle DAO for Android compatibility
// Provides in-memory storage with sample data

import 'package:cat_hotel_pos/features/services/domain/entities/product.dart';
// import 'package:uuid/uuid.dart';

class ProductBundleDao {
  static final Map<String, ProductBundle> _bundles = {};
  static bool _initialized = false;
  // TODO: Uncomment when implementing UUID generation
  // static final Uuid _uuid = const Uuid();

  static void _initialize() {
    if (_initialized) return;
    
    // Create sample product bundles
    _bundles['bundle_001'] = ProductBundle(
      id: 'bundle_001',
      name: 'New Pet Starter Kit',
      description: 'Essential products for new pet owners including food, treats, and basic accessories',
      price: 89.99,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      productIds: ['product_001', 'product_002', 'product_006'],
      productQuantities: {'product_001': 1, 'product_002': 2, 'product_006': 1},
      discountPercentage: 20.0,
      discountReason: 'New pet starter kit discount',
      termsAndConditions: 'Complete starter kit for new pet owners',
      restrictions: ['New customers only', 'Cannot be combined with other offers'],
    );

    _bundles['bundle_002'] = ProductBundle(
      id: 'bundle_002',
      name: 'Grooming Essentials Kit',
      description: 'Complete grooming kit with brush, treats, and grooming supplies',
      price: 65.99,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      productIds: ['product_004', 'product_002', 'product_008'],
      productQuantities: {'product_004': 1, 'product_002': 1, 'product_008': 1},
      discountPercentage: 15.0,
      discountReason: 'Grooming kit discount',
      termsAndConditions: 'Professional grooming kit for daily pet care',
      restrictions: ['Limited time offer', 'While supplies last'],
    );

    _bundles['bundle_003'] = ProductBundle(
      id: 'bundle_003',
      name: 'Health & Wellness Pack',
      description: 'Health supplements and vitamins for optimal pet wellness',
      price: 78.99,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      productIds: ['product_005', 'product_009'],
      productQuantities: {'product_005': 1, 'product_009': 1},
      discountPercentage: 18.0,
      discountReason: 'Health pack discount',
      termsAndConditions: 'Comprehensive health support for pets',
      restrictions: ['Consult veterinarian before use', 'Not suitable for all pets'],
    );

    _bundles['bundle_004'] = ProductBundle(
      id: 'bundle_004',
      name: 'Playtime Fun Pack',
      description: 'Interactive toys and treats for mental stimulation and entertainment',
      price: 42.99,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      productIds: ['product_003', 'product_002'],
      productQuantities: {'product_003': 1, 'product_002': 2},
      discountPercentage: 12.0,
      discountReason: 'Playtime pack discount',
      termsAndConditions: 'Fun and engaging toys for active pets',
      restrictions: ['Supervision recommended', 'Age-appropriate toys'],
    );

    _bundles['bundle_005'] = ProductBundle(
      id: 'bundle_005',
      name: 'Luxury Comfort Set',
      description: 'Premium bedding and accessories for ultimate pet comfort',
      price: 145.99,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      productIds: ['product_007', 'product_006', 'product_010'],
      productQuantities: {'product_007': 1, 'product_006': 1, 'product_010': 1},
      discountPercentage: 25.0,
      discountReason: 'Luxury set discount',
      termsAndConditions: 'Premium comfort items for discerning pet owners',
      restrictions: ['Premium items only', 'Limited availability'],
    );

    _bundles['bundle_006'] = ProductBundle(
      id: 'bundle_006',
      name: 'Travel Essentials Kit',
      description: 'Essential products for pet travel including carrier and travel supplies',
      price: 95.99,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      productIds: ['product_010', 'product_002', 'product_008'],
      productQuantities: {'product_010': 1, 'product_002': 1, 'product_008': 1},
      discountPercentage: 22.0,
      discountReason: 'Travel kit discount',
      termsAndConditions: 'Complete travel solution for pets',
      restrictions: ['Travel season only', 'Advance booking recommended'],
    );

    _bundles['bundle_007'] = ProductBundle(
      id: 'bundle_007',
      name: 'Senior Pet Care Pack',
      description: 'Specialized products for senior pets including supplements and comfort items',
      price: 120.99,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      productIds: ['product_009', 'product_007', 'product_005'],
      productQuantities: {'product_009': 1, 'product_007': 1, 'product_005': 1},
      discountPercentage: 20.0,
      discountReason: 'Senior pet care discount',
      termsAndConditions: 'Specialized care for senior pets',
      restrictions: ['Pets 7+ years old only', 'Health assessment recommended'],
    );

    _bundles['bundle_008'] = ProductBundle(
      id: 'bundle_008',
      name: 'Holiday Special Pack',
      description: 'Festive products and treats for holiday celebrations',
      price: 68.99,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      productIds: ['product_002', 'product_003', 'product_006'],
      productQuantities: {'product_002': 3, 'product_003': 1, 'product_006': 1},
      discountPercentage: 30.0,
      discountReason: 'Holiday special discount',
      termsAndConditions: 'Festive products for holiday celebrations',
      restrictions: ['Holiday season only', 'Limited edition items'],
    );

    _initialized = true;
  }

  Future<void> insert(ProductBundle bundle) async {
    _initialize();
    _bundles[bundle.id] = bundle;
  }

  Future<ProductBundle?> getById(String id) async {
    _initialize();
    return _bundles[id];
  }

  Future<ProductBundle> create(ProductBundle bundle) async {
    _initialize();
    _bundles[bundle.id] = bundle;
    return bundle;
  }

  Future<List<ProductBundle>> getAll() async {
    _initialize();
    return _bundles.values.toList();
  }

  Future<ProductBundle> update(ProductBundle bundle) async {
    _initialize();
    _bundles[bundle.id] = bundle;
    return bundle;
  }

  Future<void> delete(String id) async {
    _initialize();
    _bundles.remove(id);
  }

  Future<List<ProductBundle>> search(String query) async {
    _initialize();
    if (query.trim().isEmpty) return _bundles.values.toList();
    
    final lowercaseQuery = query.toLowerCase();
    return _bundles.values.where((bundle) =>
      bundle.name.toLowerCase().contains(lowercaseQuery) ||
      (bundle.description?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }

  Future<List<ProductBundle>> getActiveBundles() async {
    _initialize();
    return _bundles.values.where((bundle) => bundle.isActive).toList();
  }

  Future<List<ProductBundle>> getBundlesByPriceRange(double minPrice, double maxPrice) async {
    _initialize();
    return _bundles.values.where((bundle) => 
      bundle.price >= minPrice && bundle.price <= maxPrice
    ).toList();
  }

  Future<List<ProductBundle>> getBundlesByDiscountPercentage(double minDiscount) async {
    _initialize();
    return _bundles.values.where((bundle) => 
      bundle.discountPercentage != null && bundle.discountPercentage! >= minDiscount
    ).toList();
  }

  Future<List<ProductBundle>> getBundlesByProductId(String productId) async {
    _initialize();
    return _bundles.values.where((bundle) => 
      bundle.productIds?.contains(productId) ?? false
    ).toList();
  }

  Future<List<ProductBundle>> getBundlesByCategory(ProductCategory category) async {
    _initialize();
    // This would require checking if any product in the bundle matches the category
    // For now, return all bundles and let the UI filter
    return _bundles.values.toList();
  }

  Future<int> getTotalBundles() async {
    _initialize();
    return _bundles.length;
  }

  Future<double> getTotalBundleValue() async {
    _initialize();
    double total = 0.0;
    for (final bundle in _bundles.values) {
      total += bundle.price;
    }
    return total;
  }

  Future<Map<String, int>> getBundlesByDiscountRange() async {
    _initialize();
    final result = <String, int>{};
    for (final bundle in _bundles.values) {
      String range;
      if (bundle.discountPercentage == null || bundle.discountPercentage! == 0) {
        range = 'No Discount';
      } else if (bundle.discountPercentage! <= 15) {
        range = '0-15%';
      } else if (bundle.discountPercentage! <= 25) {
        range = '16-25%';
      } else {
        range = '26%+';
      }
      result[range] = (result[range] ?? 0) + 1;
    }
    return result;
  }

  Future<Map<String, double>> getAveragePriceByDiscountRange() async {
    _initialize();
    final result = <String, List<double>>{};
    for (final bundle in _bundles.values) {
      String range;
      if (bundle.discountPercentage == null || bundle.discountPercentage! == 0) {
        range = 'No Discount';
      } else if (bundle.discountPercentage! <= 15) {
        range = '0-15%';
      } else if (bundle.discountPercentage! <= 25) {
        range = '16-25%';
      } else {
        range = '26%+';
      }
      if (result[range] == null) {
        result[range] = [];
      }
      result[range]!.add(bundle.price);
    }
    
    final averages = <String, double>{};
    for (final entry in result.entries) {
      final total = entry.value.fold(0.0, (sum, price) => sum + price);
      averages[entry.key] = total / entry.value.length;
    }
    return averages;
  }

  Future<List<ProductBundle>> getBundlesByProductCount(int minProducts, int maxProducts) async {
    _initialize();
    return _bundles.values.where((bundle) => 
      bundle.productIds != null &&
      bundle.productIds!.length >= minProducts &&
      bundle.productIds!.length <= maxProducts
    ).toList();
  }
}
