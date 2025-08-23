import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/product_service.dart';
import 'package:cat_hotel_pos/features/services/domain/entities/product.dart';

// Service providers
final productServiceProvider = Provider<ProductService>((ref) {
  return ProductService();
});

// Product providers
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.read(productServiceProvider);
  return await service.getAllProducts();
});

final filteredProductsProvider = StateProvider<List<Product>>((ref) => []);

final productSearchQueryProvider = StateProvider<String>((ref) => '');

final productCategoryFilterProvider = StateProvider<String?>((ref) => null);

final lowStockProductsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.read(productServiceProvider);
  return await service.getLowStockProducts();
});

final outOfStockProductsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.read(productServiceProvider);
  return await service.getOutOfStockProducts();
});

// Analytics provider
final inventoryAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.read(productServiceProvider);
  return await service.getInventoryAnalytics();
});

// Product form state
class ProductFormState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final Product? product;

  const ProductFormState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.product,
  });

  ProductFormState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    Product? product,
  }) {
    return ProductFormState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
      product: product ?? this.product,
    );
  }
}

class ProductFormNotifier extends StateNotifier<ProductFormState> {
  final ProductService _productService;

  ProductFormNotifier(this._productService) : super(const ProductFormState());

  Future<void> createProduct(Product product) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final createdProduct = await _productService.createProduct(product);
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        product: createdProduct,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> updateProduct(Product product) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final updatedProduct = await _productService.updateProduct(product);
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        product: updatedProduct,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> deleteProduct(String productId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _productService.deleteProduct(productId);
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = const ProductFormState();
  }
}

final productFormProvider = StateNotifierProvider<ProductFormNotifier, ProductFormState>((ref) {
  final service = ref.read(productServiceProvider);
  return ProductFormNotifier(service);
});

// Stock adjustment form state
class StockAdjustmentFormState {
  final bool isLoading;
  final bool isSuccess;
  final String? error;
  final String productId;
  final int quantity;
  final String reason;

  const StockAdjustmentFormState({
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
    this.productId = '',
    this.quantity = 0,
    this.reason = '',
  });

  StockAdjustmentFormState copyWith({
    bool? isLoading,
    bool? isSuccess,
    String? error,
    String? productId,
    int? quantity,
    String? reason,
  }) {
    return StockAdjustmentFormState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      reason: reason ?? this.reason,
    );
  }
}

class StockAdjustmentFormNotifier extends StateNotifier<StockAdjustmentFormState> {
  final ProductService _productService;

  StockAdjustmentFormNotifier(this._productService) : super(const StockAdjustmentFormState());

  Future<void> adjustStock() async {
    if (state.productId.isEmpty || state.quantity == 0 || state.reason.isEmpty) {
      state = state.copyWith(error: 'Please fill in all required fields');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    try {
      await _productService.adjustStock(
        state.productId,
        state.quantity,
        state.reason,
      );
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void reset() {
    state = const StockAdjustmentFormState();
  }
}

final stockAdjustmentFormProvider = StateNotifierProvider<StockAdjustmentFormNotifier, StockAdjustmentFormState>((ref) {
  final service = ref.read(productServiceProvider);
  return StockAdjustmentFormNotifier(service);
});
