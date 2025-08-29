import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/checkin_request.dart';
import 'package:cat_hotel_pos/features/pos/domain/services/pet_inspection_service.dart';
import 'package:cat_hotel_pos/features/customers/domain/services/customer_pet_service.dart';

class PetInspectionWidget extends ConsumerStatefulWidget {
  final String petId;
  final Function(PetInspection) onInspectionCompleted;
  final VoidCallback? onSkip;
  final bool allowSkip;

  const PetInspectionWidget({
    super.key,
    required this.petId,
    required this.onInspectionCompleted,
    this.onSkip,
    this.allowSkip = false,
  });

  @override
  ConsumerState<PetInspectionWidget> createState() => _PetInspectionWidgetState();
}

class _PetInspectionWidgetState extends ConsumerState<PetInspectionWidget> {
  late final PetInspectionService _inspectionService;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _behaviorController = TextEditingController();
  final _notesController = TextEditingController();
  final _weightNotesController = TextEditingController();
  final _ownerConcernsController = TextEditingController();
  final _belongingsController = TextEditingController();
  final _foodController = TextEditingController();
  final _medicationController = TextEditingController();
  
  // Form state
  String _overallCondition = 'good';
  String _coatCondition = 'good';
  String _eyeCondition = 'good';
  String _earCondition = 'good';
  bool _vaccinationsVerified = true;
  bool _requiresVetAttention = false;
  List<String> _healthConcerns = [];
  List<String> _belongings = [];
  
  Map<String, dynamic>? _petData;
  bool _isLoading = true;
  List<String> _validationWarnings = [];

  @override
  void initState() {
    super.initState();
    _inspectionService = PetInspectionService(
      petService: CustomerPetService(),
    );
    _loadPetData();
  }

  @override
  void dispose() {
    _behaviorController.dispose();
    _notesController.dispose();
    _weightNotesController.dispose();
    _ownerConcernsController.dispose();
    _belongingsController.dispose();
    _foodController.dispose();
    _medicationController.dispose();
    super.dispose();
  }

  Future<void> _loadPetData() async {
    try {
      final petData = await _inspectionService.getPetInspectionData(widget.petId);
      final warnings = await _inspectionService.validatePetForCheckIn(widget.petId);
      
      setState(() {
        _petData = petData;
        _validationWarnings = warnings;
        _isLoading = false;
      });
      
      _prefillFormData();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading pet data: $e')),
        );
      }
    }
  }

  void _prefillFormData() {
    if (_petData == null) return;
    
    _behaviorController.text = _petData!['behaviorNotes'] ?? '';
    
    if (_petData!['dietaryRestrictions'] != null) {
      _foodController.text = _petData!['dietaryRestrictions'];
    }
  }

  Future<void> _submitInspection() async {
    if (!_formKey.currentState!.validate()) return;
    
    try {
      // Parse belongings from text input
      final belongingsText = _belongingsController.text.trim();
      if (belongingsText.isNotEmpty) {
        _belongings = belongingsText
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }

      final inspection = await _inspectionService.conductPetInspection(
        petId: widget.petId,
        inspectorId: 'current_user', // TODO: Get from auth context
        inspectorName: 'Staff Member', // TODO: Get from auth context
        overallCondition: _overallCondition,
        weightNotes: _weightNotesController.text.isEmpty ? null : _weightNotesController.text,
        coatCondition: _coatCondition,
        eyeCondition: _eyeCondition,
        earCondition: _earCondition,
        behaviorObservations: _behaviorController.text.isEmpty ? null : _behaviorController.text,
        vaccinationsVerified: _vaccinationsVerified,
        healthConcerns: _healthConcerns.isEmpty ? null : _healthConcerns,
        requiresVetAttention: _requiresVetAttention,
        belongings: _belongings.isEmpty ? null : _belongings,
        foodBrought: _foodController.text.isEmpty ? null : _foodController.text,
        medicationBrought: _medicationController.text.isEmpty ? null : _medicationController.text,
        inspectionNotes: _notesController.text.isEmpty ? null : _notesController.text,
        ownerConcerns: _ownerConcernsController.text.isEmpty ? null : _ownerConcernsController.text,
      );

      widget.onInspectionCompleted(inspection);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error conducting inspection: $e')),
        );
      }
    }
  }

  Future<void> _quickInspection() async {
    try {
      final inspection = await _inspectionService.quickInspection(
        petId: widget.petId,
        inspectorName: 'Staff Member',
        behaviorNotes: _behaviorController.text.isEmpty ? null : _behaviorController.text,
        belongings: _belongings.isEmpty ? null : _belongings,
      );

      widget.onInspectionCompleted(inspection);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error conducting quick inspection: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_petData == null || _petData!['petExists'] != true) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              const Text('Pet information not found'),
              const SizedBox(height: 16),
              if (widget.allowSkip)
                TextButton(
                  onPressed: widget.onSkip,
                  child: const Text('Skip Inspection'),
                ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pet Information Header
              _buildPetInfoHeader(),
              
              // Validation Warnings
              if (_validationWarnings.isNotEmpty) _buildWarningsSection(),
              
              const SizedBox(height: 16),
              
              // Quick Actions
              _buildQuickActions(),
              
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              
              // Detailed Inspection Form
              const Text(
                'Detailed Inspection',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              // Physical Condition
              _buildPhysicalConditionSection(),
              
              const SizedBox(height: 16),
              
              // Behavioral Observations
              _buildBehavioralSection(),
              
              const SizedBox(height: 16),
              
              // Belongings & Care Items
              _buildBelongingsSection(),
              
              const SizedBox(height: 16),
              
              // Health & Veterinary
              _buildHealthSection(),
              
              const SizedBox(height: 16),
              
              // Additional Notes
              _buildNotesSection(),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetInfoHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          const Icon(Icons.pets, color: Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _petData!['petName'] ?? 'Unknown Pet',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_petData!['breed'] != null)
                  Text('Breed: ${_petData!['breed']}'),
                if (_petData!['age'] != null)
                  Text('Age: ${_petData!['age']}'),
                if (_petData!['weight'] != null)
                  Text('Weight: ${_petData!['weight']} kg'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningsSection() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Attention Required', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          ...(_validationWarnings.map((warning) => Padding(
            padding: const EdgeInsets.only(left: 24.0),
            child: Text('• $warning'),
          )).toList()),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: _quickInspection,
          icon: const Icon(Icons.speed),
          label: const Text('Quick Check-In'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        if (widget.allowSkip)
          TextButton.icon(
            onPressed: widget.onSkip,
            icon: const Icon(Icons.skip_next),
            label: const Text('Skip Inspection'),
          ),
      ],
    );
  }

  Widget _buildPhysicalConditionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Physical Condition', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        
        // Overall Condition
        DropdownButtonFormField<String>(
          value: _overallCondition,
          decoration: const InputDecoration(
            labelText: 'Overall Condition',
            border: OutlineInputBorder(),
          ),
          items: ['excellent', 'good', 'fair', 'poor']
              .map((condition) => DropdownMenuItem(
                    value: condition,
                    child: Text(condition.toUpperCase()),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _overallCondition = value!),
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _coatCondition,
                decoration: const InputDecoration(
                  labelText: 'Coat Condition',
                  border: OutlineInputBorder(),
                ),
                items: ['excellent', 'good', 'fair', 'poor']
                    .map((condition) => DropdownMenuItem(
                          value: condition,
                          child: Text(condition.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _coatCondition = value!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _weightNotesController,
                decoration: const InputDecoration(
                  labelText: 'Weight Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBehavioralSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Behavior & Temperament', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _behaviorController,
          decoration: const InputDecoration(
            labelText: 'Behavioral Observations',
            hintText: 'Friendly, anxious, playful, etc.',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildBelongingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Belongings & Care Items', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _belongingsController,
          decoration: const InputDecoration(
            labelText: 'Pet Belongings',
            hintText: 'Toys, blankets, carrier, etc. (comma separated)',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _foodController,
                decoration: const InputDecoration(
                  labelText: 'Food Brought',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _medicationController,
                decoration: const InputDecoration(
                  labelText: 'Medication Brought',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Health & Veterinary', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: const Text('Vaccinations Verified'),
                value: _vaccinationsVerified,
                onChanged: (value) => setState(() => _vaccinationsVerified = value!),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: const Text('Requires Vet Attention'),
                value: _requiresVetAttention,
                onChanged: (value) => setState(() => _requiresVetAttention = value!),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Additional Notes', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Inspection Notes',
            hintText: 'Any additional observations or concerns...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _ownerConcernsController,
          decoration: const InputDecoration(
            labelText: 'Owner Concerns',
            hintText: 'Any concerns mentioned by the pet owner...',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (widget.allowSkip)
          TextButton(
            onPressed: widget.onSkip,
            child: const Text('Skip'),
          ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: _submitInspection,
          icon: const Icon(Icons.check_circle),
          label: const Text('Complete Inspection'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }
}

// Placeholder for missing provider - this should be implemented with proper DI
final petDaoProvider = Provider<dynamic>((ref) {
  // This should return actual PetDao instance
  throw UnimplementedError('PetDao provider not implemented');
});