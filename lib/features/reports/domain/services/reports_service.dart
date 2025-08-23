import 'package:cat_hotel_pos/features/reports/domain/entities/report.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/core/services/pos_dao.dart';
import 'package:cat_hotel_pos/core/services/booking_dao.dart';
import 'package:cat_hotel_pos/core/services/product_dao.dart';
import 'package:cat_hotel_pos/core/services/customer_dao.dart';
import 'package:uuid/uuid.dart';

class ReportsService {
  final PosDao _posDao;
  final BookingDao _bookingDao;
  final ProductDao _productDao;
  final CustomerDao _customerDao;
  final Uuid _uuid = const Uuid();

  ReportsService(
    this._posDao,
    this._bookingDao,
    this._productDao,
    this._customerDao,
  );

  // Generate Sales Report
  Future<SalesReport> generateSalesReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final transactions = await _posDao.getTransactionsByDateRange(startDate, endDate);
    
    double totalSales = 0;
    Map<String, double> salesByCategory = {};
    Map<String, int> quantitySoldByProduct = {};

    for (final transaction in transactions) {
      totalSales += transaction.totalAmount;
      
      for (final item in transaction.items) {
        // Update category sales
        final category = item.category ?? 'Other';
        salesByCategory[category] = (salesByCategory[category] ?? 0) + (item.price * item.quantity);
        
        // Update product quantity
        quantitySoldByProduct[item.name] = (quantitySoldByProduct[item.name] ?? 0) + item.quantity.toInt();
      }
    }

    final averageTransactionValue = transactions.isNotEmpty ? totalSales / transactions.length : 0.0;

    return SalesReport(
      id: _uuid.v4(),
      date: DateTime.now(),
      totalSales: totalSales,
      totalTransactions: transactions.length,
      averageTransactionValue: averageTransactionValue,
      salesByCategory: salesByCategory,
      quantitySoldByProduct: quantitySoldByProduct,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Generate Booking Report
  Future<BookingReport> generateBookingReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final bookings = await _bookingDao.getBookingsByDateRange(startDate, endDate);
    
    int checkedIn = 0;
    int checkedOut = 0;
    int cancelled = 0;
    double totalRevenue = 0;
    Map<String, int> bookingsByRoomType = {};

    for (final booking in bookings) {
      switch (booking.status) {
        case BookingStatus.checkedIn:
          checkedIn++;
          break;
        case BookingStatus.checkedOut:
          checkedOut++;
          break;
        case BookingStatus.cancelled:
          cancelled++;
          break;
        default:
          break;
      }

      if (booking.status != BookingStatus.cancelled) {
        totalRevenue += booking.totalAmount;
      }

      // Update room type bookings (use roomNumber as room type for now)
      final roomType = booking.roomNumber ?? 'Unknown';
      bookingsByRoomType[roomType] = (bookingsByRoomType[roomType] ?? 0) + 1;
    }

    // Calculate occupancy rate (simplified - would need room capacity data)
    final occupancyRate = bookings.isNotEmpty ? (checkedIn / bookings.length) * 100 : 0.0;

    return BookingReport(
      id: _uuid.v4(),
      date: DateTime.now(),
      totalBookings: bookings.length,
      checkedIn: checkedIn,
      checkedOut: checkedOut,
      cancelled: cancelled,
      totalRevenue: totalRevenue,
      occupancyRate: occupancyRate,
      bookingsByRoomType: bookingsByRoomType,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Generate Inventory Report
  Future<InventoryReport> generateInventoryReport() async {
    final products = await _productDao.getAll();
    
    int lowStockItems = 0;
    int outOfStockItems = 0;
    double totalInventoryValue = 0;
    Map<String, int> stockByCategory = {};
    List<String> topSellingProducts = [];

    for (final product in products) {
      // Check stock levels (use stockQuantity as stock level)
      final stockLevel = product.stockQuantity;
      final reorderPoint = product.reorderPoint;
      
      if (stockLevel == 0) {
        outOfStockItems++;
      } else if (stockLevel <= reorderPoint) {
        lowStockItems++;
      }

      // Calculate inventory value
      totalInventoryValue += product.price * stockLevel;

      // Update category stock
      final category = product.category.name;
      stockByCategory[category] = (stockByCategory[category] ?? 0) + stockLevel;
    }

    // Get top selling products (simplified - would need sales data analysis)
    topSellingProducts = products.take(5).map((p) => p.name).toList();

    return InventoryReport(
      id: _uuid.v4(),
      date: DateTime.now(),
      totalProducts: products.length,
      lowStockItems: lowStockItems,
      outOfStockItems: outOfStockItems,
      totalInventoryValue: totalInventoryValue,
      stockByCategory: stockByCategory,
      topSellingProducts: topSellingProducts,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Generate Customer Report
  Future<CustomerReport> generateCustomerReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final customers = await _customerDao.getAll();
    final transactions = await _posDao.getTransactionsByDateRange(startDate, endDate);
    
    int newCustomers = 0;
    int returningCustomers = 0;
    Map<String, int> customersByRegion = {};
    Map<String, double> customerSpending = {};

    // Analyze customers
    for (final customer in customers) {
      if (customer.createdAt.isAfter(startDate) && customer.createdAt.isBefore(endDate)) {
        newCustomers++;
      } else {
        returningCustomers++;
      }

      // Group by city as region
      final region = customer.city ?? 'Unknown';
      customersByRegion[region] = (customersByRegion[region] ?? 0) + 1;
    }

    // Calculate customer spending
    for (final transaction in transactions) {
      final customerId = transaction.customerId ?? 'Walk-in';
      customerSpending[customerId] = (customerSpending[customerId] ?? 0) + transaction.totalAmount;
    }

    final averageSpendPerCustomer = customers.isNotEmpty 
        ? customerSpending.values.fold(0.0, (sum, spend) => sum + spend) / customers.length
        : 0.0;

    // Get top customers
    final topCustomers = customerSpending.entries
        .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
    final topCustomerIds = topCustomers.take(5).map((e) => e.key).toList();

    return CustomerReport(
      id: _uuid.v4(),
      date: DateTime.now(),
      totalCustomers: customers.length,
      newCustomers: newCustomers,
      returningCustomers: returningCustomers,
      averageSpendPerCustomer: averageSpendPerCustomer,
      customersByRegion: customersByRegion,
      topCustomers: topCustomerIds,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Generate Financial Report
  Future<FinancialReport> generateFinancialReport({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final transactions = await _posDao.getTransactionsByDateRange(startDate, endDate);
    final bookings = await _bookingDao.getBookingsByDateRange(startDate, endDate);
    
    double salesRevenue = 0;
    double bookingRevenue = 0;
    Map<String, double> revenueBySource = {};

    // Calculate sales revenue
    for (final transaction in transactions) {
      salesRevenue += transaction.totalAmount;
    }

    // Calculate booking revenue
    for (final booking in bookings) {
      if (booking.status != BookingStatus.cancelled) {
        bookingRevenue += booking.totalAmount;
      }
    }

    final totalRevenue = salesRevenue + bookingRevenue;
    revenueBySource['Sales'] = salesRevenue;
    revenueBySource['Bookings'] = bookingRevenue;

    // Simplified expenses calculation (would need expense tracking)
    final totalExpenses = totalRevenue * 0.7; // Assume 70% expense ratio
    Map<String, double> expensesByCategory = {
      'Cost of Goods Sold': totalRevenue * 0.4,
      'Staff Salaries': totalRevenue * 0.15,
      'Utilities': totalRevenue * 0.05,
      'Maintenance': totalRevenue * 0.05,
      'Other': totalRevenue * 0.05,
    };

    final grossProfit = totalRevenue - (totalRevenue * 0.4); // Minus COGS
    final netProfit = totalRevenue - totalExpenses;

    return FinancialReport(
      id: _uuid.v4(),
      date: DateTime.now(),
      totalRevenue: totalRevenue,
      totalExpenses: totalExpenses,
      grossProfit: grossProfit,
      netProfit: netProfit,
      revenueBySource: revenueBySource,
      expensesByCategory: expensesByCategory,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Get date range for specific period
  static DateRange getDateRangeForPeriod(ReportPeriod period) {
    final now = DateTime.now();
    DateTime startDate;
    DateTime endDate = now;

    switch (period) {
      case ReportPeriod.daily:
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case ReportPeriod.weekly:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case ReportPeriod.monthly:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case ReportPeriod.quarterly:
        final quarterStart = ((now.month - 1) ~/ 3) * 3 + 1;
        startDate = DateTime(now.year, quarterStart, 1);
        break;
      case ReportPeriod.yearly:
        startDate = DateTime(now.year, 1, 1);
        break;
      case ReportPeriod.custom:
        // This should be handled by the caller
        startDate = now.subtract(const Duration(days: 30));
        break;
    }

    return DateRange(startDate: startDate, endDate: endDate);
  }

  // Export report to CSV format
  String exportReportToCSV(dynamic report, ReportType type) {
    switch (type) {
      case ReportType.sales:
        return _exportSalesReportToCSV(report as SalesReport);
      case ReportType.booking:
        return _exportBookingReportToCSV(report as BookingReport);
      case ReportType.inventory:
        return _exportInventoryReportToCSV(report as InventoryReport);
      case ReportType.customer:
        return _exportCustomerReportToCSV(report as CustomerReport);
      case ReportType.financial:
        return _exportFinancialReportToCSV(report as FinancialReport);
      default:
        return 'Report type not supported for CSV export';
    }
  }

  String _exportSalesReportToCSV(SalesReport report) {
    final buffer = StringBuffer();
    buffer.writeln('Sales Report - ${report.date}');
    buffer.writeln('Total Sales,${report.totalSales}');
    buffer.writeln('Total Transactions,${report.totalTransactions}');
    buffer.writeln('Average Transaction Value,${report.averageTransactionValue}');
    buffer.writeln('');
    buffer.writeln('Sales by Category');
    buffer.writeln('Category,Amount');
    for (final entry in report.salesByCategory.entries) {
      buffer.writeln('${entry.key},${entry.value}');
    }
    return buffer.toString();
  }

  String _exportBookingReportToCSV(BookingReport report) {
    final buffer = StringBuffer();
    buffer.writeln('Booking Report - ${report.date}');
    buffer.writeln('Total Bookings,${report.totalBookings}');
    buffer.writeln('Checked In,${report.checkedIn}');
    buffer.writeln('Checked Out,${report.checkedOut}');
    buffer.writeln('Cancelled,${report.cancelled}');
    buffer.writeln('Total Revenue,${report.totalRevenue}');
    buffer.writeln('Occupancy Rate,${report.occupancyRate}%');
    return buffer.toString();
  }

  String _exportInventoryReportToCSV(InventoryReport report) {
    final buffer = StringBuffer();
    buffer.writeln('Inventory Report - ${report.date}');
    buffer.writeln('Total Products,${report.totalProducts}');
    buffer.writeln('Low Stock Items,${report.lowStockItems}');
    buffer.writeln('Out of Stock Items,${report.outOfStockItems}');
    buffer.writeln('Total Inventory Value,${report.totalInventoryValue}');
    return buffer.toString();
  }

  String _exportCustomerReportToCSV(CustomerReport report) {
    final buffer = StringBuffer();
    buffer.writeln('Customer Report - ${report.date}');
    buffer.writeln('Total Customers,${report.totalCustomers}');
    buffer.writeln('New Customers,${report.newCustomers}');
    buffer.writeln('Returning Customers,${report.returningCustomers}');
    buffer.writeln('Average Spend per Customer,${report.averageSpendPerCustomer}');
    return buffer.toString();
  }

  String _exportFinancialReportToCSV(FinancialReport report) {
    final buffer = StringBuffer();
    buffer.writeln('Financial Report - ${report.date}');
    buffer.writeln('Total Revenue,${report.totalRevenue}');
    buffer.writeln('Total Expenses,${report.totalExpenses}');
    buffer.writeln('Gross Profit,${report.grossProfit}');
    buffer.writeln('Net Profit,${report.netProfit}');
    return buffer.toString();
  }
}

class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  DateRange({required this.startDate, required this.endDate});
}
