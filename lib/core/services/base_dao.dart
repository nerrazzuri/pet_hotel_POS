// Base DAO interface for common database operations
// This is a simplified version that doesn't depend on specific entities

abstract class BaseDao<T> {
  Future<T> create(T entity);
  Future<T> update(T entity);
  Future<void> delete(String id);
  Future<T?> getById(String id);
  Future<List<T>> getAll();
  Future<List<T>> search(String query);
}

// Base DAO for products
abstract class BaseProductDao implements BaseDao<dynamic> {
  Future<List<dynamic>> getByCategory(String category);
  Future<List<dynamic>> getLowStockProducts();
  Future<List<dynamic>> getOutOfStockProducts();
}

// Base DAO for inventory transactions
abstract class BaseInventoryTransactionDao implements BaseDao<dynamic> {
  Future<List<dynamic>> getByProductId(String productId);
  Future<List<dynamic>> getByType(String type);
  Future<List<dynamic>> getByDateRange(DateTime startDate, DateTime endDate);
}

// Base DAO for customers
abstract class BaseCustomerDao implements BaseDao<dynamic> {
  Future<List<dynamic>> getByStatus(String status);
  Future<List<dynamic>> searchByPhone(String phone);
  Future<List<dynamic>> searchByEmail(String email);
}

// Base DAO for suppliers
abstract class BaseSupplierDao implements BaseDao<dynamic> {
  Future<List<dynamic>> getByStatus(String status);
  Future<List<dynamic>> searchByName(String name);
}

// Base DAO for purchase orders
abstract class BasePurchaseOrderDao implements BaseDao<dynamic> {
  Future<List<dynamic>> getByStatus(String status);
  Future<List<dynamic>> getBySupplier(String supplierId);
  Future<List<dynamic>> getByDateRange(DateTime startDate, DateTime endDate);
}

// Base DAO for services
abstract class BaseServiceDao implements BaseDao<dynamic> {
  Future<List<dynamic>> getByCategory(String category);
  Future<List<dynamic>> getActiveServices();
}

// Base DAO for service packages
abstract class BaseServicePackageDao implements BaseDao<dynamic> {
  Future<List<dynamic>> getActivePackages();
  Future<List<dynamic>> getByService(String serviceId);
}

// Base DAO for product bundles
abstract class BaseProductBundleDao implements BaseDao<dynamic> {
  Future<List<dynamic>> getActiveBundles();
  Future<List<dynamic>> getByProduct(String productId);
}

// Base DAO for rooms
abstract class BaseRoomDao implements BaseDao<dynamic> {
  Future<List<dynamic>> getByType(String type);
  Future<List<dynamic>> getByStatus(String status);
  Future<List<dynamic>> getAvailableRooms(DateTime date);
}

// Base DAO for bookings
abstract class BaseBookingDao implements BaseDao<dynamic> {
  Future<List<dynamic>> getByStatus(String status);
  Future<List<dynamic>> getByCustomer(String customerId);
  Future<List<dynamic>> getByDateRange(DateTime startDate, DateTime endDate);
}

// Base DAO for pets
abstract class BasePetDao implements BaseDao<dynamic> {
  Future<List<dynamic>> getByCustomer(String customerId);
  Future<List<dynamic>> getByType(String type);
  Future<List<dynamic>> searchByName(String name);
}

// Base DAO for users
abstract class BaseUserDao implements BaseDao<dynamic> {
  Future<dynamic?> getByUsername(String username);
  Future<dynamic?> getByEmail(String email);
  Future<List<dynamic>> getByRole(String role);
}

// Base DAO for POS operations
abstract class BasePOSDao implements BaseDao<dynamic> {
  Future<List<dynamic>> getActiveCarts();
  Future<List<dynamic>> getHeldCarts();
  Future<List<dynamic>> getRecentTransactions(int limit);
}
