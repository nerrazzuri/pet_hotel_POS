import 'package:cat_hotel_pos/features/services/domain/entities/product.dart';
import 'package:cat_hotel_pos/core/services/product_dao.dart';

class ProductService {
  final ProductDao _productDao;

  ProductService({
    ProductDao? productDao,
  }) : _productDao = productDao ?? ProductDao();

  // Product CRUD operations
  Future<List<Product>> getAllProducts() async {
    return await _productDao.getAll();
  }

  Future<Product?> getProductById(String id) async {
    return await _productDao.getById(id);
  }

  Future<Product> createProduct(Product product) async {
    await _productDao.insert(product);
    return product;
  }

  Future<Product> updateProduct(Product product) async {
    return await _productDao.update(product);
  }

  Future<void> deleteProduct(String id) async {
    await _productDao.delete(id);
  }

  Future<List<Product>> searchProducts(String query) async {
    return await _productDao.search(query);
  }

  // Inventory operations
  Future<void> adjustStock(String productId, int quantity, String reason) async {
    final product = await _productDao.getById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    final newQuantity = product.stockQuantity + quantity;
    if (newQuantity < 0) {
      throw Exception('Insufficient stock');
    }

    final updatedProduct = product.copyWith(stockQuantity: newQuantity);
    await _productDao.update(updatedProduct);

    // For now, we'll just log the stock adjustment
    // In a real implementation, this would create an inventory transaction
    print('Stock adjusted: $quantity units of product $productId. Reason: $reason');
  }

  Future<void> transferStock(String productId, int quantity, String fromLocation, String toLocation, String notes) async {
    if (quantity <= 0) {
      throw Exception('Transfer quantity must be positive');
    }

    // For now, we'll just log the transfer since we don't have location-based inventory
    // In a real implementation, this would transfer between different storage locations
    print('Stock transfer: $quantity units of product $productId from $fromLocation to $toLocation. Notes: $notes');
  }

  Future<void> receiveStock(String productId, int quantity, String reason) async {
    await adjustStock(productId, quantity, 'Stock received: $reason');
  }

  Future<void> issueStock(String productId, int quantity, String reason) async {
    await adjustStock(productId, -quantity, 'Stock issued: $reason');
  }

  Future<void> returnStock(String productId, int quantity, String reason) async {
    await adjustStock(productId, quantity, 'Stock returned: $reason');
  }

  // Inventory analytics
  Future<Map<String, dynamic>> getInventoryAnalytics() async {
    final products = await _productDao.getAll();
    
    int totalProducts = products.length;
    int lowStockProducts = 0;
    int outOfStockProducts = 0;
    double totalValue = 0.0;
    int totalItems = 0;

    for (final product in products) {
      if (product.stockQuantity <= 0) {
        outOfStockProducts++;
      } else if (product.stockQuantity <= product.reorderPoint) {
        lowStockProducts++;
      }
      
      totalValue += product.stockQuantity * product.cost;
      totalItems += product.stockQuantity;
    }

    return {
      'totalProducts': totalProducts,
      'lowStockProducts': lowStockProducts,
      'outOfStockProducts': outOfStockProducts,
      'totalValue': totalValue,
      'totalItems': totalItems,
      'averageValue': totalProducts > 0 ? totalValue / totalProducts : 0.0,
    };
  }

  Future<List<Product>> getLowStockProducts() async {
    final products = await _productDao.getAll();
    return products.where((p) => 
      p.stockQuantity > 0 && 
      p.stockQuantity <= p.reorderPoint
    ).toList();
  }

  Future<List<Product>> getOutOfStockProducts() async {
    final products = await _productDao.getAll();
    return products.where((p) => p.stockQuantity <= 0).toList();
  }

  // Stock alerts
  Future<List<Product>> getProductsNeedingReorder() async {
    final products = await _productDao.getAll();
    return products.where((p) => 
      p.stockQuantity <= p.reorderPoint && 
      p.isActive
    ).toList();
  }

  Future<List<Product>> getExpiringProducts({int daysThreshold = 30}) async {
    // TODO: Implement when Product entity has expiryDate field
    return [];
  }

  // Bulk operations
  Future<void> bulkUpdateStock(Map<String, int> productQuantities, String reason) async {
    for (final entry in productQuantities.entries) {
      await adjustStock(entry.key, entry.value, reason);
    }
  }

  Future<void> bulkTransferStock(
    Map<String, int> fromProducts, 
    Map<String, int> toProducts, 
    String reason
  ) async {
    // Validate that quantities match
    int totalFrom = fromProducts.values.fold(0, (sum, qty) => sum + qty);
    int totalTo = toProducts.values.fold(0, (sum, qty) => sum + qty);
    
    if (totalFrom != totalTo) {
      throw Exception('Transfer quantities must match');
    }

    // Process transfers
    for (final entry in fromProducts.entries) {
      await adjustStock(entry.key, -entry.value, 'Bulk transfer out: $reason');
    }
    
    for (final entry in toProducts.entries) {
      await adjustStock(entry.key, entry.value, 'Bulk transfer in: $reason');
    }
  }

  // Product lifecycle management
  Future<void> deactivateProduct(String productId) async {
    final product = await _productDao.getById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    final updatedProduct = product.copyWith(isActive: false);
    await _productDao.update(updatedProduct);
  }

  Future<void> reactivateProduct(String productId) async {
    final product = await _productDao.getById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    final updatedProduct = product.copyWith(isActive: true);
    await _productDao.update(updatedProduct);
  }

  // Price management
  Future<void> updateProductPrice(String productId, double newPrice) async {
    final product = await _productDao.getById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    final updatedProduct = product.copyWith(price: newPrice);
    await _productDao.update(updatedProduct);
  }

  Future<void> updateProductCost(String productId, double newCost) async {
    final product = await _productDao.getById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    final updatedProduct = product.copyWith(cost: newCost);
    await _productDao.update(updatedProduct);
  }

  // Category management
  Future<List<String>> getAllCategories() async {
    final products = await _productDao.getAll();
    final categories = <String>{};
    
    for (final product in products) {
      categories.add(product.category.name);
    }
    
    return categories.toList()..sort();
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    // Convert string category to ProductCategory enum
    ProductCategory? productCategory;
    for (final cat in ProductCategory.values) {
      if (cat.name == category) {
        productCategory = cat;
        break;
      }
    }
    if (productCategory == null) return [];
    return await _productDao.getByCategory(productCategory);
  }

  // Search and filtering
  Future<List<Product>> searchProductsAdvanced({
    String? query,
    String? category,
    double? minPrice,
    double? maxPrice,
    bool? inStock,
    bool? activeOnly,
  }) async {
    final products = await _productDao.getAll();
    final filtered = <Product>[];

    for (final product in products) {
      bool matches = true;

      if (query != null && query.isNotEmpty) {
        final searchLower = query.toLowerCase();
        matches = matches && (
          product.name.toLowerCase().contains(searchLower) ||
          (product.description?.toLowerCase().contains(searchLower) ?? false) ||
          product.productCode.toLowerCase().contains(searchLower) ||
          (product.barcode?.toLowerCase().contains(searchLower) ?? false)
        );
      }

      if (category != null && category.isNotEmpty) {
        matches = matches && product.category.name == category;
      }

      if (minPrice != null) {
        matches = matches && product.price >= minPrice;
      }

      if (maxPrice != null) {
        matches = matches && product.price <= maxPrice;
      }

      if (inStock != null) {
        if (inStock) {
          matches = matches && product.stockQuantity > 0;
        } else {
          matches = matches && product.stockQuantity <= 0;
        }
      }

      if (activeOnly == true) {
        matches = matches && product.isActive;
      }

      if (matches) {
        filtered.add(product);
      }
    }

    return filtered;
  }

  // Export and reporting
  Future<Map<String, dynamic>> exportInventoryReport() async {
    final products = await _productDao.getAll();
    final analytics = await getInventoryAnalytics();
    
    return {
      'exportDate': DateTime.now().toIso8601String(),
      'products': products.map((p) => p.toJson()).toList(),
      'analytics': analytics,
      'summary': {
        'totalProducts': products.length,
        'activeProducts': products.where((p) => p.isActive).length,
        'totalValue': analytics['totalValue'],
        'lowStockCount': analytics['lowStockProducts'],
        'outOfStockCount': analytics['outOfStockProducts'],
      }
    };
  }
}
