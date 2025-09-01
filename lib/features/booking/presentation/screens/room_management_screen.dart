import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/booking/domain/entities/room.dart';
import 'package:cat_hotel_pos/features/booking/presentation/providers/room_providers.dart';
import 'package:cat_hotel_pos/features/booking/presentation/widgets/create_room_dialog.dart';
import 'package:cat_hotel_pos/features/booking/presentation/widgets/edit_room_dialog.dart';
import 'package:cat_hotel_pos/features/booking/presentation/widgets/room_details_dialog.dart';
import 'package:uuid/uuid.dart';

class RoomManagementScreen extends ConsumerStatefulWidget {
  const RoomManagementScreen({super.key});

  @override
  ConsumerState<RoomManagementScreen> createState() => _RoomManagementScreenState();
}

class _RoomManagementScreenState extends ConsumerState<RoomManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Seed default rooms if none exist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _seedDefaultRoomsIfNeeded();
    });
  }

  Future<void> _seedDefaultRoomsIfNeeded() async {
    final rooms = await ref.read(roomsProvider.future);
    if (rooms.isEmpty) {
      final roomService = ref.read(roomServiceProvider);
      await roomService.seedDefaultRooms();
      ref.invalidate(roomsProvider);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Room Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateRoomDialog(context),
            tooltip: 'Add New Room',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(roomsProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: roomsAsync.when(
        data: (rooms) {
          if (rooms.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.hotel_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No rooms found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add your first room to get started',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
                             return _RoomCard(
                 room: room,
                 onEdit: () => _showEditRoomDialog(context, room),
                 onDelete: () => _showDeleteRoomDialog(context, room),
                 onView: () => _showRoomDetailsDialog(context, room),
                 onStatusChange: (room) => _showStatusChangeDialog(context, room),
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
                'Error loading rooms',
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
      ),
    );
  }

  void _showCreateRoomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const CreateRoomDialog(),
    );
  }

  void _showEditRoomDialog(BuildContext context, Room room) {
    showDialog(
      context: context,
      builder: (context) => EditRoomDialog(room: room),
    );
  }

  void _showDeleteRoomDialog(BuildContext context, Room room) {
    showDialog(
      context: context,
      builder: (context) => _DeleteRoomDialog(room: room),
    );
  }

  void _showRoomDetailsDialog(BuildContext context, Room room) {
    showDialog(
      context: context,
      builder: (context) => RoomDetailsDialog(room: room),
    );
  }

  void _showStatusChangeDialog(BuildContext context, Room room) {
    showDialog(
      context: context,
      builder: (context) => _StatusChangeDialog(room: room),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final Room room;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onView;
  final Function(Room) onStatusChange;

  const _RoomCard({
    required this.room,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
    required this.onStatusChange,
  });

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

  Color _getTypeColor(RoomType type) {
    switch (type) {
      case RoomType.standard:
        return Colors.blue;
      case RoomType.deluxe:
        return Colors.purple;
      case RoomType.vip:
        return Colors.amber;
      case RoomType.isolation:
        return Colors.red;
      case RoomType.medical:
        return Colors.teal;
      case RoomType.family:
        return Colors.green;
      case RoomType.outdoor:
        return Colors.brown;
      case RoomType.playroom:
        return Colors.pink;
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
                            room.roomNumber,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(room.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              room.status.name.toUpperCase(),
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
                        room.name,
                        style: Theme.of(context).textTheme.titleMedium,
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
                       case 'delete':
                         onDelete();
                         break;
                       case 'status':
                         onStatusChange(room);
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
                     const PopupMenuItem(
                       value: 'status',
                       child: Row(
                         children: [
                           Icon(Icons.update),
                           SizedBox(width: 8),
                           Text('Change Status'),
                         ],
                       ),
                     ),
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
            
            // Room Details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        icon: Icons.category,
                        label: 'Type',
                        value: room.type.name.toUpperCase(),
                        valueColor: _getTypeColor(room.type),
                      ),
                      _DetailRow(
                        icon: Icons.people,
                        label: 'Capacity',
                        value: '${room.capacity} pet${room.capacity > 1 ? 's' : ''}',
                      ),
                      _DetailRow(
                        icon: Icons.attach_money,
                        label: 'Base Price',
                        value: '\$${room.basePricePerNight.toStringAsFixed(2)}/night',
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        icon: Icons.description,
                        label: 'Description',
                        value: room.description,
                        maxLines: 2,
                      ),
                      if (room.currentOccupantName != null)
                        _DetailRow(
                          icon: Icons.pets,
                          label: 'Current Pet',
                          value: room.currentOccupantName!,
                          valueColor: Colors.orange,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Amenities
            if (room.amenities.isNotEmpty) ...[
              Text(
                'Amenities:',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: room.amenities.map((amenity) => Chip(
                  label: Text(amenity),
                  backgroundColor: Colors.blue[50],
                  labelStyle: TextStyle(color: Colors.blue[700]),
                )).toList(),
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
  final Color? valueColor;
  final int? maxLines;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.maxLines,
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
              style: TextStyle(
                color: valueColor ?? Colors.black87,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              maxLines: maxLines,
              overflow: maxLines != null ? TextOverflow.ellipsis : null,
            ),
          ),
        ],
      ),
    );
  }
}

// Placeholder dialogs - these will be implemented in the next iteration
class _CreateRoomDialog extends ConsumerStatefulWidget {
  const _CreateRoomDialog();

  @override
  ConsumerState<_CreateRoomDialog> createState() => _CreateRoomDialogState();
}

class _CreateRoomDialogState extends ConsumerState<_CreateRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _roomNumberController = TextEditingController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _peakPriceController = TextEditingController();
  final _capacityController = TextEditingController();
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
    _descriptionController.dispose();
    _basePriceController.dispose();
    _peakPriceController.dispose();
    _capacityController.dispose();
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
      
      // Parse amenities from comma-separated string
      final amenities = _amenitiesController.text.isNotEmpty 
          ? _amenitiesController.text.split(',').map((e) => e.trim()).toList()
          : <String>[];

      // Parse specifications from comma-separated string
      final specifications = _specificationsController.text.isNotEmpty
          ? _specificationsController.text.split(',').map((e) => e.trim()).toList().asMap().map((index, value) => MapEntry('spec_$index', value))
          : <String, dynamic>{};

      await roomService.createRoom(
        roomNumber: _roomNumberController.text.trim(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : '',
        type: _selectedType,
        status: _selectedStatus,
        basePricePerNight: double.parse(_basePriceController.text),
        peakSeasonPrice: double.parse(_peakPriceController.text),
        capacity: int.parse(_capacityController.text),
        amenities: amenities,
        specifications: specifications,
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
    return AlertDialog(
      title: const Text('Create New Room'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Room Number
                TextFormField(
                  controller: _roomNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Room Number *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.tag),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Room number is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Room Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Room Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.hotel),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Room name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Room Type
                DropdownButtonFormField<RoomType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Room Type *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: RoomType.values.map((type) => DropdownMenuItem(
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

                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Pricing
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _basePriceController,
                        decoration: const InputDecoration(
                          labelText: 'Base Price per Night *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Base price is required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _peakPriceController,
                        decoration: const InputDecoration(
                          labelText: 'Peak Season Price *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.trending_up),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Peak price is required';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Capacity
                TextFormField(
                  controller: _capacityController,
                  decoration: const InputDecoration(
                    labelText: 'Capacity (Number of Pets) *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.pets),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Capacity is required';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // TODO: Fix amenities and specifications access
                // Amenities
                TextFormField(
                  controller: _amenitiesController,
                  decoration: const InputDecoration(
                    labelText: 'Amenities (comma-separated)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.room),
                    hintText: 'e.g., Window, Scratching post, Toys',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Specifications
                TextFormField(
                  controller: _specificationsController,
                  decoration: const InputDecoration(
                    labelText: 'Specifications (comma-separated)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.info),
                    hintText: 'e.g., 2m x 2m, 1.5m height',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
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
          onPressed: _isLoading ? null : _saveRoom,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Create Room'),
        ),
      ],
    );
  }
}

class _EditRoomDialog extends ConsumerStatefulWidget {
  final Room room;
  
  const _EditRoomDialog({required this.room});

  @override
  ConsumerState<_EditRoomDialog> createState() => _EditRoomDialogState();
}

class _EditRoomDialogState extends ConsumerState<_EditRoomDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _roomNumberController;
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _basePriceController;
  late final TextEditingController _peakPriceController;
  late final TextEditingController _capacityController;
  late final TextEditingController _amenitiesController;
  late final TextEditingController _specificationsController;
  late final TextEditingController _notesController;
  
  late RoomType _selectedType;
  late RoomStatus _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _roomNumberController = TextEditingController(text: widget.room.roomNumber);
    _nameController = TextEditingController(text: widget.room.name);
    _descriptionController = TextEditingController(text: widget.room.description);
    _basePriceController = TextEditingController(text: widget.room.basePricePerNight.toString());
    _peakPriceController = TextEditingController(text: widget.room.peakSeasonPrice.toString());
    _capacityController = TextEditingController(text: widget.room.capacity.toString());
    _amenitiesController = TextEditingController(text: widget.room.amenities.join(', '));
    _specificationsController = TextEditingController(text: _formatSpecifications(widget.room.specifications));
    _notesController = TextEditingController(text: widget.room.notes ?? '');
    _selectedType = widget.room.type;
    _selectedStatus = widget.room.status;
  }

  String _formatSpecifications(Map<String, dynamic> specifications) {
    if (specifications.isEmpty) return '';
    return specifications.entries
        .map((e) => e.value == true ? e.key : '${e.key}: ${e.value}')
        .join(', ');
  }

  @override
  void dispose() {
    _roomNumberController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _basePriceController.dispose();
    _peakPriceController.dispose();
    _capacityController.dispose();
    _amenitiesController.dispose();
    _specificationsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Room ${widget.room.roomNumber}'),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Room Number
                TextFormField(
                  controller: _roomNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Room Number *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.tag),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Room number is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Room Name
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Room Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.hotel),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Room name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Room Type
                DropdownButtonFormField<RoomType>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Room Type *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: RoomType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                
                // Room Status
                DropdownButtonFormField<RoomStatus>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Room Status *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.info),
                  ),
                  items: RoomStatus.values.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedStatus = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                // Capacity
                TextFormField(
                  controller: _capacityController,
                  decoration: const InputDecoration(
                    labelText: 'Capacity *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people),
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
                const SizedBox(height: 16),
                
                // Base Price
                TextFormField(
                  controller: _basePriceController,
                  decoration: const InputDecoration(
                    labelText: 'Base Price per Night *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Base price is required';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price < 0) {
                      return 'Price must be a positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Peak Season Price
                TextFormField(
                  controller: _peakPriceController,
                  decoration: const InputDecoration(
                    labelText: 'Peak Season Price *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.trending_up),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Peak season price is required';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price < 0) {
                      return 'Price must be a positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Description
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Description is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Amenities
                TextFormField(
                  controller: _amenitiesController,
                  decoration: const InputDecoration(
                    labelText: 'Amenities',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.room_service),
                    hintText: 'Separate with commas (e.g., WiFi, TV, AC)',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                // Specifications
                TextFormField(
                  controller: _specificationsController,
                  decoration: const InputDecoration(
                    labelText: 'Specifications',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.info),
                    hintText: 'Room dimensions, features, etc.',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notes',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 2,
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
          onPressed: _isLoading ? null : _updateRoom,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update Room'),
        ),
      ],
    );
  }

  Future<void> _updateRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final amenities = _amenitiesController.text.isNotEmpty
          ? _amenitiesController.text.split(',').map((e) => e.trim()).toList()
          : <String>[];
      
      final specifications = <String, dynamic>{};
      if (_specificationsController.text.isNotEmpty) {
        final specs = _specificationsController.text.split(',').map((e) => e.trim()).toList();
        for (final spec in specs) {
          if (spec.contains(':')) {
            final parts = spec.split(':');
            if (parts.length == 2) {
              specifications[parts[0].trim()] = parts[1].trim();
            }
          } else {
            specifications[spec] = true;
          }
        }
      }

      final updatedRoom = widget.room.copyWith(
        roomNumber: _roomNumberController.text.trim(),
        name: _nameController.text.trim(),
        type: _selectedType,
        status: _selectedStatus,
        capacity: int.parse(_capacityController.text),
        basePricePerNight: double.parse(_basePriceController.text),
        peakSeasonPrice: double.parse(_peakPriceController.text),
        description: _descriptionController.text.trim(),
        amenities: amenities,
        specifications: specifications,
        updatedAt: DateTime.now(),
        notes: _notesController.text.isNotEmpty ? _notesController.text.trim() : null,
      );

      final roomService = ref.read(roomServiceProvider);
      await roomService.updateRoom(
        roomId: updatedRoom.id,
        roomNumber: updatedRoom.roomNumber,
        name: updatedRoom.name,
        type: updatedRoom.type,
        status: updatedRoom.status,
        capacity: updatedRoom.capacity,
        basePricePerNight: updatedRoom.basePricePerNight,
        peakSeasonPrice: updatedRoom.peakSeasonPrice,
        description: updatedRoom.description,
        amenities: updatedRoom.amenities,
        specifications: updatedRoom.specifications,
        notes: updatedRoom.notes,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Room ${updatedRoom.name} updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating room: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

class _DeleteRoomDialog extends ConsumerStatefulWidget {
  final Room room;
  
  const _DeleteRoomDialog({required this.room});

  @override
  ConsumerState<_DeleteRoomDialog> createState() => _DeleteRoomDialogState();
}

class _DeleteRoomDialogState extends ConsumerState<_DeleteRoomDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete Room ${widget.room.roomNumber}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Are you sure you want to delete ${widget.room.name}?'),
          const SizedBox(height: 16),
          if (widget.room.status == RoomStatus.occupied)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                border: Border.all(color: Colors.orange.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This room is currently occupied. Deleting it may affect active bookings.',
                      style: TextStyle(color: Colors.orange.shade700),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _deleteRoom(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  Future<void> _deleteRoom(BuildContext context) async {
    try {
      final roomService = ref.read(roomServiceProvider);
      await roomService.deleteRoom(widget.room.id);
      
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Room ${widget.room.name} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting room: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _RoomDetailsDialog extends StatelessWidget {
  final Room room;
  
  const _RoomDetailsDialog({required this.room});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Room ${room.roomNumber} Details'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Basic Information
              _buildDetailSection(
                'Basic Information',
                [
                  _buildDetailRow('Room Number', room.roomNumber),
                  _buildDetailRow('Name', room.name),
                  _buildDetailRow('Type', room.type.name.toUpperCase()),
                  _buildDetailRow('Status', room.status.name.toUpperCase()),
                  _buildDetailRow('Capacity', '${room.capacity} pets'),
                  _buildDetailRow('Base Price', '\$${room.basePricePerNight.toStringAsFixed(2)}/night'),
                  _buildDetailRow('Peak Price', '\$${room.peakSeasonPrice.toStringAsFixed(2)}/night'),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Description
              _buildDetailSection(
                'Description',
                [_buildDetailRow('', room.description, maxLines: 3)],
              ),
              
              const SizedBox(height: 16),
              
              // Amenities
              if (room.amenities.isNotEmpty)
                _buildDetailSection(
                  'Amenities',
                  [_buildDetailRow('', room.amenities.join(', '), maxLines: 2)],
                ),
              
              if (room.amenities.isNotEmpty) const SizedBox(height: 16),
              
              // Specifications
              if (room.specifications.isNotEmpty)
                _buildDetailSection(
                  'Specifications',
                  [_buildDetailRow('', _formatSpecificationsForDisplay(room.specifications), maxLines: 2)],
                ),
              
              if (room.specifications.isNotEmpty) const SizedBox(height: 16),
              
              // Current Status
              _buildDetailSection(
                'Current Status',
                [
                  if (room.currentOccupantName != null)
                    _buildDetailRow('Current Occupant', room.currentOccupantName!),
                  if (room.lastCleanedAt != null)
                    _buildDetailRow('Last Cleaned', _formatDateTime(room.lastCleanedAt!)),
                  if (room.nextCleaningDue != null)
                    _buildDetailRow('Next Cleaning Due', _formatDateTime(room.nextCleaningDue!)),
                  if (room.currentPrice != null)
                    _buildDetailRow('Current Price', '\$${room.currentPrice!.toStringAsFixed(2)}/night'),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Notes
              if (room.notes != null && room.notes!.isNotEmpty)
                _buildDetailSection(
                  'Notes',
                  [_buildDetailRow('', room.notes!, maxLines: 3)],
                ),
              
              if (room.notes != null && room.notes!.isNotEmpty) const SizedBox(height: 16),
              
              // Maintenance Notes
              if (room.maintenanceNotes != null && room.maintenanceNotes!.isNotEmpty)
                _buildDetailSection(
                  'Maintenance Notes',
                  [_buildDetailRow('', room.maintenanceNotes!, maxLines: 3)],
                ),
              
              const SizedBox(height: 16),
              
              // System Information
              _buildDetailSection(
                'System Information',
                [
                  _buildDetailRow('Created', _formatDateTime(room.createdAt)),
                  _buildDetailRow('Last Updated', _formatDateTime(room.updatedAt)),
                  _buildDetailRow('Active', room.isActive ? 'Yes' : 'No'),
                ],
              ),
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

  Widget _buildDetailSection(String title, List<Widget> children) {
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

  Widget _buildDetailRow(String label, String value, {int? maxLines}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
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
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
              maxLines: maxLines,
              overflow: maxLines != null ? TextOverflow.ellipsis : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatSpecificationsForDisplay(Map<String, dynamic> specifications) {
    if (specifications.isEmpty) return '';
    return specifications.entries
        .map((e) => e.value == true ? e.key : '${e.key}: ${e.value}')
        .join(', ');
  }
}

class _StatusChangeDialog extends ConsumerStatefulWidget {
  final Room room;
  
  const _StatusChangeDialog({required this.room});

  @override
  ConsumerState<_StatusChangeDialog> createState() => _StatusChangeDialogState();
}

class _StatusChangeDialogState extends ConsumerState<_StatusChangeDialog> {
  late RoomStatus _selectedStatus;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.room.status;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Change Status - ${widget.room.roomNumber}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Current Status: ${widget.room.status.name.toUpperCase()}'),
          const SizedBox(height: 16),
          DropdownButtonFormField<RoomStatus>(
            value: _selectedStatus,
            decoration: const InputDecoration(
              labelText: 'New Status *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.update),
            ),
            items: RoomStatus.values.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(status.name.toUpperCase()),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedStatus = value;
                });
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateStatus,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Update Status'),
        ),
      ],
    );
  }

  Future<void> _updateStatus() async {
    if (_selectedStatus == widget.room.status) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final roomService = ref.read(roomServiceProvider);
      await roomService.updateRoomStatus(widget.room.id, _selectedStatus);
      
      if (mounted) {
        Navigator.of(context).pop();
        ref.invalidate(roomsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Room status updated to ${_selectedStatus.name.toUpperCase()}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
