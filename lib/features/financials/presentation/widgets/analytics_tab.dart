import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/core/services/financial_dao.dart';

class AnalyticsTab extends ConsumerStatefulWidget {
  const AnalyticsTab({super.key});

  @override
  ConsumerState<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends ConsumerState<AnalyticsTab> {
  final FinancialDao _financialDao = FinancialDao();
  Map<String, dynamic> _financialSummary = {};
  List<Map<String, dynamic>> _categoryBreakdown = [];
  bool _isLoading = true;
  String _selectedPeriod = 'current_month';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    try {
      final futures = await Future.wait([
        _financialDao.getFinancialSummary(),
        _financialDao.getCategoryBreakdown(),
      ]);
      
      setState(() {
        _financialSummary = futures[0] as Map<String, dynamic>;
        _categoryBreakdown = futures[1] as List<Map<String, dynamic>>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading analytics: $e')),
        );
      }
    }
  }

  void _updatePeriod(String period) {
    setState(() {
      _selectedPeriod = period;
      final now = DateTime.now();
      
      switch (period) {
        case 'current_month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = now;
          break;
        case 'last_month':
          _startDate = DateTime(now.year, now.month - 1, 1);
          _endDate = DateTime(now.year, now.month, 0);
          break;
        case 'current_quarter':
          final quarter = ((now.month - 1) / 3).floor();
          _startDate = DateTime(now.year, quarter * 3 + 1, 1);
          _endDate = now;
          break;
        case 'current_year':
          _startDate = DateTime(now.year, 1, 1);
          _endDate = now;
          break;
        case 'last_year':
          _startDate = DateTime(now.year - 1, 1, 1);
          _endDate = DateTime(now.year - 1, 12, 31);
          break;
        case 'custom':
          // Keep current dates for custom period
          break;
      }
    });
    
    _loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period selector
                _buildPeriodSelector(),
                const SizedBox(height: 24),
                
                // Key metrics
                _buildKeyMetrics(),
                const SizedBox(height: 24),
                
                // Financial overview
                _buildFinancialOverview(),
                const SizedBox(height: 24),
                
                // Category breakdown
                _buildCategoryBreakdown(),
                const SizedBox(height: 24),
                
                // Quick actions
                _buildQuickActions(),
              ],
            ),
          );
  }

  Widget _buildPeriodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Analysis Period',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Current Month'),
                  selected: _selectedPeriod == 'current_month',
                  onSelected: (selected) => _updatePeriod('current_month'),
                  selectedColor: Colors.amber[100],
                ),
                FilterChip(
                  label: const Text('Last Month'),
                  selected: _selectedPeriod == 'last_month',
                  onSelected: (selected) => _updatePeriod('last_month'),
                  selectedColor: Colors.amber[100],
                ),
                FilterChip(
                  label: const Text('Current Quarter'),
                  selected: _selectedPeriod == 'current_quarter',
                  onSelected: (selected) => _updatePeriod('current_quarter'),
                  selectedColor: Colors.amber[100],
                ),
                FilterChip(
                  label: const Text('Current Year'),
                  selected: _selectedPeriod == 'current_year',
                  onSelected: (selected) => _updatePeriod('current_year'),
                  selectedColor: Colors.amber[100],
                ),
                FilterChip(
                  label: const Text('Last Year'),
                  selected: _selectedPeriod == 'last_year',
                  onSelected: (selected) => _updatePeriod('last_year'),
                  selectedColor: Colors.amber[100],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Period: ${_startDate.toString().split(' ')[0]} - ${_endDate.toString().split(' ')[0]}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showCustomDatePicker(context),
                  icon: const Icon(Icons.calendar_today, size: 18),
                  label: const Text('Custom Range'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyMetrics() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          'Total Balance',
          'MYR ${_financialSummary['totalBalance']?.toStringAsFixed(2) ?? '0.00'}',
          Icons.account_balance,
          Colors.blue,
        ),
        _buildMetricCard(
          'Total Income',
          'MYR ${_financialSummary['totalIncome']?.toStringAsFixed(2) ?? '0.00'}',
          Icons.trending_up,
          Colors.green,
        ),
        _buildMetricCard(
          'Total Expenses',
          'MYR ${_financialSummary['totalExpenses']?.toStringAsFixed(2) ?? '0.00'}',
          Icons.trending_down,
          Colors.red,
        ),
        _buildMetricCard(
          'Net Income',
          'MYR ${_financialSummary['netIncome']?.toStringAsFixed(2) ?? '0.00'}',
          Icons.assessment,
          _financialSummary['netIncome'] != null && _financialSummary['netIncome'] >= 0
              ? Colors.green
              : Colors.red,
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialOverview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Overview',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewItem(
                    'Accounts',
                    _financialSummary['totalAccounts']?.toString() ?? '0',
                    Icons.account_balance,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildOverviewItem(
                    'Transactions',
                    _financialSummary['totalTransactions']?.toString() ?? '0',
                    Icons.receipt_long,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildOverviewItem(
                    'Active Budgets',
                    _financialSummary['activeBudgets']?.toString() ?? '0',
                    Icons.account_balance_wallet,
                    Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
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
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCategoryBreakdown() {
    if (_categoryBreakdown.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No category data available',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Expense Categories',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _showDetailedCategoryReport(),
                  child: const Text('View Full Report'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._categoryBreakdown.take(5).map((category) => _buildCategoryRow(category)),
            if (_categoryBreakdown.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: TextButton(
                    onPressed: () => _showDetailedCategoryReport(),
                    child: Text('View all ${_categoryBreakdown.length} categories'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(Map<String, dynamic> category) {
    final amount = category['amount'] as double? ?? 0.0;
    final percentage = category['percentage'] as double? ?? 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              category['category'] as String? ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'MYR ${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[700]!),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _exportFinancialReport(),
                    icon: const Icon(Icons.file_download, size: 18),
                    label: const Text('Export Report'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _generateCashFlowReport(),
                    icon: const Icon(Icons.timeline, size: 18),
                    label: const Text('Cash Flow'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _generateProfitLossReport(),
                    icon: const Icon(Icons.analytics, size: 18),
                    label: const Text('P&L Report'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showCustomDatePicker(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedPeriod = 'custom';
      });
      _loadAnalytics();
    }
  }

  void _showDetailedCategoryReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Category Breakdown Report'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ..._categoryBreakdown.map((category) => _buildDetailedCategoryRow(category)),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportCategoryReport();
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedCategoryRow(Map<String, dynamic> category) {
    final amount = category['amount'] as double? ?? 0.0;
    final percentage = category['percentage'] as double? ?? 0.0;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(category['category'] as String? ?? 'Unknown'),
        subtitle: Text('${percentage.toStringAsFixed(1)}% of total expenses'),
        trailing: Text(
          'MYR ${amount.toStringAsFixed(2)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  void _exportFinancialReport() {
    // TODO: Implement financial report export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Financial report export functionality coming soon!')),
    );
  }

  void _generateCashFlowReport() {
    // TODO: Implement cash flow report
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cash flow report functionality coming soon!')),
    );
  }

  void _generateProfitLossReport() {
    // TODO: Implement profit & loss report
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profit & Loss report functionality coming soon!')),
    );
  }

  void _exportCategoryReport() {
    // TODO: Implement category report export
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Category report export functionality coming soon!')),
    );
  }
}
