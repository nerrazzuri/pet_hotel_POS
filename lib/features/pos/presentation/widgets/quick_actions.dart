import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/pos/presentation/providers/pos_providers.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';
import 'package:cat_hotel_pos/features/customers/domain/services/customer_service.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/cart_item.dart';

class QuickActions extends ConsumerWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact Header
          Row(
            children: [
              Icon(
                Icons.flash_on,
                color: colorScheme.primary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'Quick Actions',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const Spacer(),
              Text(
                'Frequently used operations',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Evenly Spaced Action Buttons
          Row(
            children: [
              // New Transaction
              Expanded(
                child: _CompactQuickActionButton(
                  icon: Icons.add_shopping_cart,
                  label: 'New Sale',
                  color: colorScheme.primary,
                  onTap: () {
                    ref.read(currentCartProvider.notifier).createNewCart();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            const Text('New cart created'),
                          ],
                        ),
                        backgroundColor: colorScheme.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Fast Check-in
              Expanded(
                child: _CompactQuickActionButton(
                  icon: Icons.login,
                  label: 'Check-in',
                  color: Colors.green[600]!,
                  onTap: () {
                    _showFastCheckInDialog(context, ref);
                  },
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Search Customer
              Expanded(
                child: _CompactQuickActionButton(
                  icon: Icons.person_search,
                  label: 'Find Customer',
                  color: Colors.blue[600]!,
                  onTap: () {
                    _showCustomerSearchDialog(context, ref);
                  },
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Discount
              Expanded(
                child: _CompactQuickActionButton(
                  icon: Icons.discount,
                  label: 'Discount',
                  color: Colors.orange[600]!,
                  onTap: () {
                    _showDiscountDialog(context, ref);
                  },
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Split Bill
              Expanded(
                child: _CompactQuickActionButton(
                  icon: Icons.call_split,
                  label: 'Split Bill',
                  color: Colors.purple[600]!,
                  onTap: () {
                    _showSplitBillDialog(context, ref);
                  },
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Receipt Reprint
              Expanded(
                child: _CompactQuickActionButton(
                  icon: Icons.receipt_long,
                  label: 'Reprint',
                  color: Colors.green[600]!,
                  onTap: () {
                    _showReprintDialog(context);
                  },
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Hold Cart
              Expanded(
                child: _CompactQuickActionButton(
                  icon: Icons.pause_circle_outline,
                  label: 'Hold Cart',
                  color: Colors.amber[600]!,
                  onTap: () {
                    _showHoldCartDialog(context, ref);
                  },
                ),
              ),
              
              const SizedBox(width: 8),
              
              // View History
              Expanded(
                child: _CompactQuickActionButton(
                  icon: Icons.history,
                  label: 'History',
                  color: Colors.indigo[600]!,
                  onTap: () {
                    _showHistoryDialog(context);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
  }

  void _showCustomerSearchDialog(BuildContext context, WidgetRef ref) {
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
                                // Link customer to current cart
                                Navigator.pop(context);
                                
                                // Get the current cart from the provider
                                final currentCart = ref.read(currentCartProvider);
                                if (currentCart != null) {
                                  ref.read(currentCartProvider.notifier).setCustomerInfo(
                                    customer.id,
                                    customer.fullName,
                                    customer.phoneNumber,
                                  );
                                  
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Customer ${customer.fullName} linked to current cart'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('No active cart found. Please create a new transaction first.'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
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
                  _showAddCustomerDialog(context);
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
    final splitAmountController = TextEditingController();
    final customerNameController = TextEditingController();
    String selectedSplitMethod = 'equal';
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final currentCart = ref.read(currentCartProvider);
          final totalAmount = currentCart?.totalAmount ?? 0.0;
          
          return AlertDialog(
            title: const Text('Split Bill'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total Amount: \$${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Split Method Selection
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'equal', label: Text('Equal Split')),
                      ButtonSegment(value: 'custom', label: Text('Custom Amount')),
                    ],
                    selected: {selectedSplitMethod},
                    onSelectionChanged: (Set<String> newSelection) {
                      setState(() {
                        selectedSplitMethod = newSelection.first;
                      });
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (selectedSplitMethod == 'custom') ...[
                    TextField(
                      controller: splitAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Split Amount (\$)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  TextField(
                    controller: customerNameController,
                    decoration: const InputDecoration(
                      labelText: 'Customer Name for Split',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (selectedSplitMethod == 'equal') ...[
                    Text(
                      'Split Amount: \$${(totalAmount / 2).toStringAsFixed(2)} each',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ] else if (splitAmountController.text.isNotEmpty) ...[
                    Builder(
                      builder: (context) {
                        final splitAmount = double.tryParse(splitAmountController.text) ?? 0.0;
                        final remainingAmount = totalAmount - splitAmount;
                        if (remainingAmount >= 0) {
                          return Text(
                            'Remaining Amount: \$${remainingAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue,
                            ),
                          );
                        } else {
                          return Text(
                            'Invalid split amount!',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.red,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (customerNameController.text.isNotEmpty) {
                    _processBillSplit(context, ref, selectedSplitMethod, splitAmountController.text);
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please enter customer name'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                child: const Text('Split Bill'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _processBillSplit(BuildContext context, WidgetRef ref, String splitMethod, String splitAmountText) {
    final currentCart = ref.read(currentCartProvider);
    final totalAmount = currentCart?.totalAmount ?? 0.0;
    
    if (splitMethod == 'equal') {
      final splitAmount = totalAmount / 2;
      final remainingAmount = totalAmount - splitAmount;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bill split equally. Amount: \$${splitAmount.toStringAsFixed(2)}. Remaining: \$${remainingAmount.toStringAsFixed(2)}'),
          backgroundColor: Colors.green,
        ),
      );
    } else if (splitMethod == 'custom') {
      final splitAmount = double.tryParse(splitAmountText) ?? 0.0;
      final remainingAmount = totalAmount - splitAmount;

      if (remainingAmount >= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bill split. Amount: \$${splitAmount.toStringAsFixed(2)}. Remaining: \$${remainingAmount.toStringAsFixed(2)}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid split amount. Total: \$${totalAmount.toStringAsFixed(2)}. Split: \$${splitAmount.toStringAsFixed(2)}. Remaining: \$${remainingAmount.toStringAsFixed(2)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
                    // Process refund/void with audit trail
                    _processRefundVoid(
                      context,
                      transactionIdController.text,
                      selectedAction,
                      reasonController.text,
                    );
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all required fields'),
                        backgroundColor: Colors.orange,
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

  void _processRefundVoid(BuildContext context, String transactionId, String action, String reason) {
    // In a real implementation, this would:
    // 1. Validate the transaction exists
    // 2. Check if it's eligible for refund/void
    // 3. Process the refund/void
    // 4. Create audit trail
    // 5. Update inventory if needed
    // 6. Send notifications
    
    // For now, simulate the process
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${action == 'refund' ? 'Refund' : 'Void'} processed successfully for transaction $transactionId'),
        backgroundColor: action == 'refund' ? Colors.orange : Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
    
    // Log the action for audit purposes
    print('${action.toUpperCase()} processed: Transaction $transactionId, Reason: $reason, Time: ${DateTime.now()}');
  }

  void _showFastCheckInDialog(BuildContext context, WidgetRef ref) {
    final customerNameController = TextEditingController();
    final customerPhoneController = TextEditingController();
    final customerEmailController = TextEditingController();
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
                    controller: customerEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Email (optional)',
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
                  if (customerNameController.text.isNotEmpty && 
                      customerPhoneController.text.isNotEmpty && 
                      petNameController.text.isNotEmpty) {
                    
                    // Create customer first
                    final customer = Customer(
                      id: 'temp_${DateTime.now().millisecondsSinceEpoch}', // Temporary ID
                      customerCode: 'CUST${DateTime.now().millisecondsSinceEpoch}',
                      firstName: customerNameController.text.split(' ').first,
                      lastName: customerNameController.text.split(' ').length > 1 
                          ? customerNameController.text.split(' ').skip(1).join(' ') 
                          : '',
                      email: customerEmailController.text.isEmpty ? '' : customerEmailController.text,
                      phoneNumber: customerPhoneController.text,
                      status: CustomerStatus.active,
                      source: CustomerSource.walkIn,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );

                    final customerService = CustomerService();
                    customerService.createCustomer(
                      firstName: customer.firstName,
                      lastName: customer.lastName,
                      phoneNumber: customer.phoneNumber,
                      email: customer.email.isEmpty ? null : customer.email,
                    ).then((_) {
                      // Create cart item for the selected service
                      final cartItem = CartItem(
                        id: '${selectedService}_${DateTime.now().millisecondsSinceEpoch}',
                        name: _getServiceDisplayName(selectedService),
                        type: 'service',
                        price: _getServicePrice(selectedService),
                        quantity: serviceQuantity,
                        category: _getServiceCategory(selectedService),
                        notes: 'Pet: ${petNameController.text}',
                      );
                      
                      // Add to current cart
                      final currentCart = ref.read(currentCartProvider);
                      if (currentCart != null) {
                        ref.read(currentCartProvider.notifier).addItemToCart(cartItem);
                        ref.read(currentCartProvider.notifier).setCustomerInfo(
                          customer.id,
                          customer.fullName,
                          customer.phoneNumber,
                        );
                      } else {
                        // Create new cart if none exists
                        ref.read(currentCartProvider.notifier).createNewCart().then((_) {
                          ref.read(currentCartProvider.notifier).addItemToCart(cartItem);
                          ref.read(currentCartProvider.notifier).setCustomerInfo(
                            customer.id,
                            customer.fullName,
                            customer.phoneNumber,
                          );
                        });
                      }
                      
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Fast check-in completed! ${petNameController.text} added to cart.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error creating customer: $error'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please fill in all required fields'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
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
    final transactionIdController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reprint Receipt'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: transactionIdController,
                decoration: const InputDecoration(
                  labelText: 'Transaction ID or Receipt Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.receipt),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Enter the transaction ID or receipt number to reprint the receipt.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (transactionIdController.text.isNotEmpty) {
                _reprintReceipt(context, transactionIdController.text);
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a transaction ID'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Reprint'),
          ),
        ],
      ),
    );
  }

  void _reprintReceipt(BuildContext context, String transactionId) {
    // In a real implementation, this would:
    // 1. Look up the transaction by ID
    // 2. Generate the receipt
    // 3. Send to printer
    // 4. Log the reprint action
    
    // For now, simulate reprinting
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Receipt reprinted for transaction $transactionId'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Log the reprint action
    print('Receipt reprinted for transaction $transactionId at: ${DateTime.now()}');
  }

  void _showAddCustomerDialog(BuildContext context) {
    final customerNameController = TextEditingController();
    final customerPhoneController = TextEditingController();
    final customerEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Customer'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                controller: customerEmailController,
                decoration: const InputDecoration(
                  labelText: 'Email (optional)',
                  border: OutlineInputBorder(),
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
              if (customerNameController.text.isNotEmpty && customerPhoneController.text.isNotEmpty) {
                final customerService = CustomerService();
                customerService.createCustomer(
                  firstName: customerNameController.text.split(' ').first,
                  lastName: customerNameController.text.split(' ').length > 1 
                      ? customerNameController.text.split(' ').skip(1).join(' ') 
                      : '',
                  phoneNumber: customerPhoneController.text,
                  email: customerEmailController.text.isEmpty ? null : customerEmailController.text,
                ).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Customer added successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context);
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error adding customer: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill in name and phone number'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Add Customer'),
          ),
        ],
      ),
    );
  }

  String _getServiceDisplayName(String serviceCode) {
    switch (serviceCode) {
      case 'boarding_single':
        return 'Single Room Boarding';
      case 'boarding_deluxe':
        return 'Deluxe Room Boarding';
      case 'daycare_half':
        return 'Half Day Daycare';
      case 'daycare_full':
        return 'Full Day Daycare';
      case 'grooming_basic':
        return 'Basic Grooming';
      case 'grooming_premium':
        return 'Premium Grooming';
      default:
        return serviceCode;
    }
  }

  double _getServicePrice(String serviceCode) {
    switch (serviceCode) {
      case 'boarding_single':
        return 50.0; // Example price
      case 'boarding_deluxe':
        return 100.0; // Example price
      case 'daycare_half':
        return 20.0; // Example price
      case 'daycare_full':
        return 40.0; // Example price
      case 'grooming_basic':
        return 30.0; // Example price
      case 'grooming_premium':
        return 60.0; // Example price
      default:
        return 0.0;
    }
  }

  String _getServiceCategory(String serviceCode) {
    switch (serviceCode) {
      case 'boarding_single':
      case 'boarding_deluxe':
        return 'Boarding';
      case 'daycare_half':
      case 'daycare_full':
        return 'Daycare';
      case 'grooming_basic':
      case 'grooming_premium':
        return 'Grooming';
      default:
        return 'Other';
    }
  }

  void _showHoldCartDialog(BuildContext context, WidgetRef ref) {
    // TODO: Implement hold cart dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hold Cart feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _showHistoryDialog(BuildContext context) {
    // TODO: Implement history dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('History feature coming soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        margin: EdgeInsets.all(16),
      ),
    );
  }
}

class _CompactQuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _CompactQuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      height: 48,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 16,
                  ),
                ),
                
                const SizedBox(width: 6),
                
                // Label - Now fully visible
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                      fontSize: 11,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
