import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/financials/domain/entities/financial_account.dart';
import 'package:cat_hotel_pos/core/services/financial_dao.dart';
import 'package:cat_hotel_pos/features/financials/presentation/widgets/add_account_dialog.dart';
import 'package:cat_hotel_pos/features/financials/presentation/widgets/edit_account_dialog.dart';

class AccountsTab extends ConsumerStatefulWidget {
  const AccountsTab({super.key});

  @override
  ConsumerState<AccountsTab> createState() => _AccountsTabState();
}

class _AccountsTabState extends ConsumerState<AccountsTab> {
  final FinancialDao _financialDao = FinancialDao();
  List<FinancialAccount> _accounts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  AccountType? _selectedType;
  AccountStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  Future<void> _loadAccounts() async {
    setState(() => _isLoading = true);
    try {
      final accounts = await _financialDao.getAllAccounts();
      setState(() {
        _accounts = accounts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading accounts: $e')),
        );
      }
    }
  }

  List<FinancialAccount> get _filteredAccounts {
    return _accounts.where((account) {
      final matchesSearch = account.accountName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          account.accountNumber.contains(_searchQuery) ||
          (account.bankName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      
      final matchesType = _selectedType == null || account.accountType == _selectedType;
      final matchesStatus = _selectedStatus == null || account.status == _selectedStatus;
      
      return matchesSearch && matchesType && matchesStatus;
    }).toList();
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
                    hintText: 'Search accounts by name, number, or bank...',
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
                      child: DropdownButtonFormField<AccountType>(
                        decoration: const InputDecoration(
                          labelText: 'Account Type',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                        value: _selectedType,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Types'),
                          ),
                          ...AccountType.values.map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.shortName),
                          )),
                        ],
                        onChanged: (value) => setState(() => _selectedType = value),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: DropdownButtonFormField<AccountStatus>(
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
                          ...AccountStatus.values.map((status) => DropdownMenuItem(
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
              if (_filteredAccounts.isNotEmpty) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      '${_filteredAccounts.length} account${_filteredAccounts.length == 1 ? '' : 's'} found',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _showAddAccountDialog,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Account'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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
                      'No accounts found',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: _showAddAccountDialog,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Account'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
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

        // Accounts list
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
                        'Loading accounts...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : _filteredAccounts.isEmpty
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
                              Icons.account_balance_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No accounts found',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _searchQuery.isNotEmpty || _selectedType != null || _selectedStatus != null
                                ? 'Try adjusting your search or filters'
                                : 'Add your first financial account to get started',
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
                      itemCount: _filteredAccounts.length,
                      itemBuilder: (context, index) {
                        final account = _filteredAccounts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildAccountCard(account),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildAccountCard(FinancialAccount account) {
    final isPositive = account.balance >= 0;
    final balanceColor = isPositive ? Colors.green[700]! : Colors.red[700]!;
    
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
        onTap: () => _showAccountDetails(account),
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
                      color: _getAccountTypeColor(account.accountType).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getAccountTypeIcon(account.accountType),
                      color: _getAccountTypeColor(account.accountType),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.accountName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Account: ${account.accountNumber}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(account.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      account.status.displayName,
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
              
              // Bank info
              if (account.bankName != null) ...[
                Row(
                  children: [
                    Icon(Icons.account_balance, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(
                      account.bankName!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              
              // Balance and type
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Balance',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${account.currency} ${account.balance.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: balanceColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      account.accountType.shortName,
                      style: TextStyle(
                        color: Colors.amber[800],
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showAccountDetails(account),
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showAccountTransactions(account),
                      icon: const Icon(Icons.receipt_long, size: 16),
                      label: const Text('Transactions'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: BorderSide(color: Colors.green.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onSelected: (value) => _handleAccountAction(value, account),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      if (account.status == AccountStatus.active)
                        const PopupMenuItem(
                          value: 'freeze',
                          child: Row(
                            children: [
                              Icon(Icons.block, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Freeze Account'),
                            ],
                          ),
                        ),
                      if (account.status == AccountStatus.frozen)
                        const PopupMenuItem(
                          value: 'activate',
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Activate Account'),
                            ],
                          ),
                        ),
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

  Color _getAccountTypeColor(AccountType type) {
    switch (type) {
      case AccountType.checking:
        return Colors.blue;
      case AccountType.savings:
        return Colors.green;
      case AccountType.credit:
        return Colors.orange;
      case AccountType.loan:
        return Colors.red;
      case AccountType.investment:
        return Colors.purple;
      case AccountType.pettyCash:
        return Colors.teal;
      case AccountType.escrow:
        return Colors.indigo;
    }
  }

  IconData _getAccountTypeIcon(AccountType type) {
    switch (type) {
      case AccountType.checking:
        return Icons.account_balance;
      case AccountType.savings:
        return Icons.savings;
      case AccountType.credit:
        return Icons.credit_card;
      case AccountType.loan:
        return Icons.money_off;
      case AccountType.investment:
        return Icons.trending_up;
      case AccountType.pettyCash:
        return Icons.attach_money;
      case AccountType.escrow:
        return Icons.security;
    }
  }

  Color _getStatusColor(AccountStatus status) {
    switch (status) {
      case AccountStatus.active:
        return Colors.green;
      case AccountStatus.inactive:
        return Colors.grey;
      case AccountStatus.frozen:
        return Colors.orange;
      case AccountStatus.closed:
        return Colors.red;
    }
  }

  void _handleAccountAction(String action, FinancialAccount account) {
    switch (action) {
      case 'view':
        _showAccountDetails(account);
        break;
      case 'edit':
        _showEditAccountDialog(account);
        break;
      case 'transactions':
        _showAccountTransactions(account);
        break;
      case 'freeze':
        _freezeAccount(account);
        break;
      case 'activate':
        _activateAccount(account);
        break;
      case 'delete':
        _deleteAccount(account);
        break;
    }
  }

  void _showAccountDetails(FinancialAccount account) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Account Details - ${account.accountName}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Account Name', account.accountName),
              _buildDetailRow('Account Number', account.accountNumber),
              _buildDetailRow('Type', account.accountType.displayName),
              _buildDetailRow('Status', account.status.displayName),
              _buildDetailRow('Balance', '${account.currency} ${account.balance.toStringAsFixed(2)}'),
              if (account.description != null) _buildDetailRow('Description', account.description!),
              if (account.bankName != null) _buildDetailRow('Bank', account.bankName!),
              if (account.branchCode != null) _buildDetailRow('Branch Code', account.branchCode!),
              if (account.swiftCode != null) _buildDetailRow('SWIFT Code', account.swiftCode!),
              if (account.iban != null) _buildDetailRow('IBAN', account.iban!),
              if (account.creditLimit != null) _buildDetailRow('Credit Limit', '${account.currency} ${account.creditLimit!.toStringAsFixed(2)}'),
              if (account.interestRate != null) _buildDetailRow('Interest Rate', '${account.interestRate!.toStringAsFixed(2)}%'),
              _buildDetailRow('Created', account.createdAt.toString().split(' ')[0]),
              _buildDetailRow('Last Updated', account.updatedAt.toString().split(' ')[0]),
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



  void _showAccountTransactions(FinancialAccount account) {
    // TODO: Navigate to transactions tab with account filter
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing transactions for ${account.accountName}')),
    );
  }

  Future<void> _freezeAccount(FinancialAccount account) async {
    try {
      final updatedAccount = account.copyWith(
        status: AccountStatus.frozen,
        updatedAt: DateTime.now(),
      );
      await _financialDao.updateAccount(updatedAccount);
      await _loadAccounts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${account.accountName} has been frozen')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error freezing account: $e')),
        );
      }
    }
  }

  Future<void> _activateAccount(FinancialAccount account) async {
    try {
      final updatedAccount = account.copyWith(
        status: AccountStatus.active,
        updatedAt: DateTime.now(),
      );
      await _financialDao.updateAccount(updatedAccount);
      await _loadAccounts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${account.accountName} has been activated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error activating account: $e')),
        );
      }
    }
  }

  Future<void> _deleteAccount(FinancialAccount account) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: Text(
          'Are you sure you want to delete "${account.accountName}"? This action cannot be undone.',
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
        await _financialDao.deleteAccount(account.id);
        await _loadAccounts();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${account.accountName} has been deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting account: $e')),
          );
        }
      }
    }
  }

  void _showAddAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AddAccountDialog(
        onAccountAdded: (account) {
          _loadAccounts();
        },
      ),
    );
  }

  void _showEditAccountDialog(FinancialAccount account) {
    showDialog(
      context: context,
      builder: (context) => EditAccountDialog(
        account: account,
        onAccountUpdated: (updatedAccount) {
          _loadAccounts();
        },
      ),
    );
  }
}
