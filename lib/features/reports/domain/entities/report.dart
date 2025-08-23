import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/material.dart';

part 'report.freezed.dart';
part 'report.g.dart';

@freezed
class SalesReport with _$SalesReport {
  const factory SalesReport({
    required String id,
    required DateTime date,
    required double totalSales,
    required int totalTransactions,
    required double averageTransactionValue,
    required Map<String, double> salesByCategory,
    required Map<String, int> quantitySoldByProduct,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SalesReport;

  factory SalesReport.fromJson(Map<String, dynamic> json) =>
      _$SalesReportFromJson(json);
}

@freezed
class BookingReport with _$BookingReport {
  const factory BookingReport({
    required String id,
    required DateTime date,
    required int totalBookings,
    required int checkedIn,
    required int checkedOut,
    required int cancelled,
    required double totalRevenue,
    required double occupancyRate,
    required Map<String, int> bookingsByRoomType,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _BookingReport;

  factory BookingReport.fromJson(Map<String, dynamic> json) =>
      _$BookingReportFromJson(json);
}

@freezed
class InventoryReport with _$InventoryReport {
  const factory InventoryReport({
    required String id,
    required DateTime date,
    required int totalProducts,
    required int lowStockItems,
    required int outOfStockItems,
    required double totalInventoryValue,
    required Map<String, int> stockByCategory,
    required List<String> topSellingProducts,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _InventoryReport;

  factory InventoryReport.fromJson(Map<String, dynamic> json) =>
      _$InventoryReportFromJson(json);
}

@freezed
class CustomerReport with _$CustomerReport {
  const factory CustomerReport({
    required String id,
    required DateTime date,
    required int totalCustomers,
    required int newCustomers,
    required int returningCustomers,
    required double averageSpendPerCustomer,
    required Map<String, int> customersByRegion,
    required List<String> topCustomers,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CustomerReport;

  factory CustomerReport.fromJson(Map<String, dynamic> json) =>
      _$CustomerReportFromJson(json);
}

@freezed
class FinancialReport with _$FinancialReport {
  const factory FinancialReport({
    required String id,
    required DateTime date,
    required double totalRevenue,
    required double totalExpenses,
    required double grossProfit,
    required double netProfit,
    required Map<String, double> revenueBySource,
    required Map<String, double> expensesByCategory,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FinancialReport;

  factory FinancialReport.fromJson(Map<String, dynamic> json) =>
      _$FinancialReportFromJson(json);
}

enum ReportType {
  sales,
  booking,
  inventory,
  customer,
  financial,
  combined
}

enum ReportPeriod {
  daily,
  weekly,
  monthly,
  quarterly,
  yearly,
  custom
}

extension ReportTypeExtension on ReportType {
  String get name {
    switch (this) {
      case ReportType.sales:
        return 'Sales';
      case ReportType.booking:
        return 'Booking';
      case ReportType.inventory:
        return 'Inventory';
      case ReportType.customer:
        return 'Customer';
      case ReportType.financial:
        return 'Financial';
      case ReportType.combined:
        return 'Combined';
    }
  }

  String get description {
    switch (this) {
      case ReportType.sales:
        return 'Sales performance and trends';
      case ReportType.booking:
        return 'Booking statistics and occupancy';
      case ReportType.inventory:
        return 'Stock levels and inventory movement';
      case ReportType.customer:
        return 'Customer demographics and behavior';
      case ReportType.financial:
        return 'Revenue, expenses, and profitability';
      case ReportType.combined:
        return 'Comprehensive business overview';
    }
  }

  IconData get icon {
    switch (this) {
      case ReportType.sales:
        return Icons.trending_up;
      case ReportType.booking:
        return Icons.hotel;
      case ReportType.inventory:
        return Icons.inventory;
      case ReportType.customer:
        return Icons.people;
      case ReportType.financial:
        return Icons.account_balance;
      case ReportType.combined:
        return Icons.dashboard;
    }
  }

  Color get color {
    switch (this) {
      case ReportType.sales:
        return Colors.green;
      case ReportType.booking:
        return Colors.orange;
      case ReportType.inventory:
        return Colors.purple;
      case ReportType.customer:
        return Colors.blue;
      case ReportType.financial:
        return Colors.amber;
      case ReportType.combined:
        return Colors.teal;
    }
  }
}

extension ReportPeriodExtension on ReportPeriod {
  String get name {
    switch (this) {
      case ReportPeriod.daily:
        return 'Daily';
      case ReportPeriod.weekly:
        return 'Weekly';
      case ReportPeriod.monthly:
        return 'Monthly';
      case ReportPeriod.quarterly:
        return 'Quarterly';
      case ReportPeriod.yearly:
        return 'Yearly';
      case ReportPeriod.custom:
        return 'Custom Range';
    }
  }
}
