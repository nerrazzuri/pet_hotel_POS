import 'package:flutter/material.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/vaccination.dart';

class VaccinationDetailsDialog extends StatelessWidget {
  final Vaccination vaccination;

  const VaccinationDetailsDialog({
    super.key,
    required this.vaccination,
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
                  Icons.medical_services,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vaccination Details: ${vaccination.name}',
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
                    _buildSectionHeader('Vaccination Information'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoRow('Vaccination Name', vaccination.name),
                      _buildInfoRow('Type', vaccination.type.displayName),
                      _buildInfoRow('Status', vaccination.status.displayName),
                      _buildInfoRow('Required', _formatBoolean(vaccination.isRequired)),
                      _buildInfoRow('Blocks Check-in', _formatBoolean(vaccination.blocksCheckIn)),
                    ]),
                    const SizedBox(height: 24),
                    
                    // Dates Section
                    _buildSectionHeader('Dates'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoRow('Administered Date', _formatDate(vaccination.administeredDate)),
                      _buildInfoRow('Expiry Date', _formatDate(vaccination.expiryDate)),
                      _buildInfoRow('Days Until Expiry', _calculateDaysUntilExpiry(vaccination.expiryDate)),
                      _buildInfoRow('Created', _formatDateTime(vaccination.createdAt)),
                      _buildInfoRow('Last Updated', _formatDateTime(vaccination.updatedAt)),
                    ]),
                    const SizedBox(height: 24),
                    
                    // Medical Information Section
                    _buildSectionHeader('Medical Information'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoRow('Administered By', vaccination.administeredBy),
                      _buildInfoRow('Clinic Name', vaccination.clinicName),
                      if (vaccination.batchNumber != null && vaccination.batchNumber!.isNotEmpty)
                        _buildInfoRow('Batch Number', vaccination.batchNumber!),
                      if (vaccination.manufacturer != null && vaccination.manufacturer!.isNotEmpty)
                        _buildInfoRow('Manufacturer', vaccination.manufacturer!),
                    ]),
                    const SizedBox(height: 24),
                    
                    // Pet & Customer Information Section
                    _buildSectionHeader('Pet & Customer Information'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoRow('Pet Name', vaccination.petName),
                      _buildInfoRow('Customer Name', vaccination.customerName),
                    ]),
                    const SizedBox(height: 24),
                    
                    // Notes Section
                    if (vaccination.notes != null && vaccination.notes!.isNotEmpty) ...[
                      _buildSectionHeader('Notes'),
                      const SizedBox(height: 16),
                      _buildInfoCard([
                        _buildInfoRow('Notes', vaccination.notes!),
                      ]),
                      const SizedBox(height: 24),
                    ],
                    
                    // Status Information Section
                    _buildSectionHeader('Status Information'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoRow('Is Expired', _formatBoolean(vaccination.isExpired)),
                      _buildInfoRow('Days Until Expiry', _calculateDaysUntilExpiry(vaccination.expiryDate)),
                      _buildInfoRow('Status', vaccination.status.displayName),
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
            width: 140,
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

  Widget _buildInfoRowWithWidget(String label, Widget value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: value),
        ],
      ),
    );
  }

  Widget _buildStatusChip(VaccinationStatus status) {
    Color color;
    switch (status) {
      case VaccinationStatus.upToDate:
        color = Colors.green;
        break;
      case VaccinationStatus.dueSoon:
        color = Colors.orange;
        break;
      case VaccinationStatus.expired:
        color = Colors.red;
        break;
      case VaccinationStatus.overdue:
        color = Colors.red.shade800;
        break;
      case VaccinationStatus.notApplicable:
        color = Colors.grey;
        break;
    }

    return Chip(
      label: Text(
        status.displayName,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  String _calculateDaysUntilExpiry(DateTime? expiryDate) {
    if (expiryDate == null) return 'Not specified';
    
    final now = DateTime.now();
    final difference = expiryDate.difference(now);
    final days = difference.inDays;
    
    if (days < 0) {
      return 'Expired ${(-days)} days ago';
    } else if (days == 0) {
      return 'Expires today';
    } else {
      return '$days days';
    }
  }
}
