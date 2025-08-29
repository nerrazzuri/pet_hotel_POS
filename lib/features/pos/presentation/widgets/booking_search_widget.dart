import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/features/pos/domain/services/checkin_service.dart';
import 'package:cat_hotel_pos/features/pos/presentation/widgets/checkin_dialog.dart';

class BookingSearchWidget extends ConsumerStatefulWidget {
  final Function(Booking)? onBookingSelected;
  final bool allowWalkIn;

  const BookingSearchWidget({
    super.key,
    this.onBookingSelected,
    this.allowWalkIn = true,
  });

  @override
  ConsumerState<BookingSearchWidget> createState() => _BookingSearchWidgetState();
}

class _BookingSearchWidgetState extends ConsumerState<BookingSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _bookingNumberController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _petNameController = TextEditingController();

  List<Booking> _searchResults = [];
  bool _isSearching = false;
  String _selectedSearchType = 'booking_number';

  @override
  void dispose() {
    _searchController.dispose();
    _bookingNumberController.dispose();
    _customerNameController.dispose();
    _phoneController.dispose();
    _petNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.search, size: 24, color: Colors.blue),
                const SizedBox(width: 12),
                const Text(
                  'Find Booking for Check-In',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (widget.allowWalkIn)
                  ElevatedButton.icon(
                    onPressed: _startWalkInCheckIn,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Walk-In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Search Type Selector
            _buildSearchTypeSelector(),
            
            const SizedBox(height: 16),
            
            // Search Form
            _buildSearchForm(),
            
            const SizedBox(height: 16),
            
            // Search Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSearching ? null : _performSearch,
                icon: _isSearching 
                    ? const SizedBox(
                        width: 16, 
                        height: 16, 
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: Text(_isSearching ? 'Searching...' : 'Search Bookings'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Search Results
            if (_searchResults.isNotEmpty) ...[
              const Divider(),
              const SizedBox(height: 16),
              _buildSearchResults(),
            ] else if (_isSearching) ...[
              const Divider(),
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Search By',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Booking Number'),
                value: 'booking_number',
                groupValue: _selectedSearchType,
                onChanged: (value) {
                  setState(() {
                    _selectedSearchType = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Customer Name'),
                value: 'customer_name',
                groupValue: _selectedSearchType,
                onChanged: (value) {
                  setState(() {
                    _selectedSearchType = value!;
                  });
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Phone Number'),
                value: 'phone_number',
                groupValue: _selectedSearchType,
                onChanged: (value) {
                  setState(() {
                    _selectedSearchType = value!;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Pet Name'),
                value: 'pet_name',
                groupValue: _selectedSearchType,
                onChanged: (value) {
                  setState(() {
                    _selectedSearchType = value!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchForm() {
    switch (_selectedSearchType) {
      case 'booking_number':
        return TextFormField(
          controller: _bookingNumberController,
          decoration: const InputDecoration(
            labelText: 'Booking Number',
            hintText: 'Enter booking number (e.g., BK123456)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.confirmation_number),
          ),
          textCapitalization: TextCapitalization.characters,
          onFieldSubmitted: (_) => _performSearch(),
        );
      
      case 'customer_name':
        return TextFormField(
          controller: _customerNameController,
          decoration: const InputDecoration(
            labelText: 'Customer Name',
            hintText: 'Enter customer name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          textCapitalization: TextCapitalization.words,
          onFieldSubmitted: (_) => _performSearch(),
        );
      
      case 'phone_number':
        return TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: 'Enter phone number',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
          ),
          keyboardType: TextInputType.phone,
          onFieldSubmitted: (_) => _performSearch(),
        );
      
      case 'pet_name':
        return TextFormField(
          controller: _petNameController,
          decoration: const InputDecoration(
            labelText: 'Pet Name',
            hintText: 'Enter pet name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.pets),
          ),
          textCapitalization: TextCapitalization.words,
          onFieldSubmitted: (_) => _performSearch(),
        );
      
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Results (${_searchResults.length})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        
        if (_searchResults.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.grey.shade600),
                const SizedBox(height: 16),
                Text(
                  'No bookings found',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try searching with different criteria or create a walk-in check-in',
                  style: TextStyle(color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final booking = _searchResults[index];
              return _buildBookingCard(booking);
            },
          ),
      ],
    );
  }

  Widget _buildBookingCard(Booking booking) {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    bool canCheckIn = false;

    switch (booking.status) {
      case BookingStatus.confirmed:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Ready for Check-In';
        canCheckIn = true;
        break;
      case BookingStatus.pending:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule;
        statusText = 'Pending Confirmation';
        canCheckIn = false;
        break;
      case BookingStatus.checkedIn:
        statusColor = Colors.blue;
        statusIcon = Icons.hotel;
        statusText = 'Already Checked In';
        canCheckIn = false;
        break;
      case BookingStatus.checkedOut:
        statusColor = Colors.grey;
        statusIcon = Icons.check;
        statusText = 'Completed';
        canCheckIn = false;
        break;
      case BookingStatus.cancelled:
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        statusText = 'Cancelled';
        canCheckIn = false;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info;
        statusText = booking.status.name;
        canCheckIn = false;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.bookingNumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(statusIcon, size: 16, color: statusColor),
                          const SizedBox(width: 6),
                          Text(
                            statusText,
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (canCheckIn)
                  ElevatedButton.icon(
                    onPressed: () => _startBookingCheckIn(booking),
                    icon: const Icon(Icons.login),
                    label: const Text('Check In'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  OutlinedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.block),
                    label: const Text('Cannot Check In'),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Booking Details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(Icons.person, 'Customer', booking.customerName),
                      const SizedBox(height: 4),
                      _buildDetailRow(Icons.pets, 'Pet', booking.petName),
                      const SizedBox(height: 4),
                      _buildDetailRow(Icons.hotel, 'Room', booking.roomNumber),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(Icons.calendar_today, 'Check-In', 
                        '${booking.checkInDate.day}/${booking.checkInDate.month}/${booking.checkInDate.year}'),
                      const SizedBox(height: 4),
                      _buildDetailRow(Icons.calendar_month, 'Check-Out', 
                        '${booking.checkOutDate.day}/${booking.checkOutDate.month}/${booking.checkOutDate.year}'),
                      const SizedBox(height: 4),
                      _buildDetailRow(Icons.attach_money, 'Amount', 
                        'RM ${booking.totalAmount.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ],
            ),
            
            // Special Notes
            if (booking.specialInstructions != null && booking.specialInstructions!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info, size: 16, color: Colors.amber),
                        SizedBox(width: 6),
                        Text(
                          'Special Instructions',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(booking.specialInstructions!),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<void> _performSearch() async {
    if (_isSearching) return;

    String? searchValue;
    String? searchType;

    switch (_selectedSearchType) {
      case 'booking_number':
        searchValue = _bookingNumberController.text.trim();
        searchType = 'booking_number';
        break;
      case 'customer_name':
        searchValue = _customerNameController.text.trim();
        searchType = 'customer_name';
        break;
      case 'phone_number':
        searchValue = _phoneController.text.trim();
        searchType = 'phone_number';
        break;
      case 'pet_name':
        searchValue = _petNameController.text.trim();
        searchType = 'pet_name';
        break;
    }

    if (searchValue == null || searchValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a search value')),
      );
      return;
    }

    setState(() {
      _isSearching = true;
      _searchResults = [];
    });

    try {
      // TODO: Replace with actual service call
      final checkInService = ref.read(checkInServiceProvider);
      List<Booking> results = [];

      switch (searchType) {
        case 'booking_number':
          results = await checkInService.searchBookingsForCheckIn(bookingNumber: searchValue);
          break;
        case 'customer_name':
          results = await checkInService.searchBookingsForCheckIn(customerName: searchValue);
          break;
        case 'phone_number':
          results = await checkInService.searchBookingsForCheckIn(phoneNumber: searchValue);
          break;
        case 'pet_name':
          results = await checkInService.searchBookingsForCheckIn(petName: searchValue);
          break;
      }

      setState(() {
        _searchResults = results;
        _isSearching = false;
      });

    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: $e')),
        );
      }
    }
  }

  void _startBookingCheckIn(Booking booking) {
    if (widget.onBookingSelected != null) {
      widget.onBookingSelected!(booking);
    } else {
      // Open check-in dialog directly
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => CheckInDialog(
          existingBooking: booking,
          customerId: booking.customerId,
          customerName: booking.customerName,
          petId: booking.petId,
          petName: booking.petName,
        ),
      ).then((result) {
        if (result == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Check-in completed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh search results
          _performSearch();
        }
      });
    }
  }

  void _startWalkInCheckIn() {
    // Open check-in dialog for walk-in
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const CheckInDialog(),
    ).then((result) {
      if (result == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Walk-in check-in completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }
}

// Placeholder provider - this should be implemented properly
final checkInServiceProvider = Provider<CheckInService>((ref) {
  throw UnimplementedError('CheckInService provider not implemented');
});