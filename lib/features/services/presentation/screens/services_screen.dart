import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/services/presentation/widgets/services_management_tab.dart';
import 'package:cat_hotel_pos/features/services/presentation/widgets/products_management_tab.dart';
import 'package:cat_hotel_pos/features/services/presentation/widgets/packages_management_tab.dart';
import 'package:cat_hotel_pos/features/services/presentation/widgets/retail_services_tab.dart';
import 'package:cat_hotel_pos/features/services/presentation/widgets/services_analytics_tab.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen>
    with TickerProviderStateMixin {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services & Products Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
          tabs: const [
            Tab(
              icon: Icon(Icons.miscellaneous_services),
              text: 'Services',
            ),
            Tab(
              icon: Icon(Icons.inventory),
              text: 'Products',
            ),
            Tab(
              icon: Icon(Icons.card_giftcard),
              text: 'Packages',
            ),
            Tab(
              icon: Icon(Icons.store),
              text: 'Retail',
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
          ServicesManagementTab(),
          ProductsManagementTab(),
          PackagesManagementTab(),
          RetailServicesTab(),
          ServicesAnalyticsTab(),
        ],
      ),
    );
  }
}
