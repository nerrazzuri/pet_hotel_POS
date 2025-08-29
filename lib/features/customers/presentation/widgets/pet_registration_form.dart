import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/pet.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';
import 'package:cat_hotel_pos/core/services/customer_dao.dart';

class PetRegistrationForm extends ConsumerStatefulWidget {
  final Pet? pet; // If provided, this is an edit form
  final Customer? owner; // Owner customer if adding new pet
  final Function(Pet) onSave;
  final VoidCallback onCancel;

  const PetRegistrationForm({
    super.key,
    this.pet,
    this.owner,
    required this.onSave,
    required this.onCancel,
  });

  @override
  ConsumerState<PetRegistrationForm> createState() => _PetRegistrationFormState();
}

class _PetRegistrationFormState extends ConsumerState<PetRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _colorController = TextEditingController();
  final _microchipController = TextEditingController();
  final _weightController = TextEditingController();
  final _temperamentNotesController = TextEditingController();
  final _behaviorNotesController = TextEditingController();
  final _veterinarianNameController = TextEditingController();
  final _veterinarianPhoneController = TextEditingController();
  final _notesController = TextEditingController();
  
  // Form values
  PetType _type = PetType.dog;
  PetGender _gender = PetGender.male;
  PetSize _size = PetSize.medium;
  TemperamentType _temperament = TemperamentType.friendly;
  String _weightUnit = 'kg';
  DateTime? _dateOfBirth;
  DateTime? _lastVaccinationDate;
  DateTime? _lastDewormingDate;
  DateTime? _lastFleaTreatmentDate;
  DateTime? _lastTickTreatmentDate;
  
  // Boolean values
  bool _isNeutered = false;
  bool _isSpayed = false;
  bool _isVaccinated = false;
  bool _isDewormed = false;
  bool _isFleaTreated = false;
  bool _isTickTreated = false;
  bool _isActive = true;
  
  // Lists
  final List<String> _allergies = [];
  final List<String> _medications = [];
  final List<String> _specialNeeds = [];
  
  // Customer selection
  Customer? _selectedOwner;
  final List<Customer> _availableCustomers = [];
  
  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadCustomers();
  }
  
  void _initializeForm() {
    if (widget.pet != null) {
      // Edit mode - populate with existing data
      final pet = widget.pet!;
      _nameController.text = pet.name;
      _breedController.text = pet.breed ?? '';
      _colorController.text = pet.color ?? '';
      _microchipController.text = pet.microchipNumber ?? '';
      _weightController.text = pet.weight?.toString() ?? '';
      _temperamentNotesController.text = pet.temperamentNotes ?? '';
      _behaviorNotesController.text = pet.behaviorNotes ?? '';
      _veterinarianNameController.text = pet.veterinarianName ?? '';
      _veterinarianPhoneController.text = pet.veterinarianPhone ?? '';
      _notesController.text = pet.notes ?? '';
      
      _type = pet.type;
      _gender = pet.gender;
      _size = pet.size;
      _temperament = pet.temperament ?? TemperamentType.friendly;
      _weightUnit = pet.weightUnit ?? 'kg';
      _dateOfBirth = pet.dateOfBirth;
      _isNeutered = pet.isNeutered ?? false;
      _isSpayed = pet.isSpayed ?? false;
      _isVaccinated = pet.isVaccinated ?? false;
      _isDewormed = pet.isDewormed ?? false;
      _isFleaTreated = pet.isFleaTreated ?? false;
      _isTickTreated = pet.isTickTreated ?? false;
      _isActive = pet.isActive ?? true;
      
      // Initialize lists
      if (pet.allergies != null) _allergies.addAll(pet.allergies!);
      if (pet.medications != null) _medications.addAll(pet.medications!);
      if (pet.specialNeeds != null) _specialNeeds.addAll(pet.specialNeeds!);
      
      // Set owner
      _selectedOwner = _availableCustomers.firstWhere(
        (c) => c.id == pet.customerId,
        orElse: () => _availableCustomers.first,
      );
    } else if (widget.owner != null) {
      // Add mode with specific owner
      _selectedOwner = widget.owner;
    }
  }
  
  Future<void> _loadCustomers() async {
    final customerDao = CustomerDao();
    final customers = await customerDao.getAll();
    setState(() {
      _availableCustomers.addAll(customers);
      if (_selectedOwner == null && customers.isNotEmpty) {
        _selectedOwner = customers.first;
      }
    });
  }
  
  void _addAllergy() {
    _showAddItemDialog('Add Allergy', _allergies);
  }
  
  void _removeAllergy(int index) {
    setState(() {
      _allergies.removeAt(index);
    });
  }
  
  void _addMedication() {
    _showAddItemDialog('Add Medication', _medications);
  }
  
  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }
  
  void _addSpecialNeed() {
    _showAddItemDialog('Add Special Need', _specialNeeds);
  }
  
  void _removeSpecialNeed(int index) {
    setState(() {
      _specialNeeds.removeAt(index);
    });
  }
  
  void _showAddItemDialog(String title, List<String> list) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Enter ${title.toLowerCase()}',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  list.add(controller.text.trim());
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _colorController.dispose();
    _microchipController.dispose();
    _weightController.dispose();
    _temperamentNotesController.dispose();
    _behaviorNotesController.dispose();
    _veterinarianNameController.dispose();
    _veterinarianPhoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(DateTime? initialDate, Function(DateTime) onDateSelected) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      onDateSelected(picked);
    }
  }
  
  void _saveForm() {
    if (_formKey.currentState!.validate() && _selectedOwner != null) {
      // Calculate age from date of birth
      int? age;
      if (_dateOfBirth != null) {
        final now = DateTime.now();
        age = now.year - _dateOfBirth!.year;
        if (now.month < _dateOfBirth!.month || 
            (now.month == _dateOfBirth!.month && now.day < _dateOfBirth!.day)) {
          age--;
        }
      }
      
      // Create or update pet
      final pet = Pet(
        id: widget.pet?.id ?? 'pet_${DateTime.now().millisecondsSinceEpoch}',
        customerId: _selectedOwner!.id,
        customerName: _selectedOwner!.fullName,
        name: _nameController.text.trim(),
        type: _type,
        gender: _gender,
        size: _size,
        dateOfBirth: _dateOfBirth,
        createdAt: widget.pet?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        breed: _breedController.text.trim().isNotEmpty ? _breedController.text.trim() : null,
        color: _colorController.text.trim().isNotEmpty ? _colorController.text.trim() : null,
        weight: _weightController.text.trim().isNotEmpty ? double.tryParse(_weightController.text.trim()) : null,
        weightUnit: _weightUnit,
        microchipNumber: _microchipController.text.trim().isNotEmpty ? _microchipController.text.trim() : null,
        isNeutered: _isNeutered,
        isSpayed: _isSpayed,
        isVaccinated: _isVaccinated,
        isDewormed: _isDewormed,
        isFleaTreated: _isFleaTreated,
        isTickTreated: _isTickTreated,
        temperament: _temperament,
        temperamentNotes: _temperamentNotesController.text.trim().isNotEmpty ? _temperamentNotesController.text.trim() : null,
        allergies: _allergies.isNotEmpty ? _allergies : null,
        medications: _medications.isNotEmpty ? _medications : null,
        specialNeeds: _specialNeeds.isNotEmpty ? _specialNeeds : null,
        behaviorNotes: _behaviorNotesController.text.trim().isNotEmpty ? _behaviorNotesController.text.trim() : null,
        veterinarianName: _veterinarianNameController.text.trim().isNotEmpty ? _veterinarianNameController.text.trim() : null,
        veterinarianPhone: _veterinarianPhoneController.text.trim().isNotEmpty ? _veterinarianPhoneController.text.trim() : null,
        isActive: _isActive,
      );
      
      widget.onSave(pet);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditMode = widget.pet != null;
    
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  isEditMode ? Icons.edit : Icons.pets,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  isEditMode ? 'Edit Pet' : 'New Pet Registration',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Owner Selection Section
            _buildSectionHeader(theme, 'Pet Owner', Icons.person),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<Customer>(
              decoration: const InputDecoration(
                labelText: 'Owner *',
                border: OutlineInputBorder(),
              ),
              value: _selectedOwner,
              items: _availableCustomers.map((customer) => DropdownMenuItem(
                value: customer,
                child: Text('${customer.firstName} ${customer.lastName}'),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedOwner = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select an owner';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Basic Information Section
            _buildSectionHeader(theme, 'Basic Information', Icons.pets),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Pet Name *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Pet name is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<PetType>(
                    decoration: const InputDecoration(
                      labelText: 'Pet Type *',
                      border: OutlineInputBorder(),
                    ),
                    value: _type,
                    items: PetType.values.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _type = value;
                        });
                      }
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
                    controller: _breedController,
                    decoration: const InputDecoration(
                      labelText: 'Breed',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _colorController,
                    decoration: const InputDecoration(
                      labelText: 'Color',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<PetGender>(
                    decoration: const InputDecoration(
                      labelText: 'Gender *',
                      border: OutlineInputBorder(),
                    ),
                    value: _gender,
                    items: PetGender.values.map((gender) => DropdownMenuItem(
                      value: gender,
                      child: Text(gender.displayName),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _gender = value;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<PetSize>(
                    decoration: const InputDecoration(
                      labelText: 'Size *',
                      border: OutlineInputBorder(),
                    ),
                    value: _size,
                    items: PetSize.values.map((size) => DropdownMenuItem(
                      value: size,
                      child: Text(size.name),
                    )).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _size = value;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(_dateOfBirth, (date) {
                      setState(() {
                        _dateOfBirth = date;
                      });
                    }),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _dateOfBirth != null
                            ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                            : 'Select date',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          decoration: const InputDecoration(
                            labelText: 'Weight',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Unit',
                          border: OutlineInputBorder(),
                        ),
                        value: _weightUnit,
                        items: ['kg', 'lbs'].map((unit) => DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        )).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _weightUnit = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Medical Information Section
            _buildSectionHeader(theme, 'Medical Information', Icons.medical_services),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Neutered'),
                    value: _isNeutered,
                    onChanged: (value) {
                      setState(() {
                        _isNeutered = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Spayed'),
                    value: _isSpayed,
                    onChanged: (value) {
                      setState(() {
                        _isSpayed = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ],
            ),
            
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Vaccinated'),
                    value: _isVaccinated,
                    onChanged: (value) {
                      setState(() {
                        _isVaccinated = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Dewormed'),
                    value: _isDewormed,
                    onChanged: (value) {
                      setState(() {
                        _isDewormed = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ],
            ),
            
            Row(
              children: [
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Flea Treated'),
                    value: _isFleaTreated,
                    onChanged: (value) {
                      setState(() {
                        _isFleaTreated = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Tick Treated'),
                    value: _isTickTreated,
                    onChanged: (value) {
                      setState(() {
                        _isTickTreated = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(_lastVaccinationDate, (date) {
                      setState(() {
                        _lastVaccinationDate = date;
                      });
                    }),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Last Vaccination',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _lastVaccinationDate != null
                            ? '${_lastVaccinationDate!.day}/${_lastVaccinationDate!.month}/${_lastVaccinationDate!.year}'
                            : 'Select date',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(_lastDewormingDate, (date) {
                      setState(() {
                        _lastDewormingDate = date;
                      });
                    }),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Last Deworming',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _lastDewormingDate != null
                            ? '${_lastDewormingDate!.day}/${_lastDewormingDate!.month}/${_lastDewormingDate!.year}'
                            : 'Select date',
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Behavioral Information Section
            _buildSectionHeader(theme, 'Behavioral Information', Icons.psychology),
            const SizedBox(height: 16),
            
            DropdownButtonFormField<TemperamentType>(
              decoration: const InputDecoration(
                labelText: 'Temperament',
                border: OutlineInputBorder(),
              ),
              value: _temperament,
              items: TemperamentType.values.map((temperament) => DropdownMenuItem(
                value: temperament,
                child: Text(temperament.name),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _temperament = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _temperamentNotesController,
              decoration: const InputDecoration(
                labelText: 'Temperament Notes',
                border: OutlineInputBorder(),
                hintText: 'Additional details about temperament...',
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _behaviorNotesController,
              decoration: const InputDecoration(
                labelText: 'Behavior Notes',
                border: OutlineInputBorder(),
                hintText: 'Any special behaviors or training notes...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            
            // Health & Special Needs Section
            _buildSectionHeader(theme, 'Health & Special Needs', Icons.health_and_safety),
            const SizedBox(height: 16),
            
            // Allergies
            _buildListSection(
              theme,
              'Allergies',
              _allergies,
              _addAllergy,
              _removeAllergy,
              Icons.warning,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            
            // Medications
            _buildListSection(
              theme,
              'Current Medications',
              _medications,
              _addMedication,
              _removeMedication,
              Icons.medication,
              Colors.blue,
            ),
            const SizedBox(height: 16),
            
            // Special Needs
            _buildListSection(
              theme,
              'Special Needs',
              _specialNeeds,
              _addSpecialNeed,
              _removeSpecialNeed,
              Icons.accessibility,
              Colors.purple,
            ),
            const SizedBox(height: 24),
            
            // Veterinarian Information Section
            _buildSectionHeader(theme, 'Veterinarian Information', Icons.local_hospital),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _veterinarianNameController,
                    decoration: const InputDecoration(
                      labelText: 'Veterinarian Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _veterinarianPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Veterinarian Phone',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _microchipController,
              decoration: const InputDecoration(
                labelText: 'Microchip Number',
                border: OutlineInputBorder(),
                hintText: 'If applicable...',
              ),
            ),
            const SizedBox(height: 24),
            
            // Additional Information Section
            _buildSectionHeader(theme, 'Additional Information', Icons.note),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'General Notes',
                border: OutlineInputBorder(),
                hintText: 'Any additional information about the pet...',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            
            CheckboxListTile(
              title: const Text('Active Pet'),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value ?? true;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
            ),
            const SizedBox(height: 32),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _saveForm,
                  child: Text(isEditMode ? 'Update Pet' : 'Create Pet'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(ThemeData theme, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildListSection(
    ThemeData theme,
    String title,
    List<String> items,
    VoidCallback onAdd,
    Function(int) onRemove,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add, size: 16),
                label: Text('Add $title'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: BorderSide(color: color),
                ),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 4),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(item)),
                    IconButton(
                      onPressed: () => onRemove(index),
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 18),
                      tooltip: 'Remove',
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}
