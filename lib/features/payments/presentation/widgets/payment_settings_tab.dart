import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentSettingsTab extends ConsumerStatefulWidget {
  const PaymentSettingsTab({super.key});

  @override
  ConsumerState<PaymentSettingsTab> createState() => _PaymentSettingsTabState();
}

class _PaymentSettingsTabState extends ConsumerState<PaymentSettingsTab> {
  bool _autoCalculateTax = true;
  bool _roundTaxAmounts = true;
  bool _showTaxBreakdown = true;
  bool _requireTaxId = false;
  int _taxDecimalPlaces = 2;
  String _defaultCurrency = 'MYR';
  String _taxRoundingMethod = 'Round to nearest cent';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGeneralSettings(),
          const SizedBox(height: 24),
          _buildTaxSettings(),
          const SizedBox(height: 24),
          _buildReceiptSettings(),
          const SizedBox(height: 24),
          _buildSecuritySettings(),
          const SizedBox(height: 24),
          _buildIntegrationSettings(),
        ],
      ),
    );
  }

  Widget _buildGeneralSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'General Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Default Currency',
                border: OutlineInputBorder(),
              ),
              value: _defaultCurrency,
              items: const [
                DropdownMenuItem(value: 'MYR', child: Text('Malaysian Ringgit (MYR)')),
                DropdownMenuItem(value: 'USD', child: Text('US Dollar (USD)')),
                DropdownMenuItem(value: 'SGD', child: Text('Singapore Dollar (SGD)')),
                DropdownMenuItem(value: 'EUR', child: Text('Euro (EUR)')),
              ],
              onChanged: (value) {
                setState(() {
                  _defaultCurrency = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Business Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Business Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // TODO: Save business name
              },
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Business Tax ID',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // TODO: Save business tax ID
              },
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Business Address',
                border: OutlineInputBorder(),
                hintText: 'Enter your business address',
              ),
              maxLines: 3,
              onChanged: (value) {
                // TODO: Save business address
              },
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Business Phone',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // TODO: Save business phone
              },
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Business Email',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // TODO: Save business email
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tax Configuration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Auto-calculate Tax'),
              subtitle: const Text('Automatically calculate tax on transactions'),
              value: _autoCalculateTax,
              onChanged: (value) {
                setState(() {
                  _autoCalculateTax = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Round Tax Amounts'),
              subtitle: const Text('Round tax amounts to specified decimal places'),
              value: _roundTaxAmounts,
              onChanged: (value) {
                setState(() {
                  _roundTaxAmounts = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Show Tax Breakdown'),
              subtitle: const Text('Display tax breakdown on receipts and invoices'),
              value: _showTaxBreakdown,
              onChanged: (value) {
                setState(() {
                  _showTaxBreakdown = value;
                });
              },
            ),
            SwitchListTile(
              title: const Text('Require Tax ID'),
              subtitle: const Text('Require customer tax ID for business transactions'),
              value: _requireTaxId,
              onChanged: (value) {
                setState(() {
                  _requireTaxId = value;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Tax Decimal Places',
                border: OutlineInputBorder(),
              ),
              value: _taxDecimalPlaces,
              items: const [
                DropdownMenuItem(value: 0, child: Text('0 (Whole numbers)')),
                DropdownMenuItem(value: 1, child: Text('1 (Tenths)')),
                DropdownMenuItem(value: 2, child: Text('2 (Cents)')),
                DropdownMenuItem(value: 3, child: Text('3 (Thousandths)')),
              ],
              onChanged: (value) {
                setState(() {
                  _taxDecimalPlaces = value!;
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Tax Rounding Method',
                border: OutlineInputBorder(),
              ),
              value: _taxRoundingMethod,
              items: const [
                DropdownMenuItem(value: 'Round to nearest cent', child: Text('Round to nearest cent')),
                DropdownMenuItem(value: 'Round up', child: Text('Round up')),
                DropdownMenuItem(value: 'Round down', child: Text('Round down')),
                DropdownMenuItem(value: 'Banker\'s rounding', child: Text('Banker\'s rounding')),
              ],
              onChanged: (value) {
                setState(() {
                  _taxRoundingMethod = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Tax Rates',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _showTaxRatesDialog(),
              icon: const Icon(Icons.tune),
              label: const Text('Configure Tax Rates'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Receipt & Invoice Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Receipt Header',
                border: OutlineInputBorder(),
                hintText: 'Enter your business name or custom header',
              ),
              onChanged: (value) {
                // TODO: Save receipt header
              },
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Receipt Footer',
                border: OutlineInputBorder(),
                hintText: 'Enter custom footer message',
              ),
              maxLines: 2,
              onChanged: (value) {
                // TODO: Save receipt footer
              },
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Terms & Conditions',
                border: OutlineInputBorder(),
                hintText: 'Enter your terms and conditions',
              ),
              maxLines: 3,
              onChanged: (value) {
                // TODO: Save terms and conditions
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Receipt Options',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Auto-print Receipts'),
              subtitle: const Text('Automatically print receipts after transactions'),
              value: false,
              onChanged: (value) {
                // TODO: Save auto-print setting
              },
            ),
            SwitchListTile(
              title: const Text('Email Receipts'),
              subtitle: const Text('Send receipts via email when available'),
              value: true,
              onChanged: (value) {
                // TODO: Save email receipts setting
              },
            ),
            SwitchListTile(
              title: const Text('WhatsApp Receipts'),
              subtitle: const Text('Send receipts via WhatsApp when available'),
              value: false,
              onChanged: (value) {
                // TODO: Save WhatsApp receipts setting
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Security & Permissions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Require Authorization for Refunds'),
              subtitle: const Text('Require manager approval for refunds above threshold'),
              value: true,
              onChanged: (value) {
                // TODO: Save refund authorization setting
              },
            ),
            SwitchListTile(
              title: const Text('Require Signature for Credit Cards'),
              subtitle: const Text('Require customer signature for credit card transactions'),
              value: true,
              onChanged: (value) {
                // TODO: Save signature requirement setting
              },
            ),
            SwitchListTile(
              title: const Text('Audit Trail'),
              subtitle: const Text('Keep detailed logs of all payment activities'),
              value: true,
              onChanged: (value) {
                // TODO: Save audit trail setting
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Refund Thresholds',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Auto-approval Limit (MYR)',
                border: OutlineInputBorder(),
                hintText: 'Enter amount for automatic refund approval',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // TODO: Save auto-approval limit
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntegrationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Gateway Integration',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Credit Card Processing',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Payment Gateway',
                border: OutlineInputBorder(),
              ),
              value: 'Stripe',
              items: const [
                DropdownMenuItem(value: 'Stripe', child: Text('Stripe')),
                DropdownMenuItem(value: 'PayPal', child: Text('PayPal')),
                DropdownMenuItem(value: 'Square', child: Text('Square')),
                DropdownMenuItem(value: 'Custom', child: Text('Custom Integration')),
              ],
              onChanged: (value) {
                // TODO: Save payment gateway setting
              },
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                labelText: 'API Key',
                border: OutlineInputBorder(),
                hintText: 'Enter your payment gateway API key',
              ),
              obscureText: true,
              onChanged: (value) {
                // TODO: Save API key
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Digital Wallet Integration',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Touch n Go'),
              subtitle: const Text('Enable Touch n Go payments'),
              value: true,
              onChanged: (value) {
                // TODO: Save Touch n Go setting
              },
            ),
            SwitchListTile(
              title: const Text('GrabPay'),
              subtitle: const Text('Enable GrabPay payments'),
              value: true,
              onChanged: (value) {
                // TODO: Save GrabPay setting
              },
            ),
            SwitchListTile(
              title: const Text('Boost'),
              subtitle: const Text('Enable Boost payments'),
              value: false,
              onChanged: (value) {
                // TODO: Save Boost setting
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _testIntegration(),
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Test Integration'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _saveSettings(),
                    icon: const Icon(Icons.save),
                    label: const Text('Save Settings'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTaxRatesDialog() {
    // TODO: Implement tax rates configuration dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tax rates configuration coming soon')),
    );
  }

  void _testIntegration() {
    // TODO: Implement integration testing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Integration testing coming soon')),
    );
  }

  void _saveSettings() {
    // TODO: Implement settings saving
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully')),
    );
  }
}
