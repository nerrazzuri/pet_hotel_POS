import 'package:flutter/material.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/vaccination.dart';

class EditVaccinationDialog extends StatefulWidget {
  final Vaccination vaccination;
  final Function(Vaccination) onUpdate;

  const EditVaccinationDialog({
    super.key,
    required this.vaccination,
    required this.onUpdate,
  });

  @override
  State<EditVaccinationDialog> createState() => _EditVaccinationDialogState();
}

class _EditVaccinationDialogState extends State<EditVaccinationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _administeredByController = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _batchNumberController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _notesController = TextEditingController();
  
  VaccinationType _selectedType = VaccinationType.core;
  VaccinationStatus _selectedStatus = VaccinationStatus.upToDate;
  
  DateTime? _selectedAdministeredDate;
  DateTime? _selectedExpiryDate;
  bool _isRequired = true;
  bool _blocksCheckIn = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _nameController.text = widget.vaccination.name;
    _administeredByController.text = widget.vaccination.administeredBy;
    _clinicNameController.text = widget.vaccination.clinicName;
    _batchNumberController.text = widget.vaccination.batchNumber ?? '';
    _manufacturerController.text = widget.vaccination.manufacturer ?? '';
    _notesController.text = widget.vaccination.notes ?? '';
    
    _selectedType = widget.vaccination.type;
    _selectedStatus = widget.vaccination.status;
    _selectedAdministeredDate = widget.vaccination.administeredDate;
    _selectedExpiryDate = widget.vaccination.expiryDate;
    _isRequired = widget.vaccination.isRequired ?? true;
    _blocksCheckIn = widget.vaccination.blocksCheckIn ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _administeredByController.dispose();
    _clinicNameController.dispose();
    _batchNumberController.dispose();
    _manufacturerController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateVaccination() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    if (_selectedAdministeredDate == null || _selectedExpiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select both administered and expiry dates')),
      );
      return;
    }

    try {
      final updatedVaccination = widget.vaccination.copyWith(
        name: _nameController.text.trim(),
        type: _selectedType,
        administeredDate: _selectedAdministeredDate!,
        expiryDate: _selectedExpiryDate!,
        administeredBy: _administeredByController.text.trim(),
        clinicName: _clinicNameController.text.trim(),
        status: _selectedStatus,
        batchNumber: _batchNumberController.text.trim().isEmpty ? null : _batchNumberController.text.trim(),
        manufacturer: _manufacturerController.text.trim().isEmpty ? null : _manufacturerController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        isRequired: _isRequired,
        blocksCheckIn: _blocksCheckIn,
        updatedAt: DateTime.now(),
      );

      await widget.onUpdate(updatedVaccination);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vaccination updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating vaccination: $e'),
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
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.medical_services,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Edit Vaccination: ${widget.vaccination.name}',
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
                      _buildSectionHeader('Vaccination Information'),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Vaccination Name *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vaccination name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<VaccinationType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Vaccination Type *',
                          border: OutlineInputBorder(),
                        ),
                        items: VaccinationType.values.map((type) {
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
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<VaccinationStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status *',
                          border: OutlineInputBorder(),
                        ),
                        items: VaccinationStatus.values.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status.displayName),
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
                      const SizedBox(height: 24),
                      
                      // Dates Section
                      _buildSectionHeader('Dates'),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedAdministeredDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() {
                                    _selectedAdministeredDate = date;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Administered Date *',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _selectedAdministeredDate != null
                                      ? '${_selectedAdministeredDate!.day}/${_selectedAdministeredDate!.month}/${_selectedAdministeredDate!.year}'
                                      : 'Select date',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedExpiryDate ?? DateTime.now().add(const Duration(days: 365)),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 2000)),
                                );
                                if (date != null) {
                                  setState(() {
                                    _selectedExpiryDate = date;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Expiry Date *',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _selectedExpiryDate != null
                                      ? '${_selectedExpiryDate!.day}/${_selectedExpiryDate!.month}/${_selectedExpiryDate!.year}'
                                      : 'Select date',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Medical Information Section
                      _buildSectionHeader('Medical Information'),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _administeredByController,
                        decoration: const InputDecoration(
                          labelText: 'Administered By *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Administered by is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _clinicNameController,
                        decoration: const InputDecoration(
                          labelText: 'Clinic Name *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.local_hospital),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Clinic name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _batchNumberController,
                              decoration: const InputDecoration(
                                labelText: 'Batch Number',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _manufacturerController,
                              decoration: const InputDecoration(
                                labelText: 'Manufacturer',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Settings Section
                      _buildSectionHeader('Settings'),
                      const SizedBox(height: 16),
                      
                      SwitchListTile(
                        title: const Text('Required Vaccination'),
                        subtitle: const Text('This vaccination is required for pet check-in'),
                        value: _isRequired,
                        onChanged: (value) {
                          setState(() {
                            _isRequired = value;
                          });
                        },
                      ),
                      
                      SwitchListTile(
                        title: const Text('Blocks Check-in'),
                        subtitle: const Text('Expired vaccination blocks pet check-in'),
                        value: _blocksCheckIn,
                        onChanged: (value) {
                          setState(() {
                            _blocksCheckIn = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Notes Section
                      _buildSectionHeader('Notes'),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(),
                          hintText: 'Additional notes about the vaccination...',
                        ),
                        maxLines: 3,
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
                  onPressed: _isLoading ? null : _updateVaccination,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update Vaccination'),
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
}
