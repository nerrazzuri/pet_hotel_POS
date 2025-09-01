import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:cat_hotel_pos/features/booking/presentation/providers/room_providers.dart';

class CreateRoomDialog extends ConsumerStatefulWidget {
  const CreateRoomDialog({super.key});

  @override
  ConsumerState<CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends ConsumerState<CreateRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _roomNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _peakPriceController = TextEditingController();
  final _capacityController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amenitiesController = TextEditingController();
  final _specificationsController = TextEditingController();
  final _notesController = TextEditingController();
  
  RoomType _selectedType = RoomType.standard;
  RoomStatus _selectedStatus = RoomStatus.available;
  bool _isLoading = false;

  @override
  void dispose() {
    _roomNumberController.dispose();
    _nameController.dispose();
    _basePriceController.dispose();
    _peakPriceController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    _amenitiesController.dispose();
    _specificationsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final roomService = ref.read(roomServiceProvider);
      
      await roomService.createRoom(
        roomNumber: _roomNumberController.text.trim(),
        name: _nameController.text.trim(),
        type: _selectedType,
        status: _selectedStatus,
        capacity: int.parse(_capacityController.text),
        basePricePerNight: double.parse(_basePriceController.text),
        peakSeasonPrice: double.tryParse(_peakPriceController.text) ?? double.parse(_basePriceController.text),
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : 'No description',
        amenities: _amenitiesController.text.trim().isNotEmpty ? _amenitiesController.text.trim().split(',').map((e) => e.trim()).toList() : [],
        specifications: _specificationsController.text.trim().isNotEmpty ? {'description': _specificationsController.text.trim()} : {},
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Room created successfully!')),
        );
        // Refresh the rooms list
        ref.invalidate(roomsProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating room: $e')),
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
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.hotel,
                    color: Colors.green[800],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create New Room',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Add a new room to your hotel',
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
                      // Room Number and Name
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _roomNumberController,
                              decoration: InputDecoration(
                                labelText: 'Room Number *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.tag),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Room number is required';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: 'Room Name *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.hotel),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Room name is required';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Room Type and Status
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<RoomType>(
                              value: _selectedType,
                              decoration: InputDecoration(
                                labelText: 'Room Type *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.category),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              items: RoomType.values.map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.displayName),
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<RoomStatus>(
                              value: _selectedStatus,
                              decoration: InputDecoration(
                                labelText: 'Room Status *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.info),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                                                             items: RoomStatus.values.map((status) => DropdownMenuItem(
                                 value: status,
                                 child: Text(status.name.toUpperCase()),
                               )).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedStatus = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Capacity and Base Price
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _capacityController,
                              decoration: InputDecoration(
                                labelText: 'Capacity (Pets) *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.pets),
                                filled: true,
                                fillColor: Colors.grey[50],
                                hintText: '1',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Capacity is required';
                                }
                                final capacity = int.tryParse(value);
                                if (capacity == null || capacity <= 0) {
                                  return 'Capacity must be a positive number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _basePriceController,
                              decoration: InputDecoration(
                                labelText: 'Base Price per Night (MYR) *',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                prefixIcon: const Icon(Icons.attach_money),
                                filled: true,
                                fillColor: Colors.grey[50],
                                hintText: '0.00',
                              ),
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Base price is required';
                                }
                                final price = double.tryParse(value);
                                if (price == null || price < 0) {
                                  return 'Price must be a valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Peak Season Price
                      TextFormField(
                        controller: _peakPriceController,
                        decoration: InputDecoration(
                          labelText: 'Peak Season Price (MYR)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.trending_up),
                          filled: true,
                          fillColor: Colors.grey[50],
                          hintText: 'Leave empty to use base price',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        onChanged: (value) {
                          if (value.isEmpty && _basePriceController.text.isNotEmpty) {
                            setState(() {
                              _peakPriceController.text = _basePriceController.text;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.description),
                          filled: true,
                          fillColor: Colors.grey[50],
                          hintText: 'Brief description of the room...',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Amenities
                      TextFormField(
                        controller: _amenitiesController,
                        decoration: InputDecoration(
                          labelText: 'Amenities',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.list),
                          filled: true,
                          fillColor: Colors.grey[50],
                          hintText: 'Comma-separated amenities (e.g., AC, WiFi, TV)',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Specifications
                      TextFormField(
                        controller: _specificationsController,
                        decoration: InputDecoration(
                          labelText: 'Specifications',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                                                           prefixIcon: const Icon(Icons.settings),
                          filled: true,
                          fillColor: Colors.grey[50],
                          hintText: 'Room specifications and features...',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.note),
                          filled: true,
                          fillColor: Colors.grey[50],
                          hintText: 'Additional notes about the room...',
                        ),
                        maxLines: 2,
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
                  onPressed: _isLoading ? null : _saveRoom,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
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
                      : const Text('Create Room'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
