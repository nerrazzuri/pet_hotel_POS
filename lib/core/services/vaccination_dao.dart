import 'package:cat_hotel_pos/features/customers/domain/entities/vaccination.dart';

class VaccinationDao {
  static final VaccinationDao _instance = VaccinationDao._internal();
  factory VaccinationDao() => _instance;
  VaccinationDao._internal();

  final List<Vaccination> _vaccinations = [];

  void _initialize() {
    if (_vaccinations.isEmpty) {
      final now = DateTime.now();
      
      _vaccinations.addAll([
        Vaccination(
          id: 'v1',
          petId: 'pet1',
          petName: 'Whiskers',
          customerId: 'cust1',
          customerName: 'John Smith',
          type: VaccinationType.rabies,
          name: 'Rabies Vaccine',
          administeredDate: now.subtract(const Duration(days: 180)),
          expiryDate: now.add(const Duration(days: 185)),
          administeredBy: 'Dr. Johnson',
          clinicName: 'City Vet Clinic',
          status: VaccinationStatus.upToDate,
          batchNumber: 'RB-2024-001',
          manufacturer: 'VetCorp',
          notes: 'Annual rabies vaccination',
          isRequired: true,
          blocksCheckIn: false,
          createdAt: now.subtract(const Duration(days: 180)),
          updatedAt: now.subtract(const Duration(days: 180)),
        ),
        Vaccination(
          id: 'v2',
          petId: 'pet1',
          petName: 'Whiskers',
          customerId: 'cust1',
          customerName: 'John Smith',
          type: VaccinationType.core,
          name: 'FVRCP Vaccine',
          administeredDate: now.subtract(const Duration(days: 90)),
          expiryDate: now.add(const Duration(days: 275)),
          administeredBy: 'Dr. Johnson',
          clinicName: 'City Vet Clinic',
          status: VaccinationStatus.upToDate,
          batchNumber: 'FV-2024-002',
          manufacturer: 'VetCorp',
          notes: 'Core vaccination series',
          isRequired: true,
          blocksCheckIn: false,
          createdAt: now.subtract(const Duration(days: 90)),
          updatedAt: now.subtract(const Duration(days: 90)),
        ),
        Vaccination(
          id: 'v3',
          petId: 'pet2',
          petName: 'Buddy',
          customerId: 'cust2',
          customerName: 'Sarah Wilson',
          type: VaccinationType.rabies,
          name: 'Rabies Vaccine',
          administeredDate: now.subtract(const Duration(days: 365)),
          expiryDate: now.subtract(const Duration(days: 5)),
          administeredBy: 'Dr. Brown',
          clinicName: 'Pet Care Center',
          status: VaccinationStatus.expired,
          batchNumber: 'RB-2023-003',
          manufacturer: 'VetCorp',
          notes: 'Annual rabies vaccination - EXPIRED',
          isRequired: true,
          blocksCheckIn: true,
          createdAt: now.subtract(const Duration(days: 365)),
          updatedAt: now.subtract(const Duration(days: 5)),
        ),
        Vaccination(
          id: 'v4',
          petId: 'pet2',
          petName: 'Buddy',
          customerId: 'cust2',
          customerName: 'Sarah Wilson',
          type: VaccinationType.dhpp,
          name: 'DHPP Vaccine',
          administeredDate: now.subtract(const Duration(days: 30)),
          expiryDate: now.add(const Duration(days: 25)),
          administeredBy: 'Dr. Brown',
          clinicName: 'Pet Care Center',
          status: VaccinationStatus.dueSoon,
          batchNumber: 'DH-2024-004',
          manufacturer: 'VetCorp',
          notes: 'Core vaccination - due soon',
          isRequired: true,
          blocksCheckIn: false,
          createdAt: now.subtract(const Duration(days: 30)),
          updatedAt: now.subtract(const Duration(days: 30)),
        ),
        Vaccination(
          id: 'v5',
          petId: 'pet3',
          petName: 'Luna',
          customerId: 'cust3',
          customerName: 'Mike Davis',
          type: VaccinationType.bordetella,
          name: 'Bordetella Vaccine',
          administeredDate: now.subtract(const Duration(days: 60)),
          expiryDate: now.add(const Duration(days: 305)),
          administeredBy: 'Dr. Garcia',
          clinicName: 'Animal Hospital',
          status: VaccinationStatus.upToDate,
          batchNumber: 'BO-2024-005',
          manufacturer: 'VetCorp',
          notes: 'Kennel cough prevention',
          isRequired: false,
          blocksCheckIn: false,
          createdAt: now.subtract(const Duration(days: 60)),
          updatedAt: now.subtract(const Duration(days: 60)),
        ),
      ]);
    }
  }

  Future<List<Vaccination>> getAll() async {
    _initialize();
    return List.unmodifiable(_vaccinations);
  }

  Future<Vaccination?> getById(String id) async {
    _initialize();
    try {
      return _vaccinations.firstWhere((v) => v.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Vaccination>> getByPetId(String petId) async {
    _initialize();
    return _vaccinations.where((v) => v.petId == petId).toList();
  }

  Future<List<Vaccination>> getByCustomerId(String customerId) async {
    _initialize();
    return _vaccinations.where((v) => v.customerId == customerId).toList();
  }

  Future<List<Vaccination>> getByStatus(VaccinationStatus status) async {
    _initialize();
    return _vaccinations.where((v) => v.status == status).toList();
  }

  Future<List<Vaccination>> getExpiringSoon(int daysThreshold) async {
    _initialize();
    final now = DateTime.now();
    final threshold = now.add(Duration(days: daysThreshold));
    
    return _vaccinations.where((v) => 
      v.expiryDate.isAfter(now) && v.expiryDate.isBefore(threshold)
    ).toList();
  }

  Future<List<Vaccination>> getExpired() async {
    _initialize();
    final now = DateTime.now();
    return _vaccinations.where((v) => v.expiryDate.isBefore(now)).toList();
  }

  Future<Vaccination> create(Vaccination vaccination) async {
    _initialize();
    final newVaccination = vaccination.copyWith(
      id: 'v${_vaccinations.length + 1}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _vaccinations.add(newVaccination);
    return newVaccination;
  }

  Future<Vaccination> update(Vaccination vaccination) async {
    _initialize();
    final index = _vaccinations.indexWhere((v) => v.id == vaccination.id);
    if (index != -1) {
      final updatedVaccination = vaccination.copyWith(
        updatedAt: DateTime.now(),
      );
      _vaccinations[index] = updatedVaccination;
      return updatedVaccination;
    }
    throw Exception('Vaccination not found');
  }

  Future<bool> delete(String id) async {
    _initialize();
    final index = _vaccinations.indexWhere((v) => v.id == id);
    if (index != -1) {
      _vaccinations.removeAt(index);
      return true;
    }
    return false;
  }

  Future<List<Vaccination>> search(String query) async {
    _initialize();
    final lowercaseQuery = query.toLowerCase();
    return _vaccinations.where((v) =>
      v.petName.toLowerCase().contains(lowercaseQuery) ||
      v.customerName.toLowerCase().contains(lowercaseQuery) ||
      v.name.toLowerCase().contains(lowercaseQuery) ||
      v.clinicName.toLowerCase().contains(lowercaseQuery) ||
      v.administeredBy.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  Future<Map<String, int>> getStatusCounts() async {
    _initialize();
    final counts = <String, int>{};
    for (final vaccination in _vaccinations) {
      final status = vaccination.status.name;
      counts[status] = (counts[status] ?? 0) + 1;
    }
    return counts;
  }

  Future<Map<String, int>> getTypeCounts() async {
    _initialize();
    final counts = <String, int>{};
    for (final vaccination in _vaccinations) {
      final type = vaccination.type.name;
      counts[type] = (counts[type] ?? 0) + 1;
    }
    return counts;
  }
}
