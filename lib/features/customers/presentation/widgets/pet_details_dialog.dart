import 'package:flutter/material.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/pet.dart';

class PetDetailsDialog extends StatelessWidget {
  final Pet pet;

  const PetDetailsDialog({
    super.key,
    required this.pet,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.pets,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Pet Details: ${pet.name}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic Information Section
                    _buildSectionHeader('Basic Information'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoRow('Name', pet.name),
                      _buildInfoRow('Type', pet.type.displayName),
                      _buildInfoRow('Gender', pet.gender.displayName),
                      _buildInfoRow('Size', pet.size.displayName),
                      _buildInfoRow('Date of Birth', _formatDate(pet.dateOfBirth)),
                      _buildInfoRow('Age', _calculateAge(pet.dateOfBirth)),
                    ]),
                    const SizedBox(height: 24),
                    
                    // Physical Characteristics Section
                    _buildSectionHeader('Physical Characteristics'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoRow('Breed', pet.breed ?? 'Not specified'),
                      _buildInfoRow('Color', pet.color ?? 'Not specified'),
                      _buildInfoRow('Weight', pet.weight != null ? '${pet.weight} ${pet.weightUnit ?? 'kg'}' : 'Not specified'),
                      _buildInfoRow('Microchip Number', pet.microchipNumber ?? 'Not specified'),
                    ]),
                    const SizedBox(height: 24),
                    
                    // Health & Medical Section
                    _buildSectionHeader('Health & Medical'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoRow('Neutered', _formatBoolean(pet.isNeutered)),
                      _buildInfoRow('Spayed', _formatBoolean(pet.isSpayed)),
                      _buildInfoRow('Vaccinated', _formatBoolean(pet.isVaccinated)),
                      _buildInfoRow('Dewormed', _formatBoolean(pet.isDewormed)),
                      _buildInfoRow('Flea Treated', _formatBoolean(pet.isFleaTreated)),
                      _buildInfoRow('Tick Treated', _formatBoolean(pet.isTickTreated)),
                    ]),
                    const SizedBox(height: 24),
                    
                    // Behavior & Temperament Section
                    _buildSectionHeader('Behavior & Temperament'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoRow('Temperament', pet.temperament?.displayName ?? 'Not specified'),
                      if (pet.temperamentNotes != null && pet.temperamentNotes!.isNotEmpty)
                        _buildInfoRow('Temperament Notes', pet.temperamentNotes!),
                      if (pet.behaviorNotes != null && pet.behaviorNotes!.isNotEmpty)
                        _buildInfoRow('Behavior Notes', pet.behaviorNotes!),
                    ]),
                    const SizedBox(height: 24),
                    
                    // Special Needs & Medical Information
                    if (pet.specialNeeds != null && pet.specialNeeds!.isNotEmpty) ...[
                      _buildSectionHeader('Special Needs'),
                      const SizedBox(height: 16),
                      _buildInfoCard([
                        _buildInfoRow('Special Needs', pet.specialNeeds!.join(', ')),
                      ]),
                      const SizedBox(height: 24),
                    ],
                    
                    if (pet.allergies != null && pet.allergies!.isNotEmpty) ...[
                      _buildSectionHeader('Allergies'),
                      const SizedBox(height: 16),
                      _buildInfoCard([
                        _buildInfoRow('Allergies', pet.allergies!.join(', ')),
                      ]),
                      const SizedBox(height: 24),
                    ],
                    
                    if (pet.medications != null && pet.medications!.isNotEmpty) ...[
                      _buildSectionHeader('Medications'),
                      const SizedBox(height: 16),
                      _buildInfoCard([
                        _buildInfoRow('Medications', pet.medications!.join(', ')),
                      ]),
                      const SizedBox(height: 24),
                    ],
                    
                    // Veterinarian Information Section
                    if (pet.veterinarianName != null || pet.veterinarianPhone != null) ...[
                      _buildSectionHeader('Veterinarian Information'),
                      const SizedBox(height: 16),
                      _buildInfoCard([
                        if (pet.veterinarianName != null)
                          _buildInfoRow('Veterinarian Name', pet.veterinarianName!),
                        if (pet.veterinarianPhone != null)
                          _buildInfoRow('Veterinarian Phone', pet.veterinarianPhone!),
                      ]),
                      const SizedBox(height: 24),
                    ],
                    
                    // Status Section
                    _buildSectionHeader('Status'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoRow('Active', _formatBoolean(pet.isActive)),
                      _buildInfoRow('Created', _formatDateTime(pet.createdAt)),
                      _buildInfoRow('Last Updated', _formatDateTime(pet.updatedAt)),
                    ]),
                  ],
                ),
              ),
            ),
            
            // Action Buttons
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  label: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not specified';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'Not specified';
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatBoolean(bool? value) {
    if (value == null) return 'Not specified';
    return value ? 'Yes' : 'No';
  }

  String _calculateAge(DateTime? dateOfBirth) {
    if (dateOfBirth == null) return 'Not specified';
    
    final now = DateTime.now();
    final age = now.difference(dateOfBirth);
    final years = (age.inDays / 365).floor();
    final months = ((age.inDays % 365) / 30).floor();
    
    if (years > 0) {
      return months > 0 ? '$years years, $months months' : '$years years';
    } else if (months > 0) {
      return '$months months';
    } else {
      final days = age.inDays;
      return '$days days';
    }
  }
}
