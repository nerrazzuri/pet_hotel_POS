import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/payments/domain/entities/payment_method.dart';
import 'package:cat_hotel_pos/features/payments/domain/services/payment_service.dart';

class PaymentMethodsTab extends ConsumerStatefulWidget {
  const PaymentMethodsTab({super.key});

  @override
  ConsumerState<PaymentMethodsTab> createState() => _PaymentMethodsTabState();
}

class _PaymentMethodsTabState extends ConsumerState<PaymentMethodsTab> {
  final PaymentService _paymentService = PaymentService();
  List<PaymentMethod> _paymentMethods = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final methods = await _paymentService.getAllPaymentMethods();
      setState(() {
        _paymentMethods = methods;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading payment methods: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search payment methods...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    // Implement search functionality
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _showAddPaymentMethodDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Method'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _paymentMethods.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.payment, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No payment methods found'),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _paymentMethods.length,
                  itemBuilder: (context, index) {
                    final method = _paymentMethods[index];
                    return _buildPaymentMethodCard(method);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPaymentTypeColor(method.type),
          child: Icon(
            _getPaymentTypeIcon(method.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          method.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(method.description ?? ''),
            if (method.processingFee != null && method.processingFee! > 0)
              Text(
                'Processing Fee: ${method.processingFee}%',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: method.isActive 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    method.isActive ? 'Active' : 'Inactive',
                    style: TextStyle(
                      color: method.isActive ? Colors.green : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPaymentTypeColor(method.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    method.type.name.toUpperCase(),
                    style: TextStyle(
                      color: _getPaymentTypeColor(method.type),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            PopupMenuItem(
              value: method.isActive ? 'deactivate' : 'activate',
              child: Row(
                children: [
                  Icon(method.isActive ? Icons.block : Icons.check_circle),
                  const SizedBox(width: 8),
                  Text(method.isActive ? 'Deactivate' : 'Activate'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) async {
            switch (value) {
              case 'edit':
                _showEditPaymentMethodDialog(context, method);
                break;
              case 'deactivate':
                await _deactivatePaymentMethod(method.id);
                break;
              case 'activate':
                await _activatePaymentMethod(method.id);
                break;
              case 'delete':
                _showDeletePaymentMethodDialog(context, method);
                break;
            }
          },
        ),
      ),
    );
  }

  Color _getPaymentTypeColor(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return Colors.green;
      case PaymentType.creditCard:
        return Colors.blue;
      case PaymentType.debitCard:
        return Colors.indigo;
      case PaymentType.digitalWallet:
        return Colors.purple;
      case PaymentType.bankTransfer:
        return Colors.teal;
      case PaymentType.voucher:
        return Colors.orange;
      case PaymentType.deposit:
        return Colors.amber;
      case PaymentType.partialPayment:
        return Colors.grey;
    }
  }

  IconData _getPaymentTypeIcon(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return Icons.money;
      case PaymentType.creditCard:
        return Icons.credit_card;
      case PaymentType.debitCard:
        return Icons.credit_card;
      case PaymentType.digitalWallet:
        return Icons.account_balance_wallet;
      case PaymentType.bankTransfer:
        return Icons.account_balance;
      case PaymentType.voucher:
        return Icons.confirmation_number;
      case PaymentType.deposit:
        return Icons.account_balance_wallet;
      case PaymentType.partialPayment:
        return Icons.payment;
    }
  }

  Future<void> _deactivatePaymentMethod(String id) async {
    try {
      await _paymentService.deactivatePaymentMethod(id);
      await _loadPaymentMethods();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment method deactivated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deactivating payment method: $e')),
        );
      }
    }
  }

  Future<void> _activatePaymentMethod(String id) async {
    try {
      await _paymentService.activatePaymentMethod(id);
      await _loadPaymentMethods();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment method activated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error activating payment method: $e')),
        );
      }
    }
  }

  void _showAddPaymentMethodDialog(BuildContext context) {
    // TODO: Implement add payment method dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Payment Method functionality coming soon')),
    );
  }

  void _showEditPaymentMethodDialog(BuildContext context, PaymentMethod method) {
    // TODO: Implement edit payment method dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit Payment Method functionality coming soon')),
    );
  }

  void _showDeletePaymentMethodDialog(BuildContext context, PaymentMethod method) {
    // TODO: Implement delete payment method dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delete Payment Method functionality coming soon')),
    );
  }
}
