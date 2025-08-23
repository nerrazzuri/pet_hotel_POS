import 'package:cat_hotel_pos/features/services/domain/entities/product.dart';
import 'package:cat_hotel_pos/core/services/product_dao.dart';
import 'package:cat_hotel_pos/core/services/product_bundle_dao.dart';

class ProductService {
  final ProductDao _productDao = ProductDao();
  final ProductBundleDao _bundleDao = ProductBundleDao();

  // Product Management
  Future<List<Product>> getAllProducts() async {
    return await _productDao.getAll();
  }

  Future<List<Product>> getActiveProducts() async {
    final allProducts = await _productDao.getAll();
    return allProducts.where((product) => product.isActive).toList();
  }

  Future<List<Product>> getProductsByCategory(ProductCategory category) async {
    final allProducts = await _productDao.getAll();
    return allProducts.where((product) => 
      product.category == category && product.isActive
    ).toList();
  }

  Future<Product?> getProductById(String id) async {
    return await _productDao.getById(id);
  }

  Future<Product?> getProductByCode(String productCode) async {
    final allProducts = await _productDao.getAll();
    try {
      return allProducts.firstWhere((product) => product.productCode == productCode);
    } catch (e) {
      return null;
    }
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final allProducts = await _productDao.getAll();
    try {
      return allProducts.firstWhere((product) => product.barcode == barcode);
    } catch (e) {
      return null;
    }
  }

  Future<Product> createProduct({
    required String productCode,
    required String name,
    required ProductCategory category,
    required double price,
    required double cost,
    required int stockQuantity,
    required int reorderPoint,
    String? description,
    String? barcode,
    String? supplier,
    String? brand,
    String? size,
    String? color,
    String? weight,
    String? unit,
    String? imageUrl,
    List<String>? images,
    List<String>? tags,
    Map<String, dynamic>? specifications,
    String? notes,
    DateTime? expiryDate,
    String? batchNumber,
    String? location,
  }) async {
    final product = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productCode: productCode,
      name: name,
      category: category,
      isActive: true,
      price: price,
      cost: cost,
      stockQuantity: stockQuantity,
      reorderPoint: reorderPoint,
      status: _calculateProductStatus(stockQuantity, reorderPoint),
      description: description,
      barcode: barcode,
      supplier: supplier,
      brand: brand,
      size: size,
      color: color,
      weight: weight,
      unit: unit,
      imageUrl: imageUrl,
      images: images,
      tags: tags,
      specifications: specifications,
      notes: notes,
      expiryDate: expiryDate,
      batchNumber: batchNumber,
      location: location,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _productDao.create(product);
    return product;
  }

  Future<Product> updateProduct(String id, Map<String, dynamic> updates) async {
    final product = await _productDao.getById(id);
    if (product == null) {
      throw Exception('Product not found');
    }

    // Manually update fields since copyWith doesn't support spread operator
    var updatedProduct = product;
    
    if (updates.containsKey('name') && updates['name'] != null) updatedProduct = updatedProduct.copyWith(name: updates['name'] as String);
    if (updates.containsKey('category') && updates['category'] != null) updatedProduct = updatedProduct.copyWith(category: updates['category'] as ProductCategory);
    if (updates.containsKey('price') && updates['price'] != null) updatedProduct = updatedProduct.copyWith(price: updates['price'] as double);
    if (updates.containsKey('cost') && updates['cost'] != null) updatedProduct = updatedProduct.copyWith(cost: updates['cost'] as double);
    if (updates.containsKey('stockQuantity') && updates['stockQuantity'] != null) updatedProduct = updatedProduct.copyWith(stockQuantity: updates['stockQuantity'] as int);
    if (updates.containsKey('reorderPoint') && updates['reorderPoint'] != null) updatedProduct = updatedProduct.copyWith(reorderPoint: updates['reorderPoint'] as int);
    if (updates.containsKey('description')) updatedProduct = updatedProduct.copyWith(description: updates['description'] as String?);
    if (updates.containsKey('barcode')) updatedProduct = updatedProduct.copyWith(barcode: updates['barcode'] as String?);
    if (updates.containsKey('supplier')) updatedProduct = updatedProduct.copyWith(supplier: updates['supplier'] as String?);
    if (updates.containsKey('brand')) updatedProduct = updatedProduct.copyWith(brand: updates['brand'] as String?);
    if (updates.containsKey('size')) updatedProduct = updatedProduct.copyWith(size: updates['size'] as String?);
    if (updates.containsKey('color')) updatedProduct = updatedProduct.copyWith(color: updates['color'] as String?);
    if (updates.containsKey('weight')) updatedProduct = updatedProduct.copyWith(weight: updates['weight'] as String?);
    if (updates.containsKey('unit')) updatedProduct = updatedProduct.copyWith(unit: updates['unit'] as String?);
    if (updates.containsKey('imageUrl')) updatedProduct = updatedProduct.copyWith(imageUrl: updates['imageUrl'] as String?);
    if (updates.containsKey('images')) updatedProduct = updatedProduct.copyWith(images: updates['images'] as List<String>?);
    if (updates.containsKey('tags')) updatedProduct = updatedProduct.copyWith(tags: updates['tags'] as List<String>?);
    if (updates.containsKey('specifications')) updatedProduct = updatedProduct.copyWith(specifications: updates['specifications'] as Map<String, dynamic>?);
    if (updates.containsKey('notes')) updatedProduct = updatedProduct.copyWith(notes: updates['notes'] as String?);
    if (updates.containsKey('expiryDate')) updatedProduct = updatedProduct.copyWith(expiryDate: updates['expiryDate'] as DateTime?);
    if (updates.containsKey('batchNumber')) updatedProduct = updatedProduct.copyWith(batchNumber: updates['batchNumber'] as String?);
    if (updates.containsKey('location')) updatedProduct = updatedProduct.copyWith(location: updates['location'] as String?);
    if (updates.containsKey('isActive')) updatedProduct = updatedProduct.copyWith(isActive: updates['isActive'] as bool);
    if (updates.containsKey('discountPrice')) updatedProduct = updatedProduct.copyWith(discountPrice: updates['discountPrice'] as double?);
    if (updates.containsKey('discountReason')) updatedProduct = updatedProduct.copyWith(discountReason: updates['discountReason'] as String?);
    if (updates.containsKey('discountValidUntil')) updatedProduct = updatedProduct.copyWith(discountValidUntil: updates['discountValidUntil'] as DateTime?);
    
    updatedProduct = updatedProduct.copyWith(updatedAt: DateTime.now());

    // Recalculate status if stock quantity changed
    if (updates.containsKey('stockQuantity') || updates.containsKey('reorderPoint')) {
      final newStatus = _calculateProductStatus(
        updatedProduct.stockQuantity,
        updatedProduct.reorderPoint,
      );
      updatedProduct = updatedProduct.copyWith(status: newStatus);
    }

    await _productDao.update(updatedProduct);
    return updatedProduct;
  }

  Future<void> deactivateProduct(String id) async {
    final product = await _productDao.getById(id);
    if (product == null) {
      throw Exception('Product not found');
    }

    final updatedProduct = product.copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );

    await _productDao.update(updatedProduct);
  }

  Future<void> deleteProduct(String id) async {
    await _productDao.delete(id);
  }

  // Inventory Management
  Future<Product> updateStock(String productId, int newQuantity) async {
    final product = await _productDao.getById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    if (newQuantity < 0) {
      throw Exception('Stock quantity cannot be negative');
    }

    final newStatus = _calculateProductStatus(newQuantity, product.reorderPoint);
    
    final updatedProduct = product.copyWith(
      stockQuantity: newQuantity,
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    await _productDao.update(updatedProduct);
    return updatedProduct;
  }

  Future<Product> addStock(String productId, int quantity) async {
    final product = await _productDao.getById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    final newQuantity = product.stockQuantity + quantity;
    final newStatus = _calculateProductStatus(newQuantity, product.reorderPoint);
    
    final updatedProduct = product.copyWith(
      stockQuantity: newQuantity,
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    await _productDao.update(updatedProduct);
    return updatedProduct;
  }

  Future<Product> removeStock(String productId, int quantity) async {
    final product = await _productDao.getById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    if (quantity > product.stockQuantity) {
      throw Exception('Insufficient stock');
    }

    final newQuantity = product.stockQuantity - quantity;
    final newStatus = _calculateProductStatus(newQuantity, product.reorderPoint);
    
    final updatedProduct = product.copyWith(
      stockQuantity: newQuantity,
      status: newStatus,
      updatedAt: DateTime.now(),
    );

    await _productDao.update(updatedProduct);
    return updatedProduct;
  }

  Future<List<Product>> getLowStockProducts() async {
    final allProducts = await _productDao.getAll();
    return allProducts.where((product) => 
      product.stockQuantity <= product.reorderPoint && product.isActive
    ).toList();
  }

  Future<List<Product>> getOutOfStockProducts() async {
    final allProducts = await _productDao.getAll();
    return allProducts.where((product) => 
      product.stockQuantity == 0 && product.isActive
    ).toList();
  }

  // Pricing & Discounts
  Future<Product> applyDiscount(String productId, {
    required double discountPrice,
    required String reason,
    required DateTime validUntil,
  }) async {
    final product = await _productDao.getById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    if (discountPrice >= product.price) {
      throw Exception('Discount price must be less than original price');
    }

    final updatedProduct = product.copyWith(
      discountPrice: discountPrice,
      discountReason: reason,
      discountValidUntil: validUntil,
      updatedAt: DateTime.now(),
    );

    await _productDao.update(updatedProduct);
    return updatedProduct;
  }

  Future<Product> removeDiscount(String productId) async {
    final product = await _productDao.getById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    final updatedProduct = product.copyWith(
      discountPrice: null,
      discountReason: null,
      discountValidUntil: null,
      updatedAt: DateTime.now(),
    );

    await _productDao.update(updatedProduct);
    return updatedProduct;
  }

  // Product Bundles
  Future<List<ProductBundle>> getAllBundles() async {
    return await _bundleDao.getAll();
  }

  Future<ProductBundle?> getBundleById(String id) async {
    return await _bundleDao.getById(id);
  }

  Future<ProductBundle> createBundle({
    required String name,
    required String description,
    required double price,
    List<String>? productIds,
    Map<String, int>? productQuantities,
    double? discountPercentage,
    String? discountReason,
    DateTime? discountValidUntil,
    String? termsAndConditions,
    List<String>? restrictions,
  }) async {
    final bundle = ProductBundle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      price: price,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      productIds: productIds,
      productQuantities: productQuantities,
      discountPercentage: discountPercentage,
      discountReason: discountReason,
      discountValidUntil: discountValidUntil,
      termsAndConditions: termsAndConditions,
      restrictions: restrictions,
    );

    await _bundleDao.create(bundle);
    return bundle;
  }

  Future<ProductBundle> updateBundle(String id, Map<String, dynamic> updates) async {
    final bundle = await _bundleDao.getById(id);
    if (bundle == null) {
      throw Exception('Bundle not found');
    }

    // Manually update fields since copyWith doesn't support spread operator
    var updatedBundle = bundle;
    
    if (updates.containsKey('name') && updates['name'] != null) updatedBundle = updatedBundle.copyWith(name: updates['name'] as String);
    if (updates.containsKey('description') && updates['description'] != null) updatedBundle = updatedBundle.copyWith(description: updates['description'] as String);
    if (updates.containsKey('price') && updates['price'] != null) updatedBundle = updatedBundle.copyWith(price: updates['price'] as double);
    if (updates.containsKey('productIds')) updatedBundle = updatedBundle.copyWith(productIds: updates['productIds'] as List<String>?);
    if (updates.containsKey('productQuantities')) updatedBundle = updatedBundle.copyWith(productQuantities: updates['productQuantities'] as Map<String, int>?);
    if (updates.containsKey('discountPercentage')) updatedBundle = updatedBundle.copyWith(discountPercentage: updates['discountPercentage'] as double?);
    if (updates.containsKey('discountReason')) updatedBundle = updatedBundle.copyWith(discountReason: updates['discountReason'] as String?);
    if (updates.containsKey('discountValidUntil')) updatedBundle = updatedBundle.copyWith(discountValidUntil: updates['discountValidUntil'] as DateTime?);
    if (updates.containsKey('termsAndConditions')) updatedBundle = updatedBundle.copyWith(termsAndConditions: updates['termsAndConditions'] as String? ?? null);
    if (updates.containsKey('restrictions')) updatedBundle = updatedBundle.copyWith(restrictions: updates['restrictions'] as List<String>?);
    if (updates.containsKey('isActive')) updatedBundle = updatedBundle.copyWith(isActive: updates['isActive'] as bool);
    
    updatedBundle = updatedBundle.copyWith(updatedAt: DateTime.now());

    await _bundleDao.update(updatedBundle);
    return updatedBundle;
  }

  Future<void> deactivateBundle(String id) async {
    final bundle = await _bundleDao.getById(id);
    if (bundle == null) {
      throw Exception('Bundle not found');
    }

    final updatedBundle = bundle.copyWith(
      isActive: false,
      updatedAt: DateTime.now(),
    );

    await _bundleDao.update(updatedBundle);
  }

  // Business Logic
  Future<List<Product>> getPopularProducts({int limit = 10}) async {
    final allProducts = await _productDao.getAll();
    // TODO: Implement popularity logic based on sales/ratings
    return allProducts.take(limit).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final allProducts = await _productDao.getAll();
    final lowercaseQuery = query.toLowerCase();
    
    return allProducts.where((product) =>
      product.name.toLowerCase().contains(lowercaseQuery) ||
      product.description?.toLowerCase().contains(lowercaseQuery) == true ||
      product.brand?.toLowerCase().contains(lowercaseQuery) == true ||
      product.tags?.any((tag) => tag.toLowerCase().contains(lowercaseQuery)) == true
    ).toList();
  }

  Future<List<Product>> getProductsByPriceRange(double minPrice, double maxPrice) async {
    final allProducts = await _productDao.getAll();
    return allProducts.where((product) =>
      product.price >= minPrice && product.price <= maxPrice
    ).toList();
  }

  Future<double> calculateProductPrice(String productId, {
    int? quantity = 1,
    double? customDiscount = 0.0,
  }) async {
    final product = await _productDao.getById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    double basePrice = product.discountPrice ?? product.price;
    double totalPrice = basePrice * (quantity ?? 1);
    
    if (customDiscount != null && customDiscount > 0) {
      totalPrice = totalPrice * (1 - customDiscount);
    }

    return totalPrice;
  }

  Future<double> calculateBundlePrice(String bundleId, {
    int? quantity = 1,
    double? customDiscount = 0.0,
  }) async {
    final bundle = await _bundleDao.getById(bundleId);
    if (bundle == null) {
      throw Exception('Bundle not found');
    }

    double basePrice = bundle.discountPercentage != null 
        ? bundle.price * (1 - bundle.discountPercentage! / 100)
        : bundle.price;
    
    double totalPrice = basePrice * (quantity ?? 1);
    
    if (customDiscount != null && customDiscount > 0) {
      totalPrice = totalPrice * (1 - customDiscount);
    }

    return totalPrice;
  }

  // Validation
  bool isValidProductCode(String productCode) {
    // Product code should be alphanumeric and 3-15 characters
    return RegExp(r'^[A-Za-z0-9]{3,15}$').hasMatch(productCode);
  }

  bool isValidBarcode(String? barcode) {
    if (barcode == null || barcode.isEmpty) return true;
    // Basic barcode validation (8-13 digits)
    return RegExp(r'^\d{8,13}$').hasMatch(barcode);
  }

  bool isValidPrice(double price) {
    return price > 0;
  }

  bool isValidCost(double cost) {
    return cost >= 0;
  }

  bool isValidStockQuantity(int quantity) {
    return quantity >= 0;
  }

  bool isValidReorderPoint(int reorderPoint) {
    return reorderPoint >= 0;
  }

  // Helper Methods
  ProductStatus _calculateProductStatus(int stockQuantity, int reorderPoint) {
    if (stockQuantity == 0) {
      return ProductStatus.outOfStock;
    } else if (stockQuantity <= reorderPoint) {
      return ProductStatus.lowStock;
    } else {
      return ProductStatus.inStock;
    }
  }

  // Analytics
  Future<Map<String, dynamic>> getProductAnalytics() async {
    final allProducts = await _productDao.getAll();
    final activeProducts = allProducts.where((p) => p.isActive).toList();
    
    return {
      'totalProducts': allProducts.length,
      'activeProducts': activeProducts.length,
      'inactiveProducts': allProducts.length - activeProducts.length,
      'averagePrice': allProducts.isNotEmpty 
          ? allProducts.map((p) => p.price).reduce((a, b) => a + b) / allProducts.length 
          : 0.0,
      'totalStockValue': allProducts.fold(0.0, (sum, p) => sum + (p.price * p.stockQuantity)),
      'productsByCategory': ProductCategory.values.map((category) {
        final count = allProducts.where((p) => p.category == category).length;
        return {'category': category.name, 'count': count};
      }).toList(),
      'stockStatus': {
        'inStock': allProducts.where((p) => p.status == ProductStatus.inStock).length,
        'lowStock': allProducts.where((p) => p.status == ProductStatus.lowStock).length,
        'outOfStock': allProducts.where((p) => p.status == ProductStatus.outOfStock).length,
      },
      'discountedProducts': allProducts.where((p) => p.discountPrice != null).length,
      'lowStockProducts': allProducts.where((p) => p.stockQuantity <= p.reorderPoint).length,
    };
  }
}
