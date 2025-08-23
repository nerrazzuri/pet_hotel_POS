import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/voucher.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/cart_item.dart';
import 'package:cat_hotel_pos/features/pos/domain/services/voucher_service.dart';
import 'package:cat_hotel_pos/features/pos/presentation/providers/pos_providers.dart';

class VoucherApplicationWidget extends ConsumerStatefulWidget {
  const VoucherApplicationWidget({super.key});

  @override
  ConsumerState<VoucherApplicationWidget> createState() => _VoucherApplicationWidgetState();
}

class _VoucherApplicationWidgetState extends ConsumerState<VoucherApplicationWidget> {
  final TextEditingController _voucherCodeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  Voucher? _selectedVoucher;
  VoucherValidationResult? _validationResult;
  bool _isLoading = false;

  @override
  void dispose() {
    _voucherCodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(currentCartProvider);
    final cartItems = ref.watch(cartItemsProvider);
    final cartSubtotal = ref.watch(cartSubtotalProvider);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.card_giftcard, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Vouchers & Promotions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Voucher Code Input
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _voucherCodeController,
                    decoration: InputDecoration(
                      labelText: 'Voucher Code',
                      hintText: 'Enter voucher code...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.confirmation_number),
                      suffixIcon: _voucherCodeController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: () {
                                _voucherCodeController.clear();
                                setState(() {
                                  _selectedVoucher = null;
                                  _validationResult = null;
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        _validateVoucher(value, cartItems, cartSubtotal, cart?.customerId);
                      } else {
                        setState(() {
                          _selectedVoucher = null;
                          _validationResult = null;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : () => _validateVoucher(
                    _voucherCodeController.text,
                    cartItems,
                    cartSubtotal,
                    cart?.customerId,
                  ),
                  icon: _isLoading 
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(Icons.search),
                  label: Text('Validate'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Validation Result
            if (_validationResult != null) ...[
              _buildValidationResult(),
              const SizedBox(height: 16),
            ],

            // Selected Voucher Details
            if (_selectedVoucher != null) ...[
              _buildVoucherDetails(),
              const SizedBox(height: 16),
            ],

            // Applied Vouchers
            if (cart?.appliedVouchers != null && cart!.appliedVouchers!.isNotEmpty) ...[
              _buildAppliedVouchers(cart.appliedVouchers!),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            if (_selectedVoucher != null && _validationResult?.isValid == true) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _applyVoucher(),
                      icon: Icon(Icons.add),
                      label: Text('Apply Voucher'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildValidationResult() {
    final isValid = _validationResult!.isValid;
    final errorMessage = _validationResult!.errorMessage;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isValid ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isValid ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.error,
            color: isValid ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isValid ? 'Voucher is valid!' : errorMessage ?? 'Invalid voucher',
              style: TextStyle(
                color: isValid ? Colors.green.shade700 : Colors.red.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherDetails() {
    final voucher = _selectedVoucher!;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_giftcard, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Text(
                'Voucher Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildVoucherInfoRow('Code', voucher.code),
              ),
              Expanded(
                child: _buildVoucherInfoRow('Type', _formatVoucherType(voucher.type)),
              ),
            ],
          ),
          
          Row(
            children: [
              Expanded(
                child: _buildVoucherInfoRow('Value', _formatVoucherValue(voucher)),
              ),
              Expanded(
                child: _buildVoucherInfoRow('Status', _formatVoucherStatus(voucher.status)),
              ),
            ],
          ),
          
          if (voucher.description != null) ...[
            const SizedBox(height: 8),
            _buildVoucherInfoRow('Description', voucher.description!),
          ],
          
          if (voucher.minimumPurchaseAmount != null) ...[
            const SizedBox(height: 8),
            _buildVoucherInfoRow('Min. Purchase', 'RM${voucher.minimumPurchaseAmount!.toStringAsFixed(2)}'),
          ],
          
          if (voucher.maximumDiscountAmount != null) ...[
            const SizedBox(height: 8),
            _buildVoucherInfoRow('Max. Discount', 'RM${voucher.maximumDiscountAmount!.toStringAsFixed(2)}'),
          ],
          
          const SizedBox(height: 8),
          _buildVoucherInfoRow('Valid Until', _formatDate(voucher.validUntil)),
          _buildVoucherInfoRow('Usage', '${voucher.currentUsage}/${voucher.maxUsage}'),
        ],
      ),
    );
  }

  Widget _buildAppliedVouchers(List<Voucher> appliedVouchers) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              const SizedBox(width: 8),
              Text(
                'Applied Vouchers',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          ...appliedVouchers.map((voucher) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${voucher.code} - ${_formatVoucherValue(voucher)}',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.remove_circle, color: Colors.red, size: 20),
                  onPressed: () => _removeVoucher(voucher),
                  tooltip: 'Remove voucher',
                ),
              ],
            ),
          )).toList(),
          
          const SizedBox(height: 8),
          Text(
            'Total Voucher Discount: RM${_calculateTotalVoucherDiscount(appliedVouchers).toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _validateVoucher(
    String voucherCode,
    List<CartItem> cartItems,
    double cartSubtotal,
    String? customerId,
  ) async {
    if (voucherCode.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // For demo purposes, create a sample voucher
      // In real implementation, this would fetch from database/API
      final voucher = _createSampleVoucher(voucherCode);
      
      final result = VoucherService.validateVoucher(
        voucher,
        cartItems,
        cartSubtotal,
        customerId,
      );

      setState(() {
        _validationResult = result;
        _selectedVoucher = result.isValid ? result.voucher : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _validationResult = VoucherValidationResult(
          isValid: false,
          errorMessage: 'Error validating voucher: $e',
        );
      });
    }
  }

  void _applyVoucher() {
    if (_selectedVoucher == null) return;

    final cart = ref.read(currentCartProvider);
    if (cart == null) return;

    final cartItems = ref.read(cartItemsProvider);
    final cartSubtotal = ref.read(cartSubtotalProvider);
    final currentDiscount = cart.discountAmount ?? 0.0;

    final result = VoucherService.applyVoucherToCart(
      _selectedVoucher!,
      cartItems,
      cartSubtotal,
      currentDiscount,
    );

    // Update cart with voucher
    ref.read(currentCartProvider.notifier).applyVoucher(_selectedVoucher!, result);

    // Clear input
    _voucherCodeController.clear();
    setState(() {
      _selectedVoucher = null;
      _validationResult = null;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voucher ${_selectedVoucher!.code} applied successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _removeVoucher(Voucher voucher) {
    final cart = ref.read(currentCartProvider);
    if (cart == null) return;

    ref.read(currentCartProvider.notifier).removeVoucher(voucher);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Voucher ${voucher.code} removed'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Voucher _createSampleVoucher(String code) {
    // Create sample vouchers for demo
    switch (code.toUpperCase()) {
      case 'WELCOME10':
        return Voucher(
          id: '1',
          code: code,
          type: VoucherType.discount,
          status: VoucherStatus.active,
          value: 10.0, // 10% discount
          validFrom: DateTime.now().subtract(const Duration(days: 30)),
          validUntil: DateTime.now().add(const Duration(days: 30)),
          maxUsage: 100,
          currentUsage: 45,
          description: 'Welcome discount for new customers',
          minimumPurchaseAmount: 50.0,
          maximumDiscountAmount: 25.0,
          issuedBy: 'system',
          issuedAt: DateTime.now().subtract(const Duration(days: 30)),
        );
      
      case 'GIFT50':
        return Voucher(
          id: '2',
          code: code,
          type: VoucherType.giftCard,
          status: VoucherStatus.active,
          value: 50.0, // RM 50 gift card
          validFrom: DateTime.now().subtract(const Duration(days: 60)),
          validUntil: DateTime.now().add(const Duration(days: 300)),
          maxUsage: 1,
          currentUsage: 0,
          description: 'RM 50 Gift Card',
          issuedBy: 'system',
          issuedAt: DateTime.now().subtract(const Duration(days: 60)),
        );
      
      case 'LOYALTY20':
        return Voucher(
          id: '3',
          code: code,
          type: VoucherType.loyalty,
          status: VoucherStatus.active,
          value: 20.0, // RM 20 loyalty reward
          validFrom: DateTime.now().subtract(const Duration(days: 7)),
          validUntil: DateTime.now().add(const Duration(days: 7)),
          maxUsage: 1,
          currentUsage: 0,
          description: 'Loyalty points redemption',
          minimumPurchaseAmount: 100.0,
          issuedBy: 'system',
          issuedAt: DateTime.now().subtract(const Duration(days: 7)),
        );
      
      default:
        return Voucher(
          id: '4',
          code: code,
          type: VoucherType.promotional,
          status: VoucherStatus.active,
          value: 15.0, // 15% discount
          validFrom: DateTime.now().subtract(const Duration(days: 15)),
          validUntil: DateTime.now().add(const Duration(days: 15)),
          maxUsage: 50,
          currentUsage: 12,
          description: 'Promotional discount',
          minimumPurchaseAmount: 30.0,
          maximumDiscountAmount: 30.0,
          issuedBy: 'system',
          issuedAt: DateTime.now().subtract(const Duration(days: 15)),
        );
    }
  }

  String _formatVoucherType(VoucherType type) {
    switch (type) {
      case VoucherType.discount:
        return 'Discount';
      case VoucherType.giftCard:
        return 'Gift Card';
      case VoucherType.promotional:
        return 'Promotional';
      case VoucherType.loyalty:
        return 'Loyalty';
    }
  }

  String _formatVoucherValue(Voucher voucher) {
    switch (voucher.type) {
      case VoucherType.discount:
        return '${voucher.value.toStringAsFixed(0)}% off';
      case VoucherType.giftCard:
        return 'RM${voucher.value.toStringAsFixed(2)}';
      case VoucherType.promotional:
        return voucher.value <= 100 ? '${voucher.value.toStringAsFixed(0)}% off' : 'RM${voucher.value.toStringAsFixed(2)}';
      case VoucherType.loyalty:
        return 'RM${voucher.value.toStringAsFixed(2)}';
    }
  }

  String _formatVoucherStatus(VoucherStatus status) {
    switch (status) {
      case VoucherStatus.active:
        return 'Active';
      case VoucherStatus.used:
        return 'Used';
      case VoucherStatus.expired:
        return 'Expired';
      case VoucherStatus.cancelled:
        return 'Cancelled';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  double _calculateTotalVoucherDiscount(List<Voucher> vouchers) {
    // This would calculate the actual discount based on cart items
    // For now, return a simple sum
    return vouchers.fold(0.0, (sum, voucher) => sum + voucher.value);
  }
}
