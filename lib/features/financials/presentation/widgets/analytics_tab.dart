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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.calendar_today,
                    color: Colors.amber[800],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Analysis Period',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildPeriodChip('Current Month', 'current_month'),
                _buildPeriodChip('Last Month', 'last_month'),
                _buildPeriodChip('Current Quarter', 'current_quarter'),
                _buildPeriodChip('Current Year', 'current_year'),
                _buildPeriodChip('Last Year', 'last_year'),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.grey[600]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Period: ${_startDate.toString().split(' ')[0]} - ${_endDate.toString().split(' ')[0]}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _showCustomDatePicker(context),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: const Text('Custom Range'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.amber[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, String period) {
    final isSelected = _selectedPeriod == period;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => _updatePeriod(period),
      selectedColor: Colors.amber[100],
      checkmarkColor: Colors.amber[800],
      labelStyle: TextStyle(
        color: isSelected ? Colors.amber[800] : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? Colors.amber[300]! : Colors.grey[300]!,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.analytics,
                    color: Colors.blue[800],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Financial Overview',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOverviewItem(
                    'Transactions',
                    _financialSummary['totalTransactions']?.toString() ?? '0',
                    Icons.receipt_long,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
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
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey[400]),
                ),
                const SizedBox(height: 20),
                Text(
                  'No category data available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Category breakdown will appear here once you have transaction data',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.pie_chart,
                    color: Colors.green[800],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Expense Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showDetailedCategoryReport(),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Full Report'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ..._categoryBreakdown.take(5).map((category) => _buildCategoryRow(category)),
            if (_categoryBreakdown.length > 5)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Center(
                  child: TextButton.icon(
                    onPressed: () => _showDetailedCategoryReport(),
                    icon: const Icon(Icons.expand_more, size: 16),
                    label: Text('View all ${_categoryBreakdown.length} categories'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.flash_on,
                    color: Colors.purple[800],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.file_download,
                    label: 'Export Report',
                    color: Colors.blue,
                    onPressed: () => _exportFinancialReport(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.timeline,
                    label: 'Cash Flow',
                    color: Colors.green,
                    onPressed: () => _generateCashFlowReport(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.analytics,
                    label: 'P&L Report',
                    color: Colors.orange,
                    onPressed: () => _generateProfitLossReport(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.3)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
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
