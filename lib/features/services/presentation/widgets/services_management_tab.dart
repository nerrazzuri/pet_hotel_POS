import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/services/domain/entities/service.dart';
import 'package:cat_hotel_pos/core/services/service_dao.dart';

class ServicesManagementTab extends ConsumerStatefulWidget {
  const ServicesManagementTab({super.key});

  @override
  ConsumerState<ServicesManagementTab> createState() => _ServicesManagementTabState();
}

class _ServicesManagementTabState extends ConsumerState<ServicesManagementTab> {
  final ServiceDao _serviceDao = ServiceDao();
  List<Service> _services = [];
  List<Service> _filteredServices = [];
  ServiceCategory? _selectedCategory;
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _isLoading = true);
    try {
      final services = await _serviceDao.getAll();
      setState(() {
        _services = services;
        _filteredServices = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading services: $e')),
        );
      }
    }
  }

  void _filterServices() {
    setState(() {
      _filteredServices = _services.where((service) {
        final matchesCategory = _selectedCategory == null || service.category == _selectedCategory;
        final matchesSearch = _searchQuery.isEmpty ||
            service.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            service.serviceCode.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (service.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Services Management',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddEditServiceDialog(context),
                icon: const Icon(Icons.add),
                label: const Text('Add Service'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filters
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filters',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Search Services',
                            hintText: 'Search by name, code, or description',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            _searchQuery = value;
                            _filterServices();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      DropdownButtonFormField<ServiceCategory>(
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        value: _selectedCategory,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Categories'),
                          ),
                          ...ServiceCategory.values.map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category.name.toUpperCase()),
                          )),
                        ],
                        onChanged: (value) {
                          _selectedCategory = value;
                          _filterServices();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Services List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredServices.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.miscellaneous_services, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'No services found',
                              style: TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredServices.length,
                        itemBuilder: (context, index) {
                          final service = _filteredServices[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getCategoryColor(service.category),
                                child: Icon(
                                  _getCategoryIcon(service.category),
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                service.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(service.serviceCode),
                                  if (service.description != null)
                                    Text(
                                      service.description!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  Row(
                                    children: [
                                      Chip(
                                        label: Text(service.category.name.toUpperCase()),
                                        backgroundColor: _getCategoryColor(service.category).withOpacity(0.2),
                                        labelStyle: TextStyle(
                                          color: _getCategoryColor(service.category),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (service.duration != null)
                                        Chip(
                                          label: Text('${service.duration} min'),
                                          backgroundColor: Colors.blue.withOpacity(0.2),
                                          labelStyle: const TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '\$${service.price.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () => _showAddEditServiceDialog(context, service: service),
                                        icon: const Icon(Icons.edit, color: Colors.blue),
                                        tooltip: 'Edit',
                                      ),
                                      IconButton(
                                        onPressed: () => _deleteService(service),
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                        tooltip: 'Delete',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.grooming:
        return Colors.purple;
      case ServiceCategory.training:
        return Colors.orange;
      case ServiceCategory.wellness:
        return Colors.green;
      case ServiceCategory.medical:
        return Colors.red;
      case ServiceCategory.daycare:
        return Colors.blue;
      case ServiceCategory.addOns:
        return Colors.teal;
      case ServiceCategory.retail:
        return Colors.indigo;
      case ServiceCategory.boarding:
        return Colors.brown;
    }
  }

  IconData _getCategoryIcon(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.grooming:
        return Icons.content_cut;
      case ServiceCategory.training:
        return Icons.school;
      case ServiceCategory.wellness:
        return Icons.favorite;
      case ServiceCategory.medical:
        return Icons.medical_services;
      case ServiceCategory.daycare:
        return Icons.child_care;
      case ServiceCategory.addOns:
        return Icons.add_circle;
      case ServiceCategory.retail:
        return Icons.store;
      case ServiceCategory.boarding:
        return Icons.hotel;
    }
  }

  Future<void> _showAddEditServiceDialog(BuildContext context, {Service? service}) async {
    final isEditing = service != null;
    final nameController = TextEditingController(text: service?.name ?? '');
    final codeController = TextEditingController(text: service?.serviceCode ?? '');
    final descriptionController = TextEditingController(text: service?.description ?? '');
    final priceController = TextEditingController(text: service?.price.toString() ?? '');
    final durationController = TextEditingController(text: service?.duration?.toString() ?? '');
    
    ServiceCategory selectedCategory = service?.category ?? ServiceCategory.grooming;
    bool isActive = service?.isActive ?? true;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Service' : 'Add New Service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Service Name'),
              ),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Service Code'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<ServiceCategory>(
                decoration: const InputDecoration(labelText: 'Category'),
                value: selectedCategory,
                items: ServiceCategory.values.map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category.name.toUpperCase()),
                )).toList(),
                onChanged: (value) => selectedCategory = value!,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: isActive,
                    onChanged: (value) => isActive = value!,
                  ),
                  const Text('Active'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final newService = Service(
                  id: service?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  serviceCode: codeController.text,
                  name: nameController.text,
                  category: selectedCategory,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  isActive: isActive,
                  createdAt: service?.createdAt ?? DateTime.now(),
                  updatedAt: DateTime.now(),
                  description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                  duration: int.tryParse(durationController.text),
                );

                if (isEditing) {
                  await _serviceDao.update(newService);
                } else {
                  await _serviceDao.insert(newService);
                }

                Navigator.of(context).pop();
                _loadServices();
                _filterServices();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Service ${isEditing ? 'updated' : 'added'} successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteService(Service service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _serviceDao.delete(service.id);
        _loadServices();
        _filterServices();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting service: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
