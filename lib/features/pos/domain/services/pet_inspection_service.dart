import 'package:uuid/uuid.dart';
import 'package:cat_hotel_pos/features/pos/domain/entities/checkin_request.dart';
import 'package:cat_hotel_pos/features/customers/domain/services/customer_pet_service.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/pet.dart';

class PetInspectionService {
  final CustomerPetService _petService;
  final Uuid _uuid = const Uuid();

  PetInspectionService({
    required CustomerPetService petService,
  }) : _petService = petService;

  Future<PetInspection> conductPetInspection({
    required String petId,
    required String inspectorId,
    required String inspectorName,
    required String overallCondition,
    String? weightNotes,
    String? coatCondition,
    String? eyeCondition,
    String? earCondition,
    String? behaviorObservations,
    bool? vaccinationsVerified,
    List<String>? healthConcerns,
    bool? requiresVetAttention,
    String? temperatureCheck,
    List<String>? belongings,
    String? foodBrought,
    String? medicationBrought,
    List<String>? toysAndComforts,
    List<String>? arrivalPhotos,
    String? inspectionNotes,
    String? ownerConcerns,
  }) async {
    final pet = await _petService.getPetById(petId);
    if (pet == null) {
      throw Exception('Pet not found with ID: $petId');
    }

    final inspection = PetInspection(
      petId: petId,
      inspectionTime: DateTime.now(),
      inspectedBy: inspectorName,
      overallCondition: overallCondition,
      weightNotes: weightNotes,
      coatCondition: coatCondition,
      eyeCondition: eyeCondition,
      earCondition: earCondition,
      behaviorObservations: behaviorObservations,
      vaccinationsVerified: vaccinationsVerified,
      healthConcerns: healthConcerns,
      requiresVetAttention: requiresVetAttention,
      temperatureCheck: temperatureCheck,
      belongings: belongings,
      foodBrought: foodBrought,
      medicationBrought: medicationBrought,
      toysAndComforts: toysAndComforts,
      arrivalPhotos: arrivalPhotos,
      inspectionNotes: inspectionNotes,
      ownerConcerns: ownerConcerns,
      approved: _determineApprovalStatus(
        overallCondition: overallCondition,
        healthConcerns: healthConcerns,
        requiresVetAttention: requiresVetAttention ?? false,
      ),
    );

    return inspection;
  }

  Future<PetInspection> quickInspection({
    required String petId,
    required String inspectorName,
    String? behaviorNotes,
    List<String>? belongings,
  }) async {
    return await conductPetInspection(
      petId: petId,
      inspectorId: 'system',
      inspectorName: inspectorName,
      overallCondition: 'good',
      behaviorObservations: behaviorNotes,
      belongings: belongings,
      vaccinationsVerified: true,
    );
  }

  Future<List<String>> validatePetForCheckIn(String petId) async {
    final List<String> warnings = [];
    
    try {
      final pet = await _petService.getPetById(petId);
      if (pet == null) {
        warnings.add('Pet not found');
        return warnings;
      }

      if (pet.isActive == false) {
        warnings.add('Pet record is not active');
      }

      final now = DateTime.now();
      
      if (pet.isVaccinated != true) {
        warnings.add('Pet vaccinations are not up to date');
      }

      if (pet.allergies != null && pet.allergies!.isNotEmpty) {
        warnings.add('Pet has known allergies - check medical history');
      }

      if (pet.veterinarianPhone == null || pet.veterinarianPhone!.isEmpty) {
        warnings.add('No veterinarian contact on file');
      }

    } catch (e) {
      warnings.add('Error validating pet information: $e');
    }

    return warnings;
  }

  Future<Map<String, dynamic>> getPetInspectionData(String petId) async {
    try {
      final pet = await _petService.getPetById(petId);
      if (pet == null) {
        return {
          'error': 'Pet not found',
          'petExists': false,
        };
      }

      return {
        'petExists': true,
        'petName': pet.name,
        'breed': pet.breed,
        'age': pet.age,
        'weight': pet.weight,
        'gender': pet.gender,
        'color': pet.color,
        'notes': pet.notes,
        'specialNeeds': pet.specialNeeds,
        'behaviorNotes': pet.behaviorNotes,
        'veterinarianPhone': pet.veterinarianPhone,
        'isVaccinated': pet.isVaccinated,
        'isActive': pet.isActive,

      };
    } catch (e) {
      return {
        'error': 'Error retrieving pet data: $e',
        'petExists': false,
      };
    }
  }

  bool _determineApprovalStatus({
    required String overallCondition,
    List<String>? healthConcerns,
    required bool requiresVetAttention,
  }) {
    if (requiresVetAttention) return false;
    
    if (overallCondition.toLowerCase() == 'poor') return false;
    
    if (healthConcerns != null && healthConcerns.isNotEmpty) {
      final seriousConcerns = healthConcerns.where((concern) => 
        concern.toLowerCase().contains('injury') ||
        concern.toLowerCase().contains('infection') ||
        concern.toLowerCase().contains('fever') ||
        concern.toLowerCase().contains('emergency')
      );
      if (seriousConcerns.isNotEmpty) return false;
    }
    
    return true;
  }

  Future<String> generateInspectionSummary(PetInspection inspection) async {
    final petData = await getPetInspectionData(inspection.petId);
    final petName = petData['petName'] ?? 'Unknown Pet';
    
    final buffer = StringBuffer();
    buffer.writeln('Pet Inspection Summary');
    buffer.writeln('=====================');
    buffer.writeln('Pet: $petName');
    buffer.writeln('Inspector: ${inspection.inspectedBy}');
    buffer.writeln('Inspection Time: ${inspection.inspectionTime.toString().substring(0, 19)}');
    buffer.writeln('Overall Condition: ${inspection.overallCondition}');
    buffer.writeln('Status: ${inspection.approved == true ? 'APPROVED' : 'REQUIRES ATTENTION'}');
    
    if (inspection.healthConcerns != null && inspection.healthConcerns!.isNotEmpty) {
      buffer.writeln('\nHealth Concerns:');
      for (final concern in inspection.healthConcerns!) {
        buffer.writeln('- $concern');
      }
    }
    
    if (inspection.belongings != null && inspection.belongings!.isNotEmpty) {
      buffer.writeln('\nBelongings:');
      for (final item in inspection.belongings!) {
        buffer.writeln('- $item');
      }
    }
    
    if (inspection.inspectionNotes != null) {
      buffer.writeln('\nNotes: ${inspection.inspectionNotes}');
    }
    
    return buffer.toString();
  }
}