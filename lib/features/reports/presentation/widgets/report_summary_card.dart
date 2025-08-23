import 'package:flutter/material.dart';
import 'package:cat_hotel_pos/features/reports/domain/entities/report.dart';

class ReportSummaryCard extends StatelessWidget {
  final dynamic report;
  final ReportType reportType;

  const ReportSummaryCard({
    super.key,
    required this.report,
    required this.reportType,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  reportType.icon,
                  size: 32,
                  color: reportType.color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${reportType.name} Report Summary',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        reportType.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSummaryContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryContent() {
    switch (reportType) {
      case ReportType.sales:
        final salesReport = report as SalesReport;
        return Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                'Total Sales',
                '\$${salesReport.totalSales.toStringAsFixed(2)}',
                Icons.attach_money,
                Colors.green,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                'Transactions',
                '${salesReport.totalTransactions}',
                Icons.receipt,
                Colors.blue,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                'Avg. Transaction',
                '\$${salesReport.averageTransactionValue.toStringAsFixed(2)}',
                Icons.trending_up,
                Colors.orange,
              ),
            ),
          ],
        );

      case ReportType.booking:
        final bookingReport = report as BookingReport;
        return Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                'Total Bookings',
                '${bookingReport.totalBookings}',
                Icons.hotel,
                Colors.orange,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                'Revenue',
                '\$${bookingReport.totalRevenue.toStringAsFixed(2)}',
                Icons.attach_money,
                Colors.green,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                'Occupancy',
                '${bookingReport.occupancyRate.toStringAsFixed(1)}%',
                Icons.pie_chart,
                Colors.purple,
              ),
            ),
          ],
        );

      case ReportType.inventory:
        final inventoryReport = report as InventoryReport;
        return Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                'Total Products',
                '${inventoryReport.totalProducts}',
                Icons.inventory,
                Colors.purple,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                'Low Stock',
                '${inventoryReport.lowStockItems}',
                Icons.warning,
                Colors.amber,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                'Total Value',
                '\$${inventoryReport.totalInventoryValue.toStringAsFixed(2)}',
                Icons.attach_money,
                Colors.green,
              ),
            ),
          ],
        );

      case ReportType.customer:
        final customerReport = report as CustomerReport;
        return Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                'Total Customers',
                '${customerReport.totalCustomers}',
                Icons.people,
                Colors.blue,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                'New Customers',
                '${customerReport.newCustomers}',
                Icons.person_add,
                Colors.green,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                'Avg. Spend',
                '\$${customerReport.averageSpendPerCustomer.toStringAsFixed(2)}',
                Icons.attach_money,
                Colors.orange,
              ),
            ),
          ],
        );

      case ReportType.financial:
        final financialReport = report as FinancialReport;
        return Row(
          children: [
            Expanded(
              child: _buildSummaryItem(
                'Total Revenue',
                '\$${financialReport.totalRevenue.toStringAsFixed(2)}',
                Icons.trending_up,
                Colors.green,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                'Total Expenses',
                '\$${financialReport.totalExpenses.toStringAsFixed(2)}',
                Icons.trending_down,
                Colors.red,
              ),
            ),
            Expanded(
              child: _buildSummaryItem(
                'Net Profit',
                '\$${financialReport.netProfit.toStringAsFixed(2)}',
                Icons.account_balance,
                financialReport.netProfit >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        );

      default:
        return const Text('Report type not supported');
    }
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
