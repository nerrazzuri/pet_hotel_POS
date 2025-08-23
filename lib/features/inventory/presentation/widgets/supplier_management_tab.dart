import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/supplier.dart';
import '../providers/supplier_providers.dart';

class SupplierManagementTab extends ConsumerStatefulWidget {
  const SupplierManagementTab({super.key});

  @override
  ConsumerState<SupplierManagementTab> createState() => _SupplierManagementTabState();
}

class _SupplierManagementTabState extends ConsumerState<SupplierManagementTab> {
  final TextEditingController _searchController = TextEditingController();
  bool _showActiveOnly = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(supplierSearchQueryProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(filteredSuppliersProvider);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          _buildHeader(),
          const SizedBox(height: 24),
          
          // Search and Filter Bar
          _buildSearchAndFilter(),
          const SizedBox(height: 16),
          
          // Suppliers List
          Expanded(
            child: suppliersAsync.when(
              data: (suppliers) {
                print('SupplierManagementTab: Received ${suppliers.length} suppliers');
                if (suppliers.isEmpty) {
                  return _buildEmptyState();
                }
                return _buildSuppliersList(suppliers);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) {
                print('SupplierManagementTab: Error loading suppliers: $error');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error loading suppliers: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(filteredSuppliersProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Supplier Management',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.teal[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Manage your suppliers and vendor relationships',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => _showCreateSupplierDialog(),
          icon: const Icon(Icons.add_business),
          label: const Text('Add Supplier'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search suppliers...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        FilterChip(
          label: Text(_showActiveOnly ? 'Active Only' : 'All'),
          selected: _showActiveOnly,
          onSelected: (selected) {
            setState(() {
              _showActiveOnly = selected;
            });
            ref.read(supplierStatusFilterProvider.notifier).state = selected;
          },
          backgroundColor: Colors.grey[200],
          selectedColor: Colors.teal[100],
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No suppliers found',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first supplier to get started',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateSupplierDialog(),
            icon: const Icon(Icons.add_business),
            label: const Text('Add Supplier'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuppliersList(List<Supplier> suppliers) {
    return ListView.builder(
      itemCount: suppliers.length,
      itemBuilder: (context, index) {
        final supplier = suppliers[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: supplier.isActive ? Colors.teal : Colors.grey,
              child: Text(
                supplier.name.isNotEmpty ? supplier.name[0].toUpperCase() : '?',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              supplier.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (supplier.companyName != null) Text(supplier.companyName!),
                if (supplier.email != null) Text(supplier.email!),
                if (supplier.phone != null) Text(supplier.phone!),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Chip(
                  label: Text(supplier.isActive ? 'Active' : 'Inactive'),
                  backgroundColor: supplier.isActive ? Colors.green[100] : Colors.grey[300],
                  labelStyle: TextStyle(
                    color: supplier.isActive ? Colors.green[800] : Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleSupplierAction(value, supplier),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit'),
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'view',
                      child: ListTile(
                        leading: Icon(Icons.visibility),
                        title: Text('View Details'),
                        dense: true,
                      ),
                    ),
                    if (supplier.isActive)
                      const PopupMenuItem(
                        value: 'deactivate',
                        child: ListTile(
                          leading: Icon(Icons.block, color: Colors.red),
                          title: Text('Deactivate'),
                          dense: true,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            onTap: () => _showSupplierDetails(supplier),
          ),
        );
      },
    );
  }

  void _handleSupplierAction(String action, Supplier supplier) {
    switch (action) {
      case 'edit':
        _showEditSupplierDialog(supplier);
        break;
      case 'view':
        _showSupplierDetails(supplier);
        break;
      case 'deactivate':
        _confirmDeactivateSupplier(supplier);
        break;
    }
  }

  void _showCreateSupplierDialog() {
    showDialog(
      context: context,
      builder: (context) => const _SupplierFormDialog(),
    ).then((_) {
      // Refresh the suppliers list
      ref.invalidate(filteredSuppliersProvider);
    });
  }

  void _showEditSupplierDialog(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => _SupplierFormDialog(supplier: supplier),
    ).then((_) {
      // Refresh the suppliers list
      ref.invalidate(filteredSuppliersProvider);
    });
  }

  void _showSupplierDetails(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => _SupplierDetailsDialog(supplier: supplier),
    );
  }

  void _confirmDeactivateSupplier(Supplier supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deactivate Supplier'),
        content: Text('Are you sure you want to deactivate "${supplier.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(supplierFormProvider.notifier).deactivateSupplier(supplier.id);
              ref.invalidate(filteredSuppliersProvider);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${supplier.name} has been deactivated')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }
}

// Supplier Form Dialog
class _SupplierFormDialog extends ConsumerStatefulWidget {
  final Supplier? supplier;

  const _SupplierFormDialog({this.supplier});

  @override
  ConsumerState<_SupplierFormDialog> createState() => _SupplierFormDialogState();
}

class _SupplierFormDialogState extends ConsumerState<_SupplierFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();
  final _websiteController = TextEditingController();
  final _taxIdController = TextEditingController();
  final _paymentTermsController = TextEditingController();
  final _creditLimitController = TextEditingController();
  final _notesController = TextEditingController();

  bool get isEditing => widget.supplier != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      final supplier = widget.supplier!;
      _nameController.text = supplier.name;
      _companyController.text = supplier.companyName ?? '';
      _contactPersonController.text = supplier.contactPerson ?? '';
      _emailController.text = supplier.email ?? '';
      _phoneController.text = supplier.phone ?? '';
      _addressController.text = supplier.address ?? '';
      _cityController.text = supplier.city ?? '';
      _stateController.text = supplier.state ?? '';
      _zipController.text = supplier.postalCode ?? '';
      _countryController.text = supplier.country ?? '';
      _websiteController.text = supplier.website ?? '';
      _taxIdController.text = supplier.taxId ?? '';
      _paymentTermsController.text = supplier.paymentTerms ?? '';
      _creditLimitController.text = supplier.creditLimit?.toString() ?? '';
      _notesController.text = supplier.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _contactPersonController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    _websiteController.dispose();
    _taxIdController.dispose();
    _paymentTermsController.dispose();
    _creditLimitController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(supplierFormProvider);

    return AlertDialog(
      title: Text(isEditing ? 'Edit Supplier' : 'Add New Supplier'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Supplier Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter supplier name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _companyController,
                  decoration: const InputDecoration(
                    labelText: 'Company Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactPersonController,
                  decoration: const InputDecoration(
                    labelText: 'Contact Person',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty && !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
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
                          labelText: 'State',
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
                        controller: _zipController,
                        decoration: const InputDecoration(
                          labelText: 'ZIP Code',
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                if (formState.error != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    formState.error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: formState.isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: formState.isLoading ? null : _submitForm,
          child: formState.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isEditing ? 'Update' : 'Create'),
        ),
      ],
    );
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final creditLimit = _creditLimitController.text.isNotEmpty 
        ? double.tryParse(_creditLimitController.text) 
        : null;

    if (isEditing) {
      await ref.read(supplierFormProvider.notifier).updateSupplier(
        supplierId: widget.supplier!.id,
        name: _nameController.text,
        companyName: _companyController.text.isNotEmpty ? _companyController.text : null,
        contactPerson: _contactPersonController.text.isNotEmpty ? _contactPersonController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        city: _cityController.text.isNotEmpty ? _cityController.text : null,
        stateValue: _stateController.text.isNotEmpty ? _stateController.text : null,
        zipCode: _zipController.text.isNotEmpty ? _zipController.text : null,
        country: _countryController.text.isNotEmpty ? _countryController.text : null,
        website: _websiteController.text.isNotEmpty ? _websiteController.text : null,
        taxId: _taxIdController.text.isNotEmpty ? _taxIdController.text : null,
        paymentTerms: _paymentTermsController.text.isNotEmpty ? _paymentTermsController.text : null,
        creditLimit: creditLimit,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );
    } else {
      await ref.read(supplierFormProvider.notifier).createSupplier(
        name: _nameController.text,
        companyName: _companyController.text.isNotEmpty ? _companyController.text : null,
        contactPerson: _contactPersonController.text.isNotEmpty ? _contactPersonController.text : null,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
        phone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
        address: _addressController.text.isNotEmpty ? _addressController.text : null,
        city: _cityController.text.isNotEmpty ? _cityController.text : null,
        stateValue: _stateController.text.isNotEmpty ? _stateController.text : null,
        zipCode: _zipController.text.isNotEmpty ? _zipController.text : null,
        country: _countryController.text.isNotEmpty ? _countryController.text : null,
        website: _websiteController.text.isNotEmpty ? _websiteController.text : null,
        taxId: _taxIdController.text.isNotEmpty ? _taxIdController.text : null,
        paymentTerms: _paymentTermsController.text.isNotEmpty ? _paymentTermsController.text : null,
        creditLimit: creditLimit,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );
    }

    final currentState = ref.read(supplierFormProvider);
    if (currentState.isSuccess && mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Supplier updated successfully' : 'Supplier created successfully'),
        ),
      );
      ref.read(supplierFormProvider.notifier).resetState();
    }
  }
}

// Supplier Details Dialog
class _SupplierDetailsDialog extends StatelessWidget {
  final Supplier supplier;

  const _SupplierDetailsDialog({required this.supplier});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(supplier.name),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Company', supplier.companyName),
              _buildDetailRow('Contact Person', supplier.contactPerson),
              _buildDetailRow('Email', supplier.email),
              _buildDetailRow('Phone', supplier.phone),
              _buildDetailRow('Address', supplier.address),
              _buildDetailRow('City', supplier.city),
              _buildDetailRow('State', supplier.state),
              _buildDetailRow('Postal Code', supplier.postalCode),
              _buildDetailRow('Country', supplier.country),
              _buildDetailRow('Website', supplier.website),
              _buildDetailRow('Tax ID', supplier.taxId),
              _buildDetailRow('Payment Terms', supplier.paymentTerms),
              _buildDetailRow('Credit Limit', supplier.creditLimit?.toString()),
              _buildDetailRow('Status', supplier.isActive ? 'Active' : 'Inactive'),
              _buildDetailRow('Created', supplier.createdAt.toString().split('.')[0]),
              _buildDetailRow('Updated', supplier.updatedAt.toString().split('.')[0]),
              if (supplier.notes != null) _buildDetailRow('Notes', supplier.notes),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
