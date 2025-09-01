import 'package:cat_hotel_pos/features/customers/domain/entities/customer.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/pet.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/vaccination.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/waiver.dart';
import 'package:cat_hotel_pos/features/customers/domain/entities/incident.dart';
import 'package:cat_hotel_pos/core/services/customer_dao.dart';
import 'package:cat_hotel_pos/core/services/pet_dao.dart';
import 'package:cat_hotel_pos/core/services/vaccination_dao.dart';
import 'package:cat_hotel_pos/core/services/waiver_dao.dart';
import 'package:cat_hotel_pos/core/services/incident_dao.dart';

class CustomerPetService {
  final CustomerDao _customerDao = CustomerDao();
  final PetDao _petDao = PetDao();
  final VaccinationDao _vaccinationDao = VaccinationDao();
  final WaiverDao _waiverDao = WaiverDao();
  final IncidentDao _incidentDao = IncidentDao();
  // Customer Management
  Future<List<Customer>> getAllCustomers() async {
    try {
      return await _customerDao.getAll();
    } catch (e) {
      print('CustomerPetService.getAllCustomers: Error: $e');
      return [];
    }
  }

  Future<Customer?> getCustomerById(String id) async {
    try {
      return await _customerDao.getById(id);
    } catch (e) {
      print('CustomerPetService.getCustomerById: Error: $e');
      return null;
    }
  }

  Future<Customer?> getCustomerByCode(String customerCode) async {
    try {
      final customers = await _customerDao.getAll();
      return customers.firstWhere(
        (customer) => customer.customerCode == customerCode,
        orElse: () => throw StateError('Customer not found'),
      );
    } catch (e) {
      print('CustomerPetService.getCustomerByCode: Error: $e');
      return null;
    }
  }

  Future<Customer> createCustomer(Customer customer) async {
    try {
      await _customerDao.insert(customer);
      return customer;
    } catch (e) {
      print('CustomerPetService.createCustomer: Error: $e');
      rethrow;
    }
  }

  Future<Customer> updateCustomer(Customer customer) async {
    try {
      await _customerDao.update(customer);
      return customer;
    } catch (e) {
      print('CustomerPetService.updateCustomer: Error: $e');
      rethrow;
    }
  }

  Future<bool> deleteCustomer(String id) async {
    try {
      await _customerDao.delete(id);
      return true;
    } catch (e) {
      print('CustomerPetService.deleteCustomer: Error: $e');
      return false;
    }
  }

  Future<List<Customer>> searchCustomers(String query) async {
    try {
      return await _customerDao.search(query);
    } catch (e) {
      print('CustomerPetService.searchCustomers: Error: $e');
      return [];
    }
  }

  Future<List<Customer>> getCustomersByStatus(CustomerStatus status) async {
    try {
      return await _customerDao.getByStatus(status);
    } catch (e) {
      print('CustomerPetService.getCustomersByStatus: Error: $e');
      return [];
    }
  }

  // Pet Management
  Future<List<Pet>> getAllPets() async {
    try {
      return await _petDao.getAll();
    } catch (e) {
      print('CustomerPetService.getAllPets: Error: $e');
      return [];
    }
  }

  Future<Pet?> getPetById(String id) async {
    try {
      return await _petDao.getById(id);
    } catch (e) {
      print('CustomerPetService.getPetById: Error: $e');
      return null;
    }
  }

  Future<List<Pet>> getPetsByCustomerId(String customerId) async {
    try {
      return await _petDao.getByCustomerId(customerId);
    } catch (e) {
      print('CustomerPetService.getPetsByCustomerId: Error: $e');
      return [];
    }
  }

  Future<Pet> createPet(Pet pet) async {
    try {
      await _petDao.insert(pet);
      return pet;
    } catch (e) {
      print('CustomerPetService.createPet: Error: $e');
      rethrow;
    }
  }

  Future<Pet> updatePet(Pet pet) async {
    try {
      return await _petDao.update(pet);
    } catch (e) {
      print('CustomerPetService.updatePet: Error: $e');
      rethrow;
    }
  }

  Future<bool> deletePet(String id) async {
    try {
      await _petDao.delete(id);
      return true;
    } catch (e) {
      print('CustomerPetService.deletePet: Error: $e');
      return false;
    }
  }

  Future<List<Pet>> searchPets(String query) async {
    try {
      return await _petDao.search(query);
    } catch (e) {
      print('CustomerPetService.searchPets: Error: $e');
      return [];
    }
  }

  Future<List<Pet>> getPetsByType(PetType type) async {
    try {
      return await _petDao.getByType(type);
    } catch (e) {
      print('CustomerPetService.getPetsByType: Error: $e');
      return [];
    }
  }

  // Vaccination Management
  Future<List<Vaccination>> getAllVaccinations() async {
    try {
      return await _vaccinationDao.getAll();
    } catch (e) {
      print('CustomerPetService.getAllVaccinations: Error: $e');
      return [];
    }
  }

  Future<List<Vaccination>> getVaccinationsByPetId(String petId) async {
    try {
      return await _vaccinationDao.getByPetId(petId);
    } catch (e) {
      print('CustomerPetService.getVaccinationsByPetId: Error: $e');
      return [];
    }
  }

  Future<Vaccination> createVaccination(Vaccination record) async {
    try {
      return await _vaccinationDao.create(record);
    } catch (e) {
      print('CustomerPetService.createVaccination: Error: $e');
      rethrow;
    }
  }

  Future<Vaccination> updateVaccination(Vaccination record) async {
    try {
      return await _vaccinationDao.update(record);
    } catch (e) {
      print('CustomerPetService.updateVaccination: Error: $e');
      rethrow;
    }
  }

  Future<bool> deleteVaccination(String id) async {
    try {
      return await _vaccinationDao.delete(id);
    } catch (e) {
      print('CustomerPetService.deleteVaccination: Error: $e');
      return false;
    }
  }

  Future<List<Vaccination>> getExpiredVaccinations() async {
    try {
      return await _vaccinationDao.getExpired();
    } catch (e) {
      print('CustomerPetService.getExpiredVaccinations: Error: $e');
      return [];
    }
  }

  Future<List<Vaccination>> getVaccinationsDueSoon(int daysThreshold) async {
    try {
      return await _vaccinationDao.getExpiringSoon(daysThreshold);
    } catch (e) {
      print('CustomerPetService.getVaccinationsDueSoon: Error: $e');
      return [];
    }
  }

  // Waiver & Consent Management
  Future<List<Waiver>> getAllWaivers() async {
    try {
      return await _waiverDao.getAll();
    } catch (e) {
      print('CustomerPetService.getAllWaivers: Error: $e');
      return [];
    }
  }

  Future<List<Waiver>> getWaiversByCustomerId(String customerId) async {
    try {
      return await _waiverDao.getByCustomerId(customerId);
    } catch (e) {
      print('CustomerPetService.getWaiversByCustomerId: Error: $e');
      return [];
    }
  }

  Future<List<Waiver>> getWaiversByPetId(String petId) async {
    try {
      return await _waiverDao.getByPetId(petId);
    } catch (e) {
      print('CustomerPetService.getWaiversByPetId: Error: $e');
      return [];
    }
  }

  Future<Waiver> createWaiver(Waiver waiver) async {
    try {
      return await _waiverDao.create(waiver);
    } catch (e) {
      print('CustomerPetService.createWaiver: Error: $e');
      rethrow;
    }
  }

  Future<Waiver> updateWaiver(Waiver waiver) async {
    try {
      return await _waiverDao.update(waiver);
    } catch (e) {
      print('CustomerPetService.updateWaiver: Error: $e');
      rethrow;
    }
  }

  Future<bool> deleteWaiver(String id) async {
    try {
      return await _waiverDao.delete(id);
    } catch (e) {
      print('CustomerPetService.deleteWaiver: Error: $e');
      return false;
    }
  }

  Future<List<Waiver>> getExpiredWaivers() async {
    try {
      return await _waiverDao.getExpired();
    } catch (e) {
      print('CustomerPetService.getExpiredWaivers: Error: $e');
      return [];
    }
  }

  Future<List<Waiver>> getWaiversNeedingRenewal() async {
    try {
      return await _waiverDao.getExpiringSoon(30); // 30 days threshold
    } catch (e) {
      print('CustomerPetService.getWaiversNeedingRenewal: Error: $e');
      return [];
    }
  }

  // Incident Management
  Future<List<Incident>> getAllIncidents() async {
    try {
      return await _incidentDao.getAll();
    } catch (e) {
      print('CustomerPetService.getAllIncidents: Error: $e');
      return [];
    }
  }

  Future<List<Incident>> getIncidentsByPetId(String petId) async {
    try {
      return await _incidentDao.getByPetId(petId);
    } catch (e) {
      print('CustomerPetService.getIncidentsByPetId: Error: $e');
      return [];
    }
  }

  Future<List<Incident>> getIncidentsByCustomerId(String customerId) async {
    try {
      return await _incidentDao.getByCustomerId(customerId);
    } catch (e) {
      print('CustomerPetService.getIncidentsByCustomerId: Error: $e');
      return [];
    }
  }

  Future<Incident> createIncident(Incident incident) async {
    try {
      return await _incidentDao.create(incident);
    } catch (e) {
      print('CustomerPetService.createIncident: Error: $e');
      rethrow;
    }
  }

  Future<Incident> updateIncident(Incident incident) async {
    try {
      return await _incidentDao.update(incident);
    } catch (e) {
      print('CustomerPetService.updateIncident: Error: $e');
      rethrow;
    }
  }

  Future<bool> deleteIncident(String id) async {
    try {
      return await _incidentDao.delete(id);
    } catch (e) {
      print('CustomerPetService.deleteIncident: Error: $e');
      return false;
    }
  }

  Future<List<Incident>> getOpenIncidents() async {
    try {
      return await _incidentDao.getOpenIncidents();
    } catch (e) {
      print('CustomerPetService.getOpenIncidents: Error: $e');
      return [];
    }
  }

  Future<List<Incident>> getCriticalIncidents() async {
    try {
      return await _incidentDao.getCriticalIncidents();
    } catch (e) {
      print('CustomerPetService.getCriticalIncidents: Error: $e');
      return [];
    }
  }

  // Business Logic Methods
  Future<bool> canPetCheckIn(String petId) async {
    // Check vaccination status
    final vaccinations = await getVaccinationsByPetId(petId);
    final hasExpiredVaccinations = vaccinations.any((v) => v.isExpired);
    
    if (hasExpiredVaccinations) {
      return false;
    }

    // Check required waivers
    final waivers = await getWaiversByPetId(petId);
    final requiredWaivers = waivers.where((w) => 
      w.isRequired == true && 
      (w.type == WaiverType.boardingConsent || w.type == WaiverType.liabilityWaiver)
    );
    
    final allRequiredWaiversSigned = requiredWaivers.every((w) => 
      w.status == WaiverStatus.signed && !w.isExpired
    );
    
    return allRequiredWaiversSigned;
  }

  Future<List<String>> getCheckInBlockingReasons(String petId) async {
    final reasons = <String>[];
    
    // Check vaccination status
    final vaccinations = await getVaccinationsByPetId(petId);
    final expiredVaccinations = vaccinations.where((v) => v.isExpired);
    
    if (expiredVaccinations.isNotEmpty) {
      for (final vaccination in expiredVaccinations) {
        reasons.add('Vaccination expired: ${vaccination.name} (${vaccination.expiryDate.toString().split(' ')[0]})');
      }
    }
    
    // Check required waivers
    final waivers = await getWaiversByPetId(petId);
    final requiredWaivers = waivers.where((w) => 
      w.isRequired == true && 
      (w.type == WaiverType.boardingConsent || w.type == WaiverType.liabilityWaiver)
    );
    
    for (final waiver in requiredWaivers) {
      if (waiver.status != WaiverStatus.signed) {
        reasons.add('Missing signed waiver: ${waiver.title}');
      } else if (waiver.isExpired) {
        reasons.add('Expired waiver: ${waiver.title} (${waiver.expiryDate?.toString().split(' ')[0] ?? 'Unknown'})');
      }
    }
    
    return reasons;
  }

  Future<List<Customer>> getCustomersNeedingFollowUp() async {
    final customers = await getAllCustomers();
    return customers.where((c) => c.needsFollowUp).toList();
  }

  Future<List<Pet>> getPetsWithExpiringVaccinations(int daysThreshold) async {
    final allPets = await getAllPets();
    final petsWithExpiringVaccinations = <Pet>[];
    
    for (final pet in allPets) {
      final vaccinations = await getVaccinationsByPetId(pet.id);
      final hasExpiringVaccinations = vaccinations.any((v) => 
        v.daysUntilExpiry <= daysThreshold && v.daysUntilExpiry > 0
      );
      
      if (hasExpiringVaccinations) {
        petsWithExpiringVaccinations.add(pet);
      }
    }
    
    return petsWithExpiringVaccinations;
  }

  Future<List<Pet>> getPetsNeedingSpecialCare() async {
    final allPets = await getAllPets();
    final petsNeedingSpecialCare = <Pet>[];
    
    for (final pet in allPets) {
      if (pet.specialNeeds != null && pet.specialNeeds!.isNotEmpty) {
        petsNeedingSpecialCare.add(pet);
      }
    }
    
    return petsNeedingSpecialCare;
  }

  Future<Map<String, dynamic>> getCustomerSummary(String customerId) async {
    final customer = await getCustomerById(customerId);
    if (customer == null) {
      throw Exception('Customer not found');
    }
    
    final pets = await getPetsByCustomerId(customerId);
    final waivers = await getWaiversByCustomerId(customerId);
    final incidents = await getIncidentsByCustomerId(customerId);
    
    // Calculate statistics
    int totalPets = pets.length;
    int activePets = pets.where((p) => p.isActive == true).length;
    int petsWithExpiredVaccinations = 0;
    int petsWithMissingWaivers = 0;
    int openIncidents = 0;
    
    for (final pet in pets) {
      final vaccinations = await getVaccinationsByPetId(pet.id);
      if (vaccinations.any((v) => v.isExpired)) {
        petsWithExpiredVaccinations++;
      }
      
      final petWaivers = waivers.where((w) => w.petId == pet.id);
      final requiredWaivers = petWaivers.where((w) => w.isRequired == true);
      if (requiredWaivers.any((w) => w.status != WaiverStatus.signed)) {
        petsWithMissingWaivers++;
      }
    }
    
    openIncidents = incidents.where((i) => i.isOpen).length;
    
    return {
      'customer': customer,
      'pets': pets,
      'waivers': waivers,
      'incidents': incidents,
      'statistics': {
        'totalPets': totalPets,
        'activePets': activePets,
        'petsWithExpiredVaccinations': petsWithExpiredVaccinations,
        'petsWithMissingWaivers': petsWithMissingWaivers,
        'openIncidents': openIncidents,
        'loyaltyPoints': customer.loyaltyPoints ?? 0,
        'loyaltyTier': customer.loyaltyTier?.name ?? 'none',
        'daysSinceLastVisit': customer.daysSinceLastVisit,
        'totalSpent': customer.totalSpent ?? 0.0,
      },
    };
  }
}
