import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/reports/domain/entities/report.dart';
import 'package:cat_hotel_pos/features/reports/domain/services/reports_service.dart';
import 'package:cat_hotel_pos/core/services/pos_dao.dart';
import 'package:cat_hotel_pos/core/services/booking_dao.dart';
import 'package:cat_hotel_pos/core/services/product_dao.dart';
import 'package:cat_hotel_pos/core/services/customer_dao.dart';

// Service provider
final reportsServiceProvider = Provider<ReportsService>((ref) {
  return ReportsService(
    PosDao(),
    BookingDao(),
    ProductDao(),
    CustomerDao(),
  );
});

// State providers for report configuration
final selectedReportTypeProvider = StateProvider<ReportType>((ref) => ReportType.sales);
final selectedReportPeriodProvider = StateProvider<ReportPeriod>((ref) => ReportPeriod.monthly);
final customStartDateProvider = StateProvider<DateTime?>((ref) => null);
final customEndDateProvider = StateProvider<DateTime?>((ref) => null);
final isLoadingReportProvider = StateProvider<bool>((ref) => false);

// Current report data providers
final currentSalesReportProvider = StateProvider<SalesReport?>((ref) => null);
final currentBookingReportProvider = StateProvider<BookingReport?>((ref) => null);
final currentInventoryReportProvider = StateProvider<InventoryReport?>((ref) => null);
final currentCustomerReportProvider = StateProvider<CustomerReport?>((ref) => null);
final currentFinancialReportProvider = StateProvider<FinancialReport?>((ref) => null);

// Report generation provider
final generateReportProvider = FutureProvider.family<dynamic, Map<String, dynamic>>((ref, params) async {
  final reportsService = ref.read(reportsServiceProvider);
  final reportType = params['type'] as ReportType;
  final period = params['period'] as ReportPeriod;
  final startDate = params['startDate'] as DateTime?;
  final endDate = params['endDate'] as DateTime?;

  // Determine date range
  late DateRange dateRange;
  if (period == ReportPeriod.custom && startDate != null && endDate != null) {
    dateRange = DateRange(startDate: startDate, endDate: endDate);
  } else {
    dateRange = ReportsService.getDateRangeForPeriod(period);
  }

  // Generate report based on type
  switch (reportType) {
    case ReportType.sales:
      return await reportsService.generateSalesReport(
        startDate: dateRange.startDate,
        endDate: dateRange.endDate,
      );
    case ReportType.booking:
      return await reportsService.generateBookingReport(
        startDate: dateRange.startDate,
        endDate: dateRange.endDate,
      );
    case ReportType.inventory:
      return await reportsService.generateInventoryReport();
    case ReportType.customer:
      return await reportsService.generateCustomerReport(
        startDate: dateRange.startDate,
        endDate: dateRange.endDate,
      );
    case ReportType.financial:
      return await reportsService.generateFinancialReport(
        startDate: dateRange.startDate,
        endDate: dateRange.endDate,
      );
    case ReportType.combined:
      // For combined report, generate all reports
      final salesReport = await reportsService.generateSalesReport(
        startDate: dateRange.startDate,
        endDate: dateRange.endDate,
      );
      final bookingReport = await reportsService.generateBookingReport(
        startDate: dateRange.startDate,
        endDate: dateRange.endDate,
      );
      final inventoryReport = await reportsService.generateInventoryReport();
      final customerReport = await reportsService.generateCustomerReport(
        startDate: dateRange.startDate,
        endDate: dateRange.endDate,
      );
      final financialReport = await reportsService.generateFinancialReport(
        startDate: dateRange.startDate,
        endDate: dateRange.endDate,
      );

      return {
        'sales': salesReport,
        'booking': bookingReport,
        'inventory': inventoryReport,
        'customer': customerReport,
        'financial': financialReport,
      };
  }
});

// Report analytics provider for dashboard stats
final reportAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final reportsService = ref.read(reportsServiceProvider);
  
  // Get current month data
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  final endOfMonth = DateTime(now.year, now.month + 1, 0);

  try {
    final salesReport = await reportsService.generateSalesReport(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
    
    final bookingReport = await reportsService.generateBookingReport(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
    
    final inventoryReport = await reportsService.generateInventoryReport();
    
    final customerReport = await reportsService.generateCustomerReport(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );

    return {
      'totalSales': salesReport.totalSales,
      'totalTransactions': salesReport.totalTransactions,
      'totalBookings': bookingReport.totalBookings,
      'occupancyRate': bookingReport.occupancyRate,
      'totalCustomers': customerReport.totalCustomers,
      'newCustomers': customerReport.newCustomers,
      'lowStockItems': inventoryReport.lowStockItems,
      'outOfStockItems': inventoryReport.outOfStockItems,
    };
  } catch (e) {
    // Return default values if there's an error
    return {
      'totalSales': 0.0,
      'totalTransactions': 0,
      'totalBookings': 0,
      'occupancyRate': 0.0,
      'totalCustomers': 0,
      'newCustomers': 0,
      'lowStockItems': 0,
      'outOfStockItems': 0,
    };
  }
});

// Report export provider
final exportReportProvider = Provider<String?>((ref) {
  final reportsService = ref.read(reportsServiceProvider);
  final reportType = ref.watch(selectedReportTypeProvider);
  
  // Get current report based on type
  dynamic currentReport;
  switch (reportType) {
    case ReportType.sales:
      currentReport = ref.watch(currentSalesReportProvider);
      break;
    case ReportType.booking:
      currentReport = ref.watch(currentBookingReportProvider);
      break;
    case ReportType.inventory:
      currentReport = ref.watch(currentInventoryReportProvider);
      break;
    case ReportType.customer:
      currentReport = ref.watch(currentCustomerReportProvider);
      break;
    case ReportType.financial:
      currentReport = ref.watch(currentFinancialReportProvider);
      break;
    default:
      return null;
  }

  if (currentReport == null) return null;

  return reportsService.exportReportToCSV(currentReport, reportType);
});

// Available report types provider
final availableReportTypesProvider = Provider<List<ReportType>>((ref) {
  return ReportType.values;
});

// Available report periods provider
final availableReportPeriodsProvider = Provider<List<ReportPeriod>>((ref) {
  return ReportPeriod.values;
});
