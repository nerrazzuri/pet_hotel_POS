import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';

class RoomDetailsDialog extends ConsumerWidget {
  final Room room;
  
  const RoomDetailsDialog({super.key, required this.room});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.hotel,
                    color: Colors.indigo[800],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Room Details - ${room.roomNumber}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'View comprehensive room information',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: Colors.grey[600],
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
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(room.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(room.status),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        room.status.name.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(room.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Basic Information
                    _buildSection(
                      'Basic Information',
                      Icons.info,
                      [
                        _buildDetailRow('Room Number', room.roomNumber),
                        _buildDetailRow('Room Name', room.name),
                        _buildDetailRow('Room Type', room.type.displayName),
                        _buildDetailRow('Capacity', '${room.capacity} pets'),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Pricing Information
                    _buildSection(
                      'Pricing Information',
                      Icons.attach_money,
                      [
                        _buildDetailRow('Base Price per Night', 'MYR ${room.basePricePerNight.toStringAsFixed(2)}'),
                        _buildDetailRow('Peak Season Price', 'MYR ${room.peakSeasonPrice.toStringAsFixed(2)}'),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Description
                    if (room.description.isNotEmpty)
                      _buildSection(
                        'Description',
                        Icons.description,
                        [
                          _buildDetailRow('Description', room.description),
                        ],
                      ),
                    
                    if (room.description.isNotEmpty)
                      const SizedBox(height: 16),
                    
                    // Amenities
                    if (room.amenities.isNotEmpty)
                      _buildSection(
                        'Amenities',
                        Icons.list,
                        [
                          for (final amenity in room.amenities)
                            _buildDetailRow('Amenity', amenity),
                        ],
                      ),
                    
                    if (room.amenities.isNotEmpty)
                      const SizedBox(height: 16),
                    
                    // Specifications
                    if (room.specifications.isNotEmpty)
                      _buildSection(
                        'Specifications',
                        Icons.settings,
                        [
                          for (final entry in room.specifications.entries)
                            _buildDetailRow(entry.key, entry.value.toString()),
                        ],
                      ),
                    
                    if (room.specifications.isNotEmpty)
                      const SizedBox(height: 16),
                    
                    // Notes
                    if (room.notes?.isNotEmpty == true)
                      _buildSection(
                        'Notes',
                        Icons.note,
                        [
                          _buildDetailRow('Notes', room.notes!),
                        ],
                      ),
                    
                    if (room.notes?.isNotEmpty == true)
                      const SizedBox(height: 16),
                    
                    // Timestamps
                    _buildSection(
                      'Timestamps',
                      Icons.schedule,
                      [
                        _buildDetailRow('Created', _formatDateTime(room.createdAt)),
                        _buildDetailRow('Last Updated', _formatDateTime(room.updatedAt)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
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
              Icon(icon, color: Colors.indigo[700], size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(RoomStatus status) {
    switch (status) {
      case RoomStatus.available:
        return Colors.green;
      case RoomStatus.occupied:
        return Colors.red;
      case RoomStatus.reserved:
        return Colors.orange;
      case RoomStatus.maintenance:
        return Colors.red[700]!;
      case RoomStatus.cleaning:
        return Colors.blue;
      case RoomStatus.outOfService:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
