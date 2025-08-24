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
    _tabController = TabController(length: 8, vsync: this); // Increased tabs
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
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Customers', icon: Icon(Icons.people)),
            Tab(text: 'Pets', icon: Icon(Icons.pets)),
            Tab(text: 'Vaccinations', icon: Icon(Icons.medical_services)),
            Tab(text: 'Waivers & Incidents', icon: Icon(Icons.description)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
            Tab(text: 'Loyalty', icon: Icon(Icons.card_giftcard)),
            Tab(text: 'Communication', icon: Icon(Icons.message)),
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
                _buildPetsTab(),
                _buildVaccinationsTab(),
                _buildWaiversIncidentsTab(),
                _buildAnalyticsTab(),
                _buildLoyaltyTab(),
                _buildCommunicationTab(),
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
            
            // Customer list
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
                  : ListView.builder(
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
    return FutureBuilder<List<Vaccination>>(
      future: _vaccinationDao.getAll(),
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
                Text('Error loading vaccinations: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        
        final vaccinations = snapshot.data ?? [];
        
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
                          'Vaccination Management',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${vaccinations.length} vaccination records',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showScheduleVaccinationDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Schedule Vaccination'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: _showVaccinationReminders,
                    icon: const Icon(Icons.notifications),
                    label: const Text('Due Soon'),
                  ),
                ],
              ),
            ),
            
            // Vaccination list
            Expanded(
              child: vaccinations.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.medical_services_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No vaccination records found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Schedule your first vaccination to get started',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: vaccinations.length,
                      itemBuilder: (context, index) {
                        final vaccination = vaccinations[index];
                        return _buildVaccinationCard(vaccination);
                      },
                    ),
            ),
          ],
        );
      },
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
            child: const TabBar(
              labelColor: Colors.black87,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
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
                  : ListView.builder(
                      itemCount: waivers.length,
                      itemBuilder: (context, index) {
                        final waiver = waivers[index];
                        return _buildWaiverCard(waiver);
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
                  : ListView.builder(
                      itemCount: incidents.length,
                      itemBuilder: (context, index) {
                        final incident = incidents[index];
                        return _buildIncidentCard(incident);
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
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildEnhancedStatCard(
          'Total Customers',
          '${data['totalCustomers'] ?? 0}',
          Icons.people,
          Colors.blue,
          subtitle: '${data['activeCustomers'] ?? 0} active',
          trend: data['customerGrowth'] ?? 0.0,
        ),
        _buildEnhancedStatCard(
          'Total Pets',
          '${data['totalPets'] ?? 0}',
          Icons.pets,
          Colors.green,
          subtitle: '${data['activePets'] ?? 0} active',
          trend: data['petGrowth'] ?? 0.0,
        ),
        _buildEnhancedStatCard(
          'Expiring Vaccinations',
          '${data['expiringVaccinations'] ?? 0}',
          Icons.warning,
          Colors.orange,
          subtitle: 'Next 30 days',
          trend: data['vaccinationTrend'] ?? 0.0,
        ),
        _buildEnhancedStatCard(
          'Pending Waivers',
          '${data['pendingWaivers'] ?? 0}',
          Icons.description,
          Colors.purple,
          subtitle: 'Requires attention',
          trend: data['waiverTrend'] ?? 0.0,
        ),
        _buildEnhancedStatCard(
          'Open Incidents',
          '${data['openIncidents'] ?? 0}',
          Icons.report_problem,
          Colors.red,
          subtitle: 'Needs resolution',
          trend: data['incidentTrend'] ?? 0.0,
        ),
        _buildEnhancedStatCard(
          'Loyalty Members',
          '${data['loyaltyMembers'] ?? 0}',
          Icons.card_giftcard,
          Colors.teal,
          subtitle: '${data['loyaltyPercentage'] ?? 0}% of total',
          trend: data['loyaltyGrowth'] ?? 0.0,
        ),
        _buildEnhancedStatCard(
          'New This Month',
          '${data['newCustomersThisMonth'] ?? 0}',
          Icons.person_add,
          Colors.indigo,
          subtitle: 'Customer acquisition',
          trend: data['acquisitionTrend'] ?? 0.0,
        ),
        _buildEnhancedStatCard(
          'Avg. Customer Value',
          '\$${data['averageCustomerValue']?.toStringAsFixed(2) ?? '0.00'}',
          Icons.attach_money,
          Colors.amber,
          subtitle: 'Lifetime value',
          trend: data['valueTrend'] ?? 0.0,
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
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildQuickActionButton(
                  'Add Customer',
                  Icons.person_add,
                  Colors.blue,
                  () => _showAddCustomerDialog(),
                ),
                _buildQuickActionButton(
                  'Add Pet',
                  Icons.pets,
                  Colors.green,
                  () => _showAddPetDialog(),
                ),
                _buildQuickActionButton(
                  'Schedule Vaccination',
                  Icons.medical_services,
                  Colors.orange,
                  () => _showScheduleVaccinationDialog(),
                ),
                _buildQuickActionButton(
                  'Send Reminder',
                  Icons.notifications,
                  Colors.purple,
                  () => _showSendReminderDialog(),
                ),
                _buildQuickActionButton(
                  'Generate Report',
                  Icons.assessment,
                  Colors.teal,
                  () => _generateCustomerReport(),
                ),
                _buildQuickActionButton(
                  'Bulk Import',
                  Icons.upload_file,
                  Colors.indigo,
                  () => _showBulkImportDialog(),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
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

  // Customer card widget
  Widget _buildCustomerCard(Customer customer) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getCustomerStatusColor(customer.status),
          child: Text(
            '${customer.firstName[0]}${customer.lastName[0]}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          '${customer.firstName} ${customer.lastName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(customer.email),
            Text(customer.phoneNumber),
            Row(
              children: [
                _buildStatusChip(customer.status),
                const SizedBox(width: 8),
                if (customer.loyaltyTier != null)
                  _buildLoyaltyChip(customer.loyaltyTier!),
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
                // Customer details
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Address', customer.address),
                          _buildDetailRow('Registration Date', 
                            _formatDate(customer.createdAt)),
                          _buildDetailRow('Last Visit', 
                            customer.lastVisitDate != null ? _formatDate(customer.lastVisitDate!) : 'Never'),
                          _buildDetailRow('Total Spent', 
                            '\$${customer.totalSpent?.toStringAsFixed(2) ?? '0.00'}'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Source', customer.source.displayName),
                          _buildDetailRow('Birth Date', 
                            customer.dateOfBirth != null ? _formatDate(customer.dateOfBirth!) : 'Unknown'),
                          _buildDetailRow('Notes', customer.notes ?? 'No notes'),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Emergency contacts
                if (customer.emergencyContacts != null && customer.emergencyContacts!.isNotEmpty) ...[
                  const Text(
                    'Emergency Contacts:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...customer.emergencyContacts!.map((contact) => 
                    _buildEmergencyContact(contact)),
                  const SizedBox(height: 16),
                ],
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showEditCustomerDialog(customer),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showCustomerDetailsDialog(customer),
                      icon: const Icon(Icons.info),
                      label: const Text('Details'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _showDeleteCustomerDialog(customer),
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
  
  Color _getPetTypeColor(PetType type) {
    switch (type) {
      case PetType.cat:
        return Colors.orange;
      case PetType.dog:
        return Colors.blue;
      case PetType.bird:
        return Colors.green;
      case PetType.rabbit:
        return Colors.brown;
      case PetType.hamster:
        return Colors.grey;
      case PetType.guineaPig:
        return Colors.pink;
      case PetType.ferret:
        return Colors.purple;
      case PetType.other:
        return Colors.grey[600]!;
    }
  }
  
  IconData _getPetTypeIcon(PetType type) {
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
  
  // ... existing code ...

  // Additional dialog methods
  void _showEditCustomerDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Customer: ${customer.firstName} ${customer.lastName}'),
        content: const Text('Edit customer form coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showCustomerDetailsDialog(Customer customer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Customer Details: ${customer.firstName} ${customer.lastName}'),
        content: const Text('Detailed customer view coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
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
      builder: (context) => AlertDialog(
        title: Text('Edit Pet: ${pet.name}'),
        content: const Text('Edit pet form coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPetDetailsDialog(Pet pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pet Details: ${pet.name}'),
        content: const Text('Detailed pet view coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
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
      builder: (context) => AlertDialog(
        title: Text('Edit Vaccination: ${vaccination.name}'),
        content: const Text('Edit vaccination form coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showVaccinationDetailsDialog(Vaccination vaccination) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Vaccination Details: ${vaccination.name}'),
        content: const Text('Detailed vaccination view coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
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
      builder: (context) => AlertDialog(
        title: Text('Edit Waiver: ${waiver.title}'),
        content: const Text('Edit waiver form coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showWaiverDetailsDialog(Waiver waiver) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Waiver Details: ${waiver.title}'),
        content: const Text('Detailed waiver view coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
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
      builder: (context) => AlertDialog(
        title: Text('Edit Incident: ${incident.type.name}'),
        content: const Text('Edit incident form coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showIncidentDetailsDialog(Incident incident) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Incident Details: ${incident.type.name}'),
        content: const Text('Detailed incident view coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
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
}


