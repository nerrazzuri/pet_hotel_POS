import 'web_storage_service.dart';
import 'base_dao.dart';

// Mock Product class for web compatibility
class Product {
  final String id;
  final String name;
  final String description;
  final String category;
  final double price;
  final int stockQuantity;
  final int reorderPoint;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.stockQuantity,
    required this.reorderPoint,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'category': category,
    'price': price,
    'stockQuantity': stockQuantity,
    'reorderPoint': reorderPoint,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      price: (json['price'] as num).toDouble(),
      stockQuantity: json['stockQuantity'] as int,
      reorderPoint: json['reorderPoint'] as int,
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class WebProductDao implements BaseProductDao {
  static const String _key = 'products';

  @override
  Future<dynamic> create(dynamic entity) async {
    final product = entity as Product;
    final products = await getAll();
    products.add(product);
    WebStorageService.saveData(_key, products.map((p) => p.toJson()).toList());
    return product;
  }

  @override
  Future<dynamic> update(dynamic entity) async {
    final product = entity as Product;
    final products = await getAll();
    final index = products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      products[index] = product;
      WebStorageService.saveData(_key, products.map((p) => p.toJson()).toList());
    }
    return product;
  }

  @override
  Future<void> delete(String id) async {
    final products = await getAll();
    products.removeWhere((p) => p.id == id);
    WebStorageService.saveData(_key, products.map((p) => p.toJson()).toList());
  }

  @override
  Future<dynamic?> getById(String id) async {
    final products = await getAll();
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Product>> getAll() async {
    final data = WebStorageService.getData(_key);
    return data.map((item) => Product(
      id: item['id'] ?? '',
      name: item['name'] ?? '',
      description: item['description'] ?? '',
      category: item['category'] ?? '',
      price: (item['price'] ?? 0.0).toDouble(),
      stockQuantity: item['stockQuantity'] ?? 0,
      reorderPoint: item['reorderPoint'] ?? 0,
      isActive: item['isActive'] ?? true,
      createdAt: DateTime.tryParse(item['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(item['updatedAt'] ?? '') ?? DateTime.now(),
    )).toList();
  }

  @override
  Future<List<Product>> search(String query) async {
    final allData = WebStorageService.getData(_key);
    final filteredData = allData.where((item) {
      final searchableText = '${item['name']} ${item['description']} ${item['category']}'.toLowerCase();
      return searchableText.contains(query.toLowerCase());
    }).toList();
    
    return filteredData.map((item) => Product(
      id: item['id'] ?? '',
      name: item['name'] ?? '',
      description: item['description'] ?? '',
      category: item['category'] ?? '',
      price: (item['price'] ?? 0.0).toDouble(),
      stockQuantity: item['stockQuantity'] ?? 0,
      reorderPoint: item['reorderPoint'] ?? 0,
      isActive: item['isActive'] ?? true,
      createdAt: DateTime.tryParse(item['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(item['updatedAt'] ?? '') ?? DateTime.now(),
    )).toList();
  }

  @override
  Future<List<Product>> getByCategory(String category) async {
    final data = WebStorageService.getData(_key);
    final filteredData = data.where((item) => item['category'] == category).toList();
    
    return filteredData.map((item) => Product(
      id: item['id'] ?? '',
      name: item['name'] ?? '',
      description: item['description'] ?? '',
      category: item['category'] ?? '',
      price: (item['price'] ?? 0.0).toDouble(),
      stockQuantity: item['stockQuantity'] ?? 0,
      reorderPoint: item['reorderPoint'] ?? 0,
      isActive: item['isActive'] ?? true,
      createdAt: DateTime.tryParse(item['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(item['updatedAt'] ?? '') ?? DateTime.now(),
    )).toList();
  }

  @override
  Future<List<Product>> getLowStockProducts() async {
    final data = WebStorageService.getData(_key);
    final filteredData = data.where((item) {
      final stockQuantity = item['stockQuantity'] ?? 0;
      final reorderPoint = item['reorderPoint'] ?? 0;
      return stockQuantity <= reorderPoint && stockQuantity > 0;
    }).toList();
    
    return filteredData.map((item) => Product(
      id: item['id'] ?? '',
      name: item['name'] ?? '',
      description: item['description'] ?? '',
      category: item['category'] ?? '',
      price: (item['price'] ?? 0.0).toDouble(),
      stockQuantity: item['stockQuantity'] ?? 0,
      reorderPoint: item['reorderPoint'] ?? 0,
      isActive: item['isActive'] ?? true,
      createdAt: DateTime.tryParse(item['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(item['updatedAt'] ?? '') ?? DateTime.now(),
    )).toList();
  }

  @override
  Future<List<Product>> getOutOfStockProducts() async {
    final data = WebStorageService.getData(_key);
    final filteredData = data.where((item) => (item['stockQuantity'] ?? 0) <= 0).toList();
    
    return filteredData.map((item) => Product(
      id: item['id'] ?? '',
      name: item['name'] ?? '',
      description: item['description'] ?? '',
      category: item['category'] ?? '',
      price: (item['price'] ?? 0.0).toDouble(),
      stockQuantity: item['stockQuantity'] ?? 0,
      reorderPoint: item['reorderPoint'] ?? 0,
      isActive: item['isActive'] ?? true,
      createdAt: DateTime.tryParse(item['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(item['updatedAt'] ?? '') ?? DateTime.now(),
    )).toList();
  }
}
