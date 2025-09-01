import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/pet.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/vaccination.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/deworming_record.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/pet_document.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/pet_weight_record.dart';
import 'package:cat_hotel_pos/features/customers/domain/services/vaccination_check_service.dart';
import 'package:cat_hotel_pos/core/services/pet_dao.dart';
import 'package:cat_hotel_pos/core/services/vaccination_dao.dart';
import 'package:cat_hotel_pos/core/services/deworming_dao.dart';
import 'package:cat_hotel_pos/core/services/pet_document_dao.dart';
import 'package:cat_hotel_pos/core/services/pet_weight_dao.dart';

class EnhancedPetProfileWidget extends ConsumerStatefulWidget {
  final Pet pet;

  const EnhancedPetProfileWidget({
    super.key,
    required this.pet,
  });

  @override
  ConsumerState<EnhancedPetProfileWidget> createState() => _EnhancedPetProfileWidgetState();
}

class _EnhancedPetProfileWidgetState extends ConsumerState<EnhancedPetProfileWidget>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final VaccinationCheckService _vaccinationCheckService = VaccinationCheckService(
    petDao: PetDao(),
    vaccinationDao: VaccinationDao(),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
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
        title: Text('${widget.pet.name}\'s Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Weight', icon: Icon(Icons.monitor_weight)),
            Tab(text: 'Vaccinations', icon: Icon(Icons.vaccines)),
            Tab(text: 'Deworming', icon: Icon(Icons.medical_services)),
            Tab(text: 'Documents', icon: Icon(Icons.folder)),
            Tab(text: 'Health', icon: Icon(Icons.favorite)),
            Tab(text: 'Care', icon: Icon(Icons.pets)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildWeightTab(),
          _buildVaccinationsTab(),
          _buildDewormingTab(),
          _buildDocumentsTab(),
          _buildHealthTab(),
          _buildCareTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPetHeader(),
          const SizedBox(height: 24),
          _buildBasicInfo(),
          const SizedBox(height: 24),
          _buildVaccinationStatus(),
          const SizedBox(height: 24),
          _buildWeightSummary(),
          const SizedBox(height: 24),
          _buildSpecialNeeds(),
        ],
      ),
    );
  }

  Widget _buildPetHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: _getPetTypeColor(widget.pet.type),
              child: Icon(
                _getPetTypeIcon(widget.pet.type),
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.pet.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.pet.breed ?? 'Unknown Breed'} • ${widget.pet.type.displayName}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Age: ${widget.pet.age} years (${widget.pet.ageInMonths} months)',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (widget.pet.weight != null)
                    Text(
                      'Weight: ${widget.pet.weight!.toStringAsFixed(1)} ${widget.pet.weightUnit ?? 'kg'}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Gender', widget.pet.gender.displayName),
            _buildInfoRow('Size', widget.pet.size.displayName),
            _buildInfoRow('Color', widget.pet.color ?? 'Not specified'),
            if (widget.pet.microchipNumber != null)
              _buildInfoRow('Microchip', widget.pet.microchipNumber!),
            _buildInfoRow('Neutered', widget.pet.isNeutered == true ? 'Yes' : 'No'),
            _buildInfoRow('Spayed', widget.pet.isSpayed == true ? 'Yes' : 'No'),
            if (widget.pet.temperament != null)
              _buildInfoRow('Temperament', widget.pet.temperament!.displayName),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationStatus() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _vaccinationCheckService.checkVaccinationStatus(widget.pet.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: ${snapshot.error}'),
            ),
          );
        }

        final status = snapshot.data!;
        final canCheckIn = status['canCheckIn'] as bool;
        final blockingVaccinations = status['blockingVaccinations'] as List<Vaccination>;
        final expiringSoon = status['expiringSoon'] as List<Vaccination>;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Vaccination Status',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: canCheckIn ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        canCheckIn ? 'CLEAR' : 'BLOCKED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (blockingVaccinations.isNotEmpty) ...[
                  const Text(
                    'Expired Vaccinations (Blocking Check-in):',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...blockingVaccinations.map((v) => _buildVaccinationItem(v, true)),
                  const SizedBox(height: 16),
                ],
                if (expiringSoon.isNotEmpty) ...[
                  const Text(
                    'Expiring Soon:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...expiringSoon.map((v) => _buildVaccinationItem(v, false)),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVaccinationItem(Vaccination vaccination, bool isExpired) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isExpired ? Colors.red.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isExpired ? Colors.red.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            vaccination.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Expires: ${_formatDate(vaccination.expiryDate)}'),
          if (vaccination.administeredBy != null)
            Text('Administered by: ${vaccination.administeredBy}'),
        ],
      ),
    );
  }

  Widget _buildWeightSummary() {
    return FutureBuilder<PetWeightRecord?>(
      future: PetWeightDao().getLatestByPetId(widget.pet.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        final latestRecord = snapshot.data;
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weight Summary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (latestRecord != null) ...[
                  _buildInfoRow('Current Weight', latestRecord.weightDisplay),
                  _buildInfoRow('Recorded', _formatDate(latestRecord.recordedAt)),
                  if (latestRecord.weightChange != null)
                    _buildInfoRow('Change', latestRecord.weightChangeDisplay),
                  if (latestRecord.bodyConditionScore != null)
                    _buildInfoRow('Body Condition', latestRecord.bodyConditionDescription),
                ] else ...[
                  const Text('No weight records available'),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpecialNeeds() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Special Needs & Health',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (widget.pet.allergies != null && widget.pet.allergies!.isNotEmpty) ...[
              const Text(
                'Allergies:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...widget.pet.allergies!.map((allergy) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.orange, size: 16),
                    const SizedBox(width: 8),
                    Text(allergy),
                  ],
                ),
              )),
              const SizedBox(height: 16),
            ],
            if (widget.pet.medications != null && widget.pet.medications!.isNotEmpty) ...[
              const Text(
                'Medications:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...widget.pet.medications!.map((medication) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.medication, color: Colors.blue, size: 16),
                    const SizedBox(width: 8),
                    Text(medication),
                  ],
                ),
              )),
              const SizedBox(height: 16),
            ],
            if (widget.pet.specialNeeds != null && widget.pet.specialNeeds!.isNotEmpty) ...[
              const Text(
                'Special Needs:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...widget.pet.specialNeeds!.map((need) => Padding(
                padding: const EdgeInsets.only(left: 16, bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Text(need),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeightTab() {
    return FutureBuilder<List<PetWeightRecord>>(
      future: PetWeightDao().getByPetId(widget.pet.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final records = snapshot.data ?? [];
        
        if (records.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.monitor_weight_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No weight records available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        records.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getWeightTypeColor(record.type),
                  child: Icon(
                    _getWeightTypeIcon(record.type),
                    color: Colors.white,
                  ),
                ),
                title: Text(record.weightDisplay),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(record.type.displayName),
                    Text('Recorded: ${_formatDate(record.recordedAt)}'),
                    if (record.weightChange != null)
                      Text(
                        record.weightChangeDisplay,
                        style: TextStyle(
                          color: record.isWeightGain ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                  onSelected: (value) {
                    // Handle edit/delete
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildVaccinationsTab() {
    return FutureBuilder<List<Vaccination>>(
      future: VaccinationDao().getByPetId(widget.pet.id),
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
                Icon(Icons.vaccines_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No vaccination records available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        vaccinations.sort((a, b) => b.expiryDate.compareTo(a.expiryDate));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: vaccinations.length,
          itemBuilder: (context, index) {
            final vaccination = vaccinations[index];
            final isExpired = vaccination.expiryDate.isBefore(DateTime.now());
            final isExpiringSoon = vaccination.expiryDate.difference(DateTime.now()).inDays <= 30;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isExpired 
                      ? Colors.red 
                      : isExpiringSoon 
                          ? Colors.orange 
                          : Colors.green,
                  child: Icon(
                    Icons.vaccines,
                    color: Colors.white,
                  ),
                ),
                title: Text(vaccination.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Expires: ${_formatDate(vaccination.expiryDate)}'),
                    if (vaccination.administeredBy != null)
                      Text('Administered by: ${vaccination.administeredBy}'),
                    if (vaccination.clinicName != null)
                      Text('Clinic: ${vaccination.clinicName}'),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                  onSelected: (value) {
                    // Handle edit/delete
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDewormingTab() {
    return FutureBuilder<List<DewormingRecord>>(
      future: DewormingDao().getByPetId(widget.pet.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final records = snapshot.data ?? [];
        
        if (records.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medical_services_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No deworming records available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        records.sort((a, b) => b.scheduledDate.compareTo(a.scheduledDate));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            final isOverdue = record.isOverdue;
            final isDueSoon = record.isDueSoon;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isOverdue 
                      ? Colors.red 
                      : isDueSoon 
                          ? Colors.orange 
                          : Colors.green,
                  child: Icon(
                    Icons.medical_services,
                    color: Colors.white,
                  ),
                ),
                title: Text(record.productName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Type: ${record.type.displayName}'),
                    Text('Status: ${record.statusDisplay}'),
                    Text('Scheduled: ${_formatDate(record.scheduledDate)}'),
                    if (record.nextDueDate != null)
                      Text('Next Due: ${_formatDate(record.nextDueDate!)}'),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                  onSelected: (value) {
                    // Handle edit/delete
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDocumentsTab() {
    return FutureBuilder<List<PetDocument>>(
      future: PetDocumentDao().getByPetId(widget.pet.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final documents = snapshot.data ?? [];
        
        if (documents.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No documents available',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        documents.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            final document = documents[index];
            final isExpired = document.isExpired;
            final isExpiringSoon = document.isExpiringSoon;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isExpired 
                      ? Colors.red 
                      : isExpiringSoon 
                          ? Colors.orange 
                          : Colors.green,
                  child: Icon(
                    _getDocumentTypeIcon(document.type),
                    color: Colors.white,
                  ),
                ),
                title: Text(document.title ?? document.fileName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Type: ${document.type.displayName}'),
                    Text('Status: ${document.statusDisplay}'),
                    Text('Size: ${document.fileSizeDisplay}'),
                    Text('Uploaded: ${_formatDate(document.createdAt)}'),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Text('View'),
                    ),
                    const PopupMenuItem(
                      value: 'download',
                      child: Text('Download'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                  onSelected: (value) {
                    // Handle view/download/delete
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHealthTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMedicalHistory(),
          const SizedBox(height: 24),
          _buildAllergiesSection(),
          const SizedBox(height: 24),
          _buildMedicationsSection(),
          const SizedBox(height: 24),
          _buildVeterinarianInfo(),
        ],
      ),
    );
  }

  Widget _buildMedicalHistory() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medical History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (widget.pet.medicalHistory != null && widget.pet.medicalHistory!.isNotEmpty) ...[
              ...widget.pet.medicalHistory!.map((history) => _buildMedicalHistoryItem(history)),
            ] else ...[
              const Text('No medical history available'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalHistoryItem(MedicalHistory history) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            history.condition,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Diagnosed: ${_formatDate(history.diagnosedDate)}'),
          Text('By: ${history.diagnosedBy}'),
          if (history.treatment != null) Text('Treatment: ${history.treatment}'),
          if (history.medication != null) Text('Medication: ${history.medication}'),
          if (history.notes != null) Text('Notes: ${history.notes}'),
        ],
      ),
    );
  }

  Widget _buildAllergiesSection() {
    if (widget.pet.allergies == null || widget.pet.allergies!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Allergies',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.pet.allergies!.map((allergy) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.orange),
                  const SizedBox(width: 8),
                  Expanded(child: Text(allergy)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationsSection() {
    if (widget.pet.medications == null || widget.pet.medications!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Current Medications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.pet.medications!.map((medication) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.medication, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(child: Text(medication)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildVeterinarianInfo() {
    if (widget.pet.veterinarianName == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Veterinarian Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Name', widget.pet.veterinarianName!),
            if (widget.pet.veterinarianPhone != null)
              _buildInfoRow('Phone', widget.pet.veterinarianPhone!),
            if (widget.pet.veterinarianClinic != null)
              _buildInfoRow('Clinic', widget.pet.veterinarianClinic!),
          ],
        ),
      ),
    );
  }

  Widget _buildCareTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeedingSchedule(),
          const SizedBox(height: 24),
          _buildSpecialNeedsSection(),
          const SizedBox(height: 24),
          _buildBehaviorNotes(),
          const SizedBox(height: 24),
          _buildInsuranceInfo(),
        ],
      ),
    );
  }

  Widget _buildFeedingSchedule() {
    if (widget.pet.feedingSchedule == null) {
      return const SizedBox.shrink();
    }

    final schedule = widget.pet.feedingSchedule!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Feeding Schedule',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Type', schedule.type.displayName),
            _buildInfoRow('Food Type', schedule.foodType),
            _buildInfoRow('Portion Size', '${schedule.portionSize} ${schedule.portionUnit ?? 'units'}'),
            if (schedule.specialInstructions != null)
              _buildInfoRow('Special Instructions', schedule.specialInstructions!),
            if (schedule.notes != null)
              _buildInfoRow('Notes', schedule.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialNeedsSection() {
    if (widget.pet.specialNeeds == null || widget.pet.specialNeeds!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Special Care Needs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.pet.specialNeeds!.map((need) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  const Icon(Icons.info, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(child: Text(need)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBehaviorNotes() {
    if (widget.pet.behaviorNotes == null || widget.pet.behaviorNotes!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Behavior Notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(widget.pet.behaviorNotes!),
          ],
        ),
      ),
    );
  }

  Widget _buildInsuranceInfo() {
    if (widget.pet.insuranceProvider == null) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Insurance Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Provider', widget.pet.insuranceProvider!),
            if (widget.pet.insurancePolicyNumber != null)
              _buildInfoRow('Policy Number', widget.pet.insurancePolicyNumber!),
            if (widget.pet.insuranceExpiryDate != null)
              _buildInfoRow('Expiry Date', _formatDate(widget.pet.insuranceExpiryDate!)),
          ],
        ),
      ),
    );
  }

  // Helper methods
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
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

  Color _getWeightTypeColor(WeightRecordType type) {
    switch (type) {
      case WeightRecordType.routine:
        return Colors.blue;
      case WeightRecordType.preBoarding:
        return Colors.orange;
      case WeightRecordType.postBoarding:
        return Colors.green;
      case WeightRecordType.medical:
        return Colors.red;
      case WeightRecordType.grooming:
        return Colors.purple;
      case WeightRecordType.vaccination:
        return Colors.teal;
      case WeightRecordType.deworming:
        return Colors.indigo;
      case WeightRecordType.other:
        return Colors.grey;
    }
  }

  IconData _getWeightTypeIcon(WeightRecordType type) {
    switch (type) {
      case WeightRecordType.routine:
        return Icons.monitor_weight;
      case WeightRecordType.preBoarding:
        return Icons.hotel;
      case WeightRecordType.postBoarding:
        return Icons.check_circle;
      case WeightRecordType.medical:
        return Icons.medical_services;
      case WeightRecordType.grooming:
        return Icons.content_cut;
      case WeightRecordType.vaccination:
        return Icons.vaccines;
      case WeightRecordType.deworming:
        return Icons.medication;
      case WeightRecordType.other:
        return Icons.monitor_weight;
    }
  }

  IconData _getDocumentTypeIcon(DocumentType type) {
    switch (type) {
      case DocumentType.vaccinationCertificate:
        return Icons.vaccines;
      case DocumentType.medicalRecord:
        return Icons.medical_services;
      case DocumentType.healthCertificate:
        return Icons.health_and_safety;
      case DocumentType.microchipCertificate:
        return Icons.memory;
      case DocumentType.pedigreeCertificate:
        return Icons.family_history;
      case DocumentType.insuranceDocument:
        return Icons.security;
      case DocumentType.behaviorAssessment:
        return Icons.psychology;
      case DocumentType.trainingCertificate:
        return Icons.school;
      case DocumentType.photo:
        return Icons.photo;
      case DocumentType.video:
        return Icons.video_library;
      case DocumentType.other:
        return Icons.description;
    }
  }
}
