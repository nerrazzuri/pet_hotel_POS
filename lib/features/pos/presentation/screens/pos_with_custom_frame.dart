import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:cat_hotel_pos/core/widgets/custom_window_frame.dart';

/// POS Screen with Custom Window Frame Integration
/// This shows how to add a custom title bar to your existing POS screen
class POSWithCustomFrame extends StatefulWidget {
  const POSWithCustomFrame({super.key});

  @override
  State<POSWithCustomFrame> createState() => _POSWithCustomFrameState();
}

class _POSWithCustomFrameState extends State<POSWithCustomFrame> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Custom Title Bar for POS
          CustomTitleBar(
            title: 'Cat Hotel POS - Point of Sale',
            backgroundColor: Colors.blue[700],
            onMinimize: () async => await windowManager.minimize(),
            onMaximize: () async => await windowManager.maximize(),
            onClose: () async => await windowManager.close(),
          ),
          
          // Main POS Content
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: Column(
                children: [
                  // POS Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.point_of_sale,
                          size: 32,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Point of Sale',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Process transactions and manage sales',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Quick Actions
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                // New transaction
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('New Transaction'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[700],
                                foregroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () {
                                // View history
                              },
                              icon: const Icon(Icons.history),
                              label: const Text('History'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // POS Content Area
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          // Left Panel - Product Selection
                          Expanded(
                            flex: 2,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50],
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.search,
                                          color: Colors.blue[700],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextField(
                                            decoration: InputDecoration(
                                              hintText: 'Search products or services...',
                                              border: InputBorder.none,
                                              hintStyle: TextStyle(
                                                color: Colors.blue[400],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(16),
                                      itemCount: 10,
                                      itemBuilder: (context, index) {
                                        return Card(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              backgroundColor: Colors.blue[100],
                                              child: Icon(
                                                Icons.pets,
                                                color: Colors.blue[700],
                                              ),
                                            ),
                                            title: Text('Service ${index + 1}'),
                                            subtitle: Text('\$${(index + 1) * 10}.00'),
                                            trailing: ElevatedButton(
                                              onPressed: () {
                                                // Add to cart
                                              },
                                              child: const Text('Add'),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 20),
                          
                          // Right Panel - Cart
                          Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(12),
                                        topRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.shopping_cart,
                                          color: Colors.green[700],
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Shopping Cart',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Cart Items
                                  Expanded(
                                    child: ListView.builder(
                                      padding: const EdgeInsets.all(16),
                                      itemCount: 3,
                                      itemBuilder: (context, index) {
                                        return Card(
                                          margin: const EdgeInsets.only(bottom: 8),
                                          child: ListTile(
                                            title: Text('Item ${index + 1}'),
                                            subtitle: Text('\$${(index + 1) * 15}.00'),
                                            trailing: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IconButton(
                                                  onPressed: () {},
                                                  icon: const Icon(Icons.remove),
                                                ),
                                                Text('1'),
                                                IconButton(
                                                  onPressed: () {},
                                                  icon: const Icon(Icons.add),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  
                                  // Total and Checkout
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(12),
                                        bottomRight: Radius.circular(12),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: const [
                                            Text(
                                              'Total:',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              '\$45.00',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              // Process payment
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.green[700],
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.all(16),
                                            ),
                                            child: const Text(
                                              'Process Payment',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
