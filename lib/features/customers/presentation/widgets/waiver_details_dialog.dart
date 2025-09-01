import 'package:flutter/material.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/waiver.dart';

class WaiverDetailsDialog extends StatelessWidget {
  final Waiver waiver;

  const WaiverDetailsDialog({
    super.key,
    required this.waiver,
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
                  Icons.description,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Waiver Details: ${waiver.title}',
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
                    _buildSectionHeader('Waiver Information'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoRow('Title', waiver.title),
                      _buildInfoRow('Type', waiver.type.displayName),
                      _buildInfoRow('Status', waiver.status.displayName),
                      _buildInfoRow('Required', _formatBoolean(waiver.isRequired)),
                      _buildInfoRow('Blocks Check-in', _formatBoolean(waiver.blocksCheckIn)),
                    ]),
                    const SizedBox(height: 24),
                    
                    // Content Section
                    _buildSectionHeader('Waiver Content'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoRow('Content', waiver.content),
                    ]),
                    const SizedBox(height: 24),
                    
                    // Signature Information Section
                    _buildSectionHeader('Signature Information'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      if (waiver.signedBy != null && waiver.signedBy!.isNotEmpty)
                        _buildInfoRow('Signed By', waiver.signedBy!),
                      if (waiver.signatureMethod != null && waiver.signatureMethod!.isNotEmpty)
                        _buildInfoRow('Signature Method', waiver.signatureMethod!),
                      if (waiver.witnessName != null && waiver.witnessName!.isNotEmpty)
                        _buildInfoRow('Witness Name', waiver.witnessName!),
                    ]),
                    const SizedBox(height: 24),
                    
                    // Dates Section
                    _buildSectionHeader('Dates'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      if (waiver.signedDate != null)
                        _buildInfoRow('Signed Date', _formatDate(waiver.signedDate!)),
                      if (waiver.expiryDate != null)
                        _buildInfoRow('Expiry Date', _formatDate(waiver.expiryDate!)),
                      if (waiver.expiryDate != null)
                        _buildInfoRow('Days Until Expiry', _calculateDaysUntilExpiry(waiver.expiryDate!)),
                      _buildInfoRow('Created', _formatDateTime(waiver.createdAt)),
                      _buildInfoRow('Last Updated', _formatDateTime(waiver.updatedAt)),
                    ]),
                    const SizedBox(height: 24),
                    
                    // Pet & Customer Information Section
                    _buildSectionHeader('Pet & Customer Information'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoRow('Customer Name', waiver.customerName),
                      if (waiver.petName != null && waiver.petName!.isNotEmpty)
                        _buildInfoRow('Pet Name', waiver.petName!),
                    ]),
                    const SizedBox(height: 24),
                    
                    // Status Information Section
                    _buildSectionHeader('Status Information'),
                    const SizedBox(height: 16),
                    _buildInfoCard([
                      _buildInfoRow('Is Expired', _formatBoolean(waiver.isExpired)),
                      if (waiver.expiryDate != null)
                        _buildInfoRow('Days Until Expiry', _calculateDaysUntilExpiry(waiver.expiryDate!)),
                      _buildInfoRow('Status', waiver.status.displayName),
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

  Widget _buildStatusChip(WaiverStatus status) {
    Color color;
    switch (status) {
      case WaiverStatus.signed:
        color = Colors.green;
        break;
      case WaiverStatus.pending:
        color = Colors.orange;
        break;
      case WaiverStatus.expired:
        color = Colors.red;
        break;
      case WaiverStatus.rejected:
        color = Colors.red.shade800;
        break;
      case WaiverStatus.revoked:
        color = Colors.red.shade900;
        break;
      case WaiverStatus.notRequired:
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

  String _formatDate(DateTime date) {
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

  String _calculateDaysUntilExpiry(DateTime expiryDate) {
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
