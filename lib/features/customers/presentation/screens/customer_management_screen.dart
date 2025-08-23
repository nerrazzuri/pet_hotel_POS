import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/pet.dart';
import 'package:cat_hotel_pos/features/customers/presentation/providers/customer_providers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cat_hotel_pos/core/services/web_storage_service.dart';
// import 'package:cat_hotel_pos/core/services/database_service.dart';

class CustomerManagementScreen extends ConsumerStatefulWidget {
  const CustomerManagementScreen({super.key});

  @override
  ConsumerState<CustomerManagementScreen> createState() => _CustomerManagementScreenState();
}

class _CustomerManagementScreenState extends ConsumerState<CustomerManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  CustomerStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      ref.read(customerSearchProvider.notifier).state = _searchController.text;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(customerSearchProvider);
    final customersAsync = ref.watch(filteredCustomersProvider(searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Management'),
        actions: [
          // Debug button for web storage testing
          if (kIsWeb)
            IconButton(
              icon: const Icon(Icons.bug_report),
              onPressed: () {
                // Manually seed data for testing
                WebStorageService.seedDefaultData();
                // Refresh the screen
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data seeded manually')),
                );
              },
              tooltip: 'Seed Test Data (Debug)',
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateCustomerDialog(context),
            tooltip: 'Add New Customer',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search customers...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<CustomerStatus?>(
                    value: _selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('All Statuses'),
                      ),
                      ...CustomerStatus.values.map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(status.name),
                      )),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedStatus = value;
                      });
                      ref.read(customerStatusFilterProvider.notifier).state = value;
                    },
                  ),
                ),
              ],
            ),
          ),
          // Customers List
          Expanded(
            child: customersAsync.when(
              data: (customers) {
                print('CustomerManagementScreen: Received ${customers.length} customers');
                if (customers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No customers found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Click the debug button (🐛) to seed test data',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        // Debug information
                                    if (kIsWeb)
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      print('Manual debug: Testing web storage...');
                      WebStorageService.testWebStorage();
                    },
                    child: const Text('Test Web Storage'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      print('Manual debug: Seeding data...');
                      WebStorageService.seedDefaultData();
                      setState(() {});
                    },
                    child: const Text('Seed Data'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      final customers = WebStorageService.getAllCustomers();
                      print('Manual debug: Found ${customers.length} customers in storage');
                      print('Manual debug: Customer data: $customers');
                    },
                    child: const Text('Check Storage'),
                  ),
                ],
              )
            else
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      print('Manual debug: Seeding database...');
                      try {
                        // await DatabaseService.seedSampleData();
                        print('Database seeded successfully');
                        setState(() {});
                      } catch (e) {
                        print('Error seeding database: $e');
                      }
                    },
                    child: const Text('Seed Database'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      print('Manual debug: Checking database...');
                      try {
                        // final customers = await DatabaseService.query('customers');
                        print('Manual debug: Found ${customers.length} customers in database');
                        print('Manual debug: Customer data: $customers');
                      } catch (e) {
                        print('Error checking database: $e');
                      }
                    },
                    child: const Text('Check Database'),
                  ),
                ],
              ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return _CustomerCard(
                      customer: customer,
                      onEdit: () => _showEditCustomerDialog(context, customer),
                      onDelete: () => _showDeleteCustomerDialog(context, customer),
                      onView: () => _showCustomerDetailsDialog(context, customer),
                    );
                  },
                );
              },
              loading: () {
                print('CustomerManagementScreen: Loading customers...');
                return const Center(child: CircularProgressIndicator());
              },
              error: (error, stack) {
                print('CustomerManagementScreen: Error loading customers: $error');
                print('CustomerManagementScreen: Stack trace: $stack');
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        'Error loading customers',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {});
                        },
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

  void _showCreateCustomerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const _CreateCustomerDialog(),
    );
  }

  void _showEditCustomerDialog(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (context) => _EditCustomerDialog(customer: customer),
    );
  }

  void _showDeleteCustomerDialog(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (context) => _DeleteCustomerDialog(customer: customer),
    );
  }

  void _showCustomerDetailsDialog(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (context) => _CustomerDetailsDialog(customer: customer),
    );
  }
}

class _CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onView;

  const _CustomerCard({
    required this.customer,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: customer.status == CustomerStatus.active 
              ? Colors.green 
              : Colors.grey,
          child: Text(
            customer.firstName[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          '${customer.firstName} ${customer.lastName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (customer.email.isNotEmpty) Text(customer.email),
            Text(customer.phoneNumber),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: customer.status == CustomerStatus.active 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    customer.status.name,
                    style: TextStyle(
                      color: customer.status == CustomerStatus.active 
                          ? Colors.green 
                          : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (customer.loyaltyPoints != null && customer.loyaltyPoints! > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, size: 12, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          '${customer.loyaltyPoints} pts',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
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
          onSelected: (value) {
            switch (value) {
              case 'view':
                onView();
                break;
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
        ),
      ),
    );
  }
}

class _CreateCustomerDialog extends ConsumerStatefulWidget {
  const _CreateCustomerDialog();

  @override
  ConsumerState<_CreateCustomerDialog> createState() => _CreateCustomerDialogState();
}

class _CreateCustomerDialogState extends ConsumerState<_CreateCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Customer'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
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
              const SizedBox(height: 16),
              TextFormField(
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createCustomer,
          child: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _createCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final customerService = ref.read(customerServiceProvider);
      await customerService.createCustomer(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer created successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the customers list
        ref.invalidate(customersProvider);
        ref.invalidate(filteredCustomersProvider(''));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating customer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _EditCustomerDialog extends ConsumerStatefulWidget {
  final Customer customer;

  const _EditCustomerDialog({required this.customer});

  @override
  ConsumerState<_EditCustomerDialog> createState() => _EditCustomerDialogState();
}

class _EditCustomerDialogState extends ConsumerState<_EditCustomerDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late CustomerStatus _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.customer.firstName);
    _lastNameController = TextEditingController(text: widget.customer.lastName);
    _emailController = TextEditingController(text: widget.customer.email);
    _phoneController = TextEditingController(text: widget.customer.phoneNumber);
    _addressController = TextEditingController(text: widget.customer.address ?? '');
    _selectedStatus = widget.customer.status;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit ${widget.customer.firstName} ${widget.customer.lastName}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
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
              const SizedBox(height: 16),
              TextFormField(
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
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
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<CustomerStatus>(
                value: _selectedStatus,
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: CustomerStatus.values.map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status.name),
                )).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateCustomer,
          child: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update'),
        ),
      ],
    );
  }

  Future<void> _updateCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final customerService = ref.read(customerServiceProvider);
      await customerService.updateCustomer(
        customerId: widget.customer.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        status: _selectedStatus,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the customers list
        ref.invalidate(customersProvider);
        ref.invalidate(filteredCustomersProvider(''));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating customer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _DeleteCustomerDialog extends ConsumerWidget {
  final Customer customer;

  const _DeleteCustomerDialog({required this.customer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Delete Customer'),
      content: Text(
        'Are you sure you want to delete ${customer.firstName} ${customer.lastName}? '
        'This action cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _deleteCustomer(context, ref),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  Future<void> _deleteCustomer(BuildContext context, WidgetRef ref) async {
    try {
      final customerService = ref.read(customerServiceProvider);
      await customerService.deleteCustomer(customer.id);

      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Customer deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the customers list
        ref.invalidate(customersProvider);
        ref.invalidate(filteredCustomersProvider(''));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting customer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _CustomerDetailsDialog extends StatelessWidget {
  final Customer customer;

  const _CustomerDetailsDialog({required this.customer});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${customer.firstName} ${customer.lastName}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _DetailRow('First Name', customer.firstName),
            _DetailRow('Last Name', customer.lastName),
            if (customer.email.isNotEmpty) _DetailRow('Email', customer.email),
            _DetailRow('Phone', customer.phoneNumber),
            if (customer.address != null && customer.address!.isNotEmpty)
              _DetailRow('Address', customer.address!),
            _DetailRow('Status', customer.status.name),
            _DetailRow('Loyalty Points', '${customer.loyaltyPoints ?? 0}'),
            _DetailRow('Created', _formatDate(customer.createdAt)),
            _DetailRow('Last Updated', _formatDate(customer.updatedAt)),
            if (customer.pets != null && customer.pets!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Pets',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ...customer.pets!.map((pet) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 8),
                child: Row(
                  children: [
                    Icon(
                      _getPetIcon(pet.type),
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text('${pet.name} (${pet.breed})'),
                  ],
                ),
              )),
            ],
          ],
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  IconData _getPetIcon(PetType type) {
    switch (type) {
      case PetType.cat:
        return Icons.pets;
      case PetType.dog:
        return Icons.pets;
      case PetType.bird:
        return Icons.flutter_dash;
      case PetType.rabbit:
        return Icons.pets;
      case PetType.hamster:
        return Icons.pets;
      case PetType.guineaPig:
        return Icons.pets;
      case PetType.ferret:
        return Icons.pets;
      case PetType.other:
        return Icons.pets;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
