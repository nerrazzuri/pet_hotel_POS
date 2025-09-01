import 'package:flutter/material.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/waiver.dart';

class EditWaiverDialog extends StatefulWidget {
  final Waiver waiver;
  final Function(Waiver) onUpdate;

  const EditWaiverDialog({
    super.key,
    required this.waiver,
    required this.onUpdate,
  });

  @override
  State<EditWaiverDialog> createState() => _EditWaiverDialogState();
}

class _EditWaiverDialogState extends State<EditWaiverDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _signedByController = TextEditingController();
  final _witnessNameController = TextEditingController();
  
  WaiverType _selectedType = WaiverType.boardingConsent;
  WaiverStatus _selectedStatus = WaiverStatus.pending;
  String _selectedSignatureMethod = 'digital';
  
  DateTime? _selectedSignedDate;
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
    _titleController.text = widget.waiver.title;
    _contentController.text = widget.waiver.content;
    _signedByController.text = widget.waiver.signedBy ?? '';
    _witnessNameController.text = widget.waiver.witnessName ?? '';
    
    _selectedType = widget.waiver.type;
    _selectedStatus = widget.waiver.status;
    _selectedSignatureMethod = widget.waiver.signatureMethod ?? 'digital';
    _selectedSignedDate = widget.waiver.signedDate;
    _selectedExpiryDate = widget.waiver.expiryDate;
    _isRequired = widget.waiver.isRequired ?? true;
    _blocksCheckIn = widget.waiver.blocksCheckIn ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _signedByController.dispose();
    _witnessNameController.dispose();
    super.dispose();
  }

  Future<void> _updateWaiver() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedWaiver = widget.waiver.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        type: _selectedType,
        status: _selectedStatus,
        signedDate: _selectedSignedDate,
        signedBy: _signedByController.text.trim().isEmpty ? null : _signedByController.text.trim(),
        signatureMethod: _selectedSignatureMethod,
        witnessName: _witnessNameController.text.trim().isEmpty ? null : _witnessNameController.text.trim(),
        expiryDate: _selectedExpiryDate,
        isRequired: _isRequired,
        blocksCheckIn: _blocksCheckIn,
        updatedAt: DateTime.now(),
      );

      await widget.onUpdate(updatedWaiver);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Waiver updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating waiver: $e'),
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
                  Icons.description,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Edit Waiver: ${widget.waiver.title}',
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
                      _buildSectionHeader('Waiver Information'),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Waiver Title *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Waiver title is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<WaiverType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Waiver Type *',
                          border: OutlineInputBorder(),
                        ),
                        items: WaiverType.values.map((type) {
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
                      
                      TextFormField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          labelText: 'Waiver Content *',
                          border: OutlineInputBorder(),
                          hintText: 'Enter the waiver content...',
                        ),
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Waiver content is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Status Section
                      _buildSectionHeader('Status & Signature'),
                      const SizedBox(height: 16),
                      
                      DropdownButtonFormField<WaiverStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status *',
                          border: OutlineInputBorder(),
                        ),
                        items: WaiverStatus.values.map((status) {
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
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _signedByController,
                              decoration: const InputDecoration(
                                labelText: 'Signed By',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedSignatureMethod,
                              decoration: const InputDecoration(
                                labelText: 'Signature Method',
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'digital', child: Text('Digital')),
                                DropdownMenuItem(value: 'physical', child: Text('Physical')),
                                DropdownMenuItem(value: 'electronic', child: Text('Electronic')),
                              ],
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedSignatureMethod = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _witnessNameController,
                        decoration: const InputDecoration(
                          labelText: 'Witness Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.visibility),
                        ),
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
                                  initialDate: _selectedSignedDate ?? DateTime.now(),
                                  firstDate: DateTime(2020),
                                  lastDate: DateTime.now(),
                                );
                                if (date != null) {
                                  setState(() {
                                    _selectedSignedDate = date;
                                  });
                                }
                              },
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Signed Date',
                                  border: OutlineInputBorder(),
                                  suffixIcon: Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  _selectedSignedDate != null
                                      ? '${_selectedSignedDate!.day}/${_selectedSignedDate!.month}/${_selectedSignedDate!.year}'
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
                                  labelText: 'Expiry Date',
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
                      
                      // Settings Section
                      _buildSectionHeader('Settings'),
                      const SizedBox(height: 16),
                      
                      SwitchListTile(
                        title: const Text('Required Waiver'),
                        subtitle: const Text('This waiver is required for pet check-in'),
                        value: _isRequired,
                        onChanged: (value) {
                          setState(() {
                            _isRequired = value;
                          });
                        },
                      ),
                      
                      SwitchListTile(
                        title: const Text('Blocks Check-in'),
                        subtitle: const Text('Missing/expired waiver blocks pet check-in'),
                        value: _blocksCheckIn,
                        onChanged: (value) {
                          setState(() {
                            _blocksCheckIn = value;
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
                  onPressed: _isLoading ? null : _updateWaiver,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Update Waiver'),
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
