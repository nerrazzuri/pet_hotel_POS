// Functional Product DAO for Android compatibility
// Provides in-memory storage with sample data

import 'package:cat_hotel_pos/features/services/domain/entities/product.dart';
// import 'package:uuid/uuid.dart';

class ProductDao {
  static final Map<String, Product> _products = {};
  static bool _initialized = false;
  // TODO: Uncomment when implementing UUID generation
  // static final Uuid _uuid = const Uuid();

  static void _initialize() {
    if (_initialized) return;
    
    // Create sample products
    _products['product_001'] = Product(
      id: 'product_001',
      productCode: 'FOOD-001',
      name: 'Premium Cat Food',
      category: ProductCategory.food,
      price: 45.99,
      cost: 28.50,
      stockQuantity: 150,
      reorderPoint: 20,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'High-quality dry cat food with balanced nutrition',
      barcode: '1234567890123',
      supplier: 'Pet Food Plus Co.',
      brand: 'PremiumPaws',
      size: '5kg',
      weight: '5kg',
      unit: 'bag',
      tags: ['premium', 'dry food', 'balanced nutrition'],
      imageUrl: 'assets/images/products/premium_cat_food.jpg',
      status: ProductStatus.inStock,
    );

    _products['product_002'] = Product(
      id: 'product_002',
      productCode: 'TREAT-001',
      name: 'Cat Treats',
      category: ProductCategory.treats,
      price: 12.99,
      cost: 7.50,
      stockQuantity: 200,
      reorderPoint: 30,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Delicious cat treats for training and rewards',
      barcode: '1234567890124',
      supplier: 'Pet Food Plus Co.',
      brand: 'TreatMaster',
      size: '200g',
      weight: '200g',
      unit: 'pack',
      tags: ['treats', 'training', 'rewards'],
      imageUrl: 'assets/images/products/cat_treats.jpg',
      status: ProductStatus.inStock,
    );

    _products['product_003'] = Product(
      id: 'product_003',
      productCode: 'TOY-001',
      name: 'Interactive Cat Toy',
      category: ProductCategory.toys,
      price: 24.99,
      cost: 15.00,
      stockQuantity: 75,
      reorderPoint: 15,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Interactive toy that stimulates natural hunting instincts',
      barcode: '1234567890125',
      supplier: 'ToyWorld Inc.',
      brand: 'PlaySmart',
      size: 'Medium',
      color: 'Multi-color',
      tags: ['interactive', 'hunting', 'stimulation'],
      imageUrl: 'assets/images/products/interactive_toy.jpg',
      status: ProductStatus.inStock,
    );

    _products['product_004'] = Product(
      id: 'product_004',
      productCode: 'GROOM-001',
      name: 'Cat Brush',
      category: ProductCategory.grooming,
      price: 18.99,
      cost: 11.00,
      stockQuantity: 100,
      reorderPoint: 20,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Professional cat brush for daily grooming',
      barcode: '1234567890126',
      supplier: 'Grooming Supplies Ltd.',
      brand: 'GroomPro',
      size: 'Standard',
      color: 'Black',
      tags: ['grooming', 'brush', 'daily care'],
      imageUrl: 'assets/images/products/cat_brush.jpg',
      status: ProductStatus.inStock,
    );

    _products['product_005'] = Product(
      id: 'product_005',
      productCode: 'HEALTH-001',
      name: 'Cat Vitamins',
      category: ProductCategory.health,
      price: 32.99,
      cost: 20.00,
      stockQuantity: 60,
      reorderPoint: 10,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Essential vitamins and minerals for cat health',
      barcode: '1234567890127',
      supplier: 'HealthPet Solutions',
      brand: 'VitaPet',
      size: '100 tablets',
      weight: '100g',
      unit: 'bottle',
      tags: ['vitamins', 'health', 'supplements'],
      imageUrl: 'assets/images/products/cat_vitamins.jpg',
      status: ProductStatus.inStock,
    );

    _products['product_006'] = Product(
      id: 'product_006',
      productCode: 'ACC-001',
      name: 'Cat Collar',
      category: ProductCategory.accessories,
      price: 15.99,
      cost: 9.00,
      stockQuantity: 120,
      reorderPoint: 25,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Adjustable cat collar with safety breakaway',
      barcode: '1234567890128',
      supplier: 'Accessory World',
      brand: 'SafeCollar',
      size: 'Adjustable',
      color: 'Blue',
      tags: ['collar', 'safety', 'adjustable'],
      imageUrl: 'assets/images/products/cat_collar.jpg',
      status: ProductStatus.inStock,
    );

    _products['product_007'] = Product(
      id: 'product_007',
      productCode: 'BED-001',
      name: 'Cat Bed',
      category: ProductCategory.bedding,
      price: 89.99,
      cost: 55.00,
      stockQuantity: 25,
      reorderPoint: 5,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Comfortable and warm cat bed for rest',
      barcode: '1234567890129',
      supplier: 'Comfort Pets',
      brand: 'CozyRest',
      size: 'Large',
      color: 'Gray',
      tags: ['bed', 'comfort', 'rest'],
      imageUrl: 'assets/images/products/cat_bed.jpg',
      status: ProductStatus.inStock,
    );

    _products['product_008'] = Product(
      id: 'product_008',
      productCode: 'LITTER-001',
      name: 'Cat Litter',
      category: ProductCategory.litter,
      price: 28.99,
      cost: 18.00,
      stockQuantity: 80,
      reorderPoint: 15,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Premium clumping cat litter with odor control',
      barcode: '1234567890130',
      supplier: 'Litter Solutions',
      brand: 'CleanLitter',
      size: '10kg',
      weight: '10kg',
      unit: 'bag',
      tags: ['litter', 'clumping', 'odor control'],
      imageUrl: 'assets/images/products/cat_litter.jpg',
      status: ProductStatus.inStock,
    );

    _products['product_009'] = Product(
      id: 'product_009',
      productCode: 'SUPP-001',
      name: 'Joint Supplement',
      category: ProductCategory.supplements,
      price: 45.99,
      cost: 28.00,
      stockQuantity: 40,
      reorderPoint: 8,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Joint health supplement for senior cats',
      barcode: '1234567890131',
      supplier: 'HealthPet Solutions',
      brand: 'JointCare',
      size: '60 capsules',
      weight: '60g',
      unit: 'bottle',
      tags: ['supplements', 'joint health', 'senior cats'],
      imageUrl: 'assets/images/products/joint_supplement.jpg',
      status: ProductStatus.inStock,
    );

    _products['product_010'] = Product(
      id: 'product_010',
      productCode: 'OTHER-001',
      name: 'Cat Carrier',
      category: ProductCategory.other,
      price: 65.99,
      cost: 40.00,
      stockQuantity: 30,
      reorderPoint: 6,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: 'Comfortable and secure cat carrier for travel',
      barcode: '1234567890132',
      supplier: 'Travel Pet Gear',
      brand: 'TravelSafe',
      size: 'Medium',
      color: 'Black',
      tags: ['carrier', 'travel', 'secure'],
      imageUrl: 'assets/images/products/cat_carrier.jpg',
      status: ProductStatus.inStock,
    );

    _initialized = true;
  }

  Future<void> insert(Product product) async {
    _initialize();
    _products[product.id] = product;
  }

  Future<Product?> getById(String id) async {
    _initialize();
    return _products[id];
  }

  Future<Product> create(Product product) async {
    _initialize();
    _products[product.id] = product;
    return product;
  }

  Future<List<Product>> getAll() async {
    _initialize();
    return _products.values.toList();
  }

  Future<Product> update(Product product) async {
    _initialize();
    _products[product.id] = product;
    return product;
  }

  Future<void> delete(String id) async {
    _initialize();
    _products.remove(id);
  }

  Future<List<Product>> search(String query) async {
    _initialize();
    if (query.trim().isEmpty) return _products.values.toList();
    
    final lowercaseQuery = query.toLowerCase();
    return _products.values.where((product) =>
      product.name.toLowerCase().contains(lowercaseQuery) ||
      product.productCode.toLowerCase().contains(lowercaseQuery) ||
      (product.description?.toLowerCase().contains(lowercaseQuery) ?? false) ||
      product.category.name.toLowerCase().contains(lowercaseQuery) ||
      (product.brand?.toLowerCase().contains(lowercaseQuery) ?? false)
    ).toList();
  }

  Future<List<Product>> getByCategory(ProductCategory category) async {
    _initialize();
    return _products.values.where((product) => product.category == category).toList();
  }

  Future<List<Product>> getActiveProducts() async {
    _initialize();
    return _products.values.where((product) => product.isActive).toList();
  }

  Future<List<Product>> getProductsByStatus(ProductStatus status) async {
    _initialize();
    return _products.values.where((product) => product.status == status).toList();
  }

  Future<List<Product>> getProductsByPriceRange(double minPrice, double maxPrice) async {
    _initialize();
    return _products.values.where((product) => 
      product.price >= minPrice && product.price <= maxPrice
    ).toList();
  }

  Future<List<Product>> getLowStockProducts() async {
    _initialize();
    return _products.values.where((product) => 
      product.stockQuantity <= product.reorderPoint
    ).toList();
  }

  Future<List<Product>> getOutOfStockProducts() async {
    _initialize();
    return _products.values.where((product) => 
      product.stockQuantity == 0
    ).toList();
  }

  Future<int> getTotalProducts() async {
    _initialize();
    return _products.length;
  }

  Future<double> getTotalInventoryValue() async {
    _initialize();
    double total = 0.0;
    for (final product in _products.values) {
      total += product.cost * product.stockQuantity;
    }
    return total;
  }

  Future<Map<String, int>> getProductsByCategory() async {
    _initialize();
    final result = <String, int>{};
    for (final product in _products.values) {
      final category = product.category.name;
      result[category] = (result[category] ?? 0) + 1;
    }
    return result;
  }

  Future<Map<String, int>> getProductsByStatusCount() async {
    _initialize();
    final result = <String, int>{};
    for (final product in _products.values) {
      final status = product.status?.name ?? 'unknown';
      result[status] = (result[status] ?? 0) + 1;
    }
    return result;
  }

  Future<Map<String, double>> getAveragePriceByCategory() async {
    _initialize();
    final result = <String, List<double>>{};
    for (final product in _products.values) {
      final category = product.category.name;
      if (result[category] == null) {
        result[category] = [];
      }
      result[category]!.add(product.price);
    }
    
    final averages = <String, double>{};
    for (final entry in result.entries) {
      final total = entry.value.fold(0.0, (sum, price) => sum + price);
      averages[entry.key] = total / entry.value.length;
    }
    return averages;
  }
}
