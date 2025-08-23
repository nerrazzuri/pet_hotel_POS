import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cat_hotel_pos/features/pos/presentation/providers/pos_providers.dart';
import 'package:cat_hotel_pos/features/pos/presentation/widgets/product_grid.dart';
import 'package:cat_hotel_pos/features/pos/presentation/widgets/cart_section.dart';
import 'package:cat_hotel_pos/features/pos/presentation/widgets/payment_section.dart';
import 'package:cat_hotel_pos/features/pos/presentation/widgets/quick_actions.dart';
import 'package:cat_hotel_pos/features/pos/presentation/widgets/held_carts_drawer.dart';

class POSScreen extends ConsumerStatefulWidget {
  const POSScreen({super.key});

  @override
  ConsumerState<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends ConsumerState<POSScreen> {
  // TODO: Uncomment when implementing scaffold key functionality
  // final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Create a new cart when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(currentCartProvider.notifier).createNewCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Register'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () => Navigator.of(context).pushReplacementNamed('/dashboard'),
            tooltip: 'Back to Dashboard',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withOpacity(0.1),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          children: [
            // Quick Actions Bar spanning full width
            Container(
              width: double.infinity,
              color: Colors.grey[50],
              child: const QuickActions(),
            ),
            
            // Main content area
            Expanded(
              child: Row(
                children: [
                  // Left Side - Product Grid
                  const Expanded(
                    flex: 2,
                    child: ProductGrid(),
                  ),
                  
                  // Right Side - Cart and Payment
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(-2, 0),
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          // Cart Section
                          Expanded(
                            flex: 2,
                            child: CartSection(),
                          ),
                          
                          // Payment Section
                          Expanded(
                            flex: 1,
                            child: PaymentSection(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      endDrawer: const HeldCartsDrawer(),
    );
  }
}
