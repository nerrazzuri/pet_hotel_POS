import 'package:flutter/material.dart';
import 'package:cat_hotel_pos/features/reports/domain/entities/report.dart';

class ReportChartWidget extends StatelessWidget {
  final dynamic report;
  final ReportType reportType;

  const ReportChartWidget({
    super.key,
    required this.report,
    required this.reportType,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${reportType.name} Analytics',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildChartContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildChartContent() {
    switch (reportType) {
      case ReportType.sales:
        final salesReport = report as SalesReport;
        return _buildSalesChart(salesReport);

      case ReportType.booking:
        final bookingReport = report as BookingReport;
        return _buildBookingChart(bookingReport);

      case ReportType.inventory:
        final inventoryReport = report as InventoryReport;
        return _buildInventoryChart(inventoryReport);

      case ReportType.customer:
        final customerReport = report as CustomerReport;
        return _buildCustomerChart(customerReport);

      case ReportType.financial:
        final financialReport = report as FinancialReport;
        return _buildFinancialChart(financialReport);

      default:
        return const Text('Chart not available for this report type');
    }
  }

  Widget _buildSalesChart(SalesReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sales by Category',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        if (report.salesByCategory.isEmpty)
          const Text('No sales data available')
        else
          ...report.salesByCategory.entries.map((entry) {
            final percentage = report.totalSales > 0 
                ? (entry.value / report.totalSales) * 100 
                : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text('\$${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ],
              ),
            );
          }).toList(),
        
        const SizedBox(height: 20),
        
        Text(
          'Top Selling Products',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        if (report.quantitySoldByProduct.isEmpty)
          const Text('No product sales data available')
        else
          ...(() {
            final sortedEntries = report.quantitySoldByProduct.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
            return sortedEntries.take(5).map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(entry.key)),
                  Text('${entry.value} sold'),
                ],
              ),
            )).toList();
          })(),
      ],
    );
  }

  Widget _buildBookingChart(BookingReport report) {
    final total = report.totalBookings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Booking Status Distribution',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        if (total == 0)
          const Text('No booking data available')
        else ...[
          _buildStatusBar('Checked In', report.checkedIn, total, Colors.green),
          const SizedBox(height: 8),
          _buildStatusBar('Checked Out', report.checkedOut, total, Colors.blue),
          const SizedBox(height: 8),
          _buildStatusBar('Cancelled', report.cancelled, total, Colors.red),
        ],
        
        const SizedBox(height: 20),
        
        Text(
          'Bookings by Room Type',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        if (report.bookingsByRoomType.isEmpty)
          const Text('No room type data available')
        else
          ...report.bookingsByRoomType.entries.map((entry) {
            final percentage = total > 0 ? (entry.value / total) * 100 : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text('${entry.value} bookings (${percentage.toStringAsFixed(1)}%)'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildInventoryChart(InventoryReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Stock Status Overview',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                'In Stock',
                '${report.totalProducts - report.outOfStockItems}',
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusCard(
                'Low Stock',
                '${report.lowStockItems}',
                Colors.amber,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusCard(
                'Out of Stock',
                '${report.outOfStockItems}',
                Colors.red,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'Inventory by Category',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        if (report.stockByCategory.isEmpty)
          const Text('No category data available')
        else
          ...report.stockByCategory.entries.map((entry) {
            final totalStock = report.stockByCategory.values.fold(0, (a, b) => a + b);
            final percentage = totalStock > 0 ? (entry.value / totalStock) * 100 : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text('${entry.value} items (${percentage.toStringAsFixed(1)}%)'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildCustomerChart(CustomerReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Growth',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                'New Customers',
                '${report.newCustomers}',
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusCard(
                'Returning',
                '${report.returningCustomers}',
                Colors.blue,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'Customers by Region',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        if (report.customersByRegion.isEmpty)
          const Text('No regional data available')
        else
          ...report.customersByRegion.entries.map((entry) {
            final percentage = report.totalCustomers > 0 
                ? (entry.value / report.totalCustomers) * 100 
                : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text('${entry.value} customers (${percentage.toStringAsFixed(1)}%)'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildFinancialChart(FinancialReport report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Revenue vs Expenses',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatusCard(
                'Revenue',
                '\$${report.totalRevenue.toStringAsFixed(2)}',
                Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusCard(
                'Expenses',
                '\$${report.totalExpenses.toStringAsFixed(2)}',
                Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatusCard(
                'Net Profit',
                '\$${report.netProfit.toStringAsFixed(2)}',
                report.netProfit >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 20),
        
        Text(
          'Revenue Sources',
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        if (report.revenueBySource.isEmpty)
          const Text('No revenue source data available')
        else
          ...report.revenueBySource.entries.map((entry) {
            final percentage = report.totalRevenue > 0 
                ? (entry.value / report.totalRevenue) * 100 
                : 0.0;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text('\$${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                  ),
                ],
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildStatusBar(String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total) * 100 : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('$value (${percentage.toStringAsFixed(1)}%)'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  Widget _buildStatusCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
