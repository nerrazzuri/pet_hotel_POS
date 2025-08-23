import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/pos/presentation/providers/pos_providers.dart';

class CartSection extends ConsumerWidget {
  const CartSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartItemsProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final cartSubtotal = ref.watch(cartSubtotalProvider);
    final cartTaxAmount = ref.watch(cartTaxAmountProvider);
    final cartDiscountAmount = ref.watch(cartDiscountAmountProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.shopping_cart,
                    color: Colors.teal,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Current Cart',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              if (cartItems.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    _showClearCartDialog(context, ref);
                  },
                  icon: const Icon(Icons.clear_all),
                  label: const Text('Clear'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red[600],
                    backgroundColor: Colors.red[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Cart Items
          if (cartItems.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Cart is empty',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add items from the product grid',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  final item = cartItems[index];
                  return _CartItemCard(
                    item: item,
                    onQuantityChanged: (newQuantity) {
                      if (newQuantity <= 0) {
                        ref.read(currentCartProvider.notifier).removeCartItem(item.id);
                      } else {
                        final updatedItem = item.copyWith(quantity: newQuantity);
                        ref.read(currentCartProvider.notifier).updateCartItem(
                          item.id,
                          updatedItem,
                        );
                      }
                    },
                    onRemove: () {
                      ref.read(currentCartProvider.notifier).removeCartItem(item.id);
                    },
                  );
                },
              ),
            ),
          
          // Cart Summary
          if (cartItems.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              height: 1,
              color: Colors.grey[300],
            ),
            
            // Subtotal
            _SummaryRow(
              label: 'Subtotal',
              value: cartSubtotal,
            ),
            
            // Tax
            _SummaryRow(
              label: 'Tax (6%)',
              value: cartTaxAmount,
            ),
            
            // Discount
            if (cartDiscountAmount > 0)
              _SummaryRow(
                label: 'Discount',
                value: -cartDiscountAmount,
                valueColor: Colors.green[600],
              ),
            
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 1,
              color: Colors.grey[300],
            ),
            
            // Total
            _SummaryRow(
              label: 'Total',
              value: cartTotal,
              isTotal: true,
            ),
          ],
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to clear all items from the cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(currentCartProvider.notifier).clearCart();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final dynamic item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemCard({
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shadowColor: Colors.black.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Item Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${item.price.toStringAsFixed(2)} each',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            // Quantity Controls
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => onQuantityChanged(item.quantity - 1),
                    icon: const Icon(Icons.remove_circle_outline),
                    iconSize: 20,
                    color: Colors.grey[600],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(
                      item.quantity.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => onQuantityChanged(item.quantity + 1),
                    icon: const Icon(Icons.add_circle_outline),
                    iconSize: 20,
                    color: Colors.teal,
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 12),
            
            // Total Price
            SizedBox(
              width: 80,
              child: Text(
                '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.teal,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Remove Button
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
              iconSize: 20,
              color: Colors.red[400],
              style: IconButton.styleFrom(
                backgroundColor: Colors.red[50],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double value;
  final Color? valueColor;
  final bool isTotal;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.grey : Colors.grey[600],
            ),
          ),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: isTotal ? 20 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? (isTotal ? Colors.teal : Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
