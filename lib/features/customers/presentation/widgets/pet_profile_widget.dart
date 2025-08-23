import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/pet.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/vaccination.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/waiver.dart';

class PetProfileWidget extends ConsumerWidget {
  final Pet pet;
  final List<Vaccination> vaccinations;
  final List<Waiver> waivers;

  const PetProfileWidget({
    super.key,
    required this.pet,
    required this.vaccinations,
    required this.waivers,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPetHeader(context),
          const SizedBox(height: 24),
          _buildBasicInfo(),
          const SizedBox(height: 24),
          _buildMedicalInfo(),
          const SizedBox(height: 24),
          _buildVaccinationStatus(),
          const SizedBox(height: 24),
          _buildFeedingSchedule(),
          const SizedBox(height: 24),
          _buildSpecialNeeds(),
          const SizedBox(height: 24),
          _buildWaiversStatus(),
        ],
      ),
    );
  }

  Widget _buildPetHeader(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: _getPetTypeColor(pet.type).withOpacity(0.1),
              child: Icon(
                _getPetTypeIcon(pet.type),
                size: 50,
                color: _getPetTypeColor(pet.type),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${pet.breed ?? 'Unknown breed'} • ${pet.type.name.toUpperCase()}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.cake,
                        '${pet.age} years old',
                        Colors.pink,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.male,
                        pet.gender.name.toUpperCase(),
                        pet.gender == PetGender.male ? Colors.blue : Colors.pink,
                      ),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                        Icons.straighten,
                        '${pet.size.name} (${pet.weight ?? 'Unknown'} ${pet.weightUnit ?? 'kg'})',
                        Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (pet.needsSpecialCare)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Special Care',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                if (pet.isSenior)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Senior Pet',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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

  Widget _buildInfoChip(IconData icon, String value, Color color) {
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
            value,
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

  Widget _buildBasicInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Basic Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Microchip', pet.microchipNumber ?? 'Not microchipped'),
            _buildInfoRow('Collar Tag', pet.collarTag ?? 'No collar tag'),
            _buildInfoRow('Neutered/Spayed', _getNeuterStatus()),
            _buildInfoRow('Temperament', pet.temperament?.name ?? 'Unknown'),
            if (pet.temperamentNotes != null)
              _buildInfoRow('Temperament Notes', pet.temperamentNotes!),
            _buildInfoRow('Veterinarian', pet.veterinarianName ?? 'Not specified'),
            if (pet.veterinarianPhone != null)
              _buildInfoRow('Vet Phone', pet.veterinarianPhone!),
            if (pet.veterinarianClinic != null)
              _buildInfoRow('Vet Clinic', pet.veterinarianClinic!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalInfo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medical Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMedicalStatus(
                    'Vaccinated',
                    pet.isVaccinated ?? false,
                    Icons.vaccines,
                  ),
                ),
                Expanded(
                  child: _buildMedicalStatus(
                    'Dewormed',
                    pet.isDewormed ?? false,
                    Icons.medical_services,
                  ),
                ),
                Expanded(
                  child: _buildMedicalStatus(
                    'Flea Treated',
                    pet.isFleaTreated ?? false,
                    Icons.bug_report,
                  ),
                ),
                Expanded(
                  child: _buildMedicalStatus(
                    'Tick Treated',
                    pet.isTickTreated ?? false,
                    Icons.bug_report,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (pet.allergies != null && pet.allergies!.isNotEmpty) ...[
              _buildInfoRow('Allergies', pet.allergies!.join(', ')),
              const SizedBox(height: 8),
            ],
            if (pet.medications != null && pet.medications!.isNotEmpty) ...[
              _buildInfoRow('Medications', pet.medications!.join(', ')),
              const SizedBox(height: 8),
            ],
            if (pet.medicalHistory != null && pet.medicalHistory!.isNotEmpty) ...[
              const Text(
                'Medical History:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              ...pet.medicalHistory!.map((history) => _buildMedicalHistoryItem(history)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalStatus(String label, bool status, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: status ? Colors.green : Colors.red,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: status ? Colors.green : Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          status ? 'Yes' : 'No',
          style: TextStyle(
            fontSize: 10,
            color: status ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalHistoryItem(dynamic history) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            history.condition,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Diagnosed: ${_formatDate(history.diagnosedDate)} by ${history.diagnosedBy}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          if (history.treatment != null) ...[
            const SizedBox(height: 4),
            Text(
              'Treatment: ${history.treatment}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
          if (history.notes != null) ...[
            const SizedBox(height: 4),
            Text(
              'Notes: ${history.notes}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVaccinationStatus() {
    final expiredVaccinations = vaccinations.where((v) => v.isExpired).toList();
    final dueSoonVaccinations = vaccinations.where((v) => v.isDueSoon).toList();
    final upToDateVaccinations = vaccinations.where((v) => v.status == VaccinationStatus.upToDate).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.vaccines, color: Colors.red),
                const SizedBox(width: 8),
                const Text(
                  'Vaccination Status',
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
            Row(
              children: [
                Expanded(
                  child: _buildVaccinationStat(
                    'Up to Date',
                    upToDateVaccinations.length,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildVaccinationStat(
                    'Due Soon',
                    dueSoonVaccinations.length,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildVaccinationStat(
                    'Expired',
                    expiredVaccinations.length,
                    Colors.red,
                  ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildVaccinationStat(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildFeedingSchedule() {
    if (pet.feedingSchedule == null) {
      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Feeding Schedule',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No feeding schedule specified',
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

    final schedule = pet.feedingSchedule!;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Feeding Schedule',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Type', schedule.type.name.replaceAll('_', ' ').toUpperCase()),
            _buildInfoRow('Food Type', schedule.foodType),
            _buildInfoRow('Portion Size', '${schedule.portionSize} ${schedule.portionUnit ?? 'units'}'),
            if (schedule.feedingTimes.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Feeding Times:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              ...schedule.feedingTimes.map((time) => _buildFeedingTimeItem(time)),
            ],
            if (schedule.specialInstructions != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow('Special Instructions', schedule.specialInstructions!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeedingTimeItem(DateTime time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Text(
        _formatTime(time),
        style: const TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSpecialNeeds() {
    if (pet.specialNeeds == null || pet.specialNeeds!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.accessibility, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Special Needs',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...pet.specialNeeds!.map((need) => _buildSpecialNeedItem(need)),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialNeedItem(String need) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              need,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaiversStatus() {
    final pendingWaivers = waivers.where((w) => w.needsSignature).toList();
    final signedWaivers = waivers.where((w) => w.isSigned).toList();
    final expiredWaivers = waivers.where((w) => w.isExpired).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Waivers & Consents',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildWaiverStat(
                    'Signed',
                    signedWaivers.length,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildWaiverStat(
                    'Pending',
                    pendingWaivers.length,
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildWaiverStat(
                    'Expired',
                    expiredWaivers.length,
                    Colors.red,
                  ),
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
          ],
        ),
      ),
    );
  }

  Widget _buildWaiverStat(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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

  // Helper methods
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
        return Colors.purple;
      case PetType.ferret:
        return Colors.indigo;
      case PetType.other:
        return Colors.teal;
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

  String _getNeuterStatus() {
    if (pet.isNeutered == true) return 'Neutered';
    if (pet.isSpayed == true) return 'Spayed';
    return 'Not neutered/spayed';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
