import 'package:flutter/material.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/incident.dart';

class EditIncidentDialog extends StatefulWidget {
  final Incident incident;
  final Function(Incident) onUpdate;

  const EditIncidentDialog({
    super.key,
    required this.incident,
    required this.onUpdate,
  });

  @override
  State<EditIncidentDialog> createState() => _EditIncidentDialogState();
}

class _EditIncidentDialogState extends State<EditIncidentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _reportedByController = TextEditingController();
  final _locationController = TextEditingController();
  final _witnessesController = TextEditingController();
  final _actionsTakenController = TextEditingController();
  final _followUpRequiredController = TextEditingController();
  final _notesController = TextEditingController();
  
  IncidentType _selectedType = IncidentType.medical;
  IncidentSeverity _selectedSeverity = IncidentSeverity.minor;
  IncidentStatus _selectedStatus = IncidentStatus.reported;
  
  DateTime? _selectedOccurredDate;
  DateTime? _selectedResolvedDate;
  bool _requiresVeterinarian = false;
  bool _requiresCustomerNotification = false;
  bool _blocksCheckIn = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    _titleController.text = widget.incident.title;
    _descriptionController.text = widget.incident.description;
    _reportedByController.text = widget.incident.reportedBy;
    _locationController.text = widget.incident.location ?? '';
    _witnessesController.text = widget.incident.witnesses ?? '';
    _actionsTakenController.text = widget.incident.actionsTaken ?? '';
    _followUpRequiredController.text = widget.incident.followUpRequired ?? '';
    _notesController.text = widget.incident.notes ?? '';
    
    _selectedType = widget.incident.type;
    _selectedSeverity = widget.incident.severity;
    _selectedStatus = widget.incident.status;
    _selectedOccurredDate = widget.incident.occurredDate;
    _selectedResolvedDate = widget.incident.resolvedDate;
    _requiresVeterinarian = widget.incident.requiresVeterinarian ?? false;
    _requiresCustomerNotification = widget.incident.requiresCustomerNotification ?? false;
    _blocksCheckIn = widget.incident.blocksCheckIn ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _reportedByController.dispose();
    _locationController.dispose();
    _witnessesController.dispose();
    _actionsTakenController.dispose();
    _followUpRequiredController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _updateIncident() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedIncident = widget.incident.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        severity: _selectedSeverity,
        status: _selectedStatus,
        reportedBy: _reportedByController.text.trim(),
        occurredDate: _selectedOccurredDate,
        resolvedDate: _selectedResolvedDate,
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        witnesses: _witnessesController.text.trim().isEmpty ? null : _witnessesController.text.trim(),
        actionsTaken: _actionsTakenController.text.trim().isEmpty ? null : _actionsTakenController.text.trim(),
        followUpRequired: _followUpRequiredController.text.trim().isEmpty ? null : _followUpRequiredController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        requiresVeterinarian: _requiresVeterinarian,
        requiresCustomerNotification: _requiresCustomerNotification,
        blocksCheckIn: _blocksCheckIn,
        updatedAt: DateTime.now(),
      );

      await widget.onUpdate(updatedIncident);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incident updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating incident: $e'),
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
                  Icons.warning,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Edit Incident: ${widget.incident.title}',
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
                      _buildSectionHeader('Incident Information'),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Incident Title *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Incident title is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<IncidentType>(
                              value: _selectedType,
                              decoration: const InputDecoration(
                                labelText: 'Incident Type *',
                                border: OutlineInputBorder(),
                              ),
                              items: IncidentType.values.map((type) {
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
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<IncidentSeverity>(
                              value: _selectedSeverity,
                              decoration: const InputDecoration(
                                labelText: 'Severity *',
                                border: OutlineInputBorder(),
                              ),
                              items: IncidentSeverity.values.map((severity) {
                                return DropdownMenuItem(
                                  value: severity,
                                  child: Text(severity.displayName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedSeverity = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<IncidentStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status *',
                          border: OutlineInputBorder(),
                        ),
                        items: IncidentStatus.values.map((status) {
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
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          border: OutlineInputBorder(),
                          hintText: 'Describe what happened...',
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Description is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Reporting Information Section
                      _buildSectionHeader('Reporting Information'),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _reportedByController,
                        decoration: const InputDecoration(
                          labelText: 'Reported By *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Reported by is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final date = await showDatePicker(
                                  context: context,
                                  initialDate: _selectedOccurredDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() {
                                    _selectedOccurredDate = date;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Occurred Date *',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _selectedOccurredDate != null
                                      ? '${_selectedOccurredDate!.day}/${_selectedOccurredDate!.month}/${_selectedOccurredDate!.year}'
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
                                  initialDate: _selectedResolvedDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                );
                                if (date != null) {
                                  setState(() {
                                    _selectedResolvedDate = date;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Resolved Date',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _selectedResolvedDate != null
                                      ? '${_selectedResolvedDate!.day}/${_selectedResolvedDate!.month}/${_selectedResolvedDate!.year}'
                                      : 'Select date',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Location & Witnesses Section
                      _buildSectionHeader('Location & Witnesses'),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _witnessesController,
                        decoration: const InputDecoration(
                          labelText: 'Witnesses',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.visibility),
                          hintText: 'List any witnesses...',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      
                      // Actions & Follow-up Section
                      _buildSectionHeader('Actions & Follow-up'),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _actionsTakenController,
                        decoration: const InputDecoration(
                          labelText: 'Actions Taken',
                          border: OutlineInputBorder(),
                          hintText: 'Describe actions taken...',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _followUpRequiredController,
                        decoration: const InputDecoration(
                          labelText: 'Follow-up Required',
                          border: OutlineInputBorder(),
                          hintText: 'Describe any follow-up required...',
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      
                      // Settings Section
                      _buildSectionHeader('Settings'),
                      const SizedBox(height: 16),
                      
                      SwitchListTile(
                        title: const Text('Requires Veterinarian'),
                        subtitle: const Text('This incident requires veterinarian attention'),
                        value: _requiresVeterinarian,
                        onChanged: (value) {
                          setState(() {
                            _requiresVeterinarian = value;
                          });
                        },
                      ),
                      
                      SwitchListTile(
                        title: const Text('Requires Customer Notification'),
                        subtitle: const Text('Customer must be notified about this incident'),
                        value: _requiresCustomerNotification,
                        onChanged: (value) {
                          setState(() {
                            _requiresCustomerNotification = value;
                          });
                        },
                      ),
                      
                      SwitchListTile(
                        title: const Text('Blocks Check-in'),
                        subtitle: const Text('This incident blocks pet check-in'),
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
                          labelText: 'Additional Notes',
                          border: OutlineInputBorder(),
                          hintText: 'Any additional notes about the incident...',
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
                  onPressed: _isLoading ? null : _updateIncident,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update Incident'),
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
