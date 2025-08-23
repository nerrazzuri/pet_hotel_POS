import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/payments/domain/services/payment_service.dart';
import 'package:cat_hotel_pos/features/payments/presentation/widgets/payment_methods_tab.dart';
import 'package:cat_hotel_pos/features/payments/presentation/widgets/payment_transactions_tab.dart';
import 'package:cat_hotel_pos/features/payments/presentation/widgets/payment_analytics_tab.dart';
import 'package:cat_hotel_pos/features/payments/presentation/widgets/payment_settings_tab.dart';

class PaymentsScreen extends ConsumerStatefulWidget {
  const PaymentsScreen({super.key});

  @override
  ConsumerState<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends ConsumerState<PaymentsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final PaymentService _paymentService = PaymentService();

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
        title: const Text('Payments & Invoicing'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Payment Methods', icon: Icon(Icons.payment)),
            Tab(text: 'Transactions', icon: Icon(Icons.receipt_long)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
            Tab(text: 'Settings', icon: Icon(Icons.settings)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          PaymentMethodsTab(),
          PaymentTransactionsTab(),
          PaymentAnalyticsTab(),
          PaymentSettingsTab(),
        ],
      ),
    );
  }
}
