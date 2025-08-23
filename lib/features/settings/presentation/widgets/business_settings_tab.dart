import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/settings/domain/entities/settings.dart';
import 'package:cat_hotel_pos/features/settings/domain/services/settings_service.dart';
import 'package:cat_hotel_pos/core/services/settings_dao.dart';

class BusinessSettingsTab extends ConsumerStatefulWidget {
  const BusinessSettingsTab({super.key});

  @override
  ConsumerState<BusinessSettingsTab> createState() => _BusinessSettingsTabState();
}

class _BusinessSettingsTabState extends ConsumerState<BusinessSettingsTab> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessPhoneController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _receiptHeaderController = TextEditingController();
  final _receiptFooterController = TextEditingController();
  
  String _selectedCurrency = 'MYR';
  String _selectedTimezone = 'Asia/Kuala_Lumpur';
  bool _enableTaxCalculation = true;
  double _defaultTaxRate = 6.0;
  bool _enableReceiptPrinting = true;
  bool _enableEmailReceipts = true;
  bool _enableWhatsAppReceipts = false;
  
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _businessPhoneController.dispose();
    _businessEmailController.dispose();
    _receiptHeaderController.dispose();
    _receiptFooterController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    
    try {
      final settingsService = SettingsService(SettingsDao());
      final settings = await settingsService.getSettings();
      
      setState(() {
        _businessNameController.text = settings.businessName;
        _businessAddressController.text = settings.businessAddress;
        _businessPhoneController.text = settings.businessPhone;
        _businessEmailController.text = settings.businessEmail;
        _receiptHeaderController.text = settings.receiptHeader;
        _receiptFooterController.text = settings.receiptFooter;
        _selectedCurrency = settings.currency;
        _selectedTimezone = settings.timezone;
        _enableTaxCalculation = settings.enableTaxCalculation;
        _defaultTaxRate = settings.defaultTaxRate;
        _enableReceiptPrinting = settings.enableReceiptPrinting;
        _enableEmailReceipts = settings.enableEmailReceipts;
        _enableWhatsAppReceipts = settings.enableWhatsAppReceipts;
        _hasChanges = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading settings: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final settingsService = SettingsService(SettingsDao());
      final currentSettings = await settingsService.getSettings();
      
      final updatedSettings = currentSettings.copyWith(
        businessName: _businessNameController.text.trim(),
        businessAddress: _businessAddressController.text.trim(),
        businessPhone: _businessPhoneController.text.trim(),
        businessEmail: _businessEmailController.text.trim(),
        currency: _selectedCurrency,
        timezone: _selectedTimezone,
        enableTaxCalculation: _enableTaxCalculation,
        defaultTaxRate: _defaultTaxRate,
        enableReceiptPrinting: _enableReceiptPrinting,
        receiptHeader: _receiptHeaderController.text.trim(),
        receiptFooter: _receiptFooterController.text.trim(),
        enableEmailReceipts: _enableEmailReceipts,
        enableWhatsAppReceipts: _enableWhatsAppReceipts,
      );
      
      await settingsService.updateSettings(updatedSettings);
      
      setState(() => _hasChanges = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business settings saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving settings: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _markAsChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Information Section
            _buildSectionHeader('Business Information', Icons.business),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _businessNameController,
              decoration: const InputDecoration(
                labelText: 'Business Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.store),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Business name is required';
                }
                return null;
              },
              onChanged: (_) => _markAsChanged(),
            ),
            
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _businessAddressController,
              decoration: const InputDecoration(
                labelText: 'Business Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Business address is required';
                }
                return null;
              },
              onChanged: (_) => _markAsChanged(),
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _businessPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Business Phone',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Business phone is required';
                      }
                      return null;
                    },
                    onChanged: (_) => _markAsChanged(),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: TextFormField(
                    controller: _businessEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Business Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Business email is required';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    onChanged: (_) => _markAsChanged(),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Regional Settings Section
            _buildSectionHeader('Regional Settings', Icons.language),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    items: ['MYR', 'USD', 'EUR', 'GBP', 'SGD', 'JPY', 'CNY', 'AUD', 'CAD', 'CHF']
                        .map((currency) => DropdownMenuItem(
                              value: currency,
                              child: Text(currency),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCurrency = value);
                        _markAsChanged();
                      }
                    },
                  ),
                ),
                
                const SizedBox(width: 16),
                
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedTimezone,
                    decoration: const InputDecoration(
                      labelText: 'Timezone',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.access_time),
                    ),
                    items: [
                      'Asia/Kuala_Lumpur',
                      'Asia/Singapore',
                      'Asia/Bangkok',
                      'Asia/Manila',
                      'Asia/Jakarta',
                      'UTC',
                      'America/New_York',
                      'America/London',
                      'Europe/Paris',
                      'Europe/Berlin',
                    ]
                        .map((timezone) => DropdownMenuItem(
                              value: timezone,
                              child: Text(timezone.split('/').last),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedTimezone = value);
                        _markAsChanged();
                      }
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Tax Settings Section
            _buildSectionHeader('Tax Settings', Icons.receipt_long),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Enable Tax Calculation'),
              subtitle: const Text('Automatically calculate tax on transactions'),
              value: _enableTaxCalculation,
              onChanged: (value) {
                setState(() => _enableTaxCalculation = value);
                _markAsChanged();
              },
            ),
            
            if (_enableTaxCalculation) ...[
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _defaultTaxRate.toString(),
                decoration: const InputDecoration(
                  labelText: 'Default Tax Rate (%)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.percent),
                  suffixText: '%',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final rate = double.tryParse(value);
                  if (rate == null || rate < 0 || rate > 100) {
                    return 'Tax rate must be between 0 and 100';
                  }
                  return null;
                },
                onChanged: (value) {
                  final rate = double.tryParse(value);
                  if (rate != null) {
                    setState(() => _defaultTaxRate = rate);
                    _markAsChanged();
                  }
                },
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Receipt Settings Section
            _buildSectionHeader('Receipt Settings', Icons.receipt),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Enable Receipt Printing'),
              subtitle: const Text('Print receipts for transactions'),
              value: _enableReceiptPrinting,
              onChanged: (value) {
                setState(() => _enableReceiptPrinting = value);
                _markAsChanged();
              },
            ),
            
            if (_enableReceiptPrinting) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _receiptHeaderController,
                decoration: const InputDecoration(
                  labelText: 'Receipt Header',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.text_fields),
                ),
                onChanged: (_) => _markAsChanged(),
              ),
              
              const SizedBox(height: 16),
              TextFormField(
                controller: _receiptFooterController,
                decoration: const InputDecoration(
                  labelText: 'Receipt Footer',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.text_fields),
                ),
                onChanged: (_) => _markAsChanged(),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Communication Settings Section
            _buildSectionHeader('Communication Settings', Icons.message),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Enable Email Receipts'),
              subtitle: const Text('Send receipts via email'),
              value: _enableEmailReceipts,
              onChanged: (value) {
                setState(() => _enableEmailReceipts = value);
                _markAsChanged();
              },
            ),
            
            SwitchListTile(
              title: const Text('Enable WhatsApp Receipts'),
              subtitle: const Text('Send receipts via WhatsApp'),
              value: _enableWhatsAppReceipts,
              onChanged: (value) {
                setState(() => _enableWhatsAppReceipts = value);
                _markAsChanged();
              },
            ),
            
            const SizedBox(height: 32),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _hasChanges ? _saveSettings : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(
                        'Save Business Settings',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey[700], size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
