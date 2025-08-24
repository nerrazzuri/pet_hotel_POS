import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/services/domain/entities/service.dart';
import 'package:cat_hotel_pos/features/services/domain/entities/product.dart';
import 'package:cat_hotel_pos/core/services/service_dao.dart';
import 'package:cat_hotel_pos/features/services/presentation/widgets/services_management_tab.dart';
import 'package:cat_hotel_pos/core/services/product_dao.dart';
import 'package:cat_hotel_pos/core/services/service_package_dao.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _errorMessage;
  List<Service> _services = [];
  List<Product> _products = [];
  List<dynamic> _packages = []; // Using dynamic since ServicePackage might not exist
  
  // Phase B: Add filtering state management
  List<Service> _filteredServices = [];
  ServiceCategory? _selectedCategory;
  String _searchQuery = '';

  // Product management state
  String _productSearchQuery = '';
  ProductCategory? _selectedProductCategory;
  ProductStatus? _selectedProductStatus;
  List<Product> _filteredProducts = [];

  // Package management state
  String _packageSearchQuery = '';
  String? _selectedPackageType;
  List<Map<String, dynamic>> _filteredPackages = [];
  bool _isGridView = false;
  
  // Mock package data - In real app, this would come from ServicePackageDao
  List<Map<String, dynamic>> _mockPackages = [
    {
      'id': '1',
      'name': 'Premium Spa Package',
      'type': 'grooming',
      'description': 'Complete grooming and spa experience for your pet',
      'services': ['Bath & Blow Dry', 'Nail Trim', 'Ear Cleaning', 'Aromatherapy'],
      'originalPrice': 120.0,
      'packagePrice': 89.99,
      'savings': 30.01,
      'duration': 180,
      'isActive': true,
      'isPopular': true,
      'bookings': 45,
      'rating': 4.8,
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
    },
    {
      'id': '2',
      'name': 'Wellness Check Bundle',
      'type': 'wellness',
      'description': 'Complete health and wellness package',
      'services': ['Health Check', 'Vaccination', 'Dental Cleaning', 'Weight Assessment'],
      'originalPrice': 200.0,
      'packagePrice': 159.99,
      'savings': 40.01,
      'duration': 120,
      'isActive': true,
      'isPopular': true,
      'bookings': 32,
      'rating': 4.9,
      'createdAt': DateTime.now().subtract(const Duration(days: 45)),
    },
    {
      'id': '3',
      'name': 'Basic Care Package',
      'type': 'basic',
      'description': 'Essential care services for your pet',
      'services': ['Basic Bath', 'Nail Trim', 'Basic Health Check'],
      'originalPrice': 80.0,
      'packagePrice': 59.99,
      'savings': 20.01,
      'duration': 90,
      'isActive': true,
      'isPopular': false,
      'bookings': 28,
      'rating': 4.5,
      'createdAt': DateTime.now().subtract(const Duration(days: 15)),
    },
    {
      'id': '4',
      'name': 'Luxury Boarding Experience',
      'type': 'boarding',
      'description': 'Premium boarding with extra care and attention',
      'services': ['Private Suite', 'Daily Walks', 'Playtime', 'Gourmet Meals'],
      'originalPrice': 300.0,
      'packagePrice': 249.99,
      'savings': 50.01,
      'duration': 1440, // 24 hours
      'isActive': true,
      'isPopular': true,
      'bookings': 18,
      'rating': 4.7,
      'createdAt': DateTime.now().subtract(const Duration(days: 60)),
    },
    {
      'id': '5',
      'name': 'Weekend Getaway Package',
      'type': 'premium',
      'description': 'Perfect weekend package for busy pet owners',
      'services': ['Extended Boarding', 'Grooming', 'Exercise Sessions', 'Photo Updates'],
      'originalPrice': 180.0,
      'packagePrice': 139.99,
      'savings': 40.01,
      'duration': 2880, // 48 hours
      'isActive': false,
      'isPopular': false,
      'bookings': 12,
      'rating': 4.3,
      'createdAt': DateTime.now().subtract(const Duration(days: 10)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Delay data loading to ensure proper initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBasicData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBasicData() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Add a small delay to ensure all services are ready
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Load basic data using correct DAO methods
      final serviceDao = ServiceDao();
      final productDao = ProductDao();
      final packageDao = ServicePackageDao();
      
      // Test basic data loading operations
      final services = await serviceDao.getAll();
      final products = await productDao.getAll();
      final packages = await packageDao.getAll();
      
      if (mounted) {
        setState(() {
          _services = services;
          _products = products;
          _packages = packages;
          _filteredServices = services; // Initialize filtered services
          _filteredProducts = products; // Initialize filtered products
          _filteredPackages = _mockPackages; // Initialize filtered packages
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Product filtering logic
  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        bool matchesSearch = _productSearchQuery.isEmpty ||
            product.name.toLowerCase().contains(_productSearchQuery.toLowerCase()) ||
            product.productCode.toLowerCase().contains(_productSearchQuery.toLowerCase()) ||
            (product.description?.toLowerCase().contains(_productSearchQuery.toLowerCase()) ?? false);

        bool matchesCategory = _selectedProductCategory == null ||
            product.category == _selectedProductCategory;

        bool matchesStatus = _selectedProductStatus == null ||
            product.status == _selectedProductStatus;

        return matchesSearch && matchesCategory && matchesStatus;
      }).toList();
    });
  }

  // Package filtering logic
  void _filterPackages() {
    setState(() {
      _filteredPackages = _mockPackages.where((package) {
        bool matchesSearch = _packageSearchQuery.isEmpty ||
            package['name'].toString().toLowerCase().contains(_packageSearchQuery.toLowerCase()) ||
            package['description'].toString().toLowerCase().contains(_packageSearchQuery.toLowerCase()) ||
            (package['services'] as List).any((service) => 
                service.toString().toLowerCase().contains(_packageSearchQuery.toLowerCase()));

        bool matchesType = _selectedPackageType == null ||
            package['type'] == _selectedPackageType;

        return matchesSearch && matchesType;
      }).toList();
    });
  }

  // Phase B: Add complex filtering logic
  void _filterServices() {
    if (_services.isEmpty) return;
    
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

  // Phase E: Add helper methods from original (potential issue?)
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

  // Handle service actions from popup menu
  void _handleServiceAction(String action, Service service) {
    switch (action) {
      case 'edit':
        _showEditServiceDialog(context, service);
        break;
      case 'duplicate':
        _duplicateService(service);
        break;
      case 'deactivate':
        _toggleServiceStatus(service);
        break;
      case 'delete':
        _showDeleteServiceDialog(context, service);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unknown action: $action'),
            backgroundColor: Colors.orange,
          ),
        );
    }
  }

  // Edit existing service
  Future<void> _showEditServiceDialog(BuildContext context, Service service) async {
    final nameController = TextEditingController(text: service.name);
    final codeController = TextEditingController(text: service.serviceCode);
    final descriptionController = TextEditingController(text: service.description ?? '');
    final priceController = TextEditingController(text: service.price.toString());
    final durationController = TextEditingController(text: service.duration?.toString() ?? '');
    
    ServiceCategory selectedCategory = service.category;
    bool isActive = service.isActive;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Service: ${service.name}'),
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
                // Update the service
                final updatedService = Service(
                  id: service.id,
                  serviceCode: codeController.text,
                  name: nameController.text,
                  category: selectedCategory,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  isActive: isActive,
                  createdAt: service.createdAt,
                  updatedAt: DateTime.now(),
                  description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                  duration: int.tryParse(durationController.text),
                );

                // Update in the list
                setState(() {
                  final index = _services.indexWhere((s) => s.id == service.id);
                  if (index != -1) {
                    _services[index] = updatedService;
                    _filterServices(); // Refresh filtered list
                  }
                });
                
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${service.name} updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating service: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Duplicate service
  void _duplicateService(Service service) {
    final duplicatedService = Service(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      serviceCode: '${service.serviceCode}_COPY',
      name: '${service.name} (Copy)',
      category: service.category,
      price: service.price,
      isActive: false, // Start as inactive
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: service.description,
      duration: service.duration,
    );

    setState(() {
      _services.add(duplicatedService);
      _filterServices(); // Refresh filtered list
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${service.name} duplicated successfully!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  // Toggle service status
  void _toggleServiceStatus(Service service) {
    setState(() {
      final index = _services.indexWhere((s) => s.id == service.id);
      if (index != -1) {
        // Create updated service with new status
        final updatedService = Service(
          id: _services[index].id,
          serviceCode: _services[index].serviceCode,
          name: _services[index].name,
          category: _services[index].category,
          price: _services[index].price,
          isActive: !_services[index].isActive,
          createdAt: _services[index].createdAt,
          updatedAt: DateTime.now(),
          description: _services[index].description,
          duration: _services[index].duration,
        );
        _services[index] = updatedService;
        _filterServices(); // Refresh filtered list
      }
    });

    final newStatus = !service.isActive ? 'activated' : 'deactivated';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${service.name} $newStatus successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Show delete confirmation dialog
  Future<void> _showDeleteServiceDialog(BuildContext context, Service service) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteService(service);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Delete service
  void _deleteService(Service service) {
    setState(() {
      _services.removeWhere((s) => s.id == service.id);
      _filterServices(); // Refresh filtered list
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${service.name} deleted successfully!'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // Show service history
  void _showServiceHistory(BuildContext context, Service service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Service History: ${service.name}'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHistoryItem('Created', service.createdAt, Icons.add_circle, Colors.green),
              if (service.updatedAt != service.createdAt)
                _buildHistoryItem('Last Updated', service.updatedAt, Icons.edit, Colors.blue),
              _buildHistoryItem('Status Changed', DateTime.now().subtract(const Duration(days: 2)), Icons.toggle_on, Colors.orange),
              _buildHistoryItem('Price Updated', DateTime.now().subtract(const Duration(days: 5)), Icons.attach_money, Colors.purple),
              const Divider(),
              const Text(
                'Recent Activities:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: [
                    _buildActivityItem('Service used in booking #1234', '2 hours ago', Icons.book_online),
                    _buildActivityItem('Customer feedback received', '1 day ago', Icons.feedback),
                    _buildActivityItem('Staff training completed', '3 days ago', Icons.school),
                    _buildActivityItem('Inventory check completed', '1 week ago', Icons.inventory),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Build history item
  Widget _buildHistoryItem(String title, DateTime date, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(
                  '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build activity item
  Widget _buildActivityItem(String title, String time, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[600], size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      subtitle: Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      dense: true,
    );
  }

  // Show service analytics
  void _showServiceAnalytics(BuildContext context, Service service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Service Analytics: ${service.name}'),
        content: SizedBox(
          width: 500,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Performance Overview
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Performance Overview',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                                                         child: _buildAnalyticsCard('Total Bookings', '24', Icons.book_online, Colors.blue),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildAnalyticsCard('Revenue', '\$1,200', Icons.attach_money, Colors.green),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildAnalyticsCard('Rating', '4.8/5', Icons.star, Colors.orange),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Monthly Trends
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Monthly Trends',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTrendItem('Jan', 5, Colors.blue),
                          ),
                          Expanded(
                            child: _buildTrendItem('Feb', 8, Colors.blue),
                          ),
                          Expanded(
                            child: _buildTrendItem('Mar', 12, Colors.blue),
                          ),
                          Expanded(
                            child: _buildTrendItem('Apr', 15, Colors.blue),
                          ),
                          Expanded(
                            child: _buildTrendItem('May', 18, Colors.blue),
                          ),
                          Expanded(
                            child: _buildTrendItem('Jun', 24, Colors.blue),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Customer Insights
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Insights',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 16),
                      _buildInsightItem('Most popular time', '2:00 PM - 4:00 PM', Icons.access_time, Colors.blue),
                      _buildInsightItem('Average customer rating', '4.8/5 stars', Icons.star, Colors.orange),
                      _buildInsightItem('Repeat customers', '68%', Icons.repeat, Colors.green),
                      _buildInsightItem('Customer satisfaction', '92%', Icons.sentiment_satisfied, Colors.purple),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exporting analytics report...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            icon: const Icon(Icons.download),
            label: const Text('Export Report'),
          ),
        ],
      ),
    );
  }

  // Build analytics card
  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // Build trend item
  Widget _buildTrendItem(String month, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Container(
          width: 30,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.bottomCenter,
            heightFactor: value / 24, // Normalize to max value
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        Text(
          month,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  // Build insight item
  Widget _buildInsightItem(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[700], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Phase F: Add complex dialog implementation (final suspect)
  Future<void> _showAddEditServiceDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final durationController = TextEditingController();
    
    ServiceCategory selectedCategory = ServiceCategory.grooming;
    bool isActive = true;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Service'),
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
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  serviceCode: codeController.text,
                  name: nameController.text,
                  category: selectedCategory,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  isActive: isActive,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                  duration: int.tryParse(durationController.text),
                );

                                 // Add the new service to the list
                 setState(() {
                   _services.add(newService);
                   _filterServices(); // Refresh filtered list
                 });
                 
                 Navigator.of(context).pop();
                 
                 ScaffoldMessenger.of(context).showSnackBar(
                   const SnackBar(
                     content: Text('Service added successfully!'),
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
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services & Products Management'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 2,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
          tabs: const [
            Tab(
              icon: Icon(Icons.miscellaneous_services),
              text: 'Services',
            ),
            Tab(
              icon: Icon(Icons.inventory),
              text: 'Products',
            ),
            Tab(
              icon: Icon(Icons.card_giftcard),
              text: 'Packages',
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading services data...'),
                  ],
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Theme.of(context).colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Data Loading Failed',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error: $_errorMessage',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: _loadBasicData,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Solution: Use our working implementation
                      _buildWorkingServicesTab(),
                      // Working Products Tab
                      _buildWorkingProductsTab(),
                      // Working Packages Tab  
                      _buildWorkingPackagesTab(),
                    ],
                  ),
      ),
    );
  }

  Widget _buildServicesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Row
        Row(
          children: [
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.miscellaneous_services,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_services.length}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Services',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory,
                        size: 32,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_products.length}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Products',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        size: 32,
                        color: Theme.of(context).colorScheme.tertiary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_packages.length}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Packages',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Services List
        const Text(
          'Active Services',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _services.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.miscellaneous_services_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No services available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first service to get started',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _services.length,
                  itemBuilder: (context, index) {
                    final service = _services[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.miscellaneous_services,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        title: Text(
                          service.name,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (service.description != null)
                              Text(
                                service.description!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            Text(
                              'Code: ${service.serviceCode} • Duration: ${service.duration ?? 0} min',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
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
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: service.isActive ? Colors.green : Colors.grey,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                service.isActive ? 'Active' : 'Inactive',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('View details for ${service.name}'),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildProductsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Products Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add Product functionality would go here'),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Products Stats
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inventory,
                          size: 32,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_products.length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Total Products',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Products List
          const Text(
            'Available Products',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first product to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                            child: Icon(
                              Icons.inventory,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            'Code: ${product.productCode} • Category: ${product.category.name}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Stock: ${product.stockQuantity}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('View details for ${product.name}'),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BACKUP: Working Services Tab Implementation
  // This fully functional implementation can be restored if needed
  // ==========================================
  Widget _buildWorkingServicesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Services Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
                                        ElevatedButton.icon(
                            onPressed: () => _showAddEditServiceDialog(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Service'),
                          ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Search and Filter Row
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
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<ServiceCategory>(
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
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Services Count
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.miscellaneous_services,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_services.length}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Total Services',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Phase C: Add Wrap + FilterChip widgets (potential problem area)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Filters',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedCategory == null,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategory = null;
                              _filterServices();
                            });
                          }
                        },
                      ),
                      ...ServiceCategory.values.map((category) => FilterChip(
                        label: Text(category.name.toUpperCase()),
                        selected: _selectedCategory == category,
                        onSelected: (selected) {
                          setState(() {
                            _selectedCategory = selected ? category : null;
                            _filterServices();
                          });
                        },
                      )),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Services List
          const Text(
            'Available Services',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _filteredServices.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.miscellaneous_services_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _services.isEmpty ? 'No services available' : 'No services match your filters',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredServices.length,
                    itemBuilder: (context, index) {
                      final service = _filteredServices[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: _getCategoryColor(service.category),
                            child: Icon(
                              _getCategoryIcon(service.category),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            service.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Code: ${service.serviceCode} • Price: \$${service.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Phase D: Add complex Wrap with multiple chips
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  Chip(
                                    label: Text(service.category.name.toUpperCase()),
                                    backgroundColor: _getCategoryColor(service.category).withOpacity(0.2),
                                    labelStyle: TextStyle(
                                      color: _getCategoryColor(service.category),
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (service.duration != null && service.duration! > 0)
                                    Chip(
                                      label: Text('${service.duration} min'),
                                      backgroundColor: Colors.blue.withOpacity(0.2),
                                      labelStyle: const TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                      ),
                                    ),
                                  if (service.isActive)
                                    const Chip(
                                      label: Text(
                                        'ACTIVE',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                ],
                              ),
                            ],
                          ),
                                                     trailing: PopupMenuButton<String>(
                             onSelected: (value) {
                               _handleServiceAction(value, service);
                             },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Edit Service'),
                                  dense: true,
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'duplicate',
                                child: ListTile(
                                  leading: Icon(Icons.copy),
                                  title: Text('Duplicate'),
                                  dense: true,
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'deactivate',
                                child: ListTile(
                                  leading: Icon(Icons.pause),
                                  title: Text('Deactivate'),
                                  dense: true,
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete, color: Colors.red),
                                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                                  dense: true,
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (service.description != null && service.description!.isNotEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Description:',
                                          style: TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          service.description!,
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Duration:',
                                              style: TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            Text('${service.duration ?? 0} minutes'),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Category:',
                                              style: TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            Text(service.category.name.toUpperCase()),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                                                             OutlinedButton.icon(
                                         onPressed: () => _showEditServiceDialog(context, service),
                                         icon: const Icon(Icons.edit),
                                         label: const Text('Edit'),
                                       ),
                                                                             OutlinedButton.icon(
                                         onPressed: () => _showServiceHistory(context, service),
                                         icon: const Icon(Icons.history),
                                         label: const Text('History'),
                                       ),
                                       OutlinedButton.icon(
                                         onPressed: () => _showServiceAnalytics(context, service),
                                         icon: const Icon(Icons.analytics),
                                         label: const Text('Analytics'),
                                       ),
                                    ],
                                  ),
                                ],
                              ),
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

  Widget _buildPackagesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Service Packages',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Add Package functionality would go here'),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Add Package'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Packages Stats
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.card_giftcard,
                          size: 32,
                          color: Theme.of(context).colorScheme.tertiary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_packages.length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Total Packages',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Packages List
          const Text(
            'Available Packages',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _packages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.card_giftcard_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No packages available',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add your first package to get started',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _packages.length,
                    itemBuilder: (context, index) {
                      final package = _packages[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.tertiary.withOpacity(0.1),
                            child: Icon(
                              Icons.card_giftcard,
                              color: Theme.of(context).colorScheme.tertiary,
                            ),
                          ),
                          title: Text(
                            package.name ?? 'Unnamed Package',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            'Package ID: ${package.id}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('View details for package ${package.id}'),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkingProductsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Products Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showBulkImportDialog(context),
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Bulk Import'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showAddEditProductDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Product'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Search and Filter Section
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Products',
                    hintText: 'Search by name, code, or category',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _productSearchQuery = value;
                      _filterProducts();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<ProductCategory>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedProductCategory,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Categories'),
                    ),
                    ...ProductCategory.values.map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category.name.toUpperCase()),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedProductCategory = value;
                      _filterProducts();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<ProductStatus>(
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedProductStatus,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Status'),
                    ),
                    ...ProductStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.name.toUpperCase()),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedProductStatus = value;
                      _filterProducts();
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Quick Action Chips
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.warning, size: 18),
                        label: const Text('Low Stock'),
                        onPressed: () => _filterLowStock(),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.star, size: 18),
                        label: const Text('Best Sellers'),
                        onPressed: () => _filterBestSellers(),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.new_releases, size: 18),
                        label: const Text('New Products'),
                        onPressed: () => _filterNewProducts(),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.trending_up, size: 18),
                        label: const Text('High Margin'),
                        onPressed: () => _filterHighMargin(),
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.download, size: 18),
                        label: const Text('Export Data'),
                        onPressed: () => _exportProducts(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Statistics Cards
          Row(
            children: [
              Expanded(
                child: _buildProductStatCard(
                  'Total Products',
                  '${_products.length}',
                  Icons.inventory,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProductStatCard(
                  'Low Stock Items',
                  '${_products.where((p) => p.stockQuantity < 10).length}',
                  Icons.warning,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildProductStatCard(
                  'Total Value',
                  '\$${_products.fold(0.0, (sum, p) => sum + (p.price * p.stockQuantity)).toStringAsFixed(0)}',
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
                                Expanded(
                    child: _buildProductStatCard(
                      'In Stock Products',
                      '${_products.where((p) => p.status == ProductStatus.inStock).length}',
                      Icons.check_circle,
                      Colors.purple,
                    ),
                  ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Products List
          const Text(
            'Product Inventory',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _products.isEmpty ? 'No products available' : 'No products match your filters',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          leading: CircleAvatar(
                            backgroundColor: _getProductCategoryColor(product.category),
                            child: Icon(
                              _getProductCategoryIcon(product.category),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Code: ${product.productCode} • Price: \$${product.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  Chip(
                                    label: Text(product.category.name.toUpperCase()),
                                    backgroundColor: _getProductCategoryColor(product.category).withOpacity(0.2),
                                    labelStyle: TextStyle(
                                      color: _getProductCategoryColor(product.category),
                                      fontSize: 12,
                                    ),
                                  ),
                                  Chip(
                                    label: Text('Stock: ${product.stockQuantity}'),
                                    backgroundColor: _getStockLevelColor(product.stockQuantity).withOpacity(0.2),
                                    labelStyle: TextStyle(
                                      color: _getStockLevelColor(product.stockQuantity),
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (product.status != null)
                                    Chip(
                                      label: Text(product.status!.name.toUpperCase()),
                                      backgroundColor: _getProductStatusColor(product.status!).withOpacity(0.2),
                                      labelStyle: TextStyle(
                                        color: _getProductStatusColor(product.status!),
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) => _handleProductAction(value, product),
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Edit Product'),
                                  dense: true,
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'duplicate',
                                child: ListTile(
                                  leading: Icon(Icons.copy),
                                  title: Text('Duplicate'),
                                  dense: true,
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'adjust_stock',
                                child: ListTile(
                                  leading: Icon(Icons.inventory_2),
                                  title: Text('Adjust Stock'),
                                  dense: true,
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'price_history',
                                child: ListTile(
                                  leading: Icon(Icons.trending_up),
                                  title: Text('Price History'),
                                  dense: true,
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'sales_report',
                                child: ListTile(
                                  leading: Icon(Icons.analytics),
                                  title: Text('Sales Report'),
                                  dense: true,
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'deactivate',
                                child: ListTile(
                                  leading: Icon(Icons.pause),
                                  title: Text('Toggle Status'),
                                  dense: true,
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: ListTile(
                                  leading: Icon(Icons.delete, color: Colors.red),
                                  title: Text('Delete', style: TextStyle(color: Colors.red)),
                                  dense: true,
                                ),
                              ),
                            ],
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (product.description != null && product.description!.isNotEmpty)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Description:',
                                          style: TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          product.description!,
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                        const SizedBox(height: 12),
                                      ],
                                    ),
                                  Row(
                                    children: [
                                                                        Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Barcode:',
                                          style: TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        Text(product.barcode ?? 'N/A'),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Cost Price:',
                                          style: TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        Text('\$${product.cost.toStringAsFixed(2)}'),
                                      ],
                                    ),
                                  ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Profit Margin:',
                                              style: TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                            Text(_calculateProfitMargin(product)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () => _showEditProductDialog(context, product),
                                        icon: const Icon(Icons.edit),
                                        label: const Text('Edit'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () => _showStockAdjustmentDialog(context, product),
                                        icon: const Icon(Icons.inventory_2),
                                        label: const Text('Adjust Stock'),
                                      ),
                                      OutlinedButton.icon(
                                        onPressed: () => _showProductAnalytics(context, product),
                                        icon: const Icon(Icons.analytics),
                                        label: const Text('Analytics'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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

  Widget _buildWorkingPackagesTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Service Packages',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showPackageTemplatesDialog(context),
                    icon: const Icon(Icons.category),
                    label: const Text('Templates'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _showCreatePackageDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Package'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Package Builder & Search Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Package Builder',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Search Packages',
                            hintText: 'Search by name, services, or category',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _packageSearchQuery = value;
                              _filterPackages();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      SizedBox(
                        width: 200,
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Package Type',
                            border: OutlineInputBorder(),
                          ),
                          value: _selectedPackageType,
                          items: const [
                            DropdownMenuItem(value: null, child: Text('All Types')),
                            DropdownMenuItem(value: 'grooming', child: Text('GROOMING')),
                            DropdownMenuItem(value: 'wellness', child: Text('WELLNESS')),
                            DropdownMenuItem(value: 'boarding', child: Text('BOARDING')),
                            DropdownMenuItem(value: 'premium', child: Text('PREMIUM')),
                            DropdownMenuItem(value: 'basic', child: Text('BASIC')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedPackageType = value;
                              _filterPackages();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      OutlinedButton.icon(
                        onPressed: () => _showQuickPackageBuilder(context),
                        icon: const Icon(Icons.auto_fix_high),
                        label: const Text('Quick Builder'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Quick Actions & Analytics
          Row(
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick Actions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ActionChip(
                              avatar: const Icon(Icons.trending_up, size: 18),
                              label: const Text('Popular'),
                              onPressed: () => _filterPopularPackages(),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.new_releases, size: 18),
                              label: const Text('New Combos'),
                              onPressed: () => _showNewComboDialog(context),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.content_copy, size: 18),
                              label: const Text('Duplicate Best'),
                              onPressed: () => _duplicateBestPackage(),
                            ),
                            ActionChip(
                              avatar: const Icon(Icons.analytics, size: 18),
                              label: const Text('Analytics'),
                              onPressed: () => _showPackageAnalytics(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Package Statistics',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPackageStatItem('Total', '${_mockPackages.length}', Colors.blue),
                            _buildPackageStatItem('Active', '${_mockPackages.where((p) => p['isActive'] == true).length}', Colors.green),
                            _buildPackageStatItem('Popular', '3', Colors.orange),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Packages List Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Service Packages',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () => _togglePackageView(),
                    icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
                    tooltip: _isGridView ? 'List View' : 'Grid View',
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.sort),
                    onSelected: (value) => _sortPackages(value),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
                      const PopupMenuItem(value: 'price', child: Text('Sort by Price')),
                      const PopupMenuItem(value: 'popularity', child: Text('Sort by Popularity')),
                      const PopupMenuItem(value: 'date', child: Text('Sort by Date')),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Packages Content
          Expanded(
            child: _filteredPackages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.category_outlined,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _mockPackages.isEmpty ? 'No packages available' : 'No packages match your filters',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showCreatePackageDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text('Create Your First Package'),
                        ),
                      ],
                    ),
                  )
                : _isGridView 
                    ? GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _filteredPackages.length,
                        itemBuilder: (context, index) {
                          final package = _filteredPackages[index];
                          return _buildPackageGridCard(package);
                        },
                      )
                    : ListView.builder(
                        itemCount: _filteredPackages.length,
                        itemBuilder: (context, index) {
                          final package = _filteredPackages[index];
                          return _buildPackageListCard(package);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PRODUCT MANAGEMENT METHODS
  // ==========================================

  Widget _buildProductStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getProductCategoryColor(ProductCategory category) {
    switch (category) {
      case ProductCategory.food:
        return Colors.green;
      case ProductCategory.toys:
        return Colors.purple;
      case ProductCategory.accessories:
        return Colors.blue;
      case ProductCategory.health:
        return Colors.red;
      case ProductCategory.grooming:
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  IconData _getProductCategoryIcon(ProductCategory category) {
    switch (category) {
      case ProductCategory.food:
        return Icons.restaurant;
      case ProductCategory.toys:
        return Icons.toys;
      case ProductCategory.accessories:
        return Icons.shopping_bag;
      case ProductCategory.health:
        return Icons.health_and_safety;
      case ProductCategory.grooming:
        return Icons.content_cut;
      default:
        return Icons.inventory;
    }
  }

  Color _getStockLevelColor(int stock) {
    if (stock == 0) return Colors.red;
    if (stock < 10) return Colors.orange;
    if (stock < 50) return Colors.yellow[700]!;
    return Colors.green;
  }

  Color _getProductStatusColor(ProductStatus status) {
    switch (status) {
      case ProductStatus.inStock:
        return Colors.green;
      case ProductStatus.lowStock:
        return Colors.orange;
      case ProductStatus.outOfStock:
        return Colors.red;
      case ProductStatus.discontinued:
        return Colors.grey;
      case ProductStatus.preOrder:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _calculateProfitMargin(Product product) {
    if (product.cost == 0) {
      return 'N/A';
    }
    double margin = ((product.price - product.cost) / product.price) * 100;
    return '${margin.toStringAsFixed(1)}%';
  }

  // Product action handlers
  void _handleProductAction(String action, Product product) {
    switch (action) {
      case 'edit':
        _showEditProductDialog(context, product);
        break;
      case 'duplicate':
        _duplicateProduct(product);
        break;
      case 'adjust_stock':
        _showStockAdjustmentDialog(context, product);
        break;
      case 'price_history':
        _showPriceHistoryDialog(context, product);
        break;
      case 'sales_report':
        _showProductSalesReport(context, product);
        break;
      case 'deactivate':
        _toggleProductStatus(product);
        break;
      case 'delete':
        _showDeleteProductDialog(context, product);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unknown action: $action'),
            backgroundColor: Colors.orange,
          ),
        );
    }
  }

  // Filter methods
  void _filterLowStock() {
    setState(() {
      _selectedProductCategory = null;
      _selectedProductStatus = null;
      _productSearchQuery = '';
      _filteredProducts = _products.where((p) => p.stockQuantity < 10).toList();
    });
  }

  void _filterBestSellers() {
    setState(() {
      _selectedProductCategory = null;
      _selectedProductStatus = null;
      _productSearchQuery = '';
      // Mock best sellers - in real app, this would be based on sales data
      _filteredProducts = _products.take(5).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Showing best selling products')),
    );
  }

  void _filterNewProducts() {
    setState(() {
      _selectedProductCategory = null;
      _selectedProductStatus = null;
      _productSearchQuery = '';
      // Mock new products - products created in last 30 days
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      _filteredProducts = _products.where((p) => p.createdAt.isAfter(thirtyDaysAgo)).toList();
    });
  }

  void _filterHighMargin() {
    setState(() {
      _selectedProductCategory = null;
      _selectedProductStatus = null;
      _productSearchQuery = '';
      _filteredProducts = _products.where((p) {
        if (p.cost == 0) return false;
        double margin = ((p.price - p.cost) / p.price) * 100;
        return margin > 50; // High margin is > 50%
      }).toList();
    });
  }

  void _exportProducts() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting product data to CSV...'),
        backgroundColor: Colors.blue,
      ),
    );
    // In real app, implement CSV export functionality
  }

  // Product CRUD operations
  void _showAddEditProductDialog(BuildContext context) {
    _showProductDialog(context, null);
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    _showProductDialog(context, product);
  }

  void _showProductDialog(BuildContext context, Product? product) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final codeController = TextEditingController(text: product?.productCode ?? '');
    final descriptionController = TextEditingController(text: product?.description ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final costPriceController = TextEditingController(text: product?.cost.toString() ?? '');
    final stockController = TextEditingController(text: product?.stockQuantity.toString() ?? '');
    final barcodeController = TextEditingController(text: product?.barcode ?? '');
    
    ProductCategory selectedCategory = product?.category ?? ProductCategory.accessories;
    ProductStatus selectedStatus = product?.status ?? ProductStatus.inStock;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'Add New Product' : 'Edit Product'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Product Name'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Product Code'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: barcodeController,
                  decoration: const InputDecoration(labelText: 'Barcode'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceController,
                        decoration: const InputDecoration(labelText: 'Price'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: costPriceController,
                        decoration: const InputDecoration(labelText: 'Cost'),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: stockController,
                  decoration: const InputDecoration(labelText: 'Stock Quantity'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ProductCategory>(
                  decoration: const InputDecoration(labelText: 'Category'),
                  value: selectedCategory,
                  items: ProductCategory.values.map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category.name.toUpperCase()),
                  )).toList(),
                  onChanged: (value) => selectedCategory = value!,
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<ProductStatus>(
                  decoration: const InputDecoration(labelText: 'Status'),
                  value: selectedStatus,
                  items: ProductStatus.values.map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.name.toUpperCase()),
                  )).toList(),
                  onChanged: (value) => selectedStatus = value!,
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
            onPressed: () {
              try {
                if (product == null) {
                  // Add new product
                  final newProduct = Product(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    productCode: codeController.text,
                    name: nameController.text,
                    category: selectedCategory,
                    price: double.tryParse(priceController.text) ?? 0.0,
                    cost: double.tryParse(costPriceController.text) ?? 0.0,
                    stockQuantity: int.tryParse(stockController.text) ?? 0,
                    reorderPoint: 10,
                    status: selectedStatus,
                    isActive: true,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                    description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                    barcode: barcodeController.text.isNotEmpty ? barcodeController.text : null,
                  );

                  setState(() {
                    _products.add(newProduct);
                    _filterProducts();
                  });
                } else {
                  // Update existing product
                  final updatedProduct = Product(
                    id: product.id,
                    productCode: codeController.text,
                    name: nameController.text,
                    category: selectedCategory,
                    price: double.tryParse(priceController.text) ?? 0.0,
                    cost: double.tryParse(costPriceController.text) ?? product.cost,
                    stockQuantity: int.tryParse(stockController.text) ?? 0,
                    reorderPoint: product.reorderPoint,
                    status: selectedStatus,
                    isActive: product.isActive,
                    createdAt: product.createdAt,
                    updatedAt: DateTime.now(),
                    description: descriptionController.text.isNotEmpty ? descriptionController.text : null,
                    barcode: barcodeController.text.isNotEmpty ? barcodeController.text : null,
                  );

                  setState(() {
                    final index = _products.indexWhere((p) => p.id == product.id);
                    if (index != -1) {
                      _products[index] = updatedProduct;
                      _filterProducts();
                    }
                  });
                }
                
                Navigator.of(context).pop();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Product ${product == null ? 'added' : 'updated'} successfully!'),
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
            child: Text(product == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _duplicateProduct(Product product) {
    final duplicatedProduct = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      productCode: '${product.productCode}_COPY',
      name: '${product.name} (Copy)',
      category: product.category,
      price: product.price,
      cost: product.cost,
      stockQuantity: 0, // Start with 0 stock
      reorderPoint: product.reorderPoint,
      status: ProductStatus.preOrder, // Start as pre-order
      isActive: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: product.description,
      barcode: product.barcode != null ? '${product.barcode}_COPY' : null,
    );

    setState(() {
      _products.add(duplicatedProduct);
      _filterProducts();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} duplicated successfully!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _toggleProductStatus(Product product) {
    final newStatus = product.status == ProductStatus.inStock 
        ? ProductStatus.discontinued 
        : ProductStatus.inStock;

    setState(() {
      final index = _products.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        _products[index] = Product(
          id: product.id,
          productCode: product.productCode,
          name: product.name,
          category: product.category,
          price: product.price,
          cost: product.cost,
          stockQuantity: product.stockQuantity,
          reorderPoint: product.reorderPoint,
          status: newStatus,
          isActive: product.isActive,
          createdAt: product.createdAt,
          updatedAt: DateTime.now(),
          description: product.description,
          barcode: product.barcode,
        );
        _filterProducts();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${product.name} ${newStatus.name} successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showDeleteProductDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete "${product.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _products.removeWhere((p) => p.id == product.id);
                _filterProducts();
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${product.name} deleted successfully!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showStockAdjustmentDialog(BuildContext context, Product product) {
    final stockController = TextEditingController(text: product.stockQuantity.toString());
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adjust Stock: ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: stockController,
              decoration: const InputDecoration(
                labelText: 'New Stock Quantity',
                helperText: 'Enter the new stock quantity',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for Adjustment',
                helperText: 'Optional: Reason for stock change',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newStock = int.tryParse(stockController.text) ?? product.stockQuantity;
              setState(() {
                final index = _products.indexWhere((p) => p.id == product.id);
                if (index != -1) {
                  _products[index] = Product(
                    id: product.id,
                    productCode: product.productCode,
                    name: product.name,
                    category: product.category,
                    price: product.price,
                    cost: product.cost,
                    stockQuantity: newStock,
                    reorderPoint: product.reorderPoint,
                    status: product.status,
                    isActive: product.isActive,
                    createdAt: product.createdAt,
                    updatedAt: DateTime.now(),
                    description: product.description,
                    barcode: product.barcode,
                  );
                  _filterProducts();
                }
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Stock adjusted for ${product.name}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Update Stock'),
          ),
        ],
      ),
    );
  }

  void _showPriceHistoryDialog(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Price History: ${product.name}'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: Column(
            children: [
              const Text('Price changes over time:'),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildPriceHistoryItem('Current Price', product.price, DateTime.now()),
                    _buildPriceHistoryItem('Last Month', product.price * 0.95, DateTime.now().subtract(const Duration(days: 30))),
                    _buildPriceHistoryItem('3 Months Ago', product.price * 0.9, DateTime.now().subtract(const Duration(days: 90))),
                    _buildPriceHistoryItem('6 Months Ago', product.price * 0.85, DateTime.now().subtract(const Duration(days: 180))),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceHistoryItem(String period, double price, DateTime date) {
    return ListTile(
      title: Text(period),
      subtitle: Text('${date.day}/${date.month}/${date.year}'),
      trailing: Text(
        '\$${price.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showProductSalesReport(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sales Report: ${product.name}'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sales Performance',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildSalesMetric('Units Sold (This Month)', '45'),
              _buildSalesMetric('Revenue Generated', '\$${(45 * product.price).toStringAsFixed(2)}'),
              _buildSalesMetric('Average Monthly Sales', '38'),
              _buildSalesMetric('Peak Sales Month', 'June 2024'),
              _buildSalesMetric('Customer Rating', '4.7/5'),
              const SizedBox(height: 16),
              const Text(
                'Recent Sales Trend',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text(
                      '📈 Sales trending upward\n+15% vs last month',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exporting detailed sales report...'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Export Report'),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesMetric(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showProductAnalytics(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Analytics: ${product.name}'),
        content: SizedBox(
          width: 500,
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Key Metrics
              Row(
                children: [
                  Expanded(
                    child: _buildAnalyticsCard('Stock Level', '${product.stockQuantity}', Icons.inventory, _getStockLevelColor(product.stockQuantity)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAnalyticsCard('Profit Margin', _calculateProfitMargin(product), Icons.trending_up, Colors.green),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildAnalyticsCard('Total Value', '\$${(product.price * product.stockQuantity).toStringAsFixed(0)}', Icons.attach_money, Colors.blue),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Performance Insights
              const Text(
                'Performance Insights',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    _buildInsightItem('Reorder Level', product.stockQuantity < 10 ? 'Stock is running low' : 'Stock level is healthy', 
                        product.stockQuantity < 10 ? Icons.warning : Icons.check_circle,
                        product.stockQuantity < 10 ? Colors.orange : Colors.green),
                    _buildInsightItem('Price Competitiveness', 'Price is within market range', Icons.trending_up, Colors.blue),
                    _buildInsightItem('Customer Demand', 'High demand product', Icons.favorite, Colors.red),
                    _buildInsightItem('Seasonal Performance', 'Consistent year-round sales', Icons.calendar_today, Colors.purple),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }



  void _showBulkImportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bulk Import Products'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.upload_file, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text('Import products from CSV file'),
            SizedBox(height: 8),
            Text(
                              'CSV format: Name, Code, Category, Price, Cost, Stock, Barcode, Description',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('File picker would open here for CSV import'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Select File'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PACKAGE MANAGEMENT METHODS
  // ==========================================

  Widget _buildPackageStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPackageGridCard(Map<String, dynamic> package) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    package['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  package['isPopular'] ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              package['description'],
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${package['packagePrice'].toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  '${package['bookings']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageListCard(Map<String, dynamic> package) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getPackageTypeColor(package['type']),
          child: Icon(
            _getPackageTypeIcon(package['type']),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          package['name'],
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              package['description'],
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                Chip(
                  label: Text(package['type'].toUpperCase()),
                  backgroundColor: _getPackageTypeColor(package['type']).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: _getPackageTypeColor(package['type']),
                    fontSize: 10,
                  ),
                ),
                if (package['isPopular'])
                  const Chip(
                    label: Text('POPULAR'),
                    backgroundColor: Colors.amber,
                    labelStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
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
              '\$${package['packagePrice'].toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.green,
              ),
            ),
            Text(
              '${package['bookings']} bookings',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        onTap: () => _showPackageDetails(context, package),
      ),
    );
  }

  Color _getPackageTypeColor(String type) {
    switch (type) {
      case 'grooming':
        return Colors.purple;
      case 'wellness':
        return Colors.green;
      case 'boarding':
        return Colors.blue;
      case 'premium':
        return Colors.amber;
      case 'basic':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getPackageTypeIcon(String type) {
    switch (type) {
      case 'grooming':
        return Icons.content_cut;
      case 'wellness':
        return Icons.health_and_safety;
      case 'boarding':
        return Icons.hotel;
      case 'premium':
        return Icons.star;
      case 'basic':
        return Icons.check_circle;
      default:
        return Icons.category;
    }
  }

  // Package action methods
  void _showPackageTemplatesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Package Templates'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.category, size: 64, color: Colors.blue),
            SizedBox(height: 16),
            Text('Choose from pre-built package templates'),
            SizedBox(height: 8),
            Text(
              'Templates include: Grooming, Wellness, Boarding, Premium, and Basic packages',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Template library would open here'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            child: const Text('Browse Templates'),
          ),
        ],
      ),
    );
  }

  void _showCreatePackageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Package'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text('Create a custom service package'),
            SizedBox(height: 8),
            Text(
              'Combine multiple services into attractive packages for customers',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Package creation wizard would open here'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Create Package'),
          ),
        ],
      ),
    );
  }

  void _showQuickPackageBuilder(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Package Builder'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_fix_high, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text('AI-powered package suggestions'),
            SizedBox(height: 8),
            Text(
              'Get intelligent recommendations for service combinations',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('AI package builder would open here'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text('Generate Packages'),
          ),
        ],
      ),
    );
  }

  void _filterPopularPackages() {
    setState(() {
      _selectedPackageType = null;
      _packageSearchQuery = '';
      _filteredPackages = _mockPackages.where((p) => p['isPopular'] == true).toList();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Showing popular packages')),
    );
  }

  void _showNewComboDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Combo Suggestions'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.new_releases, size: 64, color: Colors.purple),
            SizedBox(height: 8),
            Text('Discover trending service combinations'),
            SizedBox(height: 8),
            Text(
              'Based on customer preferences and seasonal trends',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _duplicateBestPackage() {
    final bestPackage = _mockPackages
        .where((p) => p['isPopular'] == true)
        .reduce((a, b) => a['bookings'] > b['bookings'] ? a : b);
    
    final duplicatedPackage = Map<String, dynamic>.from(bestPackage);
    duplicatedPackage['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    duplicatedPackage['name'] = '${bestPackage['name']} (Copy)';
    duplicatedPackage['isActive'] = false;
    duplicatedPackage['bookings'] = 0;
    
    setState(() {
      _mockPackages.add(duplicatedPackage);
      _filterPackages();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${bestPackage['name']} duplicated successfully!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _showPackageAnalytics(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Package Analytics'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Package Performance Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildAnalyticsCard('Total Packages', '${_mockPackages.length}', Icons.category, Colors.blue),
              _buildAnalyticsCard('Popular Packages', '${_mockPackages.where((p) => p['isPopular'] == true).length}', Icons.star, Colors.amber),
              _buildAnalyticsCard('Total Bookings', '${_mockPackages.fold<int>(0, (sum, p) => sum + (p['bookings'] as int))}', Icons.book_online, Colors.green),
              const SizedBox(height: 16),
              const Text(
                'Top Performing Packages',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: _mockPackages
                      .where((p) => p['isPopular'] == true)
                      .take(3)
                      .map((p) => ListTile(
                        title: Text(p['name']),
                        subtitle: Text('${p['bookings']} bookings'),
                        trailing: Text('\$${p['packagePrice'].toStringAsFixed(2)}'),
                      ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _togglePackageView() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _sortPackages(String sortBy) {
    setState(() {
      switch (sortBy) {
        case 'name':
          _filteredPackages.sort((a, b) => a['name'].compareTo(b['name']));
          break;
        case 'price':
          _filteredPackages.sort((a, b) => a['packagePrice'].compareTo(b['packagePrice']));
          break;
        case 'popularity':
          _filteredPackages.sort((a, b) => b['bookings'].compareTo(a['bookings']));
          break;
        case 'date':
          _filteredPackages.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
          break;
      }
    });
  }

  void _showPackageDetails(BuildContext context, Map<String, dynamic> package) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Package Details: ${package['name']}'),
        content: SizedBox(
          width: 400,
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                package['description'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Services Included:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: (package['services'] as List).length,
                  itemBuilder: (context, index) {
                    final service = package['services'][index];
                    return ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(service),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
