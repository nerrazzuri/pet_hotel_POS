import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/checkin_request.dart';
import 'package:cat_hotel_pos/features/pos/domain/services/checkin_service.dart';
import 'package:cat_hotel_pos/features/pos/domain/services/pet_inspection_service.dart';
import 'package:cat_hotel_pos/features/pos/domain/services/checkin_payment_service.dart';
import 'package:cat_hotel_pos/features/pos/presentation/widgets/pet_inspection_widget.dart';
import 'package:cat_hotel_pos/features/pos/presentation/widgets/checkin_payment_widget.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/pet.dart';
import 'package:cat_hotel_pos/features/customers/domain/services/customer_service.dart';
import 'package:cat_hotel_pos/features/customers/domain/services/customer_pet_service.dart';
import 'package:cat_hotel_pos/features/booking/domain/services/room_service.dart';
import 'package:cat_hotel_pos/features/booking/domain/services/booking_service.dart';
import 'package:cat_hotel_pos/core/services/booking_dao.dart';
import 'package:cat_hotel_pos/core/services/room_dao.dart';
import 'package:cat_hotel_pos/core/services/customer_dao.dart';
import 'package:cat_hotel_pos/core/services/pet_dao.dart';
import 'package:uuid/uuid.dart';
import 'package:cat_hotel_pos/features/payments/domain/services/payment_service.dart';
import 'package:cat_hotel_pos/features/payments/domain/entities/payment_transaction.dart';
import 'package:cat_hotel_pos/features/payments/domain/entities/payment_method.dart';

class CheckInScreen extends ConsumerStatefulWidget {
  const CheckInScreen({super.key});

  @override
  ConsumerState<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends ConsumerState<CheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchController = TextEditingController();
  
  // Step tracking
  int _currentStep = 0;
  final int _totalSteps = 4;
  
  // Search results
  List<Booking> _searchResults = [];
  List<Customer> _customerResults = [];
  List<Room> _availableRooms = [];
  bool _isSearching = false;
  
  // Selected data
  Booking? _selectedBooking;
  Customer? _selectedCustomer;
  Pet? _selectedPet;
  Room? _selectedRoom;
  List<String> _selectedServices = [];
  Map<String, double> _servicePrices = {};
  
  // Check-in data
  DateTime? _checkInTime;
  DateTime? _checkOutTime;
  String? _specialInstructions;
  String? _careNotes;
  
  // Services
  late final CheckInService _checkInService;
  late final CustomerService _customerService;
  late final CustomerPetService _petService;
  late final RoomService _roomService;
  late final BookingService _bookingService;
  final Uuid _uuid = const Uuid();
  
  @override
  void initState() {
    super.initState();
    _customerService = CustomerService();
    _petService = CustomerPetService();
    _roomService = RoomService(null); // Audit service is optional
    _bookingService = BookingService(
      bookingDao: BookingDao(),
      roomDao: RoomDao.instance,
      customerDao: CustomerDao(),
      petDao: PetDao(),
    );
    
    _checkInService = CheckInService(
      bookingService: _bookingService,
      roomService: _roomService,
      customerService: _customerService,
      petService: _petService,
      inspectionService: PetInspectionService(petService: _petService),
      paymentService: CheckInPaymentService(paymentService: MockPaymentService()), // TODO: Implement
    );
    
    _checkInTime = DateTime.now();
    _checkOutTime = DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Check-In'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),
          
          // Main content
          Expanded(
            child: _buildCurrentStep(),
          ),
          
          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalSteps, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;
              
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  decoration: BoxDecoration(
                    color: isCompleted 
                        ? Colors.green 
                        : isCurrent 
                            ? Colors.blue 
                            : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            _getStepTitle(_currentStep),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _buildCustomerSearchStep();
      case 1:
        return _buildPetSelectionStep();
      case 2:
        return _buildRoomAssignmentStep();
      case 3:
        return _buildCheckInConfirmationStep();
      default:
        return const Center(child: Text('Unknown step'));
    }
  }

  Widget _buildCustomerSearchStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Find Customer & Booking',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Today's Bookings Section
          _buildTodaysBookingsSection(),
          
          const SizedBox(height: 24),
          
          // Search input
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Search by name, phone, or booking number',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchResults.clear();
                    _customerResults.clear();
                  });
                },
              ),
            ),
            onChanged: _performSearch,
          ),
          
          const SizedBox(height: 24),
          
          // Search results
          if (_isSearching)
            const Center(child: CircularProgressIndicator())
          else if (_searchResults.isNotEmpty || _customerResults.isNotEmpty)
            Expanded(
              child: _buildSearchResults(),
            )
          else if (_searchController.text.isNotEmpty)
            const Center(
              child: Text('No results found. Try a different search term.'),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_searchResults.isNotEmpty) ...[
          const Text(
            'Existing Bookings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final booking = _searchResults[index];
                return _buildBookingCard(booking);
              },
            ),
          ),
        ],
        
        if (_customerResults.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text(
            'Customers',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: _customerResults.length,
              itemBuilder: (context, index) {
                final customer = _customerResults[index];
                return _buildCustomerCard(customer);
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBookingCard(Booking booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            booking.customerName[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(booking.customerName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pet: ${booking.petName}'),
            Text('Check-in: ${_formatDate(booking.checkInDate)}'),
            Text('Status: ${_getBookingStatusText(booking.status)}'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _selectExistingBooking(booking),
          child: const Text('Select'),
        ),
      ),
    );
  }

  Widget _buildCustomerCard(Customer customer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: Text(
              customer.fullName[0].toUpperCase(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(customer.fullName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Phone: ${customer.phoneNumber}'),
            Text('Pets: ${customer.pets?.length ?? 0}'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () => _selectCustomer(customer),
          child: const Text('Select'),
        ),
      ),
    );
  }

  Widget _buildTodaysBookingsSection() {
    return FutureBuilder<List<Booking>>(
      future: _getTodaysBookings(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return const SizedBox.shrink();
        }
        
        final todaysBookings = snapshot.data ?? [];
        
        if (todaysBookings.isEmpty) {
          return const SizedBox.shrink();
        }
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.today, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Today\'s Check-ins (${todaysBookings.length})',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: todaysBookings.length,
                itemBuilder: (context, index) {
                  final booking = todaysBookings[index];
                  return _buildTodaysBookingCard(booking);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTodaysBookingCard(Booking booking) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      booking.customerName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.customerName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          'Pet: ${booking.petName}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildTodaysBookingInfoRow('Room', '${booking.roomNumber}'),
              _buildTodaysBookingInfoRow('Check-in', _formatTime(booking.checkInTime)),
              _buildTodaysBookingInfoRow('Status', _getBookingStatusText(booking.status)),
              _buildTodaysBookingInfoRow('Amount', 'RM ${booking.totalAmount?.toStringAsFixed(2) ?? 'N/A'}'),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 36,
                child: ElevatedButton(
                  onPressed: () => _selectExistingBooking(booking),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: const Text('Check-in Now', style: TextStyle(fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysBookingInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetSelectionStep() {
    if (_selectedCustomer == null) {
      return const Center(child: Text('No customer selected'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Pet',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Customer info
          _buildCustomerInfoCard(),
          
          const SizedBox(height: 24),
          
          // Pet selection
          const Text(
            'Available Pets',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: _buildPetSelectionContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child:                  Text(
                   _selectedCustomer!.fullName[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedCustomer!.fullName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text('Phone: ${_selectedCustomer!.phoneNumber}'),
                  Text('Email: ${_selectedCustomer!.email ?? 'N/A'}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetSelectionContent() {
    print('DEBUG: _buildPetSelectionContent called');
    print('DEBUG: _selectedPet: ${_selectedPet?.name}');
    print('DEBUG: _selectedCustomer: ${_selectedCustomer?.fullName}');
    
    // If we have a selected pet from an existing booking, show it directly
    if (_selectedPet != null) {
      print('DEBUG: Showing selected pet from booking');
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selected Pet (from booking)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.green),
          ),
          const SizedBox(height: 16),
          _buildPetCard(_selectedPet!),
          const SizedBox(height: 24),
          const Text(
            'Other pets for this customer:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<List<Pet>>(
              future: _petService.getPetsByCustomerId(_selectedCustomer!.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return const Center(child: Text('Could not load other pets'));
                }
                
                final pets = snapshot.data ?? [];
                final otherPets = pets.where((pet) => pet.id != _selectedPet!.id).toList();
                
                if (otherPets.isEmpty) {
                  return const Center(
                    child: Text('No other pets found for this customer.'),
                  );
                }
                
                return ListView.builder(
                  itemCount: otherPets.length,
                  itemBuilder: (context, index) {
                    final pet = otherPets[index];
                    return _buildPetCard(pet);
                  },
                );
              },
            ),
          ),
        ],
      );
    }
    
    print('DEBUG: No selected pet, showing all pets for customer');
    // Otherwise, show all pets for the customer
    return FutureBuilder<List<Pet>>(
      future: _petService.getPetsByCustomerId(_selectedCustomer!.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        final pets = snapshot.data ?? [];
        print('DEBUG: Found ${pets.length} pets for customer');
        if (pets.isEmpty) {
          return const Center(
            child: Text('No pets found for this customer.'),
          );
        }
        
        return ListView.builder(
          itemCount: pets.length,
          itemBuilder: (context, index) {
            final pet = pets[index];
            return _buildPetCard(pet);
          },
        );
      },
    );
  }

  Widget _buildPetCard(Pet pet) {
    final isSelected = _selectedPet?.id == pet.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            _getPetTypeIcon(pet.type),
            color: Colors.white,
          ),
        ),
        title: Text(pet.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${pet.breed ?? 'Unknown'} • ${pet.gender.displayName}'),
            Text('Age: ${pet.age} years • Weight: ${pet.weight ?? 'N/A'} kg'),
          ],
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
        onTap: () => _selectPet(pet),
      ),
    );
  }

  Widget _buildRoomAssignmentStep() {
    if (_selectedPet == null) {
      return const Center(child: Text('No pet selected'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Room Assignment',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Pet info
          _buildPetInfoCard(),
          
          const SizedBox(height: 24),
          
          // Room selection
          const Text(
            'Available Rooms',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          Expanded(
            child: FutureBuilder<List<Room>>(
              future: _roomService.getAvailableRooms(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                
                final rooms = snapshot.data ?? [];
                if (rooms.isEmpty) {
                  return const Center(
                    child: Text('No rooms available at the moment.'),
                  );
                }
                
                print('DEBUG: Available rooms: ${rooms.map((r) => '${r.id} (${r.roomNumber})').join(', ')}');
                
                return ListView.builder(
                  itemCount: rooms.length,
                  itemBuilder: (context, index) {
                    final room = rooms[index];
                    return _buildRoomCard(room);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.secondary,
              child: Icon(
                _getPetTypeIcon(_selectedPet!.type),
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedPet!.name,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Text('${_selectedPet!.breed ?? 'Unknown'} • ${_selectedPet!.gender.displayName}'),
                  Text('Age: ${_selectedPet!.age} years • Weight: ${_selectedPet!.weight ?? 'N/A'} kg'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(Room room) {
    final isSelected = _selectedRoom?.id == room.id;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            room.roomNumber,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text('Room ${room.roomNumber}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${room.type.displayName} • ${room.capacity} pets'),
            Text('RM ${room.currentPrice ?? room.basePricePerNight}/night'),
            if (room.amenities.isNotEmpty)
              Text('Amenities: ${room.amenities.take(3).join(', ')}'),
          ],
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Colors.green)
            : null,
        onTap: () => _selectRoom(room),
      ),
    );
  }

  Widget _buildCheckInConfirmationStep() {
    if (_selectedRoom == null) {
      return const Center(child: Text('No room selected'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Check-In Confirmation',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          
          // Summary card
          _buildSummaryCard(),
          
          const SizedBox(height: 24),
          
          // Check-in form
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Check-In Details',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    // Date/time inputs
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateTimeField(
                            label: 'Check-in Date',
                            value: _checkInTime,
                            onChanged: (date) => setState(() => _checkInTime = date),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDateTimeField(
                            label: 'Check-out Date',
                            value: _checkOutTime,
                            onChanged: (date) => setState(() => _checkOutTime = date),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Special instructions
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Special Instructions',
                        border: OutlineInputBorder(),
                        hintText: 'Any special care requirements...',
                      ),
                      maxLines: 3,
                      onChanged: (value) => _specialInstructions = value,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Care notes
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Care Notes',
                        border: OutlineInputBorder(),
                        hintText: 'Additional care information...',
                      ),
                      maxLines: 3,
                      onChanged: (value) => _careNotes = value,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildSummaryRow('Customer', _selectedCustomer?.fullName ?? 'N/A'),
            _buildSummaryRow('Pet', _selectedPet?.name ?? 'N/A'),
            _buildSummaryRow('Room', 'Room ${_selectedRoom?.roomNumber ?? 'N/A'}'),
            _buildSummaryRow('Check-in', _formatDate(_checkInTime)),
            _buildSummaryRow('Check-out', _formatDate(_checkOutTime)),
            _buildSummaryRow('Duration', '${_checkOutTime?.difference(_checkInTime ?? DateTime.now()).inDays} days'),
            _buildSummaryRow('Rate', 'RM ${_selectedRoom?.currentPrice ?? _selectedRoom?.basePricePerNight ?? 0}/night'),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required DateTime? value,
    required Function(DateTime?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (date != null) {
              onChanged(date);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                Text(value?.toString().split(' ')[0] ?? 'Select date'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            ElevatedButton(
              onPressed: _previousStep,
              child: const Text('Previous'),
            )
          else
            const SizedBox.shrink(),
          
          if (_currentStep < _totalSteps - 1)
            ElevatedButton(
              onPressed: _canProceedToNextStep() ? _nextStep : null,
              child: const Text('Next'),
            )
          else
            ElevatedButton(
              onPressed: _canProceedToNextStep() ? _completeCheckIn : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Complete Check-In'),
            ),
        ],
      ),
    );
  }

  // Helper methods
  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Customer Search';
      case 1:
        return 'Pet Selection';
      case 2:
        return 'Room Assignment';
      case 3:
        return 'Confirmation';
      default:
        return 'Unknown';
    }
  }

  bool _canProceedToNextStep() {
    switch (_currentStep) {
      case 0:
        return _selectedBooking != null || _selectedCustomer != null;
      case 1:
        return _selectedPet != null;
      case 2:
        return _selectedRoom != null;
      case 3:
        return _checkInTime != null && _checkOutTime != null;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
        _customerResults.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      // Search for existing bookings
      final bookings = await _checkInService.searchBookingsForCheckIn(
        customerName: query,
        bookingNumber: query,
      );
      
      // Search for customers
      final customers = await _customerService.searchCustomers(query);
      
      setState(() {
        _searchResults = bookings;
        _customerResults = customers;
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

  void _selectExistingBooking(Booking booking) async {
    print('DEBUG: Selecting existing booking: ${booking.bookingNumber}');
    print('DEBUG: Customer ID: ${booking.customerId}');
    print('DEBUG: Pet ID: ${booking.petId}');
    print('DEBUG: Booking room ID: ${booking.roomId}');
    
    setState(() {
      _selectedBooking = booking;
      _checkInTime = booking.checkInDate;
      _checkOutTime = booking.checkOutDate;
      // Clear any previously selected room to avoid conflicts
      _selectedRoom = null;
    });
    
    // Get customer information from the booking
    try {
      final customer = await _customerService.getCustomerById(booking.customerId);
      if (customer != null) {
        print('DEBUG: Found customer: ${customer.fullName}');
        setState(() {
          _selectedCustomer = customer;
        });
      } else {
        print('DEBUG: Customer not found, creating minimal customer');
        // If we can't get the customer, create a minimal customer object from booking data
        setState(() {
          _selectedCustomer = Customer(
            id: booking.customerId,
            customerCode: 'BK-${booking.bookingNumber}',
            firstName: booking.customerName.split(' ').first,
            lastName: booking.customerName.split(' ').length > 1 
                ? booking.customerName.split(' ').skip(1).join(' ') 
                : '',
            email: 'N/A',
            phoneNumber: 'N/A',
            status: CustomerStatus.active,
            source: CustomerSource.other,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        });
      }
    } catch (e) {
      print('DEBUG: Error getting customer: $e');
      // If we can't get the customer, create a minimal customer object from booking data
      setState(() {
        _selectedCustomer = Customer(
          id: booking.customerId,
          customerCode: 'BK-${booking.bookingNumber}',
          firstName: booking.customerName.split(' ').first,
          lastName: booking.customerName.split(' ').length > 1 
              ? booking.customerName.split(' ').skip(1).join(' ') 
              : '',
          email: 'N/A',
          phoneNumber: 'N/A',
          status: CustomerStatus.active,
          source: CustomerSource.other,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });
    }
    
    // Get pet information from the booking
    try {
      final pet = await _petService.getPetById(booking.petId);
      if (pet != null) {
        print('DEBUG: Found pet: ${pet.name}');
        setState(() {
          _selectedPet = pet;
        });
      } else {
        print('DEBUG: Pet not found, creating minimal pet');
        // If we can't get the pet, create a minimal pet object from booking data
        setState(() {
          _selectedPet = Pet(
            id: booking.petId,
            customerId: booking.customerId,
            customerName: booking.customerName,
            name: booking.petName,
            type: PetType.cat, // Default to cat, could be enhanced
            gender: PetGender.unknown,
            size: PetSize.medium, // Default to medium
            dateOfBirth: DateTime.now().subtract(const Duration(days: 365)), // Default to 1 year old
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        });
      }
    } catch (e) {
      print('DEBUG: Error getting pet: $e');
      // If we can't get the pet, create a minimal pet object from booking data
      setState(() {
        _selectedPet = Pet(
          id: booking.petId,
          customerId: booking.customerId,
          customerName: booking.customerName,
          name: booking.petName,
          type: PetType.cat, // Default to cat, could be enhanced
          gender: PetGender.unknown,
          size: PetSize.medium, // Default to medium
          dateOfBirth: DateTime.now().subtract(const Duration(days: 365)), // Default to 1 year old
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });
    }
    
    print('DEBUG: Final state - Customer: ${_selectedCustomer?.fullName}, Pet: ${_selectedPet?.name}');
    _nextStep();
  }

  void _selectCustomer(Customer customer) {
    setState(() {
      _selectedCustomer = customer;
      _selectedBooking = null;
      _selectedPet = null;
    });
    _nextStep();
  }

  void _selectPet(Pet pet) {
    setState(() {
      _selectedPet = pet;
    });
  }

  void _selectRoom(Room room) {
    print('DEBUG: Room selected: ${room.id} (${room.roomNumber})');
    setState(() {
      _selectedRoom = room;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getBookingStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.checkedIn:
        return 'Checked In';
      case BookingStatus.completed:
        return 'Completed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.noShow:
        return 'No Show';
      default:
        return 'Unknown';
    }
  }

  IconData _getPetTypeIcon(PetType type) {
    switch (type) {
      case PetType.cat:
        return Icons.pets;
      case PetType.dog:
        return Icons.pets;
      case PetType.bird:
        return Icons.flutter_dash;
      case PetType.rabbit:
        return Icons.pets;
      case PetType.hamster:
        return Icons.pets;
      case PetType.guineaPig:
        return Icons.pets;
      case PetType.ferret:
        return Icons.pets;
      case PetType.other:
        return Icons.pets;
    }
  }

  Future<void> _completeCheckIn() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      // Create check-in request
      final request = CheckInRequest(
        id: _uuid.v4(),
        type: _selectedBooking != null ? CheckInType.existingBooking : CheckInType.walkIn,
        currentStep: CheckInStep.completion,
        createdAt: DateTime.now(),
        customerId: _selectedCustomer?.id ?? _selectedBooking?.customerId ?? '',
        customerName: _selectedCustomer?.fullName ?? _selectedBooking?.customerName ?? '',
        petId: _selectedPet?.id ?? _selectedBooking?.petId ?? '',
        petName: _selectedPet?.name ?? _selectedBooking?.petName ?? '',
        assignedRoomId: _selectedRoom?.id,
        actualCheckInTime: _checkInTime,
        plannedCheckOutTime: _checkOutTime,
        specialInstructions: _specialInstructions,
        careNotes: _careNotes,
        existingBookingId: _selectedBooking?.id,
        confirmedServices: _selectedServices,
        servicePrices: _servicePrices,
      );
      
      print('DEBUG: Check-in request details:');
      print('DEBUG: - assignedRoomId: ${request.assignedRoomId}');
      print('DEBUG: - _selectedRoom: ${_selectedRoom?.id}');
      print('DEBUG: - _selectedBooking: ${_selectedBooking?.id}');

      // Perform check-in
      print('DEBUG: Sending check-in request:');
      print('DEBUG: - Customer: ${request.customerName}');
      print('DEBUG: - Pet: ${request.petName}');
      print('DEBUG: - Room: ${request.assignedRoomId}');
      print('DEBUG: - Booking: ${request.existingBookingId}');
      
      final result = await _checkInService.performCheckIn(request);
      
      if (result.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Check-in completed successfully! Room: ${result.roomNumber}'),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate back or show success screen
          Navigator.of(context).pop(result);
        }
      } else {
        print('DEBUG: Check-in failed with error: ${result.error}');
        if (result.warnings != null && result.warnings!.isNotEmpty) {
          print('DEBUG: Validation warnings: ${result.warnings}');
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Check-in failed: ${result.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during check-in: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Helper methods for today's bookings
  Future<List<Booking>> _getTodaysBookings() async {
    try {
      final allBookings = await _bookingService.getAllBookings();
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      
      return allBookings.where((booking) {
        final checkInDate = DateTime(
          booking.checkInDate.year,
          booking.checkInDate.month,
          booking.checkInDate.day,
        );
        return checkInDate.isAtSameMomentAs(todayStart) || 
               (checkInDate.isAfter(todayStart) && checkInDate.isBefore(todayEnd));
      }).toList();
    } catch (e) {
      return [];
    }
  }

  String _formatTime(BookingTimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class MockPaymentService implements PaymentService {
  @override
  Future<List<PaymentMethod>> getAllPaymentMethods() async => [];

  @override
  Future<List<PaymentMethod>> getActivePaymentMethods() async => [];

  @override
  Future<PaymentMethod?> getPaymentMethodById(String id) async => null;

  @override
  Future<List<PaymentMethod>> getPaymentMethodsByType(PaymentType type) async => [];

  @override
  Future<PaymentMethod> createPaymentMethod({
    required String name,
    required PaymentType type,
    String? description,
    String? iconPath,
    Map<String, dynamic>? configuration,
    double? processingFee,
    double? minimumAmount,
    double? maximumAmount,
    List<String>? supportedCurrencies,
    bool? requiresSignature,
    bool? requiresReceipt,
    String? notes,
  }) async {
    return PaymentMethod(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      type: type,
      isActive: true,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      description: description,
      iconPath: iconPath,
      configuration: configuration,
      processingFee: processingFee,
      minimumAmount: minimumAmount,
      maximumAmount: maximumAmount,
      supportedCurrencies: supportedCurrencies,
      requiresSignature: requiresSignature,
      requiresReceipt: requiresReceipt,
      notes: notes,
    );
  }

  @override
  Future<PaymentMethod> updatePaymentMethod(String id, Map<String, dynamic> updates) async {
    throw UnimplementedError('Mock method not implemented');
  }

  @override
  Future<void> deactivatePaymentMethod(String id) async {}

  @override
  Future<void> activatePaymentMethod(String id) async {}

  @override
  Future<void> deletePaymentMethod(String id) async {}

  @override
  Future<PaymentTransaction> processPayment({
    required String transactionId,
    required TransactionType type,
    required double amount,
    required PaymentMethod paymentMethod,
    String? customerId,
    String? customerName,
    String? orderId,
    String? invoiceId,
    String? receiptId,
    String? referenceNumber,
    String? notes,
    double? taxAmount,
    double? tipAmount,
    double? serviceChargeAmount,
    String? currency,
    String? processedBy,
  }) async {
    // Mock implementation - return a mock transaction
    return PaymentTransaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      transactionId: transactionId,
      type: type,
      amount: amount,
      paymentMethod: paymentMethod,
      status: PaymentStatus.completed,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      customerId: customerId,
      customerName: customerName,
      orderId: orderId,
      invoiceId: invoiceId,
      receiptId: receiptId,
      referenceNumber: referenceNumber,
      notes: notes,
      processingFee: 0.0,
      taxAmount: taxAmount,
      tipAmount: tipAmount,
      serviceChargeAmount: serviceChargeAmount,
      currency: currency ?? 'MYR',
      processedBy: processedBy,
    );
  }

  @override
  Future<PaymentTransaction> completePayment(String transactionId) async {
    throw UnimplementedError('Mock method not implemented');
  }

  @override
  Future<PaymentTransaction> failPayment(String transactionId, String errorMessage) async {
    throw UnimplementedError('Mock method not implemented');
  }

  @override
  Future<PaymentTransaction> cancelPayment(String transactionId, String reason) async {
    throw UnimplementedError('Mock method not implemented');
  }

  @override
  Future<PaymentTransaction> processRefund({
    required String originalTransactionId,
    required double refundAmount,
    required String reason,
    String? processedBy,
    String? notes,
  }) async {
    throw UnimplementedError('Mock method not implemented');
  }

  @override
  Future<List<PaymentTransaction>> getAllTransactions() async => [];

  @override
  Future<PaymentTransaction?> getTransactionById(String id) async => null;

  @override
  Future<List<PaymentTransaction>> getTransactionsByCustomer(String customerId) async => [];

  @override
  Future<List<PaymentTransaction>> getTransactionsByStatus(PaymentStatus status) async => [];

  @override
  Future<List<PaymentTransaction>> getTransactionsByType(TransactionType type) async => [];

  @override
  Future<List<PaymentTransaction>> getTransactionsByDateRange(DateTime startDate, DateTime endDate) async => [];

  @override
  Future<Map<String, dynamic>> getPaymentSummary(DateTime startDate, DateTime endDate) async => {};

  @override
  Future<List<PaymentTransaction>> getRecentTransactions({int limit = 10}) async => [];
}
