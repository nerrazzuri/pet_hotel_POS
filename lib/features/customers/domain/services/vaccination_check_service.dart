import 'package:cat_hotel_pos/features/customers/domain/entities/pet.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/vaccination.dart';
import 'package:cat_hotel_pos/core/services/pet_dao.dart';
import 'package:cat_hotel_pos/core/services/vaccination_dao.dart';

class VaccinationCheckService {
  final PetDao _petDao;
  final VaccinationDao _vaccinationDao;

  VaccinationCheckService({
    required PetDao petDao,
    required VaccinationDao vaccinationDao,
  })  : _petDao = petDao,
        _vaccinationDao = vaccinationDao;

  /// Check if a pet can be checked in based on vaccination status
  Future<Map<String, dynamic>> checkVaccinationStatus(String petId) async {
    try {
      final pet = await _petDao.getById(petId);
      if (pet == null) {
        return {
          'canCheckIn': false,
          'reason': 'Pet not found',
          'blockingVaccinations': [],
          'expiringSoon': [],
          'validVaccinations': [],
        };
      }

      final vaccinations = await _vaccinationDao.getByPetId(petId);
      final now = DateTime.now();
      
      final blockingVaccinations = <Vaccination>[];
      final expiringSoon = <Vaccination>[];
      final validVaccinations = <Vaccination>[];

      for (final vaccination in vaccinations) {
        if (vaccination.expiryDate.isBefore(now)) {
          // Expired vaccination
          if (vaccination.blocksCheckIn == true) {
            blockingVaccinations.add(vaccination);
          }
        } else if (vaccination.expiryDate.difference(now).inDays <= 30) {
          // Expiring soon (within 30 days)
          expiringSoon.add(vaccination);
          validVaccinations.add(vaccination);
        } else {
          // Valid vaccination
          validVaccinations.add(vaccination);
        }
      }

      final canCheckIn = blockingVaccinations.isEmpty;
      final reason = canCheckIn 
          ? 'All required vaccinations are valid'
          : 'Pet has expired vaccinations that block check-in';

      return {
        'canCheckIn': canCheckIn,
        'reason': reason,
        'blockingVaccinations': blockingVaccinations,
        'expiringSoon': expiringSoon,
        'validVaccinations': validVaccinations,
        'pet': pet,
      };
    } catch (e) {
      return {
        'canCheckIn': false,
        'reason': 'Error checking vaccination status: $e',
        'blockingVaccinations': [],
        'expiringSoon': [],
        'validVaccinations': [],
      };
    }
  }

  /// Check vaccination status for multiple pets
  Future<Map<String, Map<String, dynamic>>> checkMultiplePets(List<String> petIds) async {
    final results = <String, Map<String, dynamic>>{};
    
    for (final petId in petIds) {
      results[petId] = await checkVaccinationStatus(petId);
    }
    
    return results;
  }

  /// Get all pets with expired vaccinations
  Future<List<Map<String, dynamic>>> getPetsWithExpiredVaccinations() async {
    try {
      final allPets = await _petDao.getAll();
      final results = <Map<String, dynamic>>[];

      for (final pet in allPets) {
        final status = await checkVaccinationStatus(pet.id);
        if (status['blockingVaccinations'].isNotEmpty) {
          results.add({
            'pet': pet,
            'status': status,
          });
        }
      }

      return results;
    } catch (e) {
      return [];
    }
  }

  /// Get all pets with vaccinations expiring soon
  Future<List<Map<String, dynamic>>> getPetsWithExpiringVaccinations({int daysThreshold = 30}) async {
    try {
      final allPets = await _petDao.getAll();
      final results = <Map<String, dynamic>>[];

      for (final pet in allPets) {
        final status = await checkVaccinationStatus(pet.id);
        if (status['expiringSoon'].isNotEmpty) {
          results.add({
            'pet': pet,
            'status': status,
          });
        }
      }

      return results;
    } catch (e) {
      return [];
    }
  }

  /// Get vaccination summary for a pet
  Future<Map<String, dynamic>> getVaccinationSummary(String petId) async {
    try {
      final pet = await _petDao.getById(petId);
      if (pet == null) {
        return {
          'error': 'Pet not found',
        };
      }

      final vaccinations = await _vaccinationDao.getByPetId(petId);
      final now = DateTime.now();
      
      final expired = vaccinations.where((v) => v.expiryDate.isBefore(now)).toList();
      final expiringSoon = vaccinations.where((v) => 
        v.expiryDate.isAfter(now) && v.expiryDate.difference(now).inDays <= 30
      ).toList();
      final valid = vaccinations.where((v) => 
        v.expiryDate.isAfter(now) && v.expiryDate.difference(now).inDays > 30
      ).toList();

      final blockingCount = expired.where((v) => v.blocksCheckIn == true).length;
      final requiredCount = vaccinations.where((v) => v.isRequired == true).length;
      final validRequiredCount = valid.where((v) => v.isRequired == true).length;

      return {
        'pet': pet,
        'totalVaccinations': vaccinations.length,
        'expired': expired.length,
        'expiringSoon': expiringSoon.length,
        'valid': valid.length,
        'blockingCheckIn': blockingCount,
        'requiredVaccinations': requiredCount,
        'validRequiredVaccinations': validRequiredCount,
        'completionRate': requiredCount > 0 ? (validRequiredCount / requiredCount * 100).toStringAsFixed(1) : '0.0',
        'canCheckIn': blockingCount == 0,
        'vaccinations': {
          'expired': expired,
          'expiringSoon': expiringSoon,
          'valid': valid,
        },
      };
    } catch (e) {
      return {
        'error': 'Error getting vaccination summary: $e',
      };
    }
  }

  /// Get vaccination statistics for all pets
  Future<Map<String, dynamic>> getVaccinationStatistics() async {
    try {
      final allPets = await _petDao.getAll();
      final totalPets = allPets.length;
      
      int petsWithExpiredVaccinations = 0;
      int petsWithExpiringVaccinations = 0;
      int petsBlockedFromCheckIn = 0;
      int petsWithAllVaccinations = 0;

      for (final pet in allPets) {
        final status = await checkVaccinationStatus(pet.id);
        
        if (status['blockingVaccinations'].isNotEmpty) {
          petsWithExpiredVaccinations++;
          petsBlockedFromCheckIn++;
        }
        
        if (status['expiringSoon'].isNotEmpty) {
          petsWithExpiringVaccinations++;
        }
        
        if (status['validVaccinations'].isNotEmpty && status['blockingVaccinations'].isEmpty) {
          petsWithAllVaccinations++;
        }
      }

      return {
        'totalPets': totalPets,
        'petsWithExpiredVaccinations': petsWithExpiredVaccinations,
        'petsWithExpiringVaccinations': petsWithExpiringVaccinations,
        'petsBlockedFromCheckIn': petsBlockedFromCheckIn,
        'petsWithAllVaccinations': petsWithAllVaccinations,
        'complianceRate': totalPets > 0 ? (petsWithAllVaccinations / totalPets * 100).toStringAsFixed(1) : '0.0',
        'blockingRate': totalPets > 0 ? (petsBlockedFromCheckIn / totalPets * 100).toStringAsFixed(1) : '0.0',
      };
    } catch (e) {
      return {
        'error': 'Error getting vaccination statistics: $e',
      };
    }
  }

  /// Generate vaccination reminder for a pet
  Future<Map<String, dynamic>> generateVaccinationReminder(String petId) async {
    try {
      final summary = await getVaccinationSummary(petId);
      if (summary.containsKey('error')) {
        return summary;
      }

      final pet = summary['pet'] as Pet;
      final expiringSoon = summary['vaccinations']['expiringSoon'] as List<Vaccination>;
      
      if (expiringSoon.isEmpty) {
        return {
          'needsReminder': false,
          'message': 'No vaccinations expiring soon',
        };
      }

      final expiringVaccinations = expiringSoon.map((v) => v.name).join(', ');
      final earliestExpiry = expiringSoon.map((v) => v.expiryDate).reduce((a, b) => a.isBefore(b) ? a : b);
      final daysUntilExpiry = earliestExpiry.difference(DateTime.now()).inDays;

      return {
        'needsReminder': true,
        'pet': pet,
        'expiringVaccinations': expiringVaccinations,
        'earliestExpiry': earliestExpiry,
        'daysUntilExpiry': daysUntilExpiry,
        'message': '${pet.name}\'s vaccinations ($expiringVaccinations) expire in $daysUntilExpiry days. Please schedule an appointment.',
        'urgency': daysUntilExpiry <= 7 ? 'high' : daysUntilExpiry <= 14 ? 'medium' : 'low',
      };
    } catch (e) {
      return {
        'error': 'Error generating vaccination reminder: $e',
      };
    }
  }
}
