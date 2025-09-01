import 'package:flutter/material.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/pet.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';
import 'package:cat_hotel_pos/core/services/customer_dao.dart';

class EditPetDialog extends StatefulWidget {
  final Pet pet;
  final Function(Pet) onUpdate;

  const EditPetDialog({
    super.key,
    required this.pet,
    required this.onUpdate,
  });

  @override
  State<EditPetDialog> createState() => _EditPetDialogState();
}

class _EditPetDialogState extends State<EditPetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _colorController = TextEditingController();
  final _weightController = TextEditingController();
  final _microchipController = TextEditingController();
  final _temperamentNotesController = TextEditingController();
  final _behaviorNotesController = TextEditingController();
  final _veterinarianNameController = TextEditingController();
  final _veterinarianPhoneController = TextEditingController();
  
  PetType _selectedType = PetType.cat;
  PetGender _selectedGender = PetGender.male;
  PetSize _selectedSize = PetSize.small;
  TemperamentType _selectedTemperament = TemperamentType.friendly;
  String _selectedWeightUnit = 'kg';
  
  DateTime? _selectedDateOfBirth;
  bool _isNeutered = false;
  bool _isSpayed = false;
  bool _isVaccinated = false;
  bool _isDewormed = false;
  bool _isFleaTreated = false;
  bool _isTickTreated = false;
  bool _isActive = true;
  bool _isLoading = false;

  List<String> _allergies = [];
  List<String> _medications = [];
  List<String> _specialNeeds = [];

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _nameController.text = widget.pet.name;
    _breedController.text = widget.pet.breed ?? '';
    _colorController.text = widget.pet.color ?? '';
    _weightController.text = widget.pet.weight?.toString() ?? '';
    _microchipController.text = widget.pet.microchipNumber ?? '';
    _temperamentNotesController.text = widget.pet.temperamentNotes ?? '';
    _behaviorNotesController.text = widget.pet.behaviorNotes ?? '';
    _veterinarianNameController.text = widget.pet.veterinarianName ?? '';
    _veterinarianPhoneController.text = widget.pet.veterinarianPhone ?? '';
    
    _selectedType = widget.pet.type;
    _selectedGender = widget.pet.gender;
    _selectedSize = widget.pet.size;
    _selectedTemperament = widget.pet.temperament ?? TemperamentType.friendly;
    _selectedWeightUnit = widget.pet.weightUnit ?? 'kg';
    _selectedDateOfBirth = widget.pet.dateOfBirth;
    
    _isNeutered = widget.pet.isNeutered ?? false;
    _isSpayed = widget.pet.isSpayed ?? false;
    _isVaccinated = widget.pet.isVaccinated ?? false;
    _isDewormed = widget.pet.isDewormed ?? false;
    _isFleaTreated = widget.pet.isFleaTreated ?? false;
    _isTickTreated = widget.pet.isTickTreated ?? false;
    _isActive = widget.pet.isActive ?? true;
    
    _allergies = List.from(widget.pet.allergies ?? []);
    _medications = List.from(widget.pet.medications ?? []);
    _specialNeeds = List.from(widget.pet.specialNeeds ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _colorController.dispose();
    _weightController.dispose();
    _microchipController.dispose();
    _temperamentNotesController.dispose();
    _behaviorNotesController.dispose();
    _veterinarianNameController.dispose();
    _veterinarianPhoneController.dispose();
    super.dispose();
  }

  Future<void> _updatePet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    if (_selectedDateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a date of birth')),
      );
      return;
    }

    try {
      final updatedPet = widget.pet.copyWith(
        name: _nameController.text.trim(),
        type: _selectedType,
        gender: _selectedGender,
        size: _selectedSize,
        dateOfBirth: _selectedDateOfBirth!,
        breed: _breedController.text.trim().isEmpty ? null : _breedController.text.trim(),
        color: _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
        weight: _weightController.text.trim().isEmpty ? null : double.tryParse(_weightController.text.trim()),
        weightUnit: _selectedWeightUnit,
        microchipNumber: _microchipController.text.trim().isEmpty ? null : _microchipController.text.trim(),
        isNeutered: _isNeutered,
        isSpayed: _isSpayed,
        isVaccinated: _isVaccinated,
        isDewormed: _isDewormed,
        isFleaTreated: _isFleaTreated,
        isTickTreated: _isTickTreated,
        temperament: _selectedTemperament,
        temperamentNotes: _temperamentNotesController.text.trim().isEmpty ? null : _temperamentNotesController.text.trim(),
        behaviorNotes: _behaviorNotesController.text.trim().isEmpty ? null : _behaviorNotesController.text.trim(),
        allergies: _allergies.isEmpty ? null : _allergies,
        medications: _medications.isEmpty ? null : _medications,
        specialNeeds: _specialNeeds.isEmpty ? null : _specialNeeds,
        veterinarianName: _veterinarianNameController.text.trim().isEmpty ? null : _veterinarianNameController.text.trim(),
        veterinarianPhone: _veterinarianPhoneController.text.trim().isEmpty ? null : _veterinarianPhoneController.text.trim(),
        isActive: _isActive,
        updatedAt: DateTime.now(),
      );

      await widget.onUpdate(updatedPet);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating pet: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.pets,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Edit Pet: ${widget.pet.name}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
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
                      // Basic Information Section
                      _buildSectionHeader('Basic Information'),
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
                              value: _selectedType,
                              decoration: const InputDecoration(
                                labelText: 'Type *',
                                border: OutlineInputBorder(),
                              ),
                              items: PetType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type.displayName),
                                );
                              }).toList(),
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
                      
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<PetGender>(
                              value: _selectedGender,
                              decoration: const InputDecoration(
                                labelText: 'Gender *',
                                border: OutlineInputBorder(),
                              ),
                              items: PetGender.values.map((gender) {
                                return DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender.displayName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedGender = value;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<PetSize>(
                              value: _selectedSize,
                              decoration: const InputDecoration(
                                labelText: 'Size *',
                                border: OutlineInputBorder(),
                              ),
                              items: PetSize.values.map((size) {
                                return DropdownMenuItem(
                                  value: size,
                                  child: Text(size.displayName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedSize = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Date of Birth
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _selectedDateOfBirth ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _selectedDateOfBirth = date;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date of Birth *',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _selectedDateOfBirth != null
                                ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                                : 'Select date',
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Physical Characteristics Section
                      _buildSectionHeader('Physical Characteristics'),
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
                            child: TextFormField(
                              controller: _weightController,
                              decoration: const InputDecoration(
                                labelText: 'Weight',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedWeightUnit,
                              decoration: const InputDecoration(
                                labelText: 'Unit',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'kg', child: Text('kg')),
                                DropdownMenuItem(value: 'lbs', child: Text('lbs')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedWeightUnit = value;
                                  });
                                }
                              },
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
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Health & Medical Section
                      _buildSectionHeader('Health & Medical'),
                      const SizedBox(height: 16),
                      
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _buildCheckboxTile('Neutered', _isNeutered, (value) {
                            setState(() {
                              _isNeutered = value ?? false;
                            });
                          }),
                          _buildCheckboxTile('Spayed', _isSpayed, (value) {
                            setState(() {
                              _isSpayed = value ?? false;
                            });
                          }),
                          _buildCheckboxTile('Vaccinated', _isVaccinated, (value) {
                            setState(() {
                              _isVaccinated = value ?? false;
                            });
                          }),
                          _buildCheckboxTile('Dewormed', _isDewormed, (value) {
                            setState(() {
                              _isDewormed = value ?? false;
                            });
                          }),
                          _buildCheckboxTile('Flea Treated', _isFleaTreated, (value) {
                            setState(() {
                              _isFleaTreated = value ?? false;
                            });
                          }),
                          _buildCheckboxTile('Tick Treated', _isTickTreated, (value) {
                            setState(() {
                              _isTickTreated = value ?? false;
                            });
                          }),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Behavior Section
                      _buildSectionHeader('Behavior & Temperament'),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<TemperamentType>(
                        value: _selectedTemperament,
                        decoration: const InputDecoration(
                          labelText: 'Temperament',
                          border: OutlineInputBorder(),
                        ),
                        items: TemperamentType.values.map((temperament) {
                          return DropdownMenuItem(
                            value: temperament,
                            child: Text(temperament.displayName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedTemperament = value;
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
                          hintText: 'Describe the pet\'s temperament...',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _behaviorNotesController,
                        decoration: const InputDecoration(
                          labelText: 'Behavior Notes',
                          border: OutlineInputBorder(),
                          hintText: 'Describe the pet\'s behavior...',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      
                      // Veterinarian Information Section
                      _buildSectionHeader('Veterinarian Information'),
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
                      const SizedBox(height: 24),
                      
                      // Status Section
                      _buildSectionHeader('Status'),
                      const SizedBox(height: 16),
                      
                      SwitchListTile(
                        title: const Text('Active'),
                        subtitle: const Text('Pet is currently active in the system'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Action Buttons
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updatePet,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update Pet'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildCheckboxTile(String title, bool value, Function(bool?) onChanged) {
    return SizedBox(
      width: 120,
      child: CheckboxListTile(
        title: Text(title, style: const TextStyle(fontSize: 14)),
        value: value,
        onChanged: onChanged,
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }
}
