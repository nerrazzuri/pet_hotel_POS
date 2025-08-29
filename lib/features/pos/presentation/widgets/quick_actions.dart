import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/pos/presentation/providers/pos_providers.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';
import 'package:cat_hotel_pos/features/customers/domain/services/customer_service.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/cart_item.dart';
import 'package:cat_hotel_pos/features/pos/presentation/screens/checkin_screen.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:cat_hotel_pos/core/services/room_dao.dart';

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
              
                             // Check Room Availability
               Expanded(
                 child: _CompactQuickActionButton(
                   icon: Icons.bedroom_parent,
                   label: 'Check Room Availability',
                   color: Colors.blue[600]!,
                   onTap: () {
                     _showRoomAvailabilityDialog(context);
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
              
              // View Held Carts
              Expanded(
                child: _CompactQuickActionButton(
                  icon: Icons.pause_circle_outline,
                  label: 'View Held Carts',
                  color: Colors.amber[600]!,
                  onTap: () {
                    Scaffold.of(context).openEndDrawer();
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
    String selectedDiscountType = 'percentage';
    double discountValue = 0.0;
    String discountReason = '';
    
    // Get current cart for preview calculations
    final currentCart = ref.read(currentCartProvider);
    final cartTotal = currentCart?.totalAmount ?? 0.0;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Calculate discount preview
            double discountAmount = 0.0;
            double finalTotal = cartTotal;
            
            if (discountValue > 0) {
              if (selectedDiscountType == 'percentage') {
                discountAmount = (cartTotal * discountValue) / 100;
                finalTotal = cartTotal - discountAmount;
              } else {
                discountAmount = discountValue;
                finalTotal = cartTotal - discountAmount;
              }
            }
            
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: 550,
                constraints: const BoxConstraints(maxHeight: 700),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.blue[50]!,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.orange[600]!,
                            Colors.orange[400]!,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.discount,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Apply Discount',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Customize discount for current cart',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Cart Total Display
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Cart Total',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '\$${cartTotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Discount Type Selection
                            Text(
                              'Discount Type',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _buildDiscountTypeOption(
                                      context,
                                      'percentage',
                                      'Percentage',
                                      Icons.percent,
                                      Colors.blue[600]!,
                                      selectedDiscountType == 'percentage',
                                      () => setState(() => selectedDiscountType = 'percentage'),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildDiscountTypeOption(
                                      context,
                                      'fixed',
                                      'Fixed Amount',
                                      Icons.attach_money,
                                      Colors.green[600]!,
                                      selectedDiscountType == 'fixed',
                                      () => setState(() => selectedDiscountType = 'fixed'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Discount Value Input
                            Text(
                              selectedDiscountType == 'percentage' ? 'Discount Percentage (%)' : 'Discount Amount (\$)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: discountController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  hintText: selectedDiscountType == 'percentage' ? 'Enter percentage (e.g., 15)' : 'Enter amount (e.g., 25.50)',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16),
                                  prefixIcon: Icon(
                                    selectedDiscountType == 'percentage' ? Icons.percent : Icons.attach_money,
                                    color: Colors.grey[600],
                                  ),
                                  suffixIcon: Container(
                                    margin: const EdgeInsets.all(8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.blue[50]!,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      selectedDiscountType == 'percentage' ? '%' : '\$',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    discountValue = double.tryParse(value) ?? 0.0;
                                  });
                                },
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Discount Reason
                            Text(
                              'Reason (Optional)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: reasonController,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  hintText: 'Enter reason for discount (e.g., Loyalty customer, Special promotion)',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16),
                                  prefixIcon: Icon(
                                    Icons.note,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    discountReason = value;
                                  });
                                },
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Preview Section
                            if (discountValue > 0)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.orange[50]!,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.orange[200]!),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.orange[600],
                                          size: 24,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          'Discount Preview',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.orange[800],
                                            fontSize: 18,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildPreviewCard(
                                            'Original Total',
                                            '\$${cartTotal.toStringAsFixed(2)}',
                                            Colors.grey[600]!,
                                            Icons.shopping_cart,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildPreviewCard(
                                            'Discount',
                                            selectedDiscountType == 'percentage'
                                                ? '${discountValue.toStringAsFixed(1)}% (-\$${discountAmount.toStringAsFixed(2)})'
                                                : '-\$${discountAmount.toStringAsFixed(2)}',
                                            Colors.orange[600]!,
                                            Icons.discount,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: _buildPreviewCard(
                                            'Final Total',
                                            '\$${finalTotal.toStringAsFixed(2)}',
                                            Colors.green[600]!,
                                            Icons.check_circle,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (selectedDiscountType == 'percentage') ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.blue[50]!,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.blue[200]!),
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.lightbulb_outline,
                                              color: Colors.blue[600],
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'A ${discountValue.toStringAsFixed(1)}% discount will save \$${discountAmount.toStringAsFixed(2)} on this transaction',
                                                style: TextStyle(
                                                  color: Colors.blue[700],
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Actions
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: discountValue > 0 && cartTotal > 0
                                  ? () {
                                      // Apply discount to cart
                                      if (selectedDiscountType == 'percentage') {
                                        final percentageDiscount = (cartTotal * discountValue) / 100;
                                        ref.read(currentCartProvider.notifier).applyDiscount(
                                          percentageDiscount,
                                          reasonController.text.isEmpty 
                                              ? '${discountValue.toStringAsFixed(1)}% discount applied' 
                                              : reasonController.text,
                                        );
                                      } else {
                                        ref.read(currentCartProvider.notifier).applyDiscount(
                                          discountValue,
                                          reasonController.text.isEmpty 
                                              ? '\$${discountValue.toStringAsFixed(2)} discount applied' 
                                              : reasonController.text,
                                        );
                                      }
                                      
                                      Navigator.of(context).pop();
                                      
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            selectedDiscountType == 'percentage'
                                                ? '${discountValue.toStringAsFixed(1)}% discount applied successfully!'
                                                : '\$${discountValue.toStringAsFixed(2)} discount applied successfully!',
                                          ),
                                          backgroundColor: Colors.green[600],
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          margin: const EdgeInsets.all(16),
                                        ),
                                      );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Apply Discount',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
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
            );
          },
        );
      },
    );
  }
  
  Widget _buildDiscountTypeOption(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPreviewCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showSplitBillDialog(BuildContext context, WidgetRef ref) {
    final splitAmountController = TextEditingController();
    final customerNameController = TextEditingController();
    final customerPhoneController = TextEditingController();
    String selectedSplitMethod = 'equal';
    int numberOfSplits = 2;
    
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
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildSplitMethodOption(
                            context,
                            'equal',
                            'Equal Split',
                            Icons.equalizer,
                            Colors.blue[600]!,
                            selectedSplitMethod == 'equal',
                            () => setState(() {
                              selectedSplitMethod = 'equal';
                            }),
                          ),
                        ),
                        Expanded(
                          child: _buildSplitMethodOption(
                            context,
                            'custom',
                            'Custom Amount',
                            Icons.attach_money,
                            Colors.green[600]!,
                            selectedSplitMethod == 'custom',
                            () => setState(() {
                              selectedSplitMethod = 'custom';
                            }),
                          ),
                        ),
                        Expanded(
                          child: _buildSplitMethodOption(
                            context,
                            'percentage',
                            'Percentage',
                            Icons.percent,
                            Colors.orange[600]!,
                            selectedSplitMethod == 'percentage',
                            () => setState(() {
                              selectedSplitMethod = 'percentage';
                            }),
                          ),
                        ),
                      ],
                    ),
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
                  
                  // Customer Information
                  Row(
                    children: [
                      Text(
                        'Customer Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search,
                              size: 14,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Fuzzy Search Enabled',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: customerNameController,
                                decoration: InputDecoration(
                                  hintText: 'Customer Name',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16),
                                  prefixIcon: const Icon(Icons.person, color: Colors.grey),
                                  suffixIcon: customerNameController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear, size: 18),
                                          onPressed: () {
                                            customerNameController.clear();
                                            setState(() {});
                                          },
                                        )
                                      : null,
                                ),
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                              // Customer Name Suggestions
                              if (customerNameController.text.isNotEmpty)
                                FutureBuilder<List<Customer>>(
                                  future: CustomerService().searchCustomers(customerNameController.text),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                      );
                                    }
                                    
                                    if (snapshot.hasError) {
                                      return const SizedBox.shrink();
                                    }
                                    
                                    final customers = snapshot.data ?? [];
                                    final filteredCustomers = customers.where((customer) {
                                      final query = customerNameController.text.toLowerCase();
                                      return customer.fullName.toLowerCase().contains(query) ||
                                             customer.firstName.toLowerCase().contains(query) ||
                                             customer.lastName.toLowerCase().contains(query);
                                    }).take(5).toList();
                                    
                                    if (filteredCustomers.isEmpty) {
                                      return Container(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          'No customers found matching "${customerNameController.text}"',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      );
                                    }
                                    
                                    return Container(
                                      constraints: const BoxConstraints(maxHeight: 150),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: filteredCustomers.length,
                                        itemBuilder: (context, index) {
                                          final customer = filteredCustomers[index];
                                          return ListTile(
                                            dense: true,
                                            leading: CircleAvatar(
                                              radius: 16,
                                              backgroundColor: Colors.blue[100],
                                              child: Text(
                                                customer.firstName.isNotEmpty ? customer.firstName[0].toUpperCase() : '?',
                                                style: TextStyle(
                                                  color: Colors.blue[800],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              customer.fullName,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                            subtitle: Text(
                                              customer.phoneNumber.isNotEmpty ? customer.phoneNumber : 'No phone',
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                            ),
                                            onTap: () {
                                              customerNameController.text = customer.fullName;
                                              customerPhoneController.text = customer.phoneNumber;
                                              setState(() {});
                                            },
                                          );
                                        },
                                      ),
                                    );
                                  },
                                )
                              else
                                // Show recent customers when no search is active
                                FutureBuilder<List<Customer>>(
                                  future: CustomerService().getAllCustomers(onlyActive: true),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                      );
                                    }
                                    
                                    if (snapshot.hasError || snapshot.data == null) {
                                      return const SizedBox.shrink();
                                    }
                                    
                                    final recentCustomers = snapshot.data!.take(3).toList();
                                    
                                    if (recentCustomers.isEmpty) {
                                      return const SizedBox.shrink();
                                    }
                                    
                                    return Container(
                                      padding: const EdgeInsets.all(8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Recent Customers',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          ...recentCustomers.map((customer) => ListTile(
                                            dense: true,
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            leading: CircleAvatar(
                                              radius: 14,
                                              backgroundColor: Colors.grey[200],
                                              child: Text(
                                                customer.firstName.isNotEmpty ? customer.firstName[0].toUpperCase() : '?',
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            title: Text(
                                              customer.fullName,
                                              style: const TextStyle(fontSize: 12),
                                            ),
                                            subtitle: Text(
                                              customer.phoneNumber.isNotEmpty ? customer.phoneNumber : 'No phone',
                                              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                                            ),
                                            onTap: () {
                                              customerNameController.text = customer.fullName;
                                              customerPhoneController.text = customer.phoneNumber;
                                              setState(() {});
                                            },
                                          )),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: customerPhoneController,
                                decoration: InputDecoration(
                                  hintText: 'Phone Number (Optional)',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.all(16),
                                  prefixIcon: const Icon(Icons.phone, color: Colors.grey),
                                  suffixIcon: customerPhoneController.text.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear, size: 18),
                                          onPressed: () {
                                            customerPhoneController.clear();
                                            setState(() {});
                                          },
                                        )
                                      : null,
                                ),
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                              // Phone Number Suggestions
                              if (customerPhoneController.text.isNotEmpty)
                                FutureBuilder<List<Customer>>(
                                  future: CustomerService().searchCustomers(customerPhoneController.text),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.waiting) {
                                      return const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                      );
                                    }
                                    
                                    if (snapshot.hasError) {
                                      return const SizedBox.shrink();
                                    }
                                    
                                    final customers = snapshot.data ?? [];
                                    final filteredCustomers = customers.where((customer) {
                                      final query = customerPhoneController.text.toLowerCase();
                                      return customer.phoneNumber.toLowerCase().contains(query);
                                    }).take(5).toList();
                                    
                                    if (filteredCustomers.isEmpty) {
                                      return Container(
                                        padding: const EdgeInsets.all(12),
                                        child: Text(
                                          'No customers found matching "${customerPhoneController.text}"',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[500],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      );
                                    }
                                    
                                    return Container(
                                      constraints: const BoxConstraints(maxHeight: 150),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: filteredCustomers.length,
                                        itemBuilder: (context, index) {
                                          final customer = filteredCustomers[index];
                                          return ListTile(
                                            dense: true,
                                            leading: CircleAvatar(
                                              radius: 16,
                                              backgroundColor: Colors.green[100],
                                              child: Icon(
                                                Icons.phone,
                                                size: 16,
                                                color: Colors.green[800],
                                              ),
                                            ),
                                            title: Text(
                                              customer.phoneNumber,
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                            subtitle: Text(
                                              customer.fullName,
                                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                            ),
                                            onTap: () {
                                              customerNameController.text = customer.fullName;
                                              customerPhoneController.text = customer.phoneNumber;
                                              setState(() {});
                                            },
                                          );
                                        },
                                      ),
                                    );
                                  },
                                )
                                else
                                  // Show recent customers when no search is active
                                  FutureBuilder<List<Customer>>(
                                    future: CustomerService().getAllCustomers(onlyActive: true),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                        );
                                      }
                                      
                                      if (snapshot.hasError || snapshot.data == null) {
                                        return const SizedBox.shrink();
                                      }
                                      
                                      final recentCustomers = snapshot.data!.take(3).toList();
                                      
                                      if (recentCustomers.isEmpty) {
                                        return const SizedBox.shrink();
                                      }
                                      
                                      return Container(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Recent Customers',
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ...recentCustomers.map((customer) => ListTile(
                                              dense: true,
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              leading: CircleAvatar(
                                                radius: 14,
                                                backgroundColor: Colors.grey[200],
                                                child: Text(
                                                  customer.firstName.isNotEmpty ? customer.firstName[0].toUpperCase() : '?',
                                                  style: TextStyle(
                                                    color: Colors.grey[700],
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              title: Text(
                                                customer.fullName,
                                                style: const TextStyle(fontSize: 12),
                                              ),
                                              subtitle: Text(
                                                customer.phoneNumber.isNotEmpty ? customer.phoneNumber : 'No phone',
                                                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                                              ),
                                              onTap: () {
                                                customerNameController.text = customer.fullName;
                                                customerPhoneController.text = customer.phoneNumber;
                                                setState(() {});
                                              },
                                            )),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Split Preview
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.purple[50]!,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.purple[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.purple[600],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Split Preview',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.purple[800],
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (selectedSplitMethod == 'equal') ...[
                          Row(
                            children: List.generate(numberOfSplits, (index) {
                              final splitAmount = totalAmount / numberOfSplits;
                              return Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.purple[200]!),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.person,
                                        color: Colors.purple[600],
                                        size: 20,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Split ${index + 1}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.purple[700],
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '\$${splitAmount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple[700],
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        '${(100 / numberOfSplits).toStringAsFixed(1)}%',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        ] else if (selectedSplitMethod == 'custom' && splitAmountController.text.isNotEmpty) ...[
                          Builder(
                            builder: (context) {
                              final customAmount = double.tryParse(splitAmountController.text) ?? 0.0;
                              if (customAmount > 0 && customAmount <= totalAmount) {
                                final remainingAmount = totalAmount - customAmount;
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.purple[200]!),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.person,
                                              color: Colors.purple[600],
                                              size: 20,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Customer',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.purple[700],
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '\$${customAmount.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.purple[700],
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              '${((customAmount / totalAmount) * 100).toStringAsFixed(1)}%',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey[300]!),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.person_outline,
                                              color: Colors.grey[600],
                                              size: 20,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Remaining',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '\$${remainingAmount.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[600],
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              '${((remainingAmount / totalAmount) * 100).toStringAsFixed(1)}%',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ] else if (selectedSplitMethod == 'percentage' && splitAmountController.text.isNotEmpty) ...[
                          Builder(
                            builder: (context) {
                              final splitPercentage = double.tryParse(splitAmountController.text) ?? 0.0;
                              if (splitPercentage > 0 && splitPercentage <= 100) {
                                final splitAmount = (totalAmount * splitPercentage) / 100;
                                final remainingAmount = totalAmount - splitAmount;
                                return Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.purple[200]!),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.person,
                                              color: Colors.purple[600],
                                              size: 20,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Customer',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.purple[700],
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '\$${splitAmount.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.purple[700],
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              '${splitPercentage.toStringAsFixed(1)}%',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.grey[300]!),
                                        ),
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.person_outline,
                                              color: Colors.grey[600],
                                              size: 20,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Remaining',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[600],
                                                fontSize: 14,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '\$${remainingAmount.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[600],
                                                fontSize: 16,
                                              ),
                                            ),
                                            Text(
                                              '${(100 - splitPercentage).toStringAsFixed(1)}%',
                                              style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  if (selectedSplitMethod == 'equal') ...[
                    Row(
                      children: [
                        Text(
                          'Number of Splits: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () {
                                  if (numberOfSplits > 2) {
                                    setState(() {
                                      numberOfSplits--;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.remove_circle_outline),
                                iconSize: 20,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text(
                                  '$numberOfSplits',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  if (numberOfSplits < 10) {
                                    setState(() {
                                      numberOfSplits++;
                                    });
                                  }
                                },
                                icon: const Icon(Icons.add_circle_outline),
                                iconSize: 20,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Split Amount: \$${(totalAmount / numberOfSplits).toStringAsFixed(2)} each',
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
                    // Create split details for enhanced processing
                    List<Map<String, dynamic>> splitDetails = [];
                    if (selectedSplitMethod == 'equal') {
                      final splitAmount = totalAmount / numberOfSplits;
                      for (int i = 0; i < numberOfSplits; i++) {
                        splitDetails.add({
                          'customerName': i == 0 ? customerNameController.text : 'Split ${i + 1}',
                          'customerPhone': i == 0 ? customerPhoneController.text : '',
                          'amount': splitAmount,
                          'percentage': (100 / numberOfSplits),
                        });
                      }
                    } else if (selectedSplitMethod == 'custom') {
                      final customAmount = double.tryParse(splitAmountController.text) ?? 0.0;
                      if (customAmount > 0 && customAmount <= totalAmount) {
                        splitDetails.add({
                          'customerName': customerNameController.text,
                          'customerPhone': customerPhoneController.text,
                          'amount': customAmount,
                          'percentage': (customAmount / totalAmount) * 100,
                        });
                        final remainingAmount = totalAmount - customAmount;
                        if (remainingAmount > 0) {
                          splitDetails.add({
                            'customerName': 'Remaining',
                            'customerPhone': '',
                            'amount': remainingAmount,
                            'percentage': (remainingAmount / totalAmount) * 100,
                          });
                        }
                      }
                    } else if (selectedSplitMethod == 'percentage') {
                      final splitPercentage = double.tryParse(splitAmountController.text) ?? 0.0;
                      if (splitPercentage > 0 && splitPercentage <= 100) {
                        final splitAmount = (totalAmount * splitPercentage) / 100;
                        splitDetails.add({
                          'customerName': customerNameController.text,
                          'customerPhone': customerPhoneController.text,
                          'amount': splitAmount,
                          'percentage': splitPercentage,
                        });
                        final remainingAmount = totalAmount - splitAmount;
                        if (remainingAmount > 0) {
                          splitDetails.add({
                            'customerName': 'Remaining',
                            'customerPhone': '',
                            'amount': remainingAmount,
                            'percentage': (100 - splitPercentage),
                          });
                        }
                      }
                    }
                    
                    if (splitDetails.isNotEmpty) {
                      _processEnhancedBillSplit(context, ref, selectedSplitMethod, splitDetails);
                      Navigator.of(context).pop();
                    } else {
                      _processBillSplit(context, ref, selectedSplitMethod, splitAmountController.text);
                      Navigator.of(context).pop();
                    }
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
  
  Widget _buildSplitMethodOption(
    BuildContext context,
    String value,
    String label,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[400],
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  void _processEnhancedBillSplit(BuildContext context, WidgetRef ref, String splitMethod, List<Map<String, dynamic>> splitDetails) {
    final currentCart = ref.read(currentCartProvider);
    final totalAmount = currentCart?.totalAmount ?? 0.0;
    
    // Create a detailed summary
    String summary = 'Bill split successfully!\n\n';
    for (final detail in splitDetails) {
      if (detail['customerName'] != 'Remaining') {
        summary += '• ${detail['customerName']}: \$${detail['amount'].toStringAsFixed(2)} (${detail['percentage'].toStringAsFixed(1)}%)\n';
      }
    }
    
    if (splitDetails.any((detail) => detail['customerName'] == 'Remaining')) {
      final remainingDetail = splitDetails.firstWhere((detail) => detail['customerName'] == 'Remaining');
      summary += '• Remaining: \$${remainingDetail['amount'].toStringAsFixed(2)} (${remainingDetail['percentage'].toStringAsFixed(1)}%)\n';
    }
    
    summary += '\nTotal: \$${totalAmount.toStringAsFixed(2)}';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(summary),
        backgroundColor: Colors.purple[600],
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
    
    // Log the split action
    print('BILL SPLIT processed: Method: $splitMethod, Details: $splitDetails, Time: ${DateTime.now()}');
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final transactionIdController = TextEditingController();
    final reprintReasonController = TextEditingController();
    String selectedReprintReason = 'Customer Request';
    
    // Sample recent transactions for demo
    final recentTransactions = [
      {'id': 'TXN001', 'amount': 125.50, 'customer': 'John Smith', 'date': '2024-01-15 14:30'},
      {'id': 'TXN002', 'amount': 89.99, 'customer': 'Sarah Johnson', 'date': '2024-01-15 15:45'},
      {'id': 'TXN003', 'amount': 234.75, 'customer': 'Mike Brown', 'date': '2024-01-15 16:20'},
      {'id': 'TXN004', 'amount': 67.25, 'customer': 'Emily Davis', 'date': '2024-01-15 17:10'},
    ];
    
    // Sample reprint history for demo
    final reprintHistory = [
      {'id': 'TXN001', 'originalDate': '2024-01-15 14:30', 'reprintDate': '2024-01-15 16:45', 'reason': 'Customer Request', 'by': 'Staff'},
      {'id': 'TXN002', 'originalDate': '2024-01-15 15:45', 'reprintDate': '2024-01-15 17:20', 'reason': 'Printer Error', 'by': 'Manager'},
    ];
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 700,
          constraints: const BoxConstraints(maxHeight: 800),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      color: colorScheme.onPrimary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Receipt Reprint',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.close,
                        color: colorScheme.onPrimary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content with Tabs
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      // Tab Bar
                      Container(
                        color: colorScheme.surfaceVariant.withOpacity(0.3),
                        child: TabBar(
                          labelColor: colorScheme.primary,
                          unselectedLabelColor: colorScheme.onSurfaceVariant,
                          indicatorColor: colorScheme.primary,
                          tabs: const [
                            Tab(
                              icon: Icon(Icons.print),
                              text: 'Reprint Receipt',
                            ),
                            Tab(
                              icon: Icon(Icons.history),
                              text: 'Reprint History',
                            ),
                          ],
                        ),
                      ),
                      
                      // Tab Content
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Reprint Receipt Tab
                            SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Search Section
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: colorScheme.outline.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.search,
                                              color: colorScheme.primary,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Search Transaction',
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        TextField(
                                          controller: transactionIdController,
                                          decoration: InputDecoration(
                                            labelText: 'Transaction ID or Receipt Number',
                                            hintText: 'e.g., TXN001, RCP001',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            prefixIcon: Icon(
                                              Icons.receipt,
                                              color: colorScheme.primary,
                                            ),
                                            suffixIcon: transactionIdController.text.isNotEmpty
                                                ? IconButton(
                                                    icon: const Icon(Icons.clear),
                                                    onPressed: () => transactionIdController.clear(),
                                                  )
                                                : null,
                                            filled: true,
                                            fillColor: colorScheme.surface,
                                          ),
                                          onChanged: (value) {
                                            // Trigger rebuild to show/hide clear button
                                            (context as Element).markNeedsBuild();
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Recent Transactions Section
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: colorScheme.outline.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.history,
                                              color: colorScheme.primary,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Recent Transactions',
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              'Click to select',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Container(
                                          constraints: const BoxConstraints(maxHeight: 200),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: recentTransactions.length,
                                            itemBuilder: (context, index) {
                                              final transaction = recentTransactions[index];
                                              return Card(
                                                margin: const EdgeInsets.only(bottom: 8),
                                                child: ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundColor: colorScheme.primaryContainer,
                                                    child: Text(
                                                      (transaction['id'] as String).substring(0, 3),
                                                      style: TextStyle(
                                                        color: colorScheme.onPrimaryContainer,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  title: Text(
                                                    transaction['id'] as String,
                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  subtitle: Text(
                                                    '${transaction['customer']} • ${transaction['date']}',
                                                    style: TextStyle(
                                                      color: colorScheme.onSurfaceVariant,
                                                    ),
                                                  ),
                                                  trailing: Text(
                                                    '\$${transaction['amount']}',
                                                    style: TextStyle(
                                                      color: colorScheme.primary,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    transactionIdController.text = transaction['id'] as String;
                                                    (context as Element).markNeedsBuild();
                                                  },
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 24),
                                  
                                  // Reprint Options Section
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: colorScheme.outline.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.settings,
                                              color: colorScheme.primary,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Reprint Options',
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: DropdownButtonFormField<String>(
                                                value: selectedReprintReason,
                                                decoration: InputDecoration(
                                                  labelText: 'Reprint Reason',
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  filled: true,
                                                  fillColor: colorScheme.surface,
                                                ),
                                                items: [
                                                  'Customer Request',
                                                  'Printer Error',
                                                  'Lost Receipt',
                                                  'Duplicate for Records',
                                                  'Other'
                                                ].map((String value) {
                                                  return DropdownMenuItem<String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  selectedReprintReason = value!;
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: TextField(
                                                controller: reprintReasonController,
                                                decoration: InputDecoration(
                                                  labelText: 'Additional Notes',
                                                  hintText: 'Optional details...',
                                                  border: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  filled: true,
                                                  fillColor: colorScheme.surface,
                                                ),
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Reprint History Tab
                            SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surfaceVariant.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: colorScheme.outline.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.history,
                                              color: colorScheme.primary,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Reprint History',
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const Spacer(),
                                            Text(
                                              '${reprintHistory.length} reprints found',
                                              style: theme.textTheme.bodySmall?.copyWith(
                                                color: colorScheme.onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        if (reprintHistory.isEmpty)
                                          Center(
                                            child: Column(
                                              children: [
                                                Icon(
                                                  Icons.history,
                                                  size: 48,
                                                  color: colorScheme.onSurfaceVariant,
                                                ),
                                                const SizedBox(height: 16),
                                                Text(
                                                  'No reprint history found',
                                                  style: theme.textTheme.titleMedium?.copyWith(
                                                    color: colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  'Reprinted receipts will appear here',
                                                  style: theme.textTheme.bodyMedium?.copyWith(
                                                    color: colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        else
                                          ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: reprintHistory.length,
                                            itemBuilder: (context, index) {
                                              final reprint = reprintHistory[index];
                                              return Card(
                                                margin: const EdgeInsets.only(bottom: 12),
                                                child: ListTile(
                                                  leading: CircleAvatar(
                                                    backgroundColor: Colors.orange[100],
                                                                                                      child: Icon(
                                                    Icons.print,
                                                    color: Colors.orange[800],
                                                    size: 20,
                                                  ),
                                                  ),
                                                  title: Text(
                                                    '${reprint['id']} - Reprinted',
                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  subtitle: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text('Original: ${reprint['originalDate']}'),
                                                      Text('Reprinted: ${reprint['reprintDate']}'),
                                                      Text('Reason: ${reprint['reason']} • By: ${reprint['by']}'),
                                                    ],
                                                  ),
                                                  trailing: IconButton(
                                                    onPressed: () {
                                                      // Quick reprint from history
                                                      transactionIdController.text = reprint['id']!;
                                                      selectedReprintReason = reprint['reason']!;
                                                      // Switch to first tab
                                                      DefaultTabController.of(context).animateTo(0);
                                                    },
                                                    icon: Icon(
                                                      Icons.refresh,
                                                      color: colorScheme.primary,
                                                    ),
                                                    tooltip: 'Reprint Again',
                                                  ),
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Footer Actions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: transactionIdController.text.isNotEmpty
                          ? () {
                              _reprintReceipt(
                                context,
                                transactionIdController.text,
                                selectedReprintReason,
                                reprintReasonController.text,
                              );
                              Navigator.of(context).pop();
                            }
                          : null,
                      icon: const Icon(Icons.print),
                      label: const Text('Reprint Receipt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
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
    );
  }

  void _reprintReceipt(BuildContext context, String transactionId, String reason, String additionalNotes) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // In a real implementation, this would:
    // 1. Look up the transaction by ID
    // 2. Generate the receipt
    // 3. Send to printer
    // 4. Log the reprint action
    
    // For now, simulate reprinting
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: 48,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Success Message
              Text(
                'Receipt Reprinted Successfully!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'Transaction: $transactionId',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // Reprint Details
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reprint Details:',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Reason: $reason'),
                    if (additionalNotes.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text('Notes: $additionalNotes'),
                    ],
                    const SizedBox(height: 4),
                    Text('Time: ${DateTime.now().toString().substring(0, 19)}'),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    
    // Log the reprint action
    print('Receipt reprinted for transaction $transactionId at: ${DateTime.now()}');
    print('Reason: $reason');
    if (additionalNotes.isNotEmpty) {
      print('Additional Notes: $additionalNotes');
    }
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final reasonController = TextEditingController();
    final notesController = TextEditingController();
    String selectedHoldReason = 'Customer Request';
    bool isUrgent = false;
    
    // Get current cart for preview
    final currentCart = ref.read(currentCartProvider);
    if (currentCart == null || currentCart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No active cart to hold'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: 600,
                constraints: const BoxConstraints(maxHeight: 700),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.amber[50]!,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.amber[600]!,
                            Colors.orange[400]!,
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.pause_circle_outline,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Hold Current Cart',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Suspend transaction for later completion',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Cart Summary
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Cart Items',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${currentCart.items.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Content
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Cart Preview
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceVariant.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.shopping_cart,
                                        color: colorScheme.primary,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Cart Preview',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        'Total: \$${(currentCart.totalAmount ?? 0.0).toStringAsFixed(2)}',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          color: colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Container(
                                    constraints: const BoxConstraints(maxHeight: 150),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: currentCart.items.length,
                                      itemBuilder: (context, index) {
                                        final item = currentCart.items[index];
                                        return ListTile(
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                          leading: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: colorScheme.primaryContainer,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${item.quantity}',
                                              style: TextStyle(
                                                color: colorScheme.onPrimaryContainer,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            item.name,
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                          subtitle: Text(
                                            '\$${item.price.toStringAsFixed(2)} each',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                          trailing: Text(
                                            '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Hold Reason Selection
                            Text(
                              'Hold Reason',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Quick Reason Buttons
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        _buildQuickReasonButton(
                                          context,
                                          'Customer Request',
                                          Icons.person,
                                          Colors.blue[600]!,
                                          selectedHoldReason == 'Customer Request',
                                          () => setState(() => selectedHoldReason = 'Customer Request'),
                                        ),
                                        _buildQuickReasonButton(
                                          context,
                                          'Payment Issue',
                                          Icons.payment,
                                          Colors.red[600]!,
                                          selectedHoldReason == 'Payment Issue',
                                          () => setState(() => selectedHoldReason = 'Payment Issue'),
                                        ),
                                        _buildQuickReasonButton(
                                          context,
                                          'Stock Check',
                                          Icons.inventory,
                                          Colors.orange[600]!,
                                          selectedHoldReason == 'Stock Check',
                                          () => setState(() => selectedHoldReason = 'Stock Check'),
                                        ),
                                        _buildQuickReasonButton(
                                          context,
                                          'Manager Approval',
                                          Icons.admin_panel_settings,
                                          Colors.purple[600]!,
                                          selectedHoldReason == 'Manager Approval',
                                          () => setState(() => selectedHoldReason = 'Manager Approval'),
                                        ),
                                        _buildQuickReasonButton(
                                          context,
                                          'Customer Return',
                                          Icons.undo,
                                          Colors.teal[600]!,
                                          selectedHoldReason == 'Customer Return',
                                          () => setState(() => selectedHoldReason = 'Customer Return'),
                                        ),
                                        _buildQuickReasonButton(
                                          context,
                                          'Other',
                                          Icons.more_horiz,
                                          Colors.grey[600]!,
                                          selectedHoldReason == 'Other',
                                          () => setState(() => selectedHoldReason = 'Other'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  // Custom Reason Input
                                  if (selectedHoldReason == 'Other')
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                      child: TextField(
                                        controller: reasonController,
                                        decoration: InputDecoration(
                                          hintText: 'Enter custom hold reason...',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          prefixIcon: Icon(
                                            Icons.edit,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Additional Options
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[300]!),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.priority_high,
                                              color: Colors.red[600],
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Priority Options',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Checkbox(
                                              value: isUrgent,
                                              onChanged: (value) => setState(() => isUrgent = value ?? false),
                                              activeColor: Colors.red[600],
                                            ),
                                            Text(
                                              'Mark as Urgent',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(width: 16),
                                
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey[300]!),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.note,
                                              color: Colors.grey[600],
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Additional Notes',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.grey[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        TextField(
                                          controller: notesController,
                                          decoration: InputDecoration(
                                            hintText: 'Optional notes...',
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            contentPadding: const EdgeInsets.all(12),
                                          ),
                                          maxLines: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Hold Summary
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.amber[50]!,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.amber[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.amber[600],
                                        size: 24,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Hold Summary',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.amber[800],
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildSummaryCard(
                                          'Items',
                                          '${currentCart.items.length}',
                                          Colors.blue[600]!,
                                          Icons.shopping_cart,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildSummaryCard(
                                          'Total Value',
                                          '\$${(currentCart.totalAmount ?? 0.0).toStringAsFixed(2)}',
                                          Colors.green[600]!,
                                          Icons.attach_money,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _buildSummaryCard(
                                          'Hold Reason',
                                          selectedHoldReason == 'Other' && reasonController.text.isNotEmpty
                                              ? reasonController.text
                                              : selectedHoldReason,
                                          Colors.orange[600]!,
                                          Icons.pause_circle_outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isUrgent) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.red[50]!,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.red[200]!),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.priority_high,
                                            color: Colors.red[600],
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'This cart is marked as URGENT and will be prioritized in the held carts list',
                                              style: TextStyle(
                                                color: Colors.red[700],
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Actions
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(color: Colors.grey[300]!),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final holdReason = selectedHoldReason == 'Other' && reasonController.text.isNotEmpty
                                    ? reasonController.text
                                    : selectedHoldReason;
                                
                                // Add urgency prefix if marked as urgent
                                final finalReason = isUrgent ? '[URGENT] $holdReason' : holdReason;
                                
                                // Hold the cart
                                ref.read(currentCartProvider.notifier).holdCart(finalReason);
                                
                                Navigator.of(context).pop();
                                
                                // Show success message
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
                                        Text(
                                          'Cart held successfully! Reason: $finalReason',
                                        ),
                                      ],
                                    ),
                                    backgroundColor: Colors.green[600],
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    margin: const EdgeInsets.all(16),
                                    duration: const Duration(seconds: 4),
                                  ),
                                );
                                
                                // Log the hold action
                                print('Cart held: Reason: $finalReason, Items: ${currentCart.items.length}, Total: \$${(currentCart.totalAmount ?? 0.0).toStringAsFixed(2)}');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber[600],
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.pause_circle_outline, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Hold Cart',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
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
            );
          },
        );
      },
    );
  }
  
  Widget _buildQuickReasonButton(
    BuildContext context,
    String reason,
    IconData icon,
    Color color,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.grey[600],
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              reason,
              style: TextStyle(
                color: isSelected ? color : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }


  
  void _showRoomAvailabilityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.bedroom_parent, color: Colors.blue[600]),
              const SizedBox(width: 8),
              const Text('Room Availability'),
            ],
          ),
          content: SizedBox(
            width: 600,
            height: 500,
            child: FutureBuilder<List<Room>>(
              future: RoomDao.instance.getAll(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading rooms: ${snapshot.error}'),
                  );
                }
                
                final rooms = snapshot.data ?? [];
                if (rooms.isEmpty) {
                  return const Center(child: Text('No rooms available'));
                }
                
                // Separate rooms into available and occupied
                final availableRooms = rooms.where((room) => room.status == RoomStatus.available).toList();
                final occupiedRooms = rooms.where((room) => room.status != RoomStatus.available).toList();
                
                return DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      // Tab Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TabBar(
                          labelColor: Colors.blue[700],
                          unselectedLabelColor: Colors.grey[600],
                          indicator: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          tabs: [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, size: 16),
                                  const SizedBox(width: 8),
                                  Text('Available (${availableRooms.length})'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.cancel, size: 16),
                                  const SizedBox(width: 8),
                                  Text('Occupied (${occupiedRooms.length})'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tab Content
                      Expanded(
                        child: TabBarView(
                          children: [
                            // Available Rooms Tab
                            _buildRoomList(availableRooms, true),
                            
                            // Occupied Rooms Tab
                            _buildRoomList(occupiedRooms, false),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildRoomList(List<Room> rooms, bool isAvailable) {
    if (rooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAvailable ? Icons.check_circle_outline : Icons.cancel_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isAvailable ? 'No available rooms' : 'No occupied rooms',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isAvailable ? Colors.green[100]! : Colors.red[100]!,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isAvailable ? Icons.check_circle : Icons.cancel,
                color: isAvailable ? Colors.green[600]! : Colors.red[600]!,
                size: 20,
              ),
            ),
            title: Text(
              'Room ${room.roomNumber} - ${room.name}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isAvailable ? Colors.green[700]! : Colors.red[700]!,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type: ${room.type.name}'),
                Text('Status: ${room.status.name}'),
                Text('Capacity: ${room.capacity} pets'),
                if (room.currentOccupantName != null)
                  Text('Occupant: ${room.currentOccupantName}'),
                Text('Price: \$${room.basePricePerNight.toStringAsFixed(2)}/night'),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isAvailable ? Colors.green[50]! : Colors.red[50]!,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isAvailable ? Colors.green[200]! : Colors.red[200]!,
                ),
              ),
                             child: Text(
                 isAvailable ? 'Available' : 'Occupied',
                 style: TextStyle(
                   color: isAvailable ? Colors.green[700]! : Colors.red[700]!,
                   fontWeight: FontWeight.bold,
                   fontSize: 12,
                 ),
               ),
            ),
          ),
        );
      },
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
