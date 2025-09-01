import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/financials/domain/entities/budget.dart';
import 'package:cat_hotel_pos/core/services/financial_dao.dart';
import 'package:cat_hotel_pos/features/financials/presentation/widgets/add_budget_dialog.dart';

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
        // Header with search and filters
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search budgets by name or description...',
                    hintStyle: TextStyle(color: Colors.grey[500]),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (value) => setState(() => _searchQuery = value),
                ),
              ),
              const SizedBox(height: 16),
              
              // Filter chips
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: DropdownButtonFormField<BudgetPeriod>(
                        decoration: const InputDecoration(
                          labelText: 'Budget Period',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
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
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: DropdownButtonFormField<BudgetStatus>(
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
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
                  ),
                ],
              ),
              
              // Results count
              if (_filteredBudgets.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${_filteredBudgets.length} budget${_filteredBudgets.length == 1 ? '' : 's'} found',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _showAddBudgetDialog,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Create Budget'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      'No budgets found',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _showAddBudgetDialog,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Create Budget'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),

        // Budgets list
        Expanded(
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber[800]!),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading budgets...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : _filteredBudgets.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No budgets found',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty || _selectedPeriod != null || _selectedStatus != null
                                ? 'Try adjusting your search or filters'
                                : 'Create your first budget to get started',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: _filteredBudgets.length,
                      itemBuilder: (context, index) {
                        final budget = _filteredBudgets[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildBudgetCard(budget),
                        );
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
      child: InkWell(
        onTap: () => _showBudgetDetails(budget),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: Colors.amber[800],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          budget.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        if (budget.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            budget.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Period and dates
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      budget.period.displayName,
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${budget.startDate.toString().split(' ')[0]} - ${budget.endDate.toString().split(' ')[0]}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildBudgetMetric(
                      'Allocated',
                      '${budget.currency} ${totalAllocated.toStringAsFixed(2)}',
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildBudgetMetric(
                      'Spent',
                      '${budget.currency} ${totalSpent.toStringAsFixed(2)}',
                      isOverBudget ? Colors.red : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildBudgetMetric(
                      'Remaining',
                      '${budget.currency} ${remainingAmount.toStringAsFixed(2)}',
                      remainingAmount >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
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
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        '${(progressPercentage * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isOverBudget ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progressPercentage.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOverBudget ? Colors.red : Colors.green,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Categories summary
              if (budget.categories != null && budget.categories!.isNotEmpty) ...[
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 20),
              ],
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showBudgetDetails(budget),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('View Details'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: BorderSide(color: Colors.blue.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showEditBudgetDialog(budget),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: BorderSide(color: Colors.orange.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showBudgetReport(budget),
                      icon: const Icon(Icons.assessment, size: 16),
                      label: const Text('Report'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: BorderSide(color: Colors.green.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onSelected: (value) => _handleBudgetAction(value, budget),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
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

  void _handleBudgetAction(String action, Budget budget) {
    switch (action) {
      case 'delete':
        _deleteBudget(budget);
        break;
    }
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

  void _showAddBudgetDialog() {
    showDialog(
      context: context,
      builder: (context) => AddBudgetDialog(
        onBudgetAdded: (budget) {
          _loadBudgets();
        },
      ),
    );
  }
}
