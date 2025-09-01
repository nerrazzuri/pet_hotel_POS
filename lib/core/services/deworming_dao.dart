import 'package:cat_hotel_pos/features/customers/domain/entities/deworming_record.dart';

class DewormingDao {
  static final DewormingDao _instance = DewormingDao._internal();
  factory DewormingDao() => _instance;
  DewormingDao._internal();

  final List<DewormingRecord> _dewormingRecords = [];

  void _initialize() {
    if (_dewormingRecords.isEmpty) {
      final now = DateTime.now();
      
      _dewormingRecords.addAll([
        DewormingRecord(
          id: 'dw1',
          petId: 'pet_001',
          petName: 'Whiskers',
          customerId: 'cust_001',
          customerName: 'John Doe',
          type: DewormingType.broadSpectrum,
          productName: 'Drontal Plus',
          dosage: '1 tablet',
          frequency: 'Every 3 months',
          scheduledDate: now.subtract(const Duration(days: 30)),
          status: DewormingStatus.administered,
          createdAt: now.subtract(const Duration(days: 30)),
          updatedAt: now.subtract(const Duration(days: 30)),
          administeredDate: now.subtract(const Duration(days: 30)),
          administeredBy: 'Dr. Sarah Chen',
          veterinarianName: 'Dr. Sarah Chen',
          veterinarianPhone: '+60-3-1234-5678',
          clinicName: 'City Vet Clinic',
          batchNumber: 'DR-2024-001',
          manufacturer: 'Bayer',
          isPreventive: true,
          nextDueDate: now.add(const Duration(days: 60)),
          weightAtTime: 4.5,
          weightUnit: 'kg',
        ),
        DewormingRecord(
          id: 'dw2',
          petId: 'pet_002',
          petName: 'Buddy',
          customerId: 'cust_002',
          customerName: 'Jane Smith',
          type: DewormingType.roundworm,
          productName: 'Panacur',
          dosage: '2.5ml',
          frequency: 'Every 6 months',
          scheduledDate: now.add(const Duration(days: 15)),
          status: DewormingStatus.scheduled,
          createdAt: now.subtract(const Duration(days: 15)),
          updatedAt: now.subtract(const Duration(days: 15)),
          administeredBy: 'Dr. Michael Wong',
          veterinarianName: 'Dr. Michael Wong',
          veterinarianPhone: '+60-3-1234-5679',
          clinicName: 'Pet Care Clinic',
          batchNumber: 'PA-2024-002',
          manufacturer: 'Intervet',
          isPreventive: true,
          nextDueDate: now.add(const Duration(days: 15)),
          weightAtTime: 12.0,
          weightUnit: 'kg',
        ),
        DewormingRecord(
          id: 'dw3',
          petId: 'pet_003',
          petName: 'Luna',
          customerId: 'cust_003',
          customerName: 'Mike Johnson',
          type: DewormingType.heartworm,
          productName: 'Heartgard Plus',
          dosage: '1 chewable',
          frequency: 'Monthly',
          scheduledDate: now.subtract(const Duration(days: 5)),
          status: DewormingStatus.overdue,
          createdAt: now.subtract(const Duration(days: 35)),
          updatedAt: now.subtract(const Duration(days: 5)),
          administeredDate: now.subtract(const Duration(days: 35)),
          administeredBy: 'Dr. Sarah Chen',
          veterinarianName: 'Dr. Sarah Chen',
          veterinarianPhone: '+60-3-1234-5678',
          clinicName: 'City Vet Clinic',
          batchNumber: 'HG-2024-003',
          manufacturer: 'Merial',
          isPreventive: true,
          nextDueDate: now.subtract(const Duration(days: 5)),
          weightAtTime: 8.2,
          weightUnit: 'kg',
        ),
      ]);
    }
  }

  Future<List<DewormingRecord>> getAll() async {
    _initialize();
    return _dewormingRecords;
  }

  Future<DewormingRecord?> getById(String id) async {
    _initialize();
    try {
      return _dewormingRecords.firstWhere((record) => record.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<DewormingRecord>> getByPetId(String petId) async {
    _initialize();
    return _dewormingRecords.where((record) => record.petId == petId).toList();
  }

  Future<List<DewormingRecord>> getByCustomerId(String customerId) async {
    _initialize();
    return _dewormingRecords.where((record) => record.customerId == customerId).toList();
  }

  Future<List<DewormingRecord>> getByStatus(DewormingStatus status) async {
    _initialize();
    return _dewormingRecords.where((record) => record.status == status).toList();
  }

  Future<List<DewormingRecord>> getOverdue() async {
    _initialize();
    return _dewormingRecords.where((record) => record.isOverdue).toList();
  }

  Future<List<DewormingRecord>> getDueSoon() async {
    _initialize();
    return _dewormingRecords.where((record) => record.isDueSoon).toList();
  }

  Future<List<DewormingRecord>> getByType(DewormingType type) async {
    _initialize();
    return _dewormingRecords.where((record) => record.type == type).toList();
  }

  Future<DewormingRecord> create(DewormingRecord record) async {
    _initialize();
    final newRecord = record.copyWith(
      id: 'dw${_dewormingRecords.length + 1}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _dewormingRecords.add(newRecord);
    return newRecord;
  }

  Future<DewormingRecord> update(DewormingRecord record) async {
    _initialize();
    final index = _dewormingRecords.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      final updatedRecord = record.copyWith(
        updatedAt: DateTime.now(),
      );
      _dewormingRecords[index] = updatedRecord;
      return updatedRecord;
    }
    throw Exception('Deworming record not found');
  }

  Future<bool> delete(String id) async {
    _initialize();
    final index = _dewormingRecords.indexWhere((record) => record.id == id);
    if (index != -1) {
      _dewormingRecords.removeAt(index);
      return true;
    }
    return false;
  }

  Future<List<DewormingRecord>> getUpcoming(int daysThreshold) async {
    _initialize();
    final now = DateTime.now();
    final threshold = now.add(Duration(days: daysThreshold));
    
    return _dewormingRecords.where((record) => 
      record.nextDueDate != null && 
      record.nextDueDate!.isAfter(now) && 
      record.nextDueDate!.isBefore(threshold)
    ).toList();
  }

  Future<Map<String, dynamic>> getStatistics() async {
    _initialize();
    final total = _dewormingRecords.length;
    final administered = _dewormingRecords.where((r) => r.status == DewormingStatus.administered).length;
    final scheduled = _dewormingRecords.where((r) => r.status == DewormingStatus.scheduled).length;
    final overdue = _dewormingRecords.where((r) => r.isOverdue).length;
    final dueSoon = _dewormingRecords.where((r) => r.isDueSoon).length;

    return {
      'total': total,
      'administered': administered,
      'scheduled': scheduled,
      'overdue': overdue,
      'dueSoon': dueSoon,
      'completionRate': total > 0 ? (administered / total * 100).toStringAsFixed(1) : '0.0',
    };
  }
}
