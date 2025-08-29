import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';

class CustomerRegistrationForm extends ConsumerStatefulWidget {
  final Customer? customer; // If provided, this is an edit form
  final Function(Customer) onSave;
  final VoidCallback onCancel;

  const CustomerRegistrationForm({
    super.key,
    this.customer,
    required this.onSave,
    required this.onCancel,
  });

  @override
  ConsumerState<CustomerRegistrationForm> createState() => _CustomerRegistrationFormState();
}

class _CustomerRegistrationFormState extends ConsumerState<CustomerRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Form values
  CustomerStatus _status = CustomerStatus.active;
  CustomerSource _source = CustomerSource.walkIn;
  LoyaltyTier? _loyaltyTier;
  DateTime? _dateOfBirth;
  bool _isActive = true;
  
  // Emergency contacts
  final List<Map<String, TextEditingController>> _emergencyContacts = [];
  
  @override
  void initState() {
    super.initState();
    _initializeForm();
  }
  
  void _initializeForm() {
    if (widget.customer != null) {
      // Edit mode - populate with existing data
      final customer = widget.customer!;
      _firstNameController.text = customer.firstName;
      _lastNameController.text = customer.lastName;
      _emailController.text = customer.email;
      _phoneController.text = customer.phoneNumber;
      _addressController.text = customer.address ?? '';
      _cityController.text = customer.city ?? '';
      _stateController.text = customer.state ?? '';
      _zipCodeController.text = customer.zipCode ?? '';
      _countryController.text = customer.country ?? '';
      _notesController.text = customer.notes ?? '';
      _status = customer.status;
      _source = customer.source;
      _loyaltyTier = customer.loyaltyTier;
      _dateOfBirth = customer.dateOfBirth;
      _isActive = customer.isActive ?? true;
      
      // Initialize emergency contacts
      if (customer.emergencyContacts != null) {
        for (final contact in customer.emergencyContacts!) {
          _emergencyContacts.add({
            'name': TextEditingController(text: contact.name),
            'relationship': TextEditingController(text: contact.relationship),
            'phone': TextEditingController(text: contact.phoneNumber),
            'email': TextEditingController(text: contact.email ?? ''),
          });
        }
      }
    } else {
      // Add mode - add one empty emergency contact
      _addEmergencyContact();
    }
  }
  
  void _addEmergencyContact() {
    setState(() {
      _emergencyContacts.add({
        'name': TextEditingController(),
        'relationship': TextEditingController(),
        'phone': TextEditingController(),
        'email': TextEditingController(),
      });
    });
  }
  
  void _removeEmergencyContact(int index) {
    setState(() {
      _emergencyContacts.removeAt(index);
    });
  }
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _notesController.dispose();
    
    for (final contact in _emergencyContacts) {
      contact.values.forEach((controller) => controller.dispose());
    }
    
    super.dispose();
  }
  
  Future<void> _selectDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth ?? DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateOfBirth = picked;
      });
    }
  }
  
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      // Create emergency contacts
      final emergencyContacts = _emergencyContacts
          .where((contact) => contact['name']!.text.isNotEmpty)
          .map((contact) => EmergencyContact(
                id: 'ec_${DateTime.now().millisecondsSinceEpoch}',
                name: contact['name']!.text,
                relationship: contact['relationship']!.text,
                phoneNumber: contact['phone']!.text,
                email: contact['email']!.text.isNotEmpty ? contact['email']!.text : null,
                customerId: widget.customer?.id ?? 'temp_id',
              ))
          .toList();
      
      // Create or update customer
      final customer = Customer(
        id: widget.customer?.id ?? 'cust_${DateTime.now().millisecondsSinceEpoch}',
        customerCode: widget.customer?.customerCode ?? 'CUST${DateTime.now().millisecondsSinceEpoch}',
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        status: _status,
        source: _source,
        createdAt: widget.customer?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        address: _addressController.text.trim().isNotEmpty ? _addressController.text.trim() : null,
        city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
        state: _stateController.text.trim().isNotEmpty ? _stateController.text.trim() : null,
        zipCode: _zipCodeController.text.trim().isNotEmpty ? _zipCodeController.text.trim() : null,
        country: _countryController.text.trim().isNotEmpty ? _countryController.text.trim() : null,
        dateOfBirth: _dateOfBirth,
        loyaltyTier: _loyaltyTier,
        lastVisitDate: widget.customer?.lastVisitDate,
        totalSpent: widget.customer?.totalSpent ?? 0.0,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        emergencyContacts: emergencyContacts.isNotEmpty ? emergencyContacts : null,
        isActive: _isActive,
        pets: widget.customer?.pets, // Preserve existing pets
      );
      
      widget.onSave(customer);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditMode = widget.customer != null;
    
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  isEditMode ? Icons.edit : Icons.person_add,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  isEditMode ? 'Edit Customer' : 'New Customer Registration',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Personal Information Section
            _buildSectionHeader(theme, 'Personal Information', Icons.person),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'First name is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Last name is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectDateOfBirth,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _dateOfBirth != null
                            ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                            : 'Select date',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<CustomerStatus>(
                    decoration: const InputDecoration(
                      labelText: 'Status *',
                      border: OutlineInputBorder(),
                    ),
                    value: _status,
                    items: CustomerStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.displayName),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _status = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Address Section
            _buildSectionHeader(theme, 'Address Information', Icons.location_on),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Street Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State/Province',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _zipCodeController,
                    decoration: const InputDecoration(
                      labelText: 'ZIP/Postal Code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'Country',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Business Information Section
            _buildSectionHeader(theme, 'Business Information', Icons.business),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<CustomerSource>(
                    decoration: const InputDecoration(
                      labelText: 'Customer Source *',
                      border: OutlineInputBorder(),
                    ),
                    value: _source,
                    items: CustomerSource.values.map((source) => DropdownMenuItem(
                      value: source,
                      child: Text(source.displayName),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _source = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<LoyaltyTier?>(
                    decoration: const InputDecoration(
                      labelText: 'Loyalty Tier',
                      border: OutlineInputBorder(),
                    ),
                    value: _loyaltyTier,
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('None'),
                      ),
                      ...LoyaltyTier.values.map((tier) => DropdownMenuItem(
                        value: tier,
                        child: Text(tier.name),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _loyaltyTier = value;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Active Customer'),
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value ?? true;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Emergency Contacts Section
            _buildSectionHeader(theme, 'Emergency Contacts', Icons.emergency),
            const SizedBox(height: 16),
            
            ..._emergencyContacts.asMap().entries.map((entry) {
              final index = entry.key;
              final contact = entry.value;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Emergency Contact ${index + 1}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (_emergencyContacts.length > 1)
                          IconButton(
                            onPressed: () => _removeEmergencyContact(index),
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            tooltip: 'Remove contact',
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: contact['name']!,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: contact['relationship']!,
                            decoration: const InputDecoration(
                              labelText: 'Relationship',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: contact['phone']!,
                            decoration: const InputDecoration(
                              labelText: 'Phone Number',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: contact['email']!,
                            decoration: const InputDecoration(
                              labelText: 'Email (Optional)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            
            // Add Emergency Contact Button
            Center(
              child: OutlinedButton.icon(
                onPressed: _addEmergencyContact,
                icon: const Icon(Icons.add),
                label: const Text('Add Emergency Contact'),
              ),
            ),
            const SizedBox(height: 24),
            
            // Notes Section
            _buildSectionHeader(theme, 'Additional Information', Icons.note),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                hintText: 'Any additional information about the customer...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveForm,
                  child: Text(isEditMode ? 'Update Customer' : 'Create Customer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
