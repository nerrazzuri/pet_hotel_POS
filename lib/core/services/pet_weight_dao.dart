import 'package:cat_hotel_pos/features/customers/domain/entities/pet_weight_record.dart';

class PetWeightDao {
  static final PetWeightDao _instance = PetWeightDao._internal();
  factory PetWeightDao() => _instance;
  PetWeightDao._internal();

  final List<PetWeightRecord> _weightRecords = [];

  void _initialize() {
    if (_weightRecords.isEmpty) {
      final now = DateTime.now();
      
      _weightRecords.addAll([
        PetWeightRecord(
          id: 'wr1',
          petId: 'pet_001',
          petName: 'Whiskers',
          customerId: 'cust_001',
          customerName: 'John Doe',
          weight: 4.5,
          unit: WeightUnit.kg,
          type: WeightRecordType.routine,
          recordedAt: now.subtract(const Duration(days: 30)),
          createdAt: now.subtract(const Duration(days: 30)),
          updatedAt: now.subtract(const Duration(days: 30)),
          recordedBy: 'Dr. Sarah Chen',
          notes: 'Routine weight check - healthy weight',
          location: 'City Vet Clinic',
          equipment: 'Digital scale',
          isAccurate: true,
          bodyConditionScore: '3',
        ),
        PetWeightRecord(
          id: 'wr2',
          petId: 'pet_001',
          petName: 'Whiskers',
          customerId: 'cust_001',
          customerName: 'John Doe',
          weight: 4.3,
          unit: WeightUnit.kg,
          type: WeightRecordType.preBoarding,
          recordedAt: now.subtract(const Duration(days: 15)),
          createdAt: now.subtract(const Duration(days: 15)),
          updatedAt: now.subtract(const Duration(days: 15)),
          recordedBy: 'Staff Member',
          notes: 'Pre-boarding weight check',
          location: 'Cat Hotel',
          equipment: 'Digital scale',
          isAccurate: true,
          previousWeight: 4.5,
          previousUnit: WeightUnit.kg,
          weightChange: -0.2,
          weightChangeUnit: 'kg',
          bodyConditionScore: '3',
        ),
        PetWeightRecord(
          id: 'wr3',
          petId: 'pet_001',
          petName: 'Whiskers',
          customerId: 'cust_001',
          customerName: 'John Doe',
          weight: 4.4,
          unit: WeightUnit.kg,
          type: WeightRecordType.postBoarding,
          recordedAt: now.subtract(const Duration(days: 5)),
          createdAt: now.subtract(const Duration(days: 5)),
          updatedAt: now.subtract(const Duration(days: 5)),
          recordedBy: 'Staff Member',
          notes: 'Post-boarding weight check - slight weight gain',
          location: 'Cat Hotel',
          equipment: 'Digital scale',
          isAccurate: true,
          previousWeight: 4.3,
          previousUnit: WeightUnit.kg,
          weightChange: 0.1,
          weightChangeUnit: 'kg',
          bodyConditionScore: '3',
        ),
        PetWeightRecord(
          id: 'wr4',
          petId: 'pet_002',
          petName: 'Buddy',
          customerId: 'cust_002',
          customerName: 'Jane Smith',
          weight: 12.0,
          unit: WeightUnit.kg,
          type: WeightRecordType.vaccination,
          recordedAt: now.subtract(const Duration(days: 20)),
          createdAt: now.subtract(const Duration(days: 20)),
          updatedAt: now.subtract(const Duration(days: 20)),
          recordedBy: 'Dr. Michael Wong',
          notes: 'Weight check during vaccination visit',
          location: 'Pet Care Clinic',
          equipment: 'Veterinary scale',
          isAccurate: true,
          bodyConditionScore: '4',
        ),
        PetWeightRecord(
          id: 'wr5',
          petId: 'pet_003',
          petName: 'Luna',
          customerId: 'cust_003',
          customerName: 'Mike Johnson',
          weight: 8.2,
          unit: WeightUnit.kg,
          type: WeightRecordType.medical,
          recordedAt: now.subtract(const Duration(days: 10)),
          createdAt: now.subtract(const Duration(days: 10)),
          updatedAt: now.subtract(const Duration(days: 10)),
          recordedBy: 'Dr. Sarah Chen',
          notes: 'Weight check during medical examination',
          location: 'City Vet Clinic',
          equipment: 'Veterinary scale',
          isAccurate: true,
          previousWeight: 8.5,
          previousUnit: WeightUnit.kg,
          weightChange: -0.3,
          weightChangeUnit: 'kg',
          bodyConditionScore: '2',
        ),
        PetWeightRecord(
          id: 'wr6',
          petId: 'pet_004',
          petName: 'Max',
          customerId: 'cust_004',
          customerName: 'Sarah Wilson',
          weight: 6.8,
          unit: WeightUnit.kg,
          type: WeightRecordType.grooming,
          recordedAt: now.subtract(const Duration(days: 3)),
          createdAt: now.subtract(const Duration(days: 3)),
          updatedAt: now.subtract(const Duration(days: 3)),
          recordedBy: 'Groomer',
          notes: 'Weight check before grooming session',
          location: 'Grooming Salon',
          equipment: 'Digital scale',
          isAccurate: true,
          bodyConditionScore: '3',
        ),
      ]);
    }
  }

  Future<List<PetWeightRecord>> getAll() async {
    _initialize();
    return _weightRecords;
  }

  Future<PetWeightRecord?> getById(String id) async {
    _initialize();
    try {
      return _weightRecords.firstWhere((record) => record.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<PetWeightRecord>> getByPetId(String petId) async {
    _initialize();
    return _weightRecords.where((record) => record.petId == petId).toList();
  }

  Future<List<PetWeightRecord>> getByCustomerId(String customerId) async {
    _initialize();
    return _weightRecords.where((record) => record.customerId == customerId).toList();
  }

  Future<List<PetWeightRecord>> getByType(WeightRecordType type) async {
    _initialize();
    return _weightRecords.where((record) => record.type == type).toList();
  }

  Future<List<PetWeightRecord>> getByDateRange(DateTime startDate, DateTime endDate) async {
    _initialize();
    return _weightRecords.where((record) => 
      record.recordedAt.isAfter(startDate) && record.recordedAt.isBefore(endDate)
    ).toList();
  }

  Future<PetWeightRecord?> getLatestByPetId(String petId) async {
    _initialize();
    final records = _weightRecords.where((record) => record.petId == petId).toList();
    if (records.isEmpty) return null;
    
    records.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return records.first;
  }

  Future<PetWeightRecord?> getPreviousByPetId(String petId, DateTime currentDate) async {
    _initialize();
    final records = _weightRecords
        .where((record) => record.petId == petId && record.recordedAt.isBefore(currentDate))
        .toList();
    
    if (records.isEmpty) return null;
    
    records.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return records.first;
  }

  Future<PetWeightRecord> create(PetWeightRecord record) async {
    _initialize();
    
    // Calculate weight change if previous record exists
    final previousRecord = await getPreviousByPetId(record.petId, record.recordedAt);
    PetWeightRecord newRecord = record;
    
    if (previousRecord != null) {
      final weightChange = record.weight - previousRecord.weight;
      newRecord = record.copyWith(
        previousWeight: previousRecord.weight,
        previousUnit: previousRecord.unit,
        weightChange: weightChange,
        weightChangeUnit: record.unit.shortName,
      );
    }
    
    final finalRecord = newRecord.copyWith(
      id: 'wr${_weightRecords.length + 1}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    _weightRecords.add(finalRecord);
    return finalRecord;
  }

  Future<PetWeightRecord> update(PetWeightRecord record) async {
    _initialize();
    final index = _weightRecords.indexWhere((r) => r.id == record.id);
    if (index != -1) {
      final updatedRecord = record.copyWith(
        updatedAt: DateTime.now(),
      );
      _weightRecords[index] = updatedRecord;
      return updatedRecord;
    }
    throw Exception('Weight record not found');
  }

  Future<bool> delete(String id) async {
    _initialize();
    final index = _weightRecords.indexWhere((record) => record.id == id);
    if (index != -1) {
      _weightRecords.removeAt(index);
      return true;
    }
    return false;
  }

  Future<Map<String, dynamic>> getWeightTrend(String petId, {int days = 30}) async {
    _initialize();
    final now = DateTime.now();
    final startDate = now.subtract(Duration(days: days));
    
    final records = _weightRecords
        .where((record) => record.petId == petId && record.recordedAt.isAfter(startDate))
        .toList();
    
    if (records.isEmpty) {
      return {
        'trend': 'No data',
        'change': 0.0,
        'changePercent': 0.0,
        'records': [],
      };
    }
    
    records.sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    
    final firstWeight = records.first.weight;
    final lastWeight = records.last.weight;
    final weightChange = lastWeight - firstWeight;
    final changePercent = firstWeight > 0 ? (weightChange / firstWeight * 100) : 0.0;
    
    String trend;
    if (weightChange > 0.1) {
      trend = 'Gaining';
    } else if (weightChange < -0.1) {
      trend = 'Losing';
    } else {
      trend = 'Stable';
    }
    
    return {
      'trend': trend,
      'change': weightChange,
      'changePercent': changePercent,
      'records': records,
      'firstWeight': firstWeight,
      'lastWeight': lastWeight,
    };
  }

  Future<Map<String, dynamic>> getStatistics() async {
    _initialize();
    final total = _weightRecords.length;
    final uniquePets = _weightRecords.map((r) => r.petId).toSet().length;
    final thisMonth = _weightRecords.where((r) => 
      r.recordedAt.month == DateTime.now().month && r.recordedAt.year == DateTime.now().year
    ).length;
    
    return {
      'total': total,
      'uniquePets': uniquePets,
      'thisMonth': thisMonth,
      'averagePerPet': uniquePets > 0 ? (total / uniquePets).toStringAsFixed(1) : '0.0',
    };
  }
}
