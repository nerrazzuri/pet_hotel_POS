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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
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
        title: const Text('Customer & Pet Profiles'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
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
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildCustomersTab(),
          _buildPetsTab(),
          _buildVaccinationsTab(),
          _buildWaiversIncidentsTab(),
        ],
      ),
    );
  }
  
  Widget _buildOverviewTab() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getOverviewData(),
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
              _buildOverviewCards(data),
              const SizedBox(height: 24),
              _buildQuickActions(),
              const SizedBox(height: 24),
              _buildRecentActivity(),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildOverviewCards(Map<String, dynamic> data) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          'Total Customers',
          '${data['totalCustomers'] ?? 0}',
          Icons.people,
          Colors.blue,
        ),
        _buildStatCard(
          'Total Pets',
          '${data['totalPets'] ?? 0}',
          Icons.pets,
          Colors.green,
        ),
        _buildStatCard(
          'Expiring Vaccinations',
          '${data['expiringVaccinations'] ?? 0}',
          Icons.warning,
          Colors.orange,
        ),
        _buildStatCard(
          'Pending Waivers',
          '${data['pendingWaivers'] ?? 0}',
          Icons.description,
          Colors.purple,
        ),
        _buildStatCard(
          'Open Incidents',
          '${data['openIncidents'] ?? 0}',
          Icons.report_problem,
          Colors.red,
        ),
        _buildStatCard(
          'Total Vaccinations',
          '${data['totalVaccinations'] ?? 0}',
          Icons.medical_services,
          Colors.teal,
        ),
      ],
    );
  }
  
  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
            Icon(icon, size: 32, color: color),
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
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddCustomerDialog(context),
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Customer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddPetDialog(context),
                    icon: const Icon(Icons.pets),
                    label: const Text('Add Pet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddVaccinationDialog(context),
                    icon: const Icon(Icons.medical_services),
                    label: const Text('Add Vaccination'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddWaiverDialog(context),
                    icon: const Icon(Icons.description),
                    label: const Text('Add Waiver'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecentActivity() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getRecentActivityData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }
        
        final activities = snapshot.data ?? <Map<String, dynamic>>[];
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                if (activities.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No recent activity'),
                    ),
                  )
                else
                  ...activities.map((activity) => _buildActivityItem(
                    activity['icon'],
                    activity['title'],
                    activity['subtitle'],
                    activity['time'],
                    activity['color'],
                  )).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildActivityItem(IconData icon, String title, String subtitle, String time, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
          ),
        ],
      ),
    );
  }
  
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
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading customers: ${snapshot.error}'),
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search customers...',
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
                    onPressed: () => _showAddCustomerDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Customer'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: customers.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No customers found'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
  
  Widget _buildCustomerCard(Customer customer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
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
                _buildStatusChip(customer.status),
                if (customer.loyaltyPoints != null && customer.loyaltyPoints! > 0 && customer.loyaltyTier != null) ...[
                  const SizedBox(width: 8),
                  _buildLoyaltyChip(customer.loyaltyTier!),
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
                _showCustomerDetailsDialog(context, customer);
                break;
              case 'edit':
                _showEditCustomerDialog(context, customer);
                break;
              case 'delete':
                _showDeleteCustomerDialog(context, customer);
                break;
            }
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customer Information',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('Status: ${customer.status.name}'),
                if (customer.loyaltyPoints != null)
                  Text('Loyalty Points: ${customer.loyaltyPoints}'),
                if (customer.lastVisitDate != null)
                  Text('Last Visit: ${_formatDate(customer.lastVisitDate!)}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Show detailed customer dashboard
                  },
                  child: const Text('View Full Profile'),
                ),
              ],
            ),
          ),
        ],
      ),
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
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error loading pets: ${snapshot.error}'),
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search pets...',
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
                    onPressed: () => _showAddPetDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Pet'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: pets.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.pets, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No pets found'),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
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
  
  Widget _buildPetCard(Pet pet) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
            Text('${pet.breed} • ${pet.color}'),
            Text('Owner: ${pet.customerName}'),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (pet.isVaccinated ?? false)
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (pet.isVaccinated ?? false) ? 'Vaccinated' : 'Not Vaccinated',
                    style: TextStyle(
                      color: (pet.isVaccinated ?? false) ? Colors.green : Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (pet.specialNeeds != null && pet.specialNeeds!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Special Care',
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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
                _showPetDetailsDialog(context, pet);
                break;
              case 'edit':
                _showEditPetDialog(context, pet);
                break;
              case 'delete':
                _showDeletePetDialog(context, pet);
                break;
            }
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pet Information',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text('Type: ${pet.type.name}'),
                Text('Gender: ${pet.gender.name}'),
                Text('Size: ${pet.size.name}'),
                if (pet.dateOfBirth != null)
                  Text('Date of Birth: ${_formatDate(pet.dateOfBirth!)}'),
                if (pet.weight != null)
                  Text('Weight: ${pet.weight} kg'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Show detailed pet profile
                  },
                  child: const Text('View Full Profile'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVaccinationsTab() {
    return FutureBuilder<List<Vaccination>>(
      future: Future.value(_vaccinationDao.getAll()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error loading vaccinations',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final vaccinations = snapshot.data ?? [];

        return Column(
          children: [
            // Header with Add Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vaccination Records',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          'Manage pet vaccination records and track expiry dates',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddVaccinationDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Vaccination'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Vaccinations List
            Expanded(
              child: vaccinations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.medical_services, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No vaccination records found',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start by adding vaccination records for your pets',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: vaccinations.length,
                      itemBuilder: (context, index) {
                        final vaccination = vaccinations[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getVaccinationStatusColor(vaccination.status),
                              child: Icon(
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
                                Text('${vaccination.petName} • ${vaccination.customerName}'),
                                Text('Type: ${_getVaccinationTypeDisplay(vaccination.type)}'),
                                Text('Administered: ${_formatDate(vaccination.administeredDate)}'),
                                Text('Expires: ${_formatDate(vaccination.expiryDate)}'),
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getVaccinationStatusColor(vaccination.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getVaccinationStatusDisplay(vaccination.status),
                                    style: TextStyle(
                                      color: _getVaccinationStatusColor(vaccination.status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'view':
                                    // TODO: Show vaccination details
                                    break;
                                  case 'edit':
                                    // TODO: Edit vaccination
                                    break;
                                  case 'delete':
                                    // TODO: Delete vaccination
                                    break;
                                }
                              },
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
                            ),
                          ),
                        );
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
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade200,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.purple,
              ),
              tabs: const [
                Tab(
                  icon: Icon(Icons.description),
                  text: 'Waivers',
                ),
                Tab(
                  icon: Icon(Icons.report),
                  text: 'Incidents',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tab Content
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
      future: Future.value(_waiverDao.getAll()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error loading waivers',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final waivers = snapshot.data ?? [];

        return Column(
          children: [
            // Header with Add Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Customer Waivers & Consent Forms',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          'Manage customer waivers, consent forms, and legal documents',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddWaiverDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Waiver'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Waivers List
            Expanded(
              child: waivers.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.description, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No waivers found',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start by adding waivers and consent forms',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: waivers.length,
                      itemBuilder: (context, index) {
                        final waiver = waivers[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getWaiverStatusColor(waiver.status),
                              child: Icon(
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
                                Text('${waiver.customerName}${waiver.petName != null ? ' • ${waiver.petName}' : ''}'),
                                Text('Type: ${_getWaiverTypeDisplay(waiver.type)}'),
                                Text('Created: ${_formatDate(waiver.createdAt)}'),
                                if (waiver.expiryDate != null)
                                  Text('Expires: ${_formatDate(waiver.expiryDate!)}'),
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getWaiverStatusColor(waiver.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getWaiverStatusDisplay(waiver.status),
                                    style: TextStyle(
                                      color: _getWaiverStatusColor(waiver.status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'view':
                                    // TODO: Show waiver details
                                    break;
                                  case 'edit':
                                    // TODO: Edit waiver
                                    break;
                                  case 'delete':
                                    // TODO: Delete waiver
                                    break;
                                }
                              },
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
                            ),
                          ),
                        );
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
      future: Future.value(_incidentDao.getAll()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text(
                  'Error loading incidents',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  snapshot.error.toString(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final incidents = snapshot.data ?? [];

        return Column(
          children: [
            // Header with Add Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Incident Reports',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          'Track and manage incidents, accidents, and behavioral issues',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddIncidentDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Report Incident'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Incidents List
            Expanded(
              child: incidents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.report, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'No incidents found',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start by reporting any incidents or issues',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: incidents.length,
                      itemBuilder: (context, index) {
                        final incident = incidents[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: _getIncidentSeverityColor(incident.severity),
                              child: Icon(
                                Icons.report,
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
                                Text('${incident.petName} • ${incident.customerName}'),
                                Text('Type: ${_getIncidentTypeDisplay(incident.type)}'),
                                Text('Severity: ${_getIncidentSeverityDisplay(incident.severity)}'),
                                Text('Reported: ${_formatDate(incident.reportedDate)}'),
                                Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getIncidentStatusColor(incident.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _getIncidentStatusDisplay(incident.status),
                                    style: TextStyle(
                                      color: _getIncidentStatusColor(incident.status),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'view':
                                    // TODO: Show incident details
                                    break;
                                  case 'edit':
                                    // TODO: Edit incident
                                    break;
                                  case 'delete':
                                    // TODO: Delete incident
                                    break;
                                }
                              },
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
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
  
  // Helper methods
  Color _getPetTypeColor(PetType type) {
    switch (type) {
      case PetType.cat:
        return Colors.orange;
      case PetType.dog:
        return Colors.brown;
      case PetType.bird:
        return Colors.blue;
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
  
  Future<Map<String, dynamic>> _getOverviewData() async {
    try {
      final customers = await _customerDao.getAll();
      final pets = await _petDao.getAll();
      final vaccinations = await _vaccinationDao.getAll();
      final waivers = await _waiverDao.getAll();
      final incidents = await _incidentDao.getAll();
      
      final expiringVaccinations = await _vaccinationDao.getExpiringSoon(30);
      final pendingWaivers = await _waiverDao.getPendingSignatures();
      final openIncidents = await _incidentDao.getOpenIncidents();
      
      return {
        'totalCustomers': customers.length,
        'totalPets': pets.length,
        'expiringVaccinations': expiringVaccinations.length,
        'pendingWaivers': pendingWaivers.length,
        'openIncidents': openIncidents.length,
        'totalVaccinations': vaccinations.length,
        'totalWaivers': waivers.length,
        'totalIncidents': incidents.length,
      };
    } catch (e) {
      return {
        'totalCustomers': 0,
        'totalPets': 0,
        'expiringVaccinations': 0,
        'pendingWaivers': 0,
        'openIncidents': 0,
        'totalVaccinations': 0,
        'totalWaivers': 0,
        'totalIncidents': 0,
      };
    }
  }
  
  Future<List<Map<String, dynamic>>> _getRecentActivityData() async {
    try {
      final activities = <Map<String, dynamic>>[];
      final now = DateTime.now();
      
      // Get recent vaccinations
      final vaccinations = await _vaccinationDao.getAll();
      for (final vaccination in vaccinations.take(3)) {
        final daysAgo = now.difference(vaccination.createdAt ?? now).inDays;
        activities.add({
          'icon': Icons.medical_services,
          'title': 'Vaccination Recorded',
          'subtitle': '${vaccination.petName} - ${vaccination.name}',
          'time': daysAgo == 0 ? 'Today' : '$daysAgo days ago',
          'color': Colors.green,
        });
      }
      
      // Get recent waivers
      final waivers = await _waiverDao.getAll();
      for (final waiver in waivers.take(2)) {
        final daysAgo = now.difference(waiver.createdAt ?? now).inDays;
        activities.add({
          'icon': Icons.description,
          'title': 'Waiver ${waiver.status.name}',
          'subtitle': '${waiver.customerName} - ${waiver.title}',
          'time': daysAgo == 0 ? 'Today' : '$daysAgo days ago',
          'color': waiver.status == WaiverStatus.signed ? Colors.green : Colors.orange,
        });
      }
      
      // Get recent incidents
      final incidents = await _incidentDao.getAll();
      for (final incident in incidents.take(2)) {
        final daysAgo = now.difference(incident.reportedDate ?? now).inDays;
        activities.add({
          'icon': Icons.report_problem,
          'title': 'Incident ${incident.status.name}',
          'subtitle': '${incident.petName} - ${incident.title}',
          'time': daysAgo == 0 ? 'Today' : '$daysAgo days ago',
          'color': incident.severity == IncidentSeverity.critical ? Colors.red : Colors.orange,
        });
      }
      
      // Sort by creation date and take the most recent 5
      activities.sort((a, b) {
        final aTime = a['time'] as String;
        final bTime = b['time'] as String;
        if (aTime == 'Today') return -1;
        if (bTime == 'Today') return 1;
        final aDays = int.tryParse(aTime.split(' ')[0]) ?? 0;
        final bDays = int.tryParse(bTime.split(' ')[0]) ?? 0;
        return aDays.compareTo(bDays);
      });
      
      return activities.take(5).toList();
    } catch (e) {
      return [];
    }
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getCustomerStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getCustomerStatusDisplay(status),
        style: TextStyle(
          color: _getCustomerStatusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLoyaltyChip(LoyaltyTier tier) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, size: 12, color: Colors.amber),
          const SizedBox(width: 8),
          Text(
            _getLoyaltyTierDisplay(tier),
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  Color _getVaccinationStatusColor(VaccinationStatus status) {
    switch (status) {
      case VaccinationStatus.upToDate:
        return Colors.green;
      case VaccinationStatus.expired:
        return Colors.red;
      case VaccinationStatus.dueSoon:
        return Colors.orange;
      case VaccinationStatus.overdue:
        return Colors.red;
      case VaccinationStatus.notApplicable:
        return Colors.grey;
    }
  }
  
  String _getVaccinationTypeDisplay(VaccinationType type) {
    switch (type) {
      case VaccinationType.core:
        return 'Core Vaccination';
      case VaccinationType.nonCore:
        return 'Non-Core Vaccination';
      case VaccinationType.rabies:
        return 'Rabies';
      case VaccinationType.bordetella:
        return 'Bordetella';
      case VaccinationType.dhpp:
        return 'DHPP';
      case VaccinationType.fvrcp:
        return 'FVRCP';
      case VaccinationType.lyme:
        return 'Lyme Disease';
      case VaccinationType.leptospirosis:
        return 'Leptospirosis';
      case VaccinationType.canineInfluenza:
        return 'Canine Influenza';
      case VaccinationType.felineLeukemia:
        return 'Feline Leukemia';
      case VaccinationType.other:
        return 'Other';
    }
  }
  
  String _getVaccinationStatusDisplay(VaccinationStatus status) {
    switch (status) {
      case VaccinationStatus.upToDate:
        return 'Up to Date';
      case VaccinationStatus.expired:
        return 'Expired';
      case VaccinationStatus.dueSoon:
        return 'Due Soon';
      case VaccinationStatus.overdue:
        return 'Overdue';
      case VaccinationStatus.notApplicable:
        return 'Not Applicable';
    }
  }
  
  Color _getWaiverStatusColor(WaiverStatus status) {
    switch (status) {
      case WaiverStatus.pending:
        return Colors.orange;
      case WaiverStatus.signed:
        return Colors.green;
      case WaiverStatus.expired:
        return Colors.red;
      case WaiverStatus.revoked:
        return Colors.red;
      case WaiverStatus.notRequired:
        return Colors.grey;
    }
  }
  
  String _getWaiverTypeDisplay(WaiverType type) {
    switch (type) {
      case WaiverType.boardingConsent:
        return 'Boarding Consent';
      case WaiverType.groomingConsent:
        return 'Grooming Consent';
      case WaiverType.medicalTreatment:
        return 'Medical Treatment Consent';
      case WaiverType.emergencyContact:
        return 'Emergency Contact Authorization';
      case WaiverType.photoRelease:
        return 'Photo Release';
      case WaiverType.liabilityWaiver:
        return 'Liability Waiver';
      case WaiverType.vaccinationWaiver:
        return 'Vaccination Waiver';
      case WaiverType.other:
        return 'Other';
    }
  }
  
  String _getWaiverStatusDisplay(WaiverStatus status) {
    switch (status) {
      case WaiverStatus.pending:
        return 'Pending';
      case WaiverStatus.signed:
        return 'Signed';
      case WaiverStatus.expired:
        return 'Expired';
      case WaiverStatus.revoked:
        return 'Revoked';
      case WaiverStatus.notRequired:
        return 'Not Required';
    }
  }
  
  Color _getIncidentSeverityColor(IncidentSeverity severity) {
    switch (severity) {
      case IncidentSeverity.minor:
        return Colors.green;
      case IncidentSeverity.moderate:
        return Colors.orange;
      case IncidentSeverity.major:
        return Colors.red;
      case IncidentSeverity.critical:
        return Colors.purple;
    }
  }
  
  String _getIncidentTypeDisplay(IncidentType type) {
    switch (type) {
      case IncidentType.medical:
        return 'Medical';
      case IncidentType.behavioral:
        return 'Behavioral';
      case IncidentType.accident:
        return 'Accident';
      case IncidentType.injury:
        return 'Injury';
      case IncidentType.escape:
        return 'Escape';
      case IncidentType.aggression:
        return 'Aggression';
      case IncidentType.anxiety:
        return 'Anxiety';
      case IncidentType.dietary:
        return 'Dietary';
      case IncidentType.other:
        return 'Other';
    }
  }
  
  String _getIncidentSeverityDisplay(IncidentSeverity severity) {
    switch (severity) {
      case IncidentSeverity.minor:
        return 'Minor';
      case IncidentSeverity.moderate:
        return 'Moderate';
      case IncidentSeverity.major:
        return 'Major';
      case IncidentSeverity.critical:
        return 'Critical';
    }
  }
  
  String _getIncidentStatusDisplay(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.reported:
        return 'Reported';
      case IncidentStatus.investigating:
        return 'Investigating';
      case IncidentStatus.resolved:
        return 'Resolved';
      case IncidentStatus.closed:
        return 'Closed';
      case IncidentStatus.escalated:
        return 'Escalated';
    }
  }
  
  Color _getIncidentStatusColor(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.reported:
        return Colors.orange;
      case IncidentStatus.investigating:
        return Colors.blue;
      case IncidentStatus.resolved:
        return Colors.green;
      case IncidentStatus.closed:
        return Colors.grey;
      case IncidentStatus.escalated:
        return Colors.red;
    }
  }
  
  String _getCustomerStatusDisplay(CustomerStatus status) {
    switch (status) {
      case CustomerStatus.active:
        return 'Active';
      case CustomerStatus.inactive:
        return 'Inactive';
      case CustomerStatus.blacklisted:
        return 'Blacklisted';
      case CustomerStatus.pendingVerification:
        return 'Pending Verification';
      case CustomerStatus.suspended:
        return 'Suspended';
    }
  }
  
  String _getLoyaltyTierDisplay(LoyaltyTier tier) {
    switch (tier) {
      case LoyaltyTier.bronze:
        return 'Bronze';
      case LoyaltyTier.silver:
        return 'Silver';
      case LoyaltyTier.gold:
        return 'Gold';
      case LoyaltyTier.platinum:
        return 'Platinum';
      case LoyaltyTier.diamond:
        return 'Diamond';
    }
  }
  
  // Dialog methods (placeholders for now)
  void _showAddCustomerDialog(BuildContext context) {
    // TODO: Implement add customer dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Customer functionality coming soon')),
    );
  }
  
  void _showAddPetDialog(BuildContext context) {
    // TODO: Implement add pet dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Pet functionality coming soon')),
    );
  }
  
  void _showAddVaccinationDialog(BuildContext context) {
    // TODO: Implement add vaccination dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Vaccination functionality coming soon')),
    );
  }
  
  void _showAddWaiverDialog(BuildContext context) {
    // TODO: Implement add waiver dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Waiver functionality coming soon')),
    );
  }

  void _showAddIncidentDialog(BuildContext context) {
    // TODO: Implement add incident dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add Incident functionality coming soon')),
    );
  }
  
  void _showCustomerDetailsDialog(BuildContext context, Customer customer) {
    // TODO: Implement customer details dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Customer details functionality coming soon')),
    );
  }
  
  void _showEditCustomerDialog(BuildContext context, Customer customer) {
    // TODO: Implement edit customer dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit customer functionality coming soon')),
    );
  }
  
  void _showDeleteCustomerDialog(BuildContext context, Customer customer) {
    // TODO: Implement delete customer dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delete customer functionality coming soon')),
    );
  }
  
  void _showPetDetailsDialog(BuildContext context, Pet pet) {
    // TODO: Implement pet details dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pet details functionality coming soon')),
    );
  }
  
  void _showEditPetDialog(BuildContext context, Pet pet) {
    // TODO: Implement edit pet dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit pet functionality coming soon')),
    );
  }
  
  void _showDeletePetDialog(BuildContext context, Pet pet) {
    // TODO: Implement delete pet dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delete pet functionality coming soon')),
    );
  }
}
