import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/product_management_tab.dart';
import '../widgets/supplier_management_tab.dart';
import '../widgets/purchase_orders_tab.dart';
import '../widgets/stock_control_tab.dart';
import '../widgets/inventory_reports_tab.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory & Purchasing'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () => Navigator.of(context).pushReplacementNamed('/dashboard'),
            tooltip: 'Back to Dashboard',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: true,
          tabs: const [
            Tab(
              icon: Icon(Icons.inventory),
              text: 'Products',
            ),
            Tab(
              icon: Icon(Icons.business),
              text: 'Suppliers',
            ),
            Tab(
              icon: Icon(Icons.shopping_cart),
              text: 'Purchase Orders',
            ),
            Tab(
              icon: Icon(Icons.analytics),
              text: 'Stock Control',
            ),
            Tab(
              icon: Icon(Icons.assessment),
              text: 'Reports',
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: TabBarView(
          controller: _tabController,
          children: const [
            ProductManagementTab(),
            SupplierManagementTab(),
            PurchaseOrdersTab(),
            StockControlTab(),
            InventoryReportsTab(),
          ],
        ),
      ),
    );
  }
}
