import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/financials/presentation/widgets/accounts_tab.dart';
import 'package:cat_hotel_pos/features/financials/presentation/widgets/transactions_tab.dart';
import 'package:cat_hotel_pos/features/financials/presentation/widgets/budgets_tab.dart';
import 'package:cat_hotel_pos/features/financials/presentation/widgets/analytics_tab.dart';

class FinancialOperationsScreen extends ConsumerStatefulWidget {
  const FinancialOperationsScreen({super.key});

  @override
  ConsumerState<FinancialOperationsScreen> createState() => _FinancialOperationsScreenState();
}

class _FinancialOperationsScreenState extends ConsumerState<FinancialOperationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
        title: const Text('Financial Operations'),
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.account_balance),
              text: 'Accounts',
            ),
            Tab(
              icon: Icon(Icons.receipt_long),
              text: 'Transactions',
            ),
            Tab(
              icon: Icon(Icons.account_balance_wallet),
              text: 'Budgets',
            ),
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Analytics',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AccountsTab(),
          TransactionsTab(),
          BudgetsTab(),
          AnalyticsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show context menu for different actions
          _showActionMenu(context);
        },
        backgroundColor: Colors.amber[800],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showActionMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.account_balance, color: Colors.amber),
              title: const Text('Add New Account'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(0); // Switch to Accounts tab
                // TODO: Show add account dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.amber),
              title: const Text('Record Transaction'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(1); // Switch to Transactions tab
                // TODO: Show add transaction dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet, color: Colors.amber),
              title: const Text('Create Budget'),
              onTap: () {
                Navigator.pop(context);
                _tabController.animateTo(2); // Switch to Budgets tab
                // TODO: Show create budget dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_download, color: Colors.amber),
              title: const Text('Export Financial Report'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Export financial report
              },
            ),
          ],
        ),
      ),
    );
  }
}
