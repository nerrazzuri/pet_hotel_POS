import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/pet.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/vaccination.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/waiver.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/incident.dart';
import 'package:cat_hotel_pos/core/services/customer_dao.dart';
import 'package:cat_hotel_pos/core/services/pet_dao.dart';
import 'package:cat_hotel_pos/core/services/vaccination_dao.dart';
import 'package:cat_hotel_pos/core/services/waiver_dao.dart';
import 'package:cat_hotel_pos/core/services/incident_dao.dart';
import 'package:cat_hotel_pos/features/customers/presentation/widgets/customer_analytics_widget.dart';
import 'package:cat_hotel_pos/features/customers/presentation/widgets/loyalty_tracking_widget.dart';
import 'package:cat_hotel_pos/features/customers/presentation/widgets/communication_history_widget.dart';
import 'package:cat_hotel_pos/features/customers/presentation/widgets/edit_customer_dialog.dart';
import 'package:cat_hotel_pos/features/customers/presentation/widgets/edit_pet_dialog.dart';
import 'package:cat_hotel_pos/features/customers/presentation/widgets/edit_vaccination_dialog.dart';
import 'package:cat_hotel_pos/features/customers/presentation/widgets/edit_waiver_dialog.dart';
import 'package:cat_hotel_pos/features/customers/presentation/widgets/edit_incident_dialog.dart';
import 'package:cat_hotel_pos/features/customers/presentation/widgets/pet_details_dialog.dart';
import 'package:cat_hotel_pos/features/customers/presentation/widgets/vaccination_details_dialog.dart';
import 'package:cat_hotel_pos/features/customers/presentation/widgets/waiver_details_dialog.dart';
import 'package:cat_hotel_pos/features/customers/presentation/widgets/incident_details_dialog.dart';
import 'package:cat_hotel_pos/core/services/pos_dao.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/pos_transaction.dart';
import 'package:cat_hotel_pos/core/services/payment_transaction_dao.dart';
import 'package:cat_hotel_pos/features/payments/domain/entities/payment_transaction.dart';
import 'package:cat_hotel_pos/features/payments/domain/entities/payment_method.dart';
import 'package:cat_hotel_pos/core/services/booking_dao.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/core/services/service_dao.dart';
import 'package:cat_hotel_pos/features/services/domain/entities/service.dart';
import 'package:cat_hotel_pos/core/services/loyalty_dao.dart';
import 'package:cat_hotel_pos/features/loyalty/domain/entities/loyalty_transaction.dart';
import 'package:cat_hotel_pos/features/loyalty/domain/entities/loyalty_program.dart' as loyalty;
import 'package:cat_hotel_pos/core/services/crm_dao.dart';
import 'package:cat_hotel_pos/features/crm/domain/entities/communication_template.dart';
import 'package:cat_hotel_pos/features/crm/domain/entities/campaign.dart';
import 'package:cat_hotel_pos/features/crm/domain/entities/automated_reminder.dart';
import 'package:uuid/uuid.dart';

class CustomerPetProfilesScreen extends ConsumerStatefulWidget {
  const CustomerPetProfilesScreen({super.key});

  @override
  ConsumerState<CustomerPetProfilesScreen> createState() => _CustomerPetProfilesScreenState();
}

class _CustomerPetProfilesScreenState extends ConsumerState<CustomerPetProfilesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final CustomerDao _customerDao = CustomerDao();
  final PetDao _petDao = PetDao();
  final VaccinationDao _vaccinationDao = VaccinationDao();
  final WaiverDao _waiverDao = WaiverDao();
  final IncidentDao _incidentDao = IncidentDao();

  // Enhanced search and filter state
  String _searchQuery = '';
  CustomerStatus? _selectedStatus;
  CustomerSource? _selectedSource;
  DateTimeRange? _selectedDateRange;
  bool _showAdvancedSearch = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this); // 5 tabs for main screen (removed Loyalty and Communication)
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer & Pet Management'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,

        actions: [
          // Enhanced search toggle
          IconButton(
            icon: Icon(_showAdvancedSearch ? Icons.search_off : Icons.search),
            onPressed: () {
              setState(() {
                _showAdvancedSearch = !_showAdvancedSearch;
              });
            },
            tooltip: _showAdvancedSearch ? 'Hide Advanced Search' : 'Show Advanced Search',
          ),
          // Export button
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportCustomerData,
            tooltip: 'Export Customer Data',
          ),
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showCustomerSettings,
            tooltip: 'Customer Settings',
          ),
          // Back to Dashboard Button (moved to right side)
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
            ),
            child: IconButton(
              icon: Icon(
                Icons.dashboard,
                color: Theme.of(context).primaryColor,
                size: 24,
              ),
              onPressed: () => Navigator.of(context).pushReplacementNamed('/dashboard'),
              tooltip: 'Back to Dashboard',
              style: IconButton.styleFrom(
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: const Color(0xFFD2B48C), // Light brown color
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          labelPadding: const EdgeInsets.symmetric(horizontal: 20),
          isScrollable: false,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Customers', icon: Icon(Icons.people)),
            Tab(text: 'Vaccinations', icon: Icon(Icons.vaccines)),
            Tab(text: 'Waivers & Incidents', icon: Icon(Icons.description)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: Column(
        children: [
          // Enhanced search and filter bar
          if (_showAdvancedSearch) _buildAdvancedSearchBar(),
          
          // Main content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildCustomersTab(),
                _buildVaccinationsTab(),
                _buildWaiversIncidentsTab(),
                _buildAnalyticsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Tab Content Methods
  Widget _buildCustomersTab() {
    return FutureBuilder<List<Customer>>(
      future: _customerDao.getAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading customers: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        final customers = snapshot.data ?? [];
        
        return Column(
          children: [
            // Header with actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customer Management',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${customers.length} customers registered',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddCustomerDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Customer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _showBulkImportDialog,
                    icon: const Icon(Icons.upload),
                    label: const Text('Bulk Import'),
                  ),
                ],
              ),
            ),
            
            // Customer list - 5 cards per row
            Expanded(
              child: customers.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No customers found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your first customer to get started',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        return _buildCustomerCard(customer);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPetsTab() {
    return FutureBuilder<List<Pet>>(
      future: _petDao.getAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading pets: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        final pets = snapshot.data ?? [];
        
        return Column(
          children: [
            // Header with actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pet Management',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${pets.length} pets registered',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddPetDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Pet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _showScheduleVaccinationDialog(),
                    icon: const Icon(Icons.medical_services),
                    label: const Text('Schedule Vaccination'),
                  ),
                ],
              ),
            ),
            
            // Pet list
            Expanded(
              child: pets.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pets, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No pets found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your first pet to get started',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: pets.length,
                      itemBuilder: (context, index) {
                        final pet = pets[index];
                        return _buildPetCard(pet);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildVaccinationsTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pet Vaccinations',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Vaccination management functionality will be implemented here.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaiversIncidentsTab() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFFD2B48C), // Light brown color
              indicatorPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              labelPadding: const EdgeInsets.symmetric(horizontal: 20),
              isScrollable: false,
              tabs: [
                Tab(text: 'Waivers', icon: Icon(Icons.description)),
                Tab(text: 'Incidents', icon: Icon(Icons.warning)),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: TabBarView(
              children: [
                _buildWaiversTab(),
                _buildIncidentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWaiversTab() {
    return FutureBuilder<List<Waiver>>(
      future: _waiverDao.getAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading waivers: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        final waivers = snapshot.data ?? [];
        
        return Column(
          children: [
            // Header with actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Waiver Management',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${waivers.length} waiver records',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddWaiverDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Waiver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Waiver list
            Expanded(
              child: waivers.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No waiver records found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Add your first waiver to get started',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: waivers.length,
                      itemBuilder: (context, index) {
                        final waiver = waivers[index];
                        return _buildCompactWaiverCard(waiver);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildIncidentsTab() {
    return FutureBuilder<List<Incident>>(
      future: _incidentDao.getAll(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading incidents: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        final incidents = snapshot.data ?? [];
        
        return Column(
          children: [
            // Header with actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Incident Management',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${incidents.length} incident records',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddIncidentDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Report Incident'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            // Incident list
            Expanded(
              child: incidents.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.warning_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No incident records found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Report your first incident to get started',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemCount: incidents.length,
                      itemBuilder: (context, index) {
                        final incident = incidents[index];
                        return _buildCompactIncidentCard(incident);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  // Enhanced Advanced Search Bar
  Widget _buildAdvancedSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // Basic search
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search customers, pets, phone numbers...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _performAdvancedSearch,
                icon: const Icon(Icons.search),
                label: const Text('Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Advanced filters
          Row(
            children: [
              // Status filter
              Expanded(
                child: DropdownButtonFormField<CustomerStatus>(
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: _selectedStatus,
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
                  },
                ),
              ),
              const SizedBox(width: 16),
              
              // Source filter
              Expanded(
                child: DropdownButtonFormField<CustomerSource>(
                  decoration: const InputDecoration(
                    labelText: 'Source',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  value: _selectedSource,
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Sources'),
                    ),
                    ...CustomerSource.values.map((source) => DropdownMenuItem(
                      value: source,
                                              child: Text(source.name),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSource = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              
              // Date range filter
              Expanded(
                child: InkWell(
                  onTap: _selectDateRange,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date Range',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: Text(
                      _selectedDateRange != null
                          ? '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}'
                          : 'Select Date Range',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Clear filters button
              ElevatedButton(
                onPressed: _clearFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.grey[700],
                ),
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Enhanced Overview Tab
  Widget _buildOverviewTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getEnhancedOverviewData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading overview: ${snapshot.error}'),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        final data = snapshot.data ?? {};
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced overview cards
              _buildEnhancedOverviewCards(data),
              const SizedBox(height: 24),
              
              // Quick actions
              _buildEnhancedQuickActions(),
              const SizedBox(height: 24),
              
              // Recent activity with enhanced features
              _buildEnhancedRecentActivity(data),
              const SizedBox(height: 24),
              
              // Customer insights
              _buildCustomerInsights(data),
            ],
          ),
        );
      },
    );
  }

  // Enhanced Overview Cards
  Widget _buildEnhancedOverviewCards(Map<String, dynamic> data) {
    return Column(
      children: [
        // Key metrics in 1 row
        Row(
          children: [
            Expanded(
              child: _buildEnhancedStatCard(
                'Total Customers',
                '${data['totalCustomers'] ?? 0}',
                Icons.people,
                Colors.blue,
                subtitle: '${data['activeCustomers'] ?? 0} active',
                trend: data['customerGrowth'] ?? 0.0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildEnhancedStatCard(
                'Total Pets',
                '${data['totalPets'] ?? 0}',
                Icons.pets,
                Colors.green,
                subtitle: '${data['activePets'] ?? 0} active',
                trend: data['petGrowth'] ?? 0.0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildEnhancedStatCard(
                'Active Customers',
                '${data['activeCustomers'] ?? 0}',
                Icons.person,
                Colors.teal,
                subtitle: '${data['activeCustomers'] ?? 0} active',
                trend: data['customerGrowth'] ?? 0.0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildEnhancedStatCard(
                'VIP Customers',
                '${data['loyaltyMembers'] ?? 0}',
                Icons.card_giftcard,
                Colors.purple,
                subtitle: '${data['loyaltyPercentage'] ?? 0}% of total',
                trend: data['loyaltyGrowth'] ?? 0.0,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Additional metrics in 1 row
        Row(
          children: [
            Expanded(
              child: _buildEnhancedStatCard(
                'Expiring Vaccinations',
                '${data['expiringVaccinations'] ?? 0}',
                Icons.warning,
                Colors.orange,
                subtitle: 'Next 30 days',
                trend: data['vaccinationTrend'] ?? 0.0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildEnhancedStatCard(
                'Pending Waivers',
                '${data['pendingWaivers'] ?? 0}',
                Icons.description,
                Colors.purple,
                subtitle: 'Requires attention',
                trend: data['waiverTrend'] ?? 0.0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildEnhancedStatCard(
                'Open Incidents',
                '${data['openIncidents'] ?? 0}',
                Icons.report_problem,
                Colors.red,
                subtitle: 'Needs resolution',
                trend: data['incidentTrend'] ?? 0.0,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildEnhancedStatCard(
                'New This Month',
                '${data['newCustomersThisMonth'] ?? 0}',
                Icons.person_add,
                Colors.indigo,
                subtitle: 'Customer acquisition',
                trend: data['acquisitionTrend'] ?? 0.0,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Enhanced Stat Card with trends
  Widget _buildEnhancedStatCard(String title, String value, IconData icon, Color color, {
    String? subtitle,
    double? trend,
  }) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 32, color: color),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: trend >= 0 ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          trend >= 0 ? Icons.trending_up : Icons.trending_down,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${trend >= 0 ? '+' : ''}${trend.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Enhanced Quick Actions
  Widget _buildEnhancedQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flash_on, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _showAllQuickActions,
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Quick actions in 1 row
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'Add Customer',
                    Icons.person_add,
                    Colors.blue,
                    () => _showAddCustomerDialog(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'Add Pet',
                    Icons.pets,
                    Colors.green,
                    () => _showAddPetDialog(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'Schedule Vaccination',
                    Icons.medical_services,
                    Colors.orange,
                    () => _showScheduleVaccinationDialog(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'Send Reminder',
                    Icons.notifications,
                    Colors.purple,
                    () => _showSendReminderDialog(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'Generate Report',
                    Icons.assessment,
                    Colors.teal,
                    () => _generateCustomerReport(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    'Bulk Import',
                    Icons.upload_file,
                    Colors.indigo,
                    () => _showBulkImportDialog(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Quick Action Button
  Widget _buildQuickActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced Recent Activity
  Widget _buildEnhancedRecentActivity(Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Colors.grey),
                const SizedBox(width: 8),
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _showAllActivity,
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: (data['recentActivity'] as List?)?.length ?? 0,
                itemBuilder: (context, index) {
                  final activity = data['recentActivity'][index];
                  return _buildActivityItem(activity);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Activity Item
  Widget _buildActivityItem(Map<String, dynamic> activity) {
    final type = activity['type'] as String;
    final message = activity['message'] as String;
    final timestamp = activity['timestamp'] as DateTime;
    final icon = _getActivityIcon(type);
    final color = _getActivityColor(type);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withOpacity(0.1),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        message,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        _formatTimestamp(timestamp),
        style: TextStyle(color: Colors.grey[600], fontSize: 12),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
        size: 20,
      ),
      onTap: () => _handleActivityTap(activity),
    );
  }

  // Customer Insights
  Widget _buildCustomerInsights(Map<String, dynamic> data) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights, color: Colors.purple),
                const SizedBox(width: 8),
                const Text(
                  'Customer Insights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _showDetailedInsights,
                  child: const Text('View Details'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInsightCard(
                    'Top Customer Source',
                    data['topCustomerSource'] ?? 'N/A',
                    Icons.source,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInsightCard(
                    'Most Popular Pet Type',
                    data['mostPopularPetType'] ?? 'N/A',
                    Icons.pets,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInsightCard(
                    'Peak Check-in Time',
                    data['peakCheckinTime'] ?? 'N/A',
                    Icons.access_time,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Insight Card
  Widget _buildInsightCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // New Analytics Tab
  Widget _buildAnalyticsTab() {
    return const CustomerAnalyticsWidget();
  }

  // New Loyalty Tab
  Widget _buildLoyaltyTab() {
    return const LoyaltyTrackingWidget();
  }

  // New Communication Tab
  Widget _buildCommunicationTab() {
    return const CommunicationHistoryWidget();
  }

  // Helper methods
  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'customer_added':
        return Icons.person_add;
      case 'pet_added':
        return Icons.pets;
      case 'vaccination_scheduled':
        return Icons.medical_services;
      case 'waiver_signed':
        return Icons.description;
      case 'incident_reported':
        return Icons.report_problem;
      case 'loyalty_points_earned':
        return Icons.card_giftcard;
      default:
        return Icons.info;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'customer_added':
        return Colors.blue;
      case 'pet_added':
        return Colors.green;
      case 'vaccination_scheduled':
        return Colors.orange;
      case 'waiver_signed':
        return Colors.purple;
      case 'incident_reported':
        return Colors.red;
      case 'loyalty_points_earned':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  // Pet helper methods
  Color _getPetTypeColor(PetType type) {
    switch (type) {
      case PetType.cat:
        return Colors.orange;
      case PetType.dog:
        return Colors.blue;
      case PetType.bird:
        return Colors.green;
      case PetType.rabbit:
        return Colors.pink;
      case PetType.hamster:
        return Colors.brown;
      case PetType.guineaPig:
        return Colors.purple;
      case PetType.ferret:
        return Colors.indigo;
      case PetType.other:
        return Colors.grey;
    }
  }

  IconData _getPetTypeIcon(PetType type) {
    switch (type) {
      case PetType.dog:
        return Icons.pets;
      case PetType.cat:
        return Icons.pets;
      case PetType.bird:
        return Icons.flutter_dash;
      case PetType.guineaPig:
        return Icons.pets;
      case PetType.rabbit:
        return Icons.pets;
      case PetType.hamster:
        return Icons.pets;
      case PetType.ferret:
        return Icons.pets;
      case PetType.other:
        return Icons.pets;
    }
  }

  void _showAllPetsDialog(Customer customer, List<Pet> pets) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${customer.firstName} ${customer.lastName}\'s Pets'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: pets.length,
            itemBuilder: (context, index) {
              final pet = pets[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getPetTypeColor(pet.type).withOpacity(0.2),
                  child: Icon(
                    _getPetTypeIcon(pet.type),
                    color: _getPetTypeColor(pet.type),
                  ),
                ),
                title: Text(pet.name),
                subtitle: Text('${pet.type.name} • ${pet.breed ?? 'Unknown'}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    Navigator.pop(context);
                    _showEditPetDialog(pet);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showAddPetDialog();
            },
            child: const Text('Add Pet'),
          ),
        ],
      ),
    );
  }

  // Enhanced data methods
  Future<Map<String, dynamic>> _getEnhancedOverviewData() async {
    try {
      final customers = await _customerDao.getAll();
      final pets = await _petDao.getAll();
      final vaccinations = await _vaccinationDao.getAll();
      final waivers = await _waiverDao.getAll();
      final incidents = await _incidentDao.getAll();

      // Calculate enhanced metrics
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));
      final expiringVaccinations = vaccinations.where((v) => 
        v.expiryDate.isAfter(now) && v.expiryDate.isBefore(now.add(const Duration(days: 30)))
      ).length;

      final activeCustomers = customers.where((c) => c.status == CustomerStatus.active).length;
      final activePets = pets.where((p) => p.isActive ?? false).length;
      final pendingWaivers = waivers.where((w) => w.status == WaiverStatus.pending).length;
      final openIncidents = incidents.where((i) => i.status == IncidentStatus.reported).length;

      // Calculate trends (simplified for demo)
      final customerGrowth = customers.length > 0 ? 5.2 : 0.0;
      final petGrowth = pets.length > 0 ? 3.8 : 0.0;
      final vaccinationTrend = vaccinations.length > 0 ? -2.1 : 0.0;
      final waiverTrend = waivers.length > 0 ? 1.5 : 0.0;
      final incidentTrend = incidents.length > 0 ? -0.8 : 0.0;
      final loyaltyGrowth = 8.5;
      final acquisitionTrend = 12.3;
      final valueTrend = 4.7;

      // Generate recent activity
      final recentActivity = _generateRecentActivity(customers, pets, vaccinations, waivers, incidents);

      // Customer insights
      final topCustomerSource = _getTopCustomerSource(customers);
      final mostPopularPetType = _getMostPopularPetType(pets);
      final peakCheckinTime = '2:00 PM - 4:00 PM';

      return {
        'totalCustomers': customers.length,
        'totalPets': pets.length,
        'expiringVaccinations': expiringVaccinations,
        'pendingWaivers': pendingWaivers,
        'openIncidents': openIncidents,
        'totalVaccinations': vaccinations.length,
        'activeCustomers': activeCustomers,
        'activePets': activePets,
        'loyaltyMembers': (customers.length * 0.75).round(),
        'loyaltyPercentage': 75,
        'newCustomersThisMonth': customers.where((c) => 
          c.createdAt.isAfter(thirtyDaysAgo)).length,
        'averageCustomerValue': 1250.50,
        'customerGrowth': customerGrowth,
        'petGrowth': petGrowth,
        'vaccinationTrend': vaccinationTrend,
        'waiverTrend': waiverTrend,
        'incidentTrend': incidentTrend,
        'loyaltyGrowth': loyaltyGrowth,
        'acquisitionTrend': acquisitionTrend,
        'valueTrend': valueTrend,
        'recentActivity': recentActivity,
        'topCustomerSource': topCustomerSource,
        'mostPopularPetType': mostPopularPetType,
        'peakCheckinTime': peakCheckinTime,
      };
    } catch (e) {
      print('Error getting enhanced overview data: $e');
      return {};
    }
  }

  List<Map<String, dynamic>> _generateRecentActivity(
    List<Customer> customers,
    List<Pet> pets,
    List<Vaccination> vaccinations,
    List<Waiver> waivers,
    List<Incident> incidents,
  ) {
    final activities = <Map<String, dynamic>>[];
    final now = DateTime.now();

    // Add sample activities
    if (customers.isNotEmpty) {
      activities.add({
        'type': 'customer_added',
        'message': 'New customer ${customers.last.firstName} ${customers.last.lastName} added',
        'timestamp': now.subtract(const Duration(hours: 2)),
      });
    }

    if (pets.isNotEmpty) {
      activities.add({
        'type': 'pet_added',
        'message': 'Pet ${pets.last.name} registered for ${customers.isNotEmpty ? customers.last.firstName : 'customer'}',
        'timestamp': now.subtract(const Duration(hours: 4)),
      });
    }

    if (vaccinations.isNotEmpty) {
      activities.add({
        'type': 'vaccination_scheduled',
        'message': 'Vaccination scheduled for ${pets.isNotEmpty ? pets.last.name : 'pet'}',
        'timestamp': now.subtract(const Duration(days: 1)),
      });
    }

    if (waivers.isNotEmpty) {
      activities.add({
        'type': 'waiver_signed',
        'message': 'Waiver signed by ${customers.isNotEmpty ? customers.last.firstName : 'customer'}',
        'timestamp': now.subtract(const Duration(days: 2)),
      });
    }

    if (incidents.isNotEmpty) {
      activities.add({
        'type': 'incident_reported',
        'message': 'Incident reported for ${pets.isNotEmpty ? pets.last.name : 'pet'}',
        'timestamp': now.subtract(const Duration(days: 3)),
      });
    }

    // Sort by timestamp (most recent first)
    activities.sort((a, b) => (b['timestamp'] as DateTime).compareTo(a['timestamp'] as DateTime));
    
    return activities.take(10).toList();
  }

  String _getTopCustomerSource(List<Customer> customers) {
    final sourceCounts = <String, int>{};
    for (final customer in customers) {
              sourceCounts[customer.source.name] = (sourceCounts[customer.source.name] ?? 0) + 1;
    }
    
    if (sourceCounts.isEmpty) return 'N/A';
    
    final sortedSources = sourceCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedSources.first.key;
  }

  String _getMostPopularPetType(List<Pet> pets) {
    final typeCounts = <String, int>{};
    for (final pet in pets) {
              typeCounts[pet.type.name] = (typeCounts[pet.type.name] ?? 0) + 1;
    }
    
    if (typeCounts.isEmpty) return 'N/A';
    
    final sortedTypes = typeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedTypes.first.key;
  }

  // Action methods
  void _performAdvancedSearch() {
    // Implement advanced search logic
    print('Performing advanced search with:');
    print('Query: $_searchQuery');
    print('Status: $_selectedStatus');
    print('Source: $_selectedSource');
    print('Date Range: $_selectedDateRange');
  }

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedStatus = null;
      _selectedSource = null;
      _selectedDateRange = null;
    });
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _selectedDateRange,
    );
    
    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _exportCustomerData() {
    // Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting customer data...')),
    );
  }

  void _showCustomerSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customer Management Settings'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Customer management settings and preferences coming soon!'),
            SizedBox(height: 16),
            Text(
              'Features will include:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('• Customer data retention policies'),
            Text('• Communication preferences'),
            Text('• Loyalty program settings'),
            Text('• Privacy and consent management'),
            Text('• Data export/import settings'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAllQuickActions() {
    // Implement view all quick actions
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Showing all quick actions...')),
    );
  }

  void _showAllActivity() {
    // Implement view all activity
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Showing all activity...')),
    );
  }

  void _showDetailedInsights() {
    // Implement detailed insights
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Showing detailed insights...')),
    );
  }

  void _handleActivityTap(Map<String, dynamic> activity) {
    // Handle activity tap
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Handling activity: ${activity['message']}')),
    );
  }

  // Dialog methods for customer management
  void _showAddCustomerDialog() {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _phoneController = TextEditingController();
    final _addressController = TextEditingController();
    final _cityController = TextEditingController();
    final _stateController = TextEditingController();
    final _zipCodeController = TextEditingController();
    final _countryController = TextEditingController();
    final _notesController = TextEditingController();
    final _emergencyNameController = TextEditingController();
    final _emergencyPhoneController = TextEditingController();
    final _emergencyRelationshipController = TextEditingController();
    
    CustomerStatus _selectedStatus = CustomerStatus.active;
    CustomerSource _selectedSource = CustomerSource.walkIn;
    DateTime? _selectedBirthDate;
    LoyaltyTier _selectedLoyaltyTier = LoyaltyTier.bronze;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Customer'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Invalid email format';
                            }
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
                          labelText: 'Phone *',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Phone is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
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
                        controller: _zipCodeController,
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
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<CustomerStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: CustomerStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) _selectedStatus = value;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<CustomerSource>(
                        value: _selectedSource,
                        decoration: const InputDecoration(
                          labelText: 'Source',
                          border: OutlineInputBorder(),
                        ),
                        items: CustomerSource.values.map((source) {
                          return DropdownMenuItem(
                            value: source,
                            child: Text(source.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) _selectedSource = value;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<LoyaltyTier>(
                        value: _selectedLoyaltyTier,
                        decoration: const InputDecoration(
                          labelText: 'Loyalty Tier',
                          border: OutlineInputBorder(),
                        ),
                        items: LoyaltyTier.values.map((tier) {
                          return DropdownMenuItem(
                            value: tier,
                            child: Text(tier.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) _selectedLoyaltyTier = value;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
                            firstDate: DateTime.now().subtract(const Duration(days: 365 * 100)),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            _selectedBirthDate = date;
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _selectedBirthDate != null 
                              ? _formatDate(_selectedBirthDate!)
                              : 'Select Birth Date',
                            style: TextStyle(
                              color: _selectedBirthDate != null ? Colors.black : Colors.grey,
                            ),
                          ),
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
                const SizedBox(height: 16),
                const Text(
                  'Emergency Contact',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emergencyNameController,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _emergencyPhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emergencyRelationshipController,
                  decoration: const InputDecoration(
                    labelText: 'Relationship',
                    border: OutlineInputBorder(),
                  ),
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
              if (_formKey.currentState!.validate()) {
                final customer = Customer(
                  id: const Uuid().v4(),
                  customerCode: 'CUST${DateTime.now().millisecondsSinceEpoch}',
                  firstName: _nameController.text.trim().split(' ').first,
                  lastName: _nameController.text.trim().split(' ').length > 1 
                    ? _nameController.text.trim().split(' ').skip(1).join(' ') 
                    : 'No Last Name',
                  email: _emailController.text.trim().isEmpty ? 'no-email@example.com' : _emailController.text.trim(),
                  phoneNumber: _phoneController.text.trim(),
                  address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
                  city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
                  state: _stateController.text.trim().isEmpty ? null : _stateController.text.trim(),
                  zipCode: _zipCodeController.text.trim().isEmpty ? null : _zipCodeController.text.trim(),
                  country: _countryController.text.trim().isEmpty ? null : _countryController.text.trim(),
                  dateOfBirth: _selectedBirthDate,
                  status: _selectedStatus,
                  source: _selectedSource,
                  loyaltyTier: _selectedLoyaltyTier,
                  totalSpent: 0.0,
                  lastVisitDate: null,
                  notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                  emergencyContacts: [
                    if (_emergencyNameController.text.isNotEmpty)
                      EmergencyContact(
                        id: const Uuid().v4(),
                        name: _emergencyNameController.text.trim(),
                        phoneNumber: _emergencyPhoneController.text.trim(),
                        relationship: _emergencyRelationshipController.text.trim(),
                        customerId: const Uuid().v4(),
                      ),
                  ],
                  pets: [],
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  isActive: true,
                );
                
                _customerDao.insert(customer);
                Navigator.of(context).pop();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Customer ${customer.fullName} added successfully')),
                );
              }
            },
            child: const Text('Add Customer'),
          ),
        ],
      ),
    );
  }

  void _showAddPetDialog() {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _breedController = TextEditingController();
    final _colorController = TextEditingController();
    final _microchipController = TextEditingController();
    final _notesController = TextEditingController();
    
    PetType _selectedType = PetType.cat;
    PetGender _selectedGender = PetGender.male;
    PetSize _selectedSize = PetSize.medium;
    TemperamentType _selectedTemperament = TemperamentType.friendly;
    DateTime? _selectedBirthDate;
    double _weight = 5.0;
    Customer? _selectedCustomer;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Pet'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Pet Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Pet name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<PetType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Pet Type *',
                          border: OutlineInputBorder(),
                        ),
                        items: PetType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) _selectedType = value;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _breedController,
                        decoration: const InputDecoration(
                          labelText: 'Breed',
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
                      child: DropdownButtonFormField<PetGender>(
                        value: _selectedGender,
                        decoration: const InputDecoration(
                          labelText: 'Gender *',
                          border: OutlineInputBorder(),
                        ),
                        items: PetGender.values.map((gender) {
                          return DropdownMenuItem(
                            value: gender,
                            child: Text(gender.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) _selectedGender = value;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<PetSize>(
                        value: _selectedSize,
                        decoration: const InputDecoration(
                          labelText: 'Size *',
                          border: OutlineInputBorder(),
                        ),
                        items: PetSize.values.map((size) {
                          return DropdownMenuItem(
                            value: size,
                            child: Text(size.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) _selectedSize = value;
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
                        controller: _colorController,
                        decoration: const InputDecoration(
                          labelText: 'Color',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _microchipController,
                        decoration: const InputDecoration(
                          labelText: 'Microchip ID',
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
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().subtract(const Duration(days: 365)),
                            firstDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            _selectedBirthDate = date;
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _selectedBirthDate != null 
                              ? _formatDate(_selectedBirthDate!)
                              : 'Select Birth Date',
                            style: TextStyle(
                              color: _selectedBirthDate != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Weight (kg)', style: TextStyle(fontSize: 12)),
                          Slider(
                            value: _weight,
                            min: 0.5,
                            max: 50.0,
                            divisions: 99,
                            label: _weight.toStringAsFixed(1),
                            onChanged: (value) {
                              _weight = value;
                            },
                          ),
                          Text('${_weight.toStringAsFixed(1)} kg'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<TemperamentType>(
                  value: _selectedTemperament,
                  decoration: const InputDecoration(
                    labelText: 'Temperament',
                    border: OutlineInputBorder(),
                  ),
                  items: TemperamentType.values.map((temperament) {
                    return DropdownMenuItem(
                      value: temperament,
                      child: Text(temperament.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) _selectedTemperament = value;
                  },
                ),
                const SizedBox(height: 16),
                FutureBuilder<List<Customer>>(
                  future: _customerDao.getAll(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    final customers = snapshot.data ?? [];
                    return DropdownButtonFormField<Customer>(
                      value: _selectedCustomer,
                      decoration: const InputDecoration(
                        labelText: 'Owner *',
                        border: OutlineInputBorder(),
                      ),
                      items: customers.map((customer) {
                        return DropdownMenuItem(
                          value: customer,
                          child: Text(customer.fullName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) _selectedCustomer = value;
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select an owner';
                        }
                        return null;
                      },
                    );
                  },
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
              if (_formKey.currentState!.validate() && _selectedCustomer != null) {
                final pet = Pet(
                  id: const Uuid().v4(),
                  name: _nameController.text.trim(),
                  type: _selectedType,
                  breed: _breedController.text.trim().isEmpty ? null : _breedController.text.trim(),
                  gender: _selectedGender,
                  size: _selectedSize,
                  color: _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
                  weight: _weight,
                  microchipNumber: _microchipController.text.trim().isEmpty ? null : _microchipController.text.trim(),
                  dateOfBirth: _selectedBirthDate ?? DateTime.now(),
                  temperament: _selectedTemperament,
                  customerId: _selectedCustomer!.id,
                  customerName: _selectedCustomer!.fullName,
                  notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  isActive: true,
                );
                
                _petDao.insert(pet);
                
                // Update customer's pets list
                final updatedCustomer = _selectedCustomer!.copyWith(
                  pets: [...(_selectedCustomer!.pets ?? []), pet],
                );
                _customerDao.update(updatedCustomer);
                
                Navigator.of(context).pop();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Pet ${pet.name} added successfully')),
                );
              }
            },
            child: const Text('Add Pet'),
          ),
        ],
      ),
    );
  }

  void _showScheduleVaccinationDialog() {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _clinicController = TextEditingController();
    final _batchNumberController = TextEditingController();
    final _notesController = TextEditingController();
    
    VaccinationType _selectedType = VaccinationType.core;
    DateTime? _selectedAdministeredDate;
    DateTime? _selectedExpiryDate;
    Pet? _selectedPet;
    Customer? _selectedCustomer;
    String? _selectedAdministeredBy;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Vaccination'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder<List<Customer>>(
                  future: _customerDao.getAll(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    final customers = snapshot.data ?? [];
                    return DropdownButtonFormField<Customer>(
                      value: _selectedCustomer,
                      decoration: const InputDecoration(
                        labelText: 'Customer *',
                        border: OutlineInputBorder(),
                      ),
                      items: customers.map((customer) {
                        return DropdownMenuItem(
                          value: customer,
                          child: Text(customer.fullName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _selectedCustomer = value;
                          _selectedPet = null; // Reset pet selection
                        }
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a customer';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (_selectedCustomer != null)
                  FutureBuilder<List<Pet>>(
                    future: _petDao.getAll(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      final allPets = snapshot.data ?? [];
                      final customerPets = allPets.where((pet) => pet.customerId == _selectedCustomer!.id).toList();
                      
                      if (customerPets.isEmpty) {
                        return const Text('No pets found for this customer', style: TextStyle(color: Colors.red));
                      }
                      
                      return DropdownButtonFormField<Pet>(
                        value: _selectedPet,
                        decoration: const InputDecoration(
                          labelText: 'Pet *',
                          border: OutlineInputBorder(),
                        ),
                        items: customerPets.map((pet) {
                          return DropdownMenuItem(
                            value: pet,
                            child: Text('${pet.name} (${pet.breed ?? pet.type.name})'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) _selectedPet = value;
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a pet';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Vaccine Name *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vaccine name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<VaccinationType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Vaccine Type *',
                          border: OutlineInputBorder(),
                        ),
                        items: VaccinationType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) _selectedType = value;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _batchNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Batch Number',
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
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            _selectedAdministeredDate = date;
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _selectedAdministeredDate != null 
                              ? _formatDate(_selectedAdministeredDate!)
                              : 'Administered Date *',
                            style: TextStyle(
                              color: _selectedAdministeredDate != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 365)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                          );
                          if (date != null) {
                            _selectedExpiryDate = date;
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _selectedExpiryDate != null 
                              ? _formatDate(_selectedExpiryDate!)
                              : 'Expiry Date *',
                            style: TextStyle(
                              color: _selectedExpiryDate != null ? Colors.black : Colors.grey,
                            ),
                          ),
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
                        controller: _clinicController,
                        decoration: const InputDecoration(
                          labelText: 'Clinic Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _selectedAdministeredBy != null ? TextEditingController(text: _selectedAdministeredBy) : TextEditingController(),
                        decoration: const InputDecoration(
                          labelText: 'Administered By',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _selectedAdministeredBy = value;
                        },
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
              if (_formKey.currentState!.validate() && 
                  _selectedCustomer != null && 
                  _selectedPet != null &&
                  _selectedAdministeredDate != null &&
                  _selectedExpiryDate != null) {
                
                final vaccination = Vaccination(
                  id: const Uuid().v4(),
                  petId: _selectedPet!.id,
                  petName: _selectedPet!.name,
                  customerId: _selectedCustomer!.id,
                  customerName: _selectedCustomer!.fullName,
                  type: _selectedType,
                  name: _nameController.text.trim(),
                  administeredDate: _selectedAdministeredDate!,
                  expiryDate: _selectedExpiryDate!,
                  administeredBy: _selectedAdministeredBy?.trim().isEmpty == true ? 'Staff' : _selectedAdministeredBy!.trim(),
                  clinicName: _clinicController.text.trim().isEmpty ? 'Pet Hotel' : _clinicController.text.trim(),
                  status: VaccinationStatus.upToDate,
                  batchNumber: _batchNumberController.text.trim().isEmpty ? null : _batchNumberController.text.trim(),
                  notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                
                _vaccinationDao.create(vaccination);
                
                Navigator.of(context).pop();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vaccination scheduled for ${_selectedPet!.name}')),
                );
              }
            },
            child: const Text('Schedule Vaccination'),
          ),
        ],
      ),
    );
  }

  void _showSendReminderDialog() {
    // TODO: Implement send reminder dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Send reminder dialog coming soon!')),
    );
  }

  void _generateCustomerReport() {
    // TODO: Implement generate report
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Generating customer report...')),
    );
  }

  void _showBulkImportDialog() {
    // TODO: Implement bulk import dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bulk import dialog coming soon!')),
    );
  }

  // Customer card widget - Compact with pets integrated
  Widget _buildCustomerCard(Customer customer) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: () => _showCustomerDetailsDialog(customer),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Customer header
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getCustomerStatusColor(customer.status),
                    radius: 20,
                    child: Text(
                      '${customer.firstName[0]}${customer.lastName[0]}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${customer.firstName} ${customer.lastName}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          customer.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditCustomerDialog(customer);
                          break;
                        case 'details':
                          _showCustomerDetailsDialog(customer);
                          break;
                        case 'delete':
                          _showDeleteCustomerDialog(customer);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'details',
                        child: Row(
                          children: [
                            Icon(Icons.info, size: 16),
                            SizedBox(width: 8),
                            Text('Details'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Status and loyalty chips
              Row(
                children: [
                  _buildStatusChip(customer.status),
                  const SizedBox(width: 8),
                  if (customer.loyaltyTier != null)
                    _buildLoyaltyChip(customer.loyaltyTier!),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Customer info
              _buildCompactDetailRow('Phone', customer.phoneNumber),
              _buildCompactDetailRow('Source', customer.source.displayName),
              _buildCompactDetailRow('Total Spent', '\$${customer.totalSpent?.toStringAsFixed(2) ?? '0.00'}'),
              
              const SizedBox(height: 12),
              
              // Pets section
              FutureBuilder<List<Pet>>(
                future: _petDao.getByCustomerId(customer.id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 40,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  
                  final pets = snapshot.data ?? [];
                  
                  if (pets.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.pets, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'No pets registered',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.pets, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            'Pets (${pets.length})',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...pets.take(2).map((pet) => _buildPetMiniCard(pet)),
                      if (pets.length > 2)
                        TextButton(
                          onPressed: () => _showAllPetsDialog(customer, pets),
                          child: Text(
                            '+${pets.length - 2} more pets',
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCompactDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPetMiniCard(Pet pet) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: _getPetTypeColor(pet.type).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _getPetTypeColor(pet.type).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: _getPetTypeColor(pet.type).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getPetTypeIcon(pet.type),
              size: 14,
              color: _getPetTypeColor(pet.type),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${pet.type.name} • ${pet.breed ?? 'Unknown'}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyContact(EmergencyContact contact) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(
            contact.isPrimary == true ? Icons.star : Icons.person,
            color: contact.isPrimary == true ? Colors.amber : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${contact.relationship} - ${contact.phoneNumber}'),
                if (contact.email != null) Text(contact.email!),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusChip(CustomerStatus status) {
    return Chip(
      label: Text(
        status.name,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: _getCustomerStatusColor(status),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
  
  Widget _buildLoyaltyChip(LoyaltyTier tier) {
    return Chip(
      label: Text(
        tier.name.toUpperCase(),
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: _getLoyaltyTierColor(tier),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
  
  Color _getCustomerStatusColor(CustomerStatus status) {
    switch (status) {
      case CustomerStatus.active:
        return Colors.green;
      case CustomerStatus.inactive:
        return Colors.grey;
      case CustomerStatus.blacklisted:
        return Colors.red;
      case CustomerStatus.pendingVerification:
        return Colors.orange;
      case CustomerStatus.suspended:
        return Colors.red[700]!;
    }
  }
  
  Color _getLoyaltyTierColor(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:
        return Colors.brown;
      case LoyaltyTier.silver:
        return Colors.grey[600]!;
      case LoyaltyTier.gold:
        return Colors.amber[700]!;
      case LoyaltyTier.platinum:
        return Colors.blue[400]!;
      case LoyaltyTier.diamond:
        return Colors.purple[400]!;
      default:
        return Colors.grey;
    }
  }
  
  // Pet card widget
  Widget _buildPetCard(Pet pet) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getPetTypeColor(pet.type),
          child: Icon(
            _getPetTypeIcon(pet.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          pet.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${pet.breed} • ${pet.gender.name}'),
            Text('${pet.weight}kg • ${pet.size.name}'),
            Row(
              children: [
                _buildPetTypeChip(pet.type),
                const SizedBox(width: 8),
                if (pet.temperament != null)
                  _buildTemperamentChip(pet.temperament!),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pet details
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Birth Date', _formatDate(pet.dateOfBirth)),
                          _buildDetailRow('Color', pet.color),
                          _buildDetailRow('Microchip', pet.microchipNumber),
                          _buildDetailRow('Customer', pet.customerName),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Age', _calculateAge(pet.dateOfBirth)),
                          _buildDetailRow('Size', pet.size.name),
                          if (pet.temperament != null)
                            _buildDetailRow('Temperament', pet.temperament!.name),
                          _buildDetailRow('Notes', 'No notes'),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showEditPetDialog(pet),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showPetDetailsDialog(pet),
                      icon: const Icon(Icons.info),
                      label: const Text('Details'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showDeletePetDialog(pet),
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPetTypeChip(PetType type) {
    return Chip(
      label: Text(
        type.name,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: _getPetTypeColor(type),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
  
  Widget _buildTemperamentChip(TemperamentType temperament) {
    return Chip(
      label: Text(
        temperament.name,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: _getTemperamentColor(temperament),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
  

  
  Color _getTemperamentColor(TemperamentType temperament) {
    switch (temperament) {
      case TemperamentType.calm:
        return Colors.green;
      case TemperamentType.playful:
        return Colors.blue;
      case TemperamentType.shy:
        return Colors.grey;
      case TemperamentType.aggressive:
        return Colors.red;
      case TemperamentType.anxious:
        return Colors.orange;
      case TemperamentType.friendly:
        return Colors.green[600]!;
      case TemperamentType.independent:
        return Colors.purple;
      case TemperamentType.social:
        return Colors.teal;
      case TemperamentType.territorial:
        return Colors.red[700]!;
      case TemperamentType.other:
        return Colors.grey[600]!;
    }
  }
  
  String _calculateAge(DateTime? birthDate) {
    if (birthDate == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(birthDate);
    final years = difference.inDays ~/ 365;
    final months = (difference.inDays % 365) ~/ 30;
    
    if (years > 0) {
      return months > 0 ? '$years years, $months months' : '$years years';
    } else if (months > 0) {
      return '$months months';
    } else {
      final days = difference.inDays;
      return '$days days';
    }
  }
  
  // Vaccination card widget
  Widget _buildVaccinationCard(Vaccination vaccination) {
    final isDueSoon = vaccination.expiryDate.isBefore(
      DateTime.now().add(const Duration(days: 30))
    );
    final isOverdue = vaccination.expiryDate.isBefore(DateTime.now());
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isOverdue 
              ? Colors.red 
              : isDueSoon 
                  ? Colors.orange 
                  : Colors.green,
          child: const Icon(
            Icons.medical_services,
            color: Colors.white,
          ),
        ),
        title: Text(
          vaccination.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${vaccination.type.name} • ${vaccination.administeredBy}'),
            Text('${vaccination.clinicName} • Lot: ${vaccination.batchNumber}'),
            Row(
              children: [
                _buildVaccineTypeChip(vaccination.type.name),
                const SizedBox(width: 8),
                _buildDueDateChip(vaccination.expiryDate),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vaccination details
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Date Given', _formatDate(vaccination.administeredDate)),
                          _buildDetailRow('Expires', _formatDate(vaccination.expiryDate)),
                          _buildDetailRow('Veterinarian', vaccination.administeredBy),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Clinic', vaccination.clinicName),
                          _buildDetailRow('Lot Number', vaccination.batchNumber),
                          _buildDetailRow('Notes', vaccination.notes ?? 'No notes'),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Status indicators
                if (isOverdue || isDueSoon) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isOverdue ? Colors.red[50] : Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isOverdue ? Colors.red : Colors.orange,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isOverdue ? Icons.warning : Icons.info,
                          color: isOverdue ? Colors.red : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isOverdue 
                                ? 'Vaccination is OVERDUE! Please schedule immediately.'
                                : 'Vaccination due soon. Schedule within 30 days.',
                            style: TextStyle(
                              color: isOverdue ? Colors.red : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showEditVaccinationDialog(vaccination),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showVaccinationDetailsDialog(vaccination),
                      icon: const Icon(Icons.info),
                      label: const Text('Details'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _rescheduleVaccination(vaccination),
                      icon: const Icon(Icons.schedule),
                      label: const Text('Reschedule'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isOverdue ? Colors.red : Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVaccineTypeChip(String vaccineType) {
    return Chip(
      label: Text(
        vaccineType,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: vaccineType == 'Core' ? Colors.blue : Colors.green,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
  
  Widget _buildDueDateChip(DateTime dueDate) {
    final isOverdue = dueDate.isBefore(DateTime.now());
    final isDueSoon = dueDate.isBefore(
      DateTime.now().add(const Duration(days: 30))
    );
    
    Color backgroundColor;
    String text;
    
    if (isOverdue) {
      backgroundColor = Colors.red;
      text = 'OVERDUE';
    } else if (isDueSoon) {
      backgroundColor = Colors.orange;
      text = 'DUE SOON';
    } else {
      backgroundColor = Colors.green;
      text = 'UP TO DATE';
    }
    
    return Chip(
      label: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
  
  // Waiver card widget
  Widget _buildWaiverCard(Waiver waiver) {
    final isExpired = waiver.expiryDate != null && waiver.expiryDate!.isBefore(DateTime.now());
    final isExpiringSoon = waiver.expiryDate != null && waiver.expiryDate!.isBefore(
      DateTime.now().add(const Duration(days: 30))
    );
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: isExpired 
              ? Colors.red 
              : isExpiringSoon 
                  ? Colors.orange 
                  : Colors.green,
          child: const Icon(
            Icons.description,
            color: Colors.white,
          ),
        ),
        title: Text(
          waiver.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${waiver.type.name} • ${waiver.status.name}'),
            Text('Expires: ${waiver.expiryDate != null ? _formatDate(waiver.expiryDate!) : 'No expiry'}'),
            Row(
              children: [
                _buildWaiverTypeChip(waiver.type.name),
                const SizedBox(width: 8),
                _buildSignatureChip(waiver.status == WaiverStatus.signed),
                const SizedBox(width: 8),
                _buildExpiryChip(waiver.expiryDate ?? DateTime.now()),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Waiver details
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Type', waiver.type.name),
                          _buildDetailRow('Signed Date', 
                            waiver.status == WaiverStatus.signed && waiver.signedDate != null ? _formatDate(waiver.signedDate!) : 'Not signed'),
                          _buildDetailRow('Expires', waiver.expiryDate != null ? _formatDate(waiver.expiryDate!) : 'No expiry'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Status', waiver.status.name),
                          _buildDetailRow('Notes', waiver.notes ?? 'No notes'),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Content preview
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Content Preview:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        waiver.content.length > 200 
                            ? '${waiver.content.substring(0, 200)}...'
                            : waiver.content,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Status indicators
                if (isExpired || isExpiringSoon) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isExpired ? Colors.red[50] : Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isExpired ? Colors.red : Colors.orange,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isExpired ? Icons.warning : Icons.info,
                          color: isExpired ? Colors.red : Colors.orange,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isExpired 
                                ? 'Waiver has EXPIRED! Please renew immediately.'
                                : 'Waiver expires soon. Renew within 30 days.',
                            style: TextStyle(
                              color: isExpired ? Colors.red : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showEditWaiverDialog(waiver),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showWaiverDetailsDialog(waiver),
                      icon: const Icon(Icons.info),
                      label: const Text('Details'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _renewWaiver(waiver),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Renew'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isExpired ? Colors.red : Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Incident card widget
  Widget _buildIncidentCard(Incident incident) {
    final severityColor = _getSeverityColor(incident.severity.name);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: severityColor,
          child: const Icon(
            Icons.warning,
            color: Colors.white,
          ),
        ),
        title: Text(
          incident.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${incident.severity.name} • ${_formatDate(incident.reportedDate)}'),
            Text('${incident.location ?? 'Unknown'} • Reported by: ${incident.reportedBy}'),
            Row(
              children: [
                _buildSeverityChip(incident.severity.name),
                const SizedBox(width: 8),
                _buildFollowUpChip(incident.followUpRequired != null && incident.followUpRequired!.isNotEmpty),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Incident details
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Date Occurred', _formatDate(incident.occurredDate ?? incident.reportedDate)),
                          _buildDetailRow('Location', incident.location ?? 'Unknown'),
                          _buildDetailRow('Reported By', incident.reportedBy),
                          _buildDetailRow('Severity', incident.severity.name),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Action Taken', incident.actionsTaken ?? 'None'),
                          _buildDetailRow('Follow-up Required', incident.followUpRequired != null && incident.followUpRequired!.isNotEmpty ? 'Yes' : 'No'),
                          _buildDetailRow('Notes', incident.notes ?? 'No notes'),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Description
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Description:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        incident.description,
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showEditIncidentDialog(incident),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showIncidentDetailsDialog(incident),
                      icon: const Icon(Icons.info),
                      label: const Text('Details'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _updateIncidentStatus(incident),
                      icon: const Icon(Icons.update),
                      label: const Text('Update Status'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWaiverTypeChip(String waiverType) {
    return Chip(
      label: Text(
        waiverType,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: Colors.blue,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
  
  Widget _buildSignatureChip(bool isSigned) {
    return Chip(
      label: Text(
        isSigned ? 'SIGNED' : 'NOT SIGNED',
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: isSigned ? Colors.green : Colors.red,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
  
  Widget _buildExpiryChip(DateTime expiryDate) {
    final isExpired = expiryDate.isBefore(DateTime.now());
    final isExpiringSoon = expiryDate.isBefore(
      DateTime.now().add(const Duration(days: 30))
    );
    
    Color backgroundColor;
    String text;
    
    if (isExpired) {
      backgroundColor = Colors.red;
      text = 'EXPIRED';
    } else if (isExpiringSoon) {
      backgroundColor = Colors.orange;
      text = 'EXPIRES SOON';
    } else {
      backgroundColor = Colors.green;
      text = 'VALID';
    }
    
    return Chip(
      label: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
  
  Widget _buildSeverityChip(String severity) {
    return Chip(
      label: Text(
        severity.toUpperCase(),
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: _getSeverityColor(severity),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
  
  Widget _buildFollowUpChip(bool followUpRequired) {
    return Chip(
      label: Text(
        followUpRequired ? 'FOLLOW-UP REQUIRED' : 'NO FOLLOW-UP',
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: followUpRequired ? Colors.orange : Colors.grey,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }
  
  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'critical':
        return Colors.red[700]!;
      default:
        return Colors.grey;
    }
  }

  // Compact Waiver Card for Grid View
  Widget _buildCompactWaiverCard(Waiver waiver) {
    final isExpired = waiver.expiryDate != null && waiver.expiryDate!.isBefore(DateTime.now());
    final isExpiringSoon = waiver.expiryDate != null && waiver.expiryDate!.isBefore(
      DateTime.now().add(const Duration(days: 30))
    );
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showWaiverDetailsDialog(waiver),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status indicator
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isExpired 
                            ? Colors.red[100] 
                            : isExpiringSoon 
                                ? Colors.orange[100] 
                                : Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isExpired 
                              ? Colors.red 
                              : isExpiringSoon 
                                  ? Colors.orange 
                                  : Colors.green,
                        ),
                      ),
                      child: Text(
                        isExpired 
                            ? 'EXPIRED' 
                            : isExpiringSoon 
                                ? 'EXPIRES SOON' 
                                : 'VALID',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isExpired 
                              ? Colors.red[700] 
                              : isExpiringSoon 
                                  ? Colors.orange[700] 
                                  : Colors.green[700],
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.description,
                    color: isExpired 
                        ? Colors.red 
                        : isExpiringSoon 
                            ? Colors.orange 
                            : Colors.green,
                    size: 20,
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Title
              Text(
                waiver.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Type and Status
              Text(
                waiver.type.name,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              
              Text(
                waiver.status.name,
                style: TextStyle(
                  color: waiver.status == WaiverStatus.signed ? Colors.green[700] : Colors.red[700],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const Spacer(),
              
              // Expiry info
              if (waiver.expiryDate != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Expires: ${_formatDate(waiver.expiryDate!)}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 8),
              
              // Quick actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () => _showEditWaiverDialog(waiver),
                    icon: const Icon(Icons.edit, size: 16),
                    tooltip: 'Edit',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    onPressed: () => _showWaiverDetailsDialog(waiver),
                    icon: const Icon(Icons.info, size: 16),
                    tooltip: 'Details',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    onPressed: () => _renewWaiver(waiver),
                    icon: const Icon(Icons.refresh, size: 16),
                    tooltip: 'Renew',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Compact Incident Card for Grid View
  Widget _buildCompactIncidentCard(Incident incident) {
    final severityColor = _getSeverityColor(incident.severity.name);
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showIncidentDetailsDialog(incident),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with severity indicator
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: severityColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: severityColor),
                      ),
                      child: Text(
                        incident.severity.name.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: severityColor,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.warning,
                    color: severityColor,
                    size: 20,
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Title
              Text(
                incident.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 4),
              
              // Date and Location
              Text(
                _formatDate(incident.reportedDate),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              
              Text(
                incident.location ?? 'Unknown',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const Spacer(),
              
              // Follow-up indicator
              if (incident.followUpRequired != null && incident.followUpRequired!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Text(
                    'FOLLOW-UP REQUIRED',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 8),
              
              // Quick actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () => _showEditIncidentDialog(incident),
                    icon: const Icon(Icons.edit, size: 16),
                    tooltip: 'Edit',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    onPressed: () => _showIncidentDetailsDialog(incident),
                    icon: const Icon(Icons.info, size: 16),
                    tooltip: 'Details',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  IconButton(
                    onPressed: () => _updateIncidentStatus(incident),
                    icon: const Icon(Icons.update, size: 16),
                    tooltip: 'Update Status',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // ... existing code ...

  // Additional dialog methods
  void _showEditCustomerDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => EditCustomerDialog(
        customer: customer,
        onUpdate: (updatedCustomer) async {
          // Update customer using the service
          await _customerDao.update(updatedCustomer);
          setState(() {}); // Refresh the UI
        },
      ),
    );
  }

  void _showCustomerDetailsDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => _CustomerDetailsDialog(customer: customer),
    );
  }

  void _showDeleteCustomerDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${customer.firstName} ${customer.lastName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Customer deleted successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditPetDialog(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => EditPetDialog(
        pet: pet,
        onUpdate: (updatedPet) async {
          // Update pet using the service
          await _petDao.update(updatedPet);
          setState(() {}); // Refresh the UI
        },
      ),
    );
  }

  void _showPetDetailsDialog(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => PetDetailsDialog(pet: pet),
    );
  }

  void _showDeletePetDialog(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pet'),
        content: Text('Are you sure you want to delete ${pet.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pet deleted successfully!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showEditVaccinationDialog(Vaccination vaccination) {
    showDialog(
      context: context,
      builder: (context) => EditVaccinationDialog(
        vaccination: vaccination,
        onUpdate: (updatedVaccination) async {
          // Update vaccination using the service
          await _vaccinationDao.update(updatedVaccination);
          setState(() {}); // Refresh the UI
        },
      ),
    );
  }

  void _showVaccinationDetailsDialog(Vaccination vaccination) {
    showDialog(
      context: context,
      builder: (context) => VaccinationDetailsDialog(vaccination: vaccination),
    );
  }

  void _rescheduleVaccination(Vaccination vaccination) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reschedule Vaccination'),
        content: const Text('Reschedule vaccination form coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showVaccinationReminders() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Vaccination Reminders'),
        content: const Text('Vaccination reminders view coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddWaiverDialog() {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController();
    final _contentController = TextEditingController();
    final _clinicController = TextEditingController();
    final _notesController = TextEditingController();
    
    WaiverType _selectedType = WaiverType.boardingConsent;
    DateTime? _selectedExpiryDate;
    Customer? _selectedCustomer;
    Pet? _selectedPet;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Waiver'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder<List<Customer>>(
                  future: _customerDao.getAll(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    final customers = snapshot.data ?? [];
                    return DropdownButtonFormField<Customer>(
                      value: _selectedCustomer,
                      decoration: const InputDecoration(
                        labelText: 'Customer *',
                        border: OutlineInputBorder(),
                      ),
                      items: customers.map((customer) {
                        return DropdownMenuItem(
                          value: customer,
                          child: Text(customer.fullName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _selectedCustomer = value;
                          _selectedPet = null; // Reset pet selection
                        }
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a customer';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (_selectedCustomer != null)
                  FutureBuilder<List<Pet>>(
                    future: _petDao.getAll(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      final allPets = snapshot.data ?? [];
                      final customerPets = allPets.where((pet) => pet.customerId == _selectedCustomer!.id).toList();
                      
                      if (customerPets.isEmpty) {
                        return const Text('No pets found for this customer', style: TextStyle(color: Colors.red));
                      }
                      
                      return DropdownButtonFormField<Pet?>(
                        value: _selectedPet,
                        decoration: const InputDecoration(
                          labelText: 'Pet (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<Pet?>(
                            value: null,
                            child: Text('No specific pet'),
                          ),
                          ...customerPets.map((pet) {
                            return DropdownMenuItem<Pet?>(
                              value: pet,
                              child: Text('${pet.name} (${pet.breed ?? pet.type.name})'),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          _selectedPet = value;
                        },
                      );
                    },
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Waiver Title *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Waiver title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<WaiverType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Waiver Type *',
                          border: OutlineInputBorder(),
                        ),
                        items: WaiverType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) _selectedType = value;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 365)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                          );
                          if (date != null) {
                            _selectedExpiryDate = date;
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _selectedExpiryDate != null 
                              ? _formatDate(_selectedExpiryDate!)
                              : 'Expiry Date *',
                            style: TextStyle(
                              color: _selectedExpiryDate != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Waiver Content *',
                    border: OutlineInputBorder(),
                    hintText: 'Enter the waiver terms and conditions...',
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Waiver content is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _clinicController,
                        decoration: const InputDecoration(
                          labelText: 'Clinic/Service Provider',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Additional Notes',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
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
              if (_formKey.currentState!.validate() && 
                  _selectedCustomer != null &&
                  _selectedExpiryDate != null) {
                
                final waiver = Waiver(
                  id: const Uuid().v4(),
                  customerId: _selectedCustomer!.id,
                  customerName: _selectedCustomer!.fullName,
                  petId: _selectedPet?.id,
                  petName: _selectedPet?.name,
                  type: _selectedType,
                  title: _titleController.text.trim(),
                  content: _contentController.text.trim(),
                  status: WaiverStatus.pending,
                  expiryDate: _selectedExpiryDate!,
                  notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                
                _waiverDao.create(waiver);
                
                Navigator.of(context).pop();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Waiver created successfully')),
                );
              }
            },
            child: const Text('Create Waiver'),
          ),
        ],
      ),
    );
  }

  void _showEditWaiverDialog(Waiver waiver) {
    showDialog(
      context: context,
      builder: (context) => EditWaiverDialog(
        waiver: waiver,
        onUpdate: (updatedWaiver) async {
          // Update waiver using the service
          await _waiverDao.update(updatedWaiver);
          setState(() {}); // Refresh the UI
        },
      ),
    );
  }

  void _showWaiverDetailsDialog(Waiver waiver) {
    showDialog(
      context: context,
      builder: (context) => WaiverDetailsDialog(waiver: waiver),
    );
  }

  void _renewWaiver(Waiver waiver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Renew Waiver'),
        content: const Text('Renew waiver form coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddIncidentDialog() {
    final _formKey = GlobalKey<FormState>();
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    final _locationController = TextEditingController();
    final _reportedByController = TextEditingController();
    final _actionsTakenController = TextEditingController();
    final _followUpRequiredController = TextEditingController();
    final _notesController = TextEditingController();
    
    IncidentType _selectedType = IncidentType.medical;
    IncidentSeverity _selectedSeverity = IncidentSeverity.minor;
    IncidentStatus _selectedStatus = IncidentStatus.reported;
    DateTime? _selectedOccurredDate;
    DateTime? _selectedReportedDate;
    Customer? _selectedCustomer;
    Pet? _selectedPet;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report New Incident'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FutureBuilder<List<Customer>>(
                  future: _customerDao.getAll(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }
                    final customers = snapshot.data ?? [];
                    return DropdownButtonFormField<Customer>(
                      value: _selectedCustomer,
                      decoration: const InputDecoration(
                        labelText: 'Customer *',
                        border: OutlineInputBorder(),
                      ),
                      items: customers.map((customer) {
                        return DropdownMenuItem(
                          value: customer,
                          child: Text(customer.fullName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          _selectedCustomer = value;
                          _selectedPet = null; // Reset pet selection
                        }
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a customer';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (_selectedCustomer != null)
                  FutureBuilder<List<Pet>>(
                    future: _petDao.getAll(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      final allPets = snapshot.data ?? [];
                      final customerPets = allPets.where((pet) => pet.customerId == _selectedCustomer!.id).toList();
                      
                      if (customerPets.isEmpty) {
                        return const Text('No pets found for this customer', style: TextStyle(color: Colors.red));
                      }
                      
                      return DropdownButtonFormField<Pet?>(
                        value: _selectedPet,
                        decoration: const InputDecoration(
                          labelText: 'Pet (Optional)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<Pet?>(
                            value: null,
                            child: Text('No specific pet'),
                          ),
                          ...customerPets.map((pet) {
                            return DropdownMenuItem<Pet?>(
                              value: pet,
                              child: Text('${pet.name} (${pet.breed ?? pet.type.name})'),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          _selectedPet = value;
                        },
                      );
                    },
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Incident Title *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Incident title is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<IncidentType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Incident Type *',
                          border: OutlineInputBorder(),
                        ),
                        items: IncidentType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) _selectedType = value;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<IncidentSeverity>(
                        value: _selectedSeverity,
                        decoration: const InputDecoration(
                          labelText: 'Severity *',
                          border: OutlineInputBorder(),
                        ),
                        items: IncidentSeverity.values.map((severity) {
                          return DropdownMenuItem(
                            value: severity,
                            child: Text(severity.name),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) _selectedSeverity = value;
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
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            _selectedOccurredDate = date;
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _selectedOccurredDate != null 
                              ? _formatDate(_selectedOccurredDate!)
                              : 'Occurred Date *',
                            style: TextStyle(
                              color: _selectedOccurredDate != null ? Colors.black : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 7)),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            _selectedReportedDate = date;
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _selectedReportedDate != null 
                              ? _formatDate(_selectedReportedDate!)
                              : 'Reported Date *',
                            style: TextStyle(
                              color: _selectedReportedDate != null ? Colors.black : Colors.grey,
                            ),
                          ),
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
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _reportedByController,
                        decoration: const InputDecoration(
                          labelText: 'Reported By',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    border: OutlineInputBorder(),
                    hintText: 'Describe what happened...',
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _actionsTakenController,
                        decoration: const InputDecoration(
                          labelText: 'Actions Taken',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _followUpRequiredController,
                        decoration: const InputDecoration(
                          labelText: 'Follow-up Required',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Additional Notes',
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
            onPressed: () {
              if (_formKey.currentState!.validate() && 
                  _selectedCustomer != null &&
                  _selectedOccurredDate != null &&
                  _selectedReportedDate != null) {
                
                final incident = Incident(
                  id: const Uuid().v4(),
                  customerId: _selectedCustomer!.id,
                  customerName: _selectedCustomer!.fullName,
                  petId: _selectedPet?.id ?? 'no_pet',
                  petName: _selectedPet?.name ?? 'No Pet',
                  type: _selectedType,
                  severity: _selectedSeverity,
                  status: _selectedStatus,
                  title: _titleController.text.trim(),
                  reportedDate: _selectedReportedDate!,
                  occurredDate: _selectedOccurredDate!,
                  location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
                  reportedBy: _reportedByController.text.trim().isEmpty ? 'Staff' : _reportedByController.text.trim(),
                  description: _descriptionController.text.trim(),
                  actionsTaken: _actionsTakenController.text.trim().isEmpty ? null : _actionsTakenController.text.trim(),
                  followUpRequired: _followUpRequiredController.text.trim().isEmpty ? null : _followUpRequiredController.text.trim(),
                  notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                
                _incidentDao.create(incident);
                
                Navigator.of(context).pop();
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Incident reported successfully')),
                );
              }
            },
            child: const Text('Report Incident'),
          ),
        ],
      ),
    );
  }

  void _showEditIncidentDialog(Incident incident) {
    showDialog(
      context: context,
      builder: (context) => EditIncidentDialog(
        incident: incident,
        onUpdate: (updatedIncident) async {
          // Update incident using the service
          await _incidentDao.update(updatedIncident);
          setState(() {}); // Refresh the UI
        },
      ),
    );
  }

  void _showIncidentDetailsDialog(Incident incident) {
    showDialog(
      context: context,
      builder: (context) => IncidentDetailsDialog(incident: incident),
    );
  }

  void _updateIncidentStatus(Incident incident) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Incident Status'),
        content: const Text('Update incident status form coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProductManagementTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Management',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text('Product management functionality will be implemented here.'),
        ],
      ),
    );
  }

  Widget _buildPaymentHistoryTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment History',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text('Payment history functionality will be implemented here.'),
        ],
      ),
    );
  }
}

// Comprehensive Customer Details Dialog
class _CustomerDetailsDialog extends ConsumerStatefulWidget {
  final Customer customer;

  const _CustomerDetailsDialog({required this.customer});

  @override
  ConsumerState<_CustomerDetailsDialog> createState() => _CustomerDetailsDialogState();
}

class _CustomerDetailsDialogState extends ConsumerState<_CustomerDetailsDialog>
    with SingleTickerProviderStateMixin {
  final PetDao _petDao = PetDao();
  final VaccinationDao _vaccinationDao = VaccinationDao();
  final PosDao _posDao = PosDao();
  final PaymentTransactionDao _paymentDao = PaymentTransactionDao();
  final BookingDao _bookingDao = BookingDao();
  final ServiceDao _serviceDao = ServiceDao();
  final LoyaltyDao _loyaltyDao = LoyaltyDao();
  final CrmDao _crmDao = CrmDao();
  late TabController _tabController;
  late Future<List<Pet>> _petsFuture;
  late Future<List<POSTransaction>> _transactionsFuture;
  late Future<List<PaymentTransaction>> _paymentsFuture;
  late Future<List<Booking>> _bookingsFuture;
  late Future<List<Service>> _allServicesFuture;
  late Future<List<Vaccination>> _vaccinationsFuture;
  late Future<List<LoyaltyTransaction>> _loyaltyTransactionsFuture;
  late Future<loyalty.LoyaltyProgram?> _activeLoyaltyProgramFuture;
  late Future<List<AutomatedReminder>> _remindersFuture;
  late Future<List<CommunicationTemplate>> _templatesFuture;
  late Future<List<Campaign>> _campaignsFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 9, vsync: this);
    _petsFuture = _petDao.getByCustomerId(widget.customer.id);
    _transactionsFuture = _posDao.getTransactionsByCustomerId(widget.customer.id);
    _paymentsFuture = _paymentDao.getByCustomerId(widget.customer.id);
    _bookingsFuture = _bookingDao.getByCustomerId(widget.customer.id);
    _allServicesFuture = _serviceDao.getAll();
    _vaccinationsFuture = _vaccinationDao.getByCustomerId(widget.customer.id);
    _loyaltyTransactionsFuture = _loyaltyDao.getLoyaltyTransactionsByCustomerId(widget.customer.id);
    _activeLoyaltyProgramFuture = _loyaltyDao.getActiveLoyaltyProgram();
    _remindersFuture = _crmDao.getRemindersByCustomerId(widget.customer.id);
    _templatesFuture = _crmDao.getAllTemplates();
    _campaignsFuture = _crmDao.getAllCampaigns();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 1200,
        height: 800,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 24),
            
            // Tab Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  tabBarTheme: const TabBarThemeData(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: Color(0xFFD2B48C),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  labelColor: Colors.black, // Black text for active tabs
                  unselectedLabelColor: Colors.grey[700], // Dark grey text for inactive tabs
                  indicatorColor: const Color(0xFFD2B48C), // Light brown color
                  indicatorPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  tabs: const [
                    Tab(icon: Icon(Icons.person), text: 'Profile'),
                    Tab(icon: Icon(Icons.history), text: 'Transactions'),
                    Tab(icon: Icon(Icons.payment), text: 'Payments'),
                    Tab(icon: Icon(Icons.medical_services), text: 'Services'),
                    Tab(icon: Icon(Icons.pets), text: 'Pets'),
                    Tab(icon: Icon(Icons.vaccines), text: 'Vaccinations'),
                    Tab(icon: Icon(Icons.card_giftcard), text: 'Loyalty'),
                    Tab(icon: Icon(Icons.message), text: 'Communication'),
                    Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProfileTab(),
                  _buildTransactionsTab(),
                  _buildPaymentsTab(),
                  _buildServicesTab(),
                  _buildPetsTab(),
                  _buildVaccinationsTab(),
                  _buildLoyaltyTab(),
                  _buildCommunicationTab(),
                  _buildAnalyticsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Customer Avatar
        CircleAvatar(
          backgroundColor: _getCustomerStatusColor(widget.customer.status),
          radius: 30,
          child: Text(
            '${widget.customer.firstName[0]}${widget.customer.lastName[0]}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
        ),
        const SizedBox(width: 20),
        
        // Customer Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${widget.customer.firstName} ${widget.customer.lastName}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Customer ID: ${widget.customer.id}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildStatusChip(widget.customer.status),
                  const SizedBox(width: 12),
                  if (widget.customer.loyaltyTier != null)
                    _buildLoyaltyChip(widget.customer.loyaltyTier!),
                ],
              ),
            ],
          ),
        ),
        
        // Quick Actions
        if (_tabController.index == 0) // Only show Edit Profile when Profile tab is active
          ElevatedButton.icon(
            onPressed: () => _showEditCustomerDialog(widget.customer),
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        
        // Close Button
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close),
          tooltip: 'Close',
        ),
      ],
    );
  }

  // Profile Tab
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Personal Information'),
          const SizedBox(height: 16),
          
          // Basic Info Grid
          Row(
            children: [
              Expanded(child: _buildInfoCard('Email', widget.customer.email, Icons.email)),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoCard('Phone', widget.customer.phoneNumber, Icons.phone)),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(child: _buildInfoCard('Address', widget.customer.address ?? 'No address', Icons.location_on)),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoCard('Source', widget.customer.source.displayName, Icons.source)),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(child: _buildInfoCard('Registration Date', _formatDate(widget.customer.createdAt), Icons.calendar_today)),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoCard('Last Visit', widget.customer.lastVisitDate != null ? _formatDate(widget.customer.lastVisitDate!) : 'Never', Icons.visibility)),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(child: _buildInfoCard('Date of Birth', widget.customer.dateOfBirth != null ? _formatDate(widget.customer.dateOfBirth!) : 'Not specified', Icons.cake)),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoCard('Total Spent', '\$${widget.customer.totalSpent?.toStringAsFixed(2) ?? '0.00'}', Icons.attach_money)),
            ],
          ),
          
          const SizedBox(height: 32),
          _buildSectionTitle('Emergency Contacts'),
          const SizedBox(height: 16),
          
          if (widget.customer.emergencyContacts != null && widget.customer.emergencyContacts!.isNotEmpty)
            ...widget.customer.emergencyContacts!.map((contact) => _buildEmergencyContactCard(contact))
          else
            _buildInfoCard('No emergency contacts', 'Add emergency contacts for safety', Icons.warning),
            
          const SizedBox(height: 32),
          _buildSectionTitle('Notes & Preferences'),
          const SizedBox(height: 16),
          
          _buildInfoCard('Notes', widget.customer.notes ?? 'No notes available', Icons.note),
          
          const SizedBox(height: 32),
          _buildSectionTitle('Quick Actions'),
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showScheduleAppointmentDialog(),
                  icon: const Icon(Icons.schedule),
                  label: const Text('Schedule Appointment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showSendMessageDialog(),
                  icon: const Icon(Icons.message),
                  label: const Text('Send Message'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Pets Tab
  Widget _buildPetsTab() {
    return Container(
      color: Colors.grey[50],
      child: FutureBuilder<List<Pet>>(
        future: _petsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.red[700])));
          }
          
          final pets = snapshot.data ?? [];
          
          if (pets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text('No pets registered', style: TextStyle(fontSize: 18, color: Colors.grey[700])),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddPetDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Pet'),
                  ),
                ],
              ),
            );
          }
          
          return SingleChildScrollView(
            child: Column(
              children: [
                // Header with add button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${pets.length} Pets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                    ElevatedButton.icon(
                      onPressed: () => _showAddPetDialog(),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Pet'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Pets list with two-column layout
                ...pets.map((pet) => _buildRedesignedPetCard(pet)),
              ],
            ),
          );
        },
      ),
    );
  }

  // Transactions Tab
  Widget _buildTransactionsTab() {
    return FutureBuilder<List<POSTransaction>>(
      future: _transactionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final transactions = snapshot.data ?? [];
        
        return Column(
          children: [
            // Summary cards
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Total Transactions', transactions.length.toString(), Icons.receipt, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('Total Value', '\$${_calculateTotalTransactions(transactions).toStringAsFixed(2)}', Icons.attach_money, Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('This Month', '${_getThisMonthTransactions(transactions).length}', Icons.calendar_month, Colors.orange)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Search and filter bar
            _buildTransactionSearchBar(),
            const SizedBox(height: 16),
            
            // Transactions list
            Expanded(
              child: transactions.isEmpty
                  ? Center(child: Text('No transactions found', style: TextStyle(color: Colors.grey[700])))
                  : ListView.builder(
                      itemCount: transactions.length,
                      itemBuilder: (context, index) => _buildPOSTransactionCard(transactions[index]),
                    ),
            ),
          ],
        );
      },
    );
  }

  // Payments Tab
  Widget _buildPaymentsTab() {
    return FutureBuilder<List<PaymentTransaction>>(
      future: _paymentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final payments = snapshot.data ?? [];
        
        return Column(
          children: [
            // Summary cards
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Total Payments', payments.length.toString(), Icons.payment, Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('Total Amount', '\$${_calculateTotalPayments(payments).toStringAsFixed(2)}', Icons.attach_money, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('Payment Methods', '${_getUniquePaymentMethods(payments).length}', Icons.credit_card, Colors.purple)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Search and filter bar
            _buildPaymentSearchBar(),
            const SizedBox(height: 16),
            
            // Payments list
            Expanded(
              child: payments.isEmpty
                  ? const Center(child: Text('No payments found'))
                  : ListView.builder(
                      itemCount: payments.length,
                      itemBuilder: (context, index) => _buildPaymentTransactionCard(payments[index]),
                    ),
            ),
          ],
        );
      },
    );
  }

  // Services Tab
  Widget _buildServicesTab() {
    return FutureBuilder<List<Booking>>(
      future: _bookingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final bookings = snapshot.data ?? [];
        
        return Column(
          children: [
            // Summary cards
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Total Bookings', bookings.length.toString(), Icons.medical_services, Colors.teal)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('This Month', '${_getThisMonthBookings(bookings).length}', Icons.calendar_month, Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('Upcoming', '${_getUpcomingBookings(bookings).length}', Icons.schedule, Colors.blue)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Search and filter bar
            _buildServiceSearchBar(),
            const SizedBox(height: 16),
            
            // Bookings list
            Expanded(
              child: bookings.isEmpty
                  ? const Center(child: Text('No bookings found'))
                  : ListView.builder(
                      itemCount: bookings.length,
                      itemBuilder: (context, index) => _buildBookingCard(bookings[index]),
                    ),
            ),
          ],
        );
      },
    );
  }

  // Loyalty Tab
  Widget _buildLoyaltyTab() {
    return FutureBuilder<List<LoyaltyTransaction>>(
      future: _loyaltyTransactionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final loyaltyTransactions = snapshot.data ?? [];
        final loyaltyTier = widget.customer.loyaltyTier ?? LoyaltyTier.bronze;
        final totalPoints = loyaltyTransactions.fold<int>(0, (sum, tx) => sum + tx.points);
        
        return Column(
          children: [
            // Summary cards
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Total Points', totalPoints.toString(), Icons.card_giftcard, Colors.purple)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('Current Tier', loyaltyTier.displayName, Icons.star, Colors.amber)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('Transactions', loyaltyTransactions.length.toString(), Icons.history, Colors.blue)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Current Status
            _buildSectionTitle('Current Loyalty Status'),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: loyaltyTier == LoyaltyTier.platinum ? [Colors.purple, Colors.indigo] :
                          loyaltyTier == LoyaltyTier.gold ? [Colors.amber, Colors.orange] :
                          loyaltyTier == LoyaltyTier.silver ? [Colors.grey, Colors.blueGrey] :
                          [Colors.brown, Colors.orange],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    loyaltyTier == LoyaltyTier.platinum ? Icons.diamond :
                    loyaltyTier == LoyaltyTier.gold ? Icons.star :
                    loyaltyTier == LoyaltyTier.silver ? Icons.star_border :
                    Icons.favorite,
                    color: Colors.white,
                    size: 48,
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loyaltyTier.displayName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$totalPoints points earned',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Search and filter bar
          _buildLoyaltySearchBar(),
          const SizedBox(height: 16),
          
          // Loyalty transactions list
          Expanded(
            child: loyaltyTransactions.isEmpty
                ? const Center(child: Text('No loyalty transactions found'))
                : ListView.builder(
                    itemCount: loyaltyTransactions.length,
                    itemBuilder: (context, index) => _buildLoyaltyTransactionCard(loyaltyTransactions[index]),
                  ),
          ),
        ],
      );
      },
    );
  }

  // Communication Tab
  Widget _buildCommunicationTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Communication Overview
          _buildSectionTitle('Communication Overview'),
          const SizedBox(height: 16),
          
          FutureBuilder<List<AutomatedReminder>>(
            future: _remindersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final reminders = snapshot.data ?? [];
              final pendingReminders = reminders.where((r) => r.status == ReminderStatus.pending).length;
              final sentReminders = reminders.where((r) => r.status == ReminderStatus.sent).length;
              final failedReminders = reminders.where((r) => r.status == ReminderStatus.failed).length;
              
              return Row(
                children: [
                  Expanded(child: _buildInfoCard('Pending Reminders', '$pendingReminders', Icons.schedule)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInfoCard('Sent Reminders', '$sentReminders', Icons.check_circle)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInfoCard('Failed Reminders', '$failedReminders', Icons.error)),
                ],
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Communication Preferences
          _buildSectionTitle('Communication Preferences'),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(child: _buildInfoCard('Email Notifications', 'Enabled', Icons.email)),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoCard('SMS Notifications', 'Enabled', Icons.sms)),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoCard('Marketing Emails', 'Opted In', Icons.campaign)),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Automated Reminders
          _buildSectionTitle('Automated Reminders'),
          const SizedBox(height: 16),
          
          _buildCommunicationSearchBar(),
          const SizedBox(height: 16),
          
          FutureBuilder<List<AutomatedReminder>>(
            future: _remindersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error loading reminders: ${snapshot.error}'),
                    ],
                  ),
                );
              }
              
              final reminders = snapshot.data ?? [];
              
              if (reminders.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.schedule, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No automated reminders', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        Text('Reminders will appear here when scheduled', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              }
              
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: reminders.length,
                itemBuilder: (context, index) {
                  final reminder = reminders[index];
                  return _buildReminderCard(reminder);
                },
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Communication Templates
          _buildSectionTitle('Available Templates'),
          const SizedBox(height: 16),
          
          FutureBuilder<List<CommunicationTemplate>>(
            future: _templatesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final templates = snapshot.data ?? [];
              
              if (templates.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.description, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No communication templates', style: TextStyle(fontSize: 16, color: Colors.grey)),
                        Text('Templates will appear here when available', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),
                );
              }
              
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                ),
                itemCount: templates.length,
                itemBuilder: (context, index) {
                  final template = templates[index];
                  return _buildTemplateCard(template);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Communication Tab Helper Methods
  Widget _buildCommunicationSearchBar() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search reminders...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (value) {
                  // TODO: Implement search functionality
                },
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement create reminder functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Create reminder dialog coming soon!')),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Create Reminder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderCard(AutomatedReminder reminder) {
    final statusColor = _getReminderStatusColor(reminder.status);
    final typeIcon = _getReminderTypeIcon(reminder.type);
    final channelIcon = _getReminderChannelIcon(reminder.channel);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(typeIcon, color: statusColor),
        ),
        title: Text(
          reminder.subject,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reminder.message),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    reminder.status.name.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(channelIcon, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  reminder.channel.name.toUpperCase(),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.schedule, size: 14, color: Colors.orange),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(reminder.scheduledAt),
                  style: TextStyle(
                    color: Colors.orange[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleReminderAction(value, reminder),
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
              value: 'send_now',
              child: Row(
                children: [
                  Icon(Icons.send),
                  SizedBox(width: 8),
                  Text('Send Now'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'cancel',
              child: Row(
                children: [
                  Icon(Icons.cancel),
                  SizedBox(width: 8),
                  Text('Cancel'),
                ],
              ),
            ),
          ],
          child: const Icon(Icons.more_vert),
        ),
        onTap: () => _showReminderDetails(reminder),
      ),
    );
  }

  Widget _buildTemplateCard(CommunicationTemplate template) {
    final typeColor = _getTemplateTypeColor(template.type);
    final categoryIcon = _getTemplateCategoryIcon(template.category);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(categoryIcon, color: typeColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    template.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: typeColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              template.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: typeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: typeColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    template.type.name.toUpperCase(),
                    style: TextStyle(
                      color: typeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: Text(
                    template.category.name.toUpperCase(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _showTemplateDetails(template),
                    child: const Text('View'),
                  ),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _useTemplate(template),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: typeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text('Use'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getReminderStatusColor(ReminderStatus status) {
    switch (status) {
      case ReminderStatus.pending:
        return Colors.orange;
      case ReminderStatus.sent:
        return Colors.green;
      case ReminderStatus.failed:
        return Colors.red;
      case ReminderStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getReminderTypeIcon(ReminderType type) {
    switch (type) {
      case ReminderType.vaccinationExpiry:
        return Icons.medical_services;
      case ReminderType.upcomingBooking:
        return Icons.schedule;
      case ReminderType.checkInPrep:
        return Icons.login;
      case ReminderType.checkOut:
        return Icons.logout;
      case ReminderType.loyaltyPointsExpiry:
        return Icons.card_giftcard;
      case ReminderType.birthday:
        return Icons.cake;
      case ReminderType.followUp:
        return Icons.follow_the_signs;
      case ReminderType.custom:
        return Icons.message;
    }
  }

  IconData _getReminderChannelIcon(ReminderChannel channel) {
    switch (channel) {
      case ReminderChannel.email:
        return Icons.email;
      case ReminderChannel.sms:
        return Icons.sms;
      case ReminderChannel.whatsapp:
        return Icons.chat;
      case ReminderChannel.push:
        return Icons.notifications;
    }
  }

  Color _getTemplateTypeColor(TemplateType type) {
    switch (type) {
      case TemplateType.email:
        return Colors.blue;
      case TemplateType.sms:
        return Colors.green;
      case TemplateType.whatsapp:
        return Colors.green;
      case TemplateType.push:
        return Colors.purple;
    }
  }

  IconData _getTemplateCategoryIcon(TemplateCategory category) {
    switch (category) {
      case TemplateCategory.booking:
        return Icons.schedule;
      case TemplateCategory.vaccination:
        return Icons.medical_services;
      case TemplateCategory.loyalty:
        return Icons.card_giftcard;
      case TemplateCategory.marketing:
        return Icons.campaign;
      case TemplateCategory.reminder:
        return Icons.notifications;
      case TemplateCategory.notification:
        return Icons.info;
    }
  }

  void _handleReminderAction(String action, AutomatedReminder reminder) {
    switch (action) {
      case 'view':
        _showReminderDetails(reminder);
        break;
      case 'edit':
        _editReminder(reminder);
        break;
      case 'send_now':
        _sendReminderNow(reminder);
        break;
      case 'cancel':
        _cancelReminder(reminder);
        break;
    }
  }

  void _showReminderDetails(AutomatedReminder reminder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(reminder.subject),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', reminder.type.name),
              _buildDetailRow('Status', reminder.status.name),
              _buildDetailRow('Channel', reminder.channel.name),
              _buildDetailRow('Scheduled At', _formatDateTime(reminder.scheduledAt)),
              if (reminder.sentAt != null)
                _buildDetailRow('Sent At', _formatDateTime(reminder.sentAt!)),
              _buildDetailRow('Retry Count', '${reminder.retryCount}'),
              if (reminder.errorMessage != null)
                _buildDetailRow('Error', reminder.errorMessage!),
              const SizedBox(height: 16),
              const Text('Message:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(reminder.message),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _editReminder(AutomatedReminder reminder) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit reminder: ${reminder.subject}')),
    );
  }

  void _sendReminderNow(AutomatedReminder reminder) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sending reminder now: ${reminder.subject}')),
    );
  }

  void _cancelReminder(AutomatedReminder reminder) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Cancelling reminder: ${reminder.subject}')),
    );
  }

  void _showTemplateDetails(CommunicationTemplate template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(template.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Type', template.type.name),
              _buildDetailRow('Category', template.category.name),
              _buildDetailRow('Subject', template.subject),
              _buildDetailRow('Active', template.isActive ? 'Yes' : 'No'),
              _buildDetailRow('Created', _formatDateTime(template.createdAt)),
              const SizedBox(height: 16),
              const Text('Content:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(template.content),
              if (template.variables.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Variables:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...template.variables.entries.map((entry) => 
                  _buildDetailRow(entry.key, entry.value)
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _useTemplate(CommunicationTemplate template) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Using template: ${template.name}')),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  // Analytics Tab
  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer Value Metrics
          _buildSectionTitle('Customer Value Metrics'),
          const SizedBox(height: 16),
          
          FutureBuilder<List<PaymentTransaction>>(
            future: _paymentsFuture,
            builder: (context, paymentSnapshot) {
              if (paymentSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final payments = paymentSnapshot.data ?? [];
              final totalSpent = payments.fold<double>(0, (sum, payment) => sum + payment.amount);
              final averageTransaction = payments.isNotEmpty ? totalSpent / payments.length : 0.0;
              final transactionCount = payments.length;
              
              return Row(
                children: [
                  Expanded(child: _buildInfoCard('Total Spent', '\$${totalSpent.toStringAsFixed(2)}', Icons.trending_up)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInfoCard('Avg Transaction', '\$${averageTransaction.toStringAsFixed(2)}', Icons.analytics)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInfoCard('Total Transactions', '$transactionCount', Icons.receipt)),
                ],
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Service Analytics
          _buildSectionTitle('Service Analytics'),
          const SizedBox(height: 16),
          
          FutureBuilder<List<Booking>>(
            future: _bookingsFuture,
            builder: (context, bookingSnapshot) {
              if (bookingSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final bookings = bookingSnapshot.data ?? [];
              final completedBookings = bookings.where((b) => b.status == BookingStatus.completed).length;
              final cancelledBookings = bookings.where((b) => b.status == BookingStatus.cancelled).length;
              final upcomingBookings = bookings.where((b) => b.status == BookingStatus.confirmed).length;
              
              return Row(
                children: [
                  Expanded(child: _buildInfoCard('Completed Services', '$completedBookings', Icons.check_circle)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInfoCard('Cancelled Services', '$cancelledBookings', Icons.cancel)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInfoCard('Upcoming Services', '$upcomingBookings', Icons.schedule)),
                ],
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Pet Health Analytics
          _buildSectionTitle('Pet Health Analytics'),
          const SizedBox(height: 16),
          
          FutureBuilder<List<Vaccination>>(
            future: _vaccinationsFuture,
            builder: (context, vaccinationSnapshot) {
              if (vaccinationSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final vaccinations = vaccinationSnapshot.data ?? [];
              final upToDateVaccinations = vaccinations.where((v) => v.status == VaccinationStatus.upToDate).length;
              final expiredVaccinations = vaccinations.where((v) => v.status == VaccinationStatus.expired).length;
              final dueSoonVaccinations = vaccinations.where((v) => v.status == VaccinationStatus.dueSoon).length;
              
              return Row(
                children: [
                  Expanded(child: _buildInfoCard('Up-to-Date', '$upToDateVaccinations', Icons.health_and_safety)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInfoCard('Expired', '$expiredVaccinations', Icons.warning)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInfoCard('Due Soon', '$dueSoonVaccinations', Icons.schedule)),
                ],
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Loyalty Analytics
          _buildSectionTitle('Loyalty Analytics'),
          const SizedBox(height: 16),
          
          FutureBuilder<List<LoyaltyTransaction>>(
            future: _loyaltyTransactionsFuture,
            builder: (context, loyaltySnapshot) {
              if (loyaltySnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final loyaltyTransactions = loyaltySnapshot.data ?? [];
              final totalPoints = loyaltyTransactions.fold<int>(0, (sum, tx) => sum + tx.points);
              final earnedPoints = loyaltyTransactions.where((tx) => tx.type == LoyaltyTransactionType.earned).fold<int>(0, (sum, tx) => sum + tx.points);
              final redeemedPoints = loyaltyTransactions.where((tx) => tx.type == LoyaltyTransactionType.redeemed).fold<int>(0, (sum, tx) => sum + tx.points);
              
              return Row(
                children: [
                  Expanded(child: _buildInfoCard('Total Points', '$totalPoints', Icons.card_giftcard)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInfoCard('Points Earned', '$earnedPoints', Icons.add_circle)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInfoCard('Points Redeemed', '$redeemedPoints', Icons.remove_circle)),
                ],
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Communication Analytics
          _buildSectionTitle('Communication Analytics'),
          const SizedBox(height: 16),
          
          FutureBuilder<List<AutomatedReminder>>(
            future: _remindersFuture,
            builder: (context, reminderSnapshot) {
              if (reminderSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final reminders = reminderSnapshot.data ?? [];
              final sentReminders = reminders.where((r) => r.status == ReminderStatus.sent).length;
              final pendingReminders = reminders.where((r) => r.status == ReminderStatus.pending).length;
              final failedReminders = reminders.where((r) => r.status == ReminderStatus.failed).length;
              
              return Row(
                children: [
                  Expanded(child: _buildInfoCard('Sent Reminders', '$sentReminders', Icons.send)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInfoCard('Pending Reminders', '$pendingReminders', Icons.schedule)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInfoCard('Failed Reminders', '$failedReminders', Icons.error)),
                ],
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Service Usage Trends
          _buildSectionTitle('Service Usage Trends'),
          const SizedBox(height: 16),
          
          _buildServiceUsageChart(),
          
          const SizedBox(height: 32),
          
          // Payment Method Analytics
          _buildSectionTitle('Payment Method Analytics'),
          const SizedBox(height: 16),
          
          _buildPaymentMethodChart(),
          
          const SizedBox(height: 32),
          
          // Customer Engagement Score
          _buildSectionTitle('Customer Engagement Score'),
          const SizedBox(height: 16),
          
          _buildEngagementScoreCard(),
        ],
      ),
    );
  }

  // Analytics Helper Methods
  Widget _buildServiceUsageChart() {
    return FutureBuilder<List<Booking>>(
      future: _bookingsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final bookings = snapshot.data ?? [];
        final serviceCounts = <String, int>{};
        
        for (final booking in bookings) {
          final serviceName = booking.type.name; // Use booking type as service name
          serviceCounts[serviceName] = (serviceCounts[serviceName] ?? 0) + 1;
        }
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Most Used Services',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (serviceCounts.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No service usage data available'),
                    ),
                  )
                else
                  Builder(
                    builder: (context) {
                      final sortedEntries = serviceCounts.entries.toList()
                        ..sort((a, b) => b.value.compareTo(a.value));
                      final maxCount = serviceCounts.values.reduce((a, b) => a > b ? a : b);
                      final topServices = sortedEntries.take(5).toList();
                      
                      return Column(
                        children: topServices.map((entry) => 
                          _buildServiceUsageBar(entry.key, entry.value, maxCount)
                        ).toList(),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildServiceUsageBar(String serviceName, int count, int maxCount) {
    final percentage = maxCount > 0 ? count / maxCount : 0.0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  serviceName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                '$count',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            minHeight: 8,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodChart() {
    return FutureBuilder<List<PaymentTransaction>>(
      future: _paymentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final payments = snapshot.data ?? [];
        final paymentMethodCounts = <PaymentMethod, int>{};
        
        for (final payment in payments) {
          paymentMethodCounts[payment.paymentMethod] = (paymentMethodCounts[payment.paymentMethod] ?? 0) + 1;
        }
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Method Preferences',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (paymentMethodCounts.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: Text('No payment data available'),
                    ),
                  )
                else
                  ...paymentMethodCounts.entries.map((entry) => 
                    _buildPaymentMethodRow(entry.key, entry.value, payments.length)
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPaymentMethodRow(PaymentMethod method, int count, int totalPayments) {
    final percentage = totalPayments > 0 ? (count / totalPayments * 100) : 0.0;
    final icon = _getPaymentMethodIcon(method);
    final color = _getPaymentMethodColor(method);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _getPaymentMethodDisplayName(method),
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '$count (${percentage.toStringAsFixed(1)}%)',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementScoreCard() {
    return FutureBuilder(
      future: Future.wait([_paymentsFuture, _bookingsFuture, _loyaltyTransactionsFuture, _remindersFuture]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final results = snapshot.data as List;
        final payments = results[0] as List<PaymentTransaction>;
        final bookings = results[1] as List<Booking>;
        final loyaltyTransactions = results[2] as List<LoyaltyTransaction>;
        final reminders = results[3] as List<AutomatedReminder>;
        
        // Calculate engagement score (0-100)
        final score = _calculateEngagementScore(payments, bookings, loyaltyTransactions, reminders);
        final scoreColor = _getEngagementScoreColor(score);
        final scoreLabel = _getEngagementScoreLabel(score);
        
        return Card(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scoreColor.withOpacity(0.1), scoreColor.withOpacity(0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Customer Engagement Score',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        scoreLabel,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            '$score',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: scoreColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '/ 100',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                CircularProgressIndicator(
                  value: score / 100,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  strokeWidth: 8,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _calculateEngagementScore(List<PaymentTransaction> payments, List<Booking> bookings, List<LoyaltyTransaction> loyaltyTransactions, List<AutomatedReminder> reminders) {
    int score = 0;
    
    // Payment frequency (0-30 points)
    final paymentCount = payments.length;
    if (paymentCount >= 10) score += 30;
    else if (paymentCount >= 5) score += 20;
    else if (paymentCount >= 2) score += 10;
    
    // Service usage (0-25 points)
    final completedBookings = bookings.where((b) => b.status == BookingStatus.completed).length;
    if (completedBookings >= 5) score += 25;
    else if (completedBookings >= 3) score += 15;
    else if (completedBookings >= 1) score += 10;
    
    // Loyalty engagement (0-25 points)
    final loyaltyCount = loyaltyTransactions.length;
    if (loyaltyCount >= 5) score += 25;
    else if (loyaltyCount >= 3) score += 15;
    else if (loyaltyCount >= 1) score += 10;
    
    // Communication engagement (0-20 points)
    final sentReminders = reminders.where((r) => r.status == ReminderStatus.sent).length;
    if (sentReminders >= 3) score += 20;
    else if (sentReminders >= 1) score += 10;
    
    return score.clamp(0, 100);
  }

  Color _getEngagementScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    if (score >= 40) return Colors.amber;
    return Colors.red;
  }

  String _getEngagementScoreLabel(int score) {
    if (score >= 80) return 'Highly Engaged';
    if (score >= 60) return 'Well Engaged';
    if (score >= 40) return 'Moderately Engaged';
    if (score >= 20) return 'Low Engagement';
    return 'Minimal Engagement';
  }

  IconData _getPaymentMethodIcon(PaymentMethod method) {
    // Since PaymentMethod is a class, we need to check its type property
    switch (method.type) {
      case PaymentType.cash:
        return Icons.payments;
      case PaymentType.creditCard:
      case PaymentType.debitCard:
        return Icons.credit_card;
      case PaymentType.digitalWallet:
        return Icons.account_balance_wallet;
      case PaymentType.bankTransfer:
        return Icons.account_balance;
      case PaymentType.voucher:
        return Icons.card_giftcard;
      case PaymentType.deposit:
        return Icons.account_balance_wallet;
      case PaymentType.partialPayment:
        return Icons.payment;
    }
  }

  Color _getPaymentMethodColor(PaymentMethod method) {
    switch (method.type) {
      case PaymentType.cash:
        return Colors.green;
      case PaymentType.creditCard:
      case PaymentType.debitCard:
        return Colors.blue;
      case PaymentType.digitalWallet:
        return Colors.purple;
      case PaymentType.bankTransfer:
        return Colors.orange;
      case PaymentType.voucher:
        return Colors.pink;
      case PaymentType.deposit:
        return Colors.teal;
      case PaymentType.partialPayment:
        return Colors.amber;
    }
  }

  String _getPaymentMethodDisplayName(PaymentMethod method) {
    switch (method.type) {
      case PaymentType.cash:
        return 'Cash';
      case PaymentType.creditCard:
        return 'Credit Card';
      case PaymentType.debitCard:
        return 'Debit Card';
      case PaymentType.digitalWallet:
        return 'Digital Wallet';
      case PaymentType.bankTransfer:
        return 'Bank Transfer';
      case PaymentType.voucher:
        return 'Voucher';
      case PaymentType.deposit:
        return 'Deposit';
      case PaymentType.partialPayment:
        return 'Partial Payment';
    }
  }

  // Helper Methods
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.teal,
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.teal, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRedesignedPetCard(Pet pet) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pet header
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getPetTypeColor(pet.type).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    _getPetTypeIcon(pet.type),
                    color: _getPetTypeColor(pet.type),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${pet.type.name} • ${pet.breed ?? 'Unknown'}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Pet details in two columns
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPetDetailRow('Age', '${pet.age ?? 'Unknown'} years'),
                      _buildPetDetailRow('Weight', '${pet.weight ?? 'Unknown'} ${pet.weightUnit ?? ''}'),
                      _buildPetDetailRow('Gender', pet.gender.name),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                // Right column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPetDetailRow('Size', pet.size.name),
                      _buildPetDetailRow('Color', pet.color ?? 'Unknown'),
                      _buildPetDetailRow('Microchip', pet.microchipNumber ?? 'None'),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Vaccination information
            _buildVaccinationSection(pet),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showPetDetailsDialog(pet),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Details'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showEditPetDialog(pet),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showPetVaccinationsDialog(pet),
                  icon: const Icon(Icons.vaccines, size: 16),
                  label: const Text('Vaccinations'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationSection(Pet pet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(Icons.vaccines, color: Colors.blue[700], size: 20),
            const SizedBox(width: 8),
            Text(
              'Vaccination Records',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Vaccination list
        FutureBuilder<List<Vaccination>>(
          future: _vaccinationDao.getByPetId(pet.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasError) {
              return Text(
                'Error loading vaccinations: ${snapshot.error}',
                style: TextStyle(color: Colors.red[700]),
              );
            }
            
            final vaccinations = snapshot.data ?? [];
            
            if (vaccinations.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'No vaccination records found',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              );
            }
            
            return Column(
              children: vaccinations.map((vaccination) => _buildVaccinationItem(vaccination)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVaccinationItem(Vaccination vaccination) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vaccination.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Administered: ${_formatDate(vaccination.administeredDate)}',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
                if (vaccination.expiryDate != null)
                  Text(
                    'Expires: ${_formatDate(vaccination.expiryDate!)}',
                    style: TextStyle(
                      color: vaccination.expiryDate!.isBefore(DateTime.now()) 
                          ? Colors.red[600] 
                          : Colors.grey[700],
                      fontSize: 12,
                      fontWeight: vaccination.expiryDate!.isBefore(DateTime.now()) 
                          ? FontWeight.bold 
                          : FontWeight.normal,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: Icon(Icons.receipt, color: Colors.blue),
        ),
        title: Text(
          transaction['description'] ?? 'Transaction',
          style: TextStyle(color: Colors.black87),
        ),
        subtitle: Text(
          '${transaction['date']} • ${transaction['amount']}',
          style: TextStyle(color: Colors.grey[700]),
        ),
        trailing: Text(
          '\$${transaction['amount']}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.1),
          child: Icon(Icons.payment, color: Colors.green),
        ),
        title: Text(
          payment['method'] ?? 'Payment',
          style: TextStyle(color: Colors.black87),
        ),
        subtitle: Text(
          '${payment['date']} • ${payment['status']}',
          style: TextStyle(color: Colors.grey[700]),
        ),
        trailing: Text(
          '\$${payment['amount']}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.teal.withOpacity(0.1),
          child: Icon(Icons.medical_services, color: Colors.teal),
        ),
        title: Text(
          service['type'] ?? 'Service',
          style: TextStyle(color: Colors.black87),
        ),
        subtitle: Text(
          '${service['date']} • ${service['staff']}',
          style: TextStyle(color: Colors.grey[700]),
        ),
        trailing: Text(
          '\$${service['cost']}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.teal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildLoyaltyBenefitsGrid(LoyaltyTier? tier) {
    final benefits = ['Free grooming every 3 months', '10% discount on services', 'Priority booking'];
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 3,
      ),
      itemCount: benefits.length,
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                benefits[index],
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactCard(EmergencyContact contact) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(
            contact.isPrimary == true ? Icons.star : Icons.person,
            color: contact.isPrimary == true ? Colors.amber : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${contact.relationship} - ${contact.phoneNumber}'),
                if (contact.email != null) Text(contact.email!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationHistory() {
    final communications = [
      {'type': 'Email', 'date': '2024-01-15', 'subject': 'Appointment Reminder'},
      {'type': 'SMS', 'date': '2024-01-14', 'subject': 'Service Confirmation'},
      {'type': 'Email', 'date': '2024-01-10', 'subject': 'Welcome Message'},
    ];
    
    return Column(
      children: communications.map((comm) => Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Icon(
            comm['type'] == 'Email' ? Icons.email : Icons.sms,
            color: comm['type'] == 'Email' ? Colors.blue : Colors.green,
          ),
          title: Text(
            comm['subject'] ?? '',
            style: TextStyle(color: Colors.black87),
          ),
          subtitle: Text(
            '${comm['type']} • ${comm['date']}',
            style: TextStyle(color: Colors.grey[700]),
          ),
          trailing: Icon(Icons.check_circle, color: Colors.green, size: 16),
        ),
      )).toList(),
    );
  }

  Widget _buildServiceUtilizationChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
              child: Center(
          child: Text(
            'Service Utilization Chart\n(Chart implementation would go here)',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
    );
  }

  // Mock data methods
  Future<List<Map<String, dynamic>>> _getMockTransactions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {'description': 'Grooming Service', 'date': '2024-01-15', 'amount': 45.00},
      {'description': 'Boarding (2 nights)', 'date': '2024-01-10', 'amount': 120.00},
      {'description': 'Vaccination', 'date': '2024-01-05', 'amount': 35.00},
      {'description': 'Pet Food', 'date': '2024-01-01', 'amount': 28.50},
    ];
  }

  Future<List<Map<String, dynamic>>> _getMockPayments() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {'method': 'Credit Card', 'date': '2024-01-15', 'amount': 45.00, 'status': 'Completed'},
      {'method': 'Cash', 'date': '2024-01-10', 'amount': 120.00, 'status': 'Completed'},
      {'method': 'Credit Card', 'date': '2024-01-05', 'amount': 35.00, 'status': 'Completed'},
      {'method': 'Credit Card', 'date': '2024-01-01', 'amount': 28.50, 'status': 'Completed'},
    ];
  }

  Future<List<Map<String, dynamic>>> _getMockServices() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      {'type': 'Grooming', 'date': '2024-01-15', 'staff': 'Sarah', 'cost': 45.00},
      {'type': 'Boarding', 'date': '2024-01-10', 'staff': 'Mike', 'cost': 120.00},
      {'type': 'Vaccination', 'date': '2024-01-05', 'staff': 'Dr. Johnson', 'cost': 35.00},
      {'type': 'Consultation', 'date': '2024-01-01', 'staff': 'Dr. Johnson', 'cost': 28.50},
    ];
  }

  // Calculation methods
  double _calculateTotalTransactions(List<POSTransaction> transactions) {
    return transactions.fold(0.0, (sum, transaction) => sum + transaction.totalAmount);
  }

  List<POSTransaction> _getThisMonthTransactions(List<POSTransaction> transactions) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    return transactions.where((transaction) {
      return transaction.completedAt.isAfter(thisMonth.subtract(const Duration(days: 1)));
    }).toList();
  }

  double _calculateTotalPayments(List<PaymentTransaction> payments) {
    return payments.fold(0.0, (sum, payment) => sum + payment.amount);
  }

  List<String> _getUniquePaymentMethods(List<PaymentTransaction> payments) {
    return payments.map((p) => p.paymentMethod.name).toSet().toList();
  }

  List<Booking> _getThisMonthBookings(List<Booking> bookings) {
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month, 1);
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    
    return bookings.where((booking) {
      return booking.checkInDate.isAfter(thisMonth.subtract(const Duration(days: 1))) &&
             booking.checkInDate.isBefore(nextMonth);
    }).toList();
  }

  List<Booking> _getUpcomingBookings(List<Booking> bookings) {
    final now = DateTime.now();
    return bookings.where((booking) {
      return booking.checkInDate.isAfter(now) && 
             (booking.status == BookingStatus.confirmed || booking.status == BookingStatus.pending);
    }).toList();
  }

  String _calculateAverageTransaction() {
    final total = widget.customer.totalSpent ?? 0.0;
    final transactions = 4; // Mock count
    return transactions > 0 ? (total / transactions).toStringAsFixed(2) : '0.00';
  }

  // Action methods
  void _showAddPetDialog() {
    // Implementation for adding pet
  }

  void _showPetDetails(Pet pet) {
    // Implementation for showing pet details
  }

  void _showPetVaccinations(Pet pet) {
    // Implementation for showing pet vaccinations
  }



  void _showEditCustomerDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Customer Profile'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // First Name
                  TextFormField(
                    initialValue: customer.firstName,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Handle first name change
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Last Name
                  TextFormField(
                    initialValue: customer.lastName,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Handle last name change
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Email
                  TextFormField(
                    initialValue: customer.email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Handle email change
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Phone
                  TextFormField(
                    initialValue: customer.phoneNumber,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      // Handle phone change
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Address
                  TextFormField(
                    initialValue: customer.address ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Address',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      // Handle address change
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Notes
                  TextFormField(
                    initialValue: customer.notes ?? '',
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (value) {
                      // Handle notes change
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
              onPressed: () {
                // TODO: Implement save functionality
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Customer profile updated successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Color _getCustomerStatusColor(CustomerStatus status) {
    switch (status) {
      case CustomerStatus.active:
        return Colors.green;
      case CustomerStatus.inactive:
        return Colors.grey;
      case CustomerStatus.blacklisted:
        return Colors.red;
      case CustomerStatus.pendingVerification:
        return Colors.orange;
      case CustomerStatus.suspended:
        return Colors.red;
    }
  }

  Widget _buildStatusChip(CustomerStatus status) {
    return Chip(
      label: Text(
        status.name,
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: _getCustomerStatusColor(status),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildLoyaltyChip(LoyaltyTier tier) {
    return Chip(
      label: Text(
        tier.name.toUpperCase(),
        style: const TextStyle(fontSize: 12, color: Colors.white),
      ),
      backgroundColor: Colors.amber,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Color _getPetTypeColor(PetType type) {
    switch (type) {
      case PetType.dog:
        return Colors.brown;
      case PetType.cat:
        return Colors.orange;
      case PetType.bird:
        return Colors.blue;
      case PetType.guineaPig:
        return Colors.pink;
      case PetType.rabbit:
        return Colors.grey;
      case PetType.hamster:
        return Colors.amber;
      case PetType.guineaPig:
        return Colors.pink;
      case PetType.ferret:
        return Colors.indigo;
      case PetType.other:
        return Colors.grey;
    }
  }

  IconData _getPetTypeIcon(PetType type) {
    switch (type) {
      case PetType.dog:
        return Icons.pets;
      case PetType.cat:
        return Icons.pets;
      case PetType.bird:
        return Icons.flutter_dash;
      case PetType.guineaPig:
        return Icons.pets;
      case PetType.rabbit:
        return Icons.pets;
      case PetType.hamster:
        return Icons.pets;
      case PetType.ferret:
        return Icons.pets;
      case PetType.other:
        return Icons.pets;
    }
  }

  Widget _buildVaccinationsTab() {
    return FutureBuilder<List<Vaccination>>(
      future: _vaccinationsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final vaccinations = snapshot.data ?? [];
        
        return Column(
          children: [
            // Summary cards
            Row(
              children: [
                Expanded(child: _buildSummaryCard('Total Vaccinations', vaccinations.length.toString(), Icons.vaccines, Colors.green)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('Upcoming', '${_getUpcomingVaccinations(vaccinations).length}', Icons.schedule, Colors.orange)),
                const SizedBox(width: 16),
                Expanded(child: _buildSummaryCard('Overdue', '${_getOverdueVaccinations(vaccinations).length}', Icons.warning, Colors.red)),
              ],
            ),
            const SizedBox(height: 24),
            
            // Search and filter bar
            _buildVaccinationSearchBar(),
            const SizedBox(height: 16),
            
            // Vaccinations list
            Expanded(
              child: vaccinations.isEmpty
                  ? const Center(child: Text('No vaccinations found'))
                  : ListView.builder(
                      itemCount: vaccinations.length,
                      itemBuilder: (context, index) => _buildVaccinationCard(vaccinations[index]),
                    ),
            ),
          ],
        );
      },
    );
  }

  void _showScheduleAppointmentDialog() {
    final _formKey = GlobalKey<FormState>();
    final _serviceController = TextEditingController();
    final _notesController = TextEditingController();
    DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Appointment'),
        content: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _serviceController,
                    decoration: const InputDecoration(
                      labelText: 'Service Type',
                      hintText: 'e.g., Grooming, Boarding, Check-up',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a service type';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          title: const Text('Date'),
                          subtitle: Text(_formatDate(_selectedDate)),
                          trailing: const Icon(Icons.calendar_today),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                _selectedDate = date;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ListTile(
                          title: const Text('Time'),
                          subtitle: Text(_selectedTime.format(context)),
                          trailing: const Icon(Icons.access_time),
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: _selectedTime,
                            );
                            if (time != null) {
                              setState(() {
                                _selectedTime = time;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      hintText: 'Any special instructions or notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Here you would typically save the appointment
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Appointment scheduled for ${widget.customer.firstName} ${widget.customer.lastName} on ${_formatDate(_selectedDate)} at ${_selectedTime.format(context)}'),
                  ),
                );
              }
            },
            child: const Text('Schedule'),
          ),
        ],
      ),
    );
  }

  void _showSendMessageDialog() {
    final _formKey = GlobalKey<FormState>();
    final _subjectController = TextEditingController();
    final _messageController = TextEditingController();
    String _selectedMethod = 'email';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send Message'),
        content: SizedBox(
          width: 500,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: _selectedMethod,
                    decoration: const InputDecoration(
                      labelText: 'Contact Method',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'email', child: Text('Email')),
                      DropdownMenuItem(value: 'sms', child: Text('SMS')),
                      DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedMethod = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _subjectController,
                    decoration: const InputDecoration(
                      labelText: 'Subject',
                      hintText: 'Message subject',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a subject';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      hintText: 'Type your message here',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a message';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Here you would typically send the message
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Message sent to ${widget.customer.firstName} ${widget.customer.lastName} via ${_selectedMethod.toUpperCase()}'),
                  ),
                );
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                // TODO: Implement search functionality
              },
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            hint: const Text('Filter by Status'),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
              DropdownMenuItem(value: 'refunded', child: Text('Refunded')),
              DropdownMenuItem(value: 'voided', child: Text('Voided')),
            ],
            onChanged: (value) {
              // TODO: Implement filter functionality
            },
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement export functionality
            },
            icon: const Icon(Icons.download),
            label: const Text('Export'),
          ),
        ],
      ),
    );
  }

  Widget _buildPOSTransactionCard(POSTransaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Transaction #${transaction.receiptNumber ?? transaction.id.substring(0, 8)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${transaction.items.length} items • ${transaction.paymentMethod}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${transaction.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildTransactionStatusChip(transaction.status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(transaction.completedAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (transaction.cashierName != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Cashier: ${transaction.cashierName}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            if (transaction.items.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Items:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...transaction.items.take(3).map((item) => Text(
                      '• ${item.name} x${item.quantity}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 11,
                      ),
                    )),
                    if (transaction.items.length > 3)
                      Text(
                        '... and ${transaction.items.length - 3} more items',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showTransactionDetails(transaction),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Details'),
                ),
                const SizedBox(width: 8),
                if (transaction.status == 'completed')
                  TextButton.icon(
                    onPressed: () => _showRefundDialog(transaction),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refund'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'refunded':
        color = Colors.orange;
        break;
      case 'voided':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showTransactionDetails(POSTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transaction #${transaction.receiptNumber ?? transaction.id.substring(0, 8)}'),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTransactionDetailRow('Date', _formatDateTime(transaction.completedAt)),
                _buildTransactionDetailRow('Status', transaction.status),
                _buildTransactionDetailRow('Payment Method', transaction.paymentMethod),
                _buildTransactionDetailRow('Total Amount', '\$${transaction.totalAmount.toStringAsFixed(2)}'),
                if (transaction.subtotal != null)
                  _buildTransactionDetailRow('Subtotal', '\$${transaction.subtotal!.toStringAsFixed(2)}'),
                if (transaction.taxAmount != null)
                  _buildTransactionDetailRow('Tax', '\$${transaction.taxAmount!.toStringAsFixed(2)}'),
                if (transaction.discountAmount != null)
                  _buildTransactionDetailRow('Discount', '\$${transaction.discountAmount!.toStringAsFixed(2)}'),
                if (transaction.cashierName != null)
                  _buildTransactionDetailRow('Cashier', transaction.cashierName!),
                const SizedBox(height: 16),
                const Text(
                  'Items:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...transaction.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${item.name} x${item.quantity}'),
                      ),
                      Text('\$${(item.price * item.quantity).toStringAsFixed(2)}'),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _showRefundDialog(POSTransaction transaction) {
    final _reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refund Transaction'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to refund this transaction?'),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Refund Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement refund functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refund functionality will be implemented')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Process Refund'),
          ),
        ],
      ),
    );
  }

  void _showPetDetailsDialog(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => PetDetailsDialog(pet: pet),
    );
  }

  void _showEditPetDialog(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => EditPetDialog(
        pet: pet,
        onUpdate: (updatedPet) async {
          await _petDao.update(updatedPet);
          setState(() {
            _petsFuture = _petDao.getByCustomerId(widget.customer.id);
          });
        },
      ),
    );
  }

  void _showPetVaccinationsDialog(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${pet.name} - Vaccination Records'),
        content: SizedBox(
          width: 600,
          height: 400,
          child: FutureBuilder<List<Vaccination>>(
            future: _vaccinationDao.getByPetId(pet.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              
              final vaccinations = snapshot.data ?? [];
              
              if (vaccinations.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.vaccines, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No vaccination records found'),
                    ],
                  ),
                );
              }
              
              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${vaccinations.length} vaccination records'),
                      ElevatedButton.icon(
                        onPressed: () => _showAddVaccinationDialog(pet),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Vaccination'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: vaccinations.length,
                      itemBuilder: (context, index) {
                        final vaccination = vaccinations[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              Icons.vaccines,
                              color: vaccination.isExpired ? Colors.red : Colors.green,
                            ),
                            title: Text(vaccination.name),
                            subtitle: Text(
                              'Administered: ${_formatDate(vaccination.administeredDate)}\n'
                              'Expires: ${_formatDate(vaccination.expiryDate)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () => _showVaccinationDetailsDialog(vaccination),
                                  icon: const Icon(Icons.visibility),
                                  tooltip: 'View Details',
                                ),
                                IconButton(
                                  onPressed: () => _showEditVaccinationDialog(vaccination),
                                  icon: const Icon(Icons.edit),
                                  tooltip: 'Edit',
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddVaccinationDialog(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => EditVaccinationDialog(
        vaccination: Vaccination(
          id: '',
          petId: pet.id,
          petName: pet.name,
          customerId: widget.customer.id,
          customerName: widget.customer.fullName,
          type: VaccinationType.core,
          name: '',
          administeredDate: DateTime.now(),
          expiryDate: DateTime.now().add(const Duration(days: 365)),
          administeredBy: '',
          clinicName: '',
          status: VaccinationStatus.upToDate,
        ),
        onUpdate: (vaccination) async {
          await _vaccinationDao.create(vaccination);
          setState(() {
            _petsFuture = _petDao.getByCustomerId(widget.customer.id);
          });
        },
      ),
    );
  }

  void _showVaccinationDetailsDialog(Vaccination vaccination) {
    showDialog(
      context: context,
      builder: (context) => VaccinationDetailsDialog(vaccination: vaccination),
    );
  }



  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildPaymentSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search payments...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                // TODO: Implement search functionality
              },
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            hint: const Text('Filter by Status'),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'failed', child: Text('Failed')),
              DropdownMenuItem(value: 'refunded', child: Text('Refunded')),
            ],
            onChanged: (value) {
              // TODO: Implement filter functionality
            },
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            hint: const Text('Filter by Method'),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Methods')),
              DropdownMenuItem(value: 'cash', child: Text('Cash')),
              DropdownMenuItem(value: 'credit_card', child: Text('Credit Card')),
              DropdownMenuItem(value: 'digital_wallet', child: Text('Digital Wallet')),
              DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
            ],
            onChanged: (value) {
              // TODO: Implement filter functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTransactionCard(PaymentTransaction payment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment #${payment.id.substring(0, 8)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${payment.paymentMethod.name} • ${payment.type.name.toUpperCase()}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${payment.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildPaymentStatusChip(payment.status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  _formatDateTime(payment.createdAt),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (payment.processedBy != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.person, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Processed by: ${payment.processedBy}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            if (payment.referenceNumber != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.receipt, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Ref: ${payment.referenceNumber}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            if (payment.notes != null && payment.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  payment.notes!,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showPaymentDetails(payment),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Details'),
                ),
                const SizedBox(width: 8),
                if (payment.status == PaymentStatus.completed)
                  TextButton.icon(
                    onPressed: () => _showRefundPaymentDialog(payment),
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Refund'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.orange,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentStatusChip(PaymentStatus status) {
    Color color;
    switch (status) {
      case PaymentStatus.completed:
        color = Colors.green;
        break;
      case PaymentStatus.pending:
        color = Colors.orange;
        break;
      case PaymentStatus.failed:
        color = Colors.red;
        break;
      case PaymentStatus.refunded:
        color = Colors.blue;
        break;
      case PaymentStatus.partiallyRefunded:
        color = Colors.purple;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showPaymentDetails(PaymentTransaction payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment #${payment.id.substring(0, 8)}'),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPaymentDetailRow('Amount', '\$${payment.amount.toStringAsFixed(2)}'),
                _buildPaymentDetailRow('Status', payment.status.name.toUpperCase()),
                _buildPaymentDetailRow('Payment Method', payment.paymentMethod.name),
                _buildPaymentDetailRow('Type', payment.type.name.toUpperCase()),
                _buildPaymentDetailRow('Date', _formatDateTime(payment.createdAt)),
                if (payment.processedAt != null)
                  _buildPaymentDetailRow('Processed At', _formatDateTime(payment.processedAt!)),
                if (payment.completedAt != null)
                  _buildPaymentDetailRow('Completed At', _formatDateTime(payment.completedAt!)),
                if (payment.referenceNumber != null)
                  _buildPaymentDetailRow('Reference Number', payment.referenceNumber!),
                if (payment.authorizationCode != null)
                  _buildPaymentDetailRow('Authorization Code', payment.authorizationCode!),
                if (payment.cardType != null)
                  _buildPaymentDetailRow('Card Type', payment.cardType!),
                if (payment.cardLast4 != null)
                  _buildPaymentDetailRow('Card Last 4', payment.cardLast4!),
                if (payment.processingFee != null)
                  _buildPaymentDetailRow('Processing Fee', '\$${payment.processingFee!.toStringAsFixed(2)}'),
                if (payment.taxAmount != null)
                  _buildPaymentDetailRow('Tax Amount', '\$${payment.taxAmount!.toStringAsFixed(2)}'),
                if (payment.currency != null)
                  _buildPaymentDetailRow('Currency', payment.currency!),
                if (payment.processedBy != null)
                  _buildPaymentDetailRow('Processed By', payment.processedBy!),
                if (payment.notes != null && payment.notes!.isNotEmpty)
                  _buildPaymentDetailRow('Notes', payment.notes!),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _showRefundPaymentDialog(PaymentTransaction payment) {
    final _reasonController = TextEditingController();
    final _amountController = TextEditingController(text: payment.amount.toStringAsFixed(2));
    double _refundAmount = payment.amount;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refund Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Original Amount: \$${payment.amount.toStringAsFixed(2)}'),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Refund Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Refund Amount: '),
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      _refundAmount = double.tryParse(value) ?? payment.amount;
                    },
                    decoration: const InputDecoration(
                      prefixText: '\$',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement refund functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Refund of \$${_refundAmount.toStringAsFixed(2)} will be processed'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Process Refund'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search bookings...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                // TODO: Implement search functionality
              },
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            hint: const Text('Filter by Status'),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'confirmed', child: Text('Confirmed')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'checkedIn', child: Text('Checked In')),
              DropdownMenuItem(value: 'checkedOut', child: Text('Checked Out')),
              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
            onChanged: (value) {
              // TODO: Implement filter functionality
            },
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            hint: const Text('Filter by Type'),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Types')),
              DropdownMenuItem(value: 'standard', child: Text('Standard')),
              DropdownMenuItem(value: 'extended', child: Text('Extended')),
              DropdownMenuItem(value: 'grooming', child: Text('Grooming')),
              DropdownMenuItem(value: 'medical', child: Text('Medical')),
            ],
            onChanged: (value) {
              // TODO: Implement filter functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${booking.bookingNumber} • ${booking.petName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${booking.type.name.toUpperCase()} • Room ${booking.roomNumber}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${booking.totalAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildBookingStatusChip(booking.status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Check-in: ${_formatDate(booking.checkInDate)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Check-out: ${_formatDate(booking.checkOutDate)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (booking.additionalServices != null && booking.additionalServices!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: booking.additionalServices!.map((service) => 
                  Chip(
                    label: Text(service),
                    backgroundColor: Colors.blue[50],
                    labelStyle: TextStyle(
                      color: Colors.blue[700],
                      fontSize: 10,
                    ),
                  ),
                ).toList(),
              ),
            ],
            if (booking.specialInstructions != null && booking.specialInstructions!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.amber[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.specialInstructions!,
                        style: TextStyle(
                          color: Colors.amber[700],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showBookingDetails(booking),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Details'),
                ),
                const SizedBox(width: 8),
                if (booking.status == BookingStatus.confirmed || booking.status == BookingStatus.pending)
                  TextButton.icon(
                    onPressed: () => _showModifyBookingDialog(booking),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Modify'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.blue,
                    ),
                  ),
                const SizedBox(width: 8),
                if (booking.status == BookingStatus.confirmed || booking.status == BookingStatus.pending)
                  TextButton.icon(
                    onPressed: () => _showCancelBookingDialog(booking),
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text('Cancel'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingStatusChip(BookingStatus status) {
    Color color;
    switch (status) {
      case BookingStatus.confirmed:
        color = Colors.green;
        break;
      case BookingStatus.pending:
        color = Colors.orange;
        break;
      case BookingStatus.checkedIn:
        color = Colors.blue;
        break;
      case BookingStatus.checkedOut:
        color = Colors.purple;
        break;
      case BookingStatus.cancelled:
        color = Colors.red;
        break;
      case BookingStatus.noShow:
        color = Colors.grey;
        break;
      case BookingStatus.completed:
        color = Colors.teal;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showBookingDetails(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking ${booking.bookingNumber}'),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildBookingDetailRow('Pet', booking.petName),
                _buildBookingDetailRow('Room', 'Room ${booking.roomNumber}'),
                _buildBookingDetailRow('Type', booking.type.name.toUpperCase()),
                _buildBookingDetailRow('Status', booking.status.name.toUpperCase()),
                _buildBookingDetailRow('Check-in Date', _formatDate(booking.checkInDate)),
                _buildBookingDetailRow('Check-out Date', _formatDate(booking.checkOutDate)),
                _buildBookingDetailRow('Check-in Time', '${booking.checkInTime.hour.toString().padLeft(2, '0')}:${booking.checkInTime.minute.toString().padLeft(2, '0')}'),
                _buildBookingDetailRow('Check-out Time', '${booking.checkOutTime.hour.toString().padLeft(2, '0')}:${booking.checkOutTime.minute.toString().padLeft(2, '0')}'),
                _buildBookingDetailRow('Base Price/Night', '\$${booking.basePricePerNight.toStringAsFixed(2)}'),
                _buildBookingDetailRow('Total Amount', '\$${booking.totalAmount.toStringAsFixed(2)}'),
                if (booking.depositAmount != null)
                  _buildBookingDetailRow('Deposit', '\$${booking.depositAmount!.toStringAsFixed(2)}'),
                if (booking.assignedStaffName != null)
                  _buildBookingDetailRow('Assigned Staff', booking.assignedStaffName!),
                if (booking.paymentMethod != null)
                  _buildBookingDetailRow('Payment Method', booking.paymentMethod!),
                if (booking.paymentStatus != null)
                  _buildBookingDetailRow('Payment Status', booking.paymentStatus!),
                if (booking.specialInstructions != null && booking.specialInstructions!.isNotEmpty)
                  _buildBookingDetailRow('Special Instructions', booking.specialInstructions!),
                if (booking.careNotes != null && booking.careNotes!.isNotEmpty)
                  _buildBookingDetailRow('Care Notes', booking.careNotes!),
                if (booking.additionalServices != null && booking.additionalServices!.isNotEmpty)
                  _buildBookingDetailRow('Additional Services', booking.additionalServices!.join(', ')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showModifyBookingDialog(Booking booking) {
    // TODO: Implement booking modification dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modify Booking'),
        content: const Text('Booking modification functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCancelBookingDialog(Booking booking) {
    final _reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to cancel booking ${booking.bookingNumber}?'),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Cancellation Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Booking'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement cancellation functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking ${booking.bookingNumber} has been cancelled'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }

  List<Vaccination> _getUpcomingVaccinations(List<Vaccination> vaccinations) {
    final now = DateTime.now();
    final nextMonth = now.add(const Duration(days: 30));
    
    return vaccinations.where((vaccination) {
      return vaccination.expiryDate.isAfter(now) && 
             vaccination.expiryDate.isBefore(nextMonth) &&
             vaccination.status == VaccinationStatus.upToDate;
    }).toList();
  }

  List<Vaccination> _getOverdueVaccinations(List<Vaccination> vaccinations) {
    final now = DateTime.now();
    
    return vaccinations.where((vaccination) {
      return vaccination.expiryDate.isBefore(now) &&
             vaccination.status == VaccinationStatus.upToDate;
    }).toList();
  }

  Widget _buildVaccinationSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search vaccinations...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                // TODO: Implement search functionality
              },
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            hint: const Text('Filter by Status'),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'expired', child: Text('Expired')),
              DropdownMenuItem(value: 'notApplicable', child: Text('Not Applicable')),
            ],
            onChanged: (value) {
              // TODO: Implement filter functionality
            },
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            hint: const Text('Filter by Type'),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All Types')),
              DropdownMenuItem(value: 'rabies', child: Text('Rabies')),
              DropdownMenuItem(value: 'dhpp', child: Text('DHPP')),
              DropdownMenuItem(value: 'bordetella', child: Text('Bordetella')),
              DropdownMenuItem(value: 'feline', child: Text('Feline')),
            ],
            onChanged: (value) {
              // TODO: Implement filter functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationCard(Vaccination vaccination) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vaccination.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${vaccination.type.displayName} • Pet: ${vaccination.petName}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatDate(vaccination.expiryDate),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: vaccination.expiryDate.isBefore(DateTime.now()) 
                            ? Colors.red 
                            : vaccination.expiryDate.isBefore(DateTime.now().add(const Duration(days: 30)))
                                ? Colors.orange
                                : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildVaccinationStatusChip(vaccination.status),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Administered: ${_formatDate(vaccination.administeredDate)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  'Vet: ${vaccination.administeredBy}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            if (vaccination.notes != null && vaccination.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  vaccination.notes!,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showVaccinationDetails(vaccination),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Details'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showEditVaccinationDialog(vaccination),
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                  ),
                ),
                const SizedBox(width: 8),
                if (vaccination.status == VaccinationStatus.upToDate)
                  TextButton.icon(
                    onPressed: () => _showScheduleVaccinationDialog(vaccination),
                    icon: const Icon(Icons.schedule, size: 16),
                    label: const Text('Schedule'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationStatusChip(VaccinationStatus status) {
    Color color;
    switch (status) {
      case VaccinationStatus.upToDate:
        color = Colors.green;
        break;
      case VaccinationStatus.expired:
        color = Colors.red;
        break;
      case VaccinationStatus.notApplicable:
        color = Colors.grey;
        break;
      case VaccinationStatus.upToDate:
        color = Colors.blue;
        break;
      case VaccinationStatus.dueSoon:
        color = Colors.orange;
        break;
      case VaccinationStatus.overdue:
        color = Colors.red[700]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showVaccinationDetails(Vaccination vaccination) {
    showDialog(
      context: context,
      builder: (context) => VaccinationDetailsDialog(vaccination: vaccination),
    );
  }

  void _showEditVaccinationDialog(Vaccination vaccination) {
    showDialog(
      context: context,
      builder: (context) => EditVaccinationDialog(
        vaccination: vaccination,
        onUpdate: (updatedVaccination) async {
          await _vaccinationDao.update(updatedVaccination);
          setState(() {
            _vaccinationsFuture = _vaccinationDao.getByCustomerId(widget.customer.id);
          });
        },
      ),
    );
  }



  void _showScheduleVaccinationDialog(Vaccination vaccination) {
    // TODO: Implement vaccination scheduling dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Schedule Vaccination'),
        content: const Text('Vaccination scheduling functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltySearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search loyalty transactions...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) {
                // TODO: Implement search functionality
              },
            ),
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            hint: const Text('Filter by Type'),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'earned', child: Text('Earned')),
              DropdownMenuItem(value: 'redeemed', child: Text('Redeemed')),
              DropdownMenuItem(value: 'expired', child: Text('Expired')),
              DropdownMenuItem(value: 'adjusted', child: Text('Adjusted')),
            ],
            onChanged: (value) {
              // TODO: Implement filter functionality
            },
          ),
          const SizedBox(width: 16),
          DropdownButton<String>(
            hint: const Text('Filter by Status'),
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All')),
              DropdownMenuItem(value: 'pending', child: Text('Pending')),
              DropdownMenuItem(value: 'completed', child: Text('Completed')),
              DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
            ],
            onChanged: (value) {
              // TODO: Implement filter functionality
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyTransactionCard(LoyaltyTransaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${transaction.type.name.toUpperCase()} • ${_formatDateTime(transaction.createdAt)}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${transaction.points > 0 ? '+' : ''}${transaction.points}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: transaction.points > 0 ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildLoyaltyTransactionStatusChip(transaction.status),
                  ],
                ),
              ],
            ),
            if (transaction.referenceId != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.receipt, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Reference: ${transaction.referenceId}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
            if (transaction.notes != null && transaction.notes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  transaction.notes!,
                  style: TextStyle(
                    color: Colors.blue[700],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _showLoyaltyTransactionDetails(transaction),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Details'),
                ),
                if (transaction.status == LoyaltyTransactionStatus.pending) ...[
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _showProcessLoyaltyTransactionDialog(transaction),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Process'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoyaltyTransactionStatusChip(LoyaltyTransactionStatus status) {
    Color color;
    switch (status) {
      case LoyaltyTransactionStatus.pending:
        color = Colors.orange;
        break;
      case LoyaltyTransactionStatus.completed:
        color = Colors.green;
        break;
      case LoyaltyTransactionStatus.cancelled:
        color = Colors.red;
        break;
      case LoyaltyTransactionStatus.failed:
        color = Colors.red[700]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showLoyaltyTransactionDetails(LoyaltyTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Loyalty Transaction #${transaction.id.substring(0, 8)}'),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLoyaltyDetailRow('Description', transaction.description),
                _buildLoyaltyDetailRow('Type', transaction.type.name.toUpperCase()),
                _buildLoyaltyDetailRow('Points', '${transaction.points > 0 ? '+' : ''}${transaction.points}'),
                _buildLoyaltyDetailRow('Status', transaction.status.name.toUpperCase()),
                _buildLoyaltyDetailRow('Date', _formatDateTime(transaction.createdAt)),
                if (transaction.processedAt != null)
                  _buildLoyaltyDetailRow('Processed At', _formatDateTime(transaction.processedAt!)),
                if (transaction.referenceId != null)
                  _buildLoyaltyDetailRow('Reference ID', transaction.referenceId!),
                if (transaction.notes != null && transaction.notes!.isNotEmpty)
                  _buildLoyaltyDetailRow('Notes', transaction.notes!),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoyaltyDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showProcessLoyaltyTransactionDialog(LoyaltyTransaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Loyalty Transaction'),
        content: Text('Are you sure you want to process this loyalty transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement processing functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Loyalty transaction processed successfully'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Process'),
          ),
        ],
      ),
    );
  }
}


