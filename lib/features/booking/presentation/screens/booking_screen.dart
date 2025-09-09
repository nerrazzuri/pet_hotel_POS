import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:cat_hotel_pos/features/booking/presentation/providers/booking_providers.dart';
import 'package:cat_hotel_pos/features/booking/presentation/widgets/calendar_view.dart';
import 'package:cat_hotel_pos/features/booking/presentation/widgets/enhanced_calendar_view.dart';
import 'package:cat_hotel_pos/features/booking/presentation/widgets/waitlist_management.dart';
import 'package:cat_hotel_pos/features/booking/presentation/widgets/create_booking_dialog.dart';
import 'package:cat_hotel_pos/features/booking/presentation/widgets/edit_booking_dialog.dart';
import 'package:cat_hotel_pos/features/booking/presentation/widgets/booking_details_dialog.dart';
import 'package:cat_hotel_pos/features/booking/presentation/widgets/booking_payment_dialog.dart';
import 'package:cat_hotel_pos/features/booking/presentation/widgets/payment_history_dialog.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _statusFilterController = TextEditingController();
  final TextEditingController _dateFilterController = TextEditingController();
  
  late TabController _tabController;
  BookingStatus? _selectedStatus;
  DateTime? _selectedDate;
  String _searchQuery = '';
  bool _showAdvancedSearch = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _statusFilterController.dispose();
    _dateFilterController.dispose();
    super.dispose();
  }

  void _showCreateBookingDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateBookingDialog(),
    );
  }

  void _showEditBookingDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => EditBookingDialog(booking: booking),
    );
  }

  void _showDeleteBookingDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Booking'),
        content: Text('Are you sure you want to delete booking ${booking.bookingNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement delete booking
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Delete booking coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showBookingDetailsDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => BookingDetailsDialog(booking: booking),
    );
  }

  void _showBookingPaymentDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => BookingPaymentDialog(booking: booking),
    );
  }

  void _showPaymentHistoryDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => PaymentHistoryDialog(booking: booking),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _checkInBooking(Booking booking) {
    // TODO: Implement check-in functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Check-in functionality coming soon!')),
    );
  }

  void _checkOutBooking(Booking booking) {
    // TODO: Implement check-out functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Check-out functionality coming soon!')),
    );
  }

  void _showCancelBookingDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to cancel booking ${booking.bookingNumber}?'),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Cancellation Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement cancel booking
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cancel booking coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Cancel Booking'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(filteredBookingsProvider);
    final statisticsAsync = ref.watch(bookingStatisticsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Booking Management'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: colorScheme.onPrimary,
          labelColor: colorScheme.onPrimary,
          unselectedLabelColor: colorScheme.onPrimary.withOpacity(0.7),
          tabs: const [
            Tab(text: 'List View', icon: Icon(Icons.list)),
            Tab(text: 'Calendar', icon: Icon(Icons.calendar_month)),
            Tab(text: 'Enhanced', icon: Icon(Icons.calendar_view_week)),
            Tab(text: 'Waitlist', icon: Icon(Icons.queue)),
          ],
        ),
        actions: [
          // Enhanced search toggle
          IconButton(
            icon: Icon(_showAdvancedSearch ? Icons.search_off : Icons.search),
            onPressed: () {
              setState(() {
                _showAdvancedSearch = !_showAdvancedSearch;
              });
            },
            tooltip: _showAdvancedSearch ? 'Hide Advanced Search' : 'Show Advanced Search',
          ),
          // Export button
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportBookingData,
            tooltip: 'Export Booking Data',
          ),
          // Create booking button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateBookingDialog(),
            tooltip: 'Create New Booking',
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(filteredBookingsProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // List View Tab
          _buildListViewTab(bookingsAsync, statisticsAsync),
          // Calendar Tab
          const CalendarView(),
          // Enhanced Calendar Tab
          const EnhancedCalendarView(),
          // Waitlist Tab
          const WaitlistManagement(),
        ],
      ),
    );
  }

  void _exportBookingData() {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export functionality coming soon!')),
    );
  }

  Widget _buildListViewTab(
    AsyncValue<List<Booking>> bookingsAsync,
    AsyncValue<Map<String, dynamic>> statisticsAsync,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[50]!,
            Colors.blue[50]!,
          ],
        ),
      ),
      child: Column(
        children: [
          // Statistics Cards
          _buildStatisticsCards(statisticsAsync),
          
          // Search and Filter Section
          if (_showAdvancedSearch) _buildAdvancedSearchAndFilters(),
          
          // Bookings List
          Expanded(
            child: _buildBookingsList(bookingsAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards(AsyncValue<Map<String, dynamic>> statisticsAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: statisticsAsync.when(
        data: (statistics) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 900;
              final children = <Widget>[
                Expanded(
                  child: _buildEnhancedStatCard(
                    'Total Bookings',
                    '${statistics['totalBookings'] ?? 0}',
                    Icons.book_online,
                    Colors.blue[700]!,
                    Colors.blue[50]!,
                  ),
                ),
                const SizedBox(width: 16, height: 16),
                Expanded(
                  child: _buildEnhancedStatCard(
                    'Active Bookings',
                    '${statistics['activeBookings'] ?? 0}',
                    Icons.check_circle,
                    Colors.green[700]!,
                    Colors.green[50]!,
                  ),
                ),
                const SizedBox(width: 16, height: 16),
                Expanded(
                  child: _buildEnhancedStatCard(
                    'Pending Bookings',
                    '${statistics['pendingBookings'] ?? 0}',
                    Icons.pending,
                    Colors.orange[700]!,
                    Colors.orange[50]!,
                  ),
                ),
                const SizedBox(width: 16, height: 16),
                Expanded(
                  child: _buildEnhancedStatCard(
                    'Total Revenue',
                    'MYR ${(statistics['totalRevenue'] ?? 0.0).toStringAsFixed(2)}',
                    Icons.attach_money,
                    Colors.green[700]!,
                    Colors.green[50]!,
                  ),
                ),
              ];

              if (isNarrow) {
                return Column(
                  children: children
                      .expand((w) => [w, const SizedBox(height: 12)])
                      .toList()
                      .sublist(0, children.length * 2 - 1),
                );
              }

              return Row(children: children);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildEnhancedStatCard(String title, String value, IconData icon, Color color, Color backgroundColor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundColor, backgroundColor.withOpacity(0.7)],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSearchAndFilters() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search bookings...',
              hintText: 'Search by booking number, customer name, or pet name',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              // TODO: Implement search functionality
            },
          ),
          const SizedBox(height: 16),
          // Filter Row
          Column(
            children: [
              DropdownButtonFormField<BookingStatus?>(
                value: _selectedStatus,
                decoration: InputDecoration(
                  labelText: 'Status Filter',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('All Statuses'),
                  ),
                  ...BookingStatus.values.map((status) => DropdownMenuItem(
                    value: status,
                    child: Text(status.name.toUpperCase()),
                  )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                  // TODO: Implement status filter
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateFilterController,
                decoration: InputDecoration(
                  labelText: 'Date Filter',
                  hintText: 'Select date range',
                  prefixIcon: const Icon(Icons.date_range),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                readOnly: true,
                onTap: () async {
                  // TODO: Implement date picker
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Date picker coming soon!')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(AsyncValue<List<Booking>> bookingsAsync) {
    return bookingsAsync.when(
      data: (bookings) {
        if (bookings.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.book_online_outlined, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No bookings found',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Create your first booking to get started',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
                         return _BookingCard(
               booking: booking,
               onEdit: () => _showEditBookingDialog(booking),
               onDelete: () => _showDeleteBookingDialog(booking),
               onView: () => _showBookingDetailsDialog(booking),
               onCheckIn: () => _checkInBooking(booking),
               onCheckOut: () => _checkOutBooking(booking),
               onCancel: () => _showCancelBookingDialog(booking),
               onPayment: () => _showBookingPaymentDialog(booking),
               onPaymentHistory: () => _showPaymentHistoryDialog(booking),
             );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading bookings',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onView;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final VoidCallback onCancel;
  final VoidCallback onPayment;
  final VoidCallback onPaymentHistory;

  const _BookingCard({
    required this.booking,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onCancel,
    required this.onPayment,
    required this.onPaymentHistory,
  });

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              _getStatusColor(booking.status).withOpacity(0.05),
            ],
          ),
          border: Border.all(
            color: _getStatusColor(booking.status).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  // Booking Number Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      booking.bookingNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const Spacer(),
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
                ],
              ),
              const SizedBox(height: 16),
              
              // Customer and Pet Info
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: _getStatusColor(booking.status).withOpacity(0.1),
                    child: Icon(
                      Icons.pets,
                      color: _getStatusColor(booking.status),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.customerName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          booking.petName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Booking Details Grid
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      'Room',
                      booking.roomNumber,
                      Icons.room,
                      colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDetailItem(
                      'Amount',
                      'MYR ${booking.totalAmount.toStringAsFixed(2)}',
                      Icons.attach_money,
                      Colors.green[700]!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildDetailItem(
                      'Check-in',
                      '${booking.checkInDate.toString().split(' ')[0]}\n${booking.checkInTime.hour}:${booking.checkInTime.minute.toString().padLeft(2, '0')}',
                      Icons.login,
                      Colors.blue[700]!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildDetailItem(
                      'Check-out',
                      '${booking.checkOutDate.toString().split(' ')[0]}\n${booking.checkOutTime.hour}:${booking.checkOutTime.minute.toString().padLeft(2, '0')}',
                      Icons.logout,
                      Colors.orange[700]!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Action Buttons (wrap to avoid overflow)
              Wrap(
                alignment: WrapAlignment.spaceEvenly,
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildActionButton(
                    'View',
                    Icons.visibility,
                    Colors.blue,
                    onView,
                  ),
                  _buildActionButton(
                    'Payment',
                    Icons.payment,
                    Colors.green,
                    onPayment,
                  ),
                  _buildActionButton(
                    'History',
                    Icons.history,
                    Colors.purple,
                    onPaymentHistory,
                  ),
                  _buildActionButton(
                    'Edit',
                    Icons.edit,
                    Colors.orange,
                    onEdit,
                  ),
                  if (booking.status == BookingStatus.confirmed)
                    _buildActionButton(
                      'Check In',
                      Icons.login,
                      Colors.green,
                      onCheckIn,
                    ),
                  if (booking.status == BookingStatus.checkedIn)
                    _buildActionButton(
                      'Check Out',
                      Icons.logout,
                      Colors.blue,
                      onCheckOut,
                    ),
                  if (booking.status == BookingStatus.pending || booking.status == BookingStatus.confirmed)
                    _buildActionButton(
                      'Cancel',
                      Icons.cancel,
                      Colors.red,
                      onCancel,
                    ),
                  _buildActionButton(
                    'Delete',
                    Icons.delete,
                    Colors.red,
                    onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onPressed) {
    return Flexible(
      fit: FlexFit.loose,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(height: 2),
              Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
