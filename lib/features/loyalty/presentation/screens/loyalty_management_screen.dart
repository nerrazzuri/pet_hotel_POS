import 'package:flutter/material.dart';
import '../../../../core/services/loyalty_dao.dart';
import '../../domain/entities/loyalty_program.dart';
import '../../domain/entities/loyalty_transaction.dart';
import '../widgets/loyalty_programs_tab.dart';
import '../widgets/loyalty_tiers_tab.dart';
import '../widgets/loyalty_transactions_tab.dart';
import '../widgets/loyalty_analytics_tab.dart';

class LoyaltyManagementScreen extends StatefulWidget {
  const LoyaltyManagementScreen({super.key});

  @override
  State<LoyaltyManagementScreen> createState() => _LoyaltyManagementScreenState();
}

class _LoyaltyManagementScreenState extends State<LoyaltyManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final LoyaltyDao _loyaltyDao = LoyaltyDao();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _loyaltyDao.init();
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
        title: const Text('Loyalty Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Programs', icon: Icon(Icons.card_giftcard)),
            Tab(text: 'Tiers', icon: Icon(Icons.star)),
            Tab(text: 'Transactions', icon: Icon(Icons.receipt_long)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          LoyaltyProgramsTab(loyaltyDao: _loyaltyDao),
          LoyaltyTiersTab(loyaltyDao: _loyaltyDao),
          LoyaltyTransactionsTab(loyaltyDao: _loyaltyDao),
          LoyaltyAnalyticsTab(loyaltyDao: _loyaltyDao),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickActions(context),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.card_giftcard),
              title: const Text('Create New Program'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement create new program dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Add New Tier'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement add new tier dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.point_of_sale),
              title: const Text('Award Points'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement award points dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Program Settings'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement program settings dialog
              },
            ),
          ],
        ),
      ),
    );
  }
}
