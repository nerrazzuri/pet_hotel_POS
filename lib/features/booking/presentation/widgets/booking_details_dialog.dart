import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';

class BookingDetailsDialog extends ConsumerWidget {
  final Booking booking;
  
  const BookingDetailsDialog({super.key, required this.booking});

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
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.info,
                    color: Colors.blue[800],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking Details - ${booking.bookingNumber}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'View comprehensive booking information',
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
                        color: _getStatusColor(booking.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getStatusColor(booking.status),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        booking.status.name.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(booking.status),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Customer & Pet Information
                    _buildSection(
                      'Customer & Pet Information',
                      Icons.person,
                      [
                        _buildDetailRow('Customer Name', booking.customerName),
                        _buildDetailRow('Pet Name', booking.petName),
                        _buildDetailRow('Booking Type', booking.type.name.toUpperCase()),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Room Information
                    _buildSection(
                      'Room Information',
                      Icons.hotel,
                      [
                        _buildDetailRow('Room Number', booking.roomNumber),
                        _buildDetailRow('Base Price per Night', 'MYR ${booking.basePricePerNight.toStringAsFixed(2)}'),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Dates & Times
                    _buildSection(
                      'Dates & Times',
                      Icons.calendar_today,
                      [
                        _buildDetailRow('Check-in Date', _formatDate(booking.checkInDate)),
                        _buildDetailRow('Check-in Time', _formatTime(booking.checkInTime)),
                        _buildDetailRow('Check-out Date', _formatDate(booking.checkOutDate)),
                        _buildDetailRow('Check-out Time', _formatTime(booking.checkOutTime)),
                        _buildDetailRow('Duration', '${booking.checkOutDate.difference(booking.checkInDate).inDays} nights'),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Pricing Information
                    _buildSection(
                      'Pricing Information',
                      Icons.attach_money,
                      [
                        _buildDetailRow('Base Amount', 'MYR ${(booking.basePricePerNight * booking.checkOutDate.difference(booking.checkInDate).inDays).toStringAsFixed(2)}'),
                        if (booking.depositAmount != null && booking.depositAmount! > 0)
                          _buildDetailRow('Deposit Amount', 'MYR ${booking.depositAmount!.toStringAsFixed(2)}'),
                        if (booking.discountAmount != null && booking.discountAmount! > 0)
                          _buildDetailRow('Discount Amount', 'MYR ${booking.discountAmount!.toStringAsFixed(2)}'),
                        if (booking.taxAmount != null && booking.taxAmount! > 0)
                          _buildDetailRow('Tax Amount', 'MYR ${booking.taxAmount!.toStringAsFixed(2)}'),
                        _buildDetailRow('Total Amount', 'MYR ${booking.totalAmount.toStringAsFixed(2)}', isTotal: true),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Additional Services
                    if (booking.additionalServices != null && booking.additionalServices!.isNotEmpty)
                      _buildSection(
                        'Additional Services',
                        Icons.add_circle,
                        [
                          for (final service in booking.additionalServices!)
                            _buildDetailRow('Service', service),
                        ],
                      ),
                    
                    if (booking.additionalServices != null && booking.additionalServices!.isNotEmpty)
                      const SizedBox(height: 16),
                    
                    // Notes & Instructions
                    if (booking.specialInstructions?.isNotEmpty == true || 
                        booking.careNotes?.isNotEmpty == true || 
                        booking.veterinaryNotes?.isNotEmpty == true)
                      _buildSection(
                        'Notes & Instructions',
                        Icons.note,
                        [
                          if (booking.specialInstructions?.isNotEmpty == true)
                            _buildDetailRow('Special Instructions', booking.specialInstructions!),
                          if (booking.careNotes?.isNotEmpty == true)
                            _buildDetailRow('Care Notes', booking.careNotes!),
                          if (booking.veterinaryNotes?.isNotEmpty == true)
                            _buildDetailRow('Veterinary Notes', booking.veterinaryNotes!),
                        ],
                      ),
                    
                    if (booking.specialInstructions?.isNotEmpty == true || 
                        booking.careNotes?.isNotEmpty == true || 
                        booking.veterinaryNotes?.isNotEmpty == true)
                      const SizedBox(height: 16),
                    
                    // Staff Assignment
                    if (booking.assignedStaffName?.isNotEmpty == true)
                      _buildSection(
                        'Staff Assignment',
                        Icons.people,
                        [
                          _buildDetailRow('Assigned Staff', booking.assignedStaffName!),
                        ],
                      ),
                    
                    if (booking.assignedStaffName?.isNotEmpty == true)
                      const SizedBox(height: 16),
                    
                    // Timestamps
                    _buildSection(
                      'Timestamps',
                      Icons.schedule,
                      [
                        _buildDetailRow('Created', _formatDateTime(booking.createdAt)),
                        _buildDetailRow('Last Updated', _formatDateTime(booking.updatedAt)),
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
                    backgroundColor: Colors.blue,
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
              Icon(icon, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
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

  Widget _buildDetailRow(String label, String value, {bool isTotal = false}) {
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
                color: isTotal ? Colors.blue[700] : Colors.grey[700],
                fontSize: isTotal ? 14 : 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isTotal ? Colors.blue[700] : Colors.black87,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                fontSize: isTotal ? 14 : 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.checkedIn:
        return Colors.green;
      case BookingStatus.checkedOut:
        return Colors.grey;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.noShow:
        return Colors.purple;
      case BookingStatus.completed:
        return Colors.teal;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(BookingTimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} at ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
