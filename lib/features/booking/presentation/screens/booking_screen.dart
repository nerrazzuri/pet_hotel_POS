import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:cat_hotel_pos/features/booking/presentation/providers/booking_providers.dart';
import 'package:cat_hotel_pos/features/booking/presentation/widgets/calendar_view.dart';
import 'package:cat_hotel_pos/features/booking/presentation/widgets/enhanced_calendar_view.dart';
import 'package:cat_hotel_pos/features/booking/presentation/widgets/occupancy_board.dart';
import 'package:cat_hotel_pos/features/booking/presentation/widgets/housekeeping_status.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking & Room Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'List View', icon: Icon(Icons.list)),
            Tab(text: 'Calendar', icon: Icon(Icons.calendar_month)),
            Tab(text: 'Enhanced', icon: Icon(Icons.calendar_view_week)),
            Tab(text: 'Waitlist', icon: Icon(Icons.queue)),
            Tab(text: 'Occupancy', icon: Icon(Icons.grid_view)),
            Tab(text: 'Housekeeping', icon: Icon(Icons.cleaning_services)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateBookingDialog(),
            tooltip: 'Create New Booking',
          ),
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
          // Occupancy Tab
          const OccupancyBoard(),
          // Housekeeping Tab
          const HousekeepingStatus(),
        ],
      ),
    );
  }

  Widget _buildListViewTab(
    AsyncValue<List<Booking>> bookingsAsync,
    AsyncValue<Map<String, dynamic>> statisticsAsync,
  ) {
    return Column(
      children: [
        // Statistics Cards
        _buildStatisticsCards(statisticsAsync),
        
        // Search and Filter Section
        _buildSearchAndFilters(),
        
        // Bookings List
        Expanded(
          child: _buildBookingsList(bookingsAsync),
        ),
      ],
    );
  }

  Widget _buildStatisticsCards(AsyncValue<Map<String, dynamic>> statisticsAsync) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: statisticsAsync.when(
        data: (statistics) {
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Bookings',
                  '${statistics['totalBookings'] ?? 0}',
                  Icons.book_online,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Active Bookings',
                  '${statistics['activeBookings'] ?? 0}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Pending Bookings',
                  '${statistics['pendingBookings'] ?? 0}',
                  Icons.pending,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  'Total Revenue',
                  'MYR ${(statistics['totalRevenue'] ?? 0.0).toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.green,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search bookings...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                // TODO: Implement search functionality
              },
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 150,
            child: DropdownButtonFormField<BookingStatus?>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All'),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getStatusColor(booking.status),
            width: 2,
          ),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: _getStatusColor(booking.status),
            child: Text(
              booking.bookingNumber.split('-').last,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  '${booking.customerName} - ${booking.petName}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(booking.status),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  booking.status.name.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Room: ${booking.roomNumber}'),
              Text('Check-in: ${booking.checkInDate.toString().split(' ')[0]} at ${booking.checkInTime.hour}:${booking.checkInTime.minute.toString().padLeft(2, '0')}'),
              Text('Check-out: ${booking.checkOutDate.toString().split(' ')[0]} at ${booking.checkOutTime.hour}:${booking.checkOutTime.minute.toString().padLeft(2, '0')}'),
              Text('Amount: MYR ${booking.totalAmount.toStringAsFixed(2)}'),
            ],
          ),
                     trailing: Row(
             mainAxisSize: MainAxisSize.min,
             children: [
               IconButton(
                 icon: const Icon(Icons.visibility, color: Colors.blue),
                 onPressed: onView,
                 tooltip: 'View Details',
               ),
               IconButton(
                 icon: const Icon(Icons.payment, color: Colors.green),
                 onPressed: onPayment,
                 tooltip: 'Process Payment',
               ),
               IconButton(
                 icon: const Icon(Icons.history, color: Colors.purple),
                 onPressed: onPaymentHistory,
                 tooltip: 'Payment History',
               ),
               IconButton(
                 icon: const Icon(Icons.edit, color: Colors.orange),
                 onPressed: onEdit,
                 tooltip: 'Edit Booking',
               ),
               if (booking.status == BookingStatus.confirmed) ...[
                 IconButton(
                   icon: const Icon(Icons.login, color: Colors.green),
                   onPressed: onCheckIn,
                   tooltip: 'Check In',
                 ),
               ],
               if (booking.status == BookingStatus.checkedIn) ...[
                 IconButton(
                   icon: const Icon(Icons.logout, color: Colors.blue),
                   onPressed: onCheckOut,
                   tooltip: 'Check Out',
                 ),
               ],
               if (booking.status == BookingStatus.pending || booking.status == BookingStatus.confirmed) ...[
                 IconButton(
                   icon: const Icon(Icons.cancel, color: Colors.red),
                   onPressed: onCancel,
                   tooltip: 'Cancel Booking',
                 ),
               ],
               IconButton(
                 icon: const Icon(Icons.delete, color: Colors.red),
                 onPressed: onDelete,
                 tooltip: 'Delete Booking',
               ),
             ],
           ),
        ),
      ),
    );
  }
}
