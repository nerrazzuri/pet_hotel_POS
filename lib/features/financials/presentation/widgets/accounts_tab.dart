import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/financials/domain/entities/financial_account.dart';
import 'package:cat_hotel_pos/core/services/financial_dao.dart';

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
        // Search and filters
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search accounts...',
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
                    child: DropdownButtonFormField<AccountType>(
                      decoration: const InputDecoration(
                        labelText: 'Account Type',
                        border: OutlineInputBorder(),
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
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<AccountStatus>(
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
                        ...AccountStatus.values.map((status) => DropdownMenuItem(
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

        // Accounts list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _filteredAccounts.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.account_balance_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No accounts found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredAccounts.length,
                      itemBuilder: (context, index) {
                        final account = _filteredAccounts[index];
                        return _buildAccountCard(account);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildAccountCard(FinancialAccount account) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getAccountTypeColor(account.accountType),
          child: Icon(
            _getAccountTypeIcon(account.accountType),
            color: Colors.white,
          ),
        ),
        title: Text(
          account.accountName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Account: ${account.accountNumber}'),
            if (account.bankName != null) Text('Bank: ${account.bankName}'),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(account.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    account.status.displayName,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    account.accountType.shortName,
                    style: TextStyle(color: Colors.amber[800], fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${account.currency} ${account.balance.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: account.balance >= 0 ? Colors.green[700] : Colors.red[700],
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) => _handleAccountAction(value, account),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('View Details'),
                    ],
                  ),
                ),
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
                const PopupMenuItem(
                  value: 'transactions',
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long, color: Colors.green),
                      SizedBox(width: 8),
                      Text('View Transactions'),
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

  void _showEditAccountDialog(FinancialAccount account) {
    // TODO: Implement edit account dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit account functionality coming soon!')),
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
}
