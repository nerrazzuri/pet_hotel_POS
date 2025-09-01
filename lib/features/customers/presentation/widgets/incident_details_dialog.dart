import 'package:flutter/material.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/incident.dart';

class IncidentDetailsDialog extends StatelessWidget {
  final Incident incident;

  const IncidentDetailsDialog({
    super.key,
    required this.incident,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Incident Details: ${incident.title}',
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
                    _buildSectionHeader('Incident Information'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoRow('Title', incident.title),
                      _buildInfoRow('Type', incident.type.displayName),
                      _buildInfoRow('Severity', incident.severity.displayName),
                      _buildInfoRow('Status', incident.status.displayName),
                    ]),
                    const SizedBox(height: 24),
                    
                    // Description Section
                    _buildSectionHeader('Description'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoRow('Description', incident.description),
                    ]),
                    const SizedBox(height: 24),
                    
                    // Reporting Information Section
                    _buildSectionHeader('Reporting Information'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoRow('Reported By', incident.reportedBy),
                      _buildInfoRow('Reported Date', _formatDate(incident.reportedDate)),
                      _buildInfoRow('Occurred Date', _formatDate(incident.occurredDate)),
                      if (incident.resolvedDate != null)
                        _buildInfoRow('Resolved Date', _formatDate(incident.resolvedDate!)),
                    ]),
                    const SizedBox(height: 24),
                    
                    // Location & Witnesses Section
                    if (incident.location != null || incident.witnesses != null) ...[
                      _buildSectionHeader('Location & Witnesses'),
                      const SizedBox(height: 16),
                      _buildInfoCard([
                        if (incident.location != null && incident.location!.isNotEmpty)
                          _buildInfoRow('Location', incident.location!),
                        if (incident.witnesses != null && incident.witnesses!.isNotEmpty)
                          _buildInfoRow('Witnesses', incident.witnesses!),
                      ]),
                      const SizedBox(height: 24),
                    ],
                    
                    // Actions & Follow-up Section
                    if (incident.actionsTaken != null || incident.followUpRequired != null) ...[
                      _buildSectionHeader('Actions & Follow-up'),
                      const SizedBox(height: 16),
                      _buildInfoCard([
                        if (incident.actionsTaken != null && incident.actionsTaken!.isNotEmpty)
                          _buildInfoRow('Actions Taken', incident.actionsTaken!),
                        if (incident.followUpRequired != null && incident.followUpRequired!.isNotEmpty)
                          _buildInfoRow('Follow-up Required', incident.followUpRequired!),
                      ]),
                      const SizedBox(height: 24),
                    ],
                    
                    // Pet & Customer Information Section
                    _buildSectionHeader('Pet & Customer Information'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoRow('Customer Name', incident.customerName),
                      _buildInfoRow('Pet Name', incident.petName),
                    ]),
                    const SizedBox(height: 24),
                    
                    // Settings Section
                    _buildSectionHeader('Settings'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoRow('Requires Veterinarian', _formatBoolean(incident.requiresVeterinarian)),
                      _buildInfoRow('Requires Customer Notification', _formatBoolean(incident.requiresCustomerNotification)),
                      _buildInfoRow('Blocks Check-in', _formatBoolean(incident.blocksCheckIn)),
                    ]),
                    const SizedBox(height: 24),
                    
                    // Notes Section
                    if (incident.notes != null && incident.notes!.isNotEmpty) ...[
                      _buildSectionHeader('Notes'),
                      const SizedBox(height: 16),
                      _buildInfoCard([
                        _buildInfoRow('Notes', incident.notes!),
                      ]),
                      const SizedBox(height: 24),
                    ],
                    
                    // Status Information Section
                    _buildSectionHeader('Status Information'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoRow('Is Open', _formatBoolean(incident.isOpen)),
                      _buildInfoRow('Is Critical', _formatBoolean(incident.isCritical)),
                      _buildInfoRow('Created', _formatDateTime(incident.createdAt)),
                      _buildInfoRow('Last Updated', _formatDateTime(incident.updatedAt)),
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
            width: 160,
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

  Widget _buildSeverityChip(IncidentSeverity severity) {
    Color color;
    switch (severity) {
      case IncidentSeverity.minor:
        color = Colors.green;
        break;
      case IncidentSeverity.moderate:
        color = Colors.orange;
        break;
      case IncidentSeverity.major:
        color = Colors.red;
        break;
      case IncidentSeverity.critical:
        color = Colors.red.shade800;
        break;
    }

    return Chip(
      label: Text(
        severity.displayName,
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildStatusChip(IncidentStatus status) {
    Color color;
    switch (status) {
      case IncidentStatus.reported:
        color = Colors.blue;
        break;
      case IncidentStatus.investigating:
        color = Colors.orange;
        break;
      case IncidentStatus.escalated:
        color = Colors.red;
        break;
      case IncidentStatus.resolved:
        color = Colors.green;
        break;
      case IncidentStatus.closed:
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
}
