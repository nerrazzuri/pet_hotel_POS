import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/booking.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:cat_hotel_pos/features/booking/presentation/providers/booking_providers.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/pet.dart';

class EditBookingDialog extends ConsumerStatefulWidget {
  final Booking booking;
  
  const EditBookingDialog({super.key, required this.booking});

  @override
  ConsumerState<EditBookingDialog> createState() => _EditBookingDialogState();
}

class _EditBookingDialogState extends ConsumerState<EditBookingDialog> {
  final _formKey = GlobalKey<FormState>();
  final _checkInDateController = TextEditingController();
  final _checkOutDateController = TextEditingController();
  final _checkInTimeController = TextEditingController();
  final _checkOutTimeController = TextEditingController();
  final _depositController = TextEditingController();
  final _discountController = TextEditingController();
  final _taxController = TextEditingController();
  final _specialInstructionsController = TextEditingController();
  final _careNotesController = TextEditingController();
  final _veterinaryNotesController = TextEditingController();
  
  late DateTime _checkInDate;
  late DateTime _checkOutDate;
  late TimeOfDay _checkInTime;
  late TimeOfDay _checkOutTime;
  late BookingType _selectedType;
  late double _basePricePerNight;
  bool _isLoading = false;

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
    
    // Initialize controllers with existing data
    _depositController.text = (widget.booking.depositAmount ?? 0.0).toString();
    _discountController.text = (widget.booking.discountAmount ?? 0.0).toString();
    _taxController.text = (widget.booking.taxAmount ?? 0.0).toString();
    _specialInstructionsController.text = widget.booking.specialInstructions ?? '';
    _careNotesController.text = widget.booking.careNotes ?? '';
    _veterinaryNotesController.text = widget.booking.veterinaryNotes ?? '';
    
    _updateControllers();
  }

  // Helper method to update the text controllers
  void _updateControllers() {
    _checkInDateController.text = _checkInDate.toString().split(' ')[0];
    _checkOutDateController.text = _checkOutDate.toString().split(' ')[0];
    _checkInTimeController.text = _checkInTime.format(context);
    _checkOutTimeController.text = _checkOutTime.format(context);
  }

  @override
  void dispose() {
    _checkInDateController.dispose();
    _checkOutDateController.dispose();
    _checkInTimeController.dispose();
    _checkOutTimeController.dispose();
    _depositController.dispose();
    _discountController.dispose();
    _taxController.dispose();
    _specialInstructionsController.dispose();
    _careNotesController.dispose();
    _veterinaryNotesController.dispose();
    super.dispose();
  }

  Future<void> _updateBooking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

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
        specialInstructions: _specialInstructionsController.text.isNotEmpty ? _specialInstructionsController.text : null,
        careNotes: _careNotesController.text.isNotEmpty ? _careNotesController.text : null,
        veterinaryNotes: _veterinaryNotesController.text.isNotEmpty ? _veterinaryNotesController.text : null,
        depositAmount: double.tryParse(_depositController.text) ?? 0.0,
        discountAmount: double.tryParse(_discountController.text) ?? 0.0,
        taxAmount: double.tryParse(_taxController.text) ?? 0.0,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking updated successfully!')),
        );
        // Refresh the bookings list
        ref.invalidate(bookingsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating booking: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    color: Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit,
                    color: Colors.orange[800],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Edit Booking - ${widget.booking.bookingNumber}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Update booking details and information',
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
            
            // Form
            Expanded(
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
                              decoration: InputDecoration(
                                labelText: 'Customer',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.person),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              initialValue: widget.booking.petName,
                              decoration: InputDecoration(
                                labelText: 'Pet',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.pets),
                                filled: true,
                                fillColor: Colors.grey[100],
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
                        decoration: InputDecoration(
                          labelText: 'Room',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.hotel),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),

                      // Booking Type
                      DropdownButtonFormField<BookingType>(
                        value: _selectedType,
                        decoration: InputDecoration(
                          labelText: 'Booking Type *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.category),
                          filled: true,
                          fillColor: Colors.grey[50],
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
                      const SizedBox(height: 16),

                      // Dates and Times
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: 'Check-in Date *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.calendar_today),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              controller: _checkInDateController,
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _checkInDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (date != null) {
                                  setState(() {
                                    _checkInDate = date;
                                    if (_checkOutDate.isBefore(date)) {
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
                              decoration: InputDecoration(
                                labelText: 'Check-out Date *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.calendar_today),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              controller: _checkOutDateController,
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _checkOutDate,
                                  firstDate: _checkInDate,
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
                              decoration: InputDecoration(
                                labelText: 'Check-in Time *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.access_time),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              controller: _checkInTimeController,
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _checkInTime,
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
                              decoration: InputDecoration(
                                labelText: 'Check-out Time *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.access_time),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              controller: _checkOutTimeController,
                              onTap: () async {
                                final time = await showTimePicker(
                                  context: context,
                                  initialTime: _checkOutTime,
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
                              decoration: InputDecoration(
                                labelText: 'Base Price per Night',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.attach_money),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              controller: TextEditingController(
                                text: 'MYR ${_basePricePerNight.toStringAsFixed(2)}',
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Deposit Amount',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.payment),
                                filled: true,
                                fillColor: Colors.grey[50],
                                hintText: '0.00',
                              ),
                              controller: _depositController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Discount Amount',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.discount),
                                filled: true,
                                fillColor: Colors.grey[50],
                                hintText: '0.00',
                              ),
                              controller: _discountController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Tax Amount',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.receipt),
                                filled: true,
                                fillColor: Colors.grey[50],
                                hintText: '0.00',
                              ),
                              controller: _taxController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Notes Section
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Special Instructions',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.note),
                          filled: true,
                          fillColor: Colors.grey[50],
                          hintText: 'Any special instructions for this booking...',
                        ),
                        controller: _specialInstructionsController,
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Care Notes',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.pets),
                                filled: true,
                                fillColor: Colors.grey[50],
                                hintText: 'Special care requirements...',
                              ),
                              controller: _careNotesController,
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Veterinary Notes',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.medical_services),
                                filled: true,
                                fillColor: Colors.grey[50],
                                hintText: 'Medical or veterinary notes...',
                              ),
                              controller: _veterinaryNotesController,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Update Booking'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
