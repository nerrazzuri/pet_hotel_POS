import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/inventory/presentation/providers/product_providers.dart';
import 'package:cat_hotel_pos/features/services/domain/entities/product.dart';
import 'package:cat_hotel_pos/features/inventory/domain/entities/inventory_transaction.dart';
import 'package:cat_hotel_pos/features/inventory/presentation/providers/inventory_transaction_providers.dart';
import 'package:intl/intl.dart';

class InventoryReportsTab extends ConsumerStatefulWidget {
  const InventoryReportsTab({super.key});

  @override
  ConsumerState<InventoryReportsTab> createState() => _InventoryReportsTabState();
}

class _InventoryReportsTabState extends ConsumerState<InventoryReportsTab> {
  String _selectedReportType = 'overview';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(inventoryAnalyticsProvider);
    final transactionsAsync = ref.watch(inventoryTransactionsProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildHeader(),
          const SizedBox(height: 24),

          // Report Type Selector
          _buildReportTypeSelector(),
          const SizedBox(height: 24),

          // Date Range Selector
          _buildDateRangeSelector(),
          const SizedBox(height: 24),

          // Report Content
          Expanded(
            child: _buildReportContent(analyticsAsync, transactionsAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inventory Reports & Analytics',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Comprehensive insights into your inventory performance',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        Row(
          children: [
            // Export Report Button
            OutlinedButton.icon(
              onPressed: _exportReport,
              icon: const Icon(Icons.download),
              label: const Text('Export Report'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green[600],
                side: BorderSide(color: Colors.green[600]!),
              ),
            ),
            const SizedBox(width: 12),
            // Print Report Button
            ElevatedButton.icon(
              onPressed: _printReport,
              icon: const Icon(Icons.print),
              label: const Text('Print Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReportTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                _buildReportTypeChip('overview', 'Overview', Icons.dashboard),
                _buildReportTypeChip('stock_levels', 'Stock Levels', Icons.inventory),
                _buildReportTypeChip('movements', 'Stock Movements', Icons.swap_horiz),
                _buildReportTypeChip('valuation', 'Inventory Valuation', Icons.attach_money),
                _buildReportTypeChip('supplier', 'Supplier Analysis', Icons.business),
                _buildReportTypeChip('forecasting', 'Demand Forecasting', Icons.trending_up),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTypeChip(String value, String label, IconData icon) {
    final isSelected = _selectedReportType == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedReportType = value;
        });
      },
      selectedColor: Colors.teal[100],
      checkmarkColor: Colors.teal[800],
    );
  }

  Widget _buildDateRangeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Text(
              'Date Range: ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(width: 16),
            // Start Date
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _startDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(DateFormat('MMM dd, yyyy').format(_startDate)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Text('to', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 16),
            // End Date
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _endDate,
                  firstDate: _startDate,
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  setState(() => _endDate = date);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(DateFormat('MMM dd, yyyy').format(_endDate)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Quick Date Buttons
            Wrap(
              spacing: 8,
              children: [
                _buildQuickDateButton('Last 7 Days', 7),
                _buildQuickDateButton('Last 30 Days', 30),
                _buildQuickDateButton('Last 90 Days', 90),
                _buildQuickDateButton('This Year', 365),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDateButton(String label, int days) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          _endDate = DateTime.now();
          _startDate = DateTime.now().subtract(Duration(days: days));
        });
      },
      child: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 36),
      ),
    );
  }

  Widget _buildReportContent(AsyncValue<Map<String, dynamic>> analyticsAsync, 
                            AsyncValue<List<InventoryTransaction>> transactionsAsync) {
    switch (_selectedReportType) {
      case 'overview':
        return _buildOverviewReport(analyticsAsync);
      case 'stock_levels':
        return _buildStockStatusReport();
      case 'movements':
        return _buildStockMovementReport();
      case 'valuation':
        return _buildValuationReport();
      case 'supplier':
        return _buildSupplierAnalysisReport();
      case 'forecasting':
        return _buildDemandForecastingReport();
      default:
        return _buildOverviewReport(analyticsAsync);
    }
  }

  Widget _buildOverviewReport(AsyncValue<Map<String, dynamic>> analyticsAsync) {
    return analyticsAsync.when(
      data: (analytics) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Key Performance Indicators
            _buildKPISection(analytics),
            const SizedBox(height: 24),
            
            // Inventory Health Status
            _buildInventoryHealthSection(analytics),
            const SizedBox(height: 24),
            
            // Top Products by Value
            _buildTopProductsSection(analytics),
            const SizedBox(height: 24),
            
            // Category Distribution
            _buildCategoryDistributionSection(analytics),
          ],
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Error loading analytics')),
    );
  }

  Widget _buildKPISection(Map<String, dynamic> analytics) {
    final kpis = [
      {
        'title': 'Total Products',
        'value': '${analytics['totalProducts'] ?? 0}',
        'icon': Icons.inventory,
        'color': Colors.blue,
        'trend': '+5%',
        'trendColor': Colors.green,
      },
      {
        'title': 'Total Stock Value',
        'value': '\$${(analytics['totalValue'] ?? 0.0).toStringAsFixed(2)}',
        'icon': Icons.attach_money,
        'color': Colors.green,
        'trend': '+12%',
        'trendColor': Colors.green,
      },
      {
        'title': 'Low Stock Items',
        'value': '${analytics['lowStockProducts'] ?? 0}',
        'icon': Icons.warning,
        'color': Colors.orange,
        'trend': '-2',
        'trendColor': Colors.red,
      },
      {
        'title': 'Out of Stock',
        'value': '${analytics['outOfStockProducts'] ?? 0}',
        'icon': Icons.remove_shopping_cart,
        'color': Colors.red,
        'trend': '-1',
        'trendColor': Colors.green,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Performance Indicators',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.2,
          ),
          itemCount: kpis.length,
          itemBuilder: (context, index) {
            final kpi = kpis[index];
            return _buildKPICard(kpi);
          },
        ),
      ],
    );
  }

  Widget _buildKPICard(Map<String, dynamic> kpi) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  kpi['icon'] as IconData,
                  color: kpi['color'] as Color,
                  size: 24,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (kpi['trendColor'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    kpi['trend'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: kpi['trendColor'] as Color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              kpi['value'] as String,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: kpi['color'] as Color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              kpi['title'] as String,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryHealthSection(Map<String, dynamic> analytics) {
    final totalProducts = analytics['totalProducts'] ?? 0;
    final lowStockProducts = analytics['lowStockProducts'] ?? 0;
    final outOfStockProducts = analytics['outOfStockProducts'] ?? 0;
    final healthyProducts = totalProducts - lowStockProducts - outOfStockProducts;
    
    final healthPercentage = totalProducts > 0 ? (healthyProducts / totalProducts * 100).round() : 0;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inventory Health Status',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildHealthIndicator(
                    'Healthy',
                    healthyProducts,
                    Colors.green,
                    healthPercentage,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildHealthIndicator(
                    'Low Stock',
                    lowStockProducts,
                    Colors.orange,
                    totalProducts > 0 ? (lowStockProducts / totalProducts * 100).round() : 0,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildHealthIndicator(
                    'Out of Stock',
                    outOfStockProducts,
                    Colors.red,
                    totalProducts > 0 ? (outOfStockProducts / totalProducts * 100).round() : 0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: healthPercentage / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                healthPercentage >= 80 ? Colors.green : 
                healthPercentage >= 60 ? Colors.orange : Colors.red,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              'Overall Health: $healthPercentage%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: healthPercentage >= 80 ? Colors.green : 
                       healthPercentage >= 60 ? Colors.orange : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator(String label, int count, Color color, int percentage) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              '$count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          '$percentage%',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTopProductsSection(Map<String, dynamic> analytics) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Products by Stock Value',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Product value analysis coming soon!',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryDistributionSection(Map<String, dynamic> analytics) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Distribution',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Category analysis and charts coming soon!',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsGrid(Map<String, dynamic> analytics) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildMetricCard(
          'Total Products',
          analytics['totalProducts'].toString(),
          Icons.inventory,
          Colors.blue,
        ),
        _buildMetricCard(
          'Total Value',
          '\$${analytics['totalValue'].toStringAsFixed(2)}',
          Icons.attach_money,
          Colors.green,
        ),
        _buildMetricCard(
          'Low Stock Items',
          analytics['lowStockCount'].toString(),
          Icons.warning,
          Colors.orange,
        ),
        _buildMetricCard(
          'Out of Stock',
          analytics['outOfStockCount'].toString(),
          Icons.error,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inventory Trends',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text(
                      'Charts coming soon!',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      'Integration with fl_chart package',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Inventory Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            // Placeholder for recent transactions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: const Center(
                child: Text(
                  'Recent activity will be displayed here',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockStatusReport() {
    return Consumer(
      builder: (context, ref, child) {
        final productsAsync = ref.watch(productsProvider);
        
        return productsAsync.when(
          data: (products) => SingleChildScrollView(
            child: Column(
              children: [
                _buildStockStatusSummary(products),
                const SizedBox(height: 24),
                _buildStockStatusTable(products),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('Error loading products')),
        );
      },
    );
  }

  Widget _buildStockStatusSummary(List<Product> products) {
    final lowStock = products.where((p) => 
        p.reorderPoint != null && p.stockQuantity <= p.reorderPoint!).length;
    final outOfStock = products.where((p) => p.stockQuantity == 0).length;
    final healthy = products.where((p) => 
        p.reorderPoint == null || p.stockQuantity > p.reorderPoint!).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatusSummaryCard(
            'Healthy Stock',
            healthy.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusSummaryCard(
            'Low Stock',
            lowStock.toString(),
            Icons.warning,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatusSummaryCard(
            'Out of Stock',
            outOfStock.toString(),
            Icons.error,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSummaryCard(String title, String count, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              count,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockStatusTable(List<Product> products) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stock Status Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Product')),
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Current Stock')),
                  DataColumn(label: Text('Reorder Point')),
                  DataColumn(label: Text('Status')),
                  DataColumn(label: Text('Value')),
                ],
                rows: products.map((product) {
                  final status = _getStockStatus(product);
                  return DataRow(
                    cells: [
                      DataCell(Text(product.name)),
                      DataCell(Text(product.category.name)),
                      DataCell(Text(product.stockQuantity.toString())),
                      DataCell(Text(product.reorderPoint?.toString() ?? '-')),
                      DataCell(_buildStatusChip(status)),
                      DataCell(Text('\$${(product.stockQuantity * product.price).toStringAsFixed(2)}')),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStockStatus(Product product) {
    if (product.stockQuantity == 0) return 'out_of_stock';
    if (product.reorderPoint != null && product.stockQuantity <= product.reorderPoint!) {
      return 'low_stock';
    }
    return 'healthy';
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    
    switch (status) {
      case 'healthy':
        color = Colors.green;
        label = 'Healthy';
        break;
      case 'low_stock':
        color = Colors.orange;
        label = 'Low Stock';
        break;
      case 'out_of_stock':
        color = Colors.red;
        label = 'Out of Stock';
        break;
      default:
        color = Colors.grey;
        label = 'Unknown';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStockMovementReport() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.trending_up, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Stock Movement Report',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon! This will show stock movement patterns and trends.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildValuationReport() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.attach_money, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Inventory Valuation Report',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon! This will show detailed inventory valuation analysis.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierAnalysisReport() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.business, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Supplier Analysis Report',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon! This will show supplier performance and analysis.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDemandForecastingReport() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.trending_up, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Demand Forecasting Report',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(
            'Coming soon! This will show demand forecasting and predictions.',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _exportReport() {
    // TODO: Implement report export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon!')),
    );
  }

  void _printReport() {
    // TODO: Implement report printing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Print functionality coming soon!')),
    );
  }
}
