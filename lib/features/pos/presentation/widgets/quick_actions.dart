import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/pos/presentation/providers/pos_providers.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';
import 'package:cat_hotel_pos/features/customers/domain/services/customer_service.dart';

class QuickActions extends ConsumerWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.transparent,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // New Transaction
            _QuickActionButton(
              icon: Icons.add_shopping_cart,
              label: 'New Sale',
              color: Colors.teal,
              onTap: () {
                ref.read(currentCartProvider.notifier).createNewCart();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('New cart created'),
                    backgroundColor: Colors.teal,
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            
            const SizedBox(width: 12),
            
            // Fast Check-in
            _QuickActionButton(
              icon: Icons.login,
              label: 'Fast Check-in',
              color: Colors.green[600]!,
              onTap: () {
                _showFastCheckInDialog(context);
              },
            ),
            
            const SizedBox(width: 12),
            
            // Search Customer
            _QuickActionButton(
              icon: Icons.person_search,
              label: 'Find Customer',
              color: Colors.blue[600]!,
              onTap: () {
                _showCustomerSearchDialog(context);
              },
            ),
            
            const SizedBox(width: 12),
            
            // Discount
            _QuickActionButton(
              icon: Icons.discount,
              label: 'Discount',
              color: Colors.orange[600]!,
              onTap: () {
                _showDiscountDialog(context, ref);
              },
            ),
            
            const SizedBox(width: 12),
            
            // Split Bill
            _QuickActionButton(
              icon: Icons.call_split,
              label: 'Split Bill',
              color: Colors.purple[600]!,
              onTap: () {
                _showSplitBillDialog(context, ref);
              },
            ),
            
            const SizedBox(width: 12),
            
            // Receipt Reprint
            _QuickActionButton(
              icon: Icons.receipt_long,
              label: 'Reprint',
              color: Colors.green[600]!,
              onTap: () {
                _showReprintDialog(context);
              },
            ),
            
            const SizedBox(width: 12),
            
            // Refund/Void
            _QuickActionButton(
              icon: Icons.undo,
              label: 'Refund/Void',
              color: Colors.red[600]!,
              onTap: () {
                _showRefundVoidDialog(context);
              },
            ),
            
            const SizedBox(width: 16),
            
            // Clock (no background, sits on grey)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.access_time,
                    size: 18,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, snapshot) {
                      return Text(
                        _getCurrentTime(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  void _showCustomerSearchDialog(BuildContext context) {
    final searchController = TextEditingController();
    final customerService = CustomerService();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Search Customer'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search by name, phone, or email',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<Customer>>(
                    future: customerService.searchCustomers(searchController.text),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      
                      final customers = snapshot.data ?? [];
                      final filteredCustomers = customers.where((customer) {
                        if (searchController.text.isEmpty) return false;
                        return customer.fullName.toLowerCase().contains(searchController.text.toLowerCase()) ||
                               customer.phoneNumber?.toLowerCase().contains(searchController.text.toLowerCase()) == true ||
                               customer.email.toLowerCase().contains(searchController.text.toLowerCase());
                      }).take(10).toList();
                      
                      if (filteredCustomers.isEmpty) {
                        return const Text('No customers found');
                      }
                      
                      return Container(
                        height: 300,
                        child: ListView.builder(
                          itemCount: filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final customer = filteredCustomers[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(customer.fullName[0]),
                                backgroundColor: Colors.teal,
                                foregroundColor: Colors.white,
                              ),
                              title: Text(customer.fullName),
                              subtitle: Text('${customer.phoneNumber ?? 'No phone'} • ${customer.email}'),
                              onTap: () {
                                // TODO: Link customer to current cart
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Customer ${customer.fullName} selected'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Show quick add customer dialog
                  Navigator.pop(context);
                },
                child: const Text('Add New Customer'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDiscountDialog(BuildContext context, WidgetRef ref) {
    final discountController = TextEditingController();
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Apply Discount'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: discountController,
              decoration: const InputDecoration(
                labelText: 'Discount Amount (\$)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final discountAmount = double.tryParse(discountController.text);
              if (discountAmount != null && discountAmount > 0) {
                ref.read(currentCartProvider.notifier).applyDiscount(
                  discountAmount,
                  reasonController.text.isEmpty ? 'Discount applied' : reasonController.text,
                );
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Discount of \$${discountAmount.toStringAsFixed(2)} applied'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showSplitBillDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Split Bill'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Bill splitting functionality will be implemented here.'),
            SizedBox(height: 16),
            Text('This will allow staff to split bills between multiple customers or payment methods.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRefundVoidDialog(BuildContext context) {
    final transactionIdController = TextEditingController();
    final reasonController = TextEditingController();
    String selectedAction = 'refund';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  selectedAction == 'refund' ? Icons.money_off : Icons.cancel,
                  color: selectedAction == 'refund' ? Colors.orange : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(selectedAction == 'refund' ? 'Process Refund' : 'Void Transaction'),
              ],
            ),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Action Type Selection
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'refund', label: Text('Refund')),
                      ButtonSegment(value: 'void', label: Text('Void')),
                    ],
                    selected: {selectedAction},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        selectedAction = newSelection.first;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Transaction ID
                  TextField(
                    controller: transactionIdController,
                    decoration: const InputDecoration(
                      labelText: 'Transaction ID/Receipt Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.receipt),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Reason
                  TextField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Reason',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                    maxLines: 2,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Warning
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selectedAction == 'refund' ? Colors.orange.shade50 : Colors.red.shade50,
                      border: Border.all(
                        color: selectedAction == 'refund' ? Colors.orange.shade300 : Colors.red.shade300,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          selectedAction == 'refund' ? Icons.warning : Icons.dangerous,
                          color: selectedAction == 'refund' ? Colors.orange : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            selectedAction == 'refund' 
                              ? 'This will process a refund to the customer. Make sure to verify the transaction details.'
                              : 'This will void the transaction. This action cannot be undone.',
                            style: TextStyle(
                              color: selectedAction == 'refund' ? Colors.orange.shade800 : Colors.red.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (transactionIdController.text.isNotEmpty && reasonController.text.isNotEmpty) {
                    // TODO: Process refund/void with audit trail
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${selectedAction == 'refund' ? 'Refund' : 'Void'} processed successfully'),
                        backgroundColor: selectedAction == 'refund' ? Colors.orange : Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedAction == 'refund' ? Colors.orange : Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: Text(selectedAction == 'refund' ? 'Process Refund' : 'Void Transaction'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFastCheckInDialog(BuildContext context) {
    final customerNameController = TextEditingController();
    final customerPhoneController = TextEditingController();
    final petNameController = TextEditingController();
    String selectedService = 'boarding_single';
    int serviceQuantity = 1;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Fast Check-in'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Customer Information
                  TextField(
                    controller: customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: customerPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: petNameController,
                    decoration: const InputDecoration(
                      labelText: 'Pet Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Service Selection
                  DropdownButtonFormField<String>(
                    value: selectedService,
                    decoration: const InputDecoration(
                      labelText: 'Service',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'boarding_single', child: Text('Single Room Boarding')),
                      DropdownMenuItem(value: 'boarding_deluxe', child: Text('Deluxe Room Boarding')),
                      DropdownMenuItem(value: 'daycare_half', child: Text('Half Day Daycare')),
                      DropdownMenuItem(value: 'daycare_full', child: Text('Full Day Daycare')),
                      DropdownMenuItem(value: 'grooming_basic', child: Text('Basic Grooming')),
                      DropdownMenuItem(value: 'grooming_premium', child: Text('Premium Grooming')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedService = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Quantity/Duration
                  Row(
                    children: [
                      const Text('Quantity/Duration: '),
                      IconButton(
                        onPressed: () {
                          if (serviceQuantity > 1) {
                            setState(() {
                              serviceQuantity--;
                            });
                          }
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text('$serviceQuantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            serviceQuantity++;
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Add to cart and create customer
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fast check-in completed!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                child: const Text('Check-in'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showReprintDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reprint Receipt'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Receipt reprint functionality will be implemented here.'),
            SizedBox(height: 16),
            Text('This will allow staff to reprint receipts for completed transactions.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
