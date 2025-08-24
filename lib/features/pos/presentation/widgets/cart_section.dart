import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/pos/presentation/providers/pos_providers.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/cart_item.dart';

class CartSection extends ConsumerWidget {
  const CartSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartItemsProvider);
    final cartTotal = ref.watch(cartTotalProvider);
    final cartSubtotal = ref.watch(cartSubtotalProvider);
    final cartTaxAmount = ref.watch(cartTaxAmountProvider);
    final cartDiscountAmount = ref.watch(cartDiscountAmountProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

         return Container(
       decoration: BoxDecoration(
         color: colorScheme.surface,
         borderRadius: const BorderRadius.only(
           topLeft: Radius.circular(20),
           bottomLeft: Radius.circular(20),
         ),
       ),
      child: Column(
        children: [
          // Enhanced Header
          _buildEnhancedHeader(context, theme, colorScheme, cartItems, ref),
          
          // Cart Items with improved styling
          Expanded(
            child: cartItems.isEmpty
                ? _buildEmptyCartState(theme, colorScheme)
                : _buildCartItemsList(cartItems, theme, colorScheme, ref),
          ),
          
          // Enhanced Cart Summary
          if (cartItems.isNotEmpty) _buildCartSummary(
            cartSubtotal,
            cartTaxAmount,
            cartDiscountAmount,
            cartTotal,
            theme,
            colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedHeader(BuildContext context, ThemeData theme, ColorScheme colorScheme, List<CartItem> cartItems, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Header with Cart Icon and Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.shopping_cart,
                  color: colorScheme.onPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Cart',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    '${cartItems.length} item${cartItems.length == 1 ? '' : 's'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // Action Buttons
          if (cartItems.isNotEmpty)
            Row(
              children: [
                // Hold Cart Button
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => _showHoldCartDialog(context, ref),
                    icon: Icon(
                      Icons.pause_circle_outline,
                      color: colorScheme.onSecondaryContainer,
                      size: 20,
                    ),
                    tooltip: 'Hold Cart',
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Clear Cart Button
                Container(
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: () => _showClearCartDialog(context, ref),
                    icon: Icon(
                      Icons.clear_all,
                      color: colorScheme.onErrorContainer,
                      size: 20,
                    ),
                    tooltip: 'Clear Cart',
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyCartState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Cart is empty',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add services from the product grid',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Start by selecting a service',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList(List<CartItem> cartItems, ThemeData theme, ColorScheme colorScheme, WidgetRef ref) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        final item = cartItems[index];
        return _buildCartItemCard(item, theme, colorScheme, ref);
      },
    );
  }

     Widget _buildCartItemCard(CartItem item, ThemeData theme, ColorScheme colorScheme, WidgetRef ref) {
     return Container(
       margin: const EdgeInsets.only(bottom: 8),
       decoration: BoxDecoration(
         color: colorScheme.surface,
         borderRadius: BorderRadius.circular(12),
         border: Border.all(
           color: colorScheme.outline.withOpacity(0.1),
         ),
         boxShadow: [
           BoxShadow(
             color: colorScheme.shadow.withOpacity(0.05),
             blurRadius: 8,
             offset: const Offset(0, 1),
           ),
         ],
       ),
       child: Padding(
         padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Item Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getCategoryColor(item.category).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getCategoryColor(item.category).withOpacity(0.3),
                ),
              ),
              child: Icon(
                _getCategoryIcon(item.category),
                color: _getCategoryColor(item.category),
                size: 20,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.category ?? 'Unknown',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${item.price.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getCategoryColor(item.category),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Total: \$${(item.price * item.quantity).toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Quantity Controls
            Column(
              children: [
                // Quantity Display
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${item.quantity}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Quantity Controls
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Decrease Button
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: IconButton(
                        onPressed: () => _decreaseQuantity(ref, item),
                        icon: Icon(
                          Icons.remove,
                          color: colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(4),
                          minimumSize: const Size(24, 24),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    // Increase Button
                    Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: IconButton(
                        onPressed: () => _increaseQuantity(ref, item),
                        icon: Icon(
                          Icons.add,
                          color: colorScheme.onPrimary,
                          size: 16,
                        ),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(4),
                          minimumSize: const Size(24, 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(width: 12),
            
            // Remove Button
            IconButton(
              onPressed: () => _removeItem(ref, item),
              icon: Icon(
                Icons.delete_outline,
                color: colorScheme.error,
                size: 20,
              ),
              tooltip: 'Remove Item',
            ),
          ],
        ),
      ),
    );
  }

     Widget _buildCartSummary(double subtotal, double tax, double discount, double total, ThemeData theme, ColorScheme colorScheme) {
     return Container(
       padding: const EdgeInsets.all(16),
       decoration: BoxDecoration(
         color: colorScheme.surfaceVariant.withOpacity(0.3),
         borderRadius: const BorderRadius.only(
           bottomLeft: Radius.circular(20),
           bottomRight: Radius.circular(20),
         ),
       ),
      child: Column(
        children: [
          // Summary Row
          _buildSummaryRow('Subtotal', subtotal, theme, colorScheme),
          if (tax > 0) _buildSummaryRow('Tax', tax, theme, colorScheme),
          if (discount > 0) _buildSummaryRow('Discount', -discount, theme, colorScheme, isDiscount: true),
          
          const Divider(height: 20),
          
          // Total Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, ThemeData theme, ColorScheme colorScheme, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isDiscount ? colorScheme.error : colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String? category) {
    if (category == null) return Colors.grey;
    
    switch (category.toLowerCase()) {
      case 'boarding':
        return Colors.blue;
      case 'daycare':
        return Colors.orange;
      case 'grooming':
        return Colors.teal;
      case 'addons':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String? category) {
    if (category == null) return Icons.category;
    
    switch (category.toLowerCase()) {
      case 'boarding':
        return Icons.hotel;
      case 'daycare':
        return Icons.sunny;
      case 'grooming':
        return Icons.content_cut;
      case 'addons':
        return Icons.add_circle;
      default:
        return Icons.category;
    }
  }

  void _increaseQuantity(WidgetRef ref, CartItem item) {
    final updatedItem = item.copyWith(quantity: item.quantity + 1);
    ref.read(currentCartProvider.notifier).updateCartItem(item.id, updatedItem);
  }

  void _decreaseQuantity(WidgetRef ref, CartItem item) {
    if (item.quantity > 1) {
      final updatedItem = item.copyWith(quantity: item.quantity - 1);
      ref.read(currentCartProvider.notifier).updateCartItem(item.id, updatedItem);
    }
  }

  void _removeItem(WidgetRef ref, CartItem item) {
    ref.read(currentCartProvider.notifier).removeCartItem(item.id);
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber,
              color: Colors.orange[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text('Clear Cart'),
          ],
        ),
        content: const Text('Are you sure you want to clear all items from the cart? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
                      ElevatedButton(
              onPressed: () {
                ref.read(currentCartProvider.notifier).clearCart();
                Navigator.pop(context);
              },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear Cart'),
          ),
        ],
      ),
    );
  }

  void _showHoldCartDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.pause_circle_outline,
              color: Colors.blue[600],
              size: 24,
            ),
            const SizedBox(width: 12),
            const Text('Hold Cart'),
          ],
        ),
        content: const Text('This cart will be saved and can be retrieved later. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement hold cart functionality
              Navigator.pop(context);
            },
            child: const Text('Hold Cart'),
          ),
        ],
      ),
    );
  }
}
