import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/reports/domain/entities/report.dart';
import 'package:cat_hotel_pos/features/reports/presentation/providers/reports_providers.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports & Analytics'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.trending_up), text: 'Sales'),
            Tab(icon: Icon(Icons.hotel), text: 'Bookings'),
            Tab(icon: Icon(Icons.inventory), text: 'Inventory'),
            Tab(icon: Icon(Icons.people), text: 'Customers'),
            Tab(icon: Icon(Icons.account_balance), text: 'Financial'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildReportTab(ReportType.sales),
          _buildReportTab(ReportType.booking),
          _buildReportTab(ReportType.inventory),
          _buildReportTab(ReportType.customer),
          _buildReportTab(ReportType.financial),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final analyticsAsync = ref.watch(reportAnalyticsProvider);

    return analyticsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading analytics: $error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.refresh(reportAnalyticsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (analytics) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Business Overview',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
            ),
            const SizedBox(height: 16),
            
            // Quick Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: _getGridCrossAxisCount(context),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: [
                _buildStatCard('Total Sales', '\$${analytics['totalSales']?.toStringAsFixed(2) ?? '0.00'}', Icons.attach_money, Colors.green),
                _buildStatCard('Transactions', '${analytics['totalTransactions'] ?? 0}', Icons.receipt, Colors.blue),
                _buildStatCard('Bookings', '${analytics['totalBookings'] ?? 0}', Icons.hotel, Colors.orange),
                _buildStatCard('Occupancy Rate', '${analytics['occupancyRate']?.toStringAsFixed(1) ?? '0.0'}%', Icons.pie_chart, Colors.purple),
                _buildStatCard('Total Customers', '${analytics['totalCustomers'] ?? 0}', Icons.people, Colors.teal),
                _buildStatCard('New Customers', '${analytics['newCustomers'] ?? 0}', Icons.person_add, Colors.indigo),
                _buildStatCard('Low Stock Items', '${analytics['lowStockItems'] ?? 0}', Icons.warning, Colors.amber),
                _buildStatCard('Out of Stock', '${analytics['outOfStockItems'] ?? 0}', Icons.error, Colors.red),
              ],
            ),
            
            const SizedBox(height: 32),
            
            Text(
              'Quick Report Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ReportType.values.where((type) => type != ReportType.combined).map((type) {
                return ElevatedButton.icon(
                  onPressed: () => _tabController.animateTo(_getTabIndexForReportType(type)),
                  icon: Icon(type.icon),
                  label: Text('${type.name} Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: type.color,
                    foregroundColor: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTab(ReportType reportType) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${reportType.name} Report Configuration',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<ReportPeriod>(
                          value: ref.watch(selectedReportPeriodProvider),
                          decoration: const InputDecoration(
                            labelText: 'Report Period',
                            border: OutlineInputBorder(),
                          ),
                          items: ReportPeriod.values.map((period) {
                            return DropdownMenuItem(value: period, child: Text(period.name));
                          }).toList(),
                          onChanged: (period) {
                            if (period != null) {
                              ref.read(selectedReportPeriodProvider.notifier).state = period;
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () => _generateReport(reportType),
                        icon: const Icon(Icons.analytics),
                        label: const Text('Generate Report'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: reportType.color,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildReportContent(reportType),
        ],
      ),
    );
  }

  Widget _buildReportContent(ReportType reportType) {
    return Consumer(
      builder: (context, ref, child) {
        final isLoading = ref.watch(isLoadingReportProvider);
        
        if (isLoading) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generating report...'),
                  ],
                ),
              ),
            ),
          );
        }

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
            break;
        }

        if (currentReport == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(reportType.icon, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('No ${reportType.name} report generated yet', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(
                      'Click "Generate Report" to create a ${reportType.name.toLowerCase()} report',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return _buildReportDisplay(currentReport, reportType);
      },
    );
  }

  Widget _buildReportDisplay(dynamic report, ReportType reportType) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${reportType.name} Report Results',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildReportDetails(report, reportType),
          ],
        ),
      ),
    );
  }

  Widget _buildReportDetails(dynamic report, ReportType reportType) {
    switch (reportType) {
      case ReportType.sales:
        final salesReport = report as SalesReport;
        return Column(
          children: [
            _buildInfoRow('Total Sales', '\$${salesReport.totalSales.toStringAsFixed(2)}'),
            _buildInfoRow('Total Transactions', '${salesReport.totalTransactions}'),
            _buildInfoRow('Average Transaction', '\$${salesReport.averageTransactionValue.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            Text('Sales by Category', style: Theme.of(context).textTheme.titleMedium),
            ...salesReport.salesByCategory.entries.map((e) => _buildInfoRow(e.key, '\$${e.value.toStringAsFixed(2)}')),
          ],
        );
      case ReportType.booking:
        final bookingReport = report as BookingReport;
        return Column(
          children: [
            _buildInfoRow('Total Bookings', '${bookingReport.totalBookings}'),
            _buildInfoRow('Checked In', '${bookingReport.checkedIn}'),
            _buildInfoRow('Checked Out', '${bookingReport.checkedOut}'),
            _buildInfoRow('Cancelled', '${bookingReport.cancelled}'),
            _buildInfoRow('Total Revenue', '\$${bookingReport.totalRevenue.toStringAsFixed(2)}'),
            _buildInfoRow('Occupancy Rate', '${bookingReport.occupancyRate.toStringAsFixed(1)}%'),
          ],
        );
      case ReportType.inventory:
        final inventoryReport = report as InventoryReport;
        return Column(
          children: [
            _buildInfoRow('Total Products', '${inventoryReport.totalProducts}'),
            _buildInfoRow('Low Stock Items', '${inventoryReport.lowStockItems}'),
            _buildInfoRow('Out of Stock Items', '${inventoryReport.outOfStockItems}'),
            _buildInfoRow('Total Inventory Value', '\$${inventoryReport.totalInventoryValue.toStringAsFixed(2)}'),
          ],
        );
      case ReportType.customer:
        final customerReport = report as CustomerReport;
        return Column(
          children: [
            _buildInfoRow('Total Customers', '${customerReport.totalCustomers}'),
            _buildInfoRow('New Customers', '${customerReport.newCustomers}'),
            _buildInfoRow('Returning Customers', '${customerReport.returningCustomers}'),
            _buildInfoRow('Average Spend', '\$${customerReport.averageSpendPerCustomer.toStringAsFixed(2)}'),
          ],
        );
      case ReportType.financial:
        final financialReport = report as FinancialReport;
        return Column(
          children: [
            _buildInfoRow('Total Revenue', '\$${financialReport.totalRevenue.toStringAsFixed(2)}'),
            _buildInfoRow('Total Expenses', '\$${financialReport.totalExpenses.toStringAsFixed(2)}'),
            _buildInfoRow('Gross Profit', '\$${financialReport.grossProfit.toStringAsFixed(2)}'),
            _buildInfoRow('Net Profit', '\$${financialReport.netProfit.toStringAsFixed(2)}'),
          ],
        );
      default:
        return const Text('Report type not supported');
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: TextStyle(fontSize: 14, color: Colors.grey.shade600), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  int _getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 2;
  }

  int _getTabIndexForReportType(ReportType type) {
    switch (type) {
      case ReportType.sales: return 1;
      case ReportType.booking: return 2;
      case ReportType.inventory: return 3;
      case ReportType.customer: return 4;
      case ReportType.financial: return 5;
      default: return 0;
    }
  }

  Future<void> _generateReport(ReportType reportType) async {
    ref.read(isLoadingReportProvider.notifier).state = true;
    ref.read(selectedReportTypeProvider.notifier).state = reportType;

    try {
      final period = ref.read(selectedReportPeriodProvider);
      final startDate = ref.read(customStartDateProvider);
      final endDate = ref.read(customEndDateProvider);

      final reportAsync = ref.read(generateReportProvider({
        'type': reportType,
        'period': period,
        'startDate': startDate,
        'endDate': endDate,
      }).future);

      final report = await reportAsync;

      switch (reportType) {
        case ReportType.sales:
          ref.read(currentSalesReportProvider.notifier).state = report as SalesReport;
          break;
        case ReportType.booking:
          ref.read(currentBookingReportProvider.notifier).state = report as BookingReport;
          break;
        case ReportType.inventory:
          ref.read(currentInventoryReportProvider.notifier).state = report as InventoryReport;
          break;
        case ReportType.customer:
          ref.read(currentCustomerReportProvider.notifier).state = report as CustomerReport;
          break;
        case ReportType.financial:
          ref.read(currentFinancialReportProvider.notifier).state = report as FinancialReport;
          break;
        default:
          break;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${reportType.name} report generated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating report: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      ref.read(isLoadingReportProvider.notifier).state = false;
    }
  }
}
