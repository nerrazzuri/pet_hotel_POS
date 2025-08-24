import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:cat_hotel_pos/features/booking/presentation/providers/booking_providers.dart';
import 'package:cat_hotel_pos/features/booking/presentation/widgets/calendar_view.dart';
import 'package:cat_hotel_pos/features/booking/presentation/widgets/occupancy_board.dart';
import 'package:cat_hotel_pos/features/booking/presentation/widgets/housekeeping_status.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  BookingStatus? _selectedStatus;
  BookingType? _selectedType;
  DateTime? _fromDate;
  DateTime? _toDate;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    ref.read(bookingFilterNotifierProvider.notifier).updateFilters(
      query: _searchController.text.isEmpty ? null : _searchController.text,
      status: _selectedStatus,
      type: _selectedType,
      fromDate: _fromDate,
      toDate: _toDate,
    );
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _selectedStatus = null;
      _selectedType = null;
      _fromDate = null;
      _toDate = null;
    });
    ref.read(bookingFilterNotifierProvider.notifier).clearFilters();
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
        data: (stats) => Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Total Bookings',
                '${stats['totalBookings'] ?? 0}',
                Icons.book_online,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Active Bookings',
                '${stats['activeBookings'] ?? 0}',
                Icons.hotel,
                Colors.green,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Pending',
                '${stats['pendingBookings'] ?? 0}',
                Icons.schedule,
                Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Total Revenue',
                '\$${(stats['totalRevenue'] ?? 0.0).toStringAsFixed(2)}',
                Icons.attach_money,
                Colors.purple,
              ),
            ),
          ],
        ),
        loading: () => const Row(
          children: [
            Expanded(child: _StatCardSkeleton()),
            SizedBox(width: 16),
            Expanded(child: _StatCardSkeleton()),
            SizedBox(width: 16),
            Expanded(child: _StatCardSkeleton()),
            SizedBox(width: 16),
            Expanded(child: _StatCardSkeleton()),
          ],
        ),
        error: (error, stack) => Container(
          padding: const EdgeInsets.all(16),
          child: Text('Error loading statistics: $error'),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search bookings...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _applyFilters();
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) => _applyFilters(),
          ),
          const SizedBox(height: 16),
          
          // Filter Row
          Row(
            children: [
              // Status Filter
              Expanded(
                child: DropdownButtonFormField<BookingStatus?>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
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
                    setState(() => _selectedStatus = value);
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 16),
              
              // Type Filter
              Expanded(
                child: DropdownButtonFormField<BookingType?>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('All Types'),
                    ),
                    ...BookingType.values.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.name.toUpperCase()),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedType = value);
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 16),
              
              // Date Range Filter
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _selectDateRange(context),
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_fromDate == null 
                            ? 'From Date' 
                            : '${_fromDate!.day}/${_fromDate!.month}/${_fromDate!.year}'),
                      ),
                    ),
                    const Text('to'),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () => _selectDateRange(context),
                        icon: const Icon(Icons.calendar_today),
                        label: Text(_toDate == null 
                            ? 'To Date' 
                            : '${_toDate!.day}/${_toDate!.month}/${_toDate!.year}'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Filter Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Filters'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _applyFilters,
                  icon: const Icon(Icons.filter_list),
                  label: const Text('Apply Filters'),
                ),
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

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _fromDate != null && _toDate != null
          ? DateTimeRange(start: _fromDate!, end: _toDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      _applyFilters();
    }
  }

  void _showCreateBookingDialog() {
    showDialog(
      context: context,
      builder: (context) => const _CreateBookingDialog(),
    );
  }

  void _showEditBookingDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => _EditBookingDialog(booking: booking),
    );
  }

  void _showDeleteBookingDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => _DeleteBookingDialog(booking: booking),
    );
  }

  void _showBookingDetailsDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => _BookingDetailsDialog(booking: booking),
    );
  }

  void _showCancelBookingDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => _CancelBookingDialog(booking: booking),
    );
  }

  Future<void> _checkInBooking(Booking booking) async {
    try {
      await ref.read(bookingNotifierProvider.notifier).checkIn(booking.id);
      ref.invalidate(filteredBookingsProvider);
      ref.invalidate(bookingStatisticsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking checked in successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking in: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkOutBooking(Booking booking) async {
    try {
      await ref.read(bookingNotifierProvider.notifier).checkOut(booking.id);
      ref.invalidate(filteredBookingsProvider);
      ref.invalidate(bookingStatisticsProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking checked out successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Statistics Card Skeleton
class _StatCardSkeleton extends StatelessWidget {
  const _StatCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 60,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 80,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Booking Card Widget
class _BookingCard extends StatelessWidget {
  final Booking booking;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onView;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;
  final VoidCallback onCancel;

  const _BookingCard({
    required this.booking,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
    required this.onCheckIn,
    required this.onCheckOut,
    required this.onCancel,
  });

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.checkedIn:
        return Colors.green;
      case BookingStatus.checkedOut:
        return Colors.grey;
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.noShow:
        return Colors.red[700]!;
      case BookingStatus.completed:
        return Colors.purple;
    }
  }

  Color _getTypeColor(BookingType type) {
    switch (type) {
      case BookingType.standard:
        return Colors.blue;
      case BookingType.extended:
        return Colors.purple;
      case BookingType.emergency:
        return Colors.red;
      case BookingType.medical:
        return Colors.teal;
      case BookingType.grooming:
        return Colors.pink;
      case BookingType.training:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
                      Row(
                        children: [
                          Text(
                            booking.bookingNumber,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
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
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getTypeColor(booking.type),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              booking.type.name.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${booking.customerName} - ${booking.petName}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Room ${booking.roomNumber}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        onView();
                        break;
                      case 'edit':
                        onEdit();
                        break;
                      case 'checkin':
                        onCheckIn();
                        break;
                      case 'checkout':
                        onCheckOut();
                        break;
                      case 'cancel':
                        onCancel();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility),
                          SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    if (booking.status == BookingStatus.confirmed)
                      const PopupMenuItem(
                        value: 'checkin',
                        child: Row(
                          children: [
                            Icon(Icons.login),
                            SizedBox(width: 8),
                            Text('Check In'),
                          ],
                        ),
                      ),
                    if (booking.status == BookingStatus.checkedIn)
                      const PopupMenuItem(
                        value: 'checkout',
                        child: Row(
                          children: [
                            Icon(Icons.logout),
                            SizedBox(width: 8),
                            Text('Check Out'),
                          ],
                        ),
                      ),
                    if (booking.status != BookingStatus.checkedOut && 
                        booking.status != BookingStatus.cancelled)
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                    if (booking.status != BookingStatus.checkedOut && 
                        booking.status != BookingStatus.cancelled)
                      const PopupMenuItem(
                        value: 'cancel',
                        child: Row(
                          children: [
                            Icon(Icons.cancel),
                            SizedBox(width: 8),
                            Text('Cancel'),
                          ],
                        ),
                      ),
                    if (booking.status != BookingStatus.checkedIn)
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete),
                            SizedBox(width: 8),
                            Text('Delete'),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Booking Details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        icon: Icons.calendar_today,
                        label: 'Check-in',
                        value: '${booking.checkInDate.day}/${booking.checkInDate.month}/${booking.checkInDate.year}',
                      ),
                      _DetailRow(
                        icon: Icons.access_time,
                        label: 'Time',
                        value: '${booking.checkInTime.hour.toString().padLeft(2, '0')}:${booking.checkInTime.minute.toString().padLeft(2, '0')}',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        icon: Icons.calendar_today,
                        label: 'Check-out',
                        value: '${booking.checkOutDate.day}/${booking.checkOutDate.month}/${booking.checkOutDate.year}',
                      ),
                      _DetailRow(
                        icon: Icons.access_time,
                        label: 'Time',
                        value: '${booking.checkOutTime.hour.toString().padLeft(2, '0')}:${booking.checkOutTime.minute.toString().padLeft(2, '0')}',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        icon: Icons.attach_money,
                        label: 'Base Price',
                        value: '\$${booking.basePricePerNight.toStringAsFixed(2)}/night',
                      ),
                      _DetailRow(
                        icon: Icons.account_balance_wallet,
                        label: 'Total Amount',
                        value: '\$${booking.totalAmount.toStringAsFixed(2)}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (booking.specialInstructions != null && booking.specialInstructions!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Special Instructions:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                booking.specialInstructions!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder dialogs - these will be implemented in the next iteration
class _CreateBookingDialog extends ConsumerStatefulWidget {
  const _CreateBookingDialog();

  @override
  ConsumerState<_CreateBookingDialog> createState() => _CreateBookingDialogState();
}

class _CreateBookingDialogState extends ConsumerState<_CreateBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _bookingNumberController = TextEditingController();
  final _checkInDateController = TextEditingController();
  final _checkOutDateController = TextEditingController();
  final _checkInTimeController = TextEditingController();
  final _checkOutTimeController = TextEditingController();
  
  String? _selectedCustomerId;
  String? _selectedPetId;
  String? _selectedRoomId;
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  TimeOfDay? _checkInTime;
  TimeOfDay? _checkOutTime;
  BookingType _selectedType = BookingType.standard;
  double _basePricePerNight = 0.0;
  double _depositAmount = 0.0;
  double _discountAmount = 0.0;
  double _taxAmount = 0.0;
  String _specialInstructions = '';
  String _careNotes = '';
  String _veterinaryNotes = '';
  List<String> _additionalServices = [];
  Map<String, double> _servicePrices = {};
  bool _isLoading = false;

  // Helper method to convert Flutter's TimeOfDay to our custom BookingTimeOfDay
  BookingTimeOfDay _convertToBookingTimeOfDay(TimeOfDay timeOfDay) {
    return BookingTimeOfDay(hour: timeOfDay.hour, minute: timeOfDay.minute);
  }

  @override
  void initState() {
    super.initState();
    _checkInDate = DateTime.now().add(const Duration(days: 1));
    _checkOutDate = DateTime.now().add(const Duration(days: 2));
    _checkInTime = const TimeOfDay(hour: 14, minute: 0);
    _checkOutTime = const TimeOfDay(hour: 11, minute: 0);
    _updateControllers();
  }

  // Helper method to update the text controllers
  void _updateControllers() {
    _checkInDateController.text = _checkInDate?.toString().split(' ')[0] ?? '';
    _checkOutDateController.text = _checkOutDate?.toString().split(' ')[0] ?? '';
    _checkInTimeController.text = _checkInTime?.format(context) ?? '';
    _checkOutTimeController.text = _checkOutTime?.format(context) ?? '';
  }

  @override
  void dispose() {
    _bookingNumberController.dispose();
    _checkInDateController.dispose();
    _checkOutDateController.dispose();
    _checkInTimeController.dispose();
    _checkOutTimeController.dispose();
    super.dispose();
  }

  Future<void> _saveBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomerId == null || _selectedPetId == null || _selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final bookingService = ref.read(bookingServiceProvider);
      
      await bookingService.createBooking(
        customerId: _selectedCustomerId!,
        petId: _selectedPetId!,
        roomId: _selectedRoomId!,
        checkInDate: _checkInDate!,
        checkOutDate: _checkOutDate!,
        checkInTime: _convertToBookingTimeOfDay(_checkInTime!),
        checkOutTime: _convertToBookingTimeOfDay(_checkOutTime!),
        type: _selectedType,
        basePricePerNight: _basePricePerNight,
        additionalServices: _additionalServices.isNotEmpty ? _additionalServices : null,
        servicePrices: _servicePrices.isNotEmpty ? _servicePrices : null,
        specialInstructions: _specialInstructions.isNotEmpty ? _specialInstructions : null,
        careNotes: _careNotes.isNotEmpty ? _careNotes : null,
        veterinaryNotes: _veterinaryNotes.isNotEmpty ? _veterinaryNotes : null,
        depositAmount: _depositAmount > 0 ? _depositAmount : null,
        discountAmount: _discountAmount > 0 ? _discountAmount : null,
        taxAmount: _taxAmount > 0 ? _taxAmount : null,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking created successfully!')),
        );
        // Refresh the bookings list
        ref.invalidate(bookingsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating booking: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _updateBasePrice() {
    if (_selectedRoomId != null) {
      final roomsAsync = ref.read(roomsProvider);
      roomsAsync.whenData((rooms) {
        final selectedRoom = rooms.firstWhere((room) => room.id == _selectedRoomId);
        setState(() {
          _basePricePerNight = selectedRoom.basePricePerNight;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersProvider);
    final petsAsync = ref.watch(petsProvider);
    final roomsAsync = ref.watch(roomsProvider);

    return AlertDialog(
      title: const Text('Create New Booking'),
      content: SizedBox(
        width: 800,
        height: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer and Pet Selection
                Row(
                  children: [
                    Expanded(
                      child: customersAsync.when(
                        data: (customers) => DropdownButtonFormField<String>(
                          value: _selectedCustomerId,
                          decoration: const InputDecoration(
                            labelText: 'Customer *',
                            border: OutlineInputBorder(),
                          ),
                          items: customers.map((customer) => DropdownMenuItem(
                            value: customer.id,
                            child: Text('${customer.firstName} ${customer.lastName} (${customer.phoneNumber})'),
                          )).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCustomerId = value;
                              _selectedPetId = null;
                            });
                          },
                          validator: (value) => value == null ? 'Please select a customer' : null,
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) => Text('Error: $error'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _selectedCustomerId != null
                          ? petsAsync.when(
                              data: (pets) {
                                final customerPets = pets.where((pet) => pet.customerId == _selectedCustomerId).toList();
                                return DropdownButtonFormField<String>(
                                  value: _selectedPetId,
                                  decoration: const InputDecoration(
                                    labelText: 'Pet *',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: customerPets.map((pet) => DropdownMenuItem(
                                    value: pet.id,
                                    child: Text('${pet.name} (${pet.breed})'),
                                  )).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedPetId = value;
                                    });
                                  },
                                  validator: (value) => value == null ? 'Please select a pet' : null,
                                );
                              },
                              loading: () => const CircularProgressIndicator(),
                              error: (error, stack) => Text('Error: $error'),
                            )
                          : DropdownButtonFormField<String>(
                              value: null,
                              decoration: const InputDecoration(
                                labelText: 'Pet *',
                                border: OutlineInputBorder(),
                                enabled: false,
                              ),
                              items: [],
                              onChanged: (value) {},
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Room Selection and Type
                Row(
                  children: [
                    Expanded(
                      child: roomsAsync.when(
                        data: (rooms) => DropdownButtonFormField<String>(
                          value: _selectedRoomId,
                          decoration: const InputDecoration(
                            labelText: 'Room *',
                            border: OutlineInputBorder(),
                          ),
                          items: rooms
                              .where((room) => room.status == RoomStatus.available)
                              .map((room) => DropdownMenuItem(
                                    value: room.id,
                                    child: Text('${room.roomNumber} - ${room.name} (${room.type.name})'),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedRoomId = value;
                            });
                            _updateBasePrice();
                          },
                          validator: (value) => value == null ? 'Please select a room' : null,
                        ),
                        loading: () => const CircularProgressIndicator(),
                        error: (error, stack) => Text('Error: $error'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<BookingType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Booking Type *',
                          border: OutlineInputBorder(),
                        ),
                        items: BookingType.values.map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.name.toUpperCase()),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedType = value;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Dates and Times
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Check-in Date *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        controller: _checkInDateController,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _checkInDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() {
                              _checkInDate = date;
                              if (_checkOutDate != null && _checkOutDate!.isBefore(date)) {
                                _checkOutDate = date.add(const Duration(days: 1));
                              }
                            });
                            _updateControllers();
                          }
                        },
                        validator: (value) => _checkInDate == null ? 'Please select check-in date' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Check-out Date *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        controller: _checkOutDateController,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _checkOutDate ?? DateTime.now().add(const Duration(days: 1)),
                            firstDate: _checkInDate ?? DateTime.now().add(const Duration(days: 1)),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() {
                              _checkOutDate = date;
                            });
                            _updateControllers();
                          }
                        },
                        validator: (value) => _checkOutDate == null ? 'Please select check-out date' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Check-in Time *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        controller: _checkInTimeController,
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _checkInTime ?? const TimeOfDay(hour: 14, minute: 0),
                          );
                          if (time != null) {
                            setState(() {
                              _checkInTime = time;
                            });
                            _updateControllers();
                          }
                        },
                        validator: (value) => _checkInTime == null ? 'Please select check-in time' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Check-out Time *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        controller: _checkOutTimeController,
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _checkOutTime ?? const TimeOfDay(hour: 11, minute: 0),
                          );
                          if (time != null) {
                            setState(() {
                              _checkOutTime = time;
                            });
                            _updateControllers();
                          }
                        },
                        validator: (value) => _checkOutTime == null ? 'Please select check-out time' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Pricing Section
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Base Price per Night',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        controller: TextEditingController(
                          text: '\$${_basePricePerNight.toStringAsFixed(2)}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Deposit Amount',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.payment),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _depositAmount = double.tryParse(value) ?? 0.0;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Discount Amount',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.discount),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _discountAmount = double.tryParse(value) ?? 0.0;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Tax Amount',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.receipt),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            _taxAmount = double.tryParse(value) ?? 0.0;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Notes Section
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Special Instructions',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 2,
                  onChanged: (value) {
                    setState(() {
                      _specialInstructions = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Care Notes',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.pets),
                        ),
                        maxLines: 2,
                        onChanged: (value) {
                          setState(() {
                            _careNotes = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Veterinary Notes',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.medical_services),
                        ),
                        maxLines: 2,
                        onChanged: (value) {
                          setState(() {
                            _veterinaryNotes = value;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveBooking,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Booking'),
        ),
      ],
    );
  }
}

class _EditBookingDialog extends ConsumerStatefulWidget {
  final Booking booking;
  
  const _EditBookingDialog({required this.booking});

  @override
  ConsumerState<_EditBookingDialog> createState() => _EditBookingDialogState();
}

class _EditBookingDialogState extends ConsumerState<_EditBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  
  late DateTime _checkInDate;
  late DateTime _checkOutDate;
  late TimeOfDay _checkInTime;
  late TimeOfDay _checkOutTime;
  late BookingType _selectedType;
  late double _basePricePerNight;
  late double _depositAmount;
  late double _discountAmount;
  late double _taxAmount;
  late String _specialInstructions;
  late String _careNotes;
  late String _veterinaryNotes;
  late List<String> _additionalServices;
  late Map<String, double> _servicePrices;

  // Helper method to convert Flutter's TimeOfDay to our custom BookingTimeOfDay
  BookingTimeOfDay _convertToBookingTimeOfDay(TimeOfDay timeOfDay) {
    return BookingTimeOfDay(hour: timeOfDay.hour, minute: timeOfDay.minute);
  }

  @override
  void initState() {
    super.initState();
    _checkInDate = widget.booking.checkInDate;
    _checkOutDate = widget.booking.checkOutDate;
    _checkInTime = TimeOfDay(hour: widget.booking.checkInTime.hour, minute: widget.booking.checkInTime.minute);
    _checkOutTime = TimeOfDay(hour: widget.booking.checkOutTime.hour, minute: widget.booking.checkOutTime.minute);
    _selectedType = widget.booking.type;
    _basePricePerNight = widget.booking.basePricePerNight;
    _depositAmount = widget.booking.depositAmount ?? 0.0;
    _discountAmount = widget.booking.discountAmount ?? 0.0;
    _taxAmount = widget.booking.taxAmount ?? 0.0;
    _specialInstructions = widget.booking.specialInstructions ?? '';
    _careNotes = widget.booking.careNotes ?? '';
    _veterinaryNotes = widget.booking.veterinaryNotes ?? '';
    _additionalServices = widget.booking.additionalServices ?? [];
    _servicePrices = widget.booking.servicePrices ?? {};
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Booking ${widget.booking.bookingNumber}'),
      content: SizedBox(
        width: 800,
        height: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer and Pet Info (Read-only)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: widget.booking.customerName,
                        decoration: const InputDecoration(
                          labelText: 'Customer',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: widget.booking.petName,
                        decoration: const InputDecoration(
                          labelText: 'Pet',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Room Info (Read-only)
                TextFormField(
                  initialValue: widget.booking.roomNumber,
                  decoration: const InputDecoration(
                    labelText: 'Room',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 16),

                // Date and Time Selection
                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _checkInDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => _checkInDate = date);
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text('Check-in: ${_checkInDate.day}/${_checkInDate.month}/${_checkInDate.year}'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _checkInTime,
                          );
                          if (time != null) {
                            setState(() => _checkInTime = time);
                          }
                        },
                        icon: const Icon(Icons.access_time),
                        label: Text('Time: ${_checkInTime.hour}:${_checkInTime.minute.toString().padLeft(2, '0')}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _checkOutDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => _checkOutDate = date);
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text('Check-out: ${_checkOutDate.day}/${_checkOutDate.month}/${_checkOutDate.year}'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextButton.icon(
                        onPressed: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: _checkOutTime,
                          );
                          if (time != null) {
                            setState(() => _checkOutTime = time);
                          }
                        },
                        icon: const Icon(Icons.access_time),
                        label: Text('Time: ${_checkOutTime.hour}:${_checkOutTime.minute.toString().padLeft(2, '0')}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Booking Type and Pricing
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<BookingType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Booking Type',
                          border: OutlineInputBorder(),
                        ),
                        items: BookingType.values.map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.name.toUpperCase()),
                        )).toList(),
                        onChanged: (value) => setState(() => _selectedType = value!),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: _basePricePerNight.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Base Price per Night (\$)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => setState(() => _basePricePerNight = double.tryParse(value) ?? 0.0),
                        validator: (value) => value == null || value.isEmpty ? 'Please enter base price' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Additional Costs
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: _depositAmount.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Deposit Amount (\$)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => setState(() => _depositAmount = double.tryParse(value) ?? 0.0),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: _discountAmount.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Discount Amount (\$)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => setState(() => _discountAmount = double.tryParse(value) ?? 0.0),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        initialValue: _taxAmount.toString(),
                        decoration: const InputDecoration(
                          labelText: 'Tax Amount (\$)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => setState(() => _taxAmount = double.tryParse(value) ?? 0.0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  initialValue: _specialInstructions,
                  decoration: const InputDecoration(
                    labelText: 'Special Instructions',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onChanged: (value) => setState(() => _specialInstructions = value),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  initialValue: _careNotes,
                  decoration: const InputDecoration(
                    labelText: 'Care Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onChanged: (value) => setState(() => _careNotes = value),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  initialValue: _veterinaryNotes,
                  decoration: const InputDecoration(
                    labelText: 'Veterinary Notes',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                  onChanged: (value) => setState(() => _veterinaryNotes = value),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _updateBooking,
          child: const Text('Update Booking'),
        ),
      ],
    );
  }

  Future<void> _updateBooking() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final bookingService = ref.read(bookingServiceProvider);
      
      await bookingService.updateBooking(
        id: widget.booking.id,
        checkInDate: _checkInDate,
        checkOutDate: _checkOutDate,
        checkInTime: _convertToBookingTimeOfDay(_checkInTime),
        checkOutTime: _convertToBookingTimeOfDay(_checkOutTime),
        type: _selectedType,
        basePricePerNight: _basePricePerNight,
        additionalServices: _additionalServices.isNotEmpty ? _additionalServices : null,
        servicePrices: _servicePrices.isNotEmpty ? _servicePrices : null,
        specialInstructions: _specialInstructions.isNotEmpty ? _specialInstructions : null,
        careNotes: _careNotes.isNotEmpty ? _careNotes : null,
        veterinaryNotes: _veterinaryNotes.isNotEmpty ? _veterinaryNotes : null,
        depositAmount: _depositAmount > 0 ? _depositAmount : null,
        discountAmount: _discountAmount > 0 ? _discountAmount : null,
        taxAmount: _taxAmount > 0 ? _taxAmount : null,
      );

      Navigator.of(context).pop();
      ref.invalidate(bookingsProvider);
      ref.invalidate(activeBookingsProvider);
      ref.invalidate(upcomingBookingsProvider);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating booking: $e')),
      );
    }
  }
}

class _DeleteBookingDialog extends ConsumerStatefulWidget {
  final Booking booking;
  
  const _DeleteBookingDialog({required this.booking});

  @override
  ConsumerState<_DeleteBookingDialog> createState() => _DeleteBookingDialogState();
}

class _DeleteBookingDialogState extends ConsumerState<_DeleteBookingDialog> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete Booking ${widget.booking.bookingNumber}'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete this booking?'),
            const SizedBox(height: 16),
            Text('Customer: ${widget.booking.customerName}'),
            Text('Pet: ${widget.booking.petName}'),
            Text('Room: ${widget.booking.roomNumber}'),
            Text('Check-in: ${widget.booking.checkInDate.day}/${widget.booking.checkInDate.month}/${widget.booking.checkInDate.year}'),
            Text('Check-out: ${widget.booking.checkOutDate.day}/${widget.booking.checkOutDate.month}/${widget.booking.checkOutDate.year}'),
            const SizedBox(height: 16),
            Text(
              'This action cannot be undone. The booking will be permanently removed from the system.',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isDeleting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isDeleting ? null : _deleteBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: _isDeleting 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Delete'),
        ),
      ],
    );
  }

  Future<void> _deleteBooking() async {
    setState(() => _isDeleting = true);

    try {
      final bookingService = ref.read(bookingServiceProvider);
      await bookingService.deleteBooking(widget.booking.id);

      Navigator.of(context).pop();
      ref.invalidate(bookingsProvider);
      ref.invalidate(activeBookingsProvider);
      ref.invalidate(upcomingBookingsProvider);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting booking: $e')),
      );
    } finally {
      setState(() => _isDeleting = false);
    }
  }
}

class _BookingDetailsDialog extends StatelessWidget {
  final Booking booking;
  
  const _BookingDetailsDialog({required this.booking});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Booking ${booking.bookingNumber} Details'),
      content: SizedBox(
        width: 700,
        height: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              _buildSection('Basic Information', [
                _buildInfoRow('Booking Number', booking.bookingNumber),
                _buildInfoRow('Status', booking.status.name.toUpperCase()),
                _buildInfoRow('Type', booking.type.name.toUpperCase()),
                _buildInfoRow('Created', '${booking.createdAt.day}/${booking.createdAt.month}/${booking.createdAt.year}'),
                _buildInfoRow('Last Updated', '${booking.updatedAt.day}/${booking.updatedAt.month}/${booking.updatedAt.year}'),
              ]),
              const SizedBox(height: 16),

              // Customer and Pet Information
              _buildSection('Customer & Pet', [
                _buildInfoRow('Customer', booking.customerName),
                _buildInfoRow('Pet', booking.petName),
                _buildInfoRow('Room', booking.roomNumber),
              ]),
              const SizedBox(height: 16),

              // Dates and Times
              _buildSection('Schedule', [
                _buildInfoRow('Check-in Date', '${booking.checkInDate.day}/${booking.checkInDate.month}/${booking.checkInDate.year}'),
                _buildInfoRow('Check-in Time', '${booking.checkInTime.hour}:${booking.checkInTime.minute.toString().padLeft(2, '0')}'),
                _buildInfoRow('Check-out Date', '${booking.checkOutDate.day}/${booking.checkOutDate.month}/${booking.checkOutDate.year}'),
                _buildInfoRow('Check-out Time', '${booking.checkOutTime.hour}:${booking.checkOutTime.minute.toString().padLeft(2, '0')}'),
                if (booking.actualCheckInTime != null)
                  _buildInfoRow('Actual Check-in', '${booking.actualCheckInTime!.day}/${booking.actualCheckInTime!.month}/${booking.actualCheckInTime!.year}'),
                if (booking.actualCheckOutTime != null)
                  _buildInfoRow('Actual Check-out', '${booking.actualCheckOutTime!.day}/${booking.actualCheckOutTime!.month}/${booking.actualCheckOutTime!.year}'),
              ]),
              const SizedBox(height: 16),

              // Financial Information
              _buildSection('Financial', [
                _buildInfoRow('Base Price per Night', '\$${booking.basePricePerNight.toStringAsFixed(2)}'),
                _buildInfoRow('Total Amount', '\$${booking.totalAmount.toStringAsFixed(2)}'),
                if (booking.depositAmount != null && booking.depositAmount! > 0)
                  _buildInfoRow('Deposit Amount', '\$${booking.depositAmount!.toStringAsFixed(2)}'),
                if (booking.discountAmount != null && booking.discountAmount! > 0)
                  _buildInfoRow('Discount Amount', '\$${booking.discountAmount!.toStringAsFixed(2)}'),
                if (booking.taxAmount != null && booking.taxAmount! > 0)
                  _buildInfoRow('Tax Amount', '\$${booking.taxAmount!.toStringAsFixed(2)}'),
                if (booking.paymentStatus != null)
                  _buildInfoRow('Payment Status', booking.paymentStatus!),
                if (booking.paymentMethod != null)
                  _buildInfoRow('Payment Method', booking.paymentMethod!),
              ]),
              const SizedBox(height: 16),

              // Additional Services
              if (booking.additionalServices != null && booking.additionalServices!.isNotEmpty)
                _buildSection('Additional Services', [
                  ...booking.additionalServices!.map((service) => _buildInfoRow('Service', service)),
                ]),
              const SizedBox(height: 16),

              // Notes
              if (booking.specialInstructions != null && booking.specialInstructions!.isNotEmpty)
                _buildSection('Special Instructions', [
                  _buildInfoRow('Instructions', booking.specialInstructions!),
                ]),
              if (booking.careNotes != null && booking.careNotes!.isNotEmpty)
                _buildSection('Care Notes', [
                  _buildInfoRow('Notes', booking.careNotes!),
                ]),
              if (booking.veterinaryNotes != null && booking.veterinaryNotes!.isNotEmpty)
                _buildSection('Veterinary Notes', [
                  _buildInfoRow('Notes', booking.veterinaryNotes!),
                ]),
              const SizedBox(height: 16),

              // Staff Assignment
              if (booking.assignedStaffId != null)
                _buildSection('Staff Assignment', [
                  _buildInfoRow('Assigned Staff', booking.assignedStaffName ?? 'Unknown'),
                ]),
              const SizedBox(height: 16),

              // Cancellation Information (if applicable)
              if (booking.status == BookingStatus.cancelled)
                _buildSection('Cancellation', [
                  if (booking.cancellationReason != null)
                    _buildInfoRow('Reason', booking.cancellationReason!),
                                  if (booking.cancelledAt != null)
                  _buildInfoRow('Cancelled At', '${booking.cancelledAt!.day}/${booking.cancelledAt!.month}/${booking.cancelledAt!.year}'),
                  if (booking.cancelledBy != null)
                    _buildInfoRow('Cancelled By', booking.cancelledBy!),
                  if (booking.refundAmount != null && booking.refundAmount! > 0)
                    _buildInfoRow('Refund Amount', '\$${booking.refundAmount!.toStringAsFixed(2)}'),
                ]),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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
}

class _CancelBookingDialog extends ConsumerStatefulWidget {
  final Booking booking;
  
  const _CancelBookingDialog({required this.booking});

  @override
  ConsumerState<_CancelBookingDialog> createState() => _CancelBookingDialogState();
}

class _CancelBookingDialogState extends ConsumerState<_CancelBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _refundAmountController = TextEditingController();
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _refundAmountController.text = widget.booking.totalAmount.toString();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _refundAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Cancel Booking ${widget.booking.bookingNumber}'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Booking Information
              Text('Customer: ${widget.booking.customerName}'),
              Text('Pet: ${widget.booking.petName}'),
              Text('Room: ${widget.booking.roomNumber}'),
              Text('Check-in: ${widget.booking.checkInDate.day}/${widget.booking.checkInDate.month}/${widget.booking.checkInDate.year}'),
              Text('Check-out: ${widget.booking.checkOutDate.day}/${widget.booking.checkOutDate.month}/${widget.booking.checkOutDate.year}'),
              Text('Total Amount: \$${widget.booking.totalAmount.toStringAsFixed(2)}'),
              const SizedBox(height: 16),

              // Cancellation Reason
              TextFormField(
                controller: _reasonController,
                decoration: const InputDecoration(
                  labelText: 'Cancellation Reason *',
                  border: OutlineInputBorder(),
                  hintText: 'Please provide a reason for cancellation',
                ),
                maxLines: 3,
                validator: (value) => value == null || value.trim().isEmpty 
                    ? 'Please provide a cancellation reason' 
                    : null,
              ),
              const SizedBox(height: 16),

              // Refund Amount
              TextFormField(
                controller: _refundAmountController,
                decoration: const InputDecoration(
                  labelText: 'Refund Amount (\$)',
                  border: OutlineInputBorder(),
                  hintText: 'Amount to refund to customer',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return null;
                  final amount = double.tryParse(value);
                  if (amount == null || amount < 0) {
                    return 'Please enter a valid amount';
                  }
                  if (amount > widget.booking.totalAmount) {
                    return 'Refund cannot exceed total amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Warning
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Cancelling this booking will free up the room and may affect customer satisfaction. This action cannot be easily undone.',
                        style: TextStyle(color: Colors.orange[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isCancelling ? null : () => Navigator.of(context).pop(),
          child: const Text('Keep Booking'),
        ),
        ElevatedButton(
          onPressed: _isCancelling ? null : _cancelBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
          ),
          child: _isCancelling 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Cancel Booking'),
        ),
      ],
    );
  }

  Future<void> _cancelBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCancelling = true);

    try {
      final bookingService = ref.read(bookingServiceProvider);
      final refundAmount = double.tryParse(_refundAmountController.text) ?? 0.0;
      
      await bookingService.cancelBooking(
        widget.booking.id,
        _reasonController.text.trim(),
        refundAmount > 0 ? refundAmount : null,
      );

      Navigator.of(context).pop();
      ref.invalidate(bookingsProvider);
      ref.invalidate(activeBookingsProvider);
      ref.invalidate(upcomingBookingsProvider);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cancelling booking: $e')),
      );
    } finally {
      setState(() => _isCancelling = false);
    }
  }
}
