import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/financials/domain/entities/budget.dart';
import 'package:cat_hotel_pos/core/services/financial_dao.dart';

class BudgetsTab extends ConsumerStatefulWidget {
  const BudgetsTab({super.key});

  @override
  ConsumerState<BudgetsTab> createState() => _BudgetsTabState();
}

class _BudgetsTabState extends ConsumerState<BudgetsTab> {
  final FinancialDao _financialDao = FinancialDao();
  List<Budget> _budgets = [];
  bool _isLoading = true;
  String _searchQuery = '';
  BudgetPeriod? _selectedPeriod;
  BudgetStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadBudgets();
  }

  Future<void> _loadBudgets() async {
    setState(() => _isLoading = true);
    try {
      final budgets = await _financialDao.getAllBudgets();
      setState(() {
        _budgets = budgets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading budgets: $e')),
        );
      }
    }
  }

  List<Budget> get _filteredBudgets {
    return _budgets.where((budget) {
      final matchesSearch = budget.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (budget.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      
      final matchesPeriod = _selectedPeriod == null || budget.period == _selectedPeriod;
      final matchesStatus = _selectedStatus == null || budget.status == _selectedStatus;
      
      return matchesSearch && matchesPeriod && matchesStatus;
    }).toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and filters
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search budgets...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
              const SizedBox(height: 16),
              
              // Filter chips
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<BudgetPeriod>(
                      decoration: const InputDecoration(
                        labelText: 'Budget Period',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedPeriod,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Periods'),
                        ),
                        ...BudgetPeriod.values.map((period) => DropdownMenuItem(
                          value: period,
                          child: Text(period.displayName),
                        )),
                      ],
                      onChanged: (value) => setState(() => _selectedPeriod = value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<BudgetStatus>(
                      decoration: const InputDecoration(
                        labelText: 'Status',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedStatus,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Statuses'),
                        ),
                        ...BudgetStatus.values.map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status.displayName),
                        )),
                      ],
                      onChanged: (value) => setState(() => _selectedStatus = value),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Budgets list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredBudgets.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_balance_wallet_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No budgets found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredBudgets.length,
                      itemBuilder: (context, index) {
                        final budget = _filteredBudgets[index];
                        return _buildBudgetCard(budget);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildBudgetCard(Budget budget) {
    final totalAllocated = budget.categories?.fold<double>(0.0, (sum, cat) => sum + cat.allocatedAmount) ?? 0.0;
    final totalSpent = budget.categories?.fold<double>(0.0, (sum, cat) => sum + cat.spentAmount) ?? 0.0;
    final remainingAmount = totalAllocated - totalSpent;
    final progressPercentage = totalAllocated > 0 ? (totalSpent / totalAllocated) : 0.0;
    final isOverBudget = totalSpent > totalAllocated;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      if (budget.description != null)
                        Text(
                          budget.description!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(budget.status),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    budget.status.displayName,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Period and dates
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    budget.period.displayName,
                    style: TextStyle(color: Colors.amber[800], fontSize: 12),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${budget.startDate.toString().split(' ')[0]} - ${budget.endDate.toString().split(' ')[0]}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Budget overview
            Row(
              children: [
                Expanded(
                  child: _buildBudgetMetric(
                    'Total Budget',
                    '${budget.currency} ${budget.totalAmount.toStringAsFixed(2)}',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildBudgetMetric(
                    'Allocated',
                    '${budget.currency} ${totalAllocated.toStringAsFixed(2)}',
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildBudgetMetric(
                    'Spent',
                    '${budget.currency} ${totalSpent.toStringAsFixed(2)}',
                    isOverBudget ? Colors.red : Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildBudgetMetric(
                    'Remaining',
                    '${budget.currency} ${remainingAmount.toStringAsFixed(2)}',
                    remainingAmount >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Budget Utilization',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      '${(progressPercentage * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isOverBudget ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progressPercentage.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOverBudget ? Colors.red : Colors.green,
                  ),
                  minHeight: 8,
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Categories summary
            if (budget.categories != null && budget.categories!.isNotEmpty) ...[
              Text(
                'Categories',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              ...budget.categories!.take(3).map((category) => _buildCategoryRow(category, budget.currency)),
              if (budget.categories!.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '... and ${budget.categories!.length - 3} more categories',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
            
            const SizedBox(height: 16),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showBudgetDetails(budget),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditBudgetDialog(budget),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showBudgetReport(budget),
                    icon: const Icon(Icons.assessment, size: 18),
                    label: const Text('Report'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _deleteBudget(budget),
                    icon: const Icon(Icons.delete, size: 18),
                    label: const Text('Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
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

  Widget _buildBudgetMetric(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildCategoryRow(BudgetCategory category, String currency) {
    final progressPercentage = category.allocatedAmount > 0 
        ? (category.spentAmount / category.allocatedAmount) 
        : 0.0;
    final isOverBudget = category.spentAmount > category.allocatedAmount;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              category.name,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${currency} ${category.allocatedAmount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              '${currency} ${category.spentAmount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 12,
                color: isOverBudget ? Colors.red : Colors.grey,
                fontWeight: isOverBudget ? FontWeight.bold : FontWeight.normal,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            flex: 2,
            child: LinearProgressIndicator(
              value: progressPercentage.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? Colors.red : Colors.green,
              ),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BudgetStatus status) {
    switch (status) {
      case BudgetStatus.draft:
        return Colors.grey;
      case BudgetStatus.active:
        return Colors.green;
      case BudgetStatus.completed:
        return Colors.blue;
      case BudgetStatus.cancelled:
        return Colors.red;
    }
  }

  void _showBudgetDetails(Budget budget) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Budget Details - ${budget.name}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Name', budget.name),
              if (budget.description != null) _buildDetailRow('Description', budget.description!),
              _buildDetailRow('Period', budget.period.displayName),
              _buildDetailRow('Start Date', budget.startDate.toString().split(' ')[0]),
              _buildDetailRow('End Date', budget.endDate.toString().split(' ')[0]),
              _buildDetailRow('Total Amount', '${budget.currency} ${budget.totalAmount.toStringAsFixed(2)}'),
              _buildDetailRow('Status', budget.status.displayName),
              _buildDetailRow('Created', budget.createdAt.toString().split(' ')[0]),
              _buildDetailRow('Last Updated', budget.updatedAt.toString().split(' ')[0]),
              
              if (budget.categories != null && budget.categories!.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text(
                  'Categories:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...budget.categories!.map((category) => _buildCategoryDetail(category, budget.currency)),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildCategoryDetail(BudgetCategory category, String currency) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (category.description != null)
              Text(
                category.description!,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Allocated: ${currency} ${category.allocatedAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Spent: ${currency} ${category.spentAmount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: category.spentAmount > category.allocatedAmount ? Colors.red : Colors.grey,
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

  void _showEditBudgetDialog(Budget budget) {
    // TODO: Implement edit budget dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit budget functionality coming soon!')),
    );
  }

  void _showBudgetReport(Budget budget) {
    // TODO: Implement budget report
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Budget report functionality coming soon!')),
    );
  }

  Future<void> _deleteBudget(Budget budget) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget'),
        content: Text(
          'Are you sure you want to delete "${budget.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _financialDao.deleteBudget(budget.id);
        await _loadBudgets();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${budget.name} has been deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting budget: $e')),
          );
        }
      }
    }
  }
}
