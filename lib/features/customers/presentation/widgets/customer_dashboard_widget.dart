import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/pet.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/vaccination.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/waiver.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/incident.dart';

class CustomerDashboardWidget extends ConsumerWidget {
  final Customer customer;
  final List<Pet> pets;
  final List<Vaccination> vaccinations;
  final List<Waiver> waivers;
  final List<Incident> incidents;

  const CustomerDashboardWidget({
    super.key,
    required this.customer,
    required this.pets,
    required this.vaccinations,
    required this.waivers,
    required this.incidents,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomerHeader(context),
          const SizedBox(height: 24),
          _buildQuickStats(),
          const SizedBox(height: 24),
          _buildPetsSection(context),
          const SizedBox(height: 24),
          _buildVaccinationsSection(context),
          const SizedBox(height: 24),
          _buildWaiversSection(context),
          const SizedBox(height: 24),
          _buildIncidentsSection(context),
        ],
      ),
    );
  }

  Widget _buildCustomerHeader(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                customer.fullName[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customer.fullName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    customer.customerCode,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.phone,
                        customer.phoneNumber,
                        Colors.blue,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.email,
                        customer.email,
                        Colors.green,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.location_on,
                        customer.address ?? 'No address',
                        Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildStatusBadge(customer.status),
                const SizedBox(height: 8),
                if (customer.loyaltyTier != null)
                  _buildLoyaltyBadge(customer.loyaltyTier!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(CustomerStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case CustomerStatus.active:
        color = Colors.green;
        text = 'Active';
        break;
      case CustomerStatus.inactive:
        color = Colors.grey;
        text = 'Inactive';
        break;
      case CustomerStatus.blacklisted:
        color = Colors.red;
        text = 'Blacklisted';
        break;
      case CustomerStatus.pendingVerification:
        color = Colors.orange;
        text = 'Pending';
        break;
      case CustomerStatus.suspended:
        color = Colors.red;
        text = 'Suspended';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildLoyaltyBadge(LoyaltyTier tier) {
    Color color;
    String text;
    
    switch (tier) {
      case LoyaltyTier.bronze:
        color = Colors.brown;
        text = 'Bronze';
        break;
      case LoyaltyTier.silver:
        color = Colors.grey;
        text = 'Silver';
        break;
      case LoyaltyTier.gold:
        color = Colors.amber;
        text = 'Gold';
        break;
      case LoyaltyTier.platinum:
        color = Colors.blueGrey;
        text = 'Platinum';
        break;
      case LoyaltyTier.diamond:
        color = Colors.cyan;
        text = 'Diamond';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Pets',
            '${pets.length}',
            Icons.pets,
            Colors.blue,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Vaccinations',
            '${vaccinations.where((v) => v.isExpired).length} Expired',
            Icons.medical_services,
            Colors.red,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Waivers',
            '${waivers.where((w) => w.needsSignature).length} Pending',
            Icons.description,
            Colors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Incidents',
            '${incidents.where((i) => i.isOpen).length} Open',
            Icons.warning,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetsSection(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.pets, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Pets',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Navigate to pet management
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Pet'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (pets.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No pets registered',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  final pet = pets[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: Icon(Icons.pets, color: Colors.blue),
                    ),
                    title: Text(pet.displayName),
                    subtitle: Text('${pet.breed ?? 'Unknown breed'} • ${pet.age} years old'),
                    trailing: pet.needsSpecialCare
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Special Care',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationsSection(BuildContext context) {
    final expiredVaccinations = vaccinations.where((v) => v.isExpired).toList();
    final dueSoonVaccinations = vaccinations.where((v) => v.isDueSoon).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medical_services, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'Vaccinations',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Navigate to vaccination management
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Vaccination'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (expiredVaccinations.isNotEmpty) ...[
              _buildAlertSection(
                'Expired Vaccinations',
                expiredVaccinations.length,
                Colors.red,
                Icons.warning,
              ),
              const SizedBox(height: 12),
            ],
            if (dueSoonVaccinations.isNotEmpty) ...[
              _buildAlertSection(
                'Due Soon',
                dueSoonVaccinations.length,
                Colors.orange,
                Icons.schedule,
              ),
              const SizedBox(height: 12),
            ],
            if (vaccinations.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No vaccination records',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaiversSection(BuildContext context) {
    final pendingWaivers = waivers.where((w) => w.needsSignature).toList();
    final expiredWaivers = waivers.where((w) => w.isExpired).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Waivers & Consents',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Navigate to waiver management
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Waiver'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (pendingWaivers.isNotEmpty) ...[
              _buildAlertSection(
                'Pending Signatures',
                pendingWaivers.length,
                Colors.orange,
                Icons.edit,
              ),
              const SizedBox(height: 12),
            ],
            if (expiredWaivers.isNotEmpty) ...[
              _buildAlertSection(
                'Expired Waivers',
                expiredWaivers.length,
                Colors.red,
                Icons.warning,
              ),
              const SizedBox(height: 12),
            ],
            if (waivers.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No waiver records',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentsSection(BuildContext context) {
    final openIncidents = incidents.where((i) => i.isOpen).toList();
    final criticalIncidents = incidents.where((i) => i.isCritical).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'Incidents & Issues',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    // TODO: Navigate to incident management
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Report Incident'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (criticalIncidents.isNotEmpty) ...[
              _buildAlertSection(
                'Critical Incidents',
                criticalIncidents.length,
                Colors.purple,
                Icons.error,
              ),
              const SizedBox(height: 12),
            ],
            if (openIncidents.isNotEmpty) ...[
              _buildAlertSection(
                'Open Incidents',
                openIncidents.length,
                Colors.red,
                Icons.warning,
              ),
              const SizedBox(height: 12),
            ],
            if (incidents.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No incident records',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertSection(String title, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(
            '$title: $count',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
